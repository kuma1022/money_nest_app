import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_nest_app/components/animated_pie_chart.dart';
import 'package:money_nest_app/components/card_section.dart';
import 'package:money_nest_app/components/custom_pie_chart.dart';
import 'package:money_nest_app/components/glass_quick_bar.dart';
import 'package:money_nest_app/components/glass_quick_bar_item.dart';
import 'package:money_nest_app/components/glass_tab.dart';
import 'package:money_nest_app/components/summary_category_card.dart';
import 'package:money_nest_app/components/summary_sub_category_card.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/presentation/resources/app_texts.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:money_nest_app/util/global_store.dart';
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

  // 动画用 sections
  List<Map<String, dynamic>> _pieSections = [];

  // 资产tab的索引
  static const int assetTabIndex = 0;
  int _tabIndex = 0; // 当前tab索引（资产/负债）
  num totalAssets = 0;
  num totalCosts = 0;

  @override
  void initState() {
    super.initState();
    // 页面初次进入时，触发动画
    _animatePieChart();
    refreshTotalAssetsAndCosts();
  }

  // 刷新总资产和总成本
  void refreshTotalAssetsAndCosts() {
    final totalMap = AppUtils().getTotalAssetsAndCostsValue();
    setState(() {
      totalAssets = totalMap['totalAssets'];
      totalCosts = totalMap['totalCosts'];
    });
  }

  // 动画触发方法
  void _animatePieChart() async {
    setState(() {
      _pieSections = [
        {'color': AppColors.appChartGreen, 'value': 11.9, 'title': '株式 11.9%'},
        {'color': AppColors.appChartBlue, 'value': 0.7, 'title': 'FX（為替） 0.7%'},
        {'color': AppColors.appChartPurple, 'value': 1.1, 'title': '暗号資産 1.1%'},
        {'color': AppColors.appChartOrange, 'value': 0.7, 'title': '貴金属 0.7%'},
        {
          'color': AppColors.appChartLightBlue,
          'value': 85.6,
          'title': 'その他 85.6%',
        },
      ];
    });
  }

  void animatePieChartIfAssetTab() {
    if (_tabIndex == assetTabIndex) {
      _animatePieChart();
    }
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
                  colors: [AppColors.appBackground, AppColors.appBackground],
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
                  if (pixels < 0) pixels = 0;
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
                              children: [
                                const Text(
                                  '💰 総資産',
                                  style: TextStyle(
                                    fontSize: AppTexts.fontSizeLarge,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  AppUtils().formatMoney(
                                    totalAssets.toDouble(),
                                    GlobalStore().selectedCurrencyCode!,
                                  ),
                                  style: const TextStyle(
                                    fontSize: AppTexts.fontSizeHuge,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      totalAssets > totalCosts
                                          ? Icons.trending_up
                                          : totalAssets < totalCosts
                                          ? Icons.trending_down
                                          : Icons.trending_flat,
                                      color: totalAssets > totalCosts
                                          ? AppColors.appUpGreen
                                          : totalAssets < totalCosts
                                          ? AppColors.appDownRed
                                          : AppColors.appGrey,
                                      size: AppTexts.fontSizeMedium,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${AppUtils().formatMoney((totalAssets - totalCosts).toDouble(), GlobalStore().selectedCurrencyCode!)} (${AppUtils().formatNumberByTwoDigits(totalCosts == 0 ? 0 : ((totalAssets - totalCosts) / totalCosts * 100))}%)',
                                      style: TextStyle(
                                        color: totalAssets > totalCosts
                                            ? AppColors.appUpGreen
                                            : totalAssets < totalCosts
                                            ? AppColors.appDownRed
                                            : AppColors.appGrey,
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
                          onTap: () => widget.onAssetAnalysisTap?.call(),
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
                      child: _ClickableCardTile(
                        onTap: widget.onAssetAnalysisTap,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 0,
                          ),
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
                          subtitle: Text(
                            '資産の推移や損益をグラフで分析${GlobalStore().textForDebug}',
                            style: TextStyle(fontSize: 13),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Colors.black.withValues(alpha: 0.3),
                          ),
                        ),
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
                      // 监听tab切换
                      onTabChanged: (index) {
                        if (index == assetTabIndex) {
                          _animatePieChart();
                        } else {
                          setState(() {
                            _pieSections = [];
                          });
                        }
                      },
                      tabBarContentList: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            createPieChart(),
                            const SizedBox(height: 8),
                            createTabBarContentForAsset(),
                            const SizedBox(height: 8),
                          ],
                        ),
                        const SizedBox.shrink(),
                      ],
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

  Widget createPieChart() {
    return CustomPieChart(sections: _pieSections);
  }

  Widget createTabBarContentForAsset() {
    final List categories = [
      {
        'label': '株式',
        'dotColor': AppColors.appChartGreen,
        'rateLabel': '11.9%',
        'value': '¥1,350,000',
        'profitText': '¥125,000',
        'profitRateText': '(+10.2%)',
        'profitColor': AppColors.appUpGreen,
        'subCategories': [
          {
            'label': '国内株式（ETF含む）',
            'rateLabel': '48.1%',
            'value': '¥650,000',
            'profitText': '¥65,000',
            'profitRateText': '(+11.1%)',
            'profitColor': AppColors.appUpGreen,
          },
          {
            'label': '米国株式（ETF含む）',
            'rateLabel': '35.6%',
            'value': '¥480,000',
            'profitText': '¥48,000',
            'profitRateText': '(+11.1%)',
            'profitColor': AppColors.appUpGreen,
          },
          {
            'label': 'その他（海外株式など）',
            'rateLabel': '16.3%',
            'value': '¥220,000',
            'profitText': '¥12,000',
            'profitRateText': '(+5.8%)',
            'profitColor': AppColors.appUpGreen,
          },
        ],
      },
      {
        'label': 'FX（為替）',
        'dotColor': AppColors.appChartBlue,
        'rateLabel': '0.7%',
        'value': '¥85,000',
        'profitText': '¥5,000',
        'profitRateText': '(-5.6%)',
        'profitColor': AppColors.appDownRed,
        'subCategories': [
          {
            'label': 'USD/JPY',
            'rateLabel': '52.9%',
            'value': '¥45,000',
            'profitText': '¥2,000',
            'profitRateText': '(-4.3%)',
            'profitColor': AppColors.appDownRed,
          },
          {
            'label': 'EUR/JPY',
            'rateLabel': '29.4%',
            'value': '¥25,000',
            'profitText': '¥1,500',
            'profitRateText': '(-5.7%)',
            'profitColor': AppColors.appDownRed,
          },
          {
            'label': 'その他通貨ペア',
            'rateLabel': '17.6%',
            'value': '¥15,000',
            'profitText': '¥1,500',
            'profitRateText': '(-9.1%)',
            'profitColor': AppColors.appDownRed,
          },
        ],
      },
      {
        'label': '暗号資産',
        'dotColor': AppColors.appChartPurple,
        'rateLabel': '1.1%',
        'value': '¥120,000',
        'profitText': '¥15,000',
        'profitRateText': '(+14.3%)',
        'profitColor': AppColors.appUpGreen,
        'subCategories': [
          {
            'label': 'ビットコイン',
            'rateLabel': '62.5%',
            'value': '¥75,000',
            'profitText': '¥12,000',
            'profitRateText': '(+19%)',
            'profitColor': AppColors.appUpGreen,
          },
          {
            'label': 'イーサリアム',
            'rateLabel': '25%',
            'value': '¥30,000',
            'profitText': '¥2,000',
            'profitRateText': '(+7.1%)',
            'profitColor': AppColors.appUpGreen,
          },
          {
            'label': 'その他',
            'rateLabel': '12.5%',
            'value': '¥15,000',
            'profitText': '¥1,000',
            'profitRateText': '(+7.1%)',
            'profitColor': AppColors.appUpGreen,
          },
        ],
      },
      {
        'label': '貴金属',
        'dotColor': AppColors.appChartOrange,
        'rateLabel': '0.7%',
        'value': '¥150,000',
        'profitText': '¥10,000',
        'profitRateText': '(+7.1%)',
        'profitColor': AppColors.appUpGreen,
        'subCategories': [
          {
            'label': '金',
            'rateLabel': '70.6%',
            'value': '¥60,000',
            'profitText': '¥4,000',
            'profitRateText': '(+7.1%)',
            'profitColor': AppColors.appUpGreen,
          },
          {
            'label': '銀',
            'rateLabel': '17.6%',
            'value': '¥15,000',
            'profitText': '¥500',
            'profitRateText': '(+3.4%)',
            'profitColor': AppColors.appUpGreen,
          },
          {
            'label': 'プラチナ',
            'rateLabel': '11.8%',
            'value': '¥10,000',
            'profitText': '¥1,000',
            'profitRateText': '(+11.1%)',
            'profitColor': AppColors.appUpGreen,
          },
        ],
      },
      {
        'label': 'その他資産',
        'dotColor': AppColors.appChartLightBlue,
        'rateLabel': '85.6%',
        'value': '¥9,725,000',
        'profitText': '¥0',
        'profitRateText': '(+0%)',
        'profitColor': AppColors.appUpGreen,
        'subCategories': [
          {
            'label': '銀行預金',
            'rateLabel': '97.7%',
            'value': '¥9,500,000',
            'profitText': '¥0',
            'profitRateText': '(+0%)',
            'profitColor': AppColors.appUpGreen,
          },
          {
            'label': '現金',
            'rateLabel': '2.3%',
            'value': '¥225,000',
            'profitText': '¥0',
            'profitRateText': '(+0%)',
            'profitColor': AppColors.appUpGreen,
          },

          {
            'label': '不動産',
            'rateLabel': '0%',
            'value': '¥0',
            'profitText': '¥0',
            'profitRateText': '(+0%)',
            'profitColor': AppColors.appUpGreen,
          },

          {
            'label': '投資信託',
            'rateLabel': '0%',
            'value': '¥0',
            'profitText': '¥0',
            'profitRateText': '(+0%)',
            'profitColor': AppColors.appUpGreen,
          },

          {
            'label': '債券',
            'rateLabel': '0%',
            'value': '¥0',
            'profitText': '¥0',
            'profitRateText': '(+0%)',
            'profitColor': AppColors.appUpGreen,
          },

          {
            'label': 'その他',
            'rateLabel': '0%',
            'value': '¥0',
            'profitText': '¥0',
            'profitRateText': '(+0%)',
            'profitColor': AppColors.appUpGreen,
          },
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.map((category) {
        return SummaryCategoryCard(
          label: category['label'],
          dotColor: category['dotColor'],
          rateLabel: category['rateLabel'],
          value: category['value'],
          profitText: category['profitText'],
          profitRateText: category['profitRateText'],
          profitColor: category['profitColor'],
          subCategories: (category['subCategories'] as List)
              .map(
                (subCat) => SummarySubCategoryCard(
                  label: subCat['label'],
                  rateLabel: subCat['rateLabel'],
                  value: subCat['value'],
                  profitText: subCat['profitText'],
                  profitRateText: subCat['profitRateText'],
                  profitColor: subCat['profitColor'],
                ),
              )
              .toList(),
        );
      }).toList(),
    );
  }
}

class _ClickableCardTile extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _ClickableCardTile({required this.child, this.onTap, super.key});
  @override
  State<_ClickableCardTile> createState() => _ClickableCardTileState();
}

class _ClickableCardTileState extends State<_ClickableCardTile> {
  bool _pressed = false;
  bool _tapping = false;

  void _handleTapDown(TapDownDetails details) {
    if (_tapping) return;
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (_tapping) return;
    setState(() => _pressed = false);
    _tapping = true;
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted && widget.onTap != null) widget.onTap!();
      _tapping = false;
    });
  }

  void _handleTapCancel() {
    setState(() => _pressed = false);
    _tapping = false;
  }

  @override
  Widget build(BuildContext context) {
    final bool highlight = _pressed;
    const Color borderColor = Color(0xFF1976D2);
    final Color iconAndTextColor = _pressed ? borderColor : Colors.black87;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: highlight
                ? Colors.white.withOpacity(0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: //highlight
                  //? borderColor.withOpacity(0.22)
                  //:
                  Colors.transparent,
              width: 1.2,
            ),
          ),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              top: _pressed ? 6 : 0,
              bottom: _pressed ? 0 : 6,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                iconTheme: IconThemeData(color: iconAndTextColor),
                textTheme: Theme.of(context).textTheme.apply(
                  bodyColor: iconAndTextColor,
                  displayColor: iconAndTextColor,
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
