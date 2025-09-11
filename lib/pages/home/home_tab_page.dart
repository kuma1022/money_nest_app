import 'dart:ui';

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
  final ValueChanged<double>? onScroll;
  final ScrollController? scrollController;

  const HomeTabPage({
    super.key,
    required this.db,
    this.onPortfolioTap,
    this.onAssetAnalysisTap,
    this.scrollController,
    this.onScroll,
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
  bool _assetVisible = true;
  int _overviewTabIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE3E6F3),
                    Color(0xFFB8BFD8),
                    Color(0xFF9CA3BA),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 8, bottomPadding),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                double pixels = 0.0;
                if (notification is ScrollUpdateNotification ||
                    notification is OverscrollNotification) {
                  pixels = notification.metrics.pixels;
                  if (pixels < 0) pixels = 0; // 只允许正数（如需overscroll缩放可不处理）
                  widget.onScroll?.call(pixels);
                }
                return false;
              },
              child: SingleChildScrollView(
                controller: widget.scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _GlassPanel(
                      borderRadius: 32,
                      margin: const EdgeInsets.only(bottom: 18),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 18,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              color: Colors.black.withOpacity(0.7),
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    '資産総額',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    '¥1,600,000',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    '+¥250,000 (25%)',
                                    style: TextStyle(
                                      color: Color(0xFF43A047),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _GlassQuickBar(
                      items: [
                        _GlassQuickBarItem(
                          icon: Icons.add,
                          label: '取引追加',
                          selected: false,
                          onTap: () =>
                              setState(() => showAddTransaction = true),
                          iconColor: const Color(0xFF1976D2),
                        ),
                        _GlassQuickBarItem(
                          icon: Icons.pie_chart_outline,
                          label: '資産',
                          selected: false,
                          onTap: () => widget.onPortfolioTap?.call(),
                          iconColor: const Color(0xFF1976D2),
                        ),
                        _GlassQuickBarItem(
                          icon: Icons.download_outlined,
                          label: 'レポート',
                          selected: false,
                          onTap: () {},
                          iconColor: const Color(0xFF1976D2),
                        ),
                        _GlassQuickBarItem(
                          icon: Icons.calculate_outlined,
                          label: '損益計算',
                          selected: false,
                          onTap: () {},
                          iconColor: const Color(0xFF1976D2),
                        ),
                      ],
                    ),
                    _GlassPanel(
                      borderRadius: 24,
                      margin: const EdgeInsets.only(top: 18, bottom: 18),
                      child: ListTile(
                        leading: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.analytics_outlined,
                            color: Color(0xFF1976D2),
                            size: 28,
                          ),
                        ),
                        title: const Text(
                          '資産分析',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: const Text(
                          '資産の推移や損益をグラフで分析',
                          style: TextStyle(fontSize: 13),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.black.withOpacity(0.3),
                        ),
                        onTap: widget.onAssetAnalysisTap,
                      ),
                    ),
                    _GlassPanel(
                      borderRadius: 24,
                      margin: const EdgeInsets.only(bottom: 18),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '資産推移',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 140,
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(show: false),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            '¥${(value ~/ 10000)}万',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.black54,
                                            ),
                                          );
                                        },
                                        interval: 200000,
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final months = [
                                            '1月',
                                            '2月',
                                            '3月',
                                            '4月',
                                            '5月',
                                            '6月',
                                          ];
                                          if (value.toInt() >= 0 &&
                                              value.toInt() < months.length) {
                                            return Text(
                                              months[value.toInt()],
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.black54,
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  minX: 0,
                                  maxX: 5,
                                  minY: 900000,
                                  maxY: 1300000,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: [
                                        FlSpot(0, 1000000),
                                        FlSpot(1, 1050000),
                                        FlSpot(2, 980000),
                                        FlSpot(3, 1120000),
                                        FlSpot(4, 1180000),
                                        FlSpot(5, 1250000),
                                      ],
                                      isCurved: true,
                                      color: const Color(0xFF1976D2),
                                      barWidth: 3,
                                      dotData: FlDotData(show: true),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: const Color(
                                          0xFF1976D2,
                                        ).withOpacity(0.08),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _GlassPanel(
                      borderRadius: 24,
                      margin: const EdgeInsets.only(bottom: 18),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '今日のサマリー',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 10),
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
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _GlassCircleButton(
                        child: Icon(Icons.search, color: Colors.black87),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 毛玻璃面板
class _GlassPanel extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  const _GlassPanel({
    required this.child,
    this.borderRadius = 24,
    this.margin,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // 局部背景虚化
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(color: Colors.transparent),
            ),
            // 更通透的毛玻璃面板
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.13), // 更透明
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.white.withOpacity(0.16), // 更透明
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.08),
                    blurRadius: 0,
                    spreadRadius: 2,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

// 毛玻璃快捷操作栏
class _GlassQuickBar extends StatelessWidget {
  final List<_GlassQuickBarItem> items;
  const _GlassQuickBar({required this.items, super.key});
  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      borderRadius: 32,
      margin: const EdgeInsets.only(bottom: 18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: items
              .map(
                (item) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: item,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _GlassQuickBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? iconColor;
  const _GlassQuickBarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.iconColor,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        splashColor: Colors.white.withOpacity(0.12),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: selected
                ? Colors.white.withOpacity(0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? (iconColor ?? const Color(0xFF1976D2)).withOpacity(0.12)
                  : Colors.transparent,
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 26, color: iconColor ?? Colors.black87),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: iconColor ?? Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 毛玻璃水滴按钮
class _GlassCircleButton extends StatelessWidget {
  final Widget child;
  final double size;
  final VoidCallback? onTap;

  const _GlassCircleButton({
    required this.child,
    this.size = 56,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(color: Colors.white.withOpacity(0.13)),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.16),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(child: child),
                ),
              ],
            ),
          ),
        ),
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
