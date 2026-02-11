import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:money_nest_app/components/custom_bottom_nav_bar.dart';
import 'package:money_nest_app/components/liquid_glass/bottom_bar.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/pages/assets/assets_tab_page.dart';
import 'package:money_nest_app/pages/asset_analysis/asset_analysis_tab_page.dart';
import 'package:money_nest_app/pages/home/home_tab_page.dart';
import 'package:money_nest_app/pages/setting/setting_tab_page.dart';
import 'package:money_nest_app/pages/trade_history/trade_add_edit_page.dart';
import 'package:money_nest_app/pages/trade_history/trade_history_tab_page.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';

class MainPage extends StatefulWidget {
  final AppDatabase db;
  const MainPage({super.key, required this.db});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> with TickerProviderStateMixin {
  bool _didInitialRefresh = false; // 新增：只执行一次的标志
  int _currentIndex = 0;
  Widget? _overlayPage;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey<HomeTabPageState> homeTabPageKey =
      GlobalKey<HomeTabPageState>();
  final GlobalKey<AssetsTabPageState> assetsTabPageKey =
      GlobalKey<AssetsTabPageState>();
  final GlobalKey<TradeHistoryPageState> tradeHistoryPageKey =
      GlobalKey<TradeHistoryPageState>();
  final GlobalKey<AssetAnalysisPageState> assetAnalysisTabPageKey =
      GlobalKey<AssetAnalysisPageState>();
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
      db: widget.db,
      key: assetsTabPageKey,
      onScroll: (pixels) {
        setState(() {
          _scrollPixels = pixels;
        });
      },
      scrollController: ScrollController(),
    ),
    TradeHistoryPage(
      db: widget.db,
      key: tradeHistoryPageKey,
      onAddPressed: _showTradeAddPage,
      onScroll: (pixels) {
        setState(() {
          _scrollPixels = pixels;
        });
      },
      scrollController: ScrollController(),
    ),
    AssetAnalysisPage(
      db: widget.db,
      key: assetAnalysisTabPageKey,
      onScroll: (pixels) {
        setState(() {
          _scrollPixels = pixels;
        });
      },
      scrollController: ScrollController(),
    ),
    SettingsTabPage(db: widget.db),
  ];

  void _showTradeAddPage() {
    setState(() {
      _overlayPage = TradeAddEditPage(
        onClose: () {
          setState(() {
            _overlayPage = null;
          });
        },
        db: widget.db,
        mode: 'add',
        type: 'asset',
        record: TradeRecordDisplay(
          id: 0,
          action: ActionType.buy,
          tradeDate: '',
          tradeType: '',
          amount: '',
          detail: '',
          assetType: '',
          price: 0.0,
          quantity: 0.0,
          currency: '',
          feeAmount: 0.0,
          feeCurrency: '',
          remark: '',
          stockInfo: Stock(
            id: 0,
            name: '',
            nameUs: '',
            exchange: 'JP',
            logo: '',
            currency: '',
            country: '',
            status: '',
          ),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();

    // 在第一次 build 完成后，如果当前为首页（_currentIndex == 0）就触发 home tab 刷新（只执行一次）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_didInitialRefresh && _currentIndex == 0) {
        homeTabPageKey.currentState?.onRefresh();
        _didInitialRefresh = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final double statusBarHeight = mediaQuery.padding.top;

    //print(
    //  'ImageFilter.isShaderFilterSupported: ${ImageFilter.isShaderFilterSupported}',
    //);

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
          backgroundColor: Colors.black, // Dark background
          body: Column(
            children: [
              // 页面内容
              Expanded(
                child: Stack(
                  children: [
                    /*CustomScrollView(
                      slivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => AspectRatio(
                              aspectRatio: 2,
                              child: Image.network(
                                'https://picsum.photos/1000/500?random=$index',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 16,
                            children: [
                              LiquidStretch(
                                child: LiquidGlass(
                                  shape: LiquidRoundedSuperellipse(
                                    borderRadius: Radius.circular(20),
                                  ),
                                  child: GlassGlow(
                                    child: SizedBox.square(
                                      dimension: 100,
                                      child: Center(child: Text('REAL')),
                                    ),
                                  ),
                                ),
                              ),
                              LiquidStretch(
                                child: FakeGlass(
                                  shape: LiquidRoundedSuperellipse(
                                    borderRadius: Radius.circular(20),
                                  ),
                                  child: GlassGlow(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      child: SizedBox.square(
                                        dimension: 100,
                                        child: Center(child: Text('FAKE')),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 16,
                            children: [
                              LiquidStretch(
                                child: _buildGlassEffect(
                                  borderRadius: BorderRadius.circular(20),
                                  isDark: isDark,
                                  child: GlassGlow(
                                    child: SizedBox.square(
                                      dimension: 100,
                                      child: Center(child: Text('GLASS')),
                                    ),
                                  ),
                                ),
                              ),
                              LiquidStretch(
                                child: _buildSafeLiquidGlass(
                                  borderRadius: BorderRadius.circular(20),
                                  child: GlassGlow(
                                    child: SizedBox.square(
                                      dimension: 100,
                                      child: Center(child: Text('GLASSNEW')),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),*/
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
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: CustomBottomNavBar(
                        currentIndex: _currentIndex,
                        icons: icons,
                        labels: titles,
                        onTap: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                          // Home Tab刷新资产和成本
                          if (index == 0) {
                            homeTabPageKey.currentState?.onRefresh();
                          } else if (index == 1) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              assetsTabPageKey.currentState?.onRefresh();
                            });
                          } else if (index == 2) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              tradeHistoryPageKey.currentState?.onRefresh();
                            });
                          } else if (index == 3) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              assetAnalysisTabPageKey.currentState?.onRefresh();
                            });
                          }
                        },
                        isDark: isDark,
                      ),

                      /*LiquidGlass(
                        // The LiquidGlass widget sits on top
                        shape: LiquidRoundedSuperellipse(
                          borderRadius: Radius.circular(50),
                        ),
                        child: SizedBox(
                          height: 80,
                          child: CustomBottomNavBar(
                            currentIndex: _currentIndex,
                            icons: icons,
                            labels: titles,
                            onTap: (index) {
                              setState(() {
                                _currentIndex = index;
                              });
                              // Home Tab刷新资产和成本
                              if (index == 0) {
                                homeTabPageKey.currentState
                                    ?.refreshTotalAssetsAndCosts();
                              } else if (index == 1) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  assetsTabPageKey.currentState
                                      ?.refreshTotalAssetsAndCosts();
                                });
                              }
                            },
                            isDark: isDark,
                          ),
                        ),
                      ),*/
                    ),

                    // 底部浮动毛玻璃导航栏
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
