import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/models/stock_info.dart';
import 'package:money_nest_app/util/global_store.dart';
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
    required Map<String, dynamic>? stockData, // 传递股票信息
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
      final priceHistory =
          data['price_history'] is List &&
              (data['price_history'] as List).isNotEmpty
          ? (data['price_history'] as List)
                .map((m) => {"price": m['price'], "price_at": m['price_at']})
                .toList()
          : null;

      final warning = data['warning'] as String?;
      print('warning: $warning');

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
        if (priceHistory != null && stockData != null) {
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
        }

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

  Future<void> calculatePortfolioValue(
    String userId,
    int accountId,
    AppDatabase db,
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

    print('Updated portfolio: ${GlobalStore().portfolio}');
  }

  Future<void> getStockPricesByYHFinanceAPI(AppDatabase db) async {
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
        exchange: 'JP',
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
        stocksList.every((s) => stockPrices.containsKey(s.ticker))) {
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
    GlobalStore().currentStockPrices = {
      for (var stock in data['body'])
        stock['symbol']:
            (stock['regularMarketPrice'] as num?)?.toDouble() ?? 0.0,
    };
    GlobalStore().stockPricesLastUpdated = DateTime.now();
    await GlobalStore().saveStockPricesToPrefs();
    await GlobalStore().saveStockPricesLastUpdatedToPrefs();
  }

  dynamic getTotalAssetsAndCostsValue() {
    num totalAssets = 0;
    num totalCosts = 0;
    final currencyCode = GlobalStore().selectedCurrencyCode ?? 'JPY';
    // 计算总资产和总成本
    final rate = GlobalStore().currentStockPrices['$currencyCode=X'] ?? 140.0;

    for (var item in GlobalStore().portfolio) {
      final qty = item['quantity'] as num? ?? 0;
      final buyPrice = item['buyPrice'] as num? ?? 0;
      final code = item['code'] as String? ?? '';
      final exchange = item['exchange'] as String? ?? 'JP';
      final currency = exchange == 'JP' ? 'JPY' : 'USD';
      final fee = item['fee'] as num? ?? 0;
      final feeCurrency = item['feeCurrency'] as String? ?? currencyCode;
      final currentPrice = GlobalStore().currentStockPrices[code] ?? buyPrice;
      totalAssets += qty * currentPrice * (currency == 'USD' ? rate : 1.0);
      totalCosts +=
          qty * buyPrice * (currency == 'USD' ? rate : 1.0) +
          fee * (feeCurrency == 'USD' ? rate : 1.0);
    }
    return {'totalAssets': totalAssets, 'totalCosts': totalCosts};
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

  Future<void> syncDataWithSupabase(
    String userId,
    int accountId,
    AppDatabase db,
  ) async {
    final url = Uri.parse('${AppUtils().supabaseApiUrl}/users/$userId/latest');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${AppUtils().supabaseApiKey}'},
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

              // 1-1. 同步股票价格历史
              final stockPrices = stock['stock_prices'] as List;
              final List<StockPricesCompanion> stockPricesInsert = [];
              for (var priceItem in stockPrices) {
                final record = StockPricesCompanion(
                  stockId: Value(stock['id']),
                  price: Value(
                    (num.tryParse(priceItem['price'].toString()) ?? 0)
                        .toDouble(),
                  ),
                  priceAt: Value(
                    DateTime.tryParse(priceItem['price_at'].toString()) ??
                        DateTime.now(),
                  ),
                );
                stockPricesInsert.add(record);
              }
              // 清空本地该股票的价格历史
              await (db.delete(
                db.stockPrices,
              )..where((tbl) => tbl.stockId.equals(stock['id']))).go();
              // 插入最新的股票价格历史
              await db.batch((batch) {
                batch.insertAll(db.stockPrices, stockPricesInsert);
              });
            }
            // 清空本地该账户的股票信息
            await (db.delete(db.stocks)).go();
            // 插入最新的股票信息
            await db.batch((batch) {
              batch.insertAll(db.stocks, stockRecordsInsert);
            });

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

            // 4. 同步历史汇率
            final fxRates = accountInfo['fx_rates'] as List;
            final List<FxRatesCompanion> fxRatesInsert = [];
            for (var rate in fxRates) {
              final record = FxRatesCompanion(
                fxPairId: Value(rate['fx_pair_id']),
                rateDate: Value(
                  DateTime.tryParse(rate['rate_date'].toString()) ??
                      DateTime.now(),
                ),
                rate: Value(
                  (num.tryParse(rate['rate'].toString()) ?? 0).toDouble(),
                ),
              );
              fxRatesInsert.add(record);
            }
            // 清空本地该账户的历史汇率
            await (db.delete(db.fxRates)).go();
            // 插入最新的历史汇率
            await db.batch((batch) {
              batch.insertAll(db.fxRates, fxRatesInsert);
            });
          }
        }
      }
    }
  }

  /*
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
