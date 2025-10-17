import 'package:flutter/material.dart';
import 'package:money_nest_app/components/card_section.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';

// 毛玻璃Tab
class GlassTab extends StatefulWidget {
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final List<Widget> tabBarContentList;
  final List<String> tabs;
  final ValueChanged<int>? onTabChanged; // 新增

  const GlassTab({
    this.borderRadius = 24,
    this.margin,
    required this.tabs,
    required this.tabBarContentList,
    this.onTabChanged, // 新增
    super.key,
  });
  @override
  State<GlassTab> createState() => _GlassTabState();
}

class _GlassTabState extends State<GlassTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (mounted) setState(() {});
    // 新增：回调
    if (widget.onTabChanged != null &&
        _tabController.indexIsChanging == false) {
      widget.onTabChanged!(_tabController.index);
    }
  }

  @override
  void didUpdateWidget(covariant GlassTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) {
      _tabController.removeListener(_handleTabChange);
      _tabController.dispose();
      _tabController = TabController(length: widget.tabs.length, vsync: this);
      _tabController.addListener(_handleTabChange);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CardSection(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TabBar（需要 Material 祖先）
            Material(
              color: Colors.transparent,
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.appGrey.withValues(alpha: 0.30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  indicatorPadding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 6,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.black87,
                  unselectedLabelColor: Colors.black87,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                  ),
                  tabs: widget.tabs.isNotEmpty
                      ? widget.tabs.map((title) {
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
            ),
            const SizedBox(height: 8),
            // Tab内容动画
            AnimatedSize(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: widget.tabBarContentList[_tabController.index],
            ),
          ],
        ),
      ),
    );
  }
}
