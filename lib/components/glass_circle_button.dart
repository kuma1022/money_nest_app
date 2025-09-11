import 'dart:ui';
import 'package:flutter/material.dart';

// 毛玻璃水滴按钮
class GlassCircleButton extends StatelessWidget {
  final Widget child;
  final double size;
  final VoidCallback? onTap;

  const GlassCircleButton({
    required this.child,
    this.size = 56,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(color: Colors.white.withValues(alpha: 0.13)),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(child: child),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
