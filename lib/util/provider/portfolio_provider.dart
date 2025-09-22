import 'package:flutter/material.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/l10n/l10n_util.dart';

class PortfolioProvider extends ChangeNotifier {
  Map<String, dynamic> portfolioCategories = {};

  Future<void> fetchPortfolio(AppDatabase db, AppLocalizations l10n) async {
    // ...数据库查询和数据转换逻辑...
    portfolioCategories = await buildPortfolioCategories(db, l10n);
    notifyListeners();
  }

  Future<Map<String, dynamic>> buildPortfolioCategories(
    AppDatabase db,
    AppLocalizations l10n,
  ) async {
    // 1. 获取所有持仓记录
    final records = [];
    //await db.getAllAvailableBuyRecords();

    // 1.1 按 code 合并持仓
    final Map<String, List<dynamic>> grouped = {};
    //for (final r in records) {
    //  grouped.putIfAbsent(r.code, () => []).add(r);
    // }

    // 2. 获取所有市场数据
    final marketDataList = [];
    //await db.getAllMarketDataRecords();
    //final Map<String, MarketDataData> marketMap = {
    //  for (var market in marketDataList) market.code: market,
    //};
    // 3. 获取股票数据
    final stockDataList = [];
    //await db.getAllStocksRecords();
    //final Map<String, Stock> stockMap = {
    //  for (var stock in stockDataList) stock.code: stock,
    //};

    // 4. 按市场分类
    final Map<String, dynamic> categories = {};

    for (final entry in grouped.entries) {
      final code = entry.key;
      final recordsForCode = entry.value;

      // 合并数量和成本
      double totalQuantity = 0;
      double totalCost = 0;
      String marketCode = '';
      for (final r in recordsForCode) {
        totalQuantity += r.quantity;
        totalCost += r.quantity * r.price;
        marketCode = r.marketCode;
      }

      // 获取市场信息
      final market = {}; /*
          marketMap[marketCode] ??
          MarketDataData(
            code: marketCode,
            name: '',
            currency: '',
            sortOrder: 0,
            isActive: false,
          );*/

      //if (!market.isActive) continue;

      // 分类
      final key = ''; //market.code;
      /*categories.putIfAbsent(key, () {
        return {
          'name': getL10nStringFromL10n(l10n, market.name),
          'currency': market.currency,
          'totalValue': 0,
          'gain': 0,
          'gainPercent': 0.0,
          'stocks': [],
        };
      });*/

      // 当前市值
      final marketValue = null;
      //totalQuantity *
      //(stockMap[code]?.currentPrice ?? recordsForCode.first.price);
      // 成本
      final cost = totalCost;
      // 盈亏金额
      final gain = marketValue - cost;
      // 盈亏率
      final gainPercent = cost > 0 ? gain / cost * 100 : 0.0;

      categories[key]['totalValue'] += marketValue;
      categories[key]['gain'] += gain;
      // stocks列表
      /*categories[key]['stocks'].add({
        'symbol': code,
        'name': stockMap[code]?.name ?? code,
        'shares': totalQuantity,
        'price': stockMap[code]?.currentPrice ?? recordsForCode.first.price,
        'value': marketValue,
        'gain': gain,
        'gainPercent': gainPercent,
      });*/
    }

    // 4. 计算 gainPercent
    categories.forEach((key, cat) {
      final totalValue = cat['totalValue'] as num;
      final gain = cat['gain'] as num;
      cat['gainPercent'] = totalValue > 0 ? gain / totalValue * 100 : 0.0;
      // 4-1. 按照当前市场价降序排序
      cat['stocks'].sort((a, b) {
        final aValue = a['value'] as num;
        final bValue = b['value'] as num;
        return bValue.compareTo(aValue);
      });
    });

    // 5. 可选：添加现金项
    categories['cash'] = {
      'name': '現金',
      'totalValue': 0,
      'gain': 0,
      'gainPercent': 0.0,
    };

    return categories;
  }
}
