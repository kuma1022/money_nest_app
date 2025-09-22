import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
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
  Currency _selectedCurrency = Currency.values.first;
  DateTime _assetFetchedTime = DateTime.now();
  double _totalProfit = 0;
  double _totalCost = 0;
  String _lastAsset = '';
  String _totalAsset = '';
  bool _assetVisible = true; // 资产是否可见
  bool _stockWalletExpanded = true; // 持仓卡片是否展开
  final Map<String, bool> _stockWalletMarketExpandedMap = {}; // 持仓卡片下的各个市场的展开状态

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
    /*// 获取持仓股票的数据
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
    );*/
    return 0.0;
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
    /*
    // 取得所有持仓记录
    final records = await widget.db.getAllAvailableBuyRecords();
    final stocks = await widget.db.getAllStocks();
    final stockMap = {for (var stock in stocks) stock.code: stock};

    setState(
      () => _totalProfit = records.fold<double>(0, (sum, r) {
        final stock = stockMap[r.code];
        final currentPrice = stock?.currentPrice ?? r.price;
        final stockCurrency = stock?.currency ?? r.currencyUsed.code;

        // 1. 当前市值换算成 moneyUsed 币种
        double fxToMoneyUsed = 1.0;
        if (stockCurrency != r.currencyUsed.code) {
          final fxCode = stockCurrency != 'USD'
              ? '$stockCurrency${r.currencyUsed.code}'
              : r.currencyUsed.code;
          fxToMoneyUsed = stockMap[fxCode]?.currentPrice ?? 1.0;
        }
        final marketValueInMoneyUsed =
            r.quantity * currentPrice * fxToMoneyUsed;

        // 2. 盈亏（moneyUsed币种）
        final profitInMoneyUsed = marketValueInMoneyUsed - r.moneyUsed;

        // 3. 盈亏换算成当前选中币种
        double fxToSelected = 1.0;
        if (r.currencyUsed.code != _selectedCurrency.code) {
          final fxCode = r.currencyUsed.code != 'USD'
              ? '${r.currencyUsed.code}${_selectedCurrency.code}'
              : _selectedCurrency.code;
          fxToSelected = stockMap[fxCode]?.currentPrice ?? 1.0;
        }
        final profitInSelected = profitInMoneyUsed * fxToSelected;

        return sum + profitInSelected;
      }),
    );

    // 计算总盈亏
    return _totalProfit;
    */
    return 0.0;
  }

  // 获取总盈亏率（请用实际业务逻辑替换）
  Future<double> _getTotalProfitRate() async {
    /*// 取得所有持仓记录
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

    return _totalCost > 0 ? _totalProfit / _totalCost : 0;*/
    return 0.0;
  }

  String _formatProfit(double profit, Currency currency) {
    final symbol = profit > 0 ? '+' : (profit < 0 ? '-' : '');
    return '$symbol${NumberFormat.currency(locale: currency.locale, symbol: currency.symbol).format(profit.abs())}';
  }

  String _formatProfitRate(double rate) {
    final symbol = rate > 0 ? '+' : (rate < 0 ? '-' : '');
    return '$symbol${(rate.abs() * 100).toStringAsFixed(2)}%';
  }

  // 取得持仓的数据，并且生成相应的显示项目内容
  Future<List<Widget>> _buildAccountItems(AppLocalizations l10n) async {
    /*final markets = await widget.db.getAllMarketDataRecords();
    final records = await widget.db.getAllAvailableBuyRecords();
    final stocks = await widget.db.getAllStocks();
    final stockMap = {for (var stock in stocks) stock.code: stock};

    // 按 sortOrder 排序
    markets.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    List<Widget> items = [];

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
      Map<String, TradeRecord> mergedRecords = {}; // 合并同 code 的持仓
      for (final r in marketRecords) {
        final stock = stockMap[r.code];
        if (stock == null) continue;
        final price = stock.currentPrice ?? 0;
        total += r.quantity * price;
        cost += (r.quantity * r.price);

        // 合并同 code 的持仓
        if (mergedRecords.containsKey(r.code)) {
          final old = mergedRecords[r.code]!;
          mergedRecords[r.code] = old.copyWith(
            quantity: old.quantity + r.quantity,
            price:
                ((old.price * old.quantity) + (r.price * r.quantity)) /
                (old.quantity + r.quantity),
          );
        } else {
          mergedRecords[r.code] = r;
        }
      }
      profit = total - cost;
      final profitRate = cost > 0 ? profit / cost : 0;
      final mergedRecordList = mergedRecords.values.toList();

      // 用 market.code 作为 key
      final expanded = _stockWalletMarketExpandedMap[market.code] ?? false;

      items.add(const SizedBox(height: 8));

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
          profit: _formatProfit(
            profit,
            Currency.values.firstWhere((e) => e.code == market.currency),
          ),
          profitRate: _formatProfitRate(profitRate.toDouble()),
          currency: market.currency ?? 'USD',
          countryCode: _marketCountryCode(market.code), // 你需要实现这个方法
          tradeRecords: mergedRecordList,
          stocks: stockMap,
          expanded: expanded, // 你的展开状态数组
          onArrowTap: () {
            setState(() {
              _stockWalletMarketExpandedMap[market.code] = !expanded;
            });
          },
          assetVisible: _assetVisible,
        ),
      );
      items.add(
        const Divider(
          color: AppColors.appLightGrey,
          thickness: 1,
          height: 20, // 间隔高度
          indent: 0,
          endIndent: 0,
        ),
      );
    }
    return items;*/
    return [];
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
                side: const BorderSide(color: AppColors.appLightGrey, width: 1),
              ),
              elevation: 0, // 不加阴影
              color: AppColors.appWhite, // 白色
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
            // 持仓
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.appLightGrey, width: 1),
              ),
              elevation: 0,
              color: AppColors.appWhite, // 白色
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(8), // 可选：点击有圆角水波
                      onTap: () {
                        setState(() {
                          _stockWalletExpanded = !_stockWalletExpanded;
                        });
                      },
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.accountTabPageStockWalletTitle,
                                style: const TextStyle(
                                  fontSize: AppTexts.fontSizeMedium,
                                  color: AppColors.appDarkGrey,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                _stockWalletExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                            ],
                          ),
                          buildStockWalletDisplay(
                            _totalAsset.isNotEmpty ? _totalAsset : _lastAsset,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),
                    if (_stockWalletExpanded)
                      const Divider(
                        color: AppColors.appLightGrey,
                        thickness: 1,
                        height: 24,
                        indent: 0,
                        endIndent: 0,
                      ),

                    // 无动画，立即显示/隐藏
                    _stockWalletExpanded
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
              profitColor = AppColors.appUpGreen;
            } else if (_assetVisible && profit < 0) {
              profitColor = AppColors.appDownRed;
            } else {
              profitColor = Colors.black;
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _assetVisible
                      ? (totalAsset.isNotEmpty ? totalAsset : '*****')
                      : '*****',
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
                      _assetVisible
                          ? _formatProfit(profit, _selectedCurrency)
                          : '***',
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
              profitColor = AppColors.appUpGreen;
            } else if (_assetVisible && profit < 0) {
              profitColor = AppColors.appDownRed;
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
                      ? (totalAsset.isNotEmpty ? totalAsset : '*****')
                      : '*****',
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
                      _assetVisible
                          ? _formatProfit(profit, _selectedCurrency)
                          : '***',
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
  final List<TradeRecord>? tradeRecords;
  final Map<String, Stock>? stocks;
  final bool expanded;
  final VoidCallback? onArrowTap;
  final bool assetVisible;

  const _AccountItem({
    required this.name,
    required this.total,
    required this.profit,
    required this.profitRate,
    required this.currency,
    required this.countryCode,
    this.tradeRecords,
    this.stocks,
    this.expanded = false, // 默认收起
    this.onArrowTap,
    this.assetVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    // 动态生成表格数据
    final double totalMarketValue =
        //tradeRecords?.fold<double>(
        //  0,
        //  (sum, r) => sum + (r.quantity * (stocks?[r.code]?.currentPrice ?? 0)),
        //) ??
        0.0;
    final data =
        tradeRecords?.map((r) {
          /*
          // 你需要根据实际 TradeRecord 字段调整
          return {
            'name': stocks?[r.code]?.name ?? r.code, // 股票名称或代码
            'code': r.code,
            'marketValue': NumberFormat(
              '#,##0.00',
            ).format(r.quantity * (stocks?[r.code]?.currentPrice ?? 0)),
            'quantity': (r.quantity % 1 == 0)
                ? r.quantity.toInt().toString()
                : r.quantity.toString(),
            'cost': NumberFormat('#,##0.00').format(r.quantity * r.price),
            'marketPrice': NumberFormat(
              '#,##0.00',
            ).format(stocks?[r.code]?.currentPrice ?? 0),
            'costPrice': NumberFormat('#,##0.00').format(r.price),
            'position': totalMarketValue > 0
                ? '${(r.quantity * (stocks?[r.code]?.currentPrice ?? 0) / totalMarketValue * 100).toStringAsFixed(2)}%'
                : '0.00%',
          };
          */
          return {};
        }).toList() ??
        [];

    data.sort((a, b) {
      // 提取数字部分进行比较
      double posA =
          double.tryParse((a['position'] as String).replaceAll('%', '')) ?? 0;
      double posB =
          double.tryParse((b['position'] as String).replaceAll('%', '')) ?? 0;
      return posB.compareTo(posA); // 降序
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8), // 可选：点击有圆角水波
          onTap: onArrowTap,
          child: Row(
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
              const SizedBox(width: 16),
              Text(
                assetVisible ? total : '*****',
                style: const TextStyle(
                  fontSize: AppTexts.fontSizeSmall,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        assetVisible ? profit : '***',
                        style: TextStyle(
                          color: assetVisible && profit.startsWith('-')
                              ? AppColors.appDownRed
                              : assetVisible && profit.startsWith('+')
                              ? AppColors.appUpGreen
                              : Colors.black,
                          fontSize: AppTexts.fontSizeMini,
                        ),
                      ),
                      if (profitRate.isNotEmpty)
                        Text(
                          '  ${assetVisible ? profitRate : '***'}',
                          style: TextStyle(
                            color: assetVisible && profit.startsWith('-')
                                ? AppColors.appDownRed
                                : assetVisible && profit.startsWith('+')
                                ? AppColors.appUpGreen
                                : Colors.black,
                            fontSize: AppTexts.fontSizeMini,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              // 箭头icon
              Icon(
                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: AppColors.appGrey,
                size: 20,
              ),
            ],
          ),
        ),
        if (expanded) ...[
          // 展开内容
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SizedBox(
                height: data.length * 48.0 + 40, // 估算高度
                child: Stack(
                  children: [
                    // 右侧可滑动部分
                    Padding(
                      padding: const EdgeInsets.only(left: 90),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: [
                            // 表头
                            Row(
                              children: const [
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    '市值/数量',
                                    style: TextStyle(
                                      fontSize: AppTexts.fontSizeSmall,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 90,
                                  child: Text(
                                    '现价/成本',
                                    style: TextStyle(
                                      fontSize: AppTexts.fontSizeSmall,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    '持仓占比',
                                    style: TextStyle(
                                      fontSize: AppTexts.fontSizeSmall,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 90,
                                  child: Text(
                                    '当前盈亏',
                                    style: TextStyle(
                                      fontSize: AppTexts.fontSizeSmall,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // 右侧表头下方也加 Divider
                            SizedBox(
                              width: 370, // 110+90+80+90
                              child: Divider(
                                thickness: 1,
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            // 数据行
                            ...data.asMap().entries.map((entry) {
                              final row = entry.value;
                              final double marketValue =
                                  double.tryParse(
                                    row['marketValue']!.replaceAll(',', ''),
                                  ) ??
                                  0;
                              final double cost =
                                  double.tryParse(
                                    row['cost']!.replaceAll(',', ''),
                                  ) ??
                                  0;
                              final double profit = marketValue - cost;
                              final profitStr =
                                  (profit > 0
                                      ? '+'
                                      : profit < 0
                                      ? '-'
                                      : '') +
                                  NumberFormat('#,##0.00').format(profit.abs());
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ), // 行高
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 110,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            assetVisible
                                                ? row['marketValue']!
                                                : '***',
                                            style: const TextStyle(
                                              fontSize: AppTexts.fontSizeSmall,
                                            ),
                                          ),
                                          Text(
                                            assetVisible
                                                ? row['quantity']!
                                                : '***',
                                            style: const TextStyle(
                                              fontSize: AppTexts.fontSizeMini,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 90,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            assetVisible
                                                ? row['marketPrice']!
                                                : '***',
                                            style: const TextStyle(
                                              fontSize: AppTexts.fontSizeSmall,
                                            ),
                                          ),
                                          Text(
                                            assetVisible
                                                ? row['costPrice']!
                                                : '***',
                                            style: const TextStyle(
                                              fontSize: AppTexts.fontSizeMini,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: Text(
                                        assetVisible ? row['position']! : '***',
                                        style: const TextStyle(
                                          fontSize: AppTexts.fontSizeSmall,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 90,
                                      child: Text(
                                        assetVisible ? profitStr : '***',
                                        style: TextStyle(
                                          fontSize: AppTexts.fontSizeSmall,
                                          color: profit > 0
                                              ? AppColors.appUpGreen
                                              : profit < 0
                                              ? AppColors.appDownRed
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    // 左侧固定列
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: SizedBox(
                        width: 90,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 左侧表头
                              Container(
                                height: 21, // 与右侧表头一致
                                alignment: Alignment.centerLeft,
                                child: const Text(
                                  '名称代码',
                                  style: TextStyle(
                                    fontSize: AppTexts.fontSizeSmall,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              // 左侧表头下方也加 Divider
                              const Divider(
                                thickness: 1,
                                color: Color(0xFFE0E0E0),
                              ),
                              ...data.map(
                                (row) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ), // 行高
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        assetVisible ? row['name']! : '*****',
                                        style: const TextStyle(
                                          fontSize: AppTexts.fontSizeSmall,
                                        ),
                                      ),
                                      Text(
                                        assetVisible ? row['code']! : '***',
                                        style: const TextStyle(
                                          fontSize: AppTexts.fontSizeMini,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
