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

class USStockDetailPage extends StatefulWidget {
  final AppDatabase db;
  final ScrollController? scrollController;

  const USStockDetailPage({super.key, required this.db, this.scrollController});

  @override
  State<USStockDetailPage> createState() => _USStockDetailPageState();
}

class _USStockDetailPageState extends State<USStockDetailPage> {
  List<Map<String, dynamic>> usStocks = [];
  List<TradeRecord> tradeHistory = [];
  List<Map<String, dynamic>> dividendHistory = [];
  bool _isInitializing = true;
  double _usdToJpyRate = 150.0; // USD/JPY汇率

  // 排序相关的状态
  String _sortBy = '保有割合'; // 默认按保有割合排序
  bool _isAscending = false; // 默认降序

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
      await _loadUSStockData();
      await _loadExchangeRate();
      await _loadUSTradeHistory();
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

  Future<void> _loadExchangeRate() async {
    // 获取USD/JPY汇率
    _usdToJpyRate = GlobalStore().currentStockPrices['JPY=X'] ?? 150.0;
  }

  Future<void> _loadUSStockData() async {
    final userId = GlobalStore().userId;
    final accountId = GlobalStore().accountId;

    if (userId == null || accountId == null) return;

    // 计算持仓并更新到 GlobalStore
    //await AppUtils().calculateAndSavePortfolio(widget.db, userId, accountId);
    //await AppUtils().calculateAndSaveHistoricalPortfolioToPrefs(widget.db);

    // 确保汇率已经获取
    _usdToJpyRate = GlobalStore().currentStockPrices['JPY=X'] ?? 150.0;

    // 按股票分组计算持仓
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

      // 筛选美国股票 (exchange = 'US')
      if (exchange != 'US') {
        continue;
      }

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

      // 修正费用处理逻辑
      double tradeCost = quantity * buyPrice; // 基本成本（USD）

      if (fee != null && fee > 0) {
        if (feeCurrency == 'USD') {
          tradeCost += fee; // USD费用直接加上
        } else {
          // JPY费用转换为USD：JPY ÷ 汇率 = USD
          tradeCost += fee / _usdToJpyRate;
        }
      }

      stockPositions[stockId]!['totalCost'] += tradeCost;
    }

    // 计算当前价值和总评价额
    double totalPortfolioValue = 0.0;
    List<Map<String, dynamic>> stocks = [];

    for (final entry in stockPositions.entries) {
      final position = entry.value;

      if (position['totalQuantity'] <= 0) continue;

      final avgPrice = position['totalCost'] / position['totalQuantity'];
      final currentPriceUSD =
          GlobalStore().currentStockPrices[position['code']] ?? avgPrice;
      final totalValueUSD = position['totalQuantity'] * currentPriceUSD;
      final totalValueJPY = totalValueUSD * _usdToJpyRate;
      final profitUSD = totalValueUSD - position['totalCost'];
      final profitJPY = profitUSD * _usdToJpyRate;
      final profitRate = (profitUSD / position['totalCost']) * 100;

      totalPortfolioValue += totalValueJPY;

      stocks.add({
        'stockId': position['stockId'],
        'code': position['code'],
        'name': position['name'],
        'nameUs': position['nameUs'],
        'logo': position['logo'],
        'quantity': position['totalQuantity'],
        'avgPrice': avgPrice,
        'currentPriceUSD': currentPriceUSD,
        'currentPriceJPY': currentPriceUSD * _usdToJpyRate,
        'totalValueUSD': totalValueUSD,
        'totalValueJPY': totalValueJPY,
        'profitUSD': profitUSD,
        'profitJPY': profitJPY,
        'profitRate': profitRate,
        'totalCost': position['totalCost'],
        'trades': position['trades'],
      });
    }

    // 计算保有割合
    for (final stock in stocks) {
      stock['holdingRatio'] = totalPortfolioValue > 0
          ? (stock['totalValueJPY'] / totalPortfolioValue) * 100
          : 0.0;
    }

    // 应用排序
    _applySorting(stocks);

    if (mounted) {
      setState(() {
        usStocks = stocks;
      });
    }
  }

  Future<void> _loadUSTradeHistory() async {
    final userId = GlobalStore().userId;
    final accountId = GlobalStore().accountId;

    if (userId == null || accountId == null) return;

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
                (widget.db.stocks.exchange.equals('US')), // 美国股票交易所
          )
          ..orderBy([
            OrderingTerm(
              expression: widget.db.tradeRecords.tradeDate,
              mode: OrderingMode.desc,
            ),
          ]);

    final results = await query.get();

    // 从 join 结果中提取 TradeRecord
    final trades = results
        .map((row) => row.readTable(widget.db.tradeRecords))
        .toList();

    if (mounted) {
      setState(() {
        tradeHistory = trades;
      });
    }
  }

  // 排序方法
  void _applySorting(List<Map<String, dynamic>> stocks) {
    stocks.sort((a, b) {
      int result = 0;

      switch (_sortBy) {
        case '銘柄コード':
          result = (a['code'] as String).compareTo(b['code'] as String);
          break;
        case '評価額':
          result = (a['totalValueJPY'] as double).compareTo(
            b['totalValueJPY'] as double,
          );
          break;
        case '保有割合':
          result = (a['holdingRatio'] as double).compareTo(
            b['holdingRatio'] as double,
          );
          break;
        case '損益額':
          result = (a['profitJPY'] as double).compareTo(
            b['profitJPY'] as double,
          );
          break;
        case '損益率':
          result = (a['profitRate'] as double).compareTo(
            b['profitRate'] as double,
          );
          break;
        default:
          result = (a['totalValueJPY'] as double).compareTo(
            b['totalValueJPY'] as double,
          );
      }

      return _isAscending ? result : -result;
    });
  }

  // 更改排序
  void _changeSorting(String sortBy) {
    setState(() {
      if (_sortBy == sortBy) {
        _isAscending = !_isAscending;
      } else {
        _sortBy = sortBy;
        _isAscending = false; // 新选择的排序默认降序
      }
      _applySorting(usStocks);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '米国株式',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'US Stocks',
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
                  // 汇率显示
                  _buildExchangeRateCard(),
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

  Widget _buildExchangeRateCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.currency_exchange, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          const Text(
            'USD/JPY:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          Text(
            '¥${_usdToJpyRate.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14, color: Colors.blue),
          ),
          const Spacer(),
          Text(
            '最終更新: ${DateFormat('MM/dd HH:mm').format(DateTime.now())}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
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
                '米国株式データを読み込み中...',
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
    final totalValueJPY = usStocks.fold<double>(
      0,
      (sum, stock) => sum + stock['totalValueJPY'],
    );
    final totalValueUSD = usStocks.fold<double>(
      0,
      (sum, stock) => sum + stock['totalValueUSD'],
    );
    final totalCost = usStocks.fold<double>(
      0,
      (sum, stock) => sum + stock['totalCost'],
    );
    // 直接使用已经计算好的盈利数据，而不是重新计算
    final totalProfitJPY = usStocks.fold<double>(
      0,
      (sum, stock) => sum + stock['profitJPY'],
    );
    final totalProfitUSD = usStocks.fold<double>(
      0,
      (sum, stock) => sum + stock['profitUSD'],
    );
    final totalProfitRate = totalCost > 0
        ? (totalProfitUSD / totalCost) * 100
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 评价额卡片
        CardSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flag, size: 18, color: Colors.blue),
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
              Row(
                children: [
                  Text(
                    AppUtils().formatMoney(totalValueJPY, 'JPY'),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '\$${totalValueUSD.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    totalProfitJPY >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: totalProfitJPY >= 0
                        ? AppColors.appUpGreen
                        : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${totalProfitJPY >= 0 ? '+' : ''}${AppUtils().formatMoney(totalProfitJPY, 'JPY')}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: totalProfitJPY >= 0
                          ? AppColors.appUpGreen
                          : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(\$${totalProfitUSD >= 0 ? '+' : ''}${totalProfitUSD.toStringAsFixed(2)})',
                    style: TextStyle(
                      fontSize: 14,
                      color: totalProfitJPY >= 0
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

        // 统计信息
        Row(
          children: [
            Expanded(child: _buildStatCard('保有銘柄数', '${usStocks.length}')),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('年間配当予想', '\$0 (¥0)')),
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
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 排序选择器
        _buildSortSelector(),
        const SizedBox(height: 16),

        if (usStocks.isEmpty)
          const Center(
            child: Text(
              '保有している米国株式はありません',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        else
          ...usStocks.map((stockData) => _buildDetailedStockCard(stockData)),
      ],
    );
  }

  Widget _buildSortSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E6EA), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.sort, size: 16, color: Color(0xFF666666)),
          const SizedBox(width: 8),
          const Text(
            '並び替え',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),

          // 排序选项下拉
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                isDense: true,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.w500,
                ),
                items: ['銘柄コード', '評価額', '保有割合', '損益額', '損益率'].map((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _changeSorting(newValue);
                  }
                },
              ),
            ),
          ),

          const SizedBox(width: 8),

          // 升降序切换 - 蓝色系
          GestureDetector(
            onTap: () => _changeSorting(_sortBy),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3), // 蓝色
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isAscending ? '昇順' : '降順',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isAscending
                        ? Icons.keyboard_double_arrow_up
                        : Icons.keyboard_double_arrow_down,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStockCard(Map<String, dynamic> stockData) {
    final name = stockData['name'] as String? ?? stockData['nameUs'] as String;
    final code = stockData['code'] as String;
    final profitJPY = stockData['profitJPY'] as double;
    final profitUSD = stockData['profitUSD'] as double;
    final profitRate = stockData['profitRate'] as double;
    final holdingRatio = stockData['holdingRatio'] as double;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
          // 头部：股票名称、代码和保有割合
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧：股票信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // 右侧：保有割合和评价额
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 保有割合徽章
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.appUpGreen,
                          AppColors.appUpGreen.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.appUpGreen.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${holdingRatio.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 评价额
                  Text(
                    AppUtils().formatMoney(stockData['totalValueJPY'], 'JPY'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    '\$${stockData['totalValueUSD'].toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 分隔线
          Container(height: 1, color: const Color(0xFFF0F0F0)),

          const SizedBox(height: 16),

          // 详细信息网格
          Row(
            children: [
              // 保有株数
              Expanded(
                child: _buildInfoItem(
                  '保有株数',
                  '${stockData['quantity'].toStringAsFixed(2)}株',
                  Icons.inventory_2_outlined,
                ),
              ),
              // 竖直分隔线
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFFF0F0F0),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              // 平均取得単价 (USD)
              Expanded(
                child: _buildInfoItem(
                  '平均取得単価',
                  '\$${stockData['avgPrice'].toStringAsFixed(2)}',
                  Icons.trending_up_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              // 現在価格 (USD)
              Expanded(
                child: _buildInfoItem(
                  '現在価格',
                  '\$${stockData['currentPriceUSD'].toStringAsFixed(2)}',
                  Icons.schedule_outlined,
                ),
              ),
              // 竖直分隔线
              Container(
                width: 1,
                height: 40,
                color: const Color(0xFFF0F0F0),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              // 損益
              Expanded(
                child: _buildProfitItem('損益', profitJPY, profitUSD, profitRate),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 通用信息项组件
  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF999999)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF999999),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  // 损益专用组件 (美股版本)
  Widget _buildProfitItem(
    String label,
    double profitJPY,
    double profitUSD,
    double profitRate,
  ) {
    final isProfit = profitJPY >= 0;
    final color = isProfit ? AppColors.appUpGreen : const Color(0xFFE53E3E);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isProfit ? Icons.trending_up : Icons.trending_down,
              size: 16,
              color: const Color(0xFF999999),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF999999),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${profitJPY >= 0 ? '+' : ''}${AppUtils().formatMoney(profitJPY, 'JPY')}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              '(\$${profitUSD >= 0 ? '+' : ''}${profitUSD.toStringAsFixed(2)}) ${profitRate >= 0 ? '+' : ''}${profitRate.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
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

        // 主要配当股票
        const Text(
          '主要配当銘柄',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (usStocks.isEmpty)
          const Center(
            child: Text(
              '配当銘柄がありません',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        else
          ...usStocks
              .take(5)
              .map((stockData) => _buildDividendStockCard(stockData)),
      ],
    );
  }

  Widget _buildDividendStockCard(Map<String, dynamic> stockData) {
    final name = stockData['name'] as String? ?? stockData['nameUs'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E6EA), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.attach_money, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  '2025-09-30',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '@\$${stockData['currentPriceUSD'].toStringAsFixed(2)} × ${stockData['quantity'].toStringAsFixed(2)}株',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '¥0',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text('税引後', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text(
                '(税抜 ¥0)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
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
                    Column(
                      children: [
                        Text(
                          '\$${trade.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '(¥${(trade.price * _usdToJpyRate).toStringAsFixed(0)})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${(trade.quantity * trade.price).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '(¥${(trade.quantity * trade.price * _usdToJpyRate).toStringAsFixed(0)})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (trade.feeAmount! > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  '手数料:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(width: 4),
                Text(
                  '\$${trade.feeAmount!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(¥${(trade.feeAmount! * _usdToJpyRate).toStringAsFixed(0)})',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
