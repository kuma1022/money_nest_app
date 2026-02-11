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

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
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
                  header: const WaterDropHeader(
                    waterDropColor: Colors.grey,
                  ),
                  child: SingleChildScrollView(
                    controller: widget.scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 60),
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.menu, color: Colors.white),
                              onPressed: () {},
                            ),
                            const Text(
                              'Home',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.notifications_none,
                                      color: Colors.white),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Total Assets
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '総資産',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppUtils().formatMoney(
                                totalAssets.toDouble(),
                                GlobalStore().selectedCurrencyCode,
                              ),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (!_isInitializing)
                              Row(
                                children: [
                                  Text(
                                    '${totalAssets >= totalCosts ? '+' : ''}${AppUtils().formatMoney((totalAssets - totalCosts).toDouble(), GlobalStore().selectedCurrencyCode ?? 'JPY')}',
                                    style: TextStyle(
                                      color: totalAssets >= totalCosts
                                          ? AppColors.appUpGreen
                                          : AppColors.appDownRed,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (totalAssets >= totalCosts
                                              ? AppColors.appUpGreen
                                              : AppColors.appDownRed)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${totalAssets >= totalCosts ? '+' : ''}${AppUtils().formatNumberByTwoDigits(totalCosts == 0 ? 0 : ((totalAssets - totalCosts) / totalCosts * 100))}%',
                                      style: TextStyle(
                                        color: totalAssets >= totalCosts
                                            ? AppColors.appUpGreen
                                            : AppColors.appDownRed,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        // Quick Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildQuickActionButton(
                              icon: Icons.add,
                              label: 'Add',
                              onTap: () {},
                            ),
                            _buildQuickActionButton(
                              icon: Icons.send,
                              label: 'Send',
                              onTap: () {},
                            ),
                            _buildQuickActionButton(
                              icon: Icons.call_received,
                              label: 'Receive',
                              onTap: () {},
                            ),
                            _buildQuickActionButton(
                              icon: Icons.more_horiz,
                              label: 'More',
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Pie Chart
                        if (_pieSections.isNotEmpty)
                          SizedBox(
                            height: 220,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPieChart(sections: _pieSections),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Portfolio',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_pieSections.length} Assets',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 30),
                        const Text(
                          'Your Assets',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        createTabBarContentForAsset(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Full screen loading
            if (_isInitializing)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: Color(0xFF1C1C1E),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget createPieChart() {
    return CustomPieChart(sections: _pieSections);
  }

  Widget createTabBarContentForAsset() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: assetCategories.map((category) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // Expand logic later
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: category['dotColor'] ?? Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            (category['label'] as String).substring(0, 1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category['label'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category['rateLabel'] ?? '',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            category['value'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                category['profitText'] ?? '',
                                style: TextStyle(
                                  color: category['profitColor'] ?? Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                category['profitRateText'] ?? '',
                                style: TextStyle(
                                  color: category['profitColor'] ?? Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
