import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:money_nest_app/components/card_section.dart';
import 'package:money_nest_app/components/glass_circle_button.dart';
import 'package:money_nest_app/components/glass_panel.dart';
import 'package:money_nest_app/components/glass_quick_bar.dart';
import 'package:money_nest_app/components/glass_quick_bar_item.dart';
import 'package:money_nest_app/components/glass_tab.dart';
import 'package:money_nest_app/components/summary_row_styled.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/presentation/resources/app_texts.dart';
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
                  colors: [Color(0xFFF5F6FA), Color(0xFFF5F6FA)],
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
                    const SizedBox(height: 16),
                    CardSection(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                Text(
                                  '💰 総資産',
                                  style: TextStyle(
                                    fontSize: AppTexts.fontSizeLarge,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  '¥1,600,000',
                                  style: TextStyle(
                                    fontSize: AppTexts.fontSizeHuge,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.trending_up,
                                      color: Color(0xFF43A047),
                                      size: AppTexts.fontSizeMedium,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '¥250,000 (+25%)',
                                      style: TextStyle(
                                        color: Color(0xFF43A047),
                                        fontSize: AppTexts.fontSizeMedium,
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
                    GlassQuickBar(
                      items: [
                        GlassQuickBarItem(
                          icon: Icons.add,
                          label: '取引追加',
                          selected: false,
                          onTap: () {},
                          iconColor: const Color(0xFF1976D2),
                        ),
                        GlassQuickBarItem(
                          icon: Icons.pie_chart_outline,
                          label: '資産一覧',
                          selected: false,
                          onTap: () => widget.onPortfolioTap?.call(),
                          iconColor: const Color(0xFF1976D2),
                        ),
                        GlassQuickBarItem(
                          icon: Icons.download_outlined,
                          label: '資産分析',
                          selected: false,
                          onTap: () {},
                          iconColor: const Color(0xFF1976D2),
                        ),
                        GlassQuickBarItem(
                          icon: Icons.calculate_outlined,
                          label: '損益計算',
                          selected: false,
                          onTap: () {},
                          iconColor: const Color(0xFF1976D2),
                        ),
                      ],
                    ),
                    CardSection(
                      child: ListTile(
                        leading: Container(
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF1976D2,
                            ).withValues(alpha: 0.12),
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
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                        onTap: widget.onAssetAnalysisTap,
                      ),
                    ),
                    GlassTab(
                      borderRadius: 24,
                      margin: const EdgeInsets.only(
                        left: 0,
                        right: 0,
                        bottom: 18,
                      ),
                      tabs: ['資産', '負債'],
                      tabBarContentList: const [
                        SizedBox.shrink(),
                        SizedBox.shrink(),
                      ],
                    ),
                    CardSection(
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
                          SummaryRowStyled(
                            label: '日本株',
                            value: '+¥15,000 (+2.1%)',
                            valueColor: Color(0xFF388E3C),
                            bgColor: Color(0xFFE6F9F0),
                          ),
                          SummaryRowStyled(
                            label: '米国株',
                            value: '¥8,500 (-1.2%)',
                            valueColor: Color(0xFFD32F2F),
                            bgColor: Color(0xFFFDEAEA),
                          ),
                          SummaryRowStyled(
                            label: '現金',
                            value: '¥250,000',
                            valueColor: Color(0xFF757575),
                            bgColor: Color(0xFFF5F6FA),
                          ),
                          SummaryRowStyled(
                            label: 'その他',
                            value: '+¥2,500 (+1.7%)',
                            valueColor: Color(0xFF388E3C),
                            bgColor: Color(0xFFE6F9F0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
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
