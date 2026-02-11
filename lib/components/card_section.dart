import 'package:flutter/material.dart';

class CardSection extends StatelessWidget {
  final Widget child;
  const CardSection({required this.child, super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(22),
      ),
      child: child,
    );
  }
}
