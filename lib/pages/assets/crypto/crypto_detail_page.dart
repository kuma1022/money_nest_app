import 'package:collection/collection.dart';
import 'package:drift/drift.dart' hide Column;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:money_nest_app/components/card_section.dart';
import 'package:money_nest_app/components/custom_tab.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:intl/intl.dart';
import 'package:money_nest_app/util/bitflyer_api.dart';
import 'package:money_nest_app/util/global_store.dart';

class CryptoDetailPage extends StatefulWidget {
  final AppDatabase db;
  final ScrollController? scrollController;

  const CryptoDetailPage({super.key, required this.db, this.scrollController});

  @override
  State<CryptoDetailPage> createState() => _CryptoDetailPageState();
}

class _CryptoDetailPageState extends State<CryptoDetailPage> {
  String _selectedCurrency = 'JPY'; // 添加货币筛选状态
  List<dynamic> bitFlyerBalances = [];
  List<dynamic> bitFlyerBalanceHistory = [];
  List<String> availableCurrencies = [];
  List<CryptoInfoData> cryptoInfos = [];
  List<Map<String, dynamic>> cryptoAssets = [];
  bool _isInitializing = true; // 添加初始化loading状态

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // 添加单独的初始化方法
  Future<void> _initializeData() async {
    setState(() {
      _isInitializing = true;
    });

    try {
      //await getCryptoDataFromDB();
      final dbCryptoInfos = await AppUtils().getCryptoDataFromDB(widget.db);
      // 检查 widget 是否仍然挂载
      if (mounted) {
        setState(() {
          cryptoInfos = dbCryptoInfos;
        });
      }
      await syncCryptoDataFromServer();
    } catch (e) {
      print('Error in _initializeData: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('データの読み込みに失敗しました')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> syncCryptoDataFromServer() async {
    // 调用 Bitflyer API
    try {
      final String firstCurrency = 'JPY';
      List<dynamic> balances = [];

      for (var cryptoInfo in cryptoInfos) {
        await AppUtils().syncCryptoBalanceDataFromServer(cryptoInfo);
        balances =
            GlobalStore().cryptoBalanceDataCache[cryptoInfo.cryptoExchange
                .toLowerCase()]?['balances'] ??
            [];

        if (balances.isNotEmpty) {
          // 取各个货币的当前价格
          for (var balance in balances) {
            final double amount = balance['amount'] as double? ?? 0.0;
            final String currencyCode =
                balance['currency_code'] as String? ?? 'JPY';
            if (amount == 0.0 || currencyCode == 'JPY') {
              balance['current_price'] = 1.0;
              continue;
            }
            try {
              double currentPrice =
                  GlobalStore().currentStockPrices['$currencyCode-JPY'] ?? 0.0;
              if (currentPrice == 0.0) {
                if (cryptoInfo.cryptoExchange.toLowerCase() == 'bitflyer') {
                  final api = BitflyerApi(
                    cryptoInfo.apiKey,
                    cryptoInfo.apiSecret,
                  );
                  final Map<String, dynamic> tickerData = await api.getTicker(
                    true,
                    '${currencyCode}_JPY',
                  );
                  currentPrice = tickerData['ltp'] as double;
                }
              }
              balance['current_price'] = currentPrice;
            } catch (e) {
              balance['current_price'] = 0.0;
            }
          }

          await AppUtils().syncCryptoBalanceHistoryDataFromServer(
            cryptoInfo,
            firstCurrency,
          );

          GlobalStore().cryptoBalanceDataCache[cryptoInfo.cryptoExchange
                  .toLowerCase()]?['balances'] =
              balances;
          GlobalStore().saveCryptoBalanceDataCacheToPrefs();
        }
      }

      // 检查 widget 是否仍然挂载
      if (mounted) {
        setState(() {
          _selectedCurrency = firstCurrency;

          // 安全地处理 bitflyer 数据
          if (GlobalStore().cryptoBalanceDataCache.containsKey('bitflyer')) {
            final bitflyerData =
                GlobalStore().cryptoBalanceDataCache['bitflyer'];
            if (bitflyerData != null) {
              bitFlyerBalances = bitflyerData['balances'] ?? [];
              bitFlyerBalanceHistory = bitflyerData['balanceHistory'] ?? [];
            }
          }

          // 获取所有可用的货币代码
          availableCurrencies = bitFlyerBalances.isNotEmpty
              ? bitFlyerBalances
                    .map((balance) => balance['currency_code']?.toString())
                    .where((currency) => currency != null)
                    .cast<String>()
                    .toSet()
                    .toList()
              : [];
          // 过滤出所有可用的货币资产
          cryptoAssets = bitFlyerBalances.isNotEmpty
              ? bitFlyerBalances
                    .where((balance) {
                      return (balance['currency_code'] as String != 'JPY' &&
                          balance['amount'] as double != 0.0);
                    })
                    .map((balance) {
                      final String name = balance['currency_code'];
                      final String symbol = balance['currency_code'];
                      final String amount =
                          '${balance['amount']} ${balance['currency_code']}';
                      final String unitPrice =
                          '${AppUtils().formatMoney(balance['current_price'], 'JPY')}/$symbol';
                      final double totalValue =
                          (balance['amount'] as double) *
                          (balance['current_price'] as double);
                      final String value = AppUtils().formatMoney(
                        totalValue,
                        'JPY',
                      );

                      return {
                        'exchange': 'bitflyer',
                        'name': name,
                        'symbol': symbol,
                        'amount': amount,
                        'totalValue': totalValue,
                        'value': value,
                        'unitPrice': unitPrice,
                      };
                    })
                    .toList()
              : [];
        });
      }
    } catch (e) {
      // 提示用户待会儿再试
      // 检查 widget 是否仍然挂载
      print('Error fetching crypto data: $e');
      print('Stack trace: ${StackTrace.current}'); // 添加堆栈跟踪以便调试
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('少し時間をおいてもう一度お試しください。')));
      }
    }
  }

  Future<List<dynamic>?> getBitflyerBalanceHistoryData(
    String currencyCode,
  ) async {
    // 调用 Bitflyer API
    try {
      print('Fetching Bitflyer balance history...$cryptoInfos');
      final CryptoInfoData? cryptoInfo = cryptoInfos.firstWhereOrNull(
        (info) => info.cryptoExchange.toLowerCase() == 'bitflyer',
      );
      print('Crypto Info for Bitflyer: $cryptoInfo');
      if (cryptoInfo == null ||
          cryptoInfo.apiKey.isEmpty ||
          cryptoInfo.apiSecret.isEmpty) {
        print('No crypto info for bitflyer found.');
        return null;
      }
      final api = BitflyerApi(cryptoInfo.apiKey, cryptoInfo.apiSecret);
      final List<dynamic> balanceHistory = await api.getBalanceHistory(
        false,
        currencyCode: currencyCode,
        count: 100,
      );
      print(
        'Bitflyer Balance History Success. Length: ${balanceHistory.length}',
      );
      return balanceHistory;
    } catch (e) {
      // 提示用户待会儿再试
      // 检查 widget 是否仍然挂载
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('少し時間をおいてもう一度お試しください。')));
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '暗号資産',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '取引所連携・資産管理',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
            child: SingleChildScrollView(
              controller: widget.scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  CustomTab(
                    tabs: ['概要', '入出金', '注文履歴'],
                    tabViews: [
                      _buildOverviewTab(),
                      _buildDepositWithdrawTab(),
                      _buildOrderHistoryTab(),
                    ],
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          // Loading 遮罩
          if (_isInitializing) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  // 修改loading界面为遮罩形式
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3), // 半透明黑色遮罩
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3), // 模糊效果
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.appUpGreen),
                strokeWidth: 3,
              ),
              SizedBox(height: 24),
              Text(
                '暗号資産データを読み込み中...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '取引所からの情報を取得しています',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 概要タブ
  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 总资产卡片
        CardSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.trending_up, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text(
                    '総資産',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const Spacer(),
                  Text(
                    '最終更新: ${DateFormat('yyyy/MM/dd HH:mm:ss').format(GlobalStore().cryptoLastSyncTime.values.isNotEmpty ? GlobalStore().cryptoLastSyncTime.values.reduce((a, b) => a.isAfter(b) ? a : b) : DateTime.now())}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                cryptoAssets.isNotEmpty
                    ? AppUtils().formatMoney(
                        cryptoAssets.fold(
                          0,
                          (sum, asset) => sum + (asset['totalValue'] as double),
                        ),
                        'JPY',
                      )
                    : '¥0',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '手動入力資産',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '¥0',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '取引所連携',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cryptoAssets.isNotEmpty
                              ? AppUtils().formatMoney(
                                  cryptoAssets.fold(
                                    0,
                                    (sum, asset) =>
                                        sum + (asset['totalValue'] as double),
                                  ),
                                  'JPY',
                                )
                              : '¥0',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 保有資産标题和追加按钮
        Row(
          children: [
            const Text(
              '保有資産',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // 添加资产功能
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.appUpGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16),
                  SizedBox(width: 4),
                  Text('追加', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 保有資産列表
        cryptoAssets.isEmpty
            ? const Center(
                child: Text(
                  '保有している暗号資産はありません',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : Column(
                children: cryptoAssets.map((asset) {
                  return _CryptoAssetCard(
                    iconData: asset['symbol'] == 'BTC'
                        ? Icons.currency_bitcoin
                        : Icons.account_balance,
                    name: asset['name']!,
                    symbol: asset['symbol']!,
                    amount: asset['amount']!,
                    value: asset['value']!,
                    unitPrice: asset['unitPrice']!,
                    backgroundColor: asset['symbol'] == 'BTC'
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    iconColor: asset['symbol'] == 'BTC'
                        ? Colors.orange
                        : Colors.blue,
                  );
                }).toList(),
              ),
        const SizedBox(height: 24),
        const Divider(color: Color(0xFFE5E6EA), thickness: 1),
        const SizedBox(height: 16),
        // 取引所连携标题
        Row(
          children: [
            const Text(
              '取引所連携',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'プレミアム',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '0 / 5 連携中',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 取引所连携列表
        Column(
          children: [
            _buildExchangeItem(
              'Binance',
              Colors.amber,
              cryptoInfos.any(
                (info) => info.cryptoExchange.toLowerCase() == 'binance',
              ),
            ),
            _buildExchangeItem(
              'Coinbase',
              Colors.blue,
              cryptoInfos.any(
                (info) => info.cryptoExchange.toLowerCase() == 'coinbase',
              ),
            ),
            _buildExchangeItem(
              'bitFlyer',
              Colors.red,
              cryptoInfos.any(
                (info) => info.cryptoExchange.toLowerCase() == 'bitflyer',
              ),
            ),
            _buildExchangeItem(
              'Kraken',
              Colors.purple,
              cryptoInfos.any(
                (info) => info.cryptoExchange.toLowerCase() == 'kraken',
              ),
            ),
            _buildExchangeItem(
              'bitbank',
              Colors.green,
              cryptoInfos.any(
                (info) => info.cryptoExchange.toLowerCase() == 'bitbank',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 入出金タブ
  Widget _buildDepositWithdrawTab() {
    final depositWithdrawHistory = bitFlyerBalanceHistory.isNotEmpty
        ? bitFlyerBalanceHistory
              .where((history) {
                return history['trade_type'] == 'DEPOSIT' ||
                    history['trade_type'] == 'WITHDRAW';
              })
              .map((history) {
                // 安全地查找手续费记录
                double? fee;
                try {
                  final feeRecord = bitFlyerBalanceHistory.firstWhere(
                    (h) =>
                        h['trade_type'] == 'FEE' &&
                        h['order_id'] == '${history['order_id']}F',
                    orElse: () => null,
                  );
                  fee = feeRecord?['amount']?.toDouble();
                } catch (e) {
                  fee = null;
                }

                return {
                  'type': history['trade_type'] == 'DEPOSIT'
                      ? 'deposit'
                      : 'withdraw',
                  'status': '完了',
                  'amount': history['amount'] != null
                      ? AppUtils().formatMoney(
                          (history['amount'] as num).abs().toDouble(),
                          history['currency_code'] ?? 'JPY',
                        )
                      : 'N/A',
                  'date': history['trade_date'] ?? 'N/A',
                  'txId': history['order_id'] != null
                      ? '${history['order_id'].toString().substring(0, 7)}...'
                      : 'N/A',
                  'currency': history['currency_code'] ?? 'JPY',
                  'fee': fee != null
                      ? AppUtils().formatMoney(
                          fee.abs(),
                          history['currency_code'] ?? 'JPY',
                        )
                      : null,
                  'isCompleted': true,
                };
              })
              .toList()
        : [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 入出金履歴标题和导出按钮
          Row(
            children: [
              const Text(
                '入出金履歴',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {
                  // 导出功能
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.download, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'エクスポート',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 货币筛选按钮
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: availableCurrencies.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final currency = availableCurrencies[index];
                final isSelected = currency == _selectedCurrency;

                return GestureDetector(
                  onTap: () async {
                    if (currency == _selectedCurrency) return;
                    final List<dynamic>? balanceHistoryList =
                        await getBitflyerBalanceHistoryData(currency);
                    if (balanceHistoryList != null) {
                      setState(() {
                        bitFlyerBalanceHistory = balanceHistoryList;
                        _selectedCurrency = currency;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.appUpGreen : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.appUpGreen
                            : const Color(0xFFE5E6EA),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      currency,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // 入出金履歴列表
          depositWithdrawHistory.isEmpty
              ? const Center(
                  child: Text(
                    '入出金履歴がありません',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: depositWithdrawHistory.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final transaction = depositWithdrawHistory[index];
                    return _DepositWithdrawCard(
                      type: transaction['type']! as String,
                      status: transaction['status']! as String,
                      amount: transaction['amount']! as String,
                      date: transaction['date']! as String,
                      txId: transaction['txId']! as String,
                      currency: transaction['currency']! as String,
                      fee: transaction['fee'] as String?,
                      isCompleted: transaction['isCompleted'] as bool,
                    );
                  },
                ),
        ],
      ),
    );
  }

  // 注文履歴タブ
  Widget _buildOrderHistoryTab() {
    final orderHistories = bitFlyerBalanceHistory.isNotEmpty
        ? bitFlyerBalanceHistory
              .where((history) {
                return history['trade_type'] == 'BUY' ||
                    history['trade_type'] == 'SELL';
              })
              .map((history) {
                return {
                  'pair': history['product_code'] ?? 'N/A',
                  'orderType': history['trade_type'] == 'BUY'
                      ? '買い'
                      : history['trade_type'] == 'SELL'
                      ? '売り'
                      : 'N/A',
                  'status': '約定',
                  'date': history['trade_date'] ?? 'N/A',
                  'type': '指値',
                  'price': history['price'] != null
                      ? AppUtils().formatMoney(
                          history['price'],
                          history['currency_code'] ?? 'JPY',
                        )
                      : 'N/A',
                  'amount': history['quantity']!.toString(),
                  'filledAmount':
                      history['quantity']!.toString() +
                      (history['product_code']!.toString().contains('_')
                          ? ' ${history['product_code']!.toString().split('_')[0]}'
                          : ''),
                  'totalAmount': history['amount'] != null
                      ? history['currency_code'] == 'JPY'
                            ? AppUtils().formatMoney(
                                (history['amount'] as double).abs(),
                                'JPY',
                              )
                            : (history['amount'] as double).abs().toString()
                      : 'N/A',
                  'isBuy': history['trade_type'] == 'BUY',
                };
              })
              .toList()
        : [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 注文履歴标题和导出按钮
          Row(
            children: [
              const Text(
                '注文履歴',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {
                  // 导出功能
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.download, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'エクスポート',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 货币筛选按钮
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: availableCurrencies.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final currency = availableCurrencies[index];
                final isSelected = currency == _selectedCurrency;

                return GestureDetector(
                  onTap: () async {
                    if (currency == _selectedCurrency) return;
                    final List<dynamic>? balanceHistoryList =
                        await getBitflyerBalanceHistoryData(currency);
                    if (balanceHistoryList != null) {
                      setState(() {
                        bitFlyerBalanceHistory = balanceHistoryList;
                        _selectedCurrency = currency;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.appUpGreen : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.appUpGreen
                            : const Color(0xFFE5E6EA),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      currency == 'JPY' ? 'すべて' : currency,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // 注文履歴列表
          orderHistories.isEmpty
              ? Center(
                  child: Text(
                    '$_selectedCurrency の注文履歴がありません',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orderHistories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = orderHistories[index];
                    return _OrderHistoryCard(
                      pair: order['pair']! as String,
                      orderType: order['orderType']! as String,
                      status: order['status']! as String,
                      date: order['date']! as String,
                      type: order['type']! as String,
                      price: order['price']! as String,
                      amount: order['amount']! as String,
                      filledAmount: order['filledAmount']! as String,
                      totalAmount: order['totalAmount']! as String,
                      isBuy: order['isBuy'] as bool,
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildExchangeItem(String name, Color color, bool isLinked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E6EA), width: 1),
      ),
      child: isLinked
          ?
            // 连携済み的情况 (保持原有代码)
            Column(
              children: [
                Row(
                  children: [
                    // 交易所图标
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 交易所名称和连携状态
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '総資産: ${cryptoAssets.where((asset) => asset['exchange'] == name.toLowerCase()).isNotEmpty ? AppUtils().formatMoney(cryptoAssets.where((asset) => asset['exchange'] == name.toLowerCase()).fold(0, (sum, asset) => sum + (asset['totalValue'] as double)), 'JPY') : '¥0'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '最終同期: ${DateFormat('yyyy/MM/dd HH:mm:ss').format(GlobalStore().cryptoLastSyncTime[name.toLowerCase()] ?? DateTime.now())}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 设置和解除按钮
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // 获取当前交易所的API信息
                          final CryptoInfoData? currentInfo = cryptoInfos
                              .firstWhereOrNull(
                                (info) =>
                                    info.cryptoExchange.toLowerCase() ==
                                    name.toLowerCase(),
                              );
                          if (currentInfo != null) {
                            _showApiDialog(
                              name,
                              color,
                              currentInfo: currentInfo,
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.settings, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              '設定',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _showApiClearDialog(name, color);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 0,
                        ),
                        child: const Text('解除', style: TextStyle(fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ],
            )
          :
            // 未连携的情况 - 显示连携按钮
            Row(
              children: [
                // 交易所图标
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 交易所名称和状态
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '未連携',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                // 连携按钮
                ElevatedButton(
                  onPressed: () {
                    _showApiDialog(name, color);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appUpGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.link, size: 16),
                      SizedBox(width: 4),
                      Text('連携', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _showApiClearDialog(String name, Color color) {
    final ValueNotifier<bool> isLoading = ValueNotifier(false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ValueListenableBuilder<bool>(
          valueListenable: isLoading,
          builder: (context, loading, child) {
            return AlertDialog(
              title: const Text('連携解除の確認'),
              content: loading
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('連携を解除しています...'),
                      ],
                    )
                  : Text('$name との連携を解除してもよろしいですか？'),
              actions: loading
                  ? []
                  : [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('キャンセル'),
                      ),
                      TextButton(
                        onPressed: () async {
                          isLoading.value = true;
                          try {
                            final bool deleted = await AppUtils()
                                .deleteCryptoInfo(
                                  userId: GlobalStore().userId!,
                                  cryptoData: {
                                    'account_id': GlobalStore().accountId!,
                                    'crypto_exchange': name.toLowerCase(),
                                  },
                                );
                            if (deleted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$name との連携を解除しました。')),
                              );
                              await (widget.db.delete(widget.db.cryptoInfo)
                                    ..where(
                                      (tbl) =>
                                          tbl.accountId.equals(
                                            GlobalStore().accountId!,
                                          ) &
                                          tbl.cryptoExchange.equals(
                                            name.toLowerCase(),
                                          ),
                                    ))
                                  .go();
                              // 重新获取数据
                              final dbCryptoInfos = await AppUtils()
                                  .getCryptoDataFromDB(widget.db);
                              // 检查 widget 是否仍然挂载
                              if (mounted) {
                                setState(() {
                                  cryptoInfos = dbCryptoInfos;
                                });
                              }
                              await syncCryptoDataFromServer();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$name との連携解除に失敗しました。')),
                              );
                            }
                          } finally {
                            isLoading.value = false;
                            if (mounted) {
                              Navigator.of(context).pop();
                            }
                          }
                        },
                        child: const Text('解除'),
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  // 合并后的API连接/更新对话框
  void _showApiDialog(
    String exchangeName,
    Color color, {
    CryptoInfoData? currentInfo,
  }) {
    final bool isUpdate = currentInfo != null;
    final ValueNotifier<bool> isLoading = ValueNotifier(false);
    final TextEditingController apiKeyController = TextEditingController(
      text: isUpdate ? currentInfo!.apiKey : '',
    );
    final TextEditingController apiSecretController = TextEditingController(
      text: isUpdate ? currentInfo!.apiSecret : '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题栏
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$exchangeName API${isUpdate ? '設定' : '連携'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '取引所のAPIキーとシークレットを${isUpdate ? '更新' : '入力'}してください',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  // API Key 输入框
                  const Text(
                    'APIキー',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: apiKeyController,
                    decoration: InputDecoration(
                      hintText: 'APIキーを入力',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E6EA)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E6EA)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: color),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // API Secret 输入框
                  const Text(
                    'APIシークレット',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: apiSecretController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'APIシークレットを入力',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E6EA)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E6EA)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: color),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // API获取方法说明
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'APIキーの取得方法',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '1. bitFlyerにログイン\n'
                          '2. API管理ページにアクセス\n'
                          '3. 読み取り専用のAPIキーを発行\n'
                          '4. APIキーとシークレットをコピー',
                          style: TextStyle(color: Colors.blue, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 按钮 - 添加loading状态
                  Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: isLoading,
                          builder: (context, loading, child) {
                            return OutlinedButton(
                              onPressed: loading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.grey),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'キャンセル',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: isLoading,
                          builder: (context, loading, child) {
                            return ElevatedButton(
                              onPressed: loading
                                  ? null
                                  : () async {
                                      isLoading.value = true;
                                      try {
                                        final bool success =
                                            await _handleApiAction(
                                              exchangeName.toLowerCase(),
                                              apiKeyController.text,
                                              apiSecretController.text,
                                              isUpdate: isUpdate,
                                              cryptoInfoId: isUpdate
                                                  ? currentInfo!.id
                                                  : null,
                                            );
                                        if (mounted && success) {
                                          Navigator.of(context).pop();
                                        }
                                      } finally {
                                        isLoading.value = false;
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: loading
                                    ? Colors.grey
                                    : AppColors.appUpGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                elevation: 0,
                              ),
                              child: loading
                                  ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          '処理中...',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      isUpdate ? '更新する' : '連携する',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 合并后的API处理方法
  Future<bool> _handleApiAction(
    String exchange,
    String apiKey,
    String apiSecret, {
    required bool isUpdate,
    int? cryptoInfoId,
  }) async {
    if (apiKey.isEmpty || apiSecret.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('APIキーとシークレットを入力してください')));
      }
      return false;
    }

    try {
      final String? userId = GlobalStore().userId;
      final int? accountId = GlobalStore().accountId;

      if (userId == null || accountId == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('ユーザー情報が見つかりません')));
        }
        return false;
      }

      // 验证API信息是否有效
      final BitflyerApi api = BitflyerApi(apiKey, apiSecret);
      final bool isValid = await api.checkApiKeyAndSecret();
      if (!isValid) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('無効なAPIキーまたはシークレットです')));
        }
        return false;
      }

      // 更新到SupabaseDB
      final bool success = await AppUtils().createOrUpdateCryptoInfo(
        userId: userId,
        cryptoData: {
          'account_id': accountId,
          'crypto_exchange': exchange,
          'api_key': apiKey,
          'api_secret': apiSecret,
          'status': 'active',
        },
      );

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${isUpdate ? 'API情報の更新' : '連携情報の保存'}に失敗しました'),
            ),
          );
        }
        return false;
      }

      // 更新/插入本地数据库
      if (isUpdate && cryptoInfoId != null) {
        // 更新模式
        final cryptoInfo = CryptoInfoCompanion(
          id: Value(cryptoInfoId),
          apiKey: Value(apiKey),
          apiSecret: Value(apiSecret),
          updatedAt: Value(DateTime.now()),
        );

        await (widget.db.update(
          widget.db.cryptoInfo,
        )..where((tbl) => tbl.id.equals(cryptoInfoId))).write(cryptoInfo);
      } else {
        // 连携模式
        final cryptoInfo = CryptoInfoCompanion(
          accountId: Value(accountId),
          cryptoExchange: Value(exchange),
          apiKey: Value(apiKey),
          apiSecret: Value(apiSecret),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        );

        await widget.db
            .into(widget.db.cryptoInfo)
            .insertOnConflictUpdate(cryptoInfo);
      }

      // 重新获取数据
      final dbCryptoInfos = await AppUtils().getCryptoDataFromDB(widget.db);
      // 检查 widget 是否仍然挂载
      if (mounted) {
        setState(() {
          cryptoInfos = dbCryptoInfos;
        });
      }
      await syncCryptoDataFromServer();

      if (mounted) {
        setState(() {
          cryptoInfos = dbCryptoInfos;
        });
        final String message = isUpdate
            ? '${exchange}のAPI情報を更新しました'
            : '${exchange}との連携が完了しました';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
      return true;
    } catch (e) {
      print('Error in _handleApiAction: $e');
      if (mounted) {
        final String message = isUpdate
            ? '更新に失敗しました。もう一度お試しください。'
            : '連携に失敗しました。もう一度お試しください。';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
      return false;
    }
  }
}

// 加密货币资产卡片
class _CryptoAssetCard extends StatelessWidget {
  final IconData iconData;
  final String name;
  final String symbol;
  final String amount;
  final String value;
  final String unitPrice;
  final Color backgroundColor;
  final Color iconColor;

  const _CryptoAssetCard({
    required this.iconData,
    required this.name,
    required this.symbol,
    required this.amount,
    required this.value,
    required this.unitPrice,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 跳转到具体加密货币详情页
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E6EA), width: 1),
        ),
        child: Row(
          children: [
            // 左侧图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            // 主要内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        symbol,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        value,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        amount,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        unitPrice,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 订单历史卡片
class _OrderHistoryCard extends StatelessWidget {
  final String pair;
  final String orderType;
  final String status;
  final String date;
  final String type;
  final String price;
  final String amount;
  final String filledAmount;
  final String totalAmount;
  final bool isBuy;

  const _OrderHistoryCard({
    required this.pair,
    required this.orderType,
    required this.status,
    required this.date,
    required this.type,
    required this.price,
    required this.amount,
    required this.filledAmount,
    required this.totalAmount,
    required this.isBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E6EA), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 交易对
              Text(
                pair,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              // 状态标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isBuy
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isBuy ? Colors.green : Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // 订单类型
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  orderType,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 日期
              Text(
                date,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 价格、数量、总金额
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '価格',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '数量',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '合計',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalAmount,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 成交量
          Row(
            children: [
              const Text(
                '約定数量:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(width: 4),
              Text(
                filledAmount,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 入出金历史卡片
class _DepositWithdrawCard extends StatelessWidget {
  final String type;
  final String status;
  final String amount;
  final String date;
  final String txId;
  final String currency;
  final String? fee;
  final bool isCompleted;

  const _DepositWithdrawCard({
    required this.type,
    required this.status,
    required this.amount,
    required this.date,
    required this.txId,
    required this.currency,
    this.fee,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E6EA), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 类型标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: type == 'deposit'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  type == 'deposit' ? '入金' : '出金',
                  style: TextStyle(
                    color: type == 'deposit' ? Colors.green : Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 状态标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isCompleted ? '完了' : '処理中',
                  style: TextStyle(
                    color: isCompleted ? Colors.blue : Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // 金额
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '金額',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              // 货币
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currency,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // 日期
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '日付',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              // 交易ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '取引ID',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      txId,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (fee != null) ...[
            const SizedBox(height: 8),
            // 手数料
            Row(
              children: [
                const Text(
                  '手数料',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(width: 4),
                Text(
                  fee!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
