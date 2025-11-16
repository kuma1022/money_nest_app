import 'package:flutter/material.dart';
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
import 'package:money_nest_app/services/data_sync_service.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:money_nest_app/util/global_store.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:intl/intl.dart';

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
  bool _isInitializing = true; // 添加初始化状态
  bool _hasData = false; // 数据是否已加载
  List assetCategories = [];

  // 动画用 sections
  List<Map<String, dynamic>> _pieSections = [];

  // 资产tab的索引
  static const int assetTabIndex = 0;
  int _tabIndex = 0; // 当前tab索引（资产/负债）
  double totalAssets = 0;
  double totalCosts = 0;

  // 异步初始化数据的方法
  Future<void> _initializeData() async {
    if (!mounted) return;

    // 设置加载状态
    setState(() {
      _isInitializing = true;
    });

    final dataSync = Provider.of<DataSyncService>(context, listen: false);
    try {
      // 刷新总资产和总成本
      await AppUtils().refreshTotalAssetsAndCosts(dataSync);

      if (mounted) {
        setState(() {
          totalAssets = GlobalStore().totalAssetsAndCostsMap.keys.fold<double>(
            0,
            (prev, key) =>
                prev +
                ((GlobalStore().totalAssetsAndCostsMap[key]?['totalAssets'] ??
                        0)
                    .toDouble()),
          );
          totalCosts = GlobalStore().totalAssetsAndCostsMap.keys.fold<double>(
            0,
            (prev, key) =>
                prev +
                ((GlobalStore().totalAssetsAndCostsMap[key]?['totalCosts'] ?? 0)
                    .toDouble()),
          );

          // 取得各类资产的当前持仓List
          assetCategories = AppUtils().getAssetsHoldingList();
          print('计算得到总资产: $totalAssets, 总成本: $totalCosts');
        });
      }

      // 页面初次进入时，触发动画
      _animatePieChart();

      if (mounted) {
        setState(() {
          _hasData = true;
          _isInitializing = false;
        });
      }
    } catch (e) {
      print('Error in _initializeData: $e');
      if (mounted) {
        setState(() {
          _isInitializing = false;
          // 即使出错也要显示界面，使用默认值
          totalAssets = 0;
          totalCosts = 0;
        });
      }
    }
  }

  // 手动刷新数据
  Future<void> onRefresh() async {
    await _initializeData();
    _refreshController.refreshCompleted();
  }

  // 动画触发方法
  void _animatePieChart() {
    if (mounted) {
      setState(() {
        _pieSections = assetCategories
            .where(
              (cat) =>
                  cat['dotColor'] != null &&
                  cat['label'] != null &&
                  cat['rateLabel'] != null &&
                  (cat['value'] != null &&
                      AppUtils().parseMoneySimple(cat['value']) > 0),
            )
            .map((cat) {
              final color = cat['dotColor'] as Color;
              final label = cat['label'] as String;
              final rateLabel = cat['rateLabel'] as String;
              final rate = double.parse(rateLabel.replaceAll('%', ''));

              return {
                'color': color,
                'value': rate,
                'title': '$label $rateLabel',
              };
            })
            .toList();
      });
    }
  }

  void animatePieChartIfAssetTab() {
    if (_tabIndex == assetTabIndex) {
      _animatePieChart();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
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
              child: SmartRefresher(
                controller: _refreshController,
                onRefresh: onRefresh,
                header: const WaterDropHeader(),
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
                                      GlobalStore().selectedCurrencyCode,
                                    ),
                                    style: const TextStyle(
                                      fontSize: AppTexts.fontSizeHuge,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // 最近同步时间显示
                                  Text(
                                    GlobalStore().lastSyncTime != null
                                        ? '最終更新: ${DateFormat('yyyy-MM-dd HH:mm').format(GlobalStore().lastSyncTime!)}'
                                        : '最終更新: --',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  // 只在非加载状态下显示损益信息
                                  if (!_isInitializing)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          '${AppUtils().formatMoney((totalAssets - totalCosts).toDouble(), GlobalStore().selectedCurrencyCode ?? 'JPY')} (${AppUtils().formatNumberByTwoDigits(totalCosts == 0 ? 0 : ((totalAssets - totalCosts) / totalCosts * 100))}%)',
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
                                  // 如果初始化失败，显示重试按钮
                                  if (!_isInitializing && !_hasData)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: ElevatedButton(
                                        onPressed: _initializeData,
                                        child: const Text('データを再読み込み'),
                                      ),
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
                            subtitle: const Text(
                              '資産の推移や損益をグラフで分析',
                              style: TextStyle(fontSize: 13),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: Colors.black.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),
                      if (!_isInitializing && _pieSections.isNotEmpty ||
                          _tabIndex == 1)
                        GlassTab(
                          borderRadius: 24,
                          margin: const EdgeInsets.only(
                            left: 0,
                            right: 0,
                            bottom: 18,
                          ),
                          tabs: const ['資産', '負債'],
                          // 监听tab切换
                          onTabChanged: (index) {
                            _tabIndex = index;
                            if (index == assetTabIndex) {
                              _animatePieChart();
                            } else {
                              if (mounted) {
                                setState(() {
                                  _pieSections = [];
                                });
                              }
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
          ),

          // 全屏加载层
          if (_isInitializing)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.6),
                child: const Center(child: CircularProgressIndicator()),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: assetCategories.map((category) {
        return SummaryCategoryCard(
          label: category['label'],
          dotColor: category['dotColor'],
          rateLabel: category['rateLabel'],
          value: category['value'],
          profitText: category['profitText'],
          profitRateText: category['profitRateText'],
          profitColor: category['profitColor'],
          subCategories: (category['subCategories'] as List)
              .where(
                (e) =>
                    e['value'] != null &&
                    AppUtils().parseMoneySimple(e['value']) > 0,
              )
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
