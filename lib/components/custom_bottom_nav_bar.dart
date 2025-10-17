import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:motor/motor.dart';
import 'package:money_nest_app/presentation/resources/app_texts.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final List<IconData> icons;
  final List<String> labels;
  final ValueChanged<int> onTap;
  final bool isDark;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.icons,
    required this.labels,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  bool _isPressing = false;
  double? _pressX; // 手指目标x
  double? _magnifierX; // 动画中的实际x
  late AnimationController _moveController;
  late Animation<double> _moveAnim;
  double? _downX; // 新增：记录按下时的x

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260), // 由260改为680
    );
    _moveAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _moveController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != _currentIndex) {
      setState(() {
        _currentIndex = widget.currentIndex;
      });
      // 新增：自动动画到新tab
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final barWidth = context.size?.width ?? 0;
        if (barWidth > 0) {
          final itemWidth = barWidth / widget.icons.length;
          final targetX = _currentIndex * itemWidth + itemWidth / 2;
          _animateMagnifierTo(targetX);
        }
      });
    }
  }

  void _animateMagnifierTo(double targetX, {VoidCallback? onCompleted}) {
    if (_magnifierX == null) {
      _magnifierX = targetX;
      _moveAnim = AlwaysStoppedAnimation(targetX);
      if (onCompleted != null) onCompleted();
      return;
    }
    _moveController.stop();
    _moveAnim = Tween<double>(begin: _magnifierX!, end: targetX).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeOutCubic),
    );
    _moveController.forward(from: 0).whenCompleteOrCancel(() {
      _magnifierX = targetX;
      if (onCompleted != null) onCompleted();
    });
  }

  void _onPanDown(DragDownDetails details, double barWidth) {
    setState(() {
      _isPressing = true;
      _downX = details.localPosition.dx; // 记录按下的x
      // 计算按下的是哪个tab
      final itemWidth = barWidth / widget.icons.length;
      final tabIndex = (_downX! / itemWidth).floor().clamp(
        0,
        widget.icons.length - 1,
      );
      _pressX = tabIndex * itemWidth + itemWidth / 2;
    });
    _animateMagnifierTo(_pressX!);
  }

  void _onPanUpdate(DragUpdateDetails details, double barWidth) {
    setState(() {
      _pressX = details.localPosition.dx.clamp(0.0, barWidth);
    });
    _animateMagnifierTo(_pressX!);
  }

  void _onPanEnd(double barWidth) {
    final itemWidth = barWidth / widget.icons.length;
    double? targetX = _pressX;
    int tabIndex;

    if (_downX != null &&
        (_pressX == null ||
            (_pressX! - (_currentIndex * itemWidth + itemWidth / 2)).abs() <
                2)) {
      tabIndex = (_downX! / itemWidth).floor().clamp(
        0,
        widget.icons.length - 1,
      );
      targetX = tabIndex * itemWidth + itemWidth / 2;
    } else if (_pressX != null) {
      tabIndex = (_pressX! / itemWidth).floor().clamp(
        0,
        widget.icons.length - 1,
      );
      targetX = tabIndex * itemWidth + itemWidth / 2;
    } else {
      tabIndex = _currentIndex;
      targetX = _currentIndex * itemWidth + itemWidth / 2;
    }

    setState(() {
      _pressX = null;
      _downX = null;
      _currentIndex = tabIndex;
      // 不在这里设 _isPressing = false
    });
    widget.onTap(tabIndex);
    _animateMagnifierTo(
      targetX!,
      onCompleted: () {
        setState(() {
          _isPressing = false;
        });
      },
    );
  }

  void _onPanCancel() {
    setState(() {
      _isPressing = false;
      _pressX = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final icons = widget.icons;
    final labels = widget.labels;
    const double barHeight = 64;
    const double barRadius = 40;
    const double indicatorWidth = 70;
    const double indicatorHeight = 55;
    const double indicatorRadius = 32;

    // Build a reusable LiquidGlassSettings for the bar/indicator
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final glassSettings = LiquidGlassSettings(
      refractiveIndex: 1.2,
      thickness: 28,
      blur: 8,
      saturation: 1.2,
      blend: 8,
      lightIntensity: isDark ? .7 : 1,
      ambientStrength: isDark ? .2 : .5,
      lightAngle: math.pi / 4,
      glassColor: (isDark ? Colors.black : Colors.white).withOpacity(
        isDark ? 0.12 : 0.9,
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 32),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth;
          final itemWidth = barWidth / icons.length;

          // 默认放大镜位置
          final defaultMagnifierX = _currentIndex * itemWidth + itemWidth / 2;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (details) => _onPanDown(details, barWidth),
            onPanUpdate: (details) => _onPanUpdate(details, barWidth),
            onPanEnd: (_) => _onPanEnd(barWidth),
            onPanCancel: _onPanCancel,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(barRadius),
              child: LiquidGlassLayer(
                // API 版本差异：删除不存在的 named parameter `settings`.
                // 若需自定义 settings，请把 glassSettings 传给内部的 LiquidGlass/LiquidGlass.inLayer。
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 520),
                  height: barHeight,
                  decoration: BoxDecoration(
                    // keep translucent look but rely on LiquidGlass for glass effect
                    color: (isDark ? Colors.black : Colors.white).withOpacity(
                      0.06,
                    ),
                    borderRadius: BorderRadius.circular(barRadius),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.04),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 18,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // 放大镜 (indicator) 使用 LiquidGlass 以保证在 iOS 上也尝试渲染
                      AnimatedBuilder(
                        animation: _moveAnim,
                        builder: (context, child) {
                          double magnifierLeft =
                              (_moveAnim.value == 0 && !_isPressing)
                              ? defaultMagnifierX - indicatorWidth / 2
                              : _moveAnim.value - indicatorWidth / 2;
                          final double maxLeft = (barWidth - indicatorWidth)
                              .clamp(0.0, double.infinity);
                          magnifierLeft = magnifierLeft.clamp(0.0, maxLeft);

                          final bool pressing = _isPressing;
                          final double width = pressing
                              ? indicatorWidth + 15
                              : indicatorWidth;
                          final double height = pressing
                              ? indicatorHeight + 15
                              : indicatorHeight;
                          final double radius = pressing
                              ? indicatorRadius + 6
                              : indicatorRadius;
                          final double opacity = pressing ? 0.18 : 0.32;
                          final double borderOpacity = pressing ? 0.22 : 0.38;
                          final double blurSigma = pressing ? 10 : 4;

                          return Positioned(
                            left: magnifierLeft - (width - indicatorWidth) / 2,
                            top: -(height - barHeight) / 2,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 520),
                              curve: Curves.easeOutCubic,
                              width: width,
                              height: height,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(radius),
                                border: Border.all(
                                  color: Colors.white.withOpacity(
                                    borderOpacity,
                                  ),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.18),
                                    blurRadius: 0,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 0),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.10),
                                    blurRadius: 18,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(radius),
                                child: LiquidGlass.inLayer(
                                  // a lightweight glass child for the indicator
                                  // `settings` parameter removed to match package API;
                                  // adjust visuals via parent decoration or package-supported parameters.
                                  shape: const LiquidRoundedSuperellipse(
                                    borderRadius: Radius.circular(64),
                                  ),
                                  child: Container(color: Colors.transparent),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // 菜单按钮（图标行）
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(icons.length, (index) {
                          final selected =
                              !_isPressing && _currentIndex == index;
                          return Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              height: barHeight,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    icons[index],
                                    color: selected
                                        ? const Color(0xFF1976D2)
                                        : Colors.black87,
                                    size: 24,
                                  ),
                                  Text(
                                    labels[index],
                                    style: TextStyle(
                                      color: selected
                                          ? const Color(0xFF1976D2)
                                          : Colors.black87,
                                      fontWeight: FontWeight.normal,
                                      fontSize: AppTexts.fontSizeSmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MagnifierIndicator extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const _MagnifierIndicator({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.32),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Colors.white.withOpacity(0.38), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.18),
              blurRadius: 0,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 18,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
