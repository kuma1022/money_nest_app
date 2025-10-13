import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:money_nest_app/components/card_section.dart';
import 'package:money_nest_app/components/custom_line_chart.dart';
import 'package:money_nest_app/components/custom_tab.dart';
import 'package:money_nest_app/components/glass_panel.dart';
import 'package:money_nest_app/components/glass_tab.dart';
import 'package:money_nest_app/components/summary_category_card.dart';
import 'package:money_nest_app/components/total_asset_analysis_card.dart';
import 'package:money_nest_app/pages/assets/stock_detail_page.dart';
import 'package:money_nest_app/pages/assets/other_asset_manage_page.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/presentation/resources/app_texts.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:money_nest_app/util/global_store.dart';

class AssetsTabPage extends StatefulWidget {
  final ValueChanged<double>? onScroll;
  final ScrollController? scrollController;

  const AssetsTabPage({super.key, this.onScroll, this.scrollController});

  @override
  State<AssetsTabPage> createState() => AssetsTabPageState();
}

class AssetsTabPageState extends State<AssetsTabPage> {
  int _tabIndex = 0; // 0:概要 1:日本株 2:米国株 3:その他
  int _selectedTransitionIndex = 0; // 0:资产, 1:负債
  num totalAssets = 0;
  num totalCosts = 0;
  DateTime startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime endDate = DateTime.now();
  List<(DateTime, double)> priceHistory = [];
  List<(DateTime, double)> costBasisHistory = [];
  String _selectedRangeKey = '1ヶ月';
  final Map<String, Duration?> _rangeMap = {
    '1週間': const Duration(days: 7),
    '1ヶ月': const Duration(days: 30),
    '3ヶ月': const Duration(days: 90),
    '6ヶ月': const Duration(days: 180),
    '年初来': null, // 特殊处理
    '1年': const Duration(days: 365),
    '2年': const Duration(days: 365 * 2),
    '3年': const Duration(days: 365 * 3),
    '5年': const Duration(days: 365 * 5),
    '10年': const Duration(days: 365 * 10),
    'すべて': null,
  };

  @override
  void initState() {
    super.initState();
    // 页面初次进入时，触发动画
    //_animatePieChart();
    refreshTotalAssetsAndCosts();
  }

  // 刷新总资产和总成本
  Future<void> refreshTotalAssetsAndCosts() async {
    // 计算总资产和总成本
    final totalMap = AppUtils().getTotalAssetsAndCostsValue();
    setState(() {
      totalAssets = totalMap['totalAssets'];
      totalCosts = totalMap['totalCosts'];
    });
    // 计算历史数据
    priceHistory = [];
    costBasisHistory = [];
    // 计算资产总额和成本的历史数据
    for (var date in GlobalStore().historicalPortfolio.keys) {
      if (date.isBefore(startDate) || date.isAfter(endDate)) continue;
      final item = GlobalStore().historicalPortfolio[date]!;
      priceHistory.add((date, item['assetsTotal'] as double? ?? 0.0));
      costBasisHistory.add((date, item['costBasis'] as double? ?? 0.0));
    }
  }

  List<Map<String, dynamic>> groupConsecutive(
    List<(DateTime, double)> items,
    List<(DateTime, double)> compareItems,
  ) {
    if (items.isEmpty) return [];
    List<(DateTime, double)> currentGroup = [items.first];
    bool currentFlag = items.first.$2 > compareItems.first.$2;
    List<Map<String, dynamic>> datas = [];

    for (int i = 1; i < items.length; i++) {
      final nextFlag = items[i].$2 > compareItems[i].$2;
      if (nextFlag != currentFlag) {
        // 标志变化，结束当前组，开始新组
        datas.add({
          'label': '資産総額',
          'color': currentFlag ? AppColors.appUpGreen : AppColors.appDownRed,
          'dataList': List.from(currentGroup),
        });
        currentGroup = [items[i]];
        currentFlag = nextFlag;
      } else {
        currentGroup.add(items[i]);
      }
    }
    // 添加最后一组
    datas.add({
      'label': '資産総額',
      'color': currentFlag ? AppColors.appUpGreen : AppColors.appDownRed,
      'dataList': List.from(currentGroup),
    });

    return datas;
  }

  Future<void> _reloadByRange() async {
    final now = DateTime.now();
    final dur = _rangeMap[_selectedRangeKey];
    final String? startDate = (dur == null)
        ? null
        : now.subtract(dur).toIso8601String().split('T').first;
    final String? endDate = now.toIso8601String().split('T').first;
    //await syncDataWithSupabase(
    //  /* userId */ GlobalStore().userId!,
    //  /* accountId */ GlobalStore().currentAccountId!,
    //  /* db */ GlobalStore().db,
    //   startDate: startDate,
    //   endDate: endDate,
    // );
    setState(() {});
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
                    CustomTab(
                      tabs: ['推移', '内訳', 'ポートフォリオ', '配当'],
                      tabViews: [
                        buildTransitionWidget(),
                        buildBreakdownWidget(),
                        buildPortfolioWidget(),
                        buildDividendWidget(),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 资产总览区块
                    TotalAssetAnalysisCard(),
                    CardSection(
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
                                      ).withValues(alpha: 0.08),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: List.generate(4, (i) {
                          final tabs = ['概要', '日本株', '米国株', 'その他'];
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _tabIndex = i),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _tabIndex == i
                                      ? AppColors.appBackground
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _tabIndex == i
                                        ? const Color(0xFF1976D2)
                                        : const Color(0xFFE5E6EA),
                                    width: 1.2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    tabs[i],
                                    style: TextStyle(
                                      color: _tabIndex == i
                                          ? const Color(0xFF1976D2)
                                          : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    // tab内容区块
                    if (_tabIndex == 0) ...[
                      // 概要tab
                      _AssetCategoryCard(
                        title: '日本株',
                        amount: '¥750,000',
                        profit: '+¥125,000 (20%)',
                        profitColor: const Color(0xFF388E3C),
                        profitBg: const Color(0xFFE6F9F0),
                        items: const [
                          _AssetItem(
                            code: '7203',
                            name: 'トヨタ自動車',
                            amount: '¥250,000',
                            profit: '+¥50,000',
                            profitColor: Color(0xFF388E3C),
                          ),
                          _AssetItem(
                            code: '6758',
                            name: 'ソニー',
                            amount: '¥400,000',
                            profit: '+¥75,000',
                            profitColor: Color(0xFF388E3C),
                          ),
                          _AssetItem(
                            code: '9984',
                            name: 'ソフトバンク',
                            amount: '¥100,000',
                            profit: '+¥0',
                            profitColor: Color(0xFF757575),
                          ),
                        ],
                      ),
                      _AssetCategoryCard(
                        title: '米国株',
                        amount: '¥450,000',
                        profit: '+¥75,000 (20%)',
                        profitColor: const Color(0xFF388E3C),
                        profitBg: const Color(0xFFE6F9F0),
                        items: const [
                          _AssetItem(
                            code: 'AAPL',
                            name: 'Apple Inc.',
                            amount: '¥180,000',
                            profit: '+¥30,000',
                            profitColor: Color(0xFF388E3C),
                          ),
                          _AssetItem(
                            code: 'MSFT',
                            name: 'Microsoft',
                            amount: '¥210,000',
                            profit: '+¥35,000',
                            profitColor: Color(0xFF388E3C),
                          ),
                          _AssetItem(
                            code: 'GOOGL',
                            name: 'Alphabet',
                            amount: '¥60,000',
                            profit: '+¥10,000',
                            profitColor: Color(0xFF388E3C),
                          ),
                        ],
                      ),
                      _AssetCategoryCard(
                        title: '現金',
                        amount: '¥250,000',
                        profit: '+¥0 (0%)',
                        profitColor: const Color(0xFF757575),
                        profitBg: AppColors.appBackground,
                        items: const [],
                      ),
                      _CardSection(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'その他資産',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1976D2),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('管理'),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const OtherAssetManagePage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '¥4,870,000',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _OtherAssetItem(
                              label: '銀行預金',
                              subLabel: '現金',
                              amount: '¥250,000',
                            ),
                            _OtherAssetItem(
                              label: '金 (GOLD)',
                              subLabel: '貴金属',
                              amount: '¥120,000',
                            ),
                            _OtherAssetItem(
                              label: 'ドル預金',
                              subLabel: '外貨',
                              amount: '¥30,000',
                              subAmount: '→¥4,500,000',
                            ),
                          ],
                        ),
                      ),
                    ] else if (_tabIndex == 1) ...[
                      // 日本株tab
                      _CardSection(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  '日本株',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                const Text(
                                  '¥750,000',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6F9F0),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Text(
                                    '+¥125,000 (20%)',
                                    style: TextStyle(
                                      color: Color(0xFF388E3C),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // 日本株tab按钮布局：购买按钮大，配当按钮小且右侧
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF1976D2),
                                      side: const BorderSide(
                                        color: Color(0xFF1976D2),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    icon: const Icon(Icons.add),
                                    label: const Text('購入'),
                                    onPressed: () {},
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF1976D2),
                                      side: const BorderSide(
                                        color: Color(0xFF1976D2),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.card_giftcard,
                                      size: 18,
                                    ),
                                    label: const Text('配当'),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _AssetItem(
                              code: '7203',
                              name: 'トヨタ自動車',
                              amount: '¥250,000',
                              profit: '+¥50,000',
                              profitColor: const Color(0xFF388E3C),
                            ),
                            _AssetItem(
                              code: '6758',
                              name: 'ソニー',
                              amount: '¥400,000',
                              profit: '+¥75,000',
                              profitColor: const Color(0xFF388E3C),
                            ),
                            _AssetItem(
                              code: '9984',
                              name: 'ソフトバンク',
                              amount: '¥100,000',
                              profit: '+¥0',
                              profitColor: const Color(0xFF757575),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_tabIndex == 2) ...[
                      // 米国株tab
                      _CardSection(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  '米国株',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                const Text(
                                  '¥450,000',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6F9F0),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Text(
                                    '+¥75,000 (20%)',
                                    style: TextStyle(
                                      color: Color(0xFF388E3C),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // 米国株tab按钮布局：两个按钮等宽
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF1976D2),
                                      side: const BorderSide(
                                        color: Color(0xFF1976D2),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    icon: const Icon(Icons.add),
                                    label: const Text('購入'),
                                    onPressed: () {},
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF1976D2),
                                      side: const BorderSide(
                                        color: Color(0xFF1976D2),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.card_giftcard,
                                      size: 18,
                                    ),
                                    label: const Text('配当'),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _AssetItem(
                              code: 'AAPL',
                              name: 'Apple Inc.',
                              amount: '¥180,000',
                              profit: '+¥30,000',
                              profitColor: const Color(0xFF388E3C),
                            ),
                            _AssetItem(
                              code: 'MSFT',
                              name: 'Microsoft',
                              amount: '¥210,000',
                              profit: '+¥35,000',
                              profitColor: const Color(0xFF388E3C),
                            ),
                            _AssetItem(
                              code: 'GOOGL',
                              name: 'Alphabet',
                              amount: '¥60,000',
                              profit: '+¥10,000',
                              profitColor: const Color(0xFF388E3C),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_tabIndex == 3) ...[
                      // その他tab
                      _CardSection(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'その他資産',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1976D2),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('管理'),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const OtherAssetManagePage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '¥4,870,000',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _OtherAssetItem(
                              label: '銀行預金',
                              subLabel: '現金',
                              amount: '¥250,000',
                            ),
                            _OtherAssetItem(
                              label: '金 (GOLD)',
                              subLabel: '貴金属',
                              amount: '¥120,000',
                            ),
                            _OtherAssetItem(
                              label: 'ドル預金',
                              subLabel: '外貨',
                              amount: '¥30,000',
                              subAmount: '→¥4,500,000',
                            ),
                          ],
                        ),
                      ),
                    ],
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

  Widget buildTransitionWidget() {
    return StatefulBuilder(
      builder: (context, setState) {
        final double tabBtnHeight = 32;
        final double tabBtnRadius = tabBtnHeight / 2;

        return Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 48),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTransitionIndex = 0),
                    child: Container(
                      height: tabBtnHeight,
                      decoration: BoxDecoration(
                        color: _selectedTransitionIndex == 0
                            ? AppColors.appBlue
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(tabBtnRadius),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: _selectedTransitionIndex == 0
                                ? Colors.white
                                : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '資産',
                            style: TextStyle(
                              color: _selectedTransitionIndex == 0
                                  ? Colors.white
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTransitionIndex = 1),
                    child: Container(
                      height: tabBtnHeight,
                      decoration: BoxDecoration(
                        color: _selectedTransitionIndex == 1
                            ? AppColors.appDownRed
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(tabBtnRadius),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.trending_down,
                            color: _selectedTransitionIndex == 1
                                ? Colors.white
                                : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '負債',
                            style: TextStyle(
                              color: _selectedTransitionIndex == 1
                                  ? Colors.white
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 18),
            _selectedTransitionIndex == 0
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [buildTransitionAssetWidget(), createAssetList()],
                  )
                : buildTransitionLiabilityWidget(),
          ],
        );
      },
    );
  }

  Widget createAssetList() {
    final totalStocksMap = AppUtils().getTotalAssetsAndCostsValue();
    final double totalStocksSum = totalStocksMap['totalAssets'];
    final double totalStocksCostsSum = totalStocksMap['totalCosts'];
    final double totalStocksNetSum = totalStocksSum - totalStocksCostsSum;
    final String totalStocksNetRate = totalStocksCostsSum == 0
        ? '0.0%'
        : '${AppUtils().formatNumberByTwoDigits((totalStocksNetSum / totalStocksCostsSum) * 100)}%';

    final List categories = [
      {
        'label': '株式',
        'dotColor': AppColors.appChartGreen,
        'rateLabel': '100%',
        'value': AppUtils().formatMoney(
          totalStocksSum,
          GlobalStore().selectedCurrencyCode!,
        ),
        'profitText': AppUtils().formatMoney(
          totalStocksNetSum,
          GlobalStore().selectedCurrencyCode!,
        ),
        'profitRateText': '($totalStocksNetRate)',
        'profitColor': AppColors.appUpGreen,
        'subCategories': [],
      },
      {
        'label': '投資信託',
        'dotColor': AppColors.appDarkGrey,
        'rateLabel': '0%',
        'value': '¥0',
        'profitText': '¥0',
        'profitRateText': '(0%)',
        'profitColor': AppColors.appGrey,
        'subCategories': [],
      },
      {
        'label': 'FX（為替）',
        'dotColor': AppColors.appChartBlue,
        'rateLabel': '0%',
        'value': '¥0',
        'profitText': '¥0',
        'profitRateText': '(0%)',
        'profitColor': AppColors.appGrey,
        'subCategories': [],
      },
      {
        'label': '暗号資産',
        'dotColor': AppColors.appChartPurple,
        'rateLabel': '0%',
        'value': '¥0',
        'profitText': '¥0',
        'profitRateText': '(+0%)',
        'profitColor': AppColors.appGrey,
        'subCategories': [],
      },
      {
        'label': '貴金属',
        'dotColor': AppColors.appChartOrange,
        'rateLabel': '0%',
        'value': '¥0',
        'profitText': '¥0',
        'profitRateText': '(0%)',
        'profitColor': AppColors.appGrey,
        'subCategories': [],
      },
      {
        'label': 'その他資産',
        'dotColor': AppColors.appChartLightBlue,
        'rateLabel': '0%',
        'value': '¥0',
        'profitText': '¥0',
        'profitRateText': '(+0%)',
        'profitColor': AppColors.appGrey,
        'subCategories': [],
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
          subCategories: [],
        );
      }).toList(),
    );
  }

  // 资产推移图表卡片
  Widget buildTransitionAssetWidget() {
    final List<Map<String, dynamic>> datas = [];
    if (priceHistory.isNotEmpty && costBasisHistory.isNotEmpty) {
      /*final List<Map<String, dynamic>> grouped = groupConsecutive(
        priceHistory,
        costBasisHistory,
      );

      for (var group in grouped) {
        datas.add({
          'label': group['label'],
          'color': group['color'],
          'dataList': (group['dataList'] as List).cast<(DateTime, double)>(),
        });
      }
      */
      datas.add({
        'label': '評価総額',
        'lineColor': AppColors.appChartBlue,
        'tooltipText1Color': AppColors.appChartLightBlue,
        'tooltipText2Color': AppColors.appChartLightBlue,
        'dataList': priceHistory,
      });

      datas.add({
        'label': '取得総額',
        'lineColor': AppColors.appGrey,
        'tooltipText1Color': AppColors.appLightGrey,
        'tooltipText2Color': AppColors.appLightGrey,
        'dataList': costBasisHistory,
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '資産総額',
              style: TextStyle(
                fontSize: AppTexts.fontSizeMedium,
                color: Colors.black87,
              ),
            ),
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
          ],
        ),
        const SizedBox(height: 12),
        if (datas.isNotEmpty)
          // 区间选择 pulldown 靠右
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: _PlatformRangeSelector(
                value: _selectedRangeKey,
                values: _rangeMap.keys.toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _selectedRangeKey = v);
                  _reloadByRange();
                },
              ),
            ),
          ),
        _TransitionAssetChart(
          datas: datas,
          currencyCode: GlobalStore().selectedCurrencyCode ?? 'JPY',
        ),
      ],
    );
  }

  Widget buildTransitionLiabilityWidget() {
    return const SizedBox(
      height: 200,
      child: Center(child: Text('負債推移グラフ（未実装）')),
    );
  }

  Widget buildBreakdownWidget() {
    return const SizedBox(
      height: 200,
      child: Center(child: Text('内訳グラフ（未実装）')),
    );
  }

  Widget buildPortfolioWidget() {
    return const SizedBox(
      height: 200,
      child: Center(child: Text('ポートフォリオグラフ（未実装）')),
    );
  }

  Widget buildDividendWidget() {
    return const SizedBox(
      height: 200,
      child: Center(child: Text('配当グラフ（未実装）')),
    );
  }
}

// 卡片通用外框
class _CardSection extends StatelessWidget {
  final Widget child;
  const _CardSection({required this.child, super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E6EA), width: 1),
      ),
      child: child,
    );
  }
}

// 资产总览tab按钮
class _OverviewTabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _OverviewTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.appBackground : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF1976D2) : const Color(0xFFE5E6EA),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF1976D2) : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// 资产总览图例
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final String percent;
  const _LegendDot({
    required this.color,
    required this.label,
    required this.percent,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 2),
        Text(percent, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }
}

// 分类资产卡片
class _AssetCategoryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String profit;
  final Color profitColor;
  final Color profitBg;
  final List<_AssetItem> items;
  const _AssetCategoryCard({
    required this.title,
    required this.amount,
    required this.profit,
    required this.profitColor,
    required this.profitBg,
    required this.items,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      margin: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: profitBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  profit,
                  style: TextStyle(
                    color: profitColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 8),
            Column(children: items),
          ],
        ],
      ),
    );
  }
}

// 分类资产明细
class _AssetItem extends StatelessWidget {
  final String code;
  final String name;
  final String amount;
  final String profit;
  final Color profitColor;
  const _AssetItem({
    required this.code,
    required this.name,
    required this.amount,
    required this.profit,
    required this.profitColor,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StockDetailPage(
              code: code,
              name: name,
              amount: amount,
              profit: profit,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.appBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  name,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  profit,
                  style: TextStyle(
                    fontSize: 13,
                    color: profitColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// 其它资产明细
class _OtherAssetItem extends StatelessWidget {
  final String label;
  final String subLabel;
  final String amount;
  final String? subAmount;
  const _OtherAssetItem({
    required this.label,
    required this.subLabel,
    required this.amount,
    this.subAmount,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.appBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                subLabel,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (subAmount != null)
                Text(
                  subAmount!,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransitionAssetChart extends StatefulWidget {
  final List<Map<String, dynamic>> datas;
  final String currencyCode;
  const _TransitionAssetChart({
    required this.datas,
    required this.currencyCode,
  });

  @override
  State<_TransitionAssetChart> createState() => _TransitionAssetChartState();
}

class _TransitionAssetChartState extends State<_TransitionAssetChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // 这里直接传完整 dataList
        return CardSection(
          child: LineChartSample12(
            datas: widget.datas,
            currencyCode: widget.currencyCode,
            animationValue: _animation.value, // 0.0~1.0
          ),
        );
      },
    );
  }
}

// 平台自适应的区间选择器
class _PlatformRangeSelector extends StatelessWidget {
  const _PlatformRangeSelector({
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      // iOS/macOS: ActionSheet风格
      return _CupertinoRangeSelector(
        value: value,
        values: values,
        onChanged: onChanged,
      );
    }
    // 其它平台: Material Dropdown
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isDense: true,
        style: const TextStyle(fontSize: 13, color: Colors.black),
        borderRadius: BorderRadius.circular(10),
        items: values
            .map((v) => DropdownMenuItem<String>(value: v, child: Text(v)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _CupertinoRangeSelector extends StatelessWidget {
  const _CupertinoRangeSelector({
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  void _showPicker(BuildContext context) {
    final FixedExtentScrollController controller = FixedExtentScrollController(
      initialItem: values.indexOf(value),
    );
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 260,
        color: AppColors.appDarkGrey,
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () {
                      final picked = values[controller.selectedItem];
                      onChanged(picked);
                      Navigator.pop(context);
                    },
                    child: const Text('确定'),
                  ),
                ],
              ),
            ),
            const Divider(height: 0),
            Expanded(
              child: CupertinoPicker(
                scrollController: controller,
                itemExtent: 32,
                magnification: 1.1,
                squeeze: 1.0,
                onSelectedItemChanged: (_) {},
                children: values
                    .map(
                      (v) => Center(
                        child: Text(
                          v,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      minSize: 32,
      borderRadius: BorderRadius.circular(8),
      color: CupertinoColors.systemGrey5.resolveFrom(context),
      onPressed: () => _showPicker(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.black),
          ),
          const SizedBox(width: 4),
          const Icon(
            CupertinoIcons.chevron_down,
            size: 14,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
