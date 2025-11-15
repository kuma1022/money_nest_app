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
  late AnimationController _headerAnimController;
  late Animation<double> _headerAnim;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey<HomeTabPageState> homeTabPageKey =
      GlobalKey<HomeTabPageState>();
  final GlobalKey<AssetsTabPageState> assetsTabPageKey =
      GlobalKey<AssetsTabPageState>();
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
      onAddPressed: _showTradeAddPage, // 传递回调
      db: widget.db,
    ),
    AssetAnalysisPage(),
    SettingsTabPage(db: widget.db),
  ];

  void _showTradeAddPage() {
    setState(() {
      _overlayPage = TradeAddEditPage(
        onClose: () {
          _headerAnimController.reverse();
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

  Widget _buildSafeLiquidGlass({
    required Widget child,
    required BorderRadius borderRadius,
  }) {
    // 检查是否支持 shader filter
    if (!ImageFilter.isShaderFilterSupported) {
      //print('Shader filters not supported, falling back to BackdropFilter');
      return ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: borderRadius,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.0,
              ),
            ),
            child: child,
          ),
        ),
      );
    }

    return LiquidGlass(
      shape: LiquidRoundedSuperellipse(borderRadius: borderRadius.topLeft),
      child: child,
    );
  }

  Widget _buildGlassEffect({
    required Widget child,
    required BorderRadius borderRadius,
    bool isDark = false,
  }) {
    if (!Platform.isIOS) {
      // Android 测试：简化版，只在 FakeGlass 基础上增加轻微的边框增强
      return LiquidStretch(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            // 只加一个轻微的外边框
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.0,
            ),
            // 轻微的外阴影
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: FakeGlass(
              shape: LiquidRoundedSuperellipse(
                borderRadius: borderRadius.topLeft,
              ),
              child: child,
            ),
          ),
        ),
      );
    } else {
      // iOS 使用 LiquidGlass
      return LiquidGlass(
        shape: LiquidRoundedSuperellipse(borderRadius: borderRadius.topLeft),
        child: child,
      );
    }
  }

  Widget _buildBottomBar(BuildContext context) {
    // 保证在 iOS 的 home indicator 之上显示
    // 外层加一个半透明容器（或调试色），确保在 iOS 上会被绘制
    return SafeArea(
      top: false,
      bottom: true,
      child: Padding(
        padding: EdgeInsets.only(left: 12, right: 12, bottom: 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            // debug: 用明显色确认位置（发布时可调整为更透明或移除）
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.04)
                : Colors.white.withOpacity(0.85),
            // 强制 icon/text 颜色，排查“可点击但不可见”问题
            child: Builder(
              builder: (ctx) {
                final bool isDark = Theme.of(ctx).brightness == Brightness.dark;
                return IconTheme(
                  data: IconThemeData(
                    color: isDark ? Colors.white : Colors.black87,
                    size: 24,
                  ),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 12,
                    ),
                    child: LiquidGlassBottomBar(
                      extraButton: LiquidGlassBottomBarExtraButton(
                        icon: CupertinoIcons.add_circled,
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => const CupertinoPageScaffold(
                                child: SizedBox(),
                                navigationBar: CupertinoNavigationBar.large(),
                              ),
                            ),
                          );
                        },
                        label: '',
                      ),
                      tabs: [
                        LiquidGlassBottomBarTab(
                          label: AppLocalizations.of(context)!.mainPageTopTitle,
                          icon: CupertinoIcons.home,
                        ),
                        const LiquidGlassBottomBarTab(
                          label: '資産',
                          icon: CupertinoIcons.chart_pie,
                        ),
                        LiquidGlassBottomBarTab(
                          label: AppLocalizations.of(
                            context,
                          )!.mainPageTradeTitle,
                          icon: CupertinoIcons.list_bullet,
                        ),
                        const LiquidGlassBottomBarTab(
                          label: '資産分析',
                          icon: CupertinoIcons.add,
                        ),
                        LiquidGlassBottomBarTab(
                          label: AppLocalizations.of(
                            context,
                          )!.mainPageMoreTitle,
                          icon: CupertinoIcons.settings,
                        ),
                      ],
                      selectedIndex: _currentIndex,
                      onTabSelected: (index) {
                        setState(() {
                          _currentIndex = index.clamp(0, _pages.length - 1);
                          _overlayPage = null;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
