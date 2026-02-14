import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_nest_app/components/card_section.dart';
import 'package:money_nest_app/components/custom_line_chart.dart';
import 'package:money_nest_app/components/custom_tab.dart';
import 'package:money_nest_app/components/summary_category_card.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/pages/assets/crypto/crypto_detail_page.dart';
import 'package:money_nest_app/pages/assets/fund/fund_detail_page.dart';
import 'package:money_nest_app/pages/assets/stock/stock_detail_page.dart';
import 'package:money_nest_app/pages/assets/stock/domestic_stock_detail_page.dart';
import 'package:money_nest_app/pages/assets/stock/us_stock_detail_page.dart';
import 'package:money_nest_app/pages/assets/cash/cash_page.dart';
import 'package:money_nest_app/pages/assets/custom/custom_assets_page.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/presentation/resources/app_texts.dart';
import 'package:money_nest_app/services/data_sync_service.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:money_nest_app/util/global_store.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AssetsTabPage extends StatefulWidget {
  final AppDatabase db;
  final ValueChanged<double>? onScroll;
  final ScrollController? scrollController;

  const AssetsTabPage({
    super.key,
    required this.db,
    this.onScroll,
    this.scrollController,
  });

  @override
  State<AssetsTabPage> createState() => AssetsTabPageState();
}

class AssetsTabPageState extends State<AssetsTabPage> {
  bool _isInitializing = false;
  final RefreshController _refreshController = RefreshController();
  RefreshController get refreshController => _refreshController;
  final GlobalKey<CryptoDetailPageState> cryptoDetailPageKey =
      GlobalKey<CryptoDetailPageState>();
  int _selectedTransitionIndex = 0; // 0:资产, 1:负債
  double totalAssets = 0;
  double totalCosts = 0;
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();
  List<(DateTime, double)> priceHistory = [];
  List<(DateTime, double)> costBasisHistory = [];
  String _selectedRangeKey = '1ヶ月';
  final Map<String, Duration?> _rangeMap = {
    '1週間': const Duration(days: 7),
    '1ヶ月': const Duration(days: 30),
    '3ヶ月': const Duration(days: 90),
    '6ヶ月': const Duration(days: 180),
    '年初来': null, // 特殊处理
    '1年': const Duration(days: 365),
    '2年': const Duration(days: 365 * 2),
    '3年': const Duration(days: 365 * 3),
    '5年': const Duration(days: 365 * 5),
    '10年': const Duration(days: 365 * 10),
    'すべて': null,
  };

  // 刷新总资产和总成本
  Future<void> _initializeData() async {
    if (!mounted) return;

    setState(() {
      _isInitializing = true;
    });

    final dataSync = Provider.of<DataSyncService>(context, listen: false);

    try {
      // 刷新总资产和总成本
      await AppUtils().refreshTotalAssetsAndCosts(dataSync);

      if (mounted) {
        setState(() {
          // 安全地计算总资产
          totalAssets = GlobalStore().totalAssetsAndCostsMap.keys.fold<double>(
            0,
            (prev, key) {
              final data = GlobalStore().totalAssetsAndCostsMap[key];
              return prev + (data?['totalAssets']?.toDouble() ?? 0.0);
            },
          );
          // 安全地计算总成本
          totalCosts = GlobalStore().totalAssetsAndCostsMap.keys.fold<double>(
            0,
            (prev, key) {
              final data = GlobalStore().totalAssetsAndCostsMap[key];
              return prev + (data?['totalCosts']?.toDouble() ?? 0.0);
            },
          );
        });
      }

      // 计算历史数据
      priceHistory = [];
      costBasisHistory = [];
      // 计算资产总额和成本的历史数据
      for (var date in GlobalStore().historicalPortfolio.keys) {
        if (date.isBefore(startDate) || date.isAfter(endDate)) continue;
        final item = GlobalStore().historicalPortfolio[date]!;
        priceHistory.add((date, item['assetsTotal'] as double? ?? 0.0));
        costBasisHistory.add((date, item['costBasis'] as double? ?? 0.0));
      }
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      print('Error refreshing total assets and costs: $e');
      // 发生错误时设置默认值
      if (mounted) {
        setState(() {
          _isInitializing = false;
          totalAssets = 0;
          totalCosts = 0;
        });
      }
    }
  }

  List<Map<String, dynamic>> groupConsecutive(
    List<(DateTime, double)> items,
    List<(DateTime, double)> compareItems,
  ) {
    if (items.isEmpty) return [];
    List<(DateTime, double)> currentGroup = [items.first];
    bool currentFlag = items.first.$2 > compareItems.first.$2;
    List<Map<String, dynamic>> datas = [];

    for (int i = 1; i < items.length; i++) {
      final nextFlag = items[i].$2 > compareItems[i].$2;
      if (nextFlag != currentFlag) {
        // 标志变化，结束当前组，开始新组
        datas.add({
          'label': '資産総額',
          'color': currentFlag ? AppColors.appUpGreen : AppColors.appDownRed,
          'dataList': List.from(currentGroup),
        });
        currentGroup = [items[i]];
        currentFlag = nextFlag;
      } else {
        currentGroup.add(items[i]);
      }
    }
    // 添加最后一组
    datas.add({
      'label': '資産総額',
      'color': currentFlag ? AppColors.appUpGreen : AppColors.appDownRed,
      'dataList': List.from(currentGroup),
    });

    return datas;
  }

  Future<void> _reloadByRange() async {
    try {
      final now = DateTime.now();
      final dur = _rangeMap[_selectedRangeKey];
      final String? startDateStr = (dur == null)
          ? null
          : now.subtract(dur).toIso8601String().split('T').first;
      final String? endDateStr = now.toIso8601String().split('T').first;

      // 更新日期范围
      if (dur != null) {
        startDate = now.subtract(dur);
        endDate = now;
      } else if (_selectedRangeKey == '年初来') {
        startDate = DateTime(now.year, 1, 1);
        endDate = now;
      } else if (_selectedRangeKey == 'すべて') {
        // 使用历史数据的最早日期
        if (GlobalStore().historicalPortfolio.isNotEmpty) {
          final dates = GlobalStore().historicalPortfolio.keys.toList()..sort();
          startDate = dates.first;
          endDate = now;
        }
      }

      //await syncDataWithSupabase(
      //  /* userId */ GlobalStore().userId!,
      //  /* accountId */ GlobalStore().currentAccountId!,
      //  /* db */ GlobalStore().db,
      //   startDate: startDateStr,
      //   endDate: endDateStr,
      // );

      // 重新计算历史数据
      //await refreshTotalAssetsAndCosts();
    } catch (e) {
      print('Error reloading by range: $e');
    }
  }

  // 手动刷新数据
  Future<void> onRefresh() async {
    await _initializeData();
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  double pixels = 0.0;
                  if (notification is ScrollUpdateNotification ||
                      notification is OverscrollNotification) {
                    pixels = notification.metrics.pixels;
                    if (pixels < 0) pixels = 0;
                    widget.onScroll?.call(pixels);
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  controller: widget.scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () {},
                          ),
                          const Text(
                            'Portfolios',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.work_outline,
                                    color: Colors.white),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.search,
                                    color: Colors.white),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      buildTransitionAssetWidget(),
                      const SizedBox(height: 20),
                      // Asset List Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: '保有量 (多い順)',
                              dropdownColor: const Color(0xFF1C1C1E),
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  color: Colors.white),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              onChanged: (v) {},
                              items: const [
                                DropdownMenuItem(
                                  value: '保有量 (多い順)',
                                  child: Text('保有量 (多い順)'),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF1C1C1E),
                            ),
                            child: const Icon(
                              Icons.filter_list,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      createAssetList(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
            // Floating Action Button
            Positioned(
              right: 16,
              bottom: bottomPadding + 16,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                child: const Icon(Icons.add, color: Colors.black),
                onPressed: () {},
              ),
            ),
            // Loading Overlay
            if (_isInitializing)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget createAssetList() {
    final stockData = GlobalStore().totalAssetsAndCostsMap['stock'];
    final otherData = GlobalStore().totalAssetsAndCostsMap['other_asset'];
    final currency = GlobalStore().selectedCurrencyCode ?? 'JPY';

    // -------------------------------------------------------------------------
    // Prepare Stock Lists (Re-calculate for display)
    // -------------------------------------------------------------------------
    // Use Maps for aggregation: key (stockId or code) -> data
    final Map<String, Map<String, dynamic>> jpStockMap = {};
    final Map<String, Map<String, dynamic>> usStockMap = {};

    for (var item in GlobalStore().portfolio) {
      final qty = item['quantity'] as num? ?? 0;
      if (qty <= 0) continue; 

      // Normalize code: trim, uppercase, remove .T suffix if JP
      String normalizedCode = (item['code'] as String? ?? '').trim().toUpperCase();
      String exchange = (item['exchange'] as String? ?? 'JP').toUpperCase();
      
      // Normalize exchange names (TSE -> JP, TYO -> JP)
      if (['TSE', 'TYO', 'JP'].contains(exchange)) {
        exchange = 'JP';
      }

      if (exchange == 'JP' && normalizedCode.endsWith('.T')) {
        normalizedCode = normalizedCode.substring(0, normalizedCode.length - 2);
      }

      // Use Name + Exchange as key if code is missing, otherwise Code + Exchange
      // Ideally Code should be unique. 
      final String key = '${normalizedCode}_$exchange';
      
      final String name = item['name'] as String? ?? normalizedCode;
      final double buyPrice = (item['buyPrice'] as num? ?? 0).toDouble();
      final String itemCurrency = item['currency'] as String? ?? 'JPY';

      if (normalizedCode.isEmpty) continue;

      final rate = GlobalStore().currentStockPrices[
              '${itemCurrency == 'USD' ? '' : itemCurrency}${currency}=X'] ??
          1.0;
      final currentPrice = GlobalStore().currentStockPrices[
              exchange == 'JP' ? '$normalizedCode.T' : normalizedCode] ??
          buyPrice;

      // Values in display currency (roughly) for sorting/total
      final double marketValue = qty * currentPrice * rate;
      
      // We want to calculate weighted average buy price in ORIGINAL currency.
      // So we accumulate (qty * buyPrice)
      final double totalBuyCostOriginal = qty * buyPrice;

      // Determine which map to use
      final targetMap = (exchange == 'JP') ? jpStockMap : usStockMap;

      if (targetMap.containsKey(key)) {
        // Aggregate
        final existing = targetMap[key]!;
        existing['quantity'] = (existing['quantity'] as num) + qty;
        existing['marketValue'] = (existing['marketValue'] as double) + marketValue;
        // Accumulate original cost
        existing['totalBuyCostOriginal'] = (existing['totalBuyCostOriginal'] as double) + totalBuyCostOriginal;
      } else {
        // New entry
        targetMap[key] = {
          'code': normalizedCode,
          'name': name,
          'quantity': qty,
          'currentPrice': currentPrice,
          'marketValue': marketValue,
          'totalBuyCostOriginal': totalBuyCostOriginal,
          'currency': itemCurrency,
        };
      }
    }

    // Process maps to lists, calculating display percentage
    List<Map<String, dynamic>> processStockMap(
        Map<String, Map<String, dynamic>> sourceMap) {
      
      // First pass: Calculate total market value for this category
      double totalCategoryValue = 0.0;
      for (var data in sourceMap.values) {
        totalCategoryValue += (data['marketValue'] as double);
      }

      final list = sourceMap.values.map((data) {
        final qty = data['quantity'] as num;
        final totalBuyCostOriginal = data['totalBuyCostOriginal'] as double;
        final marketValue = data['marketValue'] as double;
        
        // Calculate Avg Cost in Original Currency
        final avgCost = (qty > 0) ? (totalBuyCostOriginal / qty) : 0.0;
        
        // Calculate Profit
        final currencyRate = GlobalStore().currentStockPrices[
                '${data['currency'] == 'USD' ? '' : data['currency']}${currency}=X'] ??
            1.0;

        final double currentTotalCostDisplay = totalBuyCostOriginal * currencyRate;
        final double profit = marketValue - currentTotalCostDisplay;
        final double profitPercent = currentTotalCostDisplay == 0 ? 0.0 : (profit / currentTotalCostDisplay) * 100;

        // Calculate Portfolio Percentage relative to this category
        final double portfolioPercent = totalCategoryValue == 0 ? 0.0 : (marketValue / totalCategoryValue) * 100;

        return {
          'code': data['code'],
          'name': data['name'],
          'quantity': qty,
          'currentPrice': data['currentPrice'],
          'avgCost': avgCost,
          'marketValue': marketValue,
          'profit': profit,
          'profitPercent': profitPercent,
          'portfolioPercent': portfolioPercent,
          'currency': data['currency'],
        };
      }).toList();

      // Sort by marketValue descending
      list.sort((a, b) => (b['marketValue'] as double)
          .compareTo(a['marketValue'] as double));
      return list;
    }

    final jpStockList = processStockMap(jpStockMap);
    final usStockList = processStockMap(usStockMap);

    // 1. Japan Stock
    final jpData = stockData?['details']?['jp_stock'];
    double jpVal = jpData?['totalAssets']?.toDouble() ?? 0.0;
    double jpCost = jpData?['totalCosts']?.toDouble() ?? 0.0;
    double jpProfit = jpVal - jpCost;
    double jpRate = jpCost == 0 ? 0.0 : (jpProfit / jpCost) * 100;

    // 2. US Stock
    final usData = stockData?['details']?['us_stock'];
    double usVal = usData?['totalAssets']?.toDouble() ?? 0.0;
    double usCost = usData?['totalCosts']?.toDouble() ?? 0.0;
    double usProfit = usVal - usCost;
    double usRate = usCost == 0 ? 0.0 : (usProfit / usCost) * 100;

    // 3. Cash
    final cashDetails = otherData?['details']?['cash'];
    double cashVal = cashDetails?['totalAssets']?.toDouble() ?? 0.0;
    double cashCost = cashDetails?['totalCosts']?.toDouble() ?? 0.0;
    double cashProfit = cashVal - cashCost;

    // 4. Custom
    double customVal = 0.0;
    double customProfit = 0.0;

    return Column(
      children: [
        _ExpandableAssetCard(
          title: '日本株',
          dotColor: AppColors.appChartGreen,
          value: AppUtils().formatMoney(jpVal, currency),
          profitText: AppUtils().formatMoney(
            jpProfit,
            currency,
          ),
          profitRateText: '(${AppUtils().formatNumberByTwoDigits(jpRate)}%)',
          profitColor:
              jpProfit >= 0 ? AppColors.appUpGreen : AppColors.appDownRed,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DomesticStockDetailPage(db: widget.db),
              ),
            );
          },
          stockList: jpStockList,
          displayCurrency: currency,
        ),
        const SizedBox(height: 12),
        _ExpandableAssetCard(
          title: '米国株',
          dotColor: AppColors.appChartBlue,
          value: AppUtils().formatMoney(usVal, currency),
          profitText: AppUtils().formatMoney(
            usProfit,
            currency,
          ),
          profitRateText: '(${AppUtils().formatNumberByTwoDigits(usRate)}%)',
          profitColor:
              usProfit >= 0 ? AppColors.appUpGreen : AppColors.appDownRed,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => USStockDetailPage(db: widget.db),
              ),
            );
          },
          stockList: usStockList,
          displayCurrency: currency,
        ),
        const SizedBox(height: 12),
        _buildAssetCard(
          title: '現金',
          dotColor: AppColors.appChartOrange,
          value: AppUtils().formatMoney(cashVal, currency),
          profitText: AppUtils().formatMoney(cashProfit, currency),
          profitRateText: '-',
          profitColor: Colors.grey,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CashPage(db: widget.db),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildAssetCard(
          title: 'その他資産',
          dotColor: Colors.purple,
          value: AppUtils().formatMoney(customVal, currency),
          profitText: AppUtils().formatMoney(customProfit, currency),
          profitRateText: '-',
          profitColor: Colors.grey,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CustomAssetsPage(db: widget.db),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAssetCard({
    required String title,
    required Color dotColor,
    required String value,
    required String profitText,
    required String profitRateText,
    required Color profitColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    title.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        profitText,
                        style: TextStyle(
                          color: profitColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profitRateText,
                        style: TextStyle(
                          color: profitColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 资产推移图表卡片
  Widget buildTransitionAssetWidget() {
    final List<Map<String, dynamic>> datas = [];
    if (priceHistory.isNotEmpty && costBasisHistory.isNotEmpty) {
      datas.add({
        'label': '評価総額',
        'lineColor': AppColors.appDownRed, // Screenshot shows red/magenta line
        'tooltipText1Color': AppColors.appChartLightBlue,
        'tooltipText2Color': AppColors.appChartLightBlue,
        'dataList': priceHistory,
      });

      // Hide cost basis line to match simpler look of screenshot?
      // Or keep it but darker.
      // Screenshot shows a dotted line, maybe that's cost basis or previous close.
      // I'll keep just price history for simplicity or keep both.
      // Keeping both for now but with updated colors.
    }

    final double profit = totalAssets - totalCosts;
    final double profitPercent =
        totalCosts == 0 ? 0 : (profit / totalCosts * 100);
    final bool isUp = profit >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ポートフォリオ価値',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              AppUtils().formatMoney(
                totalAssets.toDouble(),
                GlobalStore().selectedCurrencyCode ?? 'JPY',
              ),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              GlobalStore().selectedCurrencyCode ?? 'JPY',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '${isUp ? '+' : ''}${AppUtils().formatMoney(profit, GlobalStore().selectedCurrencyCode ?? 'JPY')}',
              style: TextStyle(
                color: isUp ? AppColors.appUpGreen : AppColors.appDownRed,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (isUp ? AppColors.appUpGreen : AppColors.appDownRed)
                    .withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${isUp ? '+' : ''}${AppUtils().formatNumberByTwoDigits(profitPercent)}%',
                style: TextStyle(
                  color: isUp ? AppColors.appUpGreen : AppColors.appDownRed,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 250, // Chart height
          child: datas.isNotEmpty
              ? _TransitionAssetChart(
                  datas: datas,
                  currencyCode: GlobalStore().selectedCurrencyCode ?? 'JPY',
                )
              : const Center(
                  child: Text('データがありません', style: TextStyle(color: Colors.grey))),
        ),
        const SizedBox(height: 16),
        // Range Selector Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _rangeMap.keys.map((key) {
              final bool isSelected = key == _selectedRangeKey;
              return GestureDetector(
                onTap: () {
                  if (mounted) {
                    setState(() => _selectedRangeKey = key);
                    _reloadByRange();
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1C1C1E)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    key,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget buildTransitionLiabilityWidget() {
    return const SizedBox(
      height: 200,
      child: Center(child: Text('負債推移グラフ（未実装）')),
    );
  }

  Widget buildBreakdownWidget() {
    return const SizedBox(
      height: 200,
      child: Center(child: Text('内訳グラフ（未実装）')),
    );
  }

  Widget buildPortfolioWidget() {
    return const SizedBox(
      height: 200,
      child: Center(child: Text('ポートフォリオグラフ（未実装）')),
    );
  }

  Widget buildDividendWidget() {
    return const SizedBox(
      height: 200,
      child: Center(child: Text('配当グラフ（未実装）')),
    );
  }
}

// 卡片通用外框
class _CardSection extends StatelessWidget {
  final Widget child;
  const _CardSection({required this.child, super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E6EA), width: 1),
      ),
      child: child,
    );
  }
}

// 资产总览tab按钮
class _OverviewTabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _OverviewTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.appBackground : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF1976D2) : const Color(0xFFE5E6EA),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF1976D2) : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// 资产总览图例
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final String percent;
  const _LegendDot({
    required this.color,
    required this.label,
    required this.percent,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 2),
        Text(percent, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }
}

class _ExpandableAssetCard extends StatelessWidget {
  final String title;
  final Color dotColor;
  final String value;
  final String profitText;
  final String profitRateText;
  final Color profitColor;
  final VoidCallback onTap;
  final List<Map<String, dynamic>> stockList;
  final String displayCurrency;

  const _ExpandableAssetCard({
    required this.title,
    required this.dotColor,
    required this.value,
    required this.profitText,
    required this.profitRateText,
    required this.profitColor,
    required this.onTap,
    required this.stockList,
    required this.displayCurrency,
  });

  @override
  Widget build(BuildContext context) {
    if (stockList.isEmpty) {
      // Fallback to simple card if no stocks
      return _buildSimpleCard();
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: Colors.white,
          collapsedIconColor: Colors.grey,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          title: InkWell(
            onTap: onTap, // Tap title to navigate
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      title.substring(0, 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          profitText,
                          style: TextStyle(
                            color: profitColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profitRateText,
                          style: TextStyle(
                            color: profitColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Padding to avoid overlapping with default expansion icon
                const SizedBox(width: 8), 
              ],
            ),
          ),
          children: [
            Column(
              children: stockList.map((stock) => _buildStockRow(stock)).toList(),
            ),
            // Optional: View Details Button at bottom
            TextButton(
              onPressed: onTap,
              child: const Text(
                '詳細を見る >',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    title.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        profitText,
                        style: TextStyle(
                          color: profitColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profitRateText,
                        style: TextStyle(
                          color: profitColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockRow(Map<String, dynamic> stock) {
    final profit = stock['profit'] as double;
    final profitPercent = stock['profitPercent'] as double;
    final portfolioPercent = stock['portfolioPercent'] as double? ?? 0.0;
    final isProfitPositive = profit >= 0;
    final profitColor = isProfitPositive ? AppColors.appUpGreen : AppColors.appDownRed;
    final currency = stock['currency'] ?? displayCurrency;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF2C2C2E))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Percentage Display (Left Side)
          SizedBox(
            width: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${portfolioPercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: dotColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '占比',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Vertical Divider
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(width: 12),
          // Main Content
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      stock['name'] ?? stock['code'],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${AppUtils().formatMoney(stock['marketValue'], displayCurrency)}',
                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left Column: Quantity, Avg Cost
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text('保有数: ${AppUtils().formatNumber(stock['quantity'])}', 
                           style: const TextStyle(color: Colors.grey, fontSize: 12)),
                         Text('取得単価: ${AppUtils().formatMoney(stock['avgCost'], currency)}',
                           style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    // Right Column: Current Price, Profit
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                         Text('現在値: ${AppUtils().formatMoney(stock['currentPrice'], currency)}',
                           style: const TextStyle(color: Colors.grey, fontSize: 12)),
                         Row(
                           children: [
                             Text(
                               '${AppUtils().formatMoney(profit, displayCurrency)}',
                               style: TextStyle(color: profitColor, fontSize: 12),
                             ),
                             const SizedBox(width: 4),
                             Text(
                               '(${AppUtils().formatNumberByTwoDigits(profitPercent)}%)',
                               style: TextStyle(color: profitColor, fontSize: 12),
                             ),
                           ],
                         ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransitionAssetChart extends StatefulWidget {
  final List<Map<String, dynamic>> datas;
  final String currencyCode;
  const _TransitionAssetChart({
    required this.datas,
    required this.currencyCode,
  });

  @override
  State<_TransitionAssetChart> createState() => _TransitionAssetChartState();
}

class _TransitionAssetChartState extends State<_TransitionAssetChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // 这里直接传完整 dataList
        return LineChartSample12(
          datas: widget.datas,
          currencyCode: widget.currencyCode,
          animationValue: _animation.value, // 0.0~1.0
        );
      },
    );
  }
}

// 平台自适应的区间选择器
class _PlatformRangeSelector extends StatelessWidget {
  const _PlatformRangeSelector({
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      // iOS/macOS: ActionSheet风格
      return _CupertinoRangeSelector(
        value: value,
        values: values,
        onChanged: onChanged,
      );
    }
    // 其它平台: Material Dropdown
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isDense: true,
        style: const TextStyle(fontSize: 13, color: Colors.black),
        borderRadius: BorderRadius.circular(10),
        items: values
            .map((v) => DropdownMenuItem<String>(value: v, child: Text(v)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _CupertinoRangeSelector extends StatelessWidget {
  const _CupertinoRangeSelector({
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  void _showPicker(BuildContext context) {
    final FixedExtentScrollController controller = FixedExtentScrollController(
      initialItem: values.indexOf(value),
    );
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 260,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () {
                      final picked = values[controller.selectedItem];
                      onChanged(picked);
                      Navigator.pop(context);
                    },
                    child: const Text('确定'),
                  ),
                ],
              ),
            ),
            const Divider(height: 0),
            Expanded(
              child: CupertinoPicker(
                scrollController: controller,
                itemExtent: 32,
                magnification: 1.1,
                squeeze: 1.0,
                onSelectedItemChanged: (_) {},
                children: values
                    .map(
                      (v) => Center(
                        child: Text(
                          v,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      minSize: 32,
      borderRadius: BorderRadius.circular(8),
      color: CupertinoColors.systemGrey5.resolveFrom(context),
      onPressed: () => _showPicker(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.black),
          ),
          const SizedBox(width: 4),
          const Icon(
            CupertinoIcons.chevron_down,
            size: 14,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
