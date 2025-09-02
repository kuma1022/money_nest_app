import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/pages/account/account_tab_page.dart';
import 'package:money_nest_app/pages/account/portfolio_tab_page.dart';
import 'package:money_nest_app/pages/home/home_tab_page.dart';
import 'package:money_nest_app/pages/trade_detail/trade_tab_page.dart';
import 'package:money_nest_app/pages/search_result/search_result_list.dart';
import 'package:money_nest_app/presentation/resources/app_resources.dart';
import 'package:money_nest_app/util/app_utils.dart';
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

  int _currentIndex = 0; // 默认选中“TOP”
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey<PortfolioTabState> portfolioTabPageKey =
      GlobalKey<PortfolioTabState>();
  final GlobalKey<HomeTabPageState> homeTabPageKey =
      GlobalKey<HomeTabPageState>();

  String _searchKeyword = '';

  late final List<Widget> _pages = [
    HomeTabPage(
      key: homeTabPageKey,
      db: widget.db,
      onPortfolioTap: () {
        setState(() {
          _currentIndex = 1; // 1为ポートフォリオTab的index
        });
      },
    ),
    //AccountTabPage(key: accountTabPageKey, db: widget.db), // 账户tab
    PortfolioTab(key: portfolioTabPageKey, db: widget.db),
    TradeTabPage(db: widget.db), // 交易明细tab
    //TotalCapitalTabPage(db: widget.db), // 资产总览tab
    Center(child: Text(AppLocalizations.of(context)!.mainPageMarketTitle)),
    Center(child: Text(AppLocalizations.of(context)!.mainPageMoreTitle)),
  ];

  @override
  Widget build(BuildContext context) {
    // 定义每个tab对应的标题
    final titles = [
      AppLocalizations.of(context)!.mainPageTopTitle,
      AppLocalizations.of(context)!.mainPageAccountTitle,
      AppLocalizations.of(context)!.mainPageTradeTitle,
      AppLocalizations.of(context)!.mainPageMarketTitle,
      AppLocalizations.of(context)!.mainPageMoreTitle,
    ];

    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: Scaffold(
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
              : null, // 搜索时隐藏 title
          backgroundColor: const Color(0xFFF2F2F2),
          elevation: 0,
          actions: [],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(
              _isSearching ? 0.5 : (_currentIndex == 2 ? 44 : 0.5),
            ),
            child: Column(
              children: [
                if (_currentIndex == 2)
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
                              color: const Color(0xFFE0E0E0),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              style: const TextStyle(
                                fontSize: AppTexts.fontSizeSmall,
                              ),
                              cursorColor: AppColors.appGreen,
                              decoration: InputDecoration(
                                isDense: true,
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: AppColors.appGrey,
                                  size: 20,
                                ),
                                hintText: AppLocalizations.of(
                                  context,
                                )!.mainPageSearchHint,
                                border: InputBorder.none,
                                hintStyle: const TextStyle(
                                  color: AppColors.appGrey,
                                  fontSize: AppTexts.fontSizeSmall,
                                ),
                                contentPadding: EdgeInsets.symmetric(
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
                                  style: const TextStyle(
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
                const Divider(
                  color: Color(0xFFDDDDDD),
                  thickness: 0.5,
                  height: 0.5,
                  indent: 0,
                  endIndent: 0,
                ),
              ],
            ),
          ),
        ),
        body: (_currentIndex == 2 && _isSearching)
            ? SearchResultList(db: widget.db, keyword: _searchKeyword)
            : IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(
              color: Color(0xFFDDDDDD), // 和 AppBar 下线一致
              thickness: 0.5,
              height: 0.5,
              indent: 0,
              endIndent: 0,
            ),
            BottomNavigationBar(
              backgroundColor: Colors.grey[100],
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined, color: AppColors.appDarkGrey),
                  activeIcon: Icon(Icons.home, color: AppColors.appGreen),
                  label: AppLocalizations.of(context)!.mainPageTopTitle,
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.pie_chart_outline,
                    color: AppColors.appDarkGrey,
                  ),
                  activeIcon: Icon(Icons.pie_chart, color: AppColors.appGreen),
                  label: AppLocalizations.of(context)!.mainPageAccountTitle,
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.list_alt_outlined,
                    color: AppColors.appDarkGrey,
                  ),
                  activeIcon: Icon(Icons.list_alt, color: AppColors.appGreen),
                  label: AppLocalizations.of(context)!.mainPageTradeTitle,
                ),
                /*BottomNavigationBarItem(
                icon: Icon(Icons.pie_chart_outline, color: AppColors.appDarkGrey),
                activeIcon: Icon(Icons.pie_chart, color: AppColors.appGreen),
                label: AppLocalizations.of(context)!.mainPageWalletTitle,
              ),*/
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.monetization_on_outlined,
                    color: AppColors.appDarkGrey,
                  ),
                  activeIcon: Icon(
                    Icons.monetization_on,
                    color: AppColors.appGreen,
                  ),
                  label: AppLocalizations.of(context)!.mainPageMarketTitle,
                ),

                BottomNavigationBarItem(
                  icon: Icon(Icons.menu, color: AppColors.appDarkGrey),
                  activeIcon: Icon(Icons.menu, color: AppColors.appGreen),
                  label: AppLocalizations.of(context)!.mainPageMoreTitle,
                ),
              ],
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.appGreen,
              unselectedItemColor: AppColors.appDarkGrey,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppTexts.fontSizeMini,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: AppTexts.fontSizeMini,
              ),
              onTap: (index) async {
                // 1. 先处理异步逻辑
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
                                DateTime.now().subtract(
                                  const Duration(hours: 1),
                                ),
                              ),
                        );
                  }
                }

                // 2. 再同步 setState
                setState(() {
                  _currentIndex = index;
                  // 其它同步状态更新
                });

                // 3. 刷新页面（如果需要）
                if (needRefresh) {
                  if (index == 0) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      homeTabPageKey.currentState?.refreshController
                          .requestRefresh();
                    });
                  } else if (index == 1) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      portfolioTabPageKey.currentState?.refreshController
                          .requestRefresh();
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
