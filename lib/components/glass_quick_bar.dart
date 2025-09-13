import 'package:flutter/material.dart';
import 'package:money_nest_app/components/card_section.dart';
import 'package:money_nest_app/components/glass_quick_bar_item.dart';

// 毛玻璃快捷操作栏
class GlassQuickBar extends StatelessWidget {
  final List<GlassQuickBarItem> items;
  const GlassQuickBar({required this.items, super.key});
  @override
  Widget build(BuildContext context) {
    return CardSection(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items
            .map(
              (item) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: item,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
