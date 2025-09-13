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
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _prevIndex;
  late int _targetIndex;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _prevIndex = widget.currentIndex;
    _targetIndex = widget.currentIndex;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _prevIndex = _targetIndex;
          _isAnimating = false;
        });
        widget.onTap(_targetIndex); // 动画结束后才通知父组件切换
      }
    });
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部切换tab时同步状态
    if (!_isAnimating && widget.currentIndex != _targetIndex) {
      setState(() {
        _prevIndex = widget.currentIndex;
        _targetIndex = widget.currentIndex;
      });
    }
  }

  void _onTap(int index) {
    if (_isAnimating || index == _targetIndex) return;
    setState(() {
      _prevIndex = _targetIndex;
      _targetIndex = index;
      _isAnimating = true;
    });
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final icons = widget.icons;
    final labels = widget.labels;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 18,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final double itemWidth =
                        constraints.maxWidth / icons.length;
                    const double indicatorWidth = 64;
                    const double indicatorHeight = 42;
                    const double barHeight = 60;

                    final double start =
                        _prevIndex * itemWidth +
                        (itemWidth - indicatorWidth) / 2;
                    final double end =
                        _targetIndex * itemWidth +
                        (itemWidth - indicatorWidth) / 2;
                    final double left =
                        start + (end - start) * _animation.value;

                    final double width = TweenSequence([
                      TweenSequenceItem(
                        tween: Tween<double>(
                          begin: indicatorWidth,
                          end: indicatorWidth + 56,
                        ).chain(CurveTween(curve: Curves.easeOut)),
                        weight: 60,
                      ),
                      TweenSequenceItem(
                        tween: Tween<double>(
                          begin: indicatorWidth + 56,
                          end: indicatorWidth,
                        ).chain(CurveTween(curve: Curves.easeIn)),
                        weight: 40,
                      ),
                    ]).transform(_animation.value);

                    final double radius = TweenSequence([
                      TweenSequenceItem(
                        tween: Tween<double>(
                          begin: 18,
                          end: 28,
                        ).chain(CurveTween(curve: Curves.easeOut)),
                        weight: 60,
                      ),
                      TweenSequenceItem(
                        tween: Tween<double>(
                          begin: 28,
                          end: 18,
                        ).chain(CurveTween(curve: Curves.easeIn)),
                        weight: 40,
                      ),
                    ]).transform(_animation.value);

                    // 动画期间保持旧的选中项
                    final int effectiveIndex = _isAnimating
                        ? _prevIndex
                        : widget.currentIndex;

                    return Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // 1. 水滴indicator
                        Positioned(
                          left: left - (width - indicatorWidth) / 2,
                          top: (barHeight - indicatorHeight) / 2 - 2,
                          child: Container(
                            width: width,
                            height: indicatorHeight,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(radius),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.10),
                                  blurRadius: 14,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // 2. 菜单按钮
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(icons.length, (index) {
                            final selected = effectiveIndex == index;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => _onTap(index),
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  alignment: Alignment.center,
                                  height: double.infinity,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 2),
                                      Icon(
                                        icons[index],
                                        color: selected
                                            ? Colors.black87
                                            : Colors.black54,
                                        size: 22,
                                      ),
                                      Text(
                                        labels[index],
                                        style: TextStyle(
                                          color: selected
                                              ? Colors.black87
                                              : Colors.black54,
                                          fontWeight: selected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: AppTexts.fontSizeSmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
