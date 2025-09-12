import 'package:flutter/material.dart';
import 'package:money_nest_app/components/glass_panel.dart';

// 毛玻璃Tab
class GlassTab extends StatelessWidget {
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final TabController? tabController;
  final List<String> tabs;
  final Widget tabBarContent;
  const GlassTab({
    this.borderRadius = 24,
    this.margin,
    this.tabController,
    required this.tabs,
    required this.tabBarContent,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassPanel(
        borderRadius: borderRadius,
        margin: margin,
        child: DefaultTabController(
          length: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TabBar
              Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: TabBar(
                  controller: tabController,
                  indicator: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  indicatorPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ), // 横向padding加大
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.black87,
                  unselectedLabelColor: Colors.black87,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                  tabs: tabs.isNotEmpty
                      ? tabs.map((title) {
                          return Tab(
                            child: Container(
                              alignment: Alignment.center,
                              height: 36,
                              width: 100,
                              child: Text(title),
                            ),
                          );
                        }).toList()
                      : [],
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                ),
              ),
              const SizedBox(height: 8),
              // Tab内容
              tabBarContent,
            ],
          ),
        ),
      ),
    );
  }
}
