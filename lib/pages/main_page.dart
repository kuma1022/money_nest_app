import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:money_nest_app/components/liquid_glass/bottom_bar.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/pages/asset_analysis/asset_analysis_tab_page.dart';
import 'package:money_nest_app/pages/assets/assets_tab_page.dart';
import 'package:money_nest_app/pages/home/home_tab_page.dart';
import 'package:money_nest_app/pages/setting/setting_tab_page.dart';
import 'package:money_nest_app/pages/trade_history/trade_add_page.dart';
import 'package:money_nest_app/pages/trade_history/trade_history_tab_page.dart';
import 'package:motor/motor.dart';

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
  final GlobalKey<AssetsTabPageState> assetsTabPageKey =
      GlobalKey<AssetsTabPageState>();
  double _scrollPixels = 0.0;

  late final AnimationController _lightController;
  late final Animation<double> _light;

  late final List<Widget> _pages = [
    HomeTabPage(
      key: homeTabPageKey,
      db: widget.db,
      onPortfolioTap: () => setState(() => _currentIndex = 1),
      onAssetAnalysisTap: () => setState(() => _currentIndex = 3),
      onScroll: (pixels) => setState(() => _scrollPixels = pixels),
    ),
    AssetsTabPage(
      key: assetsTabPageKey,
      onScroll: (pixels) => setState(() => _scrollPixels = pixels),
      scrollController: ScrollController(),
    ),
    TradeHistoryPage(onAddPressed: _showTradeAddPage),
    AssetAnalysisPage(),
    SettingsTabPage(),
  ];

  void _showTradeAddPage() {
    setState(() {
      _overlayPage = TradeAddPage(
        onClose: () {
          _headerAnimController.reverse();
          setState(() => _overlayPage = null);
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
    _lightController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _light = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _lightController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _lightController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  final settingsNotifier = ValueNotifier(
    LiquidGlassSettings(
      thickness: 20,
      blur: 10,
      refractiveIndex: 1.2,
      lightIntensity: .8,
      saturation: 1.2,
      lightAngle: pi / 4,
      glassColor: Colors.white.withValues(alpha: 0.2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CupertinoPageScaffold(
        backgroundColor: Colors.black, // ← iOS 背景必须非透明，否则 Metal 下 shader 不显示
        child: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(
                index: (_currentIndex < _pages.length) ? _currentIndex : 0,
                children: _pages,
              ),
            ),
            if (_overlayPage != null)
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _overlayPage,
                ),
              ),
            SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Material(
                  // ✅ 修复 iOS 渲染丢失
                  type: MaterialType.transparency,
                  child: Container(
                    color: Colors.transparent,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Blink extends StatelessWidget {
  const Blink({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SequenceMotionBuilder(
      converter: SingleMotionConverter(),
      sequence: StepSequence.withMotions([
        (0.0, Motion.linear(const Duration(seconds: 1))),
        (1.0, Motion.linear(const Duration(seconds: 1))),
        (1.0, Motion.linear(const Duration(seconds: 1))),
      ], loop: LoopMode.loop),
      builder: (context, value, phase, child) =>
          Opacity(opacity: value, child: child),
      child: child,
    );
  }
}
