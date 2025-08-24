import 'dart:convert';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/presentation/resources/app_resources.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/util/app_utils.dart';

class AccountTabPage extends StatefulWidget {
  final AppDatabase db;

  const AccountTabPage({super.key, required this.db});

  @override
  State<AccountTabPage> createState() => AccountTabPageState();
}

class AccountTabPageState extends State<AccountTabPage> {
  // 获取总盈亏金额（请用实际业务逻辑替换）
  double _getTotalProfit() {
    return 12345.67; // 示例
  }

  // 获取总盈亏率（请用实际业务逻辑替换）
  double _getTotalProfitRate() {
    // TODO: 替换为实际盈亏率计算
    return 0.0345; // 示例，3.45%
  }

  String _formatProfit(double profit) {
    final symbol = profit > 0 ? '+' : (profit < 0 ? '-' : '');
    return '$symbol${profit.abs().toStringAsFixed(2)}';
  }

  String _formatProfitRate(double rate) {
    final symbol = rate > 0 ? '+' : (rate < 0 ? '-' : '');
    return '$symbol${(rate.abs() * 100).toStringAsFixed(2)}%';
  }

  Currency _selectedCurrency = Currency.jpy;
  DateTime _assetFetchedTime = DateTime.now();
  String _lastAsset = '';
  String _buyAsset = '';

  // 模拟异步获取总资产和时间
  Future<String> _fetchTotalAsset(AppDatabase db, Currency currency) async {
    // 实际股票资产计算逻辑
    double total = await _calculateAllStockValue(db, currency.code);
    _assetFetchedTime = DateTime.now();
    _lastAsset = NumberFormat.currency(
      locale: currency.locale,
      symbol: currency.symbol,
    ).format(total);
    return _lastAsset;
  }

  // 这里模拟股票总价值计算，实际应从你的数据源获取
  Future<double> _calculateAllStockValue(
    AppDatabase db,
    String currencyCode,
  ) async {
    // 获取持仓股票的数据
    final stockDataList = await db.getAllStocksRecords();

    for (var stock in stockDataList) {
      print(
        'Stock: ${stock.code}, Price: ${stock.currentPrice}, UpdatedAt: ${stock.priceUpdatedAt}',
      );
    }

    List<Stock> newStockDataList = List.from(stockDataList);
    // 如果除了FX之外没有数据
    if (stockDataList.isEmpty ||
        newStockDataList.every((stock) => stock.marketCode == 'FOREX')) {
      return 0;
    }
    final marketDataList = await db.getAllMarketDataRecords();
    // 如果所有 priceUpdatedAt 都在周六或周日，则不更新
    bool allWeekend =
        stockDataList.isNotEmpty &&
        stockDataList.every((stock) {
          final dt = stock.priceUpdatedAt;
          if (dt == null) return false;
          return dt.weekday == DateTime.saturday ||
              dt.weekday == DateTime.sunday;
        });
    if (!allWeekend &&
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
      await db.updateStockPrices(newStockDataList);
    }

    Map<String, double> priceMap = {
      for (var stock in newStockDataList)
        if (stock.currentPrice != null) stock.code: stock.currentPrice!,
    };

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
  }

  String _formatTime(DateTime time) {
    // 格式化为 HH:mm:ss 或 yyyy-MM-dd HH:mm
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // 总资产卡片
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.accountTabPageTotalMoneyTitle,
                        style: TextStyle(
                          fontSize: AppTexts.fontSizeLarge,
                          color: AppColors.appDarkGrey,
                        ),
                      ),
                      DropdownMenu<Currency>(
                        initialSelection: _selectedCurrency,
                        onSelected: (v) {
                          if (v != null) setState(() => _selectedCurrency = v);
                        },
                        dropdownMenuEntries: Currency.values
                            .map(
                              (c) => DropdownMenuEntry<Currency>(
                                value: c,
                                label: c.displayName(context),
                              ),
                            )
                            .toList(),
                        width: 90,
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(
                          fontSize: AppTexts.fontSizeSmall,
                          color: AppColors.appDarkGrey,
                        ),
                        inputDecorationTheme: const InputDecorationTheme(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        menuStyle: MenuStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.white),
                          shadowColor: WidgetStatePropertyAll(
                            Colors.transparent,
                          ),
                          surfaceTintColor: WidgetStatePropertyAll(
                            Colors.transparent,
                          ),
                          elevation: WidgetStatePropertyAll(0),
                          padding: WidgetStatePropertyAll(EdgeInsets.zero),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          side: WidgetStatePropertyAll(
                            BorderSide(color: Colors.transparent),
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.analytics, size: 18),
                        label: Text(
                          AppLocalizations.of(
                            context,
                          )!.accountTabPageAccountAnalyseLabel,
                          style: TextStyle(fontSize: AppTexts.fontSizeSmall),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.appGreen,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<String>(
                    future: _fetchTotalAsset(widget.db, _selectedCurrency),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        if (_lastAsset.isNotEmpty) {
                          return buildTotalAssetDisplay(_lastAsset);
                        }
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('资产获取失败: ${snapshot.error}');
                      }
                      final totalAsset = snapshot.data ?? '0';
                      return buildTotalAssetDisplay(totalAsset);
                    },
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      if (_assetFetchedTime != null)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '获取时间',
                              style: const TextStyle(
                                fontSize: AppTexts.fontSizeMini,
                                color: AppColors.appGrey,
                              ),
                            ),
                            Text(
                              _formatTime(_assetFetchedTime!),
                              style: const TextStyle(
                                fontSize: AppTexts.fontSizeMini,
                                color: AppColors.appGrey,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 全部账户
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Text(
                        '全部账户(3)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Icon(Icons.expand_more),
                    ],
                  ),
                  const Divider(height: 20),
                  // 账户1
                  _AccountItem(
                    name: '现金及股票账户(1571)',
                    total: '2,441,286.57',
                    profit: '-18,439.71',
                    profitRate: '-0.75%',
                    currency: 'JPY',
                    subAccounts: [
                      _SubAccountItem(name: '日股', value: '1,323,778.00 JPY'),
                      _SubAccountItem(name: '美股', value: '7,520.27 USD'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 账户2
                  _AccountItem(
                    name: '期权交易账户(6857)',
                    total: '0.00',
                    profit: '+0.00',
                    profitRate: '',
                    currency: 'USD',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTotalAssetDisplay(String totalAsset) {
    final profit = _getTotalProfit(); // double
    final profitRate = _getTotalProfitRate(); // double，百分比
    Color profitColor;
    if (profit > 0) {
      profitColor = Colors.green;
    } else if (profit < 0) {
      profitColor = Colors.red;
    } else {
      profitColor = Colors.black;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          totalAsset,
          style: const TextStyle(
            fontSize: AppTexts.fontSizeHuge,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatProfit(profit),
              style: TextStyle(
                fontSize: AppTexts.fontSizeSmall,
                color: profitColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _formatProfitRate(profitRate),
              style: TextStyle(
                fontSize: AppTexts.fontSizeSmall,
                color: profitColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Move these widget classes outside of _AccountTabPageState

class _AccountItem extends StatelessWidget {
  final String name;
  final String total;
  final String profit;
  final String profitRate;
  final String currency;
  final List<_SubAccountItem>? subAccounts;

  const _AccountItem({
    required this.name,
    required this.total,
    required this.profit,
    required this.profitRate,
    required this.currency,
    this.subAccounts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.account_balance_wallet, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '总资产 · $currency',
                  style: const TextStyle(
                    fontSize: AppTexts.fontSizeSmall,
                    color: AppColors.appGrey,
                  ),
                ),
                Text(
                  total,
                  style: const TextStyle(
                    fontSize: AppTexts.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      profit,
                      style: TextStyle(
                        color: profit.startsWith('-')
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                    if (profitRate.isNotEmpty)
                      Text(
                        '  $profitRate',
                        style: TextStyle(
                          color: profit.startsWith('-')
                              ? Colors.red
                              : Colors.green,
                          fontSize: AppTexts.fontSizeSmall,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
        if (subAccounts != null) ...[
          const SizedBox(height: 12),
          ...subAccounts!,
        ],
      ],
    );
  }
}

class _SubAccountItem extends StatelessWidget {
  final String name;
  final String value;
  const _SubAccountItem({required this.name, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: AppTexts.fontSizeSmall,
              color: AppColors.appGrey,
            ),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: AppTexts.fontSizeSmall)),
        ],
      ),
    );
  }
}
