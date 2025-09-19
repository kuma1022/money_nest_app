import 'package:flutter/material.dart';

class GlassTabBarOnly extends StatelessWidget {
  final List<String> tabs;
  const GlassTabBarOnly({required this.tabs, super.key});

  @override
  Widget build(BuildContext context) {
    assert(tabs.isNotEmpty, 'tabs 不能为空');
    return TabBar(
      tabs: tabs.map((e) => Tab(text: e)).toList(),
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFFF5F6FA),
      ),
      labelColor: Colors.black87,
      unselectedLabelColor: Colors.black38,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
    );
  }
}
