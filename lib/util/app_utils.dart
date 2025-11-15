import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_nest_app/components/hud_message.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/services/data_sync_service.dart';
import 'package:money_nest_app/services/bitflyer_api.dart';
import 'package:money_nest_app/util/global_store.dart';

class AppUtils {
  factory AppUtils() {
    return _singleton;
  }
  AppUtils._internal();
  static final AppUtils _singleton = AppUtils._internal();

  // -------------------------------------------------
  // 触发完整数据拉取（用户资料、持仓、交易记录）
  //（登录成功时/App cold start/foreground）
  // -------------------------------------------------
  Future<void> initializeAppData(DataSyncService dataSync, bool isLogin) async {
    try {
      print('AppUtils.initializeAppData() starting...');
      if (GlobalStore().userId == null ||
          GlobalStore().userId!.isEmpty ||
          GlobalStore().accountId == null ||
          GlobalStore().accountId! <= 0) {
        print('User ID or Account ID is not set in GlobalStore');
        return;
        //throw Exception('User ID or Account ID is not set in GlobalStore');
      }

      final userId = GlobalStore().userId!;
      final accountId = GlobalStore().accountId!;
      bool needSync = false;

      if (!isLogin) {
        // 冷启动或前台启动时，校验是否需要同步数据
        needSync = await dataSync.checkIfNeedSyncUserData(userId, accountId);
      }

      if (isLogin || needSync) {
        // 获取用户持仓等信息并同步到本地数据库
        await dataSync.syncUserDataIfNeeded(userId, accountId);

        // 计算并保存持仓到 SharedPreferences
        await calculateAndSavePortfolio(dataSync.db, userId, accountId);
      } else {
        print('No need to sync user data at this time.');
      }
      print('AppUtils.initializeAppData() completed successfully');
    } catch (e) {
      print('AppUtils.initializeAppData() error: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // -------------------------------------------------
  // 整理当前持仓到 SharedPreferences
  // -------------------------------------------------
  Future<void> calculateAndSavePortfolio(
    AppDatabase db,
    userId,
    int accountId,
  ) async {
    // 1. 计算当前持仓
    // 查询所有 buy 批次
    final buyRecords =
        await (db.select(db.tradeRecords)..where(
              (tbl) =>
                  tbl.userId.equals(userId) &
                  tbl.accountId.equals(accountId) &
                  tbl.action.equals('buy'),
            ))
            .get();

    // 查询所有 sell mapping
    final sellMappings = await db.select(db.tradeSellMappings).get();

    // 查询所有股票信息
    final stocks = await db.select(db.stocks).get();
    final stockMap = {for (var s in stocks) s.id: s};

    // 统计每个 buy 批次已卖出数量
    final Map<int, num> buyIdToSoldQty = {};
    for (final mapping in sellMappings) {
      buyIdToSoldQty[mapping.buyId] =
          (buyIdToSoldQty[mapping.buyId] ?? 0) + mapping.quantity;
    }

    // 组装持仓
    final List<Map<String, dynamic>> portfolio = [];
    for (final buy in buyRecords) {
      final soldQty = buyIdToSoldQty[buy.id] ?? 0;
      final remainQty = buy.quantity - soldQty;
      if (remainQty <= 0) continue;
      final remainFee = (buy.feeAmount! / buy.quantity) * remainQty; // 按比例分摊手续费
      final stock = stockMap[buy.assetId];
      if (stock == null) continue;
      portfolio.add({
        'stockId': stock.id,
        'code': stock.ticker,
        'name': stock.name,
        'nameUs': stock.nameUs,
        'exchange': stock.exchange,
        'currency': stock.currency,
        'tradeDate': DateFormat('yyyy-MM-dd').format(buy.tradeDate),
        'quantity': remainQty,
        'buyPrice': buy.price,
        'fee': remainFee,
        'feeCurrency': buy.feeCurrency,
        'logo': stock.logo,
      });
    }

    // 2. 保存到 GlobalStore 并持久化
    GlobalStore().portfolio = portfolio;
    await GlobalStore().savePortfolioToPrefs();
  }

  // -------------------------------------------------
  // 刷新总资产和总成本
  // (切换页面时/手动触发)
  // -------------------------------------------------
  Future<void> refreshTotalAssetsAndCosts(DataSyncService dataSync) async {
    try {
      print('开始刷新总资产和总成本...');

      // 同步加密货币数据
      final dbCryptoInfos = await dataSync.getCryptoDataFromDB();

      for (var cryptoInfo in dbCryptoInfos) {
        await dataSync.syncCryptoBalanceDataFromServer(cryptoInfo);
        if (GlobalStore()
            .cryptoBalanceDataCache[cryptoInfo.cryptoExchange
                .toLowerCase()]!['balances']!
            .isNotEmpty) {
          for (var balance
              in GlobalStore().cryptoBalanceDataCache[cryptoInfo.cryptoExchange
                  .toLowerCase()]!['balances']!) {
            if (balance['currency_code'] as String == 'JPY' ||
                balance['amount'] as double == 0.0) {
              continue;
            }
            await dataSync.syncCryptoBalanceHistoryDataFromServer(
              cryptoInfo,
              balance['currency_code'] as String,
            );
          }
        }
      }

      // 取得总资产和总成本
      final assetsAndCostsMap = await _getTotalAssetsAndCostsValue(
        dataSync,
        dbCryptoInfos,
      );

      GlobalStore().totalAssetsAndCostsMap = assetsAndCostsMap;
      GlobalStore().saveTotalAssetsAndCostsMapToPrefs();
    } catch (e) {
      print('Error refreshing total assets and costs: $e');
    }
  }

  // -------------------------------------------------
  // 计算并保存历史持仓到 SharedPreferences
  // -------------------------------------------------
  Future<void> calculateAndSaveHistoricalPortfolioToPrefs(
    AppDatabase db,
  ) async {
    final historicalPortfolio = <DateTime, dynamic>{};
    final userId = GlobalStore().userId;
    final accountId = GlobalStore().accountId;
    if (userId == null || accountId == null) return;
    // -------------------------------------------------
    // 1. 查询所有交易记录
    // -------------------------------------------------
    final tradeQuery =
        db.select(db.stocks).join([
            innerJoin(
              db.tradeRecords,
              db.tradeRecords.assetId.equalsExp(db.stocks.id),
            ),
          ])
          ..where(db.tradeRecords.userId.equals(userId))
          ..where(db.tradeRecords.accountId.equals(accountId))
          ..where(db.tradeRecords.assetType.equals('stock'))
          ..orderBy([
            OrderingTerm.asc(db.tradeRecords.tradeDate),
            OrderingTerm.asc(db.tradeRecords.id),
          ]);

    // -------------------------------------------------
    // 2. 查询所有卖出mapping记录
    // -------------------------------------------------
    final sellMappingQuery =
        db.select(db.tradeSellMappings).join([
            innerJoin(
              db.tradeRecords,
              db.tradeRecords.id.equalsExp(db.tradeSellMappings.sellId),
            ),
          ])
          ..where(db.tradeRecords.userId.equals(userId))
          ..where(db.tradeRecords.accountId.equals(accountId))
          ..where(db.tradeRecords.assetType.equals('stock'))
          ..orderBy([
            OrderingTerm.asc(db.tradeSellMappings.sellId),
            OrderingTerm.asc(db.tradeSellMappings.buyId),
          ]);

    final tradeRows = await tradeQuery.get();
    final sellMappingRows = await sellMappingQuery.get();

    if (tradeRows.isEmpty) {
      GlobalStore().historicalPortfolio = historicalPortfolio;
      await GlobalStore().saveHistoricalPortfolioToPrefs();
      return;
    }

    // -------------------------------------------------
    // 3. 按日期分组交易 & 映射
    // -------------------------------------------------
    final tradesByDate = <DateTime, List<dynamic>>{};
    for (var row in tradeRows) {
      final trade = row.readTable(db.tradeRecords);
      final date = DateTime(
        trade.tradeDate.year,
        trade.tradeDate.month,
        trade.tradeDate.day,
      );
      tradesByDate.putIfAbsent(date, () => []).add(row);
    }

    final sellMappingsBySellId = <int, List<dynamic>>{};
    for (var m in sellMappingRows) {
      final sellId = m.readTable(db.tradeSellMappings).sellId;
      sellMappingsBySellId.putIfAbsent(sellId, () => []).add(m);
    }

    // -------------------------------------------------
    // 4. 循环每一天
    // -------------------------------------------------
    DateTime firstTradeDate = tradeRows.first
        .readTable(db.tradeRecords)
        .tradeDate;
    DateTime currentDate = DateTime(
      firstTradeDate.year,
      firstTradeDate.month,
      firstTradeDate.day,
    );
    DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final holdings = <int, Map<String, dynamic>>{};

    while (currentDate.isBefore(today)) {
      final todaysTrades = tradesByDate[currentDate] ?? [];

      for (var row in todaysTrades) {
        final trade = row.readTable(db.tradeRecords);
        final stock = row.readTable(db.stocks);

        // ---------------------------
        // 买入
        // ---------------------------
        if (trade.action == 'buy') {
          holdings.putIfAbsent(
            stock.id,
            () => {
              'ticker': stock.ticker,
              'currency': stock.currency,
              'trades': <Map<String, dynamic>>[],
            },
          );
          (holdings[stock.id]!['trades'] as List).add({
            'id': trade.id,
            'quantity': trade.quantity,
            'price': trade.price,
            'feeAmount': trade.feeAmount,
            'feeCurrency': trade.feeCurrency,
          });
        }
        // ---------------------------
        // 卖出
        // ---------------------------
        else if (trade.action == 'sell') {
          final mappings = sellMappingsBySellId[trade.id] ?? [];

          for (var mappingRow in mappings) {
            final mapping = mappingRow.readTable(db.tradeSellMappings);
            final sellQuantity = mapping.quantity;
            final buyId = mapping.buyId;

            // 找到对应的买入交易
            for (var holding in holdings.values) {
              final tradesList =
                  holding['trades'] as List<Map<String, dynamic>>;
              final idx = tradesList.indexWhere((t) => t['id'] == buyId);
              if (idx == -1) continue;

              final existingBuyTrade = tradesList[idx];
              final remainingQty = existingBuyTrade['quantity'] - sellQuantity;

              if (remainingQty > 0) {
                // ✅ 按比例调整手续费
                existingBuyTrade['feeAmount'] =
                    (existingBuyTrade['feeAmount'] ?? 0) *
                    (remainingQty / existingBuyTrade['quantity']);
                existingBuyTrade['quantity'] = remainingQty;
              } else {
                tradesList.removeAt(idx);
              }

              break;
            }
          }
        }
      }

      // 保存当天持仓（深拷贝）
      historicalPortfolio[currentDate] = {
        'holdings': jsonDecode(jsonEncode(_toEncodable(holdings))),
        'assetsTotal': null,
        'costBasis': null,
      };

      // -------------------------------------------------
      // ↓ 以下为原注释部分（保留）
      // -------------------------------------------------
      /*
    //double totalAsset = 0.0;
    //double totalCostBasis = 0.0;

    Map<String, double> dailyTotal = {};
    Map<String, double> dailyCostBasis = {};

    for (var entry in holdings.entries) {
      final stockId = entry.key;
      // 从stock_prices中查找当前价格
      final priceQuery = db.stockPrices.select()
        ..where((tbl) => tbl.stockId.equals(stockId))
        ..where((tbl) => tbl.priceAt.isSmallerOrEqualValue(currentDate))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.priceAt)])
        ..limit(1);
      final currentPrice = await priceQuery.getSingleOrNull();
      historicalPortfolio[currentDate]['holdings'].add(holdings[stockId]);
      // 计算该股票的总价值
      for (var trade in (holdings[stockId]!['trades'] as List)) {
        dailyTotal[holdings[stockId]!['stock'].currency] =
            (dailyTotal[holdings[stockId]!['stock'].currency] ?? 0) +
            trade.quantity * (currentPrice?.price ?? 0.0);
        dailyCostBasis[holdings[stockId]!['stock'].currency] =
            (dailyCostBasis[holdings[stockId]!['stock'].currency] ?? 0) +
            (trade.quantity * trade.price) +
            (trade.feeAmount ?? 0) *
                (rates[trade.feeCurrency! +
                        holdings[stockId]!['stock'].currency] ??
                    1.0);
      }
    }
    */

      currentDate = currentDate.add(const Duration(days: 1));
    }

    // -------------------------------------------------
    // 5. 保存结果
    // -------------------------------------------------
    GlobalStore().historicalPortfolio = historicalPortfolio;
    await GlobalStore().saveHistoricalPortfolioToPrefs();
  }

  // -------------------------------------------------
  // 显示成功 HUD 提示
  // -------------------------------------------------
  Future<void> showSuccessHUD(
    BuildContext context, {
    String message = '保存しました',
    Duration duration = const Duration(milliseconds: 1200),
  }) async {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (_) => HUDMessage(message: message, duration: duration),
    );

    overlay.insert(overlayEntry);

    await Future.delayed(duration);
    overlayEntry.remove();
  }

  // -------------------------------------------------
  // 格式化数字到小数点后两位
  // -------------------------------------------------
  double formatNumberByTwoDigits(double num) {
    return double.parse(num.toStringAsFixed(2));
  }

  // -------------------------------------------------
  // 根据货币代码格式化金额显示（带正负号）
  // -------------------------------------------------
  String formatProfit(double profit, String currencyCode) {
    final symbol = profit > 0 ? '+' : (profit < 0 ? '-' : '');
    final currency = Currency.values.firstWhere(
      (c) => c.code == currencyCode,
      orElse: () => Currency.jpy,
    );
    return '$symbol${NumberFormat.currency(locale: currency.locale, symbol: currency.symbol).format(profit.abs())}';
  }

  // -------------------------------------------------
  // 根据货币代码格式化金额显示
  // -------------------------------------------------
  String formatMoney(double money, String currencyCode) {
    final currency = Currency.values.firstWhere(
      (c) => c.code == currencyCode,
      orElse: () => Currency.jpy,
    );
    return NumberFormat.currency(
      locale: currency.locale,
      symbol: currency.symbol,
    ).format(money);
  }

  // -------------------------------------------------
  // 判断两个日期是否为同一天
  // -------------------------------------------------
  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // --------- 以下为私有方法 ---------

  // -------------------------------------------------
  // 计算最新的总资产和总成本
  // -------------------------------------------------
  Future<Map<String, Map<String, double>>> _getTotalAssetsAndCostsValue(
    DataSyncService dataSync,
    List<CryptoInfoData> dbCryptoInfos,
  ) async {
    print('=== getTotalAssetsAndCostsValue 开始 ===');

    double stockTotalAssets = 0.0;
    double stockTotalCosts = 0.0;
    final selectedCurrencyCode = GlobalStore().selectedCurrencyCode;

    // 获取最新股票价格
    try {
      final updated = await dataSync.getStockPricesByYHFinanceAPI();
      if (!updated) {
        print('获取股票价格失败或无更新，返回缓存的总资产和总成本');
        return GlobalStore().totalAssetsAndCostsMap;
      }
    } catch (e) {
      print('获取股票价格失败: $e');
    }

    // 计算股票总资产和总成本
    for (var item in GlobalStore().portfolio) {
      final qty = item['quantity'] as num? ?? 0;
      final buyPrice = item['buyPrice'] as num? ?? 0;
      final code = item['code'] as String? ?? '';
      final exchange = item['exchange'] as String? ?? 'JP';
      final currency = item['currency'] as String? ?? 'JPY';
      final fee = item['fee'] as num? ?? 0;
      final feeCurrency = item['feeCurrency'] as String? ?? currency;

      final rate =
          GlobalStore()
              .currentStockPrices['${currency == 'USD' ? '' : currency}${selectedCurrencyCode ?? 'JPY'}=X'] ??
          1.0;
      final feeRate =
          GlobalStore()
              .currentStockPrices['${feeCurrency == 'USD' ? '' : feeCurrency}${selectedCurrencyCode ?? 'JPY'}=X'] ??
          1.0;
      final currentPrice =
          GlobalStore().currentStockPrices[exchange == 'JP'
              ? '$code.T'
              : code] ??
          buyPrice;

      stockTotalAssets += qty * currentPrice * rate;
      stockTotalCosts += qty * buyPrice * rate + fee * feeRate;
    }

    // 计算加密资产总资产和总成本
    double cryptoTotalAssets = 0.0;
    double cryptoTotalCosts = 0.0;
    final cryptoBalanceCache = GlobalStore().cryptoBalanceDataCache;

    for (var exchangeEntry in cryptoBalanceCache.entries) {
      final exchange = exchangeEntry.key;
      final balances = exchangeEntry.value['balances'];

      if (balances != null && balances.isNotEmpty) {
        CryptoInfoData? cryptoInfo;
        try {
          cryptoInfo = dbCryptoInfos.firstWhere(
            (info) => info.cryptoExchange.toLowerCase() == exchange,
          );
        } catch (_) {
          cryptoInfo = null;
          print('未找到匹配的 cryptoInfo for $exchange');
        }

        if (cryptoInfo == null) {
          print('No crypto info found for exchange: $exchange');
          continue;
        }

        for (var balance in balances) {
          try {
            final currencyCode = balance['currency_code'];
            final amount = balance['amount'];

            if (currencyCode == 'JPY' || amount <= 0.0) {
              continue;
            }

            final rate =
                GlobalStore()
                    .currentStockPrices['JPY$selectedCurrencyCode=X'] ??
                1.0;
            double currentPrice =
                GlobalStore().currentStockPrices['$currencyCode-JPY'] ?? 0.0;

            if (currentPrice == 0.0) {
              if (cryptoInfo.cryptoExchange.toLowerCase() == 'bitflyer') {
                try {
                  final api = BitflyerApi(
                    cryptoInfo.apiKey,
                    cryptoInfo.apiSecret,
                  );
                  final Map<String, dynamic> tickerData = await api.getTicker(
                    true,
                    '${currencyCode}_JPY',
                  );
                  currentPrice = (tickerData['ltp'] as num?)?.toDouble() ?? 0.0;
                } catch (e) {
                  print('BitFlyer API 调用失败: $e');
                  currentPrice = 0.0;
                }
              }
            }

            if (currentPrice > 0) {
              cryptoTotalAssets += amount * currentPrice * rate;

              try {
                final cost = await _calculateCryptoCost(
                  cryptoInfo,
                  currencyCode,
                  amount,
                  currentPrice,
                );
                cryptoTotalCosts += cost * rate;
              } catch (e) {
                print('计算加密货币成本失败: $e');
              }
            } else {
              print('跳过 $currencyCode (价格为0)');
            }
          } catch (e) {
            print('处理余额数据时出错: $e');
            continue;
          }
        }
      }
    }

    final result = {
      'stock': {'totalAssets': stockTotalAssets, 'totalCosts': stockTotalCosts},
      'crypto': {
        'totalAssets': cryptoTotalAssets,
        'totalCosts': cryptoTotalCosts,
      },
    };

    print('=== getTotalAssetsAndCostsValue 结束 ===');
    //print('返回结果: $result');
    return result;
  }

  // -------------------------------------------------
  // 计算加密资产的成本
  // -------------------------------------------------
  Future<double> _calculateCryptoCost(
    CryptoInfoData cryptoInfo,
    String currencyCode,
    double totalAmount,
    double currentPrice,
  ) async {
    print('=== calculateCryptoCost 开始 ===');
    print(
      '参数: exchange=${cryptoInfo.cryptoExchange}, currency=$currencyCode, amount=$totalAmount',
    );

    if (cryptoInfo.cryptoExchange.isEmpty || currencyCode.isEmpty) {
      print('参数为空，返回 0');
      return 0.0;
    }

    double totalCost = 0.0;
    double currentAmount = 0.0;

    if (cryptoInfo.cryptoExchange.toLowerCase() == 'bitflyer') {
      // 获取余额历史数据
      try {
        final balanceHistoryData = GlobalStore()
            .cryptoBalanceDataCache['bitflyer']?['balanceHistory_$currencyCode'];

        if (balanceHistoryData == null) {
          print('没有找到余额历史数据: balanceHistory_$currencyCode');
          return 0.0;
        }

        final bitflyerbalanceHistory = balanceHistoryData;
        print('余额历史数据条数: ${bitflyerbalanceHistory.length}');

        if (bitflyerbalanceHistory.isEmpty) {
          print('余额历史为空');
          return totalCost;
        }

        for (var historyData in bitflyerbalanceHistory) {
          try {
            final tradeType = historyData['trade_type']?.toString();
            final amount = (historyData['amount'] as num?)?.toDouble() ?? 0.0;
            final price = (historyData['price'] as num?)?.toDouble() ?? 0.0;

            final remaining = totalAmount - currentAmount;

            switch (tradeType) {
              case 'BUY':
                final buyQty = amount.abs();
                if (buyQty >= remaining) {
                  totalCost += remaining * price;
                  currentAmount += remaining;
                } else {
                  totalCost += buyQty * price;
                  currentAmount += buyQty;
                }
                break;

              case 'SELL':
              case 'WITHDRAW':
              case 'CANCEL_COLL':
              case 'PAYMENT':
              case 'FEE':
                // 倒推时要加回减少的数量
                currentAmount -= amount.abs();
                break;

              case 'DEPOSIT':
              case 'RECEIVE':
              case 'POST_COLL':
                final recvQty = amount.abs();
                if (recvQty >= remaining) {
                  totalCost += remaining * currentPrice;
                  currentAmount += remaining;
                  break;
                } else {
                  totalCost += recvQty * currentPrice;
                  currentAmount += recvQty;
                }
                break;

              default:
                // 其他类型忽略
                break;
            }

            if (currentAmount < 0 || currentAmount >= totalAmount) break;
          } catch (e) {
            print('处理历史数据项时出错: $e');
            continue;
          }
        }
      } catch (e) {
        print('处理余额历史数据时出错: $e');
        return 0.0;
      }
    }

    print('=== calculateCryptoCost 结束 ===');
    print('计算结果: totalCost=$totalCost, currentAmount=$currentAmount');

    return totalCost;
  }

  // -------------------------------------------------
  // 将复杂对象转换为 JSON 可序列化的格式
  // -------------------------------------------------
  dynamic _toEncodable(dynamic value) {
    if (value is DateTime) {
      return value.toIso8601String();
    } else if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _toEncodable(v)));
    } else if (value is Iterable) {
      return value.map(_toEncodable).toList();
    } else if (value is num ||
        value is String ||
        value is bool ||
        value == null) {
      return value;
    } else {
      // 其他 Drift 实体对象，尝试调用 toJson 或转字符串
      try {
        return (value as dynamic).toJson?.call() ?? value.toString();
      } catch (_) {
        return value.toString();
      }
    }
  }

  // -------------------------------------------------
  // 取得指定日期的汇率
  // -------------------------------------------------
  Future<Map<String, double>> _currencyExchangeRate(
    DateTime baseDate,
    AppDatabase db,
  ) async {
    // 汇总所有货币的总资产, 并进行货币转换
    final fxRateQuery = db.fxRates.select()
      ..where((tbl) => tbl.fxPairId.equals(1))
      ..where((tbl) => tbl.rateDate.isSmallerOrEqualValue(baseDate))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.rateDate)])
      ..limit(1);

    final fxRate = await fxRateQuery.getSingleOrNull();
    final Map<String, double> rates = {}; // 货币对汇率，如
    rates['USDJPY'] = fxRate?.rate ?? 150.0;
    rates['JPYUSD'] = 1 / rates['USDJPY']!;

    return rates;
  }
}
