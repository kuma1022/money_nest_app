import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_nest_app/components/card_section.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/pages/main_page.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/presentation/resources/app_texts.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:money_nest_app/util/provider/total_asset_provider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PortfolioTab extends StatefulWidget {
  final AppDatabase db;

  const PortfolioTab({super.key, required this.db});

  @override
  State<PortfolioTab> createState() => PortfolioTabState();
}

class PortfolioTabState extends State<PortfolioTab>
    with TickerProviderStateMixin {
  final RefreshController _refreshController = RefreshController();
  RefreshController get refreshController => _refreshController;
  Map<String, dynamic>? selectedStock;
  late TabController _tabController;
  Currency _selectedCurrency = Currency.values.first;
  double _totalProfit = 0;
  double _totalCost = 0;
  bool _assetVisible = true; // 资产是否可见

  Future<void> _onRefresh() async {
    await _refreshData();
    _refreshController.refreshCompleted();
  }

  Future<void> _refreshData() async {
    // 在 PortfolioTab、HomeTab 等
    Provider.of<TotalAssetProvider>(
      context,
      listen: false,
    ).setTotalAsset(''); // 先清空或标记
    Provider.of<TotalAssetProvider>(
      context,
      listen: false,
    ).fetchTotalAsset(widget.db, _selectedCurrency);
  }

  final portfolioCategories = {
    'japanStocks': {
      'name': '日本株',
      'totalValue': 750000,
      'gain': 125000,
      'gainPercent': 20.0,
      'stocks': [
        {
          'symbol': '7203',
          'name': 'トヨタ自動車',
          'shares': 100,
          'price': 2500,
          'value': 250000,
          'gain': 50000,
          'gainPercent': 25.0,
        },
        {
          'symbol': '6758',
          'name': 'ソニー',
          'shares': 50,
          'price': 8000,
          'value': 400000,
          'gain': 75000,
          'gainPercent': 23.1,
        },
        {
          'symbol': '9984',
          'name': 'ソフトバンク',
          'shares': 200,
          'price': 500,
          'value': 100000,
          'gain': 0,
          'gainPercent': 0,
        },
      ],
    },
    'usStocks': {
      'name': '米国株',
      'totalValue': 450000,
      'gain': 75000,
      'gainPercent': 20.0,
      'stocks': [
        {
          'symbol': 'AAPL',
          'name': 'Apple Inc.',
          'shares': 10,
          'price': 18000,
          'value': 180000,
          'gain': 30000,
          'gainPercent': 20.0,
        },
        {
          'symbol': 'MSFT',
          'name': 'Microsoft',
          'shares': 5,
          'price': 42000,
          'value': 210000,
          'gain': 35000,
          'gainPercent': 20.0,
        },
        {
          'symbol': 'GOOGL',
          'name': 'Alphabet',
          'shares': 2,
          'price': 30000,
          'value': 60000,
          'gain': 10000,
          'gainPercent': 20.0,
        },
      ],
    },
    'cash': {'name': '現金', 'totalValue': 250000, 'gain': 0, 'gainPercent': 0},
  };

  int get totalPortfolioValue => portfolioCategories.values
      .map((cat) => cat['totalValue'] as int)
      .reduce((a, b) => a + b);

  // 获取总盈亏金额（请用实际业务逻辑替换）
  Future<double> _getTotalProfit() async {
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

  String _formatProfit(double profit, Currency currency) {
    final symbol = profit > 0 ? '+' : (profit < 0 ? '-' : '');
    return '$symbol${NumberFormat.currency(locale: currency.locale, symbol: currency.symbol).format(profit.abs())}';
  }

  String _formatProfitRate(double rate) {
    final symbol = rate > 0 ? '+' : (rate < 0 ? '-' : '');
    return '$symbol${(rate.abs() * 100).toStringAsFixed(2)}%';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // 初始化总资产
    //_fetchTotalAsset(widget.db, _selectedCurrency);
  }

  @override
  Widget build(BuildContext context) {
    final totalAsset = context.watch<TotalAssetProvider>().totalAsset;

    if (selectedStock != null) {
      return StockDetail(
        stock: selectedStock!,
        totalPortfolioValue: totalPortfolioValue,
        onBack: () => setState(() => selectedStock = null),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
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
        child: Column(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FutureBuilder<double>(
                    future: _getTotalProfit(),
                    builder: (context, profitSnapshot) {
                      return FutureBuilder<double>(
                        future: _getTotalProfitRate(),
                        builder: (context, profitRateSnapshot) {
                          double profit = profitSnapshot.data ?? 0.0;
                          double profitRate = profitRateSnapshot.data ?? 0.0;
                          Color profitColor;
                          Color profitLightColor;
                          if (_assetVisible && profit > 0) {
                            profitColor = AppColors.appUpGreen;
                            profitLightColor = AppColors.appLightGreen;
                          } else if (_assetVisible && profit < 0) {
                            profitColor = AppColors.appDownRed;
                            profitLightColor = AppColors.appLightRed;
                          } else {
                            profitColor = AppColors.appDarkGrey;
                            profitLightColor = AppColors.appLightGrey;
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.mainPageAccountTitle,
                                    style: const TextStyle(
                                      fontSize: AppTexts.fontSizeMedium,
                                      color: AppColors.appDarkGrey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  // 资产显示与否icon
                                  IconButton(
                                    icon: Icon(
                                      _assetVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: AppColors.appGrey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _assetVisible = !_assetVisible;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 40, // 你可以根据实际字体高度微调
                                child: Center(
                                  child: Text(
                                    _assetVisible
                                        ? (totalAsset.isNotEmpty
                                              ? totalAsset
                                              : '*****')
                                        : '*****',
                                    style: const TextStyle(
                                      fontSize: AppTexts.fontSizeHuge,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 24, // 固定高度，可根据实际内容微调
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: profitLightColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: IntrinsicWidth(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (_assetVisible && profit != 0) ...[
                                          Icon(
                                            profit > 0
                                                ? Icons.trending_up
                                                : Icons.trending_down,
                                            color: profitColor,
                                            size: AppTexts.fontSizeExtraLarge,
                                          ),
                                        ],
                                        const SizedBox(width: 4),
                                        Text(
                                          textAlign: TextAlign.center,
                                          _assetVisible
                                              ? '${_formatProfit(profit, _selectedCurrency)} (${_formatProfitRate(profitRate)})'
                                              : '***',
                                          style: TextStyle(
                                            color: profitColor,
                                            fontSize: AppTexts.fontSizeSmall,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              //const SizedBox(height: 20),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: '概要'),
                Tab(text: '配分'),
                Tab(text: 'パフォーマンス'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 概要
                  ListView(
                    children: portfolioCategories.entries.map((entry) {
                      final category = entry.value;
                      return Card(
                        margin: EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    category['name'] as String,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '¥${category['totalValue']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              ((category['gain'] ?? 0)
                                                      as num) >=
                                                  0
                                              ? Colors.green[50]
                                              : Colors.red[50],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              ((category['gain'] ?? 0)
                                                          as num) >=
                                                      0
                                                  ? Icons.trending_up
                                                  : Icons.trending_down,
                                              color:
                                                  ((category['gain'] ?? 0)
                                                          as num) >=
                                                      0
                                                  ? Colors.green
                                                  : Colors.red,
                                              size: 16,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '¥${((category['gain'] ?? 0) as num).abs()} (${category['gainPercent']}%)',
                                              style: TextStyle(
                                                color:
                                                    ((category['gain'] ?? 0)
                                                            as num) >=
                                                        0
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (category['stocks'] != null)
                                ...((category['stocks'] as List)
                                    .map<Widget>(
                                      (stock) => InkWell(
                                        onTap: () => setState(
                                          () => selectedStock = stock,
                                        ),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    stock['symbol'],
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    stock['name'],
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    '¥${stock['value']}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${stock['gain'] >= 0 ? '+' : ''}¥${stock['gain']}',
                                                    style: TextStyle(
                                                      color: stock['gain'] >= 0
                                                          ? Colors.green
                                                          : Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Icon(
                                                Icons.chevron_right,
                                                color: Colors.grey,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList()),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  // 配分
                  ListView(
                    children: [
                      Card(
                        margin: EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: portfolioCategories.entries.map((entry) {
                              final category = entry.value;
                              final percentage =
                                  ((category['totalValue'] ?? 0) as num) /
                                  totalPortfolioValue *
                                  100;
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(category['name'] as String),
                                      Text('${percentage.toStringAsFixed(1)}%'),
                                    ],
                                  ),
                                  LinearProgressIndicator(
                                    value: percentage / 100,
                                    minHeight: 8,
                                    backgroundColor: Colors.grey[200],
                                    color: Colors.blue,
                                  ),
                                  Text(
                                    '¥${category['totalValue']}',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // パフォーマンス
                  ListView(
                    children: [
                      Card(
                        margin: EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          '総利益',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        Text(
                                          '¥200,000',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '+16.0%',
                                          style: TextStyle(color: Colors.green),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(
                                          '年間利回り',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        Text(
                                          '18.5%',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '予想',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'セクター別パフォーマンス',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              sectorRow('テクノロジー', '+22.5%', Colors.green),
                              sectorRow('自動車', '+15.2%', Colors.green),
                              sectorRow('通信', '-2.1%', Colors.red),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectorRow(String name, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class StockDetail extends StatelessWidget {
  final Map<String, dynamic> stock;
  final int totalPortfolioValue;
  final VoidCallback onBack;

  const StockDetail({
    super.key,
    required this.stock,
    required this.totalPortfolioValue,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final marketInfo = {
      'prevClose': stock['price'] - 100,
      'dayHigh': stock['price'] + 150,
      'dayLow': stock['price'] - 150,
      'volume': 500000,
      'marketCap': 5000000,
    };
    final dayChange = stock['price'] - marketInfo['prevClose'];
    final dayChangePercent = dayChange / marketInfo['prevClose'] * 100;

    final recentTransactions = [
      {
        'date': '2024-08-20',
        'type': 'buy',
        'quantity': 50,
        'price': stock['price'] - 100,
      },
      {
        'date': '2024-07-15',
        'type': 'buy',
        'quantity': 30,
        'price': stock['price'] - 300,
      },
      {
        'date': '2024-06-10',
        'type': 'buy',
        'quantity': 20,
        'price': stock['price'] - 500,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('${stock['symbol']}'),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: onBack),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Center(
            child: Text('${stock['name']}', style: TextStyle(fontSize: 18)),
          ),
          Center(
            child: Text(
              '¥${stock['price']}',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  dayChange >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: dayChange >= 0 ? Colors.green : Colors.red,
                ),
                SizedBox(width: 4),
                Text(
                  '¥${dayChange.abs()} (${dayChangePercent.toStringAsFixed(2)}%)',
                  style: TextStyle(
                    color: dayChange >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('市場情報', style: TextStyle(fontWeight: FontWeight.bold)),
                  infoRow('前日終値', '¥${marketInfo['prevClose']}'),
                  infoRow(
                    '出来高',
                    '${(marketInfo['volume'] / 1000).toStringAsFixed(0)}K',
                  ),
                  infoRow('日高', '¥${marketInfo['dayHigh']}'),
                  infoRow('日安', '¥${marketInfo['dayLow']}'),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('保有情報', style: TextStyle(fontWeight: FontWeight.bold)),
                  infoRow('保有株数', '${stock['shares']}株'),
                  infoRow(
                    '平均取得価格',
                    '¥${((stock['value'] - stock['gain']) / stock['shares']).toStringAsFixed(0)}',
                  ),
                  infoRow('現在価値', '¥${stock['value']}'),
                  infoRow(
                    '評価損益',
                    '¥${stock['gain']} (${stock['gainPercent']}%)',
                    color: stock['gain'] >= 0 ? Colors.green : Colors.red,
                  ),
                  infoRow(
                    '投資比率',
                    '${(stock['value'] / totalPortfolioValue * 100).toStringAsFixed(1)}%',
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('最近の取引', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...recentTransactions.map(
                    (tx) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tx['type'] == 'buy' ? '買い' : '売り',
                            style: TextStyle(color: Colors.blue),
                          ),
                          Text(
                            tx['date'],
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text('${tx['quantity']}株'),
                          Text('¥${tx['price']}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {}, // 卖出
                  child: Text('売却', style: TextStyle(color: Colors.red)),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {}, // 追加購入
                  child: Text('追加購入'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget infoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}
