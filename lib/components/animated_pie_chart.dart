import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedPieChart extends StatefulWidget {
  final List<PieSection> sections;
  final double size;
  final Duration duration;
  final double sectionsSpace;
  final double centerSpaceRadius;
  final List<String>? titles;
  final List<Color>? legendColors;
  final List<String>? legendLabels;

  const AnimatedPieChart({
    super.key,
    required this.sections,
    this.size = 200,
    this.duration = const Duration(seconds: 1),
    this.sectionsSpace = 3,
    this.centerSpaceRadius = 40,
    this.titles,
    this.legendColors,
    this.legendLabels,
  });

  @override
  State<AnimatedPieChart> createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<AnimatedPieChart>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _touchController;
  late Animation<double> _touchAnimation;
  int? touchedIndex;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();
    _touchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 250),
    );
    _touchAnimation = Tween<double>(
      begin: 1.0,
      end: 1.12,
    ).animate(CurvedAnimation(parent: _touchController, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant AnimatedPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sections != widget.sections) {
      _mainController.reset();
      _mainController.forward();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _touchController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset local = box.globalToLocal(details.globalPosition);
    final int? index = PieChartPainter.hitTestSection(
      local,
      widget.sections,
      widget.size,
      widget.centerSpaceRadius,
    );
    if (index != null) {
      setState(() {
        touchedIndex = index;
      });
      _touchController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _touchController.reverse();
    setState(() {
      touchedIndex = null;
    });
  }

  void _onTapCancel() {
    _touchController.reverse();
    setState(() {
      touchedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: AnimatedBuilder(
              animation: Listenable.merge([_mainController, _touchController]),
              builder: (context, child) {
                return CustomPaint(
                  painter: PieChartPainter(
                    sections: widget.sections,
                    progress: _mainController.value,
                    sectionsSpace: widget.sectionsSpace,
                    centerSpaceRadius: widget.centerSpaceRadius,
                    touchedIndex: touchedIndex,
                    touchScale: _touchAnimation.value,
                    titles: widget.titles,
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.legendColors != null && widget.legendLabels != null)
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.legendColors!.length, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: widget.legendColors![i],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.legendLabels![i],
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class PieSection {
  final double value;
  final Color color;
  final String? title;

  PieSection({required this.value, required this.color, this.title});
}

class PieChartPainter extends CustomPainter {
  final List<PieSection> sections;
  final double progress; // 0.0 ~ 1.0
  final double sectionsSpace;
  final double centerSpaceRadius;
  final int? touchedIndex;
  final double touchScale;
  final List<String>? titles;

  PieChartPainter({
    required this.sections,
    required this.progress,
    this.sectionsSpace = 3,
    this.centerSpaceRadius = 40,
    this.touchedIndex,
    this.touchScale = 1.0,
    this.titles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double total = sections.fold(0, (sum, s) => sum + s.value);
    double startAngle = -pi / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = centerSpaceRadius;
    final ringWidth = outerRadius - innerRadius;

    // 计算每个扇区的间隔角度
    final gapAngle = (sectionsSpace / outerRadius);

    double sweeped = 0;
    for (int i = 0; i < sections.length; i++) {
      final section = sections[i];
      final sweepAngle = (section.value / total) * 2 * pi;
      final isTouched = i == touchedIndex;
      final scale = isTouched ? touchScale : 1.0;
      final radius = outerRadius * scale;

      // 只画到当前动画进度
      double drawAngle;
      if (sweeped + sweepAngle > 2 * pi * progress) {
        drawAngle = max(0, 2 * pi * progress - sweeped);
      } else {
        drawAngle = sweepAngle;
      }
      if (drawAngle > 0) {
        final paint = Paint()
          ..color = section.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringWidth
          ..strokeCap = StrokeCap.butt;
        final arcRect = Rect.fromCircle(
          center: center,
          radius: (radius + innerRadius) / 2,
        );
        // 关键：每个扇区两边都留出gapAngle/2
        final arcStart = startAngle + gapAngle / 2;
        final arcSweep = max(0, drawAngle - gapAngle);
        canvas.drawArc(arcRect, arcStart, arcSweep.toDouble(), false, paint);

        // 扇区标题
        if (titles != null && arcSweep > 0.2) {
          final labelAngle = arcStart + arcSweep / 2;
          final labelRadius = (radius + innerRadius) / 2;
          final labelOffset = Offset(
            center.dx + cos(labelAngle) * labelRadius * 0.7,
            center.dy + sin(labelAngle) * labelRadius * 0.7,
          );
          final textPainter = TextPainter(
            text: TextSpan(
              text: titles![i],
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          textPainter.paint(
            canvas,
            labelOffset - Offset(textPainter.width / 2, textPainter.height / 2),
          );
        }
      }
      startAngle += sweepAngle;
      sweeped += sweepAngle;
      if (sweeped >= 2 * pi * progress) break;
    }

    // 画中心空心圆
    if (centerSpaceRadius > 0) {
      final paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, innerRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.sections != sections ||
      oldDelegate.touchedIndex != touchedIndex ||
      oldDelegate.touchScale != touchScale;

  /// 命中测试：判断点击点属于哪个扇区
  static int? hitTestSection(
    Offset local,
    List<PieSection> sections,
    double size,
    double centerSpaceRadius,
  ) {
    final center = Offset(size / 2, size / 2);
    final dx = local.dx - center.dx;
    final dy = local.dy - center.dy;
    final distance = sqrt(dx * dx + dy * dy);
    if (distance < centerSpaceRadius || distance > size / 2) return null;

    double angle = atan2(dy, dx);
    if (angle < -pi / 2) angle += 2 * pi;
    angle += pi / 2;

    double total = sections.fold(0, (sum, s) => sum + s.value);
    double start = 0;
    for (int i = 0; i < sections.length; i++) {
      final sweep = (sections[i].value / total) * 2 * pi;
      if (angle >= start && angle < start + sweep) {
        return i;
      }
      start += sweep;
    }
    return null;
  }
}

class _ArcInfo {
  final Color color;
  final double startAngle;
  final double sweepAngle;
  final double radius;
  final int index;

  _ArcInfo({
    required this.color,
    required this.startAngle,
    required this.sweepAngle,
    required this.radius,
    required this.index,
  });
}
