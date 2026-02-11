import 'package:flutter/material.dart';
import 'package:money_nest_app/components/total_asset_analysis_card.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/models/categories.dart';
import 'package:money_nest_app/pages/asset_analysis/asset_analysis_detail_page.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:money_nest_app/util/global_store.dart';

// 定义时间筛选的选项
enum DateRange {
  custom,
  thisYear,
  lastYear,
  lastOneYear,
  lastThreeYears,
  lastFiveYears,
  allTime,
}

class AssetAnalysisPage extends StatefulWidget {
  final AppDatabase db;
  final ValueChanged<double>? onScroll;
  final ScrollController? scrollController;

  const AssetAnalysisPage({
    super.key,
    required this.db,
    this.onScroll,
    this.scrollController,
  });

  @override
  State<AssetAnalysisPage> createState() => AssetAnalysisPageState();
}

class AssetAnalysisPageState extends State<AssetAnalysisPage> {
  bool _isInitializing = false;
  int tabIndex = 0; // 0: 資産分析, 1: 損益分析
  int calendarTab = 0; // 0: 月別, 1: 年別
  // 注意：移除了 stockTab，因为新设计不需要在顶部切换

  // 【新增】时间筛选状态变量
  DateRange _selectedDateRange = DateRange.thisYear; // 默认选择今年
  DateTime? _startDate;
  DateTime? _endDate;

  Map<Stock, double> profitListDomestic = {};
  Map<Stock, double> profitListUS = {};
  List<Subcategories> subCategoryList = [];
  double rateJPY = 1.0;
  double rateUSD = 1.0;

  // ... (_initializeData 和 onRefresh 方法保持不变)
  Future<void> _initializeData() async {
    if (!mounted) return;
    setState(() => _isInitializing = true);
    try {
      // 大分类
      final catList = Categories.values
          .where((v) => v.type == 'asset')
          .map((v) => v.id)
          .toList();
      final subcatList = Subcategories.values
          .where((v) => catList.contains(v.categoryId))
          .toList();

      final profitsJP = await AppUtils().calculateProfitAndLoss(
        widget.db,
        "JP",
        _startDate,
        _endDate,
      );
      final profitsUS = await AppUtils().calculateProfitAndLoss(
        widget.db,
        "US",
        _startDate,
        _endDate,
      );
      if (mounted) {
        setState(() {
          rateJPY =
              GlobalStore()
                  .currentStockPrices['JPY${GlobalStore().selectedCurrencyCode}=X'] ??
              1.0;
          rateUSD =
              GlobalStore()
                  .currentStockPrices['${GlobalStore().selectedCurrencyCode}=X'] ??
              1.0;
          profitListDomestic = profitsJP;
          profitListUS = profitsUS;
          subCategoryList = subcatList;
          _isInitializing = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  // 【新增】根据选择的筛选条件更新日期范围
  void _updateDateRange(DateRange newRange) {
    setState(() {
      _selectedDateRange = newRange;
      // 实际的日期计算逻辑需要完善，这里仅为占位
      final now = DateTime.now();
      switch (newRange) {
        case DateRange.thisYear:
          _startDate = DateTime(now.year, 1, 1);
          _endDate = now;
          break;
        case DateRange.lastYear:
          _startDate = DateTime(now.year - 1, 1, 1);
          _endDate = DateTime(now.year - 1, 12, 31);
          break;
        case DateRange.lastOneYear:
          _startDate = DateTime(now.year - 1, now.month, now.day);
          _endDate = now;
          break;
        case DateRange.lastThreeYears:
          _startDate = DateTime(now.year - 3, now.month, now.day);
          _endDate = now;
          break;
        case DateRange.lastFiveYears:
          _startDate = DateTime(now.year - 5, now.month, now.day);
          _endDate = now;
          break;
        case DateRange.allTime:
          _startDate = null; // 或者设置为最早记录时间
          _endDate = now;
          break;
        case DateRange.custom:
          // 自定义日期范围需要从DatePicker中获取，这里暂时不处理
          break;
      }
      if (newRange != DateRange.custom) {
        // 重新加载数据
        _initializeData();
      }
    });
  }

  Future<void> onRefresh() async {
    _updateDateRange(DateRange.thisYear); // 初始化日期范围
    await _initializeData();
  }

  // 【新增】自定义日期范围选择器（简化版）
  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime(DateTime.now().year, 1, 1),
        end: _endDate ?? DateTime.now(),
      ),
      // *** 参考您的示例代码，添加语言环境 ***
      locale: const Locale('ja', 'JP'),
      // *** 使用 builder 确保在大型设备上以弹出框（居中对话框）形式显示 ***
      builder: (BuildContext context, Widget? child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 700.0, // 限制在平板/桌面上的最大宽度
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF4385F5), // 突出颜色
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black87,
                ),
                dialogBackgroundColor: Colors.white,
              ),
              child: child!,
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = DateRange.custom;
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _initializeData(); // 重新加载数据
    }
  }

  // 【新增】获取当前筛选范围的显示文本
  String get _dateRangeText {
    switch (_selectedDateRange) {
      case DateRange.thisYear:
        return '年初来';
      case DateRange.lastYear:
        return '去年';
      case DateRange.lastOneYear:
        return '1年';
      case DateRange.lastThreeYears:
        return '3年';
      case DateRange.lastFiveYears:
        return '5年';
      case DateRange.allTime:
        return 'すべて';
      case DateRange.custom:
        final start = _startDate != null
            ? '${_startDate!.year}/${_startDate!.month}/${_startDate!.day}'
            : '';
        final end = _endDate != null
            ? '${_endDate!.year}/${_endDate!.month}/${_endDate!.day}'
            : '';
        return '$start - $end';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black, // Dark background
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
                  return false;
                },
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
                                const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.maybePop(context),
                          ),
                          const Text(
                            'Analysis',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                           // Placeholder for symmetry or add an action
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Custom Tab Selector (Adapting to dark theme)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1E),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            _AnalysisTabButton(
                              text: 'Asset Analysis',
                              selected: tabIndex == 0,
                              onTap: () => setState(() => tabIndex = 0),
                            ),
                            _AnalysisTabButton(
                              text: 'P&L Analysis',
                              selected: tabIndex == 1,
                              onTap: () => setState(() => tabIndex = 1),
                            ),
                          ],
                        ),
                      ),

                      // Time Filter (Only for P&L)
                      if (tabIndex == 1) ...[
                        _DateRangeFilter(
                          selectedRange: _selectedDateRange,
                          dateRangeText: _dateRangeText,
                          onRangeSelected: _updateDateRange,
                          onCustomTap: _selectCustomDateRange,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Content
                      if (tabIndex == 0) ...[
                        // Ensure TotalAssetAnalysisCard handles dark mode or replace/wrap it
                        // Assuming components need to be updated or wrapped.
                        // For now wrapping in a dark container style if needed,
                        // but TotalAssetAnalysisCard might have its own style.
                        // I will update TotalAssetAnalysisCard usage if I could see it,
                        // but since I can't modify it here, I will just display it.
                        // NOTE: Ideally all sub-components should also be updated.
                        TotalAssetAnalysisCard(isAssetAnalysisBtnDisplay: false, isDark: true), // Assuming isDark param or auto-adapt
                        const SizedBox(height: 18),
                        _AssetTrendCard(),
                        const SizedBox(height: 18),
                        _ProfitTrendCard(),
                        const SizedBox(height: 18),
                        _ProfitCalendarCard(
                          tab: calendarTab,
                          onTabChanged: (i) => setState(() => calendarTab = i),
                        ),
                      ] else ...[
                        // P&L Analysis
                        _buildNewProfitSummaryCard(),
                        const SizedBox(height: 16),
                        _buildAssetClassChartCard(),
                        const SizedBox(height: 24),
                        // ... rest of P&L content
                      ],
                      const SizedBox(height: 80),
                    ],
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

                      // 3. 详情列表标题
                      const Text(
                        "詳細を見る",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 8),

                      // 4. 详情卡片 (日本株/美国株)
                      _buildDetailCardsRow(),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
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

  // --- 新的 UI 构建方法 ---

  // 1. 仿照图1的绿色汇总卡片
  Widget _buildNewProfitSummaryCard() {
    // 计算逻辑
    double calcTotalProfit(Map<Stock, double> list) =>
        list.values.where((v) => v > 0).fold(0.0, (p, c) => p + c);
    double calcTotalLoss(Map<Stock, double> list) =>
        list.values.where((v) => v < 0).fold(0.0, (p, c) => p + c); // 负数和

    final totalProfit =
        calcTotalProfit(profitListDomestic) * rateJPY +
        calcTotalProfit(profitListUS) * rateUSD;
    final totalLoss =
        (calcTotalLoss(profitListDomestic) * rateJPY +
                calcTotalLoss(profitListUS) * rateUSD)
            .abs();
    final netProfit = totalProfit - totalLoss;

    // 模拟的收益率，实际项目中需根据 (纯益 / 总投入) 计算
    final profitPercent = "--%";

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF8F1), // 浅绿色背景
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 标题
          Row(
            children: const [
              Icon(Icons.show_chart, color: Color(0xFF4CAF50), size: 20),
              SizedBox(width: 8),
              Text(
                '損益サマリー',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 总利益 / 总损失 卡片行
          Row(
            children: [
              // 总利益
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: Color(0xFF66BB6A),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '総利益',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+${AppUtils().formatMoney(totalProfit, GlobalStore().selectedCurrencyCode)}',
                        style: const TextStyle(
                          color: Color(0xFF66BB6A),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 总损失
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.trending_down,
                        color: Color(0xFFEF5350),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '総損失',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppUtils().formatMoney(
                          totalLoss,
                          GlobalStore().selectedCurrencyCode,
                        ), // Loss formatting
                        style: const TextStyle(
                          color: Color(0xFFEF5350),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 纯损益 (大卡片)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  '純損益',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  (netProfit >= 0 ? '+' : '') +
                      AppUtils().formatMoney(
                        netProfit,
                        GlobalStore().selectedCurrencyCode,
                      ),
                  style: TextStyle(
                    color: netProfit >= 0
                        ? const Color(0xFF66BB6A)
                        : const Color(0xFFEF5350),
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profitPercent, // 这里使用了模拟数据
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. 仿照图1的资产类别柱状图 (已修复溢出问题)
  Widget _buildAssetClassChartCard() {
    // 准备数据 (保持不变)
    double getNet(Map<Stock, double> list) =>
        list.values.fold(0.0, (p, c) => p + c);

    final jpNet = getNet(profitListDomestic) * rateJPY;
    final usNet = getNet(profitListUS) * rateUSD;

    // 图表数据模型 (保持不变)
    final data = subCategoryList
        .map((sub) {
          if (sub.code == 'jp_stock') {
            return {'label': sub.name, 'value': jpNet};
          }
          if (sub.code == 'us_stock') {
            return {'label': sub.name, 'value': usNet};
          }
          return {'label': sub.name, 'value': 0.0};
        })
        .where((d) => d['value'] as double != 0.0)
        .toList();

    // 找出最大值用于比例缩放 (保持不变)
    double maxValue = 100000;
    for (var item in data) {
      if ((item['value'] as double) > maxValue) {
        maxValue = (item['value'] as double);
      }
    }
    if (maxValue == 0) maxValue = 1;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'アセットクラス別損益',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // 图表区域
          AspectRatio(
            aspectRatio: 1.4,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // 背景网格线 & 左侧刻度 (保持不变)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (index) {
                        return Container(
                          height: 1,
                          color: Colors.grey.withOpacity(0.2),
                        );
                      }),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(5, (index) {
                        final val = maxValue * (4 - index) / 4;
                        return Text(
                          '¥${(val / 1000).toInt()}K',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      }),
                    ),
                    // 柱状图本体：使用 SingleChildScrollView 包裹 Row
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 35, // 留给左侧刻度的空间
                        bottom: 0,
                        top: 10,
                      ),
                      child: SingleChildScrollView(
                        // 关键修改: 允许水平滚动
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          // 移除 mainAxisAlignment: MainAxisAlignment.spaceEvenly
                          // 因为 SingleChildScrollView 内部的 Row 宽度会等于所有子组件的总宽度
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: data.map((item) {
                            final val = item['value'] as double;
                            // 计算高度比例
                            // 注意: constraints.maxHeight 应该使用 AspectRatio 限制的整个高度
                            // 但在 SingleChildScrollView 内部，Row 的宽度是无限的，其高度是 AspectRatio 给出的
                            final heightPct = (val / maxValue).clamp(0.0, 1.0);

                            // 设定固定的列间距 (如果需要)
                            const double columnSpacing = 16.0;

                            return Padding(
                              padding: const EdgeInsets.only(
                                right: columnSpacing,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // 柱子
                                  Container(
                                    width: 30, // 设定柱子固定宽度
                                    // 重新计算柱子高度：总图表高度（减去标签和间距） * 比例
                                    height:
                                        constraints.maxHeight * 0.7 * heightPct,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF66BB6A),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(6),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // 标签
                                  SizedBox(
                                    height: 30,
                                    child: Transform.rotate(
                                      angle: -0.5,
                                      child: Text(
                                        item['label'] as String,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 3. 仿照图1底部的详情卡片 (修改版：增加点击事件)
  Widget _buildDetailCardsRow() {
    double getNet(Map<Stock, double> list) =>
        list.values.fold(0.0, (p, c) => p + c);
    final jpNet = getNet(profitListDomestic) * rateJPY;
    final usNet = getNet(profitListUS) * rateUSD;

    // 数据模型
    final data = subCategoryList.map((sub) {
      if (sub.code == 'jp_stock') {
        return {
          'title': sub.name,
          'profitList': profitListDomestic,
          'currencyCode': 'JPY',
          'value': jpNet,
          'icon': Icons.account_balance,
        };
      }
      if (sub.code == 'us_stock') {
        return {
          'title': sub.name,
          'profitList': profitListUS,
          'currencyCode': 'USD',
          'value': usNet,
          'icon': Icons.attach_money,
        };
      }
      return {
        'title': sub.name,
        'profitList': [],
        'currencyCode': 'JPY',
        'value': 0.0,
        'icon': Icons.account_balance,
      };
    }).toList();

    // 使用 LayoutBuilder 获取当前可用宽度
    return LayoutBuilder(
      builder: (context, constraints) {
        // 设定间距
        const double spacing = 12.0;
        // 计算每个卡片的宽度：(总宽度 - 中间间距) / 2
        final double itemWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing, // 水平间距
          runSpacing: spacing, // 垂直换行间距
          children: data.map((e) {
            // 注意：Wrap 内部不能使用 Expanded，改用 SizedBox 指定宽度
            return SizedBox(
              width: itemWidth,
              child: GestureDetector(
                onTap: () {
                  // 只有金额不等于0才允许跳转
                  if (e['value'] as double != 0.0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssetAnalysisDetailPage(
                          // 假设您这里有一个 title 字段，或者使用 e['title']
                          // 这里的 title 生成逻辑请根据您实际需要调整
                          title: '損益分析 - ${e['title'].toString()}',
                          // 这里假设 data 里的数据结构已经包含 profitList
                          // 如果没有，您可能需要根据 e['title'] 去匹配对应的 list
                          profitList: e['profitList'] as Map<Stock, double>,
                          currencyCode: e['currencyCode'].toString(),
                        ),
                      ),
                    );
                  }
                },
                child: _DetailCard(
                  icon: e['icon'] as IconData,
                  title: e['title'].toString(),
                  amount: e['value'] as double,
                  percent: '--%', // 或者 e['percent']
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// 【新增】时间筛选器 Widget
class _DateRangeFilter extends StatelessWidget {
  final DateRange selectedRange;
  final String dateRangeText;
  final ValueChanged<DateRange> onRangeSelected;
  final VoidCallback onCustomTap;

  const _DateRangeFilter({
    required this.selectedRange,
    required this.dateRangeText,
    required this.onRangeSelected,
    required this.onCustomTap,
  });

  @override
  Widget build(BuildContext context) {
    // 预设日期范围的列表，用于 PopUpMenuButton
    final List<Map<String, dynamic>> presetRanges = [
      {'text': '年初来', 'range': DateRange.thisYear},
      {'text': '1年', 'range': DateRange.lastOneYear},
      {'text': '3年', 'range': DateRange.lastThreeYears},
      {'text': '5年', 'range': DateRange.lastFiveYears},
      {'text': 'すべて', 'range': DateRange.allTime},
    ];

    return Row(
      children: [
        // 1. 下拉菜单按钮 (预设范围)
        PopupMenuButton<DateRange>(
          initialValue: selectedRange,
          onSelected: (DateRange result) {
            if (result != DateRange.custom) {
              onRangeSelected(result);
            }
          },
          itemBuilder: (BuildContext context) => [
            ...presetRanges.map(
              (item) => PopupMenuItem<DateRange>(
                value: item['range'] as DateRange,
                child: Text(item['text'] as String),
              ),
            ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E6EA)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dateRangeText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // 2. 自定义日期按钮（日历图标）
        GestureDetector(
          onTap: onCustomTap,
          child: Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: selectedRange == DateRange.custom
                  ? const Color(0xFF4385F5)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selectedRange == DateRange.custom
                    ? const Color(0xFF4385F5)
                    : const Color(0xFFE5E6EA),
              ),
            ),
            child: Icon(
              Icons.calendar_month,
              size: 20,
              color: selectedRange == DateRange.custom
                  ? Colors.white
                  : Colors.black54,
            ),
          ),
        ),

        // 3. 右侧的占位 Spacer
        const Spacer(),
      ],
    );
  }
}

// 辅助小部件：详情卡片
// 辅助小部件：详情卡片 (已修改高度一致性)
class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double amount;
  final String percent;

  const _DetailCard({
    super.key, // 添加 super.key 是好习惯
    required this.icon,
    required this.title,
    required this.amount,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = amount >= 0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 顶部图标行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFE8F5E9),
                child: Icon(icon, color: Colors.black87, size: 20),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 20), // 稍微调整间距
          // 2. 标题区域 (关键修改)
          // 使用 SizedBox 强制设定标题区域的高度。
          // 高度 42 足够容纳 fontSize:14 的两行文字。
          // 这样，无论标题是1行还是2行，占位高度都一样。
          SizedBox(
            height: 42,
            child: Align(
              alignment: Alignment.centerLeft, // 确保单行文字也靠左居中
              child: Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                maxLines: 2, // 限制最多显示 2 行
                overflow: TextOverflow.ellipsis, // 超出 2 行显示省略号
              ),
            ),
          ),

          const SizedBox(height: 12), // 调整间距
          // 3. 金额
          Text(
            (isPositive ? '+' : '') +
                AppUtils().formatMoney(
                  amount,
                  GlobalStore().selectedCurrencyCode,
                ),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              // 根据正负显示红绿颜色
              color: isPositive
                  ? const Color(0xFF66BB6A)
                  : const Color(0xFFEF5350),
            ),
          ),
          const SizedBox(height: 4),

          // 4. 百分比
          Text(
            percent,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// 辅助小部件：资产分析Tab按钮 (复用原逻辑)
class _AnalysisTabButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _AnalysisTabButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _AssetTrendCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 静态折线图占位
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E6EA)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '資産走勢',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Text(
                      '6ヶ月',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    Icon(Icons.expand_more, size: 18, color: Colors.black54),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: CustomPaint(
              painter: _LineChartPainter(),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

// 折线图简单占位
class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1976D2)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.4),
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width, size.height * 0.1),
    ];
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);

    // 绘制点
    final dotPaint = Paint()..color = const Color(0xFF1976D2);
    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- 損益分析tab内容 ---

class _ProfitTrendCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E6EA)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '収益走勢',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: CustomPaint(
              painter: _LineChartPainter(),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfitCalendarCard extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onTabChanged;
  const _ProfitCalendarCard({required this.tab, required this.onTabChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E6EA)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '収益カレンダー',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              _CalendarTabSwitcher(tab: tab, onChanged: onTabChanged),
            ],
          ),
          const SizedBox(height: 8),
          if (tab == 1) _YearCalendarView() else _MonthCalendarView(),
        ],
      ),
    );
  }
}

class _CalendarTabSwitcher extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onChanged;
  const _CalendarTabSwitcher({required this.tab, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CalendarTabButton(
          text: '月別',
          selected: tab == 0,
          onTap: () => onChanged(0),
        ),
        const SizedBox(width: 6),
        _CalendarTabButton(
          text: '年別',
          selected: tab == 1,
          onTap: () => onChanged(1),
        ),
      ],
    );
  }
}

class _CalendarTabButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _CalendarTabButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1976D2) : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// 年别视图
class _YearCalendarView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 示例数据
    final months = [
      ['1月', '+45K', '+1.2%', true],
      ['2月', '+32K', '+2.1%', true],
      ['3月', '−18K', '−1.2%', false],
      ['4月', '+67K', '+4.5%', true],
      ['5月', '+28K', '+1.8%', true],
      ['6月', '+51K', '+3.4%', true],
      ['7月', '−22K', '−1.4%', false],
      ['8月', '+39K', '+2.6%', true],
      ['9月', '+44K', '+2.9%', true],
      ['10月', '+35K', '+2.3%', true],
      ['11月', '+23K', '+1.5%', true],
      ['12月', '+0K', '+0%', true],
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: months.map((m) {
        final isProfit = m[3] as bool;
        return Container(
          width: 90,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isProfit
                ? const Color(0xFF43A047).withOpacity(0.2) // Darker green bg
                : const Color(0xFFE53935).withOpacity(0.2), // Darker red bg
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                m[0] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white, // White text
                ),
              ),
              Text(
                m[1] as String,
                style: TextStyle(
                  color: isProfit
                      ? const Color(0xFF43A047)
                      : const Color(0xFFE53935),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                m[2] as String,
                style: TextStyle(
                  color: isProfit
                      ? const Color(0xFF43A047)
                      : const Color(0xFFE53935),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// 月别视图
class _MonthCalendarView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 示例数据
    final days = [
      [1, '+15K', '+1.2%', true],
      [2, '−8K', '−0.6%', false],
      [3, '+22K', '+1.7%', true],
      [4, '+5K', '+0.4%', true],
      [5, '−12K', '−0.9%', false],
      [8, '+8K', '+0.6%', true],
      [10, '−5K', '−0.4%', false],
      [15, '+18K', '+1.3%', true],
      [20, '+3K', '+0.2%', true],
      [25, '−10K', '−0.7%', false],
      [29, '+44K', '+2.9%', true],
    ];
    return Column(
      children: [
        Row(
          children: const [
            Expanded(
              child: Center(
                child: Text('日',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('月',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('火',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('水',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('木',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('金',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            ),
            Expanded(
              child: Center(
                child: Text('土',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: days.map((d) {
            final isProfit = d[3] as bool;
            return Container(
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isProfit
                    ? AppColors.appUpGreen.withOpacity(0.2)
                    : AppColors.appDownRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '${d[0]}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    d[1] as String,
                    style: TextStyle(
                      color: isProfit
                          ? AppColors.appUpGreen
                          : AppColors.appDownRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    d[2] as String,
                    style: TextStyle(
                      color: isProfit
                          ? AppColors.appUpGreen
                          : AppColors.appDownRed,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
