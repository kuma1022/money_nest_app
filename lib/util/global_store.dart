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
  Map<String, double> currentStockPrices = {}; // 股票价格
  DateTime? stockPricesLastUpdated;
  List<(DateTime, double)>? assetsTotalHistory; // 资产总值历史
  DateTime? lastSyncTime; // 最近与服务器同步时间

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    accountId = prefs.getInt('accountId');
    lastSyncTime = DateTime.tryParse(prefs.getString('lastSyncTime') ?? '');
    selectedCurrencyCode = prefs.getString('selectedCurrencyCode') ?? 'JPY';
    portfolio = jsonDecode(prefs.getString('portfolio') ?? '[]');
    currentStockPrices = Map<String, double>.from(
      jsonDecode(prefs.getString('stockPrices') ?? '{}'),
    );
    stockPricesLastUpdated = DateTime.tryParse(
      prefs.getString('stockPricesLastUpdated') ?? '',
    );
    assetsTotalHistory =
        (jsonDecode(prefs.getString('assetsTotalHistory') ?? '[]') as List)
            .map(
              (e) =>
                  (DateTime.parse(e['date']), (e['value'] as num).toDouble()),
            )
            .toList();
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
            OrderingTerm.asc(db.stocks.ticker),
          ]);

    final tradeRows = await tradeQuery.get();

    if (tradeRows.isEmpty) {
      // 如果没有交易记录，清空历史
      assetsTotalHistory = [];
      prefs.setString('assetsTotalHistory', jsonEncode([]));
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
    while (currentDate.isBefore(today)) {
      double totalAsset = 0.0;
      Map<int, dynamic> holdings = {}; // 股票ID -> {持仓数量, 货币}
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
            holdings[stock.id] = {
              'quantity':
                  (holdings[stock.id]?['quantity'] ?? 0) + trade.quantity,
              'currency': stock.currency,
            };
          } else if (trade.action == 'sell') {
            holdings[stock.id] = {
              'quantity':
                  (holdings[stock.id]?['quantity'] ?? 0) - trade.quantity,
              'currency': stock.currency,
            };
            if (holdings[stock.id]!['quantity'] < 0) {
              holdings[stock.id]!['quantity'] = 0; // 持仓不能为负
            }
          }
        }
      }
      // 计算当天的总资产
      Map<String, double> dailyTotal = {};
      for (var entry in holdings.entries) {
        final stockId = entry.key;
        // 从stock_prices中查找当前价格
        final priceQuery = db.stockPrices.select()
          ..where((tbl) => tbl.stockId.equals(stockId))
          ..where((tbl) => tbl.priceAt.isSmallerOrEqualValue(currentDate))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.priceAt)])
          ..limit(1);
        final currentPrice = await priceQuery.getSingleOrNull();
        dailyTotal[holdings[stockId]!['currency']] =
            (dailyTotal[holdings[stockId]!['currency']] ?? 0) +
            (holdings[stockId]!['quantity'] * (currentPrice?.price ?? 0.0));
      }
      // 汇总所有货币的总资产, 并进行货币转换
      final String targetCurrency = selectedCurrencyCode ?? 'JPY';
      final fxRateQuery = db.fxRates.select()
        ..where((tbl) => tbl.fxPairId.equals(1))
        ..where((tbl) => tbl.rateDate.isSmallerOrEqualValue(currentDate))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.rateDate)])
        ..limit(1);
      final fxRate = await fxRateQuery.getSingleOrNull();
      final Map<String, double> rates = {}; // 货币对汇率，如
      rates['USDJPY'] = fxRate?.rate ?? 150.0;
      rates['JPYUSD'] = 1 / rates['USDJPY']!;
      // 计算总资产
      dailyTotal.forEach((currency, amount) {
        if (currency == targetCurrency) {
          // 目标货币，直接加
          totalAsset += amount;
        } else {
          // 其他货币，转换后加
          String pair = currency + targetCurrency;
          totalAsset += amount * (rates[pair] ?? 1.0);
        }
      });
      // 保存当天的总资产到历史
      assetsTotalHistory ??= [];
      assetsTotalHistory!.add((currentDate, totalAsset));
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
  }
}
