import 'dart:ui';
import 'package:flutter/material.dart';

// 毛玻璃面板
class GlassPanel extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  const GlassPanel({
    required this.child,
    this.borderRadius = 24,
    this.margin,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // 局部背景虚化
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(color: Colors.transparent),
            ),
            // 更通透的毛玻璃面板
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.13), // 更透明
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.16), // 更透明
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.08),
                    blurRadius: 0,
                    spreadRadius: 2,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
