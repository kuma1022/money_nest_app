import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/l10n/app_localizations_en.dart';
import 'package:money_nest_app/l10n/l10n_util.dart';
import 'package:money_nest_app/presentation/resources/app_resources.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountTabPage extends StatefulWidget {
  final AppDatabase db;

  const AccountTabPage({super.key, required this.db});

  @override
  State<AccountTabPage> createState() => AccountTabPageState();
}

class AccountTabPageState extends State<AccountTabPage> {
  final RefreshController _refreshController = RefreshController();
  RefreshController get refreshController => _refreshController;
  Currency _selectedCurrency = Currency.jpy;
  DateTime _assetFetchedTime = DateTime.now();
  double _totalProfit = 0;
  double _totalCost = 0;
  String _lastAsset = '';
  String _totalAsset = '';
  bool _assetVisible = true; // 资产是否可见
  bool _stockWalletExpanded = true; // 持仓卡片是否展开
  List<bool> _stockWalletMarketExpandedList = []; // 持仓卡片下的各个市场的展开状态

  Future<void> _onRefresh() async {
    await _refreshData();
    _refreshController.refreshCompleted();
  }

  // 获取总资产和时间
  Future<void> _fetchTotalAsset(AppDatabase db, Currency currency) async {
    // 实际股票资产计算逻辑
    double total = await _calculateAllStockValue(db, currency.code);
    setState(() {
      _totalAsset = NumberFormat.currency(
        locale: currency.locale,
        symbol: currency.symbol,
      ).format(total);
      _lastAsset = _totalAsset;
    });
  }

  // 这里模拟股票总价值计算，实际应从你的数据源获取
  Future<double> _calculateAllStockValue(
    AppDatabase db,
    String currencyCode,
  ) async {
    // 获取持仓股票的数据
    final stockDataList = await db.getAllStocksRecords();

    //for (var stock in stockDataList) {
    //  print(
    //    'Stock: ${stock.code}, Price: ${stock.currentPrice}, UpdatedAt: ${stock.priceUpdatedAt}',
    //  );
    // }

    List<Stock> newStockDataList = List.from(stockDataList);
    // 如果除了FX之外没有数据
    if (stockDataList.isEmpty ||
        newStockDataList.every((stock) => stock.marketCode == 'FOREX')) {
      return 0;
    }
    final marketDataList = await db.getAllMarketDataRecords();
    // 如果所有 priceUpdatedAt 都在周六或周日，则不更新
    bool allWeekend =
        stockDataList.isNotEmpty &&
        stockDataList.every((stock) {
          final dt = stock.priceUpdatedAt;
          if (dt == null) return false;
          return dt.weekday == DateTime.saturday ||
              dt.weekday == DateTime.sunday;
        });
    if (!allWeekend &&
        stockDataList.any(
          (stock) =>
              stock.priceUpdatedAt == null ||
              stock.priceUpdatedAt!.isBefore(
                DateTime.now().subtract(const Duration(hours: 1)),
              ),
        )) {
      // 调用YH Finance API 获取实时股票价格
      final stocks = await db.getAllStocks();
      final appUtils = AppUtils();
      print('Fetching stock prices...');
      final stockPrices = await appUtils.getStockPricesByYHFinanceAPI(
        stocks,
        marketDataList,
      );
      newStockDataList.clear();
      for (var stock in stockDataList) {
        newStockDataList.add(
          stock.copyWith(
            currentPrice: Value(
              stockPrices['${stock.code}${marketDataList.firstWhere(
                (m) => m.code == stock.marketCode,
                orElse: () => MarketDataData(code: '', name: '', surfix: '', sortOrder: 0, isActive: true),
              ).surfix}'],
            ),
          ),
        );
      }
      // 更新数据库中的股票价格和更新时间
      await db.updateStockPrices(newStockDataList);
    }

    Map<String, double> priceMap = {
      for (var stock in newStockDataList)
        if (stock.currentPrice != null) stock.code: stock.currentPrice!,
    };

    // 更新资产获取时间
    setState(
      () => _assetFetchedTime = stockDataList.isNotEmpty
          ? stockDataList.first.priceUpdatedAt ?? DateTime.now()
          : DateTime.now(),
    );

    // 遍历持仓列表，累加每只股票的市值
    final records = await db.getAllAvailableBuyRecords();
    return records.fold<double>(
      0,
      (sum, r) =>
          sum +
          r.quantity *
              priceMap[r.code]! *
              (priceMap['${r.currency.code != 'USD' ? r.currency.code : ''}$currencyCode'] ??
                  1.0),
    );
  }

  Future<void> _refreshData() async {
    await _fetchTotalAsset(widget.db, _selectedCurrency);
  }

  String _formatTime(DateTime time) {
    // 格式化为 HH:mm:ss 或 yyyy-MM-dd HH:mm
    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // 获取总盈亏金额（请用实际业务逻辑替换）
  Future<double> _getTotalProfit() async {
    // 取得所有持仓记录
    final records = await widget.db.getAllAvailableBuyRecords();
    final stocks = await widget.db.getAllStocks();
    final stockMap = {for (var stock in stocks) stock.code: stock};

    setState(
      () => _totalProfit = records.fold<double>(
        0,
        (sum, r) =>
            sum +
            (r.quantity *
                        (stockMap[r.code]?.currentPrice ?? 0) *
                        (r.currency.code != 'USD'
                            ? stockMap['${r.currency.code}${r.currencyUsed.code}']
                                      ?.currentPrice ??
                                  1
                            : stockMap[r.currencyUsed.code]?.currentPrice ??
                                  1) -
                    r.moneyUsed) *
                (r.currencyUsed.code != 'USD'
                    ? (stockMap['${r.currencyUsed.code}${_selectedCurrency.code}']
                              ?.currentPrice ??
                          1)
                    : (stockMap[_selectedCurrency.code]?.currentPrice ?? 1)),
      ),
    );

    // 计算总盈亏
    return _totalProfit;
  }

  // 获取总盈亏率（请用实际业务逻辑替换）
  Future<double> _getTotalProfitRate() async {
    // 取得所有持仓记录
    final records = await widget.db.getAllAvailableBuyRecords();
    final stocks = await widget.db.getAllStocks();
    final stockMap = {for (var stock in stocks) stock.code: stock};

    setState(
      () => _totalCost = records.fold<double>(
        0,
        (sum, r) =>
            sum +
            r.moneyUsed *
                (r.currencyUsed.code != 'USD'
                    ? (stockMap['${r.currencyUsed.code}${_selectedCurrency.code}']
                              ?.currentPrice ??
                          1)
                    : (stockMap[_selectedCurrency.code]?.currentPrice ?? 1)),
      ),
    );

    return _totalCost > 0 ? _totalProfit / _totalCost : 0;
  }

  String _formatProfit(double profit) {
    final symbol = profit > 0 ? '+' : (profit < 0 ? '-' : '');
    return '$symbol${NumberFormat.currency(locale: _selectedCurrency.locale, symbol: _selectedCurrency.symbol).format(profit.abs())}';
  }

  String _formatProfitRate(double rate) {
    final symbol = rate > 0 ? '+' : (rate < 0 ? '-' : '');
    return '$symbol${(rate.abs() * 100).toStringAsFixed(2)}%';
  }

  // 取得持仓的数据，并且生成相应的显示项目内容
  Future<List<Widget>> _buildAccountItems(AppLocalizations l10n) async {
    final markets = await widget.db.getAllMarketDataRecords();
    final records = await widget.db.getAllAvailableBuyRecords();
    final stocks = await widget.db.getAllStocks();
    final stockMap = {for (var stock in stocks) stock.code: stock};

    // 按 sortOrder 排序
    markets.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    List<Widget> items = [];
    int i = 0;

    for (final market in markets) {
      // 该市场下的持仓
      final marketRecords = records
          .where((r) => r.marketCode == market.code)
          .toList();
      if (marketRecords.isEmpty) continue;

      // 计算总金额、盈亏、盈亏率
      double total = 0;
      double profit = 0;
      double cost = 0;
      for (final r in marketRecords) {
        final stock = stockMap[r.code];
        if (stock == null) continue;
        final price = stock.currentPrice ?? 0;
        total += r.quantity * price;
        cost += (r.quantity * r.price);
      }
      profit = total - cost;
      final profitRate = cost > 0 ? profit / cost : 0;

      // 个别标的
      final subAccounts = marketRecords
          .map(
            (r) => _SubAccountItem(
              name: r.code,
              value: '${r.quantity} × ${stockMap[r.code]?.currentPrice ?? 0}',
            ),
          )
          .toList();

      // 生成_AccountItem
      if (_stockWalletMarketExpandedList.length <= i) {
        _stockWalletMarketExpandedList.add(false); // 默认收起
      }
      items.add(
        _AccountItem(
          name: getL10nStringFromL10n(l10n, market.name),
          total: NumberFormat.currency(
            locale: Currency.values
                .firstWhere((e) => e.code == market.currency)
                .locale,
            symbol: Currency.values
                .firstWhere((e) => e.code == market.currency)
                .symbol,
          ).format(total),
          profit: _formatProfit(profit),
          profitRate: _formatProfitRate(profitRate.toDouble()),
          currency: market.currency ?? 'USD',
          countryCode: _marketCountryCode(market.code), // 你需要实现这个方法
          subAccounts: subAccounts,
          expanded: _stockWalletMarketExpandedList[i], // 你的展开状态数组
          onArrowTap: () {
            setState(() {
              _stockWalletMarketExpandedList[i] =
                  !_stockWalletMarketExpandedList[i];
            });
          },
        ),
      );
      items.add(const SizedBox(height: 16));
    }
    return items;
  }

  // 你需要实现市场code到国旗code的映射
  String _marketCountryCode(String marketCode) {
    switch (marketCode) {
      case 'JP':
        return 'jp';
      case 'US':
        return 'us';
      case 'HK':
        return 'hk';
      default:
        return 'us';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        header: CustomHeader(
          builder: (context, mode) {
            String text;
            if (mode == RefreshStatus.idle) {
              text = AppLocalizations.of(
                context,
              )!.accountTabPageRefreshStatusIdleLabel;
            } else if (mode == RefreshStatus.canRefresh) {
              text = AppLocalizations.of(
                context,
              )!.accountTabPageRefreshStatusCanRefreshLabel;
            } else if (mode == RefreshStatus.refreshing) {
              text = AppLocalizations.of(
                context,
              )!.accountTabPageRefreshStatusRefreshingLabel;
            } else if (mode == RefreshStatus.completed) {
              text = AppLocalizations.of(
                context,
              )!.accountTabPageRefreshStatusCompletedLabel;
            } else {
              text = '';
            }
            return Container(
              height: 60,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sync, color: AppColors.appGreen),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: AppTexts.fontSizeSmall,
                      color: AppColors.appGreen,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          children: [
            // 总资产卡片
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.accountTabPageTotalMoneyTitle,
                          style: TextStyle(
                            fontSize: AppTexts.fontSizeLarge,
                            color: AppColors.appDarkGrey,
                          ),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<Currency>(
                            value: _selectedCurrency,
                            alignment: AlignmentDirectional.topStart,
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _selectedCurrency = v);
                                _fetchTotalAsset(widget.db, v);
                              }
                            },
                            items: Currency.values
                                .map(
                                  (c) => DropdownMenuItem<Currency>(
                                    value: c,
                                    child: Text(
                                      c.displayName(context),
                                      style: const TextStyle(
                                        fontSize: AppTexts.fontSizeSmall,
                                        color: AppColors.appDarkGrey,
                                        height: 1,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                                .toList(),
                            underline: const SizedBox.shrink(),
                            style: const TextStyle(
                              fontSize: AppTexts.fontSizeSmall,
                              color: AppColors.appDarkGrey,
                            ),
                            dropdownColor: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.analytics, size: 18),
                          label: Text(
                            AppLocalizations.of(
                              context,
                            )!.accountTabPageAccountAnalyseLabel,
                            style: TextStyle(fontSize: AppTexts.fontSizeSmall),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.appGreen,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    buildTotalAssetDisplay(
                      _totalAsset.isNotEmpty ? _totalAsset : _lastAsset,
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${AppLocalizations.of(context)!.accountTabPageUpadateAtTimeLabel}: ${_formatTime(_assetFetchedTime)}',
                              style: const TextStyle(
                                fontSize: AppTexts.fontSizeMini,
                                color: AppColors.appGrey,
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
            const SizedBox(height: 12),
            // 全部账户
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(
                            context,
                          )!.accountTabPageStockWalletTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            _stockWalletExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                          ),
                          onPressed: () {
                            setState(() {
                              _stockWalletExpanded = !_stockWalletExpanded;
                            });
                          },
                        ),
                      ],
                    ),
                    buildStockWalletDisplay(
                      _totalAsset.isNotEmpty ? _totalAsset : _lastAsset,
                    ),
                    const SizedBox(height: 32),
                    // 用 AnimatedSize 包裹内容
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _stockWalletExpanded
                          ? FutureBuilder<List<Widget>>(
                              future: _buildAccountItems(l10n),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox.shrink();
                                }
                                return Column(children: snapshot.data!);
                              },
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTotalAssetDisplay(String totalAsset) {
    return FutureBuilder<double>(
      future: _getTotalProfit(),
      builder: (context, profitSnapshot) {
        return FutureBuilder<double>(
          future: _getTotalProfitRate(),
          builder: (context, profitRateSnapshot) {
            double profit = profitSnapshot.data ?? 0.0;
            double profitRate = profitRateSnapshot.data ?? 0.0;
            Color profitColor;
            if (_assetVisible && profit > 0) {
              profitColor = Colors.green;
            } else if (_assetVisible && profit < 0) {
              profitColor = Colors.red;
            } else {
              profitColor = Colors.black;
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _assetVisible
                      ? (totalAsset.isNotEmpty ? totalAsset : '***')
                      : '***',
                  style: const TextStyle(
                    fontSize: AppTexts.fontSizeHuge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // 资产显示与否icon
                IconButton(
                  icon: Icon(
                    _assetVisible ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.appGrey,
                  ),
                  onPressed: () {
                    setState(() {
                      _assetVisible = !_assetVisible;
                    });
                  },
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _assetVisible ? _formatProfit(profit) : '***',
                      style: TextStyle(
                        fontSize: AppTexts.fontSizeSmall,
                        color: profitColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _assetVisible ? _formatProfitRate(profitRate) : '***',
                      style: TextStyle(
                        fontSize: AppTexts.fontSizeSmall,
                        color: profitColor,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildStockWalletDisplay(String totalAsset) {
    return FutureBuilder<double>(
      future: _getTotalProfit(),
      builder: (context, profitSnapshot) {
        return FutureBuilder<double>(
          future: _getTotalProfitRate(),
          builder: (context, profitRateSnapshot) {
            double profit = profitSnapshot.data ?? 0.0;
            double profitRate = profitRateSnapshot.data ?? 0.0;
            Color profitColor;
            if (_assetVisible && profit > 0) {
              profitColor = Colors.green;
            } else if (_assetVisible && profit < 0) {
              profitColor = Colors.red;
            } else {
              profitColor = Colors.black;
            }
            return Row(
              mainAxisSize: MainAxisSize.max, // 让Row占满父容器宽度
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // 两端对齐
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 金额靠左
                Text(
                  _assetVisible
                      ? (totalAsset.isNotEmpty ? totalAsset : '***')
                      : '***',
                  style: const TextStyle(
                    fontSize: AppTexts.fontSizeLarge,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.left,
                ),
                // 盈亏靠右
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _assetVisible ? _formatProfit(profit) : '***',
                      style: TextStyle(
                        fontSize: AppTexts.fontSizeSmall,
                        color: profitColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _assetVisible ? _formatProfitRate(profitRate) : '***',
                      style: TextStyle(
                        fontSize: AppTexts.fontSizeSmall,
                        color: profitColor,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// Move these widget classes outside of _AccountTabPageState

class _AccountItem extends StatelessWidget {
  final String name;
  final String total;
  final String profit;
  final String profitRate;
  final String currency;
  final String countryCode;
  final List<_SubAccountItem>? subAccounts;
  final bool expanded;
  final VoidCallback? onArrowTap;

  const _AccountItem({
    required this.name,
    required this.total,
    required this.profit,
    required this.profitRate,
    required this.currency,
    required this.countryCode,
    this.subAccounts,
    this.expanded = false, // 默认收起
    this.onArrowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // 国旗icon
            SizedBox(
              width: 18,
              height: 18,
              child: ClipOval(
                child: SvgPicture.asset(
                  'packages/country_icons/icons/flags/svg/$countryCode.svg',
                  width: 18,
                  height: 18,
                  fit: BoxFit.cover, // 关键
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  total,
                  style: const TextStyle(
                    fontSize: AppTexts.fontSizeSmall,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      profit,
                      style: TextStyle(
                        color: profit.startsWith('-')
                            ? Colors.red
                            : profit.startsWith('+')
                            ? Colors.green
                            : Colors.black,
                        fontSize: AppTexts.fontSizeMini,
                      ),
                    ),
                    if (profitRate.isNotEmpty)
                      Text(
                        '  $profitRate',
                        style: TextStyle(
                          color: profit.startsWith('-')
                              ? Colors.red
                              : profit.startsWith('+')
                              ? Colors.green
                              : Colors.black,
                          fontSize: AppTexts.fontSizeMini,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            // 箭头icon
            IconButton(
              icon: Icon(
                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: AppColors.appGrey,
                size: 20,
              ),
              onPressed: onArrowTap,
            ),
          ],
        ),
        if (subAccounts != null) ...[
          const SizedBox(height: 12),
          ...subAccounts!,
        ],
      ],
    );
  }
}

class _SubAccountItem extends StatelessWidget {
  final String name;
  final String value;
  const _SubAccountItem({required this.name, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: AppTexts.fontSizeSmall,
              color: AppColors.appGrey,
            ),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: AppTexts.fontSizeSmall)),
        ],
      ),
    );
  }
}
