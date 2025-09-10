import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/pages/account/portfolio_tab.dart';
import 'package:money_nest_app/pages/asset_analysis/asset_analysis_tab_page.dart';
import 'package:money_nest_app/pages/home/home_tab_page.dart';
import 'package:money_nest_app/pages/setting/setting_tab_page.dart';
import 'package:money_nest_app/pages/search_result/search_result_list.dart';
import 'package:money_nest_app/pages/trade_history/trade_history_tab_page.dart';
import 'package:money_nest_app/presentation/resources/app_resources.dart';
import 'package:money_nest_app/util/provider/portfolio_provider.dart';
import 'package:money_nest_app/util/provider/total_asset_provider.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  final AppDatabase db;
  const MainPage({super.key, required this.db});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  Currency _selectedCurrency = Currency.values.first;

  @override
  void initState() {
    super.initState();
    Provider.of<TotalAssetProvider>(
      context,
      listen: false,
    ).fetchTotalAsset(widget.db, _selectedCurrency);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<PortfolioProvider>(context, listen: false);
    provider.fetchPortfolio(widget.db, l10n);
  }

  int _currentIndex = 0;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey<HomeTabPageState> homeTabPageKey =
      GlobalKey<HomeTabPageState>();

  String _searchKeyword = '';

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
    ),
    PortfolioTabPage(),
    TradeHistoryPage(),
    AssetAnalysisPage(),
    SettingsTabPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titles = [
      AppLocalizations.of(context)!.mainPageTopTitle,
      '資産', //AppLocalizations.of(context)!.mainPageAccountTitle,
      AppLocalizations.of(context)!.mainPageTradeTitle,
      '資産分析', //AppLocalizations.of(context)!.mainPageMarketTitle,
      AppLocalizations.of(context)!.mainPageMoreTitle,
    ];

    // 线条风格icon
    final icons = [
      Icons.home_outlined,
      Icons.pie_chart_outline,
      Icons.list_alt_outlined,
      Icons.monetization_on_outlined,
      Icons.menu,
    ];

    // 状态栏颜色适配
    SystemUiOverlayStyle overlayStyle = isDark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.black,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.white,
          );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF181A20)
              : const Color(0xFFF5F6FA),
          appBar: AppBar(
            centerTitle: true,
            title: !_isSearching
                ? Text(
                    titles[_currentIndex],
                    style: const TextStyle(
                      fontSize: AppTexts.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
            backgroundColor: isDark
                ? const Color(0xFF181A20)
                : const Color(0xFFF2F2F2),
            elevation: 0,
            actions: [],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(
                _isSearching ? 0.5 : (_currentIndex == 20 ? 44 : 0.5),
              ),
              child: Column(
                children: [
                  if (_currentIndex == 20)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        _isSearching ? 4 : 0,
                        16,
                        12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.ease,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF23242A)
                                    : const Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                style: TextStyle(
                                  fontSize: AppTexts.fontSizeSmall,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                cursorColor: AppColors.appGreen,
                                decoration: InputDecoration(
                                  isDense: true,
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: AppColors.appGrey,
                                    size: 20,
                                  ),
                                  hintText: AppLocalizations.of(
                                    context,
                                  )!.mainPageSearchHint,
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color: AppColors.appGrey,
                                    fontSize: AppTexts.fontSizeSmall,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: AppColors.appGrey,
                                            size: 18,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _searchController.clear();
                                              _searchKeyword = '';
                                            });
                                          },
                                        )
                                      : null,
                                ),
                                onTap: () {
                                  setState(() {
                                    _searchKeyword = '';
                                    _isSearching = true;
                                  });
                                },
                                onSubmitted: (value) {
                                  setState(() {
                                    _searchKeyword = value;
                                  });
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _searchKeyword = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          if (_isSearching)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: SizedBox(
                                height: 32,
                                width: 48,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size(48, 32),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isSearching = false;
                                      _searchController.clear();
                                      _searchFocusNode.unfocus();
                                    });
                                  },
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.mainPageSearchCancel,
                                    style: TextStyle(
                                      color: AppColors.appGreen,
                                      fontSize: AppTexts.fontSizeSmall,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  Divider(
                    color: isDark
                        ? const Color(0xFF23242A)
                        : const Color(0xFFDDDDDD),
                    thickness: 0.5,
                    height: 0.5,
                    indent: 0,
                    endIndent: 0,
                  ),
                ],
              ),
            ),
          ),
          body: (_currentIndex == 20 && _isSearching)
              ? SearchResultList(db: widget.db, keyword: _searchKeyword)
              : IndexedStack(index: _currentIndex, children: _pages),
          bottomNavigationBar: _CustomBottomNavBar(
            currentIndex: _currentIndex,
            icons: icons,
            labels: titles,
            onTap: (index) async {
              if (index != 2) {
                _isSearching = false;
                _searchController.clear();
                _searchFocusNode.unfocus();
              }

              bool needRefresh = false;
              if (_currentIndex == index) {
                needRefresh = true;
              } else if (index == 0 || index == 1) {
                final stockDataList = await widget.db.getAllStocksRecords();
                List<Stock> newStockDataList = List.from(stockDataList);
                if (stockDataList.isNotEmpty &&
                    !newStockDataList.every(
                      (stock) => stock.marketCode == 'FOREX',
                    )) {
                  bool allWeekend =
                      stockDataList.isNotEmpty &&
                      stockDataList.every((stock) {
                        final dt = stock.priceUpdatedAt;
                        if (dt == null) return false;
                        return dt.weekday == DateTime.saturday ||
                            dt.weekday == DateTime.sunday;
                      });
                  needRefresh =
                      !allWeekend &&
                      stockDataList.any(
                        (stock) =>
                            stock.priceUpdatedAt == null ||
                            stock.priceUpdatedAt!.isBefore(
                              DateTime.now().subtract(const Duration(hours: 1)),
                            ),
                      );
                }
              }

              setState(() {
                _currentIndex = index;
              });

              //if (needRefresh) {
              //  if (index == 0) {
              //    WidgetsBinding.instance.addPostFrameCallback((_) {
              //      homeTabPageKey.currentState?.refreshController
              //          .requestRefresh();
              //    });
              //  }
              //}
            },
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

// 自定义底部导航栏，适配明暗模式
class _CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final List<IconData> icons;
  final List<String> labels;
  final ValueChanged<int> onTap;
  final bool isDark;

  const _CustomBottomNavBar({
    required this.currentIndex,
    required this.icons,
    required this.labels,
    required this.onTap,
    required this.isDark,
    super.key,
  });

  @override
  State<_CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<_CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _prevIndex;
  late int _targetIndex;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _prevIndex = widget.currentIndex;
    _targetIndex = widget.currentIndex;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _prevIndex = _targetIndex;
          _isAnimating = false;
        });
        widget.onTap(_targetIndex); // 动画结束后再切换页面
      }
    });
  }

  @override
  void didUpdateWidget(covariant _CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果外部切换了tab（比如程序主动跳转），同步状态
    if (!_isAnimating && widget.currentIndex != _targetIndex) {
      setState(() {
        _prevIndex = widget.currentIndex;
        _targetIndex = widget.currentIndex;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (_isAnimating || index == _targetIndex) return;
    setState(() {
      _prevIndex = _targetIndex;
      _targetIndex = index;
      _isAnimating = true;
    });
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final icons = widget.icons;
    final labels = widget.labels;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withOpacity(0.32),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 18,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double itemWidth = constraints.maxWidth / icons.length;
                const double indicatorWidth = 68;
                const double indicatorHeight = 42;
                const double barHeight = 60;

                final double start =
                    _prevIndex * itemWidth + (itemWidth - indicatorWidth) / 2;
                final double end =
                    _targetIndex * itemWidth + (itemWidth - indicatorWidth) / 2;
                final double left = start + (end - start) * _animation.value;

                final double width = TweenSequence([
                  TweenSequenceItem(
                    tween: Tween<double>(
                      begin: indicatorWidth,
                      end: indicatorWidth + 56,
                    ).chain(CurveTween(curve: Curves.easeOut)),
                    weight: 50,
                  ),
                  TweenSequenceItem(
                    tween: Tween<double>(
                      begin: indicatorWidth + 56,
                      end: indicatorWidth,
                    ).chain(CurveTween(curve: Curves.easeIn)),
                    weight: 50,
                  ),
                ]).transform(_animation.value);

                // 当前选中的index
                final int effectiveIndex = _isAnimating
                    ? _targetIndex
                    : widget.currentIndex;

                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Positioned(
                          left: left - (width - indicatorWidth) / 2,
                          top: (barHeight - indicatorHeight) / 2,
                          child: Container(
                            width: width,
                            height: indicatorHeight,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(icons.length, (index) {
                        final selected = effectiveIndex == index;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => _onTap(index),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              alignment: Alignment.center,
                              height: double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    icons[index],
                                    color: selected
                                        ? Colors.black87
                                        : Colors.black54,
                                    size: 20,
                                  ),
                                  //const SizedBox(height: 2),
                                  Text(
                                    labels[index],
                                    style: TextStyle(
                                      color: selected
                                          ? Colors.black87
                                          : Colors.black54,
                                      fontWeight: selected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
