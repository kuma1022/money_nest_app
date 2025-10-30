import 'package:drift/drift.dart' hide Column;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:money_nest_app/components/card_section.dart';
import 'package:money_nest_app/components/custom_tab.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:intl/intl.dart';
import 'package:money_nest_app/util/global_store.dart';
import 'package:money_nest_app/pages/assets/stock/domestic_stock_detail_page.dart';
import 'package:money_nest_app/pages/assets/stock/us_stock_detail_page.dart';

class StockDetailPage extends StatefulWidget {
  final AppDatabase db;
  final ScrollController? scrollController;

  const StockDetailPage({super.key, required this.db, this.scrollController});

  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  List<Map<String, dynamic>> domesticStocks = [];
  List<Map<String, dynamic>> usStocks = [];
  List<Map<String, dynamic>> otherStocks = [];
  List<TradeRecord> tradeHistory = [];
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isInitializing = true;
    });

    try {
      await _loadStockData();
      await _loadTradeHistory();
    } catch (e) {
      print('Error in _initializeData: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('データの読み込みに失敗しました')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _loadStockData() async {
    final userId = GlobalStore().userId;
    final accountId = GlobalStore().accountId;

    if (userId == null || accountId == null) return;

    // 计算持仓并更新到 GlobalStore
    await AppUtils().calculatePortfolioValue(userId, accountId);
    await AppUtils().calculateAndSaveHistoricalPortfolioToPrefs();

    // 按股票分组计算持仓（参考 domestic_stock_detail_page.dart 的做法）
    final Map<int, Map<String, dynamic>> stockPositions = {};

    for (final trade in GlobalStore().portfolio) {
      final stockId = trade['stockId'] as int?;
      final code = trade['code'] as String?;
      final exchange = trade['exchange'] as String?;
      final tradeDate = trade['tradeDate'] != null
          ? trade['tradeDate'] is String
                ? DateTime.parse(trade['tradeDate'] as String)
                : trade['tradeDate'] as DateTime
          : null;
      final quantity = trade['quantity'] as double?;
      final buyPrice = trade['buyPrice'] as double?;

      if (stockId == null ||
          code == null ||
          code.isEmpty ||
          tradeDate == null ||
          quantity == null ||
          buyPrice == null) {
        continue;
      }

      final name = trade['name'] as String?;
      final nameUs = trade['nameUs'] as String?;
      final logo = trade['logo'] as String?;
      final fee = trade['fee'] as double?;
      final feeCurrency = trade['feeCurrency'] as String?;

      if (!stockPositions.containsKey(stockId)) {
        stockPositions[stockId] = {
          'stockId': stockId,
          'code': code,
          'name': name,
          'nameUs': nameUs,
          'logo': logo,
          'exchange': exchange,
          'totalQuantity': 0.0,
          'totalCost': 0.0,
          'trades': [],
        };
      }

      stockPositions[stockId]!['trades'].add({
        'quantity': quantity,
        'buyPrice': buyPrice,
        'tradeDate': tradeDate,
        'fee': fee,
        'feeCurrency': feeCurrency,
      });

      stockPositions[stockId]!['totalQuantity'] += quantity;
      stockPositions[stockId]!['totalCost'] +=
          quantity * buyPrice + (fee ?? 0.0);
    }

    // 计算当前价值和总评价额
    double totalPortfolioValue = 0.0;
    final Map<int, Map<String, dynamic>> stockSummary = {};
    final usdToJpyRate = GlobalStore().currentStockPrices['JPY=X'] ?? 150.0;

    for (final entry in stockPositions.entries) {
      final position = entry.value;

      if (position['totalQuantity'] <= 0) continue;

      final exchange = position['exchange'] as String;
      final avgPrice = position['totalCost'] / position['totalQuantity'];
      final currentPrice =
          GlobalStore().currentStockPrices[position['code']] ?? avgPrice;

      double totalValueJPY;
      double profitJPY;
      double profitRate;

      if (exchange == 'US') {
        // 美股计算（参考 us_stock_detail_page.dart）
        final totalValueUSD = position['totalQuantity'] * currentPrice;
        final profitUSD = totalValueUSD - position['totalCost'];

        totalValueJPY = totalValueUSD * usdToJpyRate;
        profitJPY = profitUSD * usdToJpyRate;
        profitRate = position['totalCost'] > 0
            ? (profitUSD / position['totalCost']) * 100
            : 0.0;
      } else {
        // 日股计算（参考 domestic_stock_detail_page.dart）
        totalValueJPY = position['totalQuantity'] * currentPrice;
        profitJPY = totalValueJPY - position['totalCost'];
        profitRate = position['totalCost'] > 0
            ? (profitJPY / position['totalCost']) * 100
            : 0.0;
      }

      totalPortfolioValue += totalValueJPY;

      stockSummary[entry.key] = {
        'stockId': position['stockId'],
        'code': position['code'],
        'name': position['name'],
        'nameUs': position['nameUs'],
        'logo': position['logo'],
        'exchange': exchange,
        'totalQuantity': position['totalQuantity'],
        'totalValueJPY': totalValueJPY,
        'profitJPY': profitJPY,
        'profitRate': profitRate,
        'totalCost': position['totalCost'],
        'trades': position['trades'],
      };
    }

    // 计算保有割合
    for (final stock in stockSummary.values) {
      stock['holdingRatio'] = totalPortfolioValue > 0
          ? (stock['totalValueJPY'] / totalPortfolioValue) * 100
          : 0.0;
    }

    // 按市场分类股票
    List<Map<String, dynamic>> domestic = [];
    List<Map<String, dynamic>> us = [];
    List<Map<String, dynamic>> other = [];

    for (final stock in stockSummary.values) {
      final exchange = stock['exchange'] as String;

      if (exchange == 'JP') {
        domestic.add(stock);
      } else if (exchange == 'US') {
        us.add(stock);
      } else {
        other.add(stock);
      }
    }

    // 按价值排序
    domestic.sort(
      (a, b) => (b['totalValueJPY'] as double).compareTo(
        a['totalValueJPY'] as double,
      ),
    );
    us.sort(
      (a, b) => (b['totalValueJPY'] as double).compareTo(
        a['totalValueJPY'] as double,
      ),
    );
    other.sort(
      (a, b) => (b['totalValueJPY'] as double).compareTo(
        a['totalValueJPY'] as double,
      ),
    );

    if (mounted) {
      setState(() {
        domesticStocks = domestic;
        usStocks = us;
        otherStocks = other;
      });
    }
  }

  Future<void> _loadTradeHistory() async {
    final userId = GlobalStore().userId;
    final accountId = GlobalStore().accountId;

    if (userId == null || accountId == null) return;

    // 使用 join 查询来获取股票信息
    final query =
        widget.db.select(widget.db.tradeRecords).join([
            leftOuterJoin(
              widget.db.stocks,
              widget.db.stocks.id.equalsExp(widget.db.tradeRecords.assetId),
            ),
          ])
          ..where(
            widget.db.tradeRecords.userId.equals(userId) &
                widget.db.tradeRecords.accountId.equals(accountId) &
                widget.db.tradeRecords.assetType.equals('stock'),
          )
          ..orderBy([
            OrderingTerm(
              expression: widget.db.tradeRecords.tradeDate,
              mode: OrderingMode.desc,
            ),
          ]);

    final results = await query.get();
    final trades = results
        .map((row) => row.readTable(widget.db.tradeRecords))
        .toList();

    if (mounted) {
      setState(() {
        tradeHistory = trades.take(20).toList();
        // 同时保存股票信息用于货币判断
        _tradeStockMap = Map.fromEntries(
          results.map((row) {
            final trade = row.readTable(widget.db.tradeRecords);
            final stock = row.readTableOrNull(widget.db.stocks);
            return MapEntry(trade.id, stock);
          }),
        );
      });
    }
  }

  // 添加一个Map来存储交易对应的股票信息
  Map<int, Stock?> _tradeStockMap = {};

  // 改进货币判断方法
  String _getCurrencyFromTrade(TradeRecord trade) {
    final stock = _tradeStockMap[trade.id];

    if (stock != null) {
      // 优先使用股票表中的currency字段
      return stock.currency;
    }

    if (stock != null) {
      // 备用方案：根据交易所判断货币
      if (stock.exchange == 'US') {
        return 'USD';
      } else if (stock.exchange == 'JP') {
        return 'JPY';
      }
    }

    return 'JPY'; // 默认日股
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '株式',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Stock Portfolio',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // 添加交易记录
            },
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.appUpGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    '取引追加',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
            child: SingleChildScrollView(
              controller: widget.scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  CustomTab(
                    tabs: ['概要', '保有銘柄', '配当', '取引履歴'],
                    tabViews: [
                      _buildOverviewTab(),
                      _buildHoldingsTab(),
                      _buildDividendTab(),
                      _buildTradeHistoryTab(),
                    ],
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          if (_isInitializing) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.appUpGreen),
                strokeWidth: 3,
              ),
              SizedBox(height: 24),
              Text(
                '株式データを読み込み中...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    // 计算汇总数据
    final allStocks = [...domesticStocks, ...usStocks, ...otherStocks];
    final totalValue = allStocks.fold<double>(
      0,
      (sum, stock) => sum + (stock['totalValueJPY'] as double),
    );
    final totalProfit = allStocks.fold<double>(
      0,
      (sum, stock) => sum + (stock['profitJPY'] as double),
    );
    final totalCost = totalValue - totalProfit;
    final totalProfitRate = totalCost > 0
        ? (totalProfit / totalCost) * 100
        : 0.0;

    // 按市场汇总
    final domesticValue = domesticStocks.fold<double>(
      0,
      (sum, stock) => sum + (stock['totalValueJPY'] as double),
    );
    final usValue = usStocks.fold<double>(
      0,
      (sum, stock) => sum + (stock['totalValueJPY'] as double),
    );
    final otherValue = otherStocks.fold<double>(
      0,
      (sum, stock) => sum + (stock['totalValueJPY'] as double),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 总资产卡片
        CardSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.trending_up, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text(
                    '評価額',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const Spacer(),
                  Text(
                    '最終更新: ${DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now())}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                AppUtils().formatMoney(totalValue, 'JPY'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    totalProfit >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: totalProfit >= 0 ? AppColors.appUpGreen : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${totalProfit >= 0 ? '+' : ''}${AppUtils().formatMoney(totalProfit, 'JPY')}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: totalProfit >= 0
                          ? AppColors.appUpGreen
                          : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${totalProfitRate >= 0 ? '+' : ''}${totalProfitRate.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 16,
                      color: totalProfitRate >= 0
                          ? AppColors.appUpGreen
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 推移图表
        const Text(
          '推移',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E6EA), width: 1),
          ),
          child: const Center(
            child: Text('推移グラフを準備中...', style: TextStyle(color: Colors.grey)),
          ),
        ),
        const SizedBox(height: 16),

        // 市场分类
        const Text(
          '市場別保有状況',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // 国内股票
        _buildMarketCard(
          '国内株式',
          domesticValue,
          domesticStocks.length,
          Colors.blue,
          Icons.location_on,
          () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DomesticStockDetailPage(db: widget.db),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 美国股票
        _buildMarketCard(
          '米国株式',
          usValue,
          usStocks.length,
          Colors.red,
          Icons.flag,
          () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => USStockDetailPage(db: widget.db)),
          ),
        ),
        const SizedBox(height: 12),

        // 其他股票（暂时未实装，应该为0）
        _buildMarketCard(
          'その他',
          otherValue,
          otherStocks.length,
          Colors.grey,
          Icons.public,
          null, // 未实装，不可点击
        ),

        const SizedBox(height: 16),

        // 统计信息
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '保有銘柄数',
                '${domesticStocks.length + usStocks.length + otherStocks.length}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('年間配当予想', '¥0')),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E6EA), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketCard(
    String title,
    double value,
    int count,
    Color color,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E6EA), width: 1),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count銘柄',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppUtils().formatMoney(value, 'JPY'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ] else if (title == 'その他') ...[
                  const SizedBox(height: 4),
                  const Text(
                    '未実装',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoldingsTab() {
    final allStocks = [...domesticStocks, ...usStocks, ...otherStocks]
      ..sort(
        (a, b) => (b['totalValueJPY'] as double).compareTo(
          a['totalValueJPY'] as double,
        ),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 统计卡片
        Row(
          children: [
            Expanded(child: _buildStatCard('保有銘柄数', '${allStocks.length}')),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '総評価額',
                AppUtils().formatMoney(
                  allStocks.fold<double>(
                    0,
                    (sum, stock) => sum + (stock['totalValueJPY'] as double),
                  ),
                  'JPY',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 主要保有銘柄
        const Text(
          '主要保有銘柄',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        if (allStocks.isEmpty)
          const Center(
            child: Text(
              '保有している株式がありません',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        else
          // 显示前15大持仓
          ...allStocks.take(15).map((stockData) => _buildStockCard(stockData)),
      ],
    );
  }

  Widget _buildStockCard(Map<String, dynamic> stockData) {
    final name = stockData['name'] as String;
    final nameUs = stockData['nameUs'] as String?;
    final code = stockData['code'] as String;
    final profit = stockData['profitJPY'] as double;
    final profitRate = stockData['profitRate'] as double;
    final exchange = stockData['exchange'] as String;

    // 显示名称优先级：nameUs (如果是美股) > name
    final displayName =
        exchange.startsWith('US') ||
            exchange == 'NASDAQ' ||
            exchange == 'NYSE' ||
            exchange == 'AMEX'
        ? (nameUs ?? name)
        : name;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E6EA), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 左侧：交易所标识
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getExchangeColor(exchange).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getExchangeDisplay(exchange),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getExchangeColor(exchange),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$code • ${stockData['totalQuantity'].toStringAsFixed(exchange.startsWith('US') ? 2 : 0)}株',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppUtils().formatMoney(stockData['totalValueJPY'], 'JPY'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        profit >= 0 ? Icons.trending_up : Icons.trending_down,
                        size: 14,
                        color: profit >= 0 ? AppColors.appUpGreen : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${profit >= 0 ? '+' : ''}${AppUtils().formatMoney(profit, 'JPY')}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: profit >= 0
                              ? AppColors.appUpGreen
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${profitRate >= 0 ? '+' : ''}${profitRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: profit >= 0 ? AppColors.appUpGreen : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getExchangeColor(String exchange) {
    switch (exchange) {
      case 'JP':
        return Colors.blue;
      case 'US':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getExchangeDisplay(String exchange) {
    switch (exchange) {
      case 'JP':
        return 'JP';
      case 'US':
        return 'US';
      default:
        return exchange;
    }
  }

  Widget _buildDividendTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '配当履歴',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // 添加配当记录
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.appUpGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16),
                  SizedBox(width: 4),
                  Text('配当追加', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 年间配当推移图表
        const Text(
          '年間配当推移',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E6EA), width: 1),
          ),
          child: const Center(
            child: Text('配当推移グラフを準備中...', style: TextStyle(color: Colors.grey)),
          ),
        ),
        const SizedBox(height: 16),

        // 配当统计
        Row(
          children: [
            Expanded(child: _buildStatCard('今年の配当', '¥0')),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('年間配当予想', '¥0')),
          ],
        ),
      ],
    );
  }

  Widget _buildTradeHistoryTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '取引履歴',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () {
                // 导出功能
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'エクスポート',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (tradeHistory.isEmpty)
          const Center(
            child: Text(
              '取引履歴がありません',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        else
          ...tradeHistory.map((trade) => _buildTradeCard(trade)),
      ],
    );
  }

  Widget _buildTradeCard(TradeRecord trade) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E6EA), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trade.action == 'buy'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trade.action == 'buy' ? '買付' : '売付',
                  style: TextStyle(
                    color: trade.action == 'buy' ? Colors.green : Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('yyyy-MM-dd').format(trade.tradeDate),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '数量',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${trade.quantity.toStringAsFixed(2)}株',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '単価',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppUtils().formatMoney(
                        trade.price,
                        _getCurrencyFromTrade(trade),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '合計',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppUtils().formatMoney(
                        trade.quantity * trade.price,
                        _getCurrencyFromTrade(trade),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (trade.feeAmount != null && trade.feeAmount! > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  '手数料:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(width: 4),
                Text(
                  AppUtils().formatMoney(
                    trade.feeAmount!,
                    trade.feeCurrency ?? 'JPY',
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
