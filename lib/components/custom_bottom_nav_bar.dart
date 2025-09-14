import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
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
      duration: const Duration(milliseconds: 320),
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
        widget.onTap(_targetIndex);
      }
    });
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isAnimating && widget.currentIndex != _targetIndex) {
      setState(() {
        _prevIndex = widget.currentIndex;
        _targetIndex = widget.currentIndex;
      });
    }
  }

  // 1. 动画只做“收缩”或“展开”单向动画
  void _onTap(int index) {
    if (_isAnimating || index == _targetIndex) return;
    setState(() {
      _prevIndex = widget.currentIndex;
      _targetIndex = index;
      _isAnimating = true;
    });
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final icons = widget.icons;
    final labels = widget.labels;
    final int itemCount = icons.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 18),
      child: ClipRRect(
        //borderRadius: BorderRadius.circular(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 模糊背景
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: SizedBox(
                height: 72,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double totalWidth = constraints.maxWidth;
                    final int itemCount = icons.length;
                    const double minItemWidth = 56;
                    double maxItemWidth = 140;
                    const double itemHeight = 56;
                    double gap = 4;

                    // 动态调整maxItemWidth
                    double maxPossible =
                        (totalWidth -
                        gap * (itemCount - 1) -
                        minItemWidth * (itemCount - 1));
                    if (maxPossible < minItemWidth) maxPossible = minItemWidth;
                    if (maxItemWidth > maxPossible) maxItemWidth = maxPossible;

                    List<double> widths = List.filled(itemCount, minItemWidth);

                    if (_isAnimating) {
                      widths[_prevIndex] =
                          minItemWidth +
                          (maxItemWidth - minItemWidth) *
                              (1 - _animation.value);
                    } else {
                      widths[widget.currentIndex] = maxItemWidth;
                    }

                    // gap不取整，直接用double
                    double usedWidth = widths.reduce((a, b) => a + b);
                    double totalGap = totalWidth - usedWidth;
                    gap = (itemCount > 1)
                        ? (totalGap / (itemCount - 1)).clamp(0.0, 8.0)
                        : 0.0;

                    // 最后一个按钮宽度强制补齐
                    double widthSum = 0;
                    List<double> realWidths = [];
                    for (int i = 0; i < itemCount; i++) {
                      if (i < itemCount - 1) {
                        realWidths.add(widths[i]);
                        widthSum += widths[i];
                      } else {
                        // 最后一个
                        realWidths.add(
                          (totalWidth - widthSum - gap * (itemCount - 1)).clamp(
                            0.0,
                            double.infinity,
                          ),
                        );
                      }
                    }

                    // 字号插值
                    double minFontSize = 1;
                    double maxFontSize = AppTexts.fontSizeSmall;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(itemCount, (i) {
                        return Padding(
                          padding: EdgeInsets.only(left: i == 0 ? 0 : gap),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: minItemWidth,
                              end: realWidths[i],
                            ),
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeInOutCubic,
                            builder: (context, animatedWidth, child) {
                              final bool selected =
                                  animatedWidth > minItemWidth + 1;
                              double fontSize = minFontSize;
                              if (animatedWidth > minItemWidth + 1) {
                                fontSize =
                                    minFontSize +
                                    (maxFontSize - minFontSize) *
                                        ((animatedWidth - minItemWidth) /
                                                (maxItemWidth - minItemWidth))
                                            .clamp(0.0, 1.0);
                              }
                              return Container(
                                width: animatedWidth,
                                height: itemHeight,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: const Color(0xFFE5E6EA),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.10),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(28),
                                  onTap: () => _onTap(i),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        icons[i],
                                        color: selected
                                            ? Colors.black87
                                            : Colors.black54,
                                        size: 24,
                                      ),
                                      AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 220,
                                        ),
                                        child:
                                            selected &&
                                                fontSize > minFontSize + 1
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 6,
                                                ),
                                                child: Text(
                                                  labels[i],
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: fontSize,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
