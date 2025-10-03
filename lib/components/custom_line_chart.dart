import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/presentation/resources/app_texts.dart';
import 'package:money_nest_app/util/app_utils.dart';

class LineChartSample12 extends StatefulWidget {
  const LineChartSample12({
    super.key,
    required this.datas,
    required this.currencyCode,
    this.animationValue = 1.0, // 新增参数，默认为1.0（全显示）
  });
  final List<Map<String, dynamic>> datas;
  final String currencyCode;
  final double animationValue; // 0.0~1.0

  @override
  State<LineChartSample12> createState() => _LineChartSample12State();
}

class _LineChartSample12State extends State<LineChartSample12> {
  List<LineBarSpot>? _touchedSpots;

  @override
  Widget build(BuildContext context) {
    const leftReservedSize = 52.0;
    final TransformationController _transformationController =
        TransformationController();
    bool _isPanEnabled = true;
    bool _isScaleEnabled = true;

    // 获取所有数据的最小值和最大值
    final allDataList = widget.datas
        .expand((data) => (data['dataList'] as List<(DateTime, double)>))
        .toList();
    final minY = allDataList.map((e) => e.$2).reduce((a, b) => a < b ? a : b);
    final maxY = allDataList.map((e) => e.$2).reduce((a, b) => a > b ? a : b);

    // 关键：动画时补齐spots，未到动画进度的点用double.nan
    List<LineChartBarData> lineBarsData = widget.datas.map((data) {
      final dataList = data['dataList'] as List<(DateTime, double)>;
      final fullLength = dataList.length;
      int showCount = (fullLength * widget.animationValue)
          .clamp(1, fullLength)
          .toInt();
      final spots = List<FlSpot>.generate(
        fullLength,
        (i) => i < showCount
            ? FlSpot(i.toDouble(), dataList[i].$2)
            : FlSpot(i.toDouble(), double.nan), // 用 double.nan 让 fl_chart 断线
      );
      return LineChartBarData(
        spots: spots,
        dotData: const FlDotData(show: false),
        color: data['lineColor'] as Color,
        barWidth: 1,
        shadow: Shadow(color: data['lineColor'] as Color, blurRadius: 2),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              (data['lineColor'] as Color).withAlpha((0.2 * 255).toInt()),
              (data['lineColor'] as Color).withAlpha(0),
            ],
            stops: const [0.5, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
    }).toList();

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.4,
          child: Padding(
            padding: const EdgeInsets.only(top: 0.0, right: 18.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 计算 tooltip 的 left
                double? tooltipLeft;
                double indicatorOffset = 60; // tooltip宽度一半
                const double tooltipWidth = 120;
                if (_touchedSpots != null && _touchedSpots!.isNotEmpty) {
                  final spot = _touchedSpots!.first;
                  final touchX = spot.x;
                  final chartWidth = constraints.maxWidth;
                  final dataList =
                      widget.datas[spot.barIndex]['dataList']
                          as List<(DateTime, double)>;
                  final count = dataList.length;
                  final dx = count > 1 ? chartWidth / (count - 1) : 0;
                  double left = dx * touchX - tooltipWidth / 2;
                  if (left < 0) {
                    indicatorOffset = dx * touchX;
                    left = 0;
                  } else if (left + tooltipWidth > chartWidth) {
                    indicatorOffset = tooltipWidth - (chartWidth - dx * touchX);
                    left = chartWidth - tooltipWidth;
                  } else {
                    indicatorOffset = tooltipWidth / 2;
                  }
                  tooltipLeft = left;
                }

                return Stack(
                  children: [
                    LineChart(
                      LineChartData(
                        minX: 0.0,
                        maxX: (widget.datas.last['dataList'].length - 1)
                            .toDouble(), // 用最后一个数据的长度
                        minY: minY, // 固定最小值
                        maxY: maxY, // 固定最大值
                        lineBarsData: lineBarsData,
                        lineTouchData: LineTouchData(
                          touchSpotThreshold: 5,
                          getTouchLineStart: (_, __) => -double.infinity,
                          getTouchLineEnd: (_, __) => double.infinity,
                          getTouchedSpotIndicator:
                              (
                                LineChartBarData barData,
                                List<int> spotIndexes,
                              ) {
                                return spotIndexes.map((spotIndex) {
                                  return TouchedSpotIndicatorData(
                                    const FlLine(
                                      color: AppColors.appChartLightBlue,
                                      strokeWidth: 1.5,
                                      dashArray: [8, 2],
                                    ),
                                    FlDotData(
                                      show: true,
                                      getDotPainter:
                                          (spot, percent, barData, index) {
                                            return FlDotCirclePainter(
                                              radius: 6,
                                              color: AppColors.appGreen,
                                              strokeWidth: 0,
                                              strokeColor: AppColors.appGreen,
                                            );
                                          },
                                    ),
                                  );
                                }).toList();
                              },
                          touchTooltipData: LineTouchTooltipData(
                            showOnTopOfTheChartBoxArea: false,
                            getTooltipItems: (touchedBarSpots) =>
                                List.filled(touchedBarSpots.length, null),
                            getTooltipColor: (barSpot) => Colors.transparent,
                          ),
                          touchCallback: (event, response) {
                            if (event is FlLongPressEnd ||
                                event is FlPanEndEvent ||
                                event is FlTapUpEvent) {
                              setState(() {
                                _touchedSpots = null;
                              });
                            } else {
                              setState(() {
                                _touchedSpots =
                                    response?.lineBarSpots?.isNotEmpty == true
                                    ? response!.lineBarSpots
                                    : null;
                              });
                            }
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: const AxisTitles(
                            drawBelowEverything: true,
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: leftReservedSize,
                              maxIncluded: false,
                              minIncluded: false,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 38,
                              maxIncluded: false,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final dataList =
                                    widget.datas.last['dataList']
                                        as List<(DateTime, double)>;
                                final date =
                                    dataList.isNotEmpty &&
                                        value.toInt() < dataList.length
                                    ? dataList[value.toInt()].$1
                                    : DateTime.now();
                                return SideTitleWidget(
                                  meta: meta,
                                  child: Transform.rotate(
                                    angle: -45 * 3.14 / 180,
                                    child: Text(
                                      '${date.year}/${date.month}/${date.day}',
                                      style: const TextStyle(
                                        color: AppColors.appGrey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      duration: Duration.zero, // 必须为 zero，防止缩放动画
                    ),
                    if (_touchedSpots != null &&
                        _touchedSpots!.isNotEmpty &&
                        tooltipLeft != null)
                      Builder(
                        builder: (context) {
                          // 判断是否在上方
                          final spot = _touchedSpots!.first;
                          final chartMaxY = widget.datas
                              .expand(
                                (d) =>
                                    (d['dataList'] as List<(DateTime, double)>)
                                        .map((e) => e.$2),
                              )
                              .reduce((a, b) => a > b ? a : b);
                          final isTop = spot.y > chartMaxY * 0.7; // 0.7 可根据实际调整

                          return Positioned(
                            top: isTop ? null : 8,
                            bottom: isTop ? 8 : null,
                            left: tooltipLeft,
                            width: 120,
                            child: Material(
                              color: Colors.transparent,
                              child: _buildTooltipContent(),
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // 工具方法
  Widget _buildTooltipContent() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.7),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: _touchedSpots!.map((spot) {
        final barIndex = spot.barIndex;
        final dataList =
            widget.datas[barIndex]['dataList'] as List<(DateTime, double)>;
        final xIdx = spot.x.toInt();
        final date = (xIdx >= 0 && xIdx < dataList.length)
            ? dataList[xIdx].$1
            : DateTime.now();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: RichText(
            text: TextSpan(
              text: '',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text:
                      '${widget.datas[barIndex]['label']} '
                      '${date.year}/${date.month}/${date.day}',
                  style: TextStyle(
                    color:
                        widget.datas[barIndex]['tooltipText1Color'] ??
                        Colors.white,
                    fontSize: AppTexts.fontSizeTiny,
                  ),
                ),
                TextSpan(
                  text:
                      '\n${AppUtils().formatMoney(spot.y, widget.currencyCode)}',
                  style: TextStyle(
                    color:
                        widget.datas[barIndex]['tooltipText2Color'] ??
                        AppColors.appGreen,
                    fontSize: AppTexts.fontSizeTiny,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ),
  );

  Widget _buildTooltipTriangle(double indicatorOffset) => SizedBox(
    height: 6,
    width: 120,
    child: Stack(
      children: [
        Positioned(
          left: indicatorOffset - 6,
          child: CustomPaint(
            size: const Size(12, 6),
            painter: _TrianglePainter(),
          ),
        ),
      ],
    ),
  );
}

class _ChartTitle extends StatelessWidget {
  const _ChartTitle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 14),
        Text(
          'Bitcoin Price History',
          style: TextStyle(
            color: AppColors.contentColorYellow,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          '2023/12/19 - 2024/12/17',
          style: TextStyle(
            color: AppColors.contentColorGreen,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 14),
      ],
    );
  }
}

class _TransformationButtons extends StatelessWidget {
  const _TransformationButtons({required this.controller});

  final TransformationController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Tooltip(
          message: 'Zoom in',
          child: IconButton(
            icon: const Icon(Icons.add, size: 16),
            onPressed: _transformationZoomIn,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: 'Move left',
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                onPressed: _transformationMoveLeft,
              ),
            ),
            Tooltip(
              message: 'Reset zoom',
              child: IconButton(
                icon: const Icon(Icons.refresh, size: 16),
                onPressed: _transformationReset,
              ),
            ),
            Tooltip(
              message: 'Move right',
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: _transformationMoveRight,
              ),
            ),
          ],
        ),
        Tooltip(
          message: 'Zoom out',
          child: IconButton(
            icon: const Icon(Icons.minimize, size: 16),
            onPressed: _transformationZoomOut,
          ),
        ),
      ],
    );
  }

  void _transformationReset() {
    controller.value = Matrix4.identity();
  }

  void _transformationZoomIn() {
    controller.value *= Matrix4.diagonal3Values(1.1, 1.1, 1);
  }

  void _transformationMoveLeft() {
    controller.value *= Matrix4.translationValues(20, 0, 0);
  }

  void _transformationMoveRight() {
    controller.value *= Matrix4.translationValues(-20, 0, 0);
  }

  void _transformationZoomOut() {
    controller.value *= Matrix4.diagonal3Values(0.9, 0.9, 1);
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
