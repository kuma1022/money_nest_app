import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/util/bitflyer_api.dart';
import 'package:money_nest_app/util/global_store.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppUtils {
  factory AppUtils() {
    return _singleton;
  }
  AppUtils._internal();
  static final AppUtils _singleton = AppUtils._internal();

  // Supabase客户端
  SupabaseClient? _supabase;

  SupabaseClient get supabase {
    _supabase ??= Supabase.instance.client;
    return _supabase!;
  }

  // API Keys and URLs
  String yahooFinanceApiKey =
      '003c4869d0msh2ea657dbb66bd59p1e94f4jsn72dabcb8d29a';
  String yahooFinanceApiHost = 'yahoo-finance15.p.rapidapi.com';
  String yahooFinanceApiUrl =
      'https://yahoo-finance15.p.rapidapi.com/api/v1/markets/stock/quotes';
  // 数据库实例
  final db = AppDatabase();

  // 初始化 Supabase 认证状态监听器
  StreamSubscription<AuthState> initializeAuthListener(
    Function(AuthState)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return supabase.auth.onAuthStateChange.listen(
      (data) {
        if (onData != null) {
          onData(data);
        }
      },
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  // 取消认证状态监听
  void cancelAuthListener(StreamSubscription<AuthState> subscription) {
    subscription.cancel();
  }

  // 调用 Supabase 函数
  Future<FunctionResponse> supabaseInvoke(
    String functionName, {
    Map<String, String>? headers,
    Object? body,
    Iterable<MultipartFile>? files,
    Map<String, dynamic>? queryParameters,
    HttpMethod method = HttpMethod.post,
    String? region,
  }) async {
    return await supabase.functions.invoke(
      functionName,
      headers: headers,
      body: body,
      files: files,
      queryParameters: queryParameters,
      method: method,
      region: region,
    );
  }

  // 初始化应用数据
  Future<void> initializeAppData() async {
    try {
      print('AppUtils.initializeAppData() starting...');

      final t2 = DateTime.now();
      GlobalStore().selectedCurrencyCode = 'JPY';
      GlobalStore().saveSelectedCurrencyCodeToPrefs();

      String userId = GlobalStore().userId ?? '';
      int accountId = GlobalStore().accountId ?? 0;

      print('initializeAppData - userId: $userId (${userId.runtimeType})');
      print(
        'initializeAppData - accountId: $accountId (${accountId.runtimeType})',
      );

      // 类型检查和转换
      if (GlobalStore().userId != null && GlobalStore().userId is! String) {
        print('Warning: userId is not String, converting...');
        userId = GlobalStore().userId.toString();
        GlobalStore().userId = userId; // 修正 GlobalStore 中的数据
      }

      if (GlobalStore().accountId != null && GlobalStore().accountId is! int) {
        print('Warning: accountId is not int, converting...');
        try {
          if (GlobalStore().accountId is String) {
            accountId = int.parse(GlobalStore().accountId as String);
          } else if (GlobalStore().accountId is double) {
            accountId = (GlobalStore().accountId as double).toInt();
          } else {
            throw Exception(
              'Cannot convert accountId to int: ${GlobalStore().accountId.runtimeType}',
            );
          }
          GlobalStore().accountId = accountId; // 修正 GlobalStore 中的数据
        } catch (e) {
          throw Exception(
            'Invalid accountId type: ${GlobalStore().accountId.runtimeType}',
          );
        }
      }

      if (userId.isEmpty || accountId == 0) {
        throw Exception('User ID or Account ID is not set in GlobalStore');
      }

      // 判断是否同步服务器，如果没有同步，则进行同步
      if (GlobalStore().lastSyncTime == null) {
        // 初始化数据库
        await db.initialize();

        // 再次确认类型正确
        print(
          'Before sync - userId: $userId (${userId.runtimeType}), accountId: $accountId (${accountId.runtimeType})',
        );

        await AppUtils().syncDataWithSupabase(userId, accountId, db);
        final t3_1 = DateTime.now();
        print('Sync data time: ${t3_1.difference(t2).inMilliseconds} ms');
        await GlobalStore().saveLastSyncTimeToPrefs();
      } else {
        print('No need to fetch historical data');
      }

      final t3 = DateTime.now();
      print('Sync data time: ${t3.difference(t2).inMilliseconds} ms');

      // 计算持仓并更新到 GlobalStore
      await AppUtils().calculatePortfolioValue(userId, accountId);
      await AppUtils().calculateAndSaveHistoricalPortfolioToPrefs();
      final t4 = DateTime.now();
      print('Calculate portfolio time: ${t4.difference(t3).inMilliseconds} ms');

      print('AppUtils.initializeAppData() completed successfully');
    } catch (e) {
      print('AppUtils.initializeAppData() error: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // 刷新总资产和总成本
  Future<void> refreshTotalAssetsAndCosts() async {
    try {
      print('开始刷新总资产和总成本...');

      // 同步加密货币数据
      final dbCryptoInfos = await AppUtils().getCryptoDataFromDB(db);
      print('从数据库获取到 ${dbCryptoInfos.length} 条加密货币信息');

      for (var cryptoInfo in dbCryptoInfos) {
        print('同步 ${cryptoInfo.cryptoExchange} 的余额数据...');
        await AppUtils().syncCryptoBalanceDataFromServer(cryptoInfo);
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
            await AppUtils().syncCryptoBalanceHistoryDataFromServer(
              cryptoInfo,
              balance['currency_code'] as String,
            );
          }
        }
      }

      // 取得总资产和总成本
      final assetsAndCostsMap = await AppUtils().getTotalAssetsAndCostsValue(
        dbCryptoInfos,
      );
      print('资产成本映射: $assetsAndCostsMap');

      GlobalStore().totalAssetsAndCostsMap = assetsAndCostsMap;
      GlobalStore().saveTotalAssetsAndCostsMapToPrefs();
    } catch (e) {
      print('Error refreshing total assets and costs: $e');
    }
  }

  // -------------------------------------------------
  // 获取股票搜索建议
  // -------------------------------------------------
  Future<List<Stock>> fetchStockSuggestions(
    String value,
    String exchange,
  ) async {
    final response = await supabaseInvoke(
      'money_grow_api',
      queryParameters: {
        'action': 'stock-search',
        'q': value,
        'exchange': exchange,
        'limit': '5',
      },
      method: HttpMethod.get,
    );

    List<Stock> result = [];
    if (response.status == 200) {
      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
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
    final response = await supabaseInvoke(
      'money_grow_api',
      queryParameters: {'action': 'user-assets', 'user_id': userId},
      body: assetData,
      method: HttpMethod.post,
    );

    if (response.status == 200 || response.status == 201) {
      // 1. 解析返回的 asset id
      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
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
      print('Create asset failed: ${response.status} ${response.data}');
      return false;
    }
  }

  // -------------------------------------------------
  // 创建或更新暗号资产Key
  // -------------------------------------------------
  Future<bool> createOrUpdateCryptoInfo({
    required String userId,
    required Map<String, dynamic> cryptoData,
  }) async {
    final response = await supabaseInvoke(
      'money_grow_api',
      queryParameters: {'action': 'user-cryptoInfo', 'user_id': userId},
      body: cryptoData,
      method: HttpMethod.post,
    );

    if (response.status == 200 || response.status == 201) {
      // 操作成功
      return true;
    }
    return false;
  }

  // -------------------------------------------------
  // 创建或更新暗号资产Key
  // -------------------------------------------------
  Future<bool> deleteCryptoInfo({
    required String userId,
    required Map<String, dynamic> cryptoData,
  }) async {
    final response = await supabaseInvoke(
      'money_grow_api',
      queryParameters: {'action': 'user-cryptoInfo', 'user_id': userId},
      body: cryptoData,
      method: HttpMethod.delete,
    );
    if (response.status == 200 || response.status == 201) {
      // 操作成功
      return true;
    }
    return false;
  }

  // -------------------------------------------------
  // 从数据库获取加密资产数据
  // -------------------------------------------------
  Future<List<CryptoInfoData>> getCryptoDataFromDB(AppDatabase db) async {
    // 从数据库获取加密资产数据（如果有的话）
    // 从CryptoInfo表获取数据(USER_ID = 当前用户ID, Account_ID = 当前账户ID)
    final int? accountId = GlobalStore().accountId;
    if (accountId == null) {
      print('No accountId available.');
      return [];
    }
    final dbCryptoInfos = await (db.select(
      db.cryptoInfo,
    )..where((tbl) => tbl.accountId.equals(accountId))).get();
    print('Crypto Infos from DB: $dbCryptoInfos');

    return dbCryptoInfos;
  }

  // -------------------------------------------------
  // 从服务器同步加密资产余额数据
  // -------------------------------------------------
  Future<void> syncCryptoBalanceDataFromServer(
    CryptoInfoData cryptoInfo,
  ) async {
    // 调用 Bitflyer API
    List<dynamic> balances = [];

    if (cryptoInfo.cryptoExchange.toLowerCase() == 'bitflyer') {
      final api = BitflyerApi(cryptoInfo.apiKey, cryptoInfo.apiSecret);
      if (await api.checkApiKeyAndSecret()) {
        balances = await api.getBalances(true);

        // 更新缓存
        GlobalStore().cryptoBalanceDataCache['bitflyer'] = {
          'balances': balances,
          'balanceHistory':
              GlobalStore()
                  .cryptoBalanceDataCache['bitflyer']?['balanceHistory'] ??
              [],
        };
        await GlobalStore().saveCryptoBalanceDataCacheToPrefs();
        print('Bitflyer Balances Success: $balances');
      } else {
        print('Bitflyer API key or secret is missing, skipping API call.');
      }
    }
  }

  // -------------------------------------------------
  // 从服务器同步加密资产余额历史数据
  // -------------------------------------------------
  Future<void> syncCryptoBalanceHistoryDataFromServer(
    CryptoInfoData cryptoInfo,
    String currencyCode,
  ) async {
    // 调用 Bitflyer API
    List<dynamic> balanceHistory = [];

    if (cryptoInfo.cryptoExchange.toLowerCase() == 'bitflyer') {
      final api = BitflyerApi(cryptoInfo.apiKey, cryptoInfo.apiSecret);
      if (await api.checkApiKeyAndSecret()) {
        balanceHistory = await api.getBalanceHistory(
          true,
          currencyCode: currencyCode,
          count: 100,
        );

        // 更新缓存
        GlobalStore()
                .cryptoBalanceDataCache['bitflyer']?['balanceHistory_$currencyCode'] =
            balanceHistory;
        await GlobalStore().saveCryptoBalanceDataCacheToPrefs();
        print('Bitflyer Balance History Success: $balanceHistory');
      } else {
        print('Bitflyer API key or secret is missing, skipping API call.');
      }
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
    if (GlobalStore().cryptoBalanceDataCache.keys.isNotEmpty) {
      for (var exchange in GlobalStore().cryptoBalanceDataCache.keys) {
        final balances =
            GlobalStore().cryptoBalanceDataCache[exchange]?['balances'];
        if (balances != null && balances.isNotEmpty) {
          for (var balance in balances) {
            final currencyCode = balance['currency_code'];
            if (currencyCode != 'JPY' &&
                balance['amount'] > 0.0 &&
                !stocksList.any((s) => s.ticker == '$currencyCode-JPY')) {
              stocksList.add(
                Stock(
                  id: -1,
                  ticker: '$currencyCode-JPY',
                  exchange: 'CRYPTO',
                  name: '$currencyCode-JPY',
                  currency: 'JPY',
                  country: 'US',
                  status: 'active',
                ),
              );
            }
          }
        }
      }
    }
    stocksList.add(
      Stock(
        id: -1,
        ticker: 'JPY=X',
        exchange: 'US',
        name: '',
        currency: 'USD',
        country: 'US',
        status: 'active',
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
        status: 'active',
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
  Future<Map<String, Map<String, double>>> getTotalAssetsAndCostsValue(
    List<CryptoInfoData> dbCryptoInfos,
  ) async {
    print('=== getTotalAssetsAndCostsValue 开始 ===');
    print('输入参数 dbCryptoInfos: ${dbCryptoInfos.length} 条记录');

    double stockTotalAssets = 0.0;
    double stockTotalCosts = 0.0;
    final selectedCurrencyCode = GlobalStore().selectedCurrencyCode;
    print('当前选择的货币: $selectedCurrencyCode');

    // 获取最新股票价格
    try {
      await AppUtils().getStockPricesByYHFinanceAPI();
    } catch (e) {
      print('获取股票价格失败: $e');
    }

    // 计算股票总资产和总成本
    print('开始计算股票资产，Portfolio 数量: ${GlobalStore().portfolio.length}');
    for (var item in GlobalStore().portfolio) {
      final qty = item['quantity'] as num? ?? 0;
      final buyPrice = item['buyPrice'] as num? ?? 0;
      final code = item['code'] as String? ?? '';
      final exchange = item['exchange'] as String? ?? 'JP';
      final currency = item['currency'] as String? ?? 'JPY';
      final fee = item['fee'] as num? ?? 0;
      final feeCurrency = item['feeCurrency'] as String? ?? currency;

      print('处理股票: $code, 数量: $qty, 买入价格: $buyPrice');

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

      print(
        '股票计算结果: 资产+${qty * currentPrice * rate}, 成本+${qty * buyPrice * rate + fee * feeRate}',
      );
    }

    print('股票总计: 资产=$stockTotalAssets, 成本=$stockTotalCosts');

    // 计算加密资产总资产和总成本
    double cryptoTotalAssets = 0.0;
    double cryptoTotalCosts = 0.0;
    final cryptoBalanceCache = GlobalStore().cryptoBalanceDataCache;

    print('开始计算加密货币资产');
    print('加密货币余额缓存: $cryptoBalanceCache');

    for (var exchangeEntry in cryptoBalanceCache.entries) {
      final exchange = exchangeEntry.key;
      final balances = exchangeEntry.value['balances'];

      print('处理交易所: $exchange');
      print('余额数据: $balances');

      if (balances != null && balances.isNotEmpty) {
        CryptoInfoData? cryptoInfo;
        try {
          cryptoInfo = dbCryptoInfos.firstWhere(
            (info) => info.cryptoExchange.toLowerCase() == exchange,
          );
          print('找到匹配的 cryptoInfo: ${cryptoInfo.cryptoExchange}');
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

            print('处理加密货币: $currencyCode, 数量: $amount');

            if (currencyCode == 'JPY' || amount <= 0.0) {
              print('跳过 $currencyCode (JPY或数量<=0)');
              continue;
            }

            final rate =
                GlobalStore()
                    .currentStockPrices['JPY$selectedCurrencyCode=X'] ??
                1.0;
            double currentPrice =
                GlobalStore().currentStockPrices['$currencyCode-JPY'] ?? 0.0;

            print('当前价格: $currentPrice, 汇率: $rate');

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
                  print('从 BitFlyer API 获取价格: $currentPrice');
                } catch (e) {
                  print('BitFlyer API 调用失败: $e');
                  currentPrice = 0.0;
                }
              }
            }

            if (currentPrice > 0) {
              cryptoTotalAssets += amount * currentPrice * rate;

              try {
                final cost = await calculateCryptoCost(
                  cryptoInfo,
                  currencyCode,
                  amount,
                  currentPrice,
                );
                cryptoTotalCosts += cost * rate;
                print(
                  '加密货币计算: $currencyCode, 资产+${amount * currentPrice * rate}, 成本+${cost * rate}',
                );
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

    print('加密货币总计: 资产=$cryptoTotalAssets, 成本=$cryptoTotalCosts');

    final result = {
      'stock': {'totalAssets': stockTotalAssets, 'totalCosts': stockTotalCosts},
      'crypto': {
        'totalAssets': cryptoTotalAssets,
        'totalCosts': cryptoTotalCosts,
      },
    };

    print('=== getTotalAssetsAndCostsValue 结束 ===');
    print('返回结果: $result');
    return result;
  }

  // -------------------------------------------------
  // 计算加密资产的成本
  // -------------------------------------------------
  Future<double> calculateCryptoCost(
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

        final bitflyerbalanceHistory = balanceHistoryData as List<dynamic>;
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
                  break;
                } else {
                  totalCost += buyQty * price;
                  currentAmount += buyQty;
                }
                break;

              case 'SELL':
              case 'WITHDRAW':
              case 'CANCEL_COLL':
              case 'PAYMENT':
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

            if (currentAmount >= totalAmount) break;
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
    final response = await supabaseInvoke(
      'money_grow_api',
      queryParameters: {
        'action': 'stock-prices',
        'stock_ids': stockIds,
        'start_date': startDate,
        'end_date': endDate,
      },
      method: HttpMethod.get,
    );

    if (response.status == 200 || response.status == 201) {
      //final historicalPortfolio = GlobalStore().historicalPortfolio;
      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
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
    try {
      final t0 = DateTime.now();
      final response = await supabaseInvoke(
        'money_grow_api',
        queryParameters: {'action': 'user-summary', 'user_id': userId},
        method: HttpMethod.get,
      );
      final t1 = DateTime.now();
      print(
        'Fetch data from supabase time: ${t1.difference(t0).inMilliseconds} ms',
      );

      print('Sync data response: ${response.data}');
      print('Response data type: ${response.data.runtimeType}');

      if (response.status == 200) {
        // 安全地处理响应数据
        dynamic data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        print('Parsed data type: ${data.runtimeType}');

        if (data['account_info'] is List) {
          final accountInfoList = data['account_info'] as List;
          print('Found ${accountInfoList.length} accounts');

          for (var accountInfo in accountInfoList) {
            if (accountInfo is! Map<String, dynamic>) {
              print(
                'Skipping invalid account info: ${accountInfo.runtimeType}',
              );
              continue;
            }

            final accountInfoMap = accountInfo as Map<String, dynamic>;
            print('Processing account: ${accountInfoMap['account_id']}');

            if (accountInfoMap['account_id'] == accountId) {
              print('Found matching account: $accountId');

              // 1. 同步股票信息
              final stocks = accountInfoMap['stocks'] as List;
              print('Syncing ${stocks.length} stocks');

              final List<StocksCompanion> stockRecordsInsert = [];
              for (var stock in stocks) {
                if (stock is! Map<String, dynamic>) {
                  print('Skipping invalid stock data: ${stock.runtimeType}');
                  continue;
                }

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
              final tradeRecords = accountInfoMap['trade_records'] as List;
              print('Syncing ${tradeRecords.length} trade records');

              final List<TradeRecordsCompanion> tradeRecordsInsert = [];
              for (var trade in tradeRecords) {
                if (trade is! Map<String, dynamic>) {
                  print('Skipping invalid trade data: ${trade.runtimeType}');
                  continue;
                }

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
                    (num.tryParse(trade['quantity'].toString()) ?? 0)
                        .toDouble(),
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
              final sellMappings = accountInfoMap['trade_sell_mapping'] as List;
              print('Syncing ${sellMappings.length} sell mappings');

              final List<TradeSellMappingsCompanion> sellMappingsInsert = [];
              for (var mapping in sellMappings) {
                if (mapping is! Map<String, dynamic>) {
                  print(
                    'Skipping invalid mapping data: ${mapping.runtimeType}',
                  );
                  continue;
                }

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

              // 4. 同步crypto info
              final cryptoInfo = accountInfoMap['crypto_info'] as List;
              print('Syncing ${cryptoInfo.length} crypto info records');

              final List<CryptoInfoCompanion> cryptoInfoInsert = [];
              for (var crypto in cryptoInfo) {
                if (crypto is! Map<String, dynamic>) {
                  print('Skipping invalid crypto data: ${crypto.runtimeType}');
                  continue;
                }

                final cryptoCompanion = CryptoInfoCompanion(
                  accountId: Value(accountId),
                  cryptoExchange: Value(crypto['crypto_exchange']),
                  apiKey: Value(crypto['api_key']),
                  apiSecret: Value(crypto['api_secret']),
                  status: Value(crypto['status']),
                  createdAt: Value(
                    DateTime.tryParse(crypto['created_at']) ?? DateTime.now(),
                  ),
                  updatedAt: Value(
                    DateTime.tryParse(crypto['updated_at']) ?? DateTime.now(),
                  ),
                );
                cryptoInfoInsert.add(cryptoCompanion);
              }

              // 清空本地该账户的crypto info
              await (db.delete(
                db.cryptoInfo,
              )..where((tbl) => tbl.accountId.equals(accountId))).go();
              // 插入最新的crypto info
              await db.batch((batch) {
                batch.insertAll(db.cryptoInfo, cryptoInfoInsert);
              });

              final t5 = DateTime.now();
              print(
                'Sync crypto info time: ${t5.difference(t4).inMilliseconds} ms',
              );

              print('Account $accountId sync completed successfully');
            }
          }
        } else {
          print('No account_info found in response data');
        }
      } else {
        print('Sync failed with status: ${response.status}');
        throw Exception(
          'Server returned status ${response.status}: ${response.data}',
        );
      }
    } catch (e) {
      print('Error in syncDataWithSupabase: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
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
