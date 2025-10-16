import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/util/global_store.dart';

class AppUtils {
  factory AppUtils() {
    return _singleton;
  }
  AppUtils._internal();
  static final AppUtils _singleton = AppUtils._internal();

  // API Keys and URLs
  String supabaseApiUrl =
      'https://yeciaqfdlznrstjhqfxu.supabase.co/functions/v1/money_grow_api';
  String supabaseApiKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InllY2lhcWZkbHpucnN0amhxZnh1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MDE3NTIsImV4cCI6MjA3MTk3Nzc1Mn0.QXWNGKbr9qjeBLYRWQHEEBMT1nfNKZS3vne-Za38bOc';
  String yahooFinanceApiKey =
      '003c4869d0msh2ea657dbb66bd59p1e94f4jsn72dabcb8d29a';
  String yahooFinanceApiHost = 'yahoo-finance15.p.rapidapi.com';
  String yahooFinanceApiUrl =
      'https://yahoo-finance15.p.rapidapi.com/api/v1/markets/stock/quotes';
  // 数据库实例
  final db = AppDatabase();

  // -------------------------------------------------
  // 获取股票搜索建议
  // -------------------------------------------------
  Future<List<Stock>> fetchStockSuggestions(
    String value,
    String exchange,
  ) async {
    final url = Uri.parse(
      '${AppUtils().supabaseApiUrl}/stock-search?q=$value&exchange=$exchange&limit=5',
    );
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${AppUtils().supabaseApiKey}'},
    );

    List<Stock> result = [];
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] is List) {
        result = (data['results'] as List)
            .map(
              (item) => Stock(
                id: item['id'] as int,
                ticker: item['ticker'] as String?,
                exchange: item['exchange'] as String?,
                name: item['name'] as String,
                nameUs: item['name_us'] as String?,
                currency: item['currency'] as String,
                country: item['country'] as String,
                sectorIndustryId: item['sector_industry_id'] as int?,
                logo: item['logo'] as String?,
                status: item['status'] as String,
                lastPrice: item['last_price'] != null
                    ? (item['last_price'] as num).toDouble()
                    : null,
                lastPriceAt: item['last_price_at'] != null
                    ? DateTime.tryParse(item['last_price_at'].toString())
                    : null,
              ),
            )
            .toList();
      }
    }

    return result;
  }

  // -------------------------------------------------
  // 创建资产（买入或卖出）
  // -------------------------------------------------
  Future<bool> createAsset({
    required String userId,
    required Map<String, dynamic> assetData,
    required Map<String, dynamic>? stockData, // 传递股票信息
  }) async {
    final url = Uri.parse('${AppUtils().supabaseApiUrl}/users/$userId/assets');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${AppUtils().supabaseApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(assetData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // 1. 解析返回的 asset id
      final data = jsonDecode(response.body);
      final int? assetId = data['asset_id'] is int
          ? data['asset_id']
          : int.tryParse(data['asset_id']?.toString() ?? '');
      final sellMappingData =
          data['sell_mappings'] is List &&
              (data['sell_mappings'] as List).isNotEmpty
          ? (data['sell_mappings'] as List)
                .map(
                  (m) => {
                    "sell_id": m['sell_id'],
                    "buy_id": m['buy_id'],
                    "quantity": m['quantity'],
                  },
                )
                .toList()
          : null;
      //final priceHistory =
      //    data['price_history'] is List &&
      //        (data['price_history'] as List).isNotEmpty
      //    ? (data['price_history'] as List)
      //          .map((m) => {"price": m['price'], "price_at": m['price_at']})
      //          .toList()
      //    : null;

      final warning = data['warning'] as String?;
      print('warning: $warning');

      if (assetId != null) {
        // 2. 插入本地 TradeRecords
        await db
            .into(db.tradeRecords)
            .insert(
              TradeRecordsCompanion(
                id: Value(assetId),
                userId: Value(userId),
                accountId: Value(assetData['account_id']),
                assetType: Value(assetData['asset_type']),
                assetId: Value(assetData['asset_id']),
                tradeDate: Value(
                  DateFormat('yyyy-MM-dd').parse(assetData['trade_date']!),
                ),
                action: Value(assetData['action']),
                tradeType: Value(assetData['trade_type']),
                quantity: Value(
                  (num.tryParse(assetData['quantity'].toString()) ?? 0)
                      .toDouble(),
                ),
                price: Value(
                  (num.tryParse(assetData['price'].toString()) ?? 0).toDouble(),
                ),
                feeAmount: Value(
                  (num.tryParse(assetData['fee_amount']?.toString() ?? '0') ??
                          0)
                      .toDouble(),
                ),
                feeCurrency: Value(assetData['fee_currency']),
                positionType: Value(assetData['position_type']),
                leverage: Value(
                  assetData['leverage'] != null
                      ? num.tryParse(
                          assetData['leverage'].toString(),
                        )?.toDouble()
                      : null,
                ),
                swapAmount: Value(
                  assetData['swap_amount'] != null
                      ? (num.tryParse(
                          assetData['swap_amount'].toString(),
                        ))?.toDouble()
                      : null,
                ),
                swapCurrency: Value(assetData['swap_currency']),
                manualRateInput: Value(assetData['manual_rate_input'] ?? false),
                remark: Value(assetData['remark']),
              ),
            );

        // 3. 插入或更新本地 Stocks
        if (stockData != null) {
          final stockId = stockData['id'] as int;
          // 检查本地是否已有该股票
          final existing = await (db.select(
            db.stocks,
          )..where((tbl) => tbl.id.equals(stockId))).getSingleOrNull();

          final stocksCompanion = StocksCompanion(
            id: Value(stockData['id']),
            ticker: Value(stockData['ticker']),
            exchange: Value(stockData['exchange']),
            name: Value(stockData['name']),
            currency: Value(stockData['currency']),
            country: Value(stockData['country']),
            status: Value(stockData['status'] ?? 'active'),
            lastPrice: Value(
              stockData['last_price'] != null
                  ? (num.tryParse(
                      stockData['last_price'].toString(),
                    )?.toDouble())
                  : null,
            ),
            lastPriceAt: Value(
              stockData['last_price_at'] != null
                  ? DateTime.tryParse(stockData['last_price_at'].toString())
                  : null,
            ),
            nameUs: Value(stockData['name_us']),
            sectorIndustryId: Value(stockData['sector_industry_id']),
            logo: Value(stockData['logo']),
          );

          if (existing == null) {
            await db.into(db.stocks).insert(stocksCompanion);
          } else {
            await (db.update(
              db.stocks,
            )..where((tbl) => tbl.id.equals(stockId))).write(stocksCompanion);
          }
        }

        // 3.1 插入或更新本地 StockPrices
        /*if (priceHistory != null && stockData != null) {
          final stockId = stockData['id'] as int;
          for (final priceItem in priceHistory) {
            final price = (num.tryParse(priceItem['price'].toString()) ?? 0)
                .toDouble();
            final priceAt = DateTime.tryParse(priceItem['price_at'].toString());
            if (priceAt == null) continue;

            // 先查是否已存在
            final existing =
                await (db.select(db.stockPrices)..where(
                      (tbl) =>
                          tbl.stockId.equals(stockId) &
                          tbl.priceAt.equals(priceAt),
                    ))
                    .getSingleOrNull();

            final stockPriceCompanion = StockPricesCompanion(
              stockId: Value(stockId),
              price: Value(price),
              priceAt: Value(priceAt),
            );

            if (existing == null) {
              await db.into(db.stockPrices).insert(stockPriceCompanion);
            } else {
              await (db.update(db.stockPrices)
                    ..where((tbl) => tbl.id.equals(existing.id)))
                  .write(stockPriceCompanion);
            }
          }
        }*/

        // 4. 插入本地 SellMappings
        if (sellMappingData != null) {
          for (var sellMapping in sellMappingData) {
            final buyId = sellMapping['buy_id'];
            final sellId = sellMapping['sell_id'];
            final quantity =
                (num.tryParse(sellMapping['quantity'].toString()) ?? 0)
                    .toDouble();

            await db
                .into(db.tradeSellMappings)
                .insert(
                  TradeSellMappingsCompanion(
                    buyId: Value(buyId),
                    sellId: Value(sellId),
                    quantity: Value(quantity),
                  ),
                );
          }
        }
      }
      return true;
    } else {
      print('Create asset failed: ${response.statusCode} ${response.body}');
      return false;
    }
  }

  // -------------------------------------------------
  // 计算并保存当前持仓到 SharedPreferences
  // -------------------------------------------------
  Future<void> calculatePortfolioValue(String userId, int accountId) async {
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
  // 通过 Yahoo Finance API 获取最新股票价格
  // -------------------------------------------------
  Future<void> getStockPricesByYHFinanceAPI() async {
    final stocksList = await db.select(db.stocks).get();
    stocksList.add(
      Stock(
        id: -1,
        ticker: 'JPY=X',
        exchange: 'US',
        name: '',
        currency: 'USD',
        country: 'US',
        sectorIndustryId: null,
        logo: '',
        status: '',
      ),
    );
    stocksList.add(
      Stock(
        id: 0,
        ticker: 'JPYUSD=X',
        exchange: 'US',
        name: '',
        currency: 'JPY',
        country: 'JP',
        sectorIndustryId: null,
        logo: '',
        status: '',
      ),
    );
    final stockPrices = GlobalStore().currentStockPrices;
    if (GlobalStore().stockPricesLastUpdated != null &&
        stocksList.every(
          (s) => stockPrices.containsKey(
            s.exchange == 'JP' ? '${s.ticker}.T' : s.ticker,
          ),
        )) {
      final diff = DateTime.now().difference(
        GlobalStore().stockPricesLastUpdated!,
      );
      if (diff.inMinutes < 60) {
        print(
          'Stock prices recently updated at ${GlobalStore().stockPricesLastUpdated}, skip fetching.',
        );
        return;
      }
    }

    final tickers = stocksList
        .map((s) => '${s.ticker}${s.exchange == 'JP' ? '.T' : ''}')
        .join(',');

    // 这里调用你的股票价格 API
    final response = await http.get(
      Uri.parse('$yahooFinanceApiUrl?ticker=$tickers'),
      headers: {
        'x-rapidapi-key': yahooFinanceApiKey,
        'x-rapidapi-host': yahooFinanceApiHost,
      },
    );

    final data = jsonDecode(response.body);
    print(data);
    // 解析返回的股票价格数据
    GlobalStore().currentStockPrices = {
      for (var stock in data['body'])
        stock['symbol']:
            (stock['regularMarketPrice'] as num?)?.toDouble() ?? 0.0,
    };
    // 更新最后获取时间
    GlobalStore().stockPricesLastUpdated = DateTime.now();
    // 保存到 SharedPreferences
    await GlobalStore().saveCurrentStockPricesToPrefs();
    await GlobalStore().saveStockPricesLastUpdatedToPrefs();
  }

  // -------------------------------------------------
  // 计算最新的总资产和总成本
  // -------------------------------------------------
  dynamic getTotalAssetsAndCostsValue() {
    num totalAssets = 0.0;
    num totalCosts = 0.0;
    final selectedCurrencyCode = GlobalStore().selectedCurrencyCode;
    // 计算总资产和总成本
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
              .currentStockPrices['${currency == 'USD' ? '' : currency}$selectedCurrencyCode=X'] ??
          1.0;
      final feeRate =
          GlobalStore()
              .currentStockPrices['${feeCurrency == 'USD' ? '' : feeCurrency}$selectedCurrencyCode=X'] ??
          1.0;
      final currentPrice =
          GlobalStore().currentStockPrices[exchange == 'JP'
              ? '$code.T'
              : code] ??
          buyPrice;

      totalAssets += qty * currentPrice * rate;
      totalCosts += qty * buyPrice * rate + fee * feeRate;
    }
    return {'totalAssets': totalAssets, 'totalCosts': totalCosts};
  }

  // -------------------------------------------------
  // 获取指定日期范围的成本和价格历史数据
  // -------------------------------------------------
  dynamic getCostAndPriceHistoryData(DateTime startDate, DateTime endDate) {
    final stockIds = GlobalStore().portfolio
        .map((item) => item['stockId'].toString())
        .join(',');
    DateTime? syncStartDate = GlobalStore().syncStartDate;
    DateTime? syncEndDate = GlobalStore().syncEndDate;

    if (syncStartDate == null || syncEndDate == null) {
      // [startDate, endDate]を取得
      getHistoryPricesDataFromSupabase(stockIds, startDate, endDate);
      GlobalStore().syncStartDate = startDate;
      GlobalStore().syncEndDate = endDate;
    } else if ((startDate.isAfter(syncStartDate) ||
            startDate.isAtSameMomentAs(syncStartDate)) &&
        (endDate.isBefore(syncEndDate) ||
            endDate.isAtSameMomentAs(syncEndDate))) {
      //取得不要
    } else if ((startDate.isAfter(syncStartDate) ||
            startDate.isAtSameMomentAs(syncStartDate)) &&
        endDate.isAfter(syncEndDate)) {
      //[syncEndDate+1, endDate]を取得
      getHistoryPricesDataFromSupabase(
        stockIds,
        syncEndDate.add(const Duration(days: 1)),
        endDate,
      );
      GlobalStore().syncEndDate = endDate;
    } else if (startDate.isBefore(syncStartDate) &&
        (endDate.isBefore(syncEndDate) ||
            endDate.isAtSameMomentAs(syncEndDate))) {
      // [startDate, syncStartDate-1]を取得
      getHistoryPricesDataFromSupabase(
        stockIds,
        startDate,
        syncStartDate.subtract(const Duration(days: 1)),
      );
      GlobalStore().syncStartDate = startDate;
    } else if (startDate.isBefore(syncStartDate) &&
        endDate.isAfter(syncEndDate)) {
      // [startDate, syncStartDate-1]、[syncEndDate+1, endDate]を取得
      getHistoryPricesDataFromSupabase(
        stockIds,
        startDate,
        syncStartDate.subtract(const Duration(days: 1)),
      );
      getHistoryPricesDataFromSupabase(
        stockIds,
        syncEndDate.add(const Duration(days: 1)),
        endDate,
      );
      GlobalStore().syncStartDate = startDate;
      GlobalStore().syncEndDate = endDate;
    }

    // 取得したデータを保存
    GlobalStore().syncStartDate = syncStartDate;
    GlobalStore().syncEndDate = syncEndDate;
    GlobalStore().saveSyncDateToPrefs();

    return {'priceHistory': [], 'costBasisHistory': []};
  }

  // -------------------------------------------------
  // 从 Supabase 获取历史价格数据
  // -------------------------------------------------
  Future<Map<DateTime, dynamic>> getHistoryPricesDataFromSupabase(
    String stockIds,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Supabaseから履歴価格データを取得
    final url = Uri.parse('${AppUtils().supabaseApiUrl}/stock-prices').replace(
      queryParameters: {
        'stock_ids': stockIds,
        'start_date': startDate,
        'end_date': endDate,
      },
    );
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${AppUtils().supabaseApiKey}'},
    );
    print(url);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final historicalPortfolio = GlobalStore().historicalPortfolio;
      final data = jsonDecode(response.body);
      final stocks = data['stocks'];
      final fxRates = data['fx_rates'];
      for (var key in (stocks as Map).keys) {
        final stockPrices = stocks[key]['stock_prices'];
        (stockPrices as List).forEach((price) {
          print(price);
        });
      }
      for (var rate in (fxRates as List)) {
        print(rate);
      }
    }

    return {};
  }

  double formatNumberByTwoDigits(double num) {
    return double.parse(num.toStringAsFixed(2));
  }

  String formatProfit(double profit, String currencyCode) {
    final symbol = profit > 0 ? '+' : (profit < 0 ? '-' : '');
    final currency = Currency.values.firstWhere(
      (c) => c.code == currencyCode,
      orElse: () => Currency.jpy,
    );
    return '$symbol${NumberFormat.currency(locale: currency.locale, symbol: currency.symbol).format(profit.abs())}';
  }

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

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // -------------------------------------------------
  // 同步 Supabase 数据到本地数据库
  // -------------------------------------------------
  Future<void> syncDataWithSupabase(
    String userId,
    int accountId,
    AppDatabase db,
  ) async {
    final t0 = DateTime.now();
    final url = Uri.parse('${AppUtils().supabaseApiUrl}/users/$userId/summary');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${AppUtils().supabaseApiKey}'},
    );
    final t1 = DateTime.now();
    print(
      'Fetch data from supabase time: ${t1.difference(t0).inMilliseconds} ms',
    );

    List<Stock> result = [];
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['account_info'] is List) {
        final accountInfoList = data['account_info'] as List;
        for (var accountInfo in accountInfoList) {
          if (accountInfo['account_id'] == accountId) {
            // 1. 同步股票信息
            final stocks = accountInfo['stocks'] as List;
            final List<StocksCompanion> stockRecordsInsert = [];
            for (var stock in stocks) {
              final record = StocksCompanion(
                id: Value(stock['id']),
                ticker: Value(stock['ticker']),
                exchange: Value(stock['exchange']),
                name: Value(stock['name']),
                currency: Value(stock['currency']),
                country: Value(stock['country']),
                status: Value(stock['status'] ?? 'active'),
                nameUs: Value(stock['name_us']),
                sectorIndustryId: Value(stock['sector_industry_id']),
                logo: Value(stock['logo']),
              );
              stockRecordsInsert.add(record);
            }
            // 清空本地该账户的股票信息
            await (db.delete(db.stocks)).go();
            // 插入最新的股票信息
            await db.batch((batch) {
              batch.insertAll(db.stocks, stockRecordsInsert);
            });

            final t2 = DateTime.now();
            print(
              'Sync stocks and stock prices time: ${t2.difference(t1).inMilliseconds} ms',
            );

            // 2. 同步股票交易信息
            final tradeRecords = accountInfo['trade_records'] as List;
            final List<TradeRecordsCompanion> tradeRecordsInsert = [];
            for (var trade in tradeRecords) {
              final record = TradeRecordsCompanion(
                id: Value(trade['trade_id']),
                userId: Value(userId),
                accountId: Value(trade['account_id']),
                assetType: Value(trade['asset_type']),
                assetId: Value(trade['asset_id']),
                tradeDate: Value(
                  DateFormat('yyyy-MM-dd').parse(trade['trade_date']),
                ),
                action: Value(trade['action']),
                tradeType: Value(trade['trade_type']),
                quantity: Value(
                  (num.tryParse(trade['quantity'].toString()) ?? 0).toDouble(),
                ),
                price: Value(
                  (num.tryParse(trade['price'].toString()) ?? 0).toDouble(),
                ),
                feeAmount: Value(
                  (num.tryParse(trade['fee_amount']?.toString() ?? '0') ?? 0)
                      .toDouble(),
                ),
                feeCurrency: Value(trade['fee_currency']),
                positionType: Value(trade['position_type']),
                leverage: Value(
                  trade['leverage'] != null
                      ? (num.tryParse(trade['leverage'].toString()) ?? 0)
                            .toDouble()
                      : null,
                ),
                swapAmount: Value(
                  trade['swap_amount'] != null
                      ? (num.tryParse(trade['swap_amount'].toString()) ?? 0)
                            .toDouble()
                      : null,
                ),
                swapCurrency: Value(trade['swap_currency']),
                manualRateInput: Value(trade['manual_rate_input'] ?? false),
                remark: Value(trade['remark']),
              );
              tradeRecordsInsert.add(record);
            }
            // 清空本地该账户的交易记录
            await (db.delete(db.tradeRecords)..where(
                  (tbl) =>
                      tbl.userId.equals(userId) &
                      tbl.accountId.equals(accountId),
                ))
                .go();
            // 插入最新的交易记录
            await db.batch((batch) {
              batch.insertAll(db.tradeRecords, tradeRecordsInsert);
            });

            final t3 = DateTime.now();
            print(
              'Sync trade records time: ${t3.difference(t2).inMilliseconds} ms',
            );

            // 3. 同步卖出映射关系
            final sellMappings = accountInfo['trade_sell_mapping'] as List;
            final List<TradeSellMappingsCompanion> sellMappingsInsert = [];
            for (var mapping in sellMappings) {
              final record = TradeSellMappingsCompanion(
                buyId: Value(mapping['buy_id']),
                sellId: Value(mapping['sell_id']),
                quantity: Value(
                  (num.tryParse(mapping['quantity'].toString()) ?? 0)
                      .toDouble(),
                ),
              );
              sellMappingsInsert.add(record);
            }
            // 清空本地该账户的卖出映射关系
            await (db.delete(db.tradeSellMappings)).go();
            // 插入最新的卖出映射关系
            await db.batch((batch) {
              batch.insertAll(db.tradeSellMappings, sellMappingsInsert);
            });

            final t4 = DateTime.now();
            print(
              'Sync sell mappings time: ${t4.difference(t3).inMilliseconds} ms',
            );
          }
        }
      }
    }
  }

  // -------------------------------------------------
  // 计算并保存历史持仓到 SharedPreferences
  // -------------------------------------------------
  Future<void> calculateAndSaveHistoricalPortfolioToPrefs() async {
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

  // --- 计算指定日期的汇率 ---
  Future<Map<String, double>> currencyExchangeRate(
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
