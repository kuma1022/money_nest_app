import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtils {
  factory AppUtils() {
    return _singleton;
  }

  AppUtils._internal();
  static final AppUtils _singleton = AppUtils._internal();

  double degreeToRadian(double degree) {
    return degree * math.pi / 180;
  }

  double radianToDegree(double radian) {
    return radian * 180 / math.pi;
  }

  Future<bool> tryToLaunchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  Future<Map<String, double>> getStockPricesByYHFinanceAPI(
    List<Stock> stocks,
    List<MarketDataData> marketDataList,
  ) async {
    final tickers = stocks
        .map(
          (s) =>
              '${s.code}${marketDataList.firstWhere(
                (m) => m.code == s.marketCode,
                orElse: () => MarketDataData(code: '', name: '', surfix: '', sortOrder: 0, isActive: true),
              ).surfix}',
        )
        .join(',');

    // 这里调用你的股票价格 API
    final response = await http.get(
      Uri.parse(
        'https://yahoo-finance15.p.rapidapi.com/api/v1/markets/stock/quotes?ticker=$tickers',
      ),
      headers: {
        'x-rapidapi-key': '003c4869d0msh2ea657dbb66bd59p1e94f4jsn72dabcb8d29a',
        'x-rapidapi-host': 'yahoo-finance15.p.rapidapi.com',
      },
    );

    final data = jsonDecode(response.body);
    print(data);
    // 解析返回的股票价格数据
    return {
      for (var stock in data['body'])
        stock['symbol']:
            (stock['regularMarketPrice'] as num?)?.toDouble() ?? 0.0,
    };
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

  Future<double> getCurrencyExchangeRatesByDate(
    String fromCurrency,
    String toCurrency,
    DateTime date,
  ) async {
    AppDatabase db = AppDatabase();
    // 先检查数据库中是否已有该日期的汇率数据
    final existingRate =
        await (db.select(db.exchangeRates)..where(
              (tbl) =>
                  tbl.date.equals(date) &
                  tbl.fromCurrency.equals(fromCurrency) &
                  tbl.toCurrency.equals(toCurrency),
            ))
            .getSingleOrNull();
    if (existingRate != null) {
      // 已有数据，直接返回
      return existingRate.rate;
    }

    final response = await http.get(
      Uri.parse(
        'https://openexchangerates.org/api/historical/${DateFormat('yyyy-MM-dd').format(date)}.json?app_id=0fb44797862744c798dfaf16db35a829',
      ),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final Map<String, double> rates = Map<String, double>.from(data['rates']);
      // 处理汇率数据
      if (rates.containsKey(fromCurrency) && rates.containsKey(toCurrency)) {
        final fromRate = rates[fromCurrency]!;
        final toRate = rates[toCurrency]!;
        final exchangeRate = toRate / fromRate;

        // 将新的汇率数据存入数据库
        await db
            .into(db.exchangeRates)
            .insert(
              ExchangeRatesCompanion(
                date: Value(date),
                fromCurrency: Value(
                  Currency.values.firstWhere(
                    (c) => c.code == fromCurrency,
                    orElse: () => Currency.jpy,
                  ),
                ),
                toCurrency: Value(
                  Currency.values.firstWhere(
                    (c) => c.code == toCurrency,
                    orElse: () => Currency.jpy,
                  ),
                ),
                rate: Value(exchangeRate),
                updatedAt: Value(DateTime.now()),
                remark: Value('Fetched from API'),
              ),
            );

        return exchangeRate;
      } else {
        throw Exception('Currency not found in the response');
      }
    }
    throw Exception('Failed to fetch exchange rates');
  }
}
