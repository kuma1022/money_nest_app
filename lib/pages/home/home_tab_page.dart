import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:money_nest_app/components/total_asset_analysis_card.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:provider/provider.dart';
import 'package:money_nest_app/util/provider/total_asset_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeTabPage extends StatefulWidget {
  final AppDatabase db;
  final VoidCallback? onPortfolioTap;
  final VoidCallback? onAssetAnalysisTap;

  const HomeTabPage({
    super.key,
    required this.db,
    this.onPortfolioTap,
    this.onAssetAnalysisTap,
  });

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
  int _overviewTabIndex = 0; // 资产总览tab切换

  Future<void> _onRefresh() async {
    await _refreshData();
    _refreshController.refreshCompleted();
  }

  Future<void> _refreshData() async {
    Provider.of<TotalAssetProvider>(context, listen: false).setTotalAsset('');
    Provider.of<TotalAssetProvider>(
      context,
      listen: false,
    ).fetchTotalAsset(widget.db, _selectedCurrency);
  }

  // 获取总盈亏金额（请用实际业务逻辑替换）
  Future<double> _getTotalProfit() async {
    final records = await widget.db.getAllAvailableBuyRecords();
    final stocks = await widget.db.getAllStocks();
    final stockMap = {for (var stock in stocks) stock.code: stock};

    setState(
      () => _totalProfit = records.fold<double>(0, (sum, r) {
        final stock = stockMap[r.code];
        final currentPrice = stock?.currentPrice ?? r.price;
        final stockCurrency = stock?.currency ?? r.currencyUsed.code;

        double fxToMoneyUsed = 1.0;
        if (stockCurrency != r.currencyUsed.code) {
          final fxCode = stockCurrency != 'USD'
              ? '$stockCurrency${r.currencyUsed.code}'
              : r.currencyUsed.code;
          fxToMoneyUsed = stockMap[fxCode]?.currentPrice ?? 1.0;
        }
        final marketValueInMoneyUsed =
            r.quantity * currentPrice * fxToMoneyUsed;

        final profitInMoneyUsed = marketValueInMoneyUsed - r.moneyUsed;

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
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 总资产卡片
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E6EA), width: 1),
              ),
              child: Column(
                children: [
                  const Text(
                    '資産総額',
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¥1,600,000',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F9F0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.trending_up, color: Colors.green, size: 20),
                        SizedBox(width: 4),
                        Text(
                          '+¥250,000 (25%)',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 资产总览卡片
            TotalAssetAnalysisCard(
              onAssetAnalysisTap: widget.onAssetAnalysisTap,
            ),
            // 快捷操作
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E6EA), width: 1),
              ),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.6,
                children: [
                  _QuickActionButton(
                    icon: Icons.add,
                    label: '取引追加',
                    onTap: () => setState(() => showAddTransaction = true),
                    bgColor: const Color(0xFF1976D2),
                    fontColor: Colors.white,
                  ),
                  _QuickActionButton(
                    icon: Icons.pie_chart_outline,
                    label: 'ポートフォリオ',
                    onTap: () => widget.onPortfolioTap?.call(),
                  ),
                  _QuickActionButton(
                    icon: Icons.download,
                    label: 'レポート',
                    onTap: () {},
                  ),
                  _QuickActionButton(
                    icon: Icons.calculate,
                    label: '損益計算',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            // 今日のサマリー
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE5E6EA), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Padding(
                    padding: EdgeInsets.only(left: 8, bottom: 8),
                    child: Text(
                      '今日のサマリー',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  _SummaryRowStyled(
                    label: '日本株',
                    value: '+¥15,000 (+2.1%)',
                    valueColor: Color(0xFF388E3C),
                    bgColor: Color(0xFFE6F9F0),
                  ),
                  _SummaryRowStyled(
                    label: '米国株',
                    value: '¥8,500 (-1.2%)',
                    valueColor: Color(0xFFD32F2F),
                    bgColor: Color(0xFFFDEAEA),
                  ),
                  _SummaryRowStyled(
                    label: '現金',
                    value: '¥250,000',
                    valueColor: Color(0xFF757575),
                    bgColor: Color(0xFFF5F6FA),
                  ),
                  _SummaryRowStyled(
                    label: 'その他',
                    value: '+¥2,500 (+1.7%)',
                    valueColor: Color(0xFF388E3C),
                    bgColor: Color(0xFFE6F9F0),
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

// 图例每行两个
class _LegendRow extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _LegendRow({required this.left, required this.right});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        SizedBox(width: 16), // 中间空白
        Expanded(child: right),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final String percent;
  const _LegendDot({
    required this.color,
    required this.label,
    required this.percent,
    this.alignRight = false,
  });
  final bool alignRight; // 兼容旧参数，但不再使用
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8), // 左右增加空白
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          Text(
            percent,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

// 快捷按钮
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? bgColor;
  final Color? fontColor;
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.bgColor,
    this.fontColor,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: bgColor ?? Colors.white,
        foregroundColor: fontColor ?? Colors.black,
        side: BorderSide(color: bgColor ?? const Color(0xFFE5E6EA)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.zero,
      ),
      onPressed: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: fontColor ?? Colors.black),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: fontColor ?? Colors.black)),
        ],
      ),
    );
  }
}

// 今日のサマリー行
class _SummaryRowStyled extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final Color bgColor;
  const _SummaryRowStyled({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.bgColor,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
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
