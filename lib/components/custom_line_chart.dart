import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/util/app_utils.dart';

class LineChartSample12 extends StatelessWidget {
  const LineChartSample12({super.key, required this.priceHistory});
  final List<(DateTime, double)> priceHistory;

  @override
  Widget build(BuildContext context) {
    const leftReservedSize = 52.0;
    final TransformationController _transformationController =
        TransformationController();
    bool _isPanEnabled = true;
    bool _isScaleEnabled = true;
    return Column(
      children: [
        /*
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return width >= 380
                ? Row(
                    children: [
                      const SizedBox(width: leftReservedSize),
                      const _ChartTitle(),
                      const Spacer(),
                      Center(
                        child: _TransformationButtons(
                          controller: _transformationController,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      const _ChartTitle(),
                      const SizedBox(height: 16),
                      _TransformationButtons(
                        controller: _transformationController,
                      ),
                    ],
                  );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 16,
            children: [
              const Text('Pan'),
              Switch(
                value: _isPanEnabled,
                onChanged: (value) {
                  setState(() {
                    _isPanEnabled = value;
                  });
                },
              ),
              const Text('Scale'),
              Switch(
                value: _isScaleEnabled,
                onChanged: (value) {
                  setState(() {
                    _isScaleEnabled = value;
                  });
                },
              ),
            ],
          ),
        ),*/
        AspectRatio(
          aspectRatio: 1.4,
          child: Padding(
            padding: const EdgeInsets.only(top: 0.0, right: 18.0),
            child: LineChart(
              transformationConfig: FlTransformationConfig(
                scaleAxis: FlScaleAxis.horizontal,
                minScale: 1.0,
                maxScale: 25.0,
                panEnabled: _isPanEnabled,
                scaleEnabled: _isScaleEnabled,
                transformationController: _transformationController,
              ),
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: priceHistory.asMap().entries.map((e) {
                      final index = e.key;
                      final item = e.value;
                      final value = item.$2;
                      return FlSpot(index.toDouble(), value);
                    }).toList(),
                    dotData: const FlDotData(show: false),
                    color: AppColors.appGreen,
                    barWidth: 1,
                    shadow: const Shadow(
                      color: AppColors.appGreen,
                      blurRadius: 2,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.appGreen.withValues(alpha: 0.2),
                          AppColors.appGreen.withValues(alpha: 0.0),
                        ],
                        stops: const [0.5, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchSpotThreshold: 5,
                  getTouchLineStart: (_, __) => -double.infinity,
                  getTouchLineEnd: (_, __) => double.infinity,
                  getTouchedSpotIndicator:
                      (LineChartBarData barData, List<int> spotIndexes) {
                        return spotIndexes.map((spotIndex) {
                          return TouchedSpotIndicatorData(
                            const FlLine(
                              color: AppColors.appBlue,
                              strokeWidth: 1.5,
                              dashArray: [8, 2],
                            ),
                            FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
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
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final price = barSpot.y;
                        final date = priceHistory.isNotEmpty
                            ? priceHistory[barSpot.x.toInt()].$1
                            : DateTime.now();
                        return LineTooltipItem(
                          '',
                          const TextStyle(
                            color: AppColors.contentColorBlack,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '${date.year}/${date.month}/${date.day}',
                              style: TextStyle(
                                color: AppColors.appWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            TextSpan(
                              text: '\n${AppUtils().formatMoney(price, 'USD')}',
                              style: const TextStyle(
                                color: AppColors.appGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                    getTooltipColor: (LineBarSpot barSpot) =>
                        AppColors.contentColorBlack,
                  ),
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
                        final date = priceHistory.isNotEmpty
                            ? priceHistory[value.toInt()].$1
                            : DateTime.now();
                        return SideTitleWidget(
                          meta: meta,
                          child: Transform.rotate(
                            angle: -45 * 3.14 / 180,
                            child: Text(
                              '${date.month}/${date.day}',
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
              duration: Duration.zero,
            ),
          ),
        ),
      ],
    );
  }
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
