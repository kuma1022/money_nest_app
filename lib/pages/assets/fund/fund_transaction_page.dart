import 'package:flutter/material.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';

class FundTransactionPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onSaved;
  final Map<String, dynamic>? editingData; // 编辑时传入的数据
  final bool isEditMode; // 是否为编辑模式

  const FundTransactionPage({
    super.key,
    required this.onSaved,
    this.editingData,
    this.isEditMode = false,
  });

  @override
  State<FundTransactionPage> createState() => _FundTransactionPageState();
}

class _FundTransactionPageState extends State<FundTransactionPage> {
  // 基本交易信息
  String _selectedTransactionType = '買付';
  String _selectedPurchaseType = 'one-time';

  // 控制器
  final TextEditingController _fundNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _basePriceController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  // 日期
  DateTime _selectedDate = DateTime.now();

  // 基金搜索相关状态
  Map<String, dynamic>? _selectedFund;
  List<Map<String, dynamic>> _fundSearchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';

  // 积立设定列表
  List<Map<String, dynamic>> _recurringSettings = [];

  // 个别购入的账户类型
  String _selectedAccountType = 'NISA（つみたて）';

  // 频率
  String _selectedFrequencyType =
      'monthly'; // daily, weekly, monthly, bimonthly
  Map<String, dynamic> _frequencyConfig = {
    'type': 'monthly',
    'days': [1],
  };

  // 选项列表
  final List<String> _purchaseTypes = ['one-time', '積立購入', '個別購入'];
  final List<Map<String, String>> _frequencyTypes = [
    {'value': 'daily', 'label': '毎日'},
    {'value': 'weekly', 'label': '毎週'},
    {'value': 'monthly', 'label': '毎月'},
    {'value': 'bimonthly', 'label': '隔月'},
  ];
  final List<String> _accountTypes = [
    'NISA（つみたて）',
    'NISA（成長）',
    '特定',
    'general',
  ];

  // 新增的控制器，用于积立设定的金额输入
  final TextEditingController _recurringAmountController =
      TextEditingController();

  // 新增的状态，用于处理结束日期
  DateTime _recurringStartDate = DateTime.now();
  DateTime _recurringEndDate = DateTime.now();
  bool _hasEndDate = false;

  // 周几的选项
  final List<Map<String, dynamic>> _weekDays = [
    {'value': 1, 'label': '月曜日'},
    {'value': 2, 'label': '火曜日'},
    {'value': 3, 'label': '水曜日'},
    {'value': 4, 'label': '木曜日'},
    {'value': 5, 'label': '金曜日'},
    {'value': 6, 'label': '土曜日'},
    {'value': 7, 'label': '日曜日'},
  ];

  @override
  void dispose() {
    _fundNameController.dispose();
    _amountController.dispose();
    _basePriceController.dispose();
    _feeController.dispose();
    _memoController.dispose();
    _recurringAmountController.dispose();
    // 释放积立设定的控制器
    _clearAllRecurringSettings();
    super.dispose();
  }

  // 初始化积立设定
  void _initializeRecurringSetting() {
    if (_recurringSettings.isEmpty) {
      _recurringSettings.add({
        'accountType': 'NISA（つみたて）',
        'frequency': '毎月1日',
        'amount': 0.0,
        'startDate': DateTime.now(),
        'endDate': null,
        'controllers': {'amount': TextEditingController()},
      });
    }
  }

  // 基金搜索方法
  Future<void> _searchFunds(String query) async {
    if (query.isEmpty) {
      setState(() {
        _fundSearchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // TODO: 替换为真实的 Supabase API 调用
    await Future.delayed(const Duration(milliseconds: 500));

    // Dummy 数据
    final dummyResults =
        [
              {
                'id': '1',
                'name': 'eMAXIS Slim 米国株式（S&P500）',
                'code': '09311179',
                'company': '三菱UFJ国際投信',
              },
              {
                'id': '2',
                'name': 'eMAXIS Slim 全世界株式（オール・カントリー）',
                'code': '03311179',
                'company': '三菱UFJ国際投信',
              },
              {
                'id': '3',
                'name': 'eMAXIS Slim 先進国株式インデックス',
                'code': '03312179',
                'company': '三菱UFJ国際投信',
              },
            ]
            .where(
              (fund) =>
                  fund['name']!.toLowerCase().contains(query.toLowerCase()) ||
                  fund['code']!.contains(query),
            )
            .toList();

    setState(() {
      _fundSearchResults = dummyResults;
      _isSearching = false;
    });
  }

  // 选择基金
  void _selectFund(Map<String, dynamic> fund) {
    setState(() {
      _selectedFund = fund;
      _fundSearchResults = [];
      _searchQuery = '';
      _fundNameController.clear();
      // 当选择了基金且是积立购入时，初始化积立设定
      if (_selectedPurchaseType == '積立購入') {
        _initializeRecurringSetting();
      }
    });
  }

  // 清除选择的基金
  void _clearSelectedFund() {
    setState(() {
      _selectedFund = null;
      _fundSearchResults = [];
      _searchQuery = '';
      // 清除积立设定
      _clearAllRecurringSettings();
    });
  }

  // 清除所有积立设定
  void _clearAllRecurringSettings() {
    for (final setting in _recurringSettings) {
      setting['controllers']['amount']?.dispose();
    }
    _recurringSettings.clear();
  }

  // 添加新的积立设定
  void _addNewRecurringSetting() {
    setState(() {
      _recurringSettings.add({
        'accountType': 'NISA（つみたて）',
        'frequency': '毎月1日',
        'amount': 0.0,
        'startDate': DateTime.now(),
        'endDate': null,
        'controllers': {'amount': TextEditingController()},
      });
    });
  }

  // 删除积立设定
  void _removeRecurringSetting(int index) {
    // 如果只有一个设定，不允许删除
    if (_recurringSettings.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('最低1つの積立設定が必要です'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      // 释放控制器
      _recurringSettings[index]['controllers']['amount']?.dispose();
      _recurringSettings.removeAt(index);
    });
  }

  // 更新积立设定字段
  void _updateRecurringSetting(int index, String field, dynamic value) {
    setState(() {
      _recurringSettings[index][field] = value;
    });
  }

  // 检查期间重合
  bool _hasDateOverlap(
    DateTime start1,
    DateTime? end1,
    DateTime start2,
    DateTime? end2,
  ) {
    final effectiveEnd1 = end1 ?? DateTime(2099, 12, 31);
    final effectiveEnd2 = end2 ?? DateTime(2099, 12, 31);

    return !(effectiveEnd1.isBefore(start2) || effectiveEnd2.isBefore(start1));
  }

  // 验证期间重合
  String? _validateDateOverlap() {
    for (int i = 0; i < _recurringSettings.length; i++) {
      for (int j = i + 1; j < _recurringSettings.length; j++) {
        if (_hasDateOverlap(
          _recurringSettings[i]['startDate'],
          _recurringSettings[i]['endDate'],
          _recurringSettings[j]['startDate'],
          _recurringSettings[j]['endDate'],
        )) {
          return '設定 ${i + 1} と設定 ${j + 1} の期間が重複しています';
        }
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    // 如果是编辑模式，预填充数据
    if (widget.isEditMode && widget.editingData != null) {
      _initializeEditingData();
    }
  }

  // 初始化编辑数据
  void _initializeEditingData() {
    final data = widget.editingData!;

    // 设置交易类型（固定为买付）
    _selectedTransactionType = '買付';

    // 设置购买类型（固定为积立购入）
    _selectedPurchaseType = '積立購入';

    // 设置基金信息
    _selectedFund = {
      'id': 'edit_fund_id', // 编辑模式下的临时ID
      'name': data['fundName'],
      'code': 'EDIT001', // 编辑模式下的临时代码
      'company': '編集中', // 编辑模式下的临时公司名
      'type': 'Investment Trust',
    };

    // 设置积立设定相关数据
    final settingData = data['settingData'] as Map<String, dynamic>;

    _selectedAccountType = settingData['accountType'];

    // 解析频率设定
    if (settingData['frequencyType'] != null &&
        settingData['frequencyConfig'] != null) {
      _selectedFrequencyType = settingData['frequencyType'];
      _frequencyConfig = Map<String, dynamic>.from(
        settingData['frequencyConfig'],
      );
    } else {
      // 向后兼容旧数据
      final frequency = settingData['frequency'] as String?;
      _convertLegacyFrequency(frequency);
    }

    _recurringAmountController.text = settingData['amount'].toString();

    // 解析开始日期
    final startDateParts = settingData['startDate'].split('-');
    _recurringStartDate = DateTime(
      int.parse(startDateParts[0]),
      int.parse(startDateParts[1]),
      int.parse(startDateParts[2]),
    );

    // 设置结束日期（如果有的话）
    if (settingData['endDate'] != null) {
      final endDateParts = settingData['endDate'].split('-');
      _recurringEndDate = DateTime(
        int.parse(endDateParts[0]),
        int.parse(endDateParts[1]),
        int.parse(endDateParts[2]),
      );
      _hasEndDate = true;
    }
  }

  // 向后兼容旧的频率格式
  void _convertLegacyFrequency(String? frequency) {
    switch (frequency) {
      case '毎日':
        _selectedFrequencyType = 'daily';
        _frequencyConfig = {'type': 'daily'};
        break;
      case '毎月1日':
        _selectedFrequencyType = 'monthly';
        _frequencyConfig = {
          'type': 'monthly',
          'days': [1],
        };
        break;
      case '毎月15日':
        _selectedFrequencyType = 'monthly';
        _frequencyConfig = {
          'type': 'monthly',
          'days': [15],
        };
        break;
      default:
        _selectedFrequencyType = 'monthly';
        _frequencyConfig = {
          'type': 'monthly',
          'days': [1],
        };
    }
  }

  // 修改积立设定UI
  Widget _buildRecurringSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.repeat, size: 18, color: AppColors.appUpGreen),
              SizedBox(width: 8),
              Text(
                '積立設定',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 预金区分（编辑模式下禁用）
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '預かり区分',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: widget.isEditMode
                      ? Colors.grey.shade200
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedAccountType,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: widget.isEditMode ? Colors.grey.shade500 : null,
                    ),
                    items: _accountTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(
                          type,
                          style: TextStyle(
                            color: widget.isEditMode
                                ? Colors.grey.shade600
                                : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: widget.isEditMode
                        ? null
                        : (String? newValue) {
                            if (newValue != null) {
                              setState(() => _selectedAccountType = newValue);
                            }
                          },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 频度类型和金额
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '積立頻度',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFrequencyType,
                          isExpanded: true,
                          isDense: true,
                          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                          items: _frequencyTypes.map((
                            Map<String, String> freq,
                          ) {
                            return DropdownMenuItem<String>(
                              value: freq['value'],
                              child: Text(
                                freq['label']!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedFrequencyType = newValue;
                                _initializeFrequencyConfig(newValue);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '積立金額',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _recurringAmountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: '10000',
                          hintStyle: TextStyle(fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 频度详细设定
          _buildFrequencyDetailSettings(),
          const SizedBox(height: 16),

          // 日期范围
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '開始日',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectStartDate(0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _formatDate(_recurringStartDate),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '終了日（任意）',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectEndDate(0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _hasEndDate
                                    ? _formatDate(_recurringEndDate)
                                    : '継続',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 初始化频度配置
  void _initializeFrequencyConfig(String frequencyType) {
    switch (frequencyType) {
      case 'daily':
        _frequencyConfig = {'type': 'daily'};
        break;
      case 'weekly':
        _frequencyConfig = {
          'type': 'weekly',
          'days': [1],
        }; // 默认周一
        break;
      case 'monthly':
        _frequencyConfig = {
          'type': 'monthly',
          'days': [1],
        }; // 默认每月1号
        break;
      case 'bimonthly':
        _frequencyConfig = {
          'type': 'bimonthly',
          'months': 'odd',
          'days': [1],
        }; // 默认奇数月1号
        break;
    }
  }

  // 频度详细设定UI
  Widget _buildFrequencyDetailSettings() {
    switch (_selectedFrequencyType) {
      case 'daily':
        return _buildDailySettings();
      case 'weekly':
        return _buildWeeklySettings();
      case 'monthly':
        return _buildMonthlySettings();
      case 'bimonthly':
        return _buildBimonthlySettings();
      default:
        return const SizedBox.shrink();
    }
  }

  // 每日设定（无需额外设定）
  Widget _buildDailySettings() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.appUpGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: AppColors.appUpGreen),
          SizedBox(width: 8),
          Text(
            '毎日積立が実行されます',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.appUpGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 每周设定
  Widget _buildWeeklySettings() {
    final selectedDays = List<int>.from(_frequencyConfig['days'] ?? [1]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '実行曜日を選択',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _weekDays.map((day) {
            final isSelected = selectedDays.contains(day['value']);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    if (selectedDays.length > 1) {
                      selectedDays.remove(day['value']);
                    }
                  } else {
                    selectedDays.add(day['value']);
                  }
                  _frequencyConfig['days'] = selectedDays;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.appUpGreen : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.appUpGreen
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  day['label'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 每月设定
  Widget _buildMonthlySettings() {
    final selectedDays = List<int>.from(_frequencyConfig['days'] ?? [1]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '実行日を選択（複数選択可能）',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              // 快速选择按钮
              Row(
                children: [
                  _buildQuickSelectButton('1日', [1], selectedDays),
                  const SizedBox(width: 8),
                  _buildQuickSelectButton('15日', [15], selectedDays),
                  const SizedBox(width: 8),
                  _buildQuickSelectButton('月末', [31], selectedDays),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _frequencyConfig['days'] = [];
                      });
                    },
                    child: const Text('クリア', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 日期网格
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 1,
                ),
                itemCount: 31,
                itemBuilder: (context, index) {
                  final day = index + 1;
                  final isSelected = selectedDays.contains(day);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          if (selectedDays.length > 1) {
                            selectedDays.remove(day);
                          }
                        } else {
                          selectedDays.add(day);
                        }
                        _frequencyConfig['days'] = selectedDays;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.appUpGreen : Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.appUpGreen
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          day.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 隔月设定
  Widget _buildBimonthlySettings() {
    final selectedMonths = _frequencyConfig['months'] ?? 'odd';
    final selectedDays = List<int>.from(_frequencyConfig['days'] ?? [1]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 月份选择
        const Text(
          '対象月を選択',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _frequencyConfig['months'] = 'odd';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: selectedMonths == 'odd'
                        ? AppColors.appUpGreen
                        : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: selectedMonths == 'odd'
                          ? AppColors.appUpGreen
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '奇数月',
                      style: TextStyle(
                        fontSize: 14,
                        color: selectedMonths == 'odd'
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _frequencyConfig['months'] = 'even';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: selectedMonths == 'even'
                        ? AppColors.appUpGreen
                        : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: selectedMonths == 'even'
                          ? AppColors.appUpGreen
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '偶数月',
                      style: TextStyle(
                        fontSize: 14,
                        color: selectedMonths == 'even'
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 复用每月设定的日期选择
        _buildMonthlySettings(),
      ],
    );
  }

  // 快速选择按钮
  Widget _buildQuickSelectButton(
    String label,
    List<int> days,
    List<int> selectedDays,
  ) {
    final isSelected = days.every((day) => selectedDays.contains(day));

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            for (final day in days) {
              selectedDays.remove(day);
            }
          } else {
            for (final day in days) {
              if (!selectedDays.contains(day)) {
                selectedDays.add(day);
              }
            }
          }
          if (selectedDays.isEmpty) {
            selectedDays.add(1); // 至少保留一个日期
          }
          _frequencyConfig['days'] = selectedDays;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.appUpGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.appUpGreen : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // 获取频率描述文本
  String _getFrequencyDescription() {
    switch (_selectedFrequencyType) {
      case 'daily':
        return '毎日';
      case 'weekly':
        final days = List<int>.from(_frequencyConfig['days'] ?? []);
        final dayLabels = days
            .map(
              (day) => _weekDays.firstWhere((w) => w['value'] == day)['label'],
            )
            .join('・');
        return '毎週 $dayLabels';
      case 'monthly':
        final days = List<int>.from(_frequencyConfig['days'] ?? []);
        final dayLabels = days
            .map((day) => day == 31 ? '月末' : '${day}日')
            .join('・');
        return '毎月 $dayLabels';
      case 'bimonthly':
        final months = _frequencyConfig['months'] == 'odd' ? '奇数月' : '偶数月';
        final days = List<int>.from(_frequencyConfig['days'] ?? []);
        final dayLabels = days
            .map((day) => day == 31 ? '月末' : '${day}日')
            .join('・');
        return '$months $dayLabels';
      default:
        return '';
    }
  }

  // 修改保存交易方法，包含新的频率数据
  void _saveTransaction() {
    // 输入验证
    if (_selectedFund == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ファンドを選択してください'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 根据不同购买类型验证必填字段
    if (_selectedPurchaseType == '積立購入') {
      // 检查期间重合
      final overlapError = _validateDateOverlap();
      if (overlapError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(overlapError), backgroundColor: Colors.red),
        );
        return;
      }

      // 检查是否所有设定都有金额
      for (int i = 0; i < _recurringSettings.length; i++) {
        final controller =
            _recurringSettings[i]['controllers']['amount']
                as TextEditingController;
        if (controller.text.isEmpty ||
            (double.tryParse(controller.text) ?? 0.0) <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('積立設定 ${i + 1} の金額を入力してください'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    } else {
      final hasValidAmount = _amountController.text.isNotEmpty;
      if (!hasValidAmount) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('金額を入力してください'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // 更新积立设定中的金额
    if (_selectedPurchaseType == '積立購入') {
      for (int i = 0; i < _recurringSettings.length; i++) {
        final controller =
            _recurringSettings[i]['controllers']['amount']
                as TextEditingController;
        _recurringSettings[i]['amount'] =
            double.tryParse(controller.text) ?? 0.0;
      }
    }

    // 构建交易数据
    final transactionData = {
      'transactionType': _selectedTransactionType,
      'purchaseType': _selectedPurchaseType,
      'fundId': _selectedFund!['id'],
      'fundName': _selectedFund!['name'],
      'fundCode': _selectedFund!['code'],
      'accountType': _selectedPurchaseType == '積立購入'
          ? null // 积立购入的账户类型在每个设定中
          : _selectedAccountType,
      'amount': _selectedPurchaseType == '積立購入'
          ? null // 积立购入的金额在每个设定中
          : double.tryParse(_amountController.text) ?? 0.0,
      'basePrice': double.tryParse(_basePriceController.text) ?? 0.0,
      'fee': double.tryParse(_feeController.text) ?? 0.0,
      'memo': _memoController.text,
      if (_selectedPurchaseType == '積立購入') ...{
        'recurringSettings': [
          {
            'accountType': _selectedAccountType,
            'frequencyType': _selectedFrequencyType,
            'frequencyConfig': _frequencyConfig,
            'frequencyDescription': _getFrequencyDescription(),
            'amount': double.tryParse(_recurringAmountController.text) ?? 0.0,
            'startDate': _recurringStartDate,
            'endDate': _hasEndDate ? _recurringEndDate : null,
          },
        ],
      } else ...{
        'transactionDate': _selectedDate,
      },
      'createdAt': DateTime.now(),
    };

    // 调用回调函数
    widget.onSaved(transactionData);

    // 关闭页面
    Navigator.of(context).pop();
  }

  // 购入详细（包含所有个别购入相关字段）
  Widget _buildPurchaseDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shopping_cart, size: 18, color: AppColors.appUpGreen),
              SizedBox(width: 8),
              Text(
                '購入詳細',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 金额和基准价额
          _buildAmountFields(),
          const SizedBox(height: 16),

          // 购入日期
          _buildDatePicker(),
          const SizedBox(height: 16),

          // 手续费
          _buildFeeField(),
        ],
      ),
    );
  }

  // 账户类型选择器
  Widget _buildAccountTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '預かり区分',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedAccountType,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: _accountTypes.map((String type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() => _selectedAccountType = newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // 金额字段（金额和基准价额）
  Widget _buildAmountFields() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedPurchaseType == '個別購入' ? '購入金額' : '金額',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: _selectedPurchaseType == '個別購入'
                        ? '例: 100000'
                        : '50000',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '基準価額',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _basePriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '21.32',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 日期选择器
  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedPurchaseType == '個別購入' ? '購入日' : '取引日',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_selectedDate.year}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 手续费字段
  Widget _buildFeeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '手数料（任意）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _feeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '例: 500',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  // 备注字段
  Widget _buildMemoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'メモ（任意）',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _memoController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: _selectedPurchaseType == '積立購入'
                  ? '積立に関するメモを入力'
                  : '購入に関するメモを入力',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  // 底部按钮
  Widget _buildBottomButtons() {
    bool canSave = false;

    if (_selectedTransactionType == '売却') {
      canSave = _selectedFund != null;
    } else if (_selectedTransactionType == '買付') {
      canSave = _selectedPurchaseType != 'one-time' && _selectedFund != null;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: const Text(
                'キャンセル',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: canSave ? _saveTransaction : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canSave ? AppColors.appUpGreen : Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: Text(
                widget.isEditMode ? '更新' : '保存',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 日期选择方法
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('ja', 'JP'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // 显示基金搜索对话框
  void _showFundSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ファンド検索'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _fundNameController,
                  onChanged: (value) {
                    _searchQuery = value;
                    _searchFunds(value);
                  },
                  decoration: const InputDecoration(
                    hintText: 'ファンドを検索...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    suffixIcon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 8),
                // 搜索状态和结果
                if (_isSearching) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('検索中...'),
                      ],
                    ),
                  ),
                ] else if (_fundSearchResults.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _fundSearchResults.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1, color: Colors.grey.shade200),
                      itemBuilder: (context, index) {
                        final fund = _fundSearchResults[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text(
                            fund['name']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            '${fund['company']} • ${fund['code']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          onTap: () {
                            _selectFund(fund);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
                ] else if (_searchQuery.isNotEmpty && !_isSearching) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '該当するファンドが見つかりませんでした',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  // 添加缺失的build方法
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEditMode ? '積立設定編集' : '取引追加',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_selectedTransactionType == '買付')
              Text(
                widget.isEditMode ? '積立設定の内容を編集します' : '投資信託の買付・売却を記録します',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // 编辑模式下隐藏交易类型选择器
                    if (!widget.isEditMode) ...[
                      _buildTransactionTypeSelector(),
                      const SizedBox(height: 20),
                    ],

                    // 购买种类选择（只在买付时显示，编辑模式下隐藏）
                    if (_selectedTransactionType == '買付' &&
                        !widget.isEditMode) ...[
                      _buildPurchaseTypeSelector(),
                      const SizedBox(height: 20),
                    ],

                    // 基金选择（编辑模式下禁用）
                    if (_selectedTransactionType == '売却' ||
                        (_selectedTransactionType == '買付' &&
                            _selectedPurchaseType != 'one-time')) ...[
                      _buildInvestmentTrustInfo(),
                      _buildFundNameField(disabled: widget.isEditMode),
                      const SizedBox(height: 20),

                      // 只有选择了基金后才显示后续项目
                      if (_selectedFund != null) ...[
                        // 积立购入的设定
                        if (_selectedPurchaseType == '積立購入') ...[
                          _buildRecurringSettings(),
                          const SizedBox(height: 20),
                        ],

                        // 个别购入的设定
                        if (_selectedPurchaseType == '個別購入') ...[
                          _buildAccountTypeSelector(),
                          const SizedBox(height: 20),
                          _buildPurchaseDetails(),
                          const SizedBox(height: 20),
                        ],

                        // 备注
                        _buildMemoField(),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  // 添加缺失的交易类型选择器
  Widget _buildTransactionTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '取引種別',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildTransactionTypeButton('買付', '買付')),
            const SizedBox(width: 12),
            Expanded(child: _buildTransactionTypeButton('売却', '売却')),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionTypeButton(String type, String label) {
    final isSelected = _selectedTransactionType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedTransactionType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.appUpGreen : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.appUpGreen : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // 添加缺失的购买类型选择器
  Widget _buildPurchaseTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '購入種別',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildPurchaseTypeButton('個別購入', '個別購入')),
            const SizedBox(width: 12),
            Expanded(child: _buildPurchaseTypeButton('積立購入', '積立購入')),
          ],
        ),
      ],
    );
  }

  Widget _buildPurchaseTypeButton(String type, String label) {
    final isSelected = _selectedPurchaseType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPurchaseType = type;
          if (type == '積立購入' && _selectedFund != null) {
            _initializeRecurringSetting();
          } else {
            _clearAllRecurringSettings();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.appUpGreen : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.appUpGreen : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // 添加缺失的投资信托信息标题
  Widget _buildInvestmentTrustInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '投資信託情報',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '取引するファンドを選択してください',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  // 添加缺失的基金名称字段
  Widget _buildFundNameField({bool disabled = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ファンド名',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: disabled ? Colors.grey.shade200 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _fundNameController,
            enabled: !disabled,
            decoration: InputDecoration(
              hintText: _selectedFund?['name'] ?? 'ファンド名を入力',
              hintStyle: TextStyle(
                color: disabled ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              suffixIcon: _selectedFund == null
                  ? (disabled
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: _showFundSearchDialog,
                          ))
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: disabled
                          ? null
                          : () {
                              setState(() {
                                _selectedFund = null;
                                _fundNameController.clear();
                              });
                            },
                    ),
            ),
            style: TextStyle(
              color: disabled ? Colors.grey.shade600 : Colors.black,
            ),
          ),
        ),
        // 显示选中的基金信息
        if (_selectedFund != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.appUpGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.appUpGreen.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedFund!['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selectedFund!['company']} • ${_selectedFund!['code']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // 添加缺失的日期格式化方法
  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  // 添加缺失的开始日期选择方法
  Future<void> _selectStartDate(int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _recurringStartDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      locale: const Locale('ja', 'JP'),
    );
    if (picked != null) {
      setState(() {
        _recurringStartDate = picked;
      });
    }
  }

  // 添加缺失的结束日期选择方法
  Future<void> _selectEndDate(int index) async {
    final startDate = _recurringStartDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _hasEndDate
          ? _recurringEndDate
          : startDate.add(const Duration(days: 365)),
      firstDate: startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      locale: const Locale('ja', 'JP'),
    );
    if (picked != null) {
      setState(() {
        _recurringEndDate = picked;
        _hasEndDate = true;
      });
    } else {
      // 用户可能想要清除结束日期
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('終了日'),
          content: const Text('終了日を設定しませんか？'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _hasEndDate = false;
                  _recurringEndDate = DateTime.now();
                });
                Navigator.of(context).pop();
              },
              child: const Text('継続'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
          ],
        ),
      );
    }
  }
}
