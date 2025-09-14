import 'package:flutter/material.dart';

class CardSection extends StatelessWidget {
  final Widget child;
  const CardSection({required this.child, super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20), // padding略大更像设计稿
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22), // 更圆润
        border: Border.all(color: const Color(0xFFE5E6EA), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // 柔和黑色阴影
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
