import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_nest_app/components/card_section.dart';
import 'package:money_nest_app/components/quick_action_button.dart';
import 'package:money_nest_app/components/summary_row.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/presentation/resources/app_texts.dart';
import 'package:money_nest_app/util/provider/total_asset_provider.dart';
import 'package:provider/provider.dart';
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
  bool _assetVisible = true; // 资产是否可见

  Future<void> _onRefresh() async {
    await _refreshData();
    _refreshController.refreshCompleted();
  }

  Future<void> _refreshData() async {
    //await _fetchTotalAsset(widget.db, _selectedCurrency);
    // 在 PortfolioTab、HomeTab 等
    Provider.of<TotalAssetProvider>(
      context,
      listen: false,
    ).setTotalAsset(''); // 先清空或标记
    Provider.of<TotalAssetProvider>(
      context,
      listen: false,
    ).fetchTotalAsset(widget.db, _selectedCurrency);
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
    final totalAsset = context.watch<TotalAssetProvider>().totalAsset;

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
                      Color profitLightColor;
                      if (_assetVisible && profit > 0) {
                        profitColor = AppColors.appUpGreen;
                        profitLightColor = AppColors.appLightGreen;
                      } else if (_assetVisible && profit < 0) {
                        profitColor = AppColors.appDownRed;
                        profitLightColor = AppColors.appLightRed;
                      } else {
                        profitColor = AppColors.appDarkGrey;
                        profitLightColor = AppColors.appLightGrey;
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
                                  fontSize: AppTexts.fontSizeMedium,
                                  color: AppColors.appDarkGrey,
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
                          SizedBox(
                            height: 40, // 你可以根据实际字体高度微调
                            child: Center(
                              child: Text(
                                _assetVisible
                                    ? (totalAsset.isNotEmpty
                                          ? totalAsset
                                          : '*****')
                                    : '*****',
                                style: const TextStyle(
                                  fontSize: AppTexts.fontSizeHuge,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 24, // 固定高度，可根据实际内容微调
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: profitLightColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IntrinsicWidth(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
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
                                      textAlign: TextAlign.center,
                                      _assetVisible
                                          ? '${_formatProfit(profit, _selectedCurrency)} (${_formatProfitRate(profitRate)})'
                                          : '***',
                                      style: TextStyle(
                                        color: profitColor,
                                        fontSize: AppTexts.fontSizeSmall,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  );
                },
              ),
              // Portfolio Chart
              CardSection(
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
              CardSection(
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
                          QuickActionButton(
                            icon: Icons.add,
                            label: '取引追加',
                            onTap: () =>
                                setState(() => showAddTransaction = true),
                            iconColor: AppColors.appWhite,
                            bgColor: AppColors.appBlue,
                            fontColor: AppColors.appWhite,
                          ),
                          QuickActionButton(
                            icon: Icons.pie_chart_outline,
                            label: 'ポートフォリオ',
                            onTap: () => widget.onPortfolioTap?.call(),
                            iconColor: AppColors.appPurple,
                          ),
                          QuickActionButton(
                            icon: Icons.download,
                            label: 'レポート',
                            onTap: () {},
                            iconColor: AppColors.appGreen,
                          ),
                          QuickActionButton(
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
              CardSection(
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
