import 'dart:ui';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:money_nest_app/components/card_section.dart';
import 'package:money_nest_app/components/custom_tab.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/pages/trade_history/trade_add_edit_page.dart';
import 'package:money_nest_app/pages/trade_history/trade_history_tab_page.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:intl/intl.dart';
import 'package:money_nest_app/util/global_store.dart';

class DomesticStockDetailPage extends StatefulWidget {
  final AppDatabase db;
  final ScrollController? scrollController;

  const DomesticStockDetailPage({
    super.key,
    required this.db,
    this.scrollController,
  });

  @override
  State<DomesticStockDetailPage> createState() =>
      _DomesticStockDetailPageState();
}

class _DomesticStockDetailPageState extends State<DomesticStockDetailPage> {
  List<Map<String, dynamic>> domesticStocks = [];
  List<TradeRecord> tradeHistory = [];
  List<Map<String, dynamic>> dividendHistory = [];
  bool _isInitializing = true;

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
      await _loadDomesticStockData();
      await _loadDomesticTradeHistory();
      print('Domestic stock data loaded successfully: $domesticStocks');
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

  Future<void> _loadDomesticStockData() async {
    final userId = GlobalStore().userId;
    final accountId = GlobalStore().accountId;

    if (userId == null || accountId == null) return;

    // 计算持仓并更新到 GlobalStore
    //await AppUtils().calculateAndSavePortfolio(widget.db, userId, accountId);
    //await AppUtils().calculateAndSaveHistoricalPortfolioToPrefs(widget.db);

    // 按股票分组计算持仓
    final Map<int, Map<String, dynamic>> stockPositions = {};
    final rate = GlobalStore().currentStockPrices['JPY=X'] ?? 150.0;

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

      if (exchange != 'JP' ||
          stockId == null ||
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
      stockPositions[stockId]!['totalCost'] +=
          quantity * buyPrice +
          (fee != null
              ? feeCurrency == 'USD'
                    ? fee * rate
                    : fee
              : 0.0);
    }

    // 计算当前价值和总评价额
    double totalPortfolioValue = 0.0;
    List<Map<String, dynamic>> stocks = [];

    for (final entry in stockPositions.entries) {
      final position = entry.value;

      if (position['totalQuantity'] <= 0) continue;

      final avgPrice = position['totalCost'] / position['totalQuantity'];
      final currentPrice =
          GlobalStore().currentStockPrices[position['code'] + '.T'] ?? avgPrice;
      final totalValue = position['totalQuantity'] * currentPrice;
      final profit = totalValue - position['totalCost'];
      final profitRate = (profit / position['totalCost']) * 100;

      totalPortfolioValue += totalValue;

      stocks.add({
        'stockId': position['stockId'],
        'code': position['code'],
        'name': position['name'],
        'nameUs': position['nameUs'],
        'logo': position['logo'],
        'quantity': position['totalQuantity'],
        'avgPrice': avgPrice,
        'currentPrice': currentPrice,
        'totalValue': totalValue,
        'profit': profit,
        'profitRate': profitRate,
        'totalCost': position['totalCost'],
        'trades': position['trades'],
      });
    }

    // 计算保有割合
    for (final stock in stocks) {
      stock['holdingRatio'] = totalPortfolioValue > 0
          ? (stock['totalValue'] / totalPortfolioValue) * 100
          : 0.0;
    }

    // 应用排序
    _applySorting(stocks);

    if (mounted) {
      setState(() {
        domesticStocks = stocks;
      });
    }
  }

  Future<void> _loadDomesticTradeHistory() async {
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
                widget.db.stocks.exchange.equals('JP'), // 只获取日本股票的交易记录
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
          result = (a['totalValue'] as double).compareTo(
            b['totalValue'] as double,
          );
          break;
        case '保有割合':
          result = (a['holdingRatio'] as double).compareTo(
            b['holdingRatio'] as double,
          );
          break;
        case '損益額':
          result = (a['profit'] as double).compareTo(b['profit'] as double);
          break;
        case '損益率':
          result = (a['profitRate'] as double).compareTo(
            b['profitRate'] as double,
          );
          break;
        default:
          result = (a['totalValue'] as double).compareTo(
            b['totalValue'] as double,
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
      _applySorting(domesticStocks);
    });
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
              '国内株式',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Domestic Stocks',
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
            onPressed: () async {
              // 添加交易记录
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TradeAddEditPage(
                    db: widget.db,
                    mode: 'add',
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
                    type: 'asset',
                  ),
                ),
              );

              if (result == true) {
                // 刷新数据
                // 调用子组件的刷新方法
                //_listKey.currentState?._fetchRecords();
              }
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
                '国内株式データを読み込み中...',
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
    final totalValue = domesticStocks.fold<double>(
      0,
      (sum, stock) => sum + stock['totalValue'],
    );
    final totalCost = domesticStocks.fold<double>(
      0,
      (sum, stock) => sum + stock['totalCost'],
    );
    final totalProfit = totalValue - totalCost;
    final totalProfitRate = totalCost > 0
        ? (totalProfit / totalCost) * 100
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
                  const Icon(Icons.location_on, size: 18, color: Colors.blue),
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

        // 统计信息
        Row(
          children: [
            Expanded(
              child: _buildStatCard('保有銘柄数', '${domesticStocks.length}'),
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

  Widget _buildHoldingsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 排序选择器
        _buildSortSelector(),
        const SizedBox(height: 16),

        if (domesticStocks.isEmpty)
          const Center(
            child: Text(
              '保有している国内株式はありません',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
        else
          ...domesticStocks.map(
            (stockData) => _buildDetailedStockCard(stockData),
          ),
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

          // 升降序切换 - 改为蓝色系
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
    final name = stockData['name'] as String;
    final code = stockData['code'] as String;
    final profit = stockData['profit'] as double;
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
                    AppUtils().formatMoney(stockData['totalValue'], 'JPY'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF1A1A1A),
                    ),
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
                  '${stockData['quantity'].toInt()}株',
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
              // 平均取得単価
              Expanded(
                child: _buildInfoItem(
                  '平均取得単価',
                  AppUtils().formatMoney(stockData['avgPrice'], 'JPY'),
                  Icons.trending_up_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              // 現在価格
              Expanded(
                child: _buildInfoItem(
                  '現在価格',
                  AppUtils().formatMoney(stockData['currentPrice'], 'JPY'),
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
              Expanded(child: _buildProfitItem('損益', profit, profitRate)),
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

  // 损益专用组件
  Widget _buildProfitItem(String label, double profit, double profitRate) {
    final isProfit = profit >= 0;
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
              '${profit >= 0 ? '+' : ''}${AppUtils().formatMoney(profit, 'JPY')}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              '${profitRate >= 0 ? '+' : ''}${profitRate.toStringAsFixed(1)}%',
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
        ...domesticStocks
            .take(5)
            .map((stockData) => _buildDividendStockCard(stockData)),
      ],
    );
  }

  Widget _buildDividendStockCard(Map<String, dynamic> stockData) {
    final name = stockData['name'] as String;

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
            decoration: const BoxDecoration(
              color: Colors.green,
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
                Text(
                  '2025-09-30',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '@¥70 × ${stockData['quantity'].toInt()}株',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '¥5,566',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Text(
                '税引後',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Text(
                '(税抜 ¥7,000)',
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
                      '${trade.quantity.toInt()}株',
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
                      AppUtils().formatMoney(trade.price, 'JPY'),
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
                        'JPY',
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
