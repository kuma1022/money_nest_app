import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:money_nest_app/components/card_section.dart';
import 'package:money_nest_app/components/custom_tab.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:intl/intl.dart';
import 'package:money_nest_app/util/bitflyer_api.dart';
import 'package:money_nest_app/util/global_store.dart';

class CryptoDetailPage extends StatefulWidget {
  final ScrollController? scrollController;

  const CryptoDetailPage({super.key, this.scrollController});

  @override
  State<CryptoDetailPage> createState() => _CryptoDetailPageState();
}

class _CryptoDetailPageState extends State<CryptoDetailPage> {
  String _selectedCurrency = 'JPY'; // 添加货币筛选状态
  List<dynamic> bitFlyerBalances = [];
  List<dynamic> bitFlyerBalanceHistory = [];
  List<String> availableCurrencies = [];

  @override
  void initState() {
    super.initState();
    syncBitflyerData();
  }

  Future<void> syncBitflyerData() async {
    // 调用 Bitflyer API
    try {
      final api = BitflyerApi();
      final List<dynamic> balances = await api.getBalances(false);
      final String firstCurrency = 'JPY';
      print('Bitflyer Balances Success: $balances');
      // 取各个货币的当前价格
      for (var balance in balances) {
        if (balance['amount'] as double == 0.0 ||
            balance['currency_code'] == 'JPY') {
          balance['current_price'] = 1.0;
          continue;
        }
        final String symbol = balance['currency_code'] + '_JPY';
        try {
          final Map<String, dynamic> tickerData = await api.getTicker(
            true,
            symbol,
          );
          final double currentPrice = tickerData['ltp'] as double;
          balance['current_price'] = currentPrice;
        } catch (e) {
          balance['current_price'] = 0.0;
        }
      }
      final List<dynamic> balanceHistory = await api.getBalanceHistory(
        true,
        currencyCode: firstCurrency,
        count: 100,
      );
      print(
        'Bitflyer Balance History Success. Length: ${balanceHistory.length}',
      );
      // 检查 widget 是否仍然挂载
      if (mounted) {
        setState(() {
          _selectedCurrency = firstCurrency;
          bitFlyerBalances = balances;
          bitFlyerBalanceHistory = balanceHistory;
          // 获取所有可用的货币代码
          availableCurrencies = bitFlyerBalances.isNotEmpty
              ? bitFlyerBalances
                    .map((balance) => balance['currency_code']?.toString())
                    .where((currency) => currency != null)
                    .cast<String>()
                    .toSet()
                    .toList()
              : [];
        });
      }
    } catch (e) {
      // 提示用户待会儿再试
      // 检查 widget 是否仍然挂载
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
      final api = BitflyerApi();
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
      body: Padding(
        padding: EdgeInsets.fromLTRB(8, 0, 8, bottomPadding),
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
    );
  }

  // 概要タブ
  Widget _buildOverviewTab() {
    // 过滤出所有可用的货币资产
    List<Map<String, dynamic>> cryptoAssets = bitFlyerBalances.isNotEmpty
        ? bitFlyerBalances
              .where((balance) {
                return (balance['currency_code'] != 'JPY' &&
                    balance['amount'] != 0);
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
                final String value = AppUtils().formatMoney(totalValue, 'JPY');

                return {
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
                    '最終更新: ${DateFormat('yyyy/MM/dd HH:mm:ss').format(GlobalStore().bitflyerLastSyncTime ?? DateTime.now())}',
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
