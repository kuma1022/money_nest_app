import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/presentation/resources/app_texts.dart';
import 'package:money_nest_app/widgets/indicator.dart';

class CustomPieChart extends StatefulWidget {
  final List<Map<String, dynamic>> sections; // 你的实际数据
  final Color emptyColor; // D的颜色

  const CustomPieChart({
    super.key,
    required this.sections,
    this.emptyColor = Colors.white,
  });

  @override
  State<StatefulWidget> createState() => CustomPieChartState();
}

class CustomPieChartState extends State<CustomPieChart>
    with SingleTickerProviderStateMixin {
  int touchedIndex = -1;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant CustomPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sections != widget.sections) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<PieChartSectionData> _animatedSections(double t) {
    double sum = 0;
    final animatedSections = widget.sections.asMap().entries.map((entry) {
      final i = entry.key;
      final s = entry.value;
      final target = s['value'] as double;
      final value = target * t;
      sum += value;
      final isTouched = i == touchedIndex;
      final fontSize = isTouched
          ? AppTexts.fontSizeLarge
          : AppTexts.fontSizeMedium;
      final radius = isTouched ? 60.0 : 50.0;
      final title = isTouched && value > 0.1 ? s['title'] as String : '';
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      return PieChartSectionData(
        color: s['color'],
        value: value,
        title: title,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    }).toList();

    // 剩余部分用白色D补足
    final remain = (100 - sum).clamp(0, 100);
    if (remain > 0.01) {
      animatedSections.add(
        PieChartSectionData(
          color: widget.emptyColor,
          value: remain.toDouble(),
          title: '',
          radius: 50,
          titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
        ),
      );
    }
    return animatedSections;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse
                              .touchedSection!
                              .touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 3,
                    centerSpaceRadius: 40,
                    sections: _animatedSections(_controller.value),
                  ),
                  swapAnimationDuration: Duration.zero, // 关闭fl_chart自带动画
                  swapAnimationCurve: Curves.linear,
                );
              },
            ),
          ),
          // legend/indicator...
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.sections.map((section) {
              return Indicator(
                color: section['color'],
                text: section['title'],
                isSquare: false,
                size: 10,
                textStyle: TextStyle(
                  fontSize: AppTexts.fontSizeMini,
                  fontWeight: FontWeight.normal,
                  color: AppColors.appDarkGrey,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
