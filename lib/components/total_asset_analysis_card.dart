import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_nest_app/components/glass_panel.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';

class TotalAssetAnalysisCard extends StatefulWidget {
  final VoidCallback? onAssetAnalysisTap;
  final bool isAssetAnalysisBtnDisplay;

  const TotalAssetAnalysisCard({
    super.key,
    this.onAssetAnalysisTap,
    this.isAssetAnalysisBtnDisplay = true,
  });
  @override
  TotalAssetAnalysisCardState createState() => TotalAssetAnalysisCardState();
}

class TotalAssetAnalysisCardState extends State<TotalAssetAnalysisCard> {
  int _overviewTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和tab按钮在同一行
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '資産総覧',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                // 品种下拉框
                Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _overviewTabIndex,
                      borderRadius: BorderRadius.circular(12),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                      dropdownColor: const Color(0xFF2C2C2E),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('カテゴリ')),
                        DropdownMenuItem(value: 1, child: Text('日本株')),
                        DropdownMenuItem(value: 2, child: Text('米国株')),
                        DropdownMenuItem(value: 3, child: Text('現金')),
                        DropdownMenuItem(value: 4, child: Text('その他')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _overviewTabIndex = v);
                      },
                    ),
                  ),
                ),
                if (widget.isAssetAnalysisBtnDisplay) ...[
                  const SizedBox(width: 10),
                  // 分析按钮
                  GestureDetector(
                    onTap: () => widget.onAssetAnalysisTap?.call(),
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: _overviewTabIndex == 2
                            ? const Color(0xFF7ED36D) // 选中时绿色背景
                            : Colors.transparent, // 未选中时透明
                        borderRadius: BorderRadius.circular(12),
                        // 无边框
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.bar_chart,
                            color: const Color(0xFF4385F5), // 蓝色
                            size: 22,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '分析',
                            style: TextStyle(
                              color: const Color(0xFF4385F5), // 蓝色
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            // 环形图
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: const Color(0xFF4CAF50),
                      value: 46.9,
                      title: '',
                      radius: 40,
                    ),
                    PieChartSectionData(
                      color: const Color(0xFF2196F3),
                      value: 28.1,
                      title: '',
                      radius: 40,
                    ),
                    PieChartSectionData(
                      color: const Color(0xFFFF9800),
                      value: 15.6,
                      title: '',
                      radius: 40,
                    ),
                    PieChartSectionData(
                      color: const Color(0xFF9C27B0),
                      value: 9.4,
                      title: '',
                      radius: 40,
                    ),
                  ],
                  centerSpaceRadius: 50,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 图例部分，每行两个
            _LegendRow(
              left: const _LegendDot(
                color: Color(0xFF4CAF50),
                label: '日本株',
                percent: '46.9%',
              ),
              right: const _LegendDot(
                color: Color(0xFF2196F3),
                label: '米国株',
                percent: '28.1%',
                alignRight: true,
              ),
            ),
            const SizedBox(height: 4),
            _LegendRow(
              left: const _LegendDot(
                color: Color(0xFFFF9800),
                label: '現金',
                percent: '15.6%',
              ),
              right: const _LegendDot(
                color: Color(0xFF9C27B0),
                label: 'その他',
                percent: '9.4%',
                alignRight: true,
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
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.white)),
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
