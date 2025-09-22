import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/util/app_utils.dart';

class TotalAssetProvider extends ChangeNotifier {
  String _totalAsset = '';
  DateTime _assetFetchedTime = DateTime.now();

  String get totalAsset => _totalAsset;
  DateTime get assetFetchedTime => _assetFetchedTime;

  void setTotalAsset(String value) {
    _totalAsset = value;
    notifyListeners();
  }

  Future<void> fetchTotalAsset(AppDatabase db, Currency currency) async {
    //double total = await _calculateAllStockValue(db, currency.code);
    //final formatted = NumberFormat.currency(
    //  locale: currency.locale,
    //  symbol: currency.symbol,
    //).format(total);
    //_totalAsset = formatted;
    //notifyListeners();
  }

  // 这里模拟股票总价值计算，实际应从你的数据源获取
  /*Future<double> _calculateAllStockValue(
    AppDatabase db,
    String currencyCode,
  ) async {
    // 获取持仓股票的数据
    final stockDataList = await db.getAllStocksRecords();

    List<Stock> newStockDataList = List.from(stockDataList);
    // 如果除了FX之外没有数据
    //if (stockDataList.isEmpty ||
    //    newStockDataList.every((stock) => stock.marketCode == 'FOREX')) {
    //  return 0;
   // }
    final marketDataList = await db.getAllMarketDataRecords();
    // 如果所有 priceUpdatedAt 都在周六或周日，则不更新
    //bool allWeekend =
    //    stockDataList.isNotEmpty &&
        //stockDataList.every((stock) {
          //final dt = stock.priceUpdatedAt;
          //if (dt == null) return false;
          //return dt.weekday == DateTime.saturday ||
          //    dt.weekday == DateTime.sunday;
        //});
    /*if (!allWeekend &&
        stockDataList.any(
          (stock) =>
              stock.priceUpdatedAt == null ||
              stock.priceUpdatedAt!.isBefore(
                DateTime.now().subtract(const Duration(hours: 1)),
              ),
        )) {
      // 调用YH Finance API 获取实时股票价格
      final stocks = await db.getAllStocks();
      final appUtils = AppUtils();
      print('Fetching stock prices...');
      final stockPrices = await appUtils.getStockPricesByYHFinanceAPI(
        stocks,
        marketDataList,
      );
      newStockDataList.clear();
      for (var stock in stockDataList) {
        newStockDataList.add(
          stock.copyWith(
            currentPrice: Value(
              stockPrices['${stock.code}${marketDataList.firstWhere(
                (m) => m.code == stock.marketCode,
                orElse: () => MarketDataData(code: '', name: '', surfix: '', sortOrder: 0, isActive: true),
              ).surfix}'],
            ),
          ),
        );
      }
      // 更新数据库中的股票价格和更新时间
      await db.updateStockPrices(newStockDataList);*/
    }

    Map<String, double> priceMap = {
      for (var stock in newStockDataList)
        if (stock.currentPrice != null) stock.code: stock.currentPrice!,
    };

    // 更新资产获取时间
    _assetFetchedTime = stockDataList.isNotEmpty
        ? stockDataList.first.priceUpdatedAt ?? DateTime.now()
        : DateTime.now();

    // 遍历持仓列表，累加每只股票的市值
    final records = await db.getAllAvailableBuyRecords();
    return records.fold<double>(
      0,
      (sum, r) =>
          sum +
          r.quantity *
              priceMap[r.code]! *
              (priceMap['${r.currency.code != 'USD' ? r.currency.code : ''}$currencyCode'] ??
                  1.0),
    );
  }*/
}
