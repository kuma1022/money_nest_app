// 今日のサマリー行
import 'package:flutter/material.dart';

class SummaryRowStyled extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final Color bgColor;
  const SummaryRowStyled({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.bgColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
