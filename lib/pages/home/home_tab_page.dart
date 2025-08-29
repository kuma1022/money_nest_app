import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/presentation/resources/app_texts.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeTabPage extends StatefulWidget {
  final AppDatabase db;
  final VoidCallback? onPortfolioTap;

  const HomeTabPage({super.key, required this.db, this.onPortfolioTap});

  @override
  State<HomeTabPage> createState() => HomeTabPageState();
}

class HomeTabPageState extends State<HomeTabPage> {
  final RefreshController _refreshController = RefreshController();
  RefreshController get refreshController => _refreshController;
  bool showAddTransaction = false;

  final List<Map<String, dynamic>> portfolioData = [
    {'date': '1月', 'value': 1000000},
    {'date': '2月', 'value': 1050000},
    {'date': '3月', 'value': 980000},
    {'date': '4月', 'value': 1120000},
    {'date': '5月', 'value': 1180000},
    {'date': '6月', 'value': 1250000},
  ];

  final int totalAssets = 1250000;
  final int totalGain = 250000;
  final double gainPercentage = 25.0;

  Currency _selectedCurrency = Currency.values.first;
  double _totalProfit = 0;
  double _totalCost = 0;
  String _lastAsset = '';
  String _totalAsset = '';
  DateTime _assetFetchedTime = DateTime.now();
  bool _assetVisible = true; // 资产是否可见

  Future<void> _onRefresh() async {
    await _refreshData();
    _refreshController.refreshCompleted();
  }

  Future<void> _refreshData() async {
    await _fetchTotalAsset(widget.db, _selectedCurrency);
  }

  // 获取总资产和时间
  Future<void> _fetchTotalAsset(AppDatabase db, Currency currency) async {
    // 实际股票资产计算逻辑
    double total = await _calculateAllStockValue(db, currency.code);
    setState(() {
      _totalAsset = NumberFormat.currency(
        locale: currency.locale,
        symbol: currency.symbol,
      ).format(total);
      _lastAsset = _totalAsset;
    });
  }

  // 这里模拟股票总价值计算，实际应从你的数据源获取
  Future<double> _calculateAllStockValue(
    AppDatabase db,
    String currencyCode,
  ) async {
    // 获取持仓股票的数据
    final stockDataList = await db.getAllStocksRecords();

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
      await db.updateStockPrices(newStockDataList);
    }

    Map<String, double> priceMap = {
      for (var stock in newStockDataList)
        if (stock.currentPrice != null) stock.code: stock.currentPrice!,
    };

    // 更新资产获取时间
    setState(
      () => _assetFetchedTime = stockDataList.isNotEmpty
          ? stockDataList.first.priceUpdatedAt ?? DateTime.now()
          : DateTime.now(),
    );

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

  // 获取总盈亏金额（请用实际业务逻辑替换）
  Future<double> _getTotalProfit() async {
    // 取得所有持仓记录
    final records = await widget.db.getAllAvailableBuyRecords();
    final stocks = await widget.db.getAllStocks();
    final stockMap = {for (var stock in stocks) stock.code: stock};

    setState(
      () => _totalProfit = records.fold<double>(0, (sum, r) {
        final stock = stockMap[r.code];
        final currentPrice = stock?.currentPrice ?? r.price;
        final stockCurrency = stock?.currency ?? r.currencyUsed.code;

        // 1. 当前市值换算成 moneyUsed 币种
        double fxToMoneyUsed = 1.0;
        if (stockCurrency != r.currencyUsed.code) {
          final fxCode = stockCurrency != 'USD'
              ? '$stockCurrency${r.currencyUsed.code}'
              : r.currencyUsed.code;
          fxToMoneyUsed = stockMap[fxCode]?.currentPrice ?? 1.0;
        }
        final marketValueInMoneyUsed =
            r.quantity * currentPrice * fxToMoneyUsed;

        // 2. 盈亏（moneyUsed币种）
        final profitInMoneyUsed = marketValueInMoneyUsed - r.moneyUsed;

        // 3. 盈亏换算成当前选中币种
        double fxToSelected = 1.0;
        if (r.currencyUsed.code != _selectedCurrency.code) {
          final fxCode = r.currencyUsed.code != 'USD'
              ? '${r.currencyUsed.code}${_selectedCurrency.code}'
              : _selectedCurrency.code;
          fxToSelected = stockMap[fxCode]?.currentPrice ?? 1.0;
        }
        final profitInSelected = profitInMoneyUsed * fxToSelected;

        return sum + profitInSelected;
      }),
    );

    // 计算总盈亏
    return _totalProfit;
  }

  // 获取总盈亏率（请用实际业务逻辑替换）
  Future<double> _getTotalProfitRate() async {
    // 取得所有持仓记录
    final records = await widget.db.getAllAvailableBuyRecords();
    final stocks = await widget.db.getAllStocks();
    final stockMap = {for (var stock in stocks) stock.code: stock};

    setState(
      () => _totalCost = records.fold<double>(
        0,
        (sum, r) =>
            sum +
            r.moneyUsed *
                (r.currencyUsed.code != 'USD'
                    ? (stockMap['${r.currencyUsed.code}${_selectedCurrency.code}']
                              ?.currentPrice ??
                          1)
                    : (stockMap[_selectedCurrency.code]?.currentPrice ?? 1)),
      ),
    );

    return _totalCost > 0 ? _totalProfit / _totalCost : 0;
  }

  String _formatProfit(double profit, Currency currency) {
    final symbol = profit > 0 ? '+' : (profit < 0 ? '-' : '');
    return '$symbol${NumberFormat.currency(locale: currency.locale, symbol: currency.symbol).format(profit.abs())}';
  }

  String _formatProfitRate(double rate) {
    final symbol = rate > 0 ? '+' : (rate < 0 ? '-' : '');
    return '$symbol${(rate.abs() * 100).toStringAsFixed(2)}%';
  }

  @override
  Widget build(BuildContext context) {
    if (showAddTransaction) {
      // TODO: AddTransactionForm 替换为实际表单
      return Scaffold(
        appBar: AppBar(title: const Text('取引追加')),
        body: const Center(child: Text('AddTransactionForm Placeholder')),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.pageBackground,

      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        header: CustomHeader(
          builder: (context, mode) {
            String text;
            if (mode == RefreshStatus.idle) {
              text = AppLocalizations.of(
                context,
              )!.accountTabPageRefreshStatusIdleLabel;
            } else if (mode == RefreshStatus.canRefresh) {
              text = AppLocalizations.of(
                context,
              )!.accountTabPageRefreshStatusCanRefreshLabel;
            } else if (mode == RefreshStatus.refreshing) {
              text = AppLocalizations.of(
                context,
              )!.accountTabPageRefreshStatusRefreshingLabel;
            } else if (mode == RefreshStatus.completed) {
              text = AppLocalizations.of(
                context,
              )!.accountTabPageRefreshStatusCompletedLabel;
            } else {
              text = '';
            }
            return Container(
              height: 60,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sync, color: AppColors.appGreen),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: AppTexts.fontSizeSmall,
                      color: AppColors.appGreen,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              FutureBuilder<double>(
                future: _getTotalProfit(),
                builder: (context, profitSnapshot) {
                  return FutureBuilder<double>(
                    future: _getTotalProfitRate(),
                    builder: (context, profitRateSnapshot) {
                      double profit = profitSnapshot.data ?? 0.0;
                      double profitRate = profitRateSnapshot.data ?? 0.0;
                      Color profitColor;
                      if (_assetVisible && profit > 0) {
                        profitColor = AppColors.appUpGreen;
                      } else if (_assetVisible && profit < 0) {
                        profitColor = AppColors.appDownRed;
                      } else {
                        profitColor = Colors.black;
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.homeTabPageTotalAssetLabel,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              // 资产显示与否icon
                              IconButton(
                                icon: Icon(
                                  _assetVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColors.appGrey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _assetVisible = !_assetVisible;
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                          Text(
                            _assetVisible
                                ? (_totalAsset.isNotEmpty
                                      ? _totalAsset
                                      : '*****')
                                : '*****',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_assetVisible && profit != 0) ...[
                                Icon(
                                  profit > 0
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  color: profitColor,
                                  size: AppTexts.fontSizeExtraLarge,
                                ),
                              ],
                              const SizedBox(width: 4),
                              Text(
                                _assetVisible
                                    ? '${_formatProfit(profit, _selectedCurrency)} (${_formatProfitRate(profitRate)})'
                                    : '***',
                                style: TextStyle(
                                  color: profitColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  );
                },
              ),
              // Portfolio Chart
              _CardSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 16, bottom: 0),
                      child: Text(
                        '資産推移',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 160,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: portfolioData.map((data) {
                          final double height =
                              ((data['value'] - 900000) / 400000) * 100;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 24,
                                height: 20 + (height > 0 ? height : 0),
                                decoration: BoxDecoration(
                                  color: AppColors.appBlue,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['date'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            '¥0.9M',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          Text(
                            '¥1.3M',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Quick Actions
              _CardSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 16, bottom: 0),
                      child: Text(
                        'クイックアクション',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.8,
                        children: [
                          _QuickActionButton(
                            icon: Icons.add,
                            label: '取引追加',
                            onTap: () =>
                                setState(() => showAddTransaction = true),
                            iconColor: AppColors.appGreen,
                          ),
                          _QuickActionButton(
                            icon: Icons.pie_chart_outline,
                            label: 'ポートフォリオ',
                            onTap: () => widget.onPortfolioTap?.call(),
                            iconColor: AppColors.appPurple,
                          ),
                          _QuickActionButton(
                            icon: Icons.download,
                            label: 'レポート',
                            onTap: () {},
                            iconColor: AppColors.appBlue,
                          ),
                          _QuickActionButton(
                            icon: Icons.calculate,
                            label: '損益計算',
                            onTap: () {},
                            iconColor: AppColors.appOrange,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              // 今日のサマリー
              _CardSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 16, bottom: 0),
                      child: Text(
                        '今日のサマリー',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: const [
                          SummaryRow(
                            label: '日本株',
                            value: '+¥15,000 (+2.1%)',
                            valueColor: Colors.green,
                          ),
                          SummaryRow(
                            label: '米国株',
                            value: '-¥8,500 (-1.2%)',
                            valueColor: Colors.red,
                          ),
                          SummaryRow(
                            label: '現金',
                            value: '¥250,000',
                            valueColor: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  final Widget child;
  const _CardSection({required this.child, super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E6EA), width: 1),
      ),
      child: child,
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = Colors.black,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        side: const BorderSide(color: Color(0xFFE5E6EA)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.zero,
      ),
      onPressed: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const SummaryRow({
    required this.label,
    required this.value,
    required this.valueColor,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
