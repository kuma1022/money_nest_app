import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_nest_app/components/custom_bottom_nav_bar.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/pages/assets/assets_tab_page.dart';
import 'package:money_nest_app/pages/asset_analysis/asset_analysis_tab_page.dart';
import 'package:money_nest_app/pages/home/home_tab_page.dart';
import 'package:money_nest_app/pages/setting/setting_tab_page.dart';
import 'package:money_nest_app/pages/trade_history/trade_history_tab_page.dart';

class MainPage extends StatefulWidget {
  final AppDatabase db;
  const MainPage({super.key, required this.db});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey<HomeTabPageState> homeTabPageKey =
      GlobalKey<HomeTabPageState>();
  double _scrollPixels = 0.0;

  late final List<Widget> _pages = [
    HomeTabPage(
      key: homeTabPageKey,
      db: widget.db,
      onPortfolioTap: () {
        setState(() {
          _currentIndex = 1;
        });
      },
      onAssetAnalysisTap: () {
        setState(() {
          _currentIndex = 3;
        });
      },
      onScroll: (pixels) {
        setState(() {
          _scrollPixels = pixels;
        });
      },
    ),
    AssetsTabPage(
      onScroll: (pixels) {
        setState(() {
          _scrollPixels = pixels;
        });
      },
    ),
    TradeHistoryPage(),
    AssetAnalysisPage(),
    SettingsTabPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final double statusBarHeight = mediaQuery.padding.top;

    final titles = [
      AppLocalizations.of(context)!.mainPageTopTitle,
      '資産',
      AppLocalizations.of(context)!.mainPageTradeTitle,
      '資産分析',
      AppLocalizations.of(context)!.mainPageMoreTitle,
    ];
    final icons = [
      Icons.home_outlined,
      Icons.pie_chart_outline,
      Icons.list_alt_outlined,
      Icons.monetization_on_outlined,
      Icons.menu,
    ];

    // Header参数
    final double minTitleSize = 18;
    final double maxTitleSize = 26;
    final double topPosition = statusBarHeight + 10.0;
    final double headerHeight = statusBarHeight + 50.0;
    final double t = (_scrollPixels / 60).clamp(0, 1);
    final double titleFontSize =
        maxTitleSize - (maxTitleSize - minTitleSize) * t;

    final Color headerBgColor = isDark
        ? const Color(0xFF23242A)
        : const Color(0xFFE3E6F3);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.black,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.white,
            ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF181A20)
              : const Color(0xFF9CA3BA), //Color(0xFFF5F6FA),
          body: SizedBox.expand(
            // 关键：让Stack填满整个屏幕
            child: Stack(
              children: [
                // 顶部header
                Container(
                  height: headerHeight,
                  width: double.infinity,
                  color: headerBgColor,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: topPosition),
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 180),
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              child: Text(titles[_currentIndex]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 页面内容（headerHeight以下区域）
                Positioned.fill(
                  top: headerHeight,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IndexedStack(index: _currentIndex, children: _pages),
                ),
                // 悬浮底栏
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 4,
                  child: IgnorePointer(
                    ignoring: false, // 允许点击
                    child: CustomBottomNavBar(
                      currentIndex: _currentIndex,
                      icons: icons,
                      labels: titles,
                      onTap: (index) async {
                        // 只在动画结束后才切换
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      isDark: isDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
