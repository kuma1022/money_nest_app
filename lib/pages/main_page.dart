import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:money_nest_app/components/custom_bottom_nav_bar.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/pages/assets/assets_tab_page.dart';
import 'package:money_nest_app/pages/asset_analysis/asset_analysis_tab_page.dart';
import 'package:money_nest_app/pages/home/home_tab_page.dart';
import 'package:money_nest_app/pages/setting/setting_tab_page.dart';
import 'package:money_nest_app/pages/trade_history/trade_add_page.dart';
import 'package:money_nest_app/pages/trade_history/trade_history_tab_page.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';

class MainPage extends StatefulWidget {
  final AppDatabase db;
  const MainPage({super.key, required this.db});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  Widget? _overlayPage;
  late AnimationController _headerAnimController;
  late Animation<double> _headerAnim;
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
      scrollController: ScrollController(),
    ),
    TradeHistoryPage(
      onAddPressed: _showTradeAddPage, // 传递回调
    ),
    AssetAnalysisPage(),
    SettingsTabPage(),
  ];

  void _showTradeAddPage() {
    setState(() {
      _overlayPage = TradeAddPage(
        onClose: () {
          _headerAnimController.reverse();
          setState(() {
            _overlayPage = null;
          });
        },
      );
    });
    _headerAnimController.forward(from: 0);
  }

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _headerAnim = CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.easeInOut,
    );
  }

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
    final double maxHeaderHeight = statusBarHeight + 50.0;
    final double minHeaderHeight = statusBarHeight + 40.0;
    final double t = (_scrollPixels / 60).clamp(0, 1);
    final double titleFontSize =
        maxTitleSize - (maxTitleSize - minTitleSize) * t;
    final double headerHeight =
        maxHeaderHeight - (maxHeaderHeight - minHeaderHeight) * t;

    final Color headerBgColor = isDark
        ? const Color(0xFF23242A)
        : AppColors.appBackground;

    void onTabChanged(int index) {
      setState(() {
        _currentIndex = index;
      });
      // 切换到首页且首页当前是资产tab时，触发动画
      if (index == 0) {
        // 这里加一个延迟，确保页面已build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          homeTabPageKey.currentState?.animatePieChartIfAssetTab();
        });
      }
    }

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
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              AnimatedBuilder(
                animation: _headerAnim,
                builder: (context, child) {
                  // headerHeight: 动画期间从正常高度到0
                  final double animatedHeight = (_overlayPage == null)
                      ? headerHeight
                      : headerHeight * (1 - _headerAnim.value);
                  final double animatedOpacity = (_overlayPage == null)
                      ? 1.0
                      : 1.0 - _headerAnim.value;
                  if (animatedHeight < 1) return const SizedBox.shrink();
                  return Opacity(
                    opacity: animatedOpacity,
                    child: Container(
                      height: animatedHeight,
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
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  child: Text(titles[_currentIndex]),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              // 页面内容
              Expanded(
                child: Stack(
                  children: [
                    IndexedStack(
                      index: (_currentIndex < _pages.length)
                          ? _currentIndex
                          : 0,
                      children: _pages,
                    ),
                    // 动画显示 overlayPage
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        final offsetAnimation =
                            Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            );
                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                      child: _overlayPage != null
                          ? SizedBox(
                              key: const ValueKey('trade_add_page'),
                              width: double.infinity,
                              height: double.infinity,
                              child: _overlayPage!,
                            )
                          : const SizedBox.shrink(),
                    ),
                    // 底部浮动毛玻璃导航栏
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: CustomBottomNavBar(
                        currentIndex: _currentIndex,
                        icons: icons,
                        labels: titles,
                        onTap: (index) {
                          // Home Tab刷新资产和成本
                          if (index == 0) {
                            homeTabPageKey.currentState
                                ?.refreshTotalAssetsAndCosts();
                          }
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          /*bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _currentIndex,
            icons: icons,
            labels: titles,
            onTap: (index) {
              setState(() {
                _currentIndex = index.clamp(0, _pages.length - 1);
                _overlayPage = null;
              });
            },
            isDark: isDark,
          ),*/
        ),
      ),
    );
  }
}
