import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/models/stock_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtils {
  String supabaseApiUrl =
      'https://yeciaqfdlznrstjhqfxu.supabase.co/functions/v1/money_grow_api';
  String supabaseApiKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InllY2lhcWZkbHpucnN0amhxZnh1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MDE3NTIsImV4cCI6MjA3MTk3Nzc1Mn0.QXWNGKbr9qjeBLYRWQHEEBMT1nfNKZS3vne-Za38bOc';

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

  Future<bool> createAsset({
    required String userId,
    required Map<String, dynamic> assetData,
    required Map<String, dynamic> stockData, // 新增参数，传递股票信息
  }) async {
    print('createAsset: $userId $assetData');
    final url = Uri.parse('${AppUtils().supabaseApiUrl}/users/$userId/assets');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${AppUtils().supabaseApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(assetData),
    );

    print(url);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Create asset success: ${response.body}');
      // 1. 解析返回的 asset id
      final data = jsonDecode(response.body);
      final int? assetId = data['asset'] is int
          ? data['asset']
          : int.tryParse(data['asset']?.toString() ?? '');

      if (assetId != null) {
        final db = AppDatabase();

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
                ? (num.tryParse(stockData['last_price'].toString())?.toDouble())
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
      return true;
    } else {
      print('Create asset failed: ${response.statusCode} ${response.body}');
      return false;
    }
  }

  /*Future<Map<String, double>> getStockPricesByYHFinanceAPI(
    List<Stock> stocks,
    List<MarketDataData> marketDataList,
  ) async {
    /*final tickers = stocks
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
    };*/
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
  }*/
}
