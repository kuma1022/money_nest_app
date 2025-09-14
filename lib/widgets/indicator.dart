import 'package:flutter/material.dart';
import 'package:money_nest_app/presentation/resources/app_resources.dart';

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    required this.textStyle,
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: textStyle),
      ],
    );
  }
}
