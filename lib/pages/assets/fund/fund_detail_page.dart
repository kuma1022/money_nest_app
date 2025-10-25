import 'package:flutter/material.dart';
import 'package:money_nest_app/components/card_section.dart';
import 'package:money_nest_app/components/custom_tab.dart';
import 'package:money_nest_app/components/custom_line_chart.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/pages/assets/fund/fund_transaction_page.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:money_nest_app/util/global_store.dart';

class FundDetailPage extends StatefulWidget {
  final AppDatabase db;
  final ScrollController? scrollController;

  const FundDetailPage({super.key, required this.db, this.scrollController});

  @override
  State<FundDetailPage> createState() => _FundDetailPageState();
}

class _FundDetailPageState extends State<FundDetailPage> {
  bool _isLoading = false;
  double _totalAssets = 0.0;
  double _totalCosts = 0.0;
  double _totalProfit = 0.0;
  double _profitRate = 0.0;
  List<(DateTime, double)> _assetHistory = [];
  List<Map<String, dynamic>> _fundBreakdown = [];

  @override
  void initState() {
    super.initState();
    _loadFundData();
  }

  Future<void> _loadFundData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 从 GlobalStore 获取投资信托数据
      final fundData = GlobalStore().totalAssetsAndCostsMap['fund'];
      _totalAssets = fundData?['totalAssets']?.toDouble() ?? 0.0;
      _totalCosts = fundData?['totalCosts']?.toDouble() ?? 0.0;
      _totalProfit = _totalAssets - _totalCosts;
      _profitRate = _totalCosts == 0 ? 0.0 : (_totalProfit / _totalCosts) * 100;

      // 构建投资信托明细数据（模拟数据，实际应该从数据库获取）
      _buildFundBreakdown();

      // 构建历史数据
      _buildAssetHistory();
    } catch (e) {
      print('Error loading fund data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _buildFundBreakdown() {
    // 模拟投资信托数据，实际应该从数据库或API获取
    _fundBreakdown = [
      {
        'name': 'NISA（つみたて）',
        'subType': '2銘柄',
        'currentValue': 250000.0,
        'cost': 230000.0,
        'profit': 20000.0,
        'profitRate': 8.7,
      },
      {
        'name': 'NISA（成長）',
        'subType': '1銘柄',
        'currentValue': 130000.0,
        'cost': 120000.0,
        'profit': 10000.0,
        'profitRate': 8.3,
      },
      {
        'name': '特定',
        'subType': '1銘柄',
        'currentValue': 70000.0,
        'cost': 65000.0,
        'profit': 5000.0,
        'profitRate': 7.7,
      },
    ];
  }

  void _buildAssetHistory() {
    _assetHistory.clear();
    final now = DateTime.now();
    final startDate = DateTime(2024, 11, 1); // 从2024年11月开始

    // 模拟历史数据，实际应该从 GlobalStore 的历史数据中获取
    final dataPoints = [
      (DateTime(2024, 11, 1), 290000.0),
      (DateTime(2024, 12, 1), 310000.0),
      (DateTime(2025, 1, 1), 330000.0),
      (DateTime(2025, 3, 1), 370000.0),
      (DateTime(2025, 5, 1), 400000.0),
      (DateTime(2025, 7, 1), 430000.0),
      (DateTime(2025, 10, 1), 450000.0),
    ];

    _assetHistory = dataPoints;
  }

  // 处理新交易数据
  void _handleNewTransaction(Map<String, dynamic> transactionData) {
    print('New transaction data: $transactionData');

    // TODO: 实现保存交易数据到数据库的逻辑
    // 例如：
    // 1. 解析交易数据
    // 2. 保存到数据库
    // 3. 更新 GlobalStore
    // 4. 刷新页面数据

    // 暂时显示成功消息
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('取引を追加しました'),
        backgroundColor: AppColors.appUpGreen,
      ),
    );

    // 重新加载数据
    _loadFundData();
  }

  // 编辑积立设定
  void _editRecurringSetting(
    String fundName,
    Map<String, dynamic> setting,
    int settingIndex,
  ) {
    // 构建编辑数据
    final editingData = {
      'fundName': fundName,
      'settingIndex': settingIndex,
      'settingData': setting,
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FundTransactionPage(
          isEditMode: true,
          editingData: editingData,
          onSaved: (transactionData) {
            _handleEditedRecurringSetting(transactionData);
          },
        ),
      ),
    );
  }

  // 处理编辑后的积立设定数据
  void _handleEditedRecurringSetting(Map<String, dynamic> editedData) {
    print('Edited recurring setting data: $editedData');

    // TODO: 实现更新积立设定到数据库的逻辑
    // 例如：
    // 1. 解析编辑后的数据
    // 2. 更新数据库中的积立设定
    // 3. 更新 GlobalStore
    // 4. 刷新页面数据

    // 暂时显示成功消息
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('積立設定を更新しました'),
        backgroundColor: AppColors.appUpGreen,
      ),
    );

    // 重新加载数据
    _loadFundData();
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
              '投資信託',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Investment Trusts',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FundTransactionPage(
                      onSaved: (transactionData) {
                        _handleNewTransaction(transactionData);
                      },
                    ),
                  ),
                );
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
              child: const Text(
                '取引追加',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
              child: SingleChildScrollView(
                controller: widget.scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    _buildSummarySection(),
                    const SizedBox(height: 16),
                    CustomTab(
                      tabs: ['概要', '積立設定', '取引履歴'],
                      tabViews: [
                        _buildOverviewTab(),
                        _buildRecurringTab(),
                        _buildHistoryTab(),
                      ],
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummarySection() {
    return Row(
      children: [
        Expanded(
          child: CardSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '評価額',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppUtils().formatMoney(
                    _totalAssets,
                    GlobalStore().selectedCurrencyCode ?? 'JPY',
                  ),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CardSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '損益',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.trending_up,
                      color: AppColors.appUpGreen,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppUtils().formatMoney(
                    _totalProfit,
                    GlobalStore().selectedCurrencyCode ?? 'JPY',
                  ),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _totalProfit > 0
                        ? AppColors.appUpGreen
                        : AppColors.appDownRed,
                  ),
                ),
                Text(
                  '${_profitRate >= 0 ? '+' : ''}${AppUtils().formatNumberByTwoDigits(_profitRate)}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: _totalProfit > 0
                        ? AppColors.appUpGreen
                        : AppColors.appDownRed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChartSection(),
        const SizedBox(height: 24),
        _buildBreakdownSection(),
        const SizedBox(height: 24),
        _buildRecentTransactionsSection(),
      ],
    );
  }

  Widget _buildChartSection() {
    return _assetHistory.isNotEmpty
        ? CardSection(
            child: LineChartSample12(
              datas: [
                {
                  'label': '評価額',
                  'lineColor': AppColors.appUpGreen,
                  'tooltipText1Color': AppColors.appUpGreen,
                  'tooltipText2Color': AppColors.appUpGreen,
                  'dataList': _assetHistory,
                },
              ],
              currencyCode: GlobalStore().selectedCurrencyCode,
              animationValue: 1.0, // 0.0~1.0
            ),
          )
        : const Center(
            child: Text('データがありません', style: TextStyle(color: Colors.grey)),
          );
  }

  Widget _buildBreakdownSection() {
    return CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '預かり区分別',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: _fundBreakdown.asMap().entries.map((entry) {
              final index = entry.key;
              final fund = entry.value;
              return Column(
                children: [
                  _buildFundItem(fund),
                  if (index < _fundBreakdown.length - 1)
                    const SizedBox(height: 24),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFundItem(Map<String, dynamic> fund) {
    final isProfit = fund['profit'] > 0;

    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fund['name'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  fund['subType'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppUtils().formatMoney(
                  fund['currentValue'],
                  GlobalStore().selectedCurrencyCode ?? 'JPY',
                ),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${isProfit ? '+' : ''}${AppUtils().formatMoney(fund['profit'], GlobalStore().selectedCurrencyCode ?? 'JPY')} (${isProfit ? '+' : ''}${AppUtils().formatNumberByTwoDigits(fund['profitRate'])}%)',
                style: TextStyle(
                  fontSize: 16,
                  color: isProfit ? AppColors.appUpGreen : AppColors.appDownRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsSection() {
    // 模拟最近交易数据
    final recentTransactions = [
      {
        'fundName': 'eMAXIS Slim 全世界株式',
        'date': '2025-10-15',
        'accountType': 'NISA（つみたて）',
        'type': '買付',
        'amount': 50000.0,
        'units': 2345.67,
        'basePrice': 21.32,
      },
      {
        'fundName': 'eMAXIS Slim 全世界株式',
        'date': '2025-09-15',
        'accountType': 'NISA（つみたて）',
        'type': '買付',
        'amount': 50000.0,
        'units': 2387.54,
        'basePrice': 20.95,
      },
      {
        'fundName': 'ニッセイ外国株式インデックス',
        'date': '2025-08-15',
        'accountType': 'NISA（成長）',
        'type': '買付',
        'amount': 30000.0,
        'units': 1234.56,
        'basePrice': 24.31,
      },
    ];

    return CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '直近の取引',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: recentTransactions.asMap().entries.map((entry) {
              final index = entry.key;
              final transaction = entry.value;
              return Column(
                children: [
                  _buildTransactionItem(transaction),
                  if (index < recentTransactions.length - 1)
                    const SizedBox(height: 24),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return Container(
      child: Row(
        children: [
          // 左侧图标
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.appUpGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.add, color: AppColors.appUpGreen, size: 16),
          ),
          const SizedBox(width: 12),

          // 中间内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 基金名称
                Text(
                  transaction['fundName'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),

                // 日期
                Text(
                  transaction['date'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),

                // 标签行
                Row(
                  children: [
                    // 预金区分标签
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.appUpGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction['accountType'],
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.appUpGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // 交易类型标签
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.appUpGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction['type'],
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.appUpGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 右侧金额信息
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 金额
              Text(
                '+${AppUtils().formatMoney(transaction['amount'], GlobalStore().selectedCurrencyCode ?? 'JPY')}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.appUpGreen,
                ),
              ),
              const SizedBox(height: 2),

              // 口数
              Text(
                '${AppUtils().formatNumberByTwoDigits(transaction['units'])}口',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),

              // 基准价额
              Text(
                '@¥${AppUtils().formatNumberByTwoDigits(transaction['basePrice'])}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 积立模拟器卡片
        _buildRecurringSimulatorCard(),
        const SizedBox(height: 16),

        // 积立设定标题和新规追加按钮
        _buildRecurringHeader(),
        const SizedBox(height: 16),

        // 积立设定列表
        ..._buildRecurringSettingsList(),
      ],
    );
  }

  // 积立模拟器卡片
  Widget _buildRecurringSimulatorCard() {
    return CardSection(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.appUpGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calculate_outlined,
              color: AppColors.appUpGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '積立シミュレーション',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '目標金額から逆算',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 实现积立模拟器功能
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.appUpGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 0,
            ),
            child: const Text(
              '開始',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // 积立设定标题和新规追加按钮
  Widget _buildRecurringHeader() {
    return Row(
      children: [
        const Text(
          '6件の積立設定',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FundTransactionPage(
                  onSaved: (transactionData) {
                    _handleNewTransaction(transactionData);
                  },
                ),
              ),
            );
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('新規追加'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.appUpGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  // 更新模拟数据以使用新的频率格式
  List<Widget> _buildRecurringSettingsList() {
    final recurringSettings = [
      {
        'fundName': 'eMAXIS Slim 全世界株式',
        'settings': [
          {
            'accountType': 'NISA（つみたて）',
            'status': '有効',
            'frequencyType': 'monthly',
            'frequencyConfig': {
              'type': 'monthly',
              'days': [1],
            },
            'frequencyDescription': '毎月 1日',
            'amount': 30000.0,
            'startDate': '2024-01-01',
            'endDate': '2024-12-31',
          },
          {
            'accountType': 'NISA（つみたて）',
            'status': '有効',
            'frequencyType': 'monthly',
            'frequencyConfig': {
              'type': 'monthly',
              'days': [15],
            },
            'frequencyDescription': '毎月 15日',
            'amount': 50000.0,
            'startDate': '2025-01-15',
            'endDate': null,
          },
        ],
      },
      {
        'fundName': 'ニッセイ外国株式インデックス',
        'settings': [
          {
            'accountType': 'NISA（成長）',
            'status': '有効',
            'frequencyType': 'weekly',
            'frequencyConfig': {
              'type': 'weekly',
              'days': [1, 3, 5],
            },
            'frequencyDescription': '毎週 月曜日・水曜日・金曜日',
            'amount': 10000.0,
            'startDate': '2024-03-01',
            'endDate': '2024-10-31',
          },
          {
            'accountType': '特定',
            'status': '有効',
            'frequencyType': 'bimonthly',
            'frequencyConfig': {
              'type': 'bimonthly',
              'months': 'odd',
              'days': [1, 15],
            },
            'frequencyDescription': '奇数月 1日・15日',
            'amount': 20000.0,
            'startDate': '2024-11-01',
            'endDate': null,
          },
          {
            'accountType': 'NISA（成長）',
            'status': '有効',
            'frequencyType': 'monthly',
            'frequencyConfig': {
              'type': 'monthly',
              'days': [20, 31],
            },
            'frequencyDescription': '毎月 20日・月末',
            'amount': 40000.0,
            'startDate': '2025-01-01',
            'endDate': null,
          },
        ],
      },
      {
        'fundName': 'SBI・V・S&P500インデックス',
        'settings': [
          {
            'accountType': 'NISA（つみたて）',
            'status': '有効',
            'frequencyType': 'daily',
            'frequencyConfig': {'type': 'daily'},
            'frequencyDescription': '毎日',
            'amount': 1000.0,
            'startDate': '2024-05-01',
            'endDate': null,
          },
        ],
      },
    ];

    return recurringSettings
        .map(
          (fund) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildRecurringFundCard(fund),
          ),
        )
        .toList();
  }

  // 单个基金的积立设定卡片
  Widget _buildRecurringFundCard(Map<String, dynamic> fund) {
    final settings = fund['settings'] as List<Map<String, dynamic>>;

    return _RecurringFundCard(
      fundName: fund['fundName'],
      settings: settings,
      onEdit: (settingIndex) {
        _editRecurringSetting(
          fund['fundName'],
          settings[settingIndex],
          settingIndex,
        );
      },
      onDelete: (settingIndex) {
        // TODO: 删除积立设定
        print('Delete setting $settingIndex for ${fund['fundName']}');
      },
    );
  }

  // 取引履歴标签页
  Widget _buildHistoryTab() {
    // 模拟交易历史数据
    final transactionHistory = [
      {
        'date': '2025-10-15',
        'type': '買付',
        'fundName': 'eMAXIS Slim 全世界株式',
        'accountType': 'NISA（つみたて）',
        'amount': 50000.0,
        'units': 2345.67,
        'basePrice': 21.32,
      },
      {
        'date': '2025-09-15',
        'type': '買付',
        'fundName': 'eMAXIS Slim 全世界株式',
        'accountType': 'NISA（つみたて）',
        'amount': 50000.0,
        'units': 2387.54,
        'basePrice': 20.95,
      },
      {
        'date': '2025-08-15',
        'type': '買付',
        'fundName': 'ニッセイ外国株式インデックス',
        'accountType': 'NISA（成長）',
        'amount': 30000.0,
        'units': 1234.56,
        'basePrice': 24.30,
      },
      {
        'date': '2025-07-20',
        'type': '売却',
        'fundName': 'eMAXIS Slim 先進国株式',
        'accountType': '特定',
        'amount': -25000.0,
        'units': -1150.45,
        'basePrice': 21.74,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题和筛选按钮（不包裹在卡片中）
        Row(
          children: [
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                // TODO: 实现筛选功能
              },
              icon: const Icon(Icons.filter_list, size: 18),
              label: const Text('フィルター'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: 实现排序功能
              },
              icon: const Icon(Icons.sort, size: 18),
              label: const Text('並び替え'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 交易历史列表
        ...transactionHistory
            .map(
              (transaction) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _buildHistoryItem(transaction),
              ),
            )
            .toList(),
      ],
    );
  }

  // 历史项目
  Widget _buildHistoryItem(Map<String, dynamic> transaction) {
    final isBuy = transaction['type'] == '買付';
    final amount = transaction['amount'] as double;
    final units = transaction['units'] as double;

    return CardSection(
      child: Row(
        children: [
          // 左侧图标
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isBuy
                  ? AppColors.appUpGreen.withOpacity(0.1)
                  : AppColors.appDownRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isBuy ? Icons.add : Icons.remove,
              color: isBuy ? AppColors.appUpGreen : AppColors.appDownRed,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),

          // 中间内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 基金名称
                Text(
                  transaction['fundName'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),

                // 日期
                Text(
                  transaction['date'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),

                // 标签行
                Row(
                  children: [
                    // 预金区分标签
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isBuy
                            ? AppColors.appUpGreen.withOpacity(0.1)
                            : AppColors.appDownRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction['accountType'],
                        style: TextStyle(
                          fontSize: 10,
                          color: isBuy
                              ? AppColors.appUpGreen
                              : AppColors.appDownRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // 交易类型标签
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isBuy
                            ? AppColors.appUpGreen.withOpacity(0.1)
                            : AppColors.appDownRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction['type'],
                        style: TextStyle(
                          fontSize: 10,
                          color: isBuy
                              ? AppColors.appUpGreen
                              : AppColors.appDownRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 右侧金额信息
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 金额
              Text(
                '${amount > 0 ? '+' : ''}${AppUtils().formatMoney(amount, GlobalStore().selectedCurrencyCode ?? 'JPY')}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isBuy ? AppColors.appUpGreen : AppColors.appDownRed,
                ),
              ),
              const SizedBox(height: 2),

              // 口数
              Text(
                '${AppUtils().formatNumberByTwoDigits(units.abs())}口',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),

              // 基准价额
              Text(
                '@¥${AppUtils().formatNumberByTwoDigits(transaction['basePrice'])}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 积立设定基金卡片组件
class _RecurringFundCard extends StatefulWidget {
  final String fundName;
  final List<Map<String, dynamic>> settings;
  final Function(int) onEdit;
  final Function(int) onDelete;

  const _RecurringFundCard({
    required this.fundName,
    required this.settings,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_RecurringFundCard> createState() => _RecurringFundCardState();
}

class _RecurringFundCardState extends State<_RecurringFundCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // 获取最新的设定（日期最近的）
    final latestSetting = widget.settings.isNotEmpty
        ? widget.settings.last
        : null;

    return CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 基金名称和操作按钮
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.fundName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => widget.onEdit(widget.settings.length - 1),
                icon: const Icon(Icons.edit, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              IconButton(
                onPressed: () => widget.onDelete(widget.settings.length - 1),
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),

          if (latestSetting != null) ...[
            const SizedBox(height: 16),

            // 账户类型和状态标签
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.appUpGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    latestSetting['accountType'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.appUpGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.appUpGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    latestSetting['status'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.appUpGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 频度和金额
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '頻度',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        latestSetting['frequencyDescription'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '積立金額',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppUtils().formatMoney(
                          latestSetting['amount'],
                          GlobalStore().selectedCurrencyCode ?? 'JPY',
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 开始日期
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '開始日',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  latestSetting['startDate'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            // 如果有多个设定，显示展开/收起按钮
            if (widget.settings.length > 1) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isExpanded
                            ? '他の設定を隠す'
                            : '他の${widget.settings.length - 1}件の設定を表示',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.appUpGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.appUpGreen,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // 展开的其他设定
            if (_isExpanded && widget.settings.length > 1) ...[
              const Divider(),
              const SizedBox(height: 16),
              ...widget.settings
                  .asMap()
                  .entries
                  .where((entry) => entry.key < widget.settings.length - 1)
                  .map((entry) {
                    final index = entry.key;
                    final setting = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildExpandedSettingItem(setting, index),
                    );
                  })
                  .toList(),
            ],
          ],
        ],
      ),
    );
  }

  // 展开的设定项目
  Widget _buildExpandedSettingItem(Map<String, dynamic> setting, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 设定标题和操作按钮
          Row(
            children: [
              Text(
                '設定 ${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => widget.onEdit(index),
                icon: const Icon(Icons.edit, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
              IconButton(
                onPressed: () => widget.onDelete(index),
                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 账户类型和状态
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.appUpGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  setting['accountType'],
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.appUpGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.appUpGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  setting['status'],
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.appUpGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 详细信息
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '頻度: ${setting['frequencyDescription']}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '金額: ${AppUtils().formatMoney(setting['amount'], GlobalStore().selectedCurrencyCode ?? 'JPY')}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                '開始: ${setting['startDate']}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
