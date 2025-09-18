import 'dart:ui';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
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
    }
  }

  void _animateMagnifierTo(double targetX) {
    if (_magnifierX == null) {
      _magnifierX = targetX;
      _moveAnim = AlwaysStoppedAnimation(targetX);
      return;
    }
    _moveController.stop();
    _moveAnim = Tween<double>(begin: _magnifierX!, end: targetX).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeOutCubic),
    );
    _moveController.forward(from: 0);
    _magnifierX = targetX;
  }

  void _onPanDown(DragDownDetails details, double barWidth) {
    setState(() {
      _isPressing = true;
      _pressX = details.localPosition.dx.clamp(0.0, barWidth);
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
    if (_pressX == null) {
      setState(() {
        _isPressing = false;
        _pressX = null;
      });
      return;
    }
    final itemWidth = barWidth / widget.icons.length;
    final magnifierCenter = _pressX!;
    int tabIndex = (magnifierCenter / itemWidth).floor().clamp(
      0,
      widget.icons.length - 1,
    );
    setState(() {
      _isPressing = false;
      _pressX = null;
      _currentIndex = tabIndex;
    });
    widget.onTap(tabIndex);
    // 放大镜动画直接跳到目标tab
    final targetX = tabIndex * itemWidth + itemWidth / 2;
    _animateMagnifierTo(targetX);
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 32),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth;
          final itemWidth = barWidth / icons.length;

          // 非按压时，放大镜在选中tab正中
          final defaultMagnifierX = _currentIndex * itemWidth + itemWidth / 2;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanDown: (details) => _onPanDown(details, barWidth),
            onPanUpdate: (details) => _onPanUpdate(details, barWidth),
            onPanEnd: (_) => _onPanEnd(barWidth),
            onPanCancel: _onPanCancel,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(barRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
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
                      // 放大镜
                      AnimatedBuilder(
                        animation: _moveAnim,
                        builder: (context, child) {
                          double magnifierLeft;
                          if (_isPressing && _pressX != null) {
                            // 动画跟随手指
                            magnifierLeft =
                                _moveAnim.value - indicatorWidth / 2;
                          } else {
                            // 非按压时，放大镜在选中tab正中
                            magnifierLeft =
                                defaultMagnifierX - indicatorWidth / 2;
                          }
                          // 边界限制
                          magnifierLeft = magnifierLeft.clamp(
                            0.0,
                            barWidth - indicatorWidth,
                          );
                          return Positioned(
                            left: magnifierLeft,
                            top: -(indicatorHeight - barHeight) / 2,
                            child: _MagnifierIndicator(
                              width: indicatorWidth,
                              height: indicatorHeight,
                              radius: indicatorRadius,
                            ),
                          );
                        },
                      ),
                      // 菜单按钮
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
                                  //const SizedBox(height: 6),
                                  Icon(
                                    icons[index],
                                    color: selected
                                        ? const Color(0xFF1976D2)
                                        : Colors.black87,
                                    size: 24,
                                  ),
                                  //const SizedBox(height: 2),
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
