import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalStore {
  static final GlobalStore _instance = GlobalStore._internal();
  factory GlobalStore() => _instance;
  GlobalStore._internal();

  String? userId;
  int? accountId;
  String? selectedCurrencyCode;
  List<dynamic> portfolio = []; // 持仓列表
  Map<DateTime, dynamic> historicalPortfolio =
      {}; // 历史持仓，key 是日期，value 是{持仓列表，成本基础，总资产}
  Map<String, double> currentStockPrices = {}; // 股票价格
  DateTime? stockPricesLastUpdated;
  //List<(DateTime, double)>? assetsTotalHistory; // 资产总值历史
  //List<(DateTime, double)>? costBasisHistory; // 成本基础历史
  DateTime? lastSyncTime; // 最近与服务器同步时间
  String textForDebug = '';

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    accountId = prefs.getInt('accountId');
    lastSyncTime = DateTime.tryParse(prefs.getString('lastSyncTime') ?? '');
    selectedCurrencyCode = prefs.getString('selectedCurrencyCode') ?? 'JPY';
    portfolio = jsonDecode(prefs.getString('portfolio') ?? '[]');
    historicalPortfolio =
        jsonDecode(
          prefs.getString('historicalPortfolio') ?? '{}',
        ).map<DateTime, dynamic>(
          (key, value) => MapEntry(DateTime.parse(key), value),
        );
    currentStockPrices = Map<String, double>.from(
      jsonDecode(prefs.getString('stockPrices') ?? '{}'),
    );
    stockPricesLastUpdated = DateTime.tryParse(
      prefs.getString('stockPricesLastUpdated') ?? '',
    );
  }

  Future<void> saveTextForDebugToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('textForDebug', textForDebug);
  }

  Future<void> saveUserIdToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (userId != null) {
      prefs.setString('userId', userId!);
    }
  }

  Future<void> saveAccountIdToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (accountId != null) {
      prefs.setInt('accountId', accountId!);
    }
  }

  Future<void> saveLastSyncTimeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('lastSyncTime', DateTime.now().toIso8601String());
  }

  Future<void> saveSelectedCurrencyCodeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (selectedCurrencyCode != null) {
      prefs.setString('selectedCurrencyCode', selectedCurrencyCode!);
    }
  }

  Future<void> saveStockPricesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (currentStockPrices.isNotEmpty) {
      prefs.setString('stockPrices', jsonEncode(currentStockPrices));
    }
  }

  Future<void> savePortfolioToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('portfolio', jsonEncode(portfolio));
  }

  Future<void> saveStockPricesLastUpdatedToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (stockPricesLastUpdated != null) {
      prefs.setString(
        'stockPricesLastUpdated',
        stockPricesLastUpdated!.toIso8601String(),
      );
    }
  }

  Future<void> saveHistoricalPortfolioToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'historicalPortfolio',
      jsonEncode(
        historicalPortfolio.map<String, dynamic>(
          (key, value) => MapEntry(key.toIso8601String(), value),
        ),
      ),
    );
  }

  Future<void> calculateAndSaveAssetsTotalHistoryToPrefs(AppDatabase db) async {
    final prefs = await SharedPreferences.getInstance();

    final userId = GlobalStore().userId;
    final accountId = GlobalStore().accountId;
    if (userId == null || accountId == null) return;
    // 1. 查询所有交易记录
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
    // 2. 查询所有卖出mapping记录
    final sellMappingQuery =
        db.select(db.tradeSellMappings).join([
            leftOuterJoin(
              db.tradeRecords,
              db.tradeRecords.id.equalsExp(db.tradeSellMappings.buyId),
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
      // 如果没有交易记录，清空历史
      assetsTotalHistory = [];
      costBasisHistory = [];
      prefs.setString('assetsTotalHistory', jsonEncode([]));
      prefs.setString('costBasisHistory', jsonEncode([]));
      return;
    }

    // 2. 循环计算最早交易日起的持仓和总资产
    DateTime firstTradeDate = tradeRows.first
        .readTable(db.tradeRecords)
        .tradeDate;

    // 从最早交易日开始到昨天的所有日期循环
    DateTime currentDate = DateTime(
      firstTradeDate.year,
      firstTradeDate.month,
      firstTradeDate.day,
    );
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day); // 只保留年月日
    // 清空历史，重新计算
    assetsTotalHistory = [];
    costBasisHistory = [];
    while (currentDate.isBefore(today)) {
      double totalAsset = 0.0;
      double totalCostBasis = 0.0;
      // 当前持仓，股票ID -> {股票信息, 交易信息List}
      Map<int, Map<String, dynamic>> holdings = {};

      // 汇总所有货币的总资产, 并进行货币转换
      final String targetCurrency = selectedCurrencyCode ?? 'JPY';
      final Map<String, double> rates = await currencyExchangeRate(
        currentDate,
        db,
      );

      // 处理当天的交易
      for (var row in tradeRows) {
        final trade = row.readTable(db.tradeRecords);
        final stock = row.readTable(db.stocks);
        if (trade.tradeDate.isBefore(currentDate) ||
            (trade.tradeDate.year == currentDate.year &&
                trade.tradeDate.month == currentDate.month &&
                trade.tradeDate.day == currentDate.day)) {
          // 是当天的交易
          if (trade.action == 'buy') {
            if (holdings[stock.id] == null) {
              holdings[stock.id] = {
                'stock': stock,
                'trades': [trade],
              };
            } else {
              (holdings[stock.id]?['trades'] as List).add(trade);
            }
          } else if (trade.action == 'sell') {
            sellMappingRows
                .where(
                  (mappingRow) =>
                      mappingRow.readTable(db.tradeSellMappings).sellId ==
                      trade.id,
                )
                .forEach((mappingRow) {
                  final sellQuantity = mappingRow
                      .readTable(db.tradeSellMappings)
                      .quantity;
                  final buyTrade = mappingRow.readTable(db.tradeRecords);
                  if (holdings[stock.id] != null) {
                    final tradesList = (holdings[stock.id]?['trades'] as List)
                        .cast<TradeRecord>();
                    final idx = tradesList.indexWhere(
                      (t) => t.id == buyTrade.id,
                    );

                    if (idx != -1) {
                      final existingBuyTrade = tradesList[idx];
                      final updatedBuyTrade = existingBuyTrade.copyWith(
                        quantity: existingBuyTrade.quantity - sellQuantity,
                        feeAmount: Value(
                          (existingBuyTrade.feeAmount ?? 0) *
                              ((existingBuyTrade.quantity - sellQuantity) /
                                  (existingBuyTrade.quantity)),
                        ),
                      );
                      tradesList[idx] = updatedBuyTrade;
                    } else {
                      // 找不到对应的买入交易，可能数据有问题，忽略
                      print(
                        'Warning: Cannot find corresponding buy trade for sell trade id ${trade.id}',
                      );
                    }
                  }
                });
          }
        }
      }
      // 计算当天的总资产
      Map<String, double> dailyTotal = {};
      // 计算当天的成本基础
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
      // 计算总资产
      dailyTotal.forEach((currency, amount) {
        // 转换为目标货币
        String pair = currency + targetCurrency;
        totalAsset += amount * (rates[pair] ?? 1.0);
      });
      // 计算总成本基础
      dailyCostBasis.forEach((currency, amount) {
        // 转换为目标货币
        String pair = currency + targetCurrency;
        totalCostBasis += amount * (rates[pair] ?? 1.0);
      });
      // 保存当天的总资产到历史
      assetsTotalHistory ??= [];
      costBasisHistory ??= [];
      assetsTotalHistory!.add((currentDate, totalAsset));
      costBasisHistory!.add((currentDate, totalCostBasis));
      // 日期加1天
      currentDate = currentDate.add(const Duration(days: 1));
    }
    prefs.setString(
      'assetsTotalHistory',
      jsonEncode(
        assetsTotalHistory!
            .map((e) => {'date': e.$1.toIso8601String(), 'value': e.$2})
            .toList(),
      ),
    );
    prefs.setString(
      'costBasisHistory',
      jsonEncode(
        costBasisHistory!
            .map((e) => {'date': e.$1.toIso8601String(), 'value': e.$2})
            .toList(),
      ),
    );
  }
}
