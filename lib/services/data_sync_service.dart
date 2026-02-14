import 'dart:async';
import 'dart:convert';
import 'dart:developer' as console;
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:money_nest_app/services/fund_api.dart';
import 'package:money_nest_app/services/supabase_api.dart';
import 'package:money_nest_app/services/yahoo_api.dart';
import 'package:money_nest_app/services/bitflyer_api.dart';
import 'package:money_nest_app/util/global_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataSyncService {
  static const Duration priceTtl = Duration(hours: 1);
  static const Duration cryptoTtl = Duration(minutes: 15);

  final SupabaseApi supabaseApi;
  final YahooApi yahooApi;
  final SharedPreferences prefs;
  final AppDatabase db;

  DataSyncService({
    required this.supabaseApi,
    required this.yahooApi,
    required this.prefs,
    required this.db,
  });

  // -------------------------------------------------
  // 初始化DB数据
  // -------------------------------------------------
  Future<void> initializeDatabase() async {
    await db.initialize();
  }

  // -------------------------------------------------
  // 获取DB实例
  // -------------------------------------------------
  AppDatabase getDatabase() {
    return db;
  }

  // -------------------------------------------------
  // 用户登录
  // -------------------------------------------------
  Future<FunctionResponse> userLogin(String email, String password) async {
    return await supabaseApi.supabaseInvoke(
      'money_grow_api',
      queryParameters: {'action': 'login'},
      body: {'email': email, 'password': password},
      method: HttpMethod.post,
    );
  }

  // -------------------------------------------------
  // 用户注册
  // -------------------------------------------------
  Future<FunctionResponse> userRegister(
    String email,
    String password,
    String nickname,
  ) async {
    return await supabaseApi.supabaseInvoke(
      'money_grow_api',
      queryParameters: {'action': 'register'},
      body: {
        'email': email,
        'password': password,
        'name': nickname,
        'account_type': 'personal',
      },
      headers: {'Content-Type': 'application/json'},
      method: HttpMethod.post,
    );
  }

  // -------------------------------------------------
  // 判断是否需要同步用户数据
  // -------------------------------------------------
  Future<bool> checkIfNeedSyncUserData(String userId, int accountId) async {
    // 检查用户数据的最后同步时间
    final lastSyncTime = GlobalStore().lastSyncTime;
    if (lastSyncTime == null) {
      console.log('No last sync time found, need to sync user data');
      return true;
    }

    // 调用 Supabase 函数获取服务器上的用户数据最后更新时间
    final response = await supabaseApi.supabaseInvoke(
      'money_grow_api',
      queryParameters: {
        'action': 'get-last-sync-time',
        'user_id': userId,
        'account_id': accountId.toString(),
      },
      method: HttpMethod.get,
    );

    if (response.status == 200) {
      dynamic data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      final serverLastSyncTime = DateTime.parse(data['last_sync_time']);
      print('Server last sync time: $serverLastSyncTime');
      if (lastSyncTime.compareTo(serverLastSyncTime) != 0) {
        print('Last sync was modified, need to sync user data');
        return true;
      } else {
        print('User data is up to date, no need to sync');
        return false;
      }
    }
    print('Failed to get last sync time from server, need to sync user data');
    return true;
  }

  // 登录后或需要时拉取用户/持仓（带 quick meta 校验）
  Future<void> syncUserDataIfNeeded(String userId, int accountId) async {
    try {
      final t0 = DateTime.now();

      final response = await supabaseApi.supabaseInvoke(
        'money_grow_api',
        queryParameters: {'action': 'user-summary', 'user_id': userId},
        method: HttpMethod.get,
      );
      final t1 = DateTime.now();
      console.log(
        'Fetch data from supabase time: ${t1.difference(t0).inMilliseconds} ms',
      );

      console.log('Sync data response: ${response.data}');
      console.log('Response data type: ${response.data.runtimeType}');

      if (response.status == 200) {
        // 安全地处理响应数据
        dynamic data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        console.log('Parsed data type: ${data.runtimeType}');

        if (data['account_info'] is List) {
          final accountInfoList = data['account_info'] as List;
          console.log('Found ${accountInfoList.length} accounts');

          for (var accountInfo in accountInfoList) {
            if (accountInfo is! Map<String, dynamic>) {
              console.log(
                'Skipping invalid account info: ${accountInfo.runtimeType}',
              );
              continue;
            }

            final accountInfoMap = accountInfo;
            console.log('Processing account: ${accountInfoMap['account_id']}');

            if (accountInfoMap['account_id'] == accountId) {
              // 获取最近更新时间并保存
              final DateTime accountUpdatedAt = DateTime.parse(
                accountInfoMap['account_updated_at'],
              );
              GlobalStore().lastSyncTime = accountUpdatedAt;
              GlobalStore().saveLastSyncTimeToPrefs();

              // 初始化数据库
              await initializeDatabase();

              // 1. 同步股票信息
              final stocks = accountInfoMap['stocks'] as List;
              console.log('Syncing ${stocks.length} stocks');

              final List<StocksCompanion> stockRecordsInsert = [];
              for (var stock in stocks) {
                if (stock is! Map<String, dynamic>) {
                  console.log(
                    'Skipping invalid stock data: ${stock.runtimeType}',
                  );
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

              // 插入最新的股票信息
              await db.batch((batch) {
                batch.insertAll(db.stocks, stockRecordsInsert);
              });

              final t2 = DateTime.now();
              console.log(
                'Sync stocks and stock prices time: ${t2.difference(t1).inMilliseconds} ms',
              );

              // 2. 同步股票交易信息
              final tradeRecords = accountInfoMap['trade_records'] as List;
              console.log('Syncing ${tradeRecords.length} trade records');

              final List<TradeRecordsCompanion> tradeRecordsInsert = [];
              for (var trade in tradeRecords) {
                if (trade is! Map<String, dynamic>) {
                  console.log(
                    'Skipping invalid trade data: ${trade.runtimeType}',
                  );
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
                  remark: Value(trade['remark']),
                  profit: Value(
                    trade['profit'] != null
                        ? (num.tryParse(trade['profit'].toString()) ?? 0)
                              .toDouble()
                        : null,
                  ),
                );
                tradeRecordsInsert.add(record);
              }

              // 插入最新的交易记录
              await db.batch((batch) {
                batch.insertAll(db.tradeRecords, tradeRecordsInsert);
              });

              final t3 = DateTime.now();
              console.log(
                'Sync trade records time: ${t3.difference(t2).inMilliseconds} ms',
              );

              // 3. 同步卖出映射关系
              final sellMappings = accountInfoMap['trade_sell_mapping'] as List;
              console.log('Syncing ${sellMappings.length} sell mappings');

              final List<TradeSellMappingsCompanion> sellMappingsInsert = [];
              for (var mapping in sellMappings) {
                if (mapping is! Map<String, dynamic>) {
                  console.log(
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

              // 插入最新的卖出映射关系
              await db.batch((batch) {
                batch.insertAll(db.tradeSellMappings, sellMappingsInsert);
              });

              final t4 = DateTime.now();
              console.log(
                'Sync sell mappings time: ${t4.difference(t3).inMilliseconds} ms',
              );

              // 4. 同步crypto info
              final cryptoInfo = accountInfoMap['crypto_info'] as List;
              console.log('Syncing ${cryptoInfo.length} crypto info records');

              final List<CryptoInfoCompanion> cryptoInfoInsert = [];
              for (var crypto in cryptoInfo) {
                if (crypto is! Map<String, dynamic>) {
                  console.log(
                    'Skipping invalid crypto data: ${crypto.runtimeType}',
                  );
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

              // 插入最新的crypto info
              await db.batch((batch) {
                batch.insertAll(db.cryptoInfo, cryptoInfoInsert);
              });

              final t5 = DateTime.now();
              console.log(
                'Sync crypto info time: ${t5.difference(t4).inMilliseconds} ms',
              );

              // 5. 同步 Account Balances
              final accountBalances = accountInfoMap['account_balances'] as List? ?? [];
              console.log('Syncing ${accountBalances.length} account balances');

              final List<AccountBalancesCompanion> accountBalancesInsert = [];
              for (var balance in accountBalances) {
                if (balance is! Map<String, dynamic>) continue;
                
                accountBalancesInsert.add(AccountBalancesCompanion(
                  id: Value(balance['id']),
                  accountId: Value(balance['account_id']),
                  userId: Value(balance['user_id']),
                  currency: Value(balance['currency']),
                  amount: Value((num.tryParse(balance['amount'].toString()) ?? 0).toDouble()),
                  updatedAt: Value(DateTime.tryParse(balance['updated_at'].toString()) ?? DateTime.now()),
                ));
              }
              
              await db.batch((batch) {
                batch.insertAllOnConflictUpdate(db.accountBalances, accountBalancesInsert);
              });
              
              final t6 = DateTime.now();
              console.log(
                'Sync account balances time: ${t6.difference(t5).inMilliseconds} ms',
              );

              // 6. 同步 Cash Transactions
              final cashTransactions = accountInfoMap['cash_transactions'] as List? ?? [];
              console.log('Syncing ${cashTransactions.length} cash transactions');
              
              final List<CashTransactionsCompanion> cashTransactionsInsert = [];
              for (var tx in cashTransactions) {
                if (tx is! Map<String, dynamic>) continue;

                cashTransactionsInsert.add(CashTransactionsCompanion(
                  id: Value(tx['id']),
                  userId: Value(tx['user_id']),
                  accountId: Value(tx['account_id']),
                  currency: Value(tx['currency']),
                  amount: Value((num.tryParse(tx['amount'].toString()) ?? 0).toDouble()),
                  type: Value(tx['type']),
                  transactionDate: Value(DateTime.tryParse(tx['transaction_date'].toString()) ?? DateTime.now()),
                  remark: Value(tx['remark']),
                ));
              }

              await db.batch((batch) {
                batch.insertAllOnConflictUpdate(db.cashTransactions, cashTransactionsInsert);
              });
              
              final t7 = DateTime.now();
              console.log(
                'Sync cash transactions time: ${t7.difference(t6).inMilliseconds} ms',
              );

              console.log('Account $accountId sync completed successfully');
            }
          }
        } else {
          console.log('No account_info found in response data');
        }
      } else {
        console.log('Sync failed with status: ${response.status}');
        throw Exception(
          'Server returned status ${response.status}: ${response.data}',
        );
      }
    } catch (e) {
      console.log('Error in syncDataWithSupabase: $e');
      console.log('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // -------------------------------------------------
  // 获取股票搜索建议
  // -------------------------------------------------
  Future<List<Stock>> fetchStockSuggestions(
    String value,
    String exchange,
  ) async {
    final response = await supabaseApi.supabaseInvoke(
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
  // 获取基金搜索建议
  // -------------------------------------------------
  /*Future<List<Fund>> fetchFundSuggestions(String value) async {
    final response = await FundApi.fetchFundList(value);

    List<Fund> result = [];
    if (response.isNotEmpty) {
      result = response
          .map(
            (item) => Fund(
              isinCd: item['isinCd'],
              associFundCd: item['associFundCd'],
              fundNm: item['fundNm'],
              nisaFlg: item['nisaFlg'],
            ),
          )
          .toList();
    }

    return result;
  }*/
  Future<List<Fund>> fetchFundSuggestions(String value) async {
    final response = await supabaseApi.supabaseInvoke(
      'money_grow_api',
      queryParameters: {'action': 'fund-search', 'q': value, 'limit': '5'},
      method: HttpMethod.get,
    );

    List<Fund> result = [];
    if (response.status == 200) {
      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      if (data['results'] is List) {
        result = (data['results'] as List)
            .map(
              (item) => Fund(
                id: item['id'] as int,
                code: item['code'] as String,
                name: item['name'] as String,
                nameUs: item['name_us'] as String?,
                managementCompany: item['management_company'] as String?,
                foundationDate: item['foundation_date'] != null
                    ? DateTime.tryParse(item['foundation_date'].toString())
                    : null,
                tsumitateFlag: item['tsumitate_flag'] as bool?,
                isinCd: item['isin_cd'] as String?,
              ),
            )
            .toList();
      }
    }

    return result;
  }

  // -------------------------------------------------
  // 创建股票资产（买入或卖出）
  // -------------------------------------------------
  Future<bool> createOrUpdateStockTrade(
    String mode, {
    required String userId,
    required Map<String, dynamic> assetData,
    required Map<String, dynamic>? stockData, // 传递股票信息
  }) async {
    try {
      final response = await supabaseApi.supabaseInvoke(
        'money_grow_api',
        queryParameters: {'action': 'user-assets', 'user_id': userId},
        body: assetData,
        method: mode == 'add' ? HttpMethod.post : HttpMethod.put,
      );

      if (response.status == 200 || response.status == 201) {
        // 1. 解析返回的 trade id
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        final int? tradeId = mode == 'add'
            ? (data['trade_id'] is int
                  ? data['trade_id']
                  : int.tryParse(data['trade_id']?.toString() ?? ''))
            : assetData['id'];
        final double? profit = data['profit'] != null
            ? (num.tryParse(data['profit'].toString()) ?? 0).toDouble()
            : null;
        final DateTime? accountUpdatedAt = DateTime.tryParse(
          data['account_updated_at'],
        );

        if (tradeId != null && accountUpdatedAt != null) {
          // 卖出mapping数据
          final sellMappingData =
              assetData['sell_mappings'] is List &&
                  (assetData['sell_mappings'] as List).isNotEmpty
              ? (assetData['sell_mappings'] as List)
                    .map(
                      (m) => {
                        "sell_id": tradeId!,
                        "buy_id": m['buy_id'],
                        "quantity": m['quantity'],
                      },
                    )
                    .toList()
              : null;
          if (mode == 'add') {
            // 插入本地 TradeRecords
            await db
                .into(db.tradeRecords)
                .insert(
                  TradeRecordsCompanion(
                    id: Value(tradeId),
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
                      (num.tryParse(assetData['price'].toString()) ?? 0)
                          .toDouble(),
                    ),
                    feeAmount: Value(
                      (num.tryParse(
                                assetData['fee_amount']?.toString() ?? '0',
                              ) ??
                              0)
                          .toDouble(),
                    ),
                    feeCurrency: Value(assetData['fee_currency']),
                    remark: Value(assetData['remark']),
                    profit: Value(profit),
                  ),
                );
          } else if (mode == 'edit') {
            // 更新本地 TradeRecords
            await (db.update(
              db.tradeRecords,
            )..where((tbl) => tbl.id.equals(tradeId))).write(
              TradeRecordsCompanion(
                tradeDate: Value(
                  DateFormat('yyyy-MM-dd').parse(assetData['trade_date']!),
                ),
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
                remark: Value(assetData['remark']),
                profit: Value(profit),
              ),
            );
          }

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

          // 4. 插入本地 SellMappings
          if (sellMappingData != null) {
            if (mode == 'edit') {
              // 先删除已有的映射关系
              await (db.delete(
                db.tradeSellMappings,
              )..where((tbl) => tbl.sellId.equals(tradeId))).go();
            }

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

          // 更新最后同步时间
          GlobalStore().lastSyncTime = accountUpdatedAt;
          GlobalStore().saveLastSyncTimeToPrefs();
          print('更新accountUpdatedAt: $accountUpdatedAt');
        }
        return true;
      } else {
        print('Create asset failed: ${response.status} ${response.data}');
        return false;
      }
    } catch (e) {
      print('Error in createAsset: $e');
      print('Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  // -------------------------------------------------
  // 删除资产（买入或卖出）
  // -------------------------------------------------
  Future<bool> deleteAsset({
    required String userId,
    required int accountId,
    required int tradeId,
  }) async {
    try {
      final response = await supabaseApi.supabaseInvoke(
        'money_grow_api',
        queryParameters: {'action': 'user-assets', 'user_id': userId},
        body: {'account_id': accountId, 'id': tradeId},
        method: HttpMethod.delete,
      );

      if (response.status == 200 || response.status == 201) {
        // 1. 解析返回的 trade id
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        final DateTime? accountUpdatedAt = DateTime.tryParse(
          data['account_updated_at'],
        );

        if (accountUpdatedAt != null) {
          // 取得股票ID
          final localTrade = await (db.select(
            db.tradeRecords,
          )..where((tbl) => tbl.id.equals(tradeId))).getSingleOrNull();
          final stockId = localTrade?.assetId;

          // 删除本地 TradeRecords
          await (db.delete(
            db.tradeRecords,
          )..where((tbl) => tbl.id.equals(tradeId))).go();

          // 删除本地 TradeSellMappings
          await (db.delete(
            db.tradeSellMappings,
          )..where((tbl) => tbl.sellId.equals(tradeId))).go();

          // 删除本地 Stocks (如果没有其他交易使用该股票)
          if (stockId != null) {
            final otherTrades =
                await (db.select(db.tradeRecords)..where(
                      (tbl) =>
                          tbl.assetId.equals(stockId) &
                          tbl.assetType.equals('stock'),
                    ))
                    .get();
            if (otherTrades.isEmpty) {
              await (db.delete(
                db.stocks,
              )..where((tbl) => tbl.id.equals(stockId))).go();
            }
          }

          // 更新最后同步时间
          GlobalStore().lastSyncTime = accountUpdatedAt;
          GlobalStore().saveLastSyncTimeToPrefs();
          print('更新accountUpdatedAt: $accountUpdatedAt');
        }
        return true;
      } else {
        print('Delete asset failed: ${response.status} ${response.data}');
        return false;
      }
    } catch (e) {
      print('Error in deleteAsset: $e');
      print('Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  // -------------------------------------------------
  // 创建Fund资产（买入或卖出）
  // -------------------------------------------------
  Future<bool> createOrUpdateFundTrade(
    String mode, {
    required String userId,
    required Map<String, dynamic> fundTransactionData,
    required Fund? fundData,
  }) async {
    try {
      final response = await supabaseApi.supabaseInvoke(
        'money_grow_api',
        queryParameters: {'action': 'user-fund', 'user_id': userId},
        body: fundTransactionData,
        method: mode == 'add' ? HttpMethod.post : HttpMethod.put,
      );

      if (response.status == 200 || response.status == 201) {
        // 1. 解析返回的 trade id
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        final int? transactionId = mode == 'add'
            ? (data['transaction_id'] is int
                  ? data['transaction_id']
                  : int.tryParse(data['transaction_id']?.toString() ?? ''))
            : null; //assetData['id'];
        final DateTime? accountUpdatedAt = DateTime.tryParse(
          data['account_updated_at'],
        );

        if (transactionId != null && accountUpdatedAt != null) {
          if (mode == 'add') {
            // 插入本地 FundTransactions
            await db
                .into(db.fundTransactions)
                .insert(
                  FundTransactionsCompanion(
                    id: Value(transactionId),
                    userId: Value(userId),
                    accountId: Value(fundTransactionData['account_id']),
                    fundId: Value(fundTransactionData['fund_id']),
                    tradeDate: Value(
                      DateFormat(
                        'yyyy/MM/dd',
                      ).parse(fundTransactionData['trade_date']!),
                    ),
                    action: Value(fundTransactionData['action']),
                    tradeType: Value(fundTransactionData['trade_type']),
                    accountType: Value(fundTransactionData['account_type']),
                    amount: Value(
                      (num.tryParse(fundTransactionData['amount'].toString()) ??
                              0)
                          .toDouble(),
                    ),
                    quantity: Value(
                      (num.tryParse(
                                fundTransactionData['quantity'].toString(),
                              ) ??
                              0)
                          .toDouble(),
                    ),
                    price: Value(
                      (num.tryParse(fundTransactionData['price'].toString()) ??
                              0)
                          .toDouble(),
                    ),
                    feeAmount: Value(
                      (num.tryParse(
                                fundTransactionData['fee_amount']?.toString() ??
                                    '0',
                              ) ??
                              0)
                          .toDouble(),
                    ),
                    feeCurrency: Value(fundTransactionData['fee_currency']),
                    recurringFrequencyType: Value(
                      fundTransactionData['recurring_frequency_type'],
                    ),
                    recurringFrequencyConfig: Value(
                      fundTransactionData['recurring_frequency_config'],
                    ),
                    recurringStartDate: Value(
                      DateFormat(
                        'yyyy/MM/dd',
                      ).parse(fundTransactionData['recurring_start_date']!),
                    ),
                    recurringEndDate: Value(
                      DateFormat(
                        'yyyy/MM/dd',
                      ).parse(fundTransactionData['recurring_end_date']!),
                    ),
                    recurringStatus: Value(
                      fundTransactionData['recurring_status'],
                    ),

                    remark: Value(fundTransactionData['remark']),
                  ),
                );
          }

          // 3. 插入或更新本地 Funds
          if (fundData != null) {
            final fundId = fundData.id;
            // 检查本地是否已有该基金
            final existing = await (db.select(
              db.funds,
            )..where((tbl) => tbl.id.equals(fundId))).getSingleOrNull();

            final fundCompanion = FundsCompanion(
              id: Value(fundId),
              code: Value(fundData.code),
              name: Value(fundData.name),
              nameUs: Value(fundData.nameUs),
              managementCompany: Value(fundData.managementCompany),
              foundationDate: Value(fundData.foundationDate),
              tsumitateFlag: Value(fundData.tsumitateFlag),
              isinCd: Value(fundData.isinCd),
            );

            if (existing == null) {
              await db.into(db.funds).insert(fundCompanion);
            } else {
              await (db.update(
                db.funds,
              )..where((tbl) => tbl.id.equals(fundId))).write(fundCompanion);
            }
          }

          // 更新最后同步时间
          GlobalStore().lastSyncTime = accountUpdatedAt;
          GlobalStore().saveLastSyncTimeToPrefs();
          print('更新accountUpdatedAt: $accountUpdatedAt');
        }
        return true;
      } else {
        print('Create asset failed: ${response.status} ${response.data}');
        return false;
      }
    } catch (e) {
      print('Error in createOrUpdateFundTrade: $e');
      print('Stack trace: ${StackTrace.current}');
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
    final response = await supabaseApi.supabaseInvoke(
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
    final response = await supabaseApi.supabaseInvoke(
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
  // 通过 Yahoo Finance API 获取最新股票价格
  // -------------------------------------------------
  Future<bool> getStockPricesByYHFinanceAPI() async {
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
        return false;
      }
    }

    final tickers = stocksList
        .map((s) => '${s.ticker}${s.exchange == 'JP' ? '.T' : ''}')
        .toList();

    final data = await yahooApi.fetchBatchQuotes(tickers);

    final Map<String, double> prices = {};
    // 解析返回的股票价格数据
    if (data is Map && data.containsKey('body') && data['body'] is List) {
      for (final stock in data['body'] as List) {
        try {
          final symbol = stock['symbol']?.toString() ?? '';
          final price =
              (stock['regularMarketPrice'] as num?)?.toDouble() ??
              (stock['price'] as num?)?.toDouble() ??
              0.0;
          if (symbol.isNotEmpty) prices[symbol] = price;
        } catch (_) {}
      }
    } else if (data is Map) {
      // assume symbol -> { price: ... } map
      for (final entry in data.entries) {
        final k = entry.key;
        final v = entry.value;
        if (v is Map) {
          final price =
              (v['price'] as num?)?.toDouble() ??
              (v['regularMarketPrice'] as num?)?.toDouble() ??
              0.0;
          prices[k.toString()] = price;
        }
      }
    } else {
      console.log('Unexpected yahoo data shape: ${data.runtimeType}');
    }

    // 如果没有获取到任何价格，则不更新
    if (prices.isEmpty) {
      print('No stock prices fetched from Yahoo Finance API.');
      return false;
    }

    // 更新全局缓存
    GlobalStore().currentStockPrices = prices;
    // 更新最后获取时间
    GlobalStore().stockPricesLastUpdated = DateTime.now();
    // 保存到 SharedPreferences
    await GlobalStore().saveCurrentStockPricesToPrefs();
    await GlobalStore().saveStockPricesLastUpdatedToPrefs();

    return true;
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
    final response = await supabaseApi.supabaseInvoke(
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
        for (var price in (stockPrices as List)) {
          console.log(price);
        }
      }
      for (var rate in (fxRates as List)) {
        console.log(rate);
      }
    }

    return {};
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
  // 从数据库获取加密资产数据
  // -------------------------------------------------
  Future<List<CryptoInfoData>> getCryptoDataFromDB() async {
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
  // 获取指定日期范围的成本和价格历史数据
  // -------------------------------------------------
  dynamic getCostAndPriceHistoryData(
    DataSyncService dataSync,
    DateTime startDate,
    DateTime endDate,
  ) {
    final stockIds = GlobalStore().portfolio
        .map((item) => item['stockId'].toString())
        .join(',');
    DateTime? syncStartDate = GlobalStore().syncStartDate;
    DateTime? syncEndDate = GlobalStore().syncEndDate;

    if (syncStartDate == null || syncEndDate == null) {
      // [startDate, endDate]を取得
      dataSync.getHistoryPricesDataFromSupabase(stockIds, startDate, endDate);
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
      dataSync.getHistoryPricesDataFromSupabase(
        stockIds,
        syncEndDate.add(const Duration(days: 1)),
        endDate,
      );
      GlobalStore().syncEndDate = endDate;
    } else if (startDate.isBefore(syncStartDate) &&
        (endDate.isBefore(syncEndDate) ||
            endDate.isAtSameMomentAs(syncEndDate))) {
      // [startDate, syncStartDate-1]を取得
      dataSync.getHistoryPricesDataFromSupabase(
        stockIds,
        startDate,
        syncStartDate.subtract(const Duration(days: 1)),
      );
      GlobalStore().syncStartDate = startDate;
    } else if (startDate.isBefore(syncStartDate) &&
        endDate.isAfter(syncEndDate)) {
      // [startDate, syncStartDate-1]、[syncEndDate+1, endDate]を取得
      dataSync.getHistoryPricesDataFromSupabase(
        stockIds,
        startDate,
        syncStartDate.subtract(const Duration(days: 1)),
      );
      dataSync.getHistoryPricesDataFromSupabase(
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
  }

  // -------------------------------------------------
  // 现金交易（入金/出金）追加
  // -------------------------------------------------
  Future<void> addCashTransaction({
    required bool isDeposit,
    required double amount,
    required String currency,
    required DateTime date,
    String? memo,
  }) async {
    try {
      final userId = GlobalStore().userId!;
      final accountId = GlobalStore().accountId!;

      // 1. 调用 Supabase Edge Function 处理逻辑
      final response = await supabaseApi.supabaseInvoke(
        'money_grow_api',
        queryParameters: {
          'action': 'user-cash',
          'user_id': userId,
        },
        body: {
          'account_id': accountId,
          'currency': currency,
          'amount': amount,
          'type': isDeposit ? 'deposit' : 'withdraw',
          'transaction_date': date.toIso8601String(),
          'remark': memo,
        },
        method: HttpMethod.post,
      );

      if (response.status != 201 && response.status != 200) {
        throw Exception('Failed to add cash transaction: ${response.data}');
      }

      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }
      final txRes = data['transaction'];
      final upsertRes = data['balance'];

      // 5. 保存到本地数据库 (需要先运行 build_runner 生成代码)
      // 由于 build_runner 未运行，这里暂时注释掉本地保存部分，或者使用 raw sql
      // TODO: Uncomment after generating drifted code
      
      await db.into(db.accountBalances).insertOnConflictUpdate(
        AccountBalancesCompanion(
          id: Value(upsertRes['id'] as int),
          accountId: Value(accountId),
          userId: Value(userId),
          currency: Value(currency),
          amount: Value((upsertRes['amount'] as num).toDouble()),
          updatedAt: Value(DateTime.parse(upsertRes['updated_at'])),
        ),
      );
      
      await db.into(db.cashTransactions).insert(
        CashTransactionsCompanion(
          id: Value(txRes['id'] as int),
          userId: Value(userId),
          accountId: Value(accountId),
          currency: Value(currency),
          amount: Value(amount),
          type: Value(isDeposit ? 'deposit' : 'withdraw'),
          transactionDate: Value(DateTime.parse(txRes['transaction_date'])),
          remark: Value(memo),
        ),
      );
      
      
      // 更新 GlobalStore 缓存（简单版）
      // GlobalStore().totalAssetsAndCostsMap... 需要重新拉取或手动更新
      // 暂时只打印日志
      print('Cash Transaction Added: $txRes');

    } catch (e) {
      print('Error adding cash transaction: $e');
      rethrow;
    }
  }
}
