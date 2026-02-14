import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' hide Column;
import 'package:intl/intl.dart';
import 'package:money_nest_app/components/custom_date_dropdown_field.dart';
import 'package:money_nest_app/components/modern_hud_dropdown.dart';
import 'package:money_nest_app/components/custom_input_form_field_by_suggestion.dart';
import 'package:money_nest_app/components/custom_text_form_field.dart';
import 'package:money_nest_app/components/glass_tab.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/models/categories.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/models/trade_type.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/presentation/resources/app_texts.dart';
import 'package:money_nest_app/services/data_sync_service.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:money_nest_app/util/global_store.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'trade_history_tab_page.dart'; // 导入 TradeRecord/TradeType

class TradeAddEditPage extends StatefulWidget {
  final String mode;
  final String type; // 'asset' or 'liability'
  final TradeRecordDisplay record; // 支持编辑模式
  final Stock? initialStock;
  final VoidCallback? onClose;
  final AppDatabase db;
  const TradeAddEditPage({
    super.key,
    this.onClose,
    required this.db,
    required this.record,
    required this.mode,
    required this.type,
    this.initialStock,
  }); //this.record});

  @override
  State<TradeAddEditPage> createState() => _TradeAddEditPageState();
}

class _TradeAddEditPageState extends State<TradeAddEditPage> {
  // 共通 State
  int tabIndex = 0; // 0: 資産, 1: 負債
  final List<dynamic> tradeTypes = TradeType.values
      .map((e) => {'code': e.code, 'name': e.displayName})
      .toList();
  String? tradeDate; // 取引日

  // ##### 0. 資産 #####
  late final int tradeId; // 编辑模式下的交易ID
  // ----- 0-1. カテゴリ・サブカテゴリ -----
  late final List<Categories> assetCategories;
  late final Map<String, List<Map<String, dynamic>>> assetCategoriesWithSub;
  String assetCategoryCode = '';
  String assetSubCategoryCode = '';

  // ----- 0-2. 株式 -----
  // 操作タイプ（買い or 売り）
  ActionType tradeAction = ActionType.buy;
  // 0-2-1. 買い
  // 銘柄情報
  final TextEditingController _stockCodeController = TextEditingController();
  final FocusNode _stockCodeFocusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  List<Stock> _stockSuggestions = [];
  bool _stockLoading = false;
  Timer? _debounceTimer;
  String _lastQueriedValue = '';
  bool _selectedFromDropdown = false;
  Stock? selectedStockInfo;
  String selectedStockCode = '';
  String selectedStockName = '';
  // 取引詳細
  // 口座区分
  late String tradeTypeCode = tradeTypes.first['code'];
  // 数量・単価・金額
  final _numberFormatter = NumberFormat("#,##0.####");
  final TextEditingController _quantityController = TextEditingController();
  final FocusNode _quantityFocusNode = FocusNode();
  final TextEditingController _unitPriceController = TextEditingController();
  final FocusNode _unitPriceFocusNode = FocusNode();
  final TextEditingController _amountController = TextEditingController();
  num? quantityValue;
  num? unitPriceValue;
  // 手数料・手数料通貨
  final TextEditingController _commissionController = TextEditingController();
  final FocusNode _commissionFocusNode = FocusNode();
  final List<String> commissionCurrencies = Currency.values
      .map((e) => e.code)
      .toList();
  num? commissionValue;
  late String commissionCurrency;
  // メモ
  String? memoValue;
  final TextEditingController _memoController = TextEditingController();
  
  // NEW: Cash Balance Update Checkbox
  bool _updateCashBalance = false;

  // 0-2-2. 売り
  // 売却する銘柄情報
  List<Map<String, dynamic>> sellHoldings = [];
  int? selectedSellStockId;
  String selectedSellStockCode = '';
  String selectedSellStockName = '';
  String selectedSellStockExchange = '';
  // 取引詳細
  // 取引日
  // String? tradeDate; // 共用buy/sell
  // 売却数量・売却単価・売却金額
  Map<String, TextEditingController> sellBatchControllers = {};
  Map<String, FocusNode> sellBatchFocusNodes = {};
  List<dynamic> sellBatches = [];
  num sellTotalQty = 0;
  final TextEditingController _sellUnitPriceController =
      TextEditingController();
  final TextEditingController _sellAmountController = TextEditingController(
    text: '¥0',
  );
  final FocusNode _sellUnitPriceFocusNode = FocusNode();
  num? sellUnitPrice;
  // 売却手数料・手数料通貨
  final TextEditingController _sellCommissionController =
      TextEditingController();
  final FocusNode _sellCommissionFocusNode = FocusNode();
  num? sellCommissionValue;
  late String sellCommissionCurrency;
  // 売却メモ
  String? sellMemoValue;
  final TextEditingController _sellMemoController = TextEditingController();

  // ----- 0-3. 投資信託 -----
  String selectedPurchaseType = 'saving-plan';
  // 账户类型
  late String fundSelectedAccountType = tradeTypes.first['code'];
  // 基金搜索相关状态
  final TextEditingController fundNameController = TextEditingController();
  Fund? selectedFund;
  List<Map<String, dynamic>> fundSearchResults = [];
  OverlayEntry? _fundOverlayEntry;
  bool isSearching = false;
  String searchQuery = '';
  Timer? _fundDebounceTimer;
  bool _fundSelectedFromDropdown = false;
  String _lastQueriedFundValue = '';
  final FocusNode _fundCodeFocusNode = FocusNode();
  List<Fund> _fundSuggestions = [];
  bool _fundLoading = false;
  // 频率
  String fundSelectedFrequencyType =
      'monthly'; // daily, weekly, monthly, bimonthly
  Map<String, dynamic> fundFrequencyConfig = {
    'type': 'monthly',
    'days': [1],
  };
  // 选项列表
  final List<Map<String, String>> frequencyTypes = [
    {'value': 'daily', 'label': '毎日'},
    {'value': 'weekly', 'label': '毎週'},
    {'value': 'monthly', 'label': '毎月'},
    {'value': 'bimonthly', 'label': '隔月'},
  ];
  // 周几的选项
  final List<Map<String, dynamic>> fundWeekDays = [
    {'value': 1, 'label': '月曜日'},
    {'value': 2, 'label': '火曜日'},
    {'value': 3, 'label': '水曜日'},
    {'value': 4, 'label': '木曜日'},
    {'value': 5, 'label': '金曜日'},
    {'value': 6, 'label': '土曜日'},
    {'value': 7, 'label': '日曜日'},
  ];
  // 金额
  final TextEditingController fundRecurringAmountController =
      TextEditingController();
  final FocusNode fundRecurringAmountFocusNode = FocusNode();
  num fundRecurringAmount = 0.0;
  // 状态 用于处理结束日期
  DateTime fundRecurringStartDate = DateTime.now();
  DateTime fundRecurringEndDate = DateTime.now();
  bool fundHasEndDate = false;
  // memo
  final TextEditingController fundMemoController = TextEditingController();
  String? fundMemoValue;

  // ##### 1. 負債 #####
  // ----- 1-1. カテゴリ・サブカテゴリ -----
  String debtCategoryCode = '';
  String debtSubCategoryCode = '';
  late final List<Categories> debtCategories;
  late final Map<String, List<Map<String, dynamic>>> debtCategoriesWithSub;

  // 初始化处理
  @override
  void initState() {
    super.initState();

    setState(() {
      // 初始化资产类别
      //if (widget.mode == 'add' ||
      //    widget.mode == 'edit' && widget.type == 'asset') {
      assetCategories =
          Categories.values.where((cat) => cat.type == 'asset').toList()
            ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      assetCategoriesWithSub = assetCategories
          .fold<Map<String, List<Map<String, dynamic>>>>({}, (map, cat) {
            map[cat.code] = Subcategories.values
                .where((sub) => sub.categoryId == cat.id)
                .map(
                  (e) => {
                    'id': e.id,
                    'code': e.code,
                    'name': e.name,
                    'displayOrder': e.displayOrder,
                  },
                )
                .toList();
            map[cat.code]?.sort(
              (a, b) => a['displayOrder'].compareTo(b['displayOrder']),
            );
            return map;
          });
      //}
      // 初始化负债类别
      //if (widget.mode == 'add' ||
      //    widget.mode == 'edit' && widget.type == 'liability') {
      debtCategories =
          Categories.values.where((cat) => cat.type == 'liability').toList()
            ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      debtCategoriesWithSub = debtCategories
          .fold<Map<String, List<Map<String, dynamic>>>>({}, (map, cat) {
            map[cat.code] = Subcategories.values
                .where((sub) => sub.categoryId == cat.id)
                .map(
                  (e) => {
                    'id': e.id,
                    'code': e.code,
                    'name': e.name,
                    'displayOrder': e.displayOrder,
                  },
                )
                .toList();
            map[cat.code]?.sort(
              (a, b) => a['displayOrder'].compareTo(b['displayOrder']),
            );
            return map;
          });
      //}
    });

    // ADD MODE 初始化默认值
    if (widget.mode == 'add') {
      // 设置默认的货币选项
      setState(() {
        commissionCurrency = commissionCurrencies.first;
        sellCommissionCurrency = commissionCurrencies.first;
      });

      if (widget.initialStock != null) {
        final stock = widget.initialStock!;
        setState(() {
          tabIndex = 0;
          assetCategoryCode = 'stock';
          assetSubCategoryCode =
              stock.exchange == 'JP' ? 'jp_stock' : 'us_stock';
          selectedStockInfo = stock;
          selectedStockCode = stock.ticker ?? '';
          _stockCodeController.text = selectedStockCode;
          selectedStockName = stock.name;
        });
      }
    }

    // EDIT MODE 初始化已有值
    if (widget.mode == 'edit') {
      final record = widget.record;
      tradeId = record.id;
      if (widget.type == 'asset') {
        setState(() {
          tabIndex = 0;
          assetCategoryCode = record.assetType;
          assetSubCategoryCode = record.stockInfo.exchange == 'JP'
              ? 'jp_stock'
              : 'us_stock';
          tradeAction = record.action;
          if (tradeAction == ActionType.buy) {
            selectedStockInfo = record.stockInfo;
            selectedStockCode = record.stockInfo.ticker ?? '';
            _stockCodeController.text = selectedStockCode;
            selectedStockName = record.stockInfo.name;
            tradeDate = record.tradeDate;
            tradeTypeCode = record.tradeType;
            quantityValue = record.quantity;
            _quantityController.text = quantityValue.toString();
            unitPriceValue = record.price;
            _unitPriceController.text = unitPriceValue.toString();
            _updateAmount();
            commissionValue = record.feeAmount;
            _commissionController.text = commissionValue.toString();
            commissionCurrency = record.feeCurrency;
            memoValue = record.remark;
            _memoController.text = memoValue ?? '';
          } else if (tradeAction == ActionType.sell) {
            selectedSellStockId = record.stockInfo.id;
            selectedSellStockCode = record.stockInfo.ticker ?? '';
            selectedSellStockName = record.stockInfo.name;
            selectedSellStockExchange = record.stockInfo.exchange ?? '';
            tradeDate = record.tradeDate;
            sellTotalQty = record.quantity;
            sellUnitPrice = record.price;
            _sellUnitPriceController.text = sellUnitPrice.toString();
            _updateSellAmount();
            sellCommissionValue = record.feeAmount;
            _sellCommissionController.text = sellCommissionValue.toString();
            sellCommissionCurrency = record.feeCurrency;
            sellMemoValue = record.remark;
            _sellMemoController.text = sellMemoValue ?? '';
          }
        });
      } else if (widget.type == 'liability') {
        // 负债的其他字段初始化略
      }
    }

    // 初始化数字输入框的格式化监听
    addFocusFormatListener(
      focusNode: _quantityFocusNode,
      controller: _quantityController,
      numberFormatter: _numberFormatter,
      maxDecimal: 4,
      afterFormat: _updateAmount,
    );
    addFocusFormatListener(
      focusNode: _unitPriceFocusNode,
      controller: _unitPriceController,
      numberFormatter: _numberFormatter,
      maxDecimal: 4,
      afterFormat: _updateAmount,
    );
    addFocusFormatListener(
      focusNode: _commissionFocusNode,
      controller: _commissionController,
      numberFormatter: _numberFormatter,
      maxDecimal: 4, // 最多4位小数
    );
    addFocusFormatListener(
      focusNode: _sellUnitPriceFocusNode,
      controller: _sellUnitPriceController,
      numberFormatter: _numberFormatter,
      maxDecimal: 4, // 最多4位小数
      afterFormat: _updateSellAmount,
    );
    addFocusFormatListener(
      focusNode: _sellCommissionFocusNode,
      controller: _sellCommissionController,
      numberFormatter: _numberFormatter,
      maxDecimal: 4, // 最多4位小数
    );
    addFocusFormatListener(
      focusNode: fundRecurringAmountFocusNode,
      controller: fundRecurringAmountController,
      numberFormatter: _numberFormatter,
      maxDecimal: 4, // 最多4位小数
    );

    if (widget.mode == 'add') {
      // 初始化卖出持仓
      _loadSellHoldings();
    }
    if (widget.mode == 'edit' &&
        widget.type == 'asset' &&
        tradeAction == ActionType.sell) {
      // 编辑模式下初始化卖出持仓
      _loadSellHoldings(notNeedRefresh: true);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _quantityFocusNode.dispose();
    _unitPriceController.dispose();
    _unitPriceFocusNode.dispose();
    _amountController.dispose();
    _stockCodeController.dispose();
    _stockCodeFocusNode.dispose();
    _commissionController.dispose();
    _commissionFocusNode.dispose();
    _memoController.dispose();
    _sellCommissionController.dispose();
    _sellCommissionFocusNode.dispose();
    _sellUnitPriceController.dispose();
    _sellUnitPriceFocusNode.dispose();
    _sellMemoController.dispose();
    for (var node in sellBatchFocusNodes.values) {
      node.dispose();
    }
    for (var controller in sellBatchControllers.values) {
      controller.dispose();
    }
    _removeOverlay();
    _debounceTimer?.cancel();
    // 释放积立设定的控制器
    fundNameController.dispose();
    _fundCodeFocusNode.dispose();
    fundMemoController.dispose();
    fundRecurringAmountController.dispose();
    fundRecurringAmountFocusNode.dispose();
    super.dispose();
  }

  // MARK: - New Stock UI Methods

  Widget _buildStockTradeUI() {
    // Determine color based on action
    final actionColor = _getActionColor();
    final stock = selectedStockInfo;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: widget.onClose ?? () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              if (stock?.logo != null && stock!.logo!.isNotEmpty)
                 Container(
                    width: 24, height: 24,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(stock!.logo!, errorBuilder: (c,e,s) => Container(color: Colors.grey)),
                 )
              else 
                 Container(
                    width: 24, height: 24,
                    decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(stock?.name.substring(0,1) ?? 'S', style: const TextStyle(color: Colors.white, fontSize: 12)),
                 ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(stock?.name ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildActionSelectorUI(),
              const SizedBox(height: 24),
              Text(
                '取引所\n${stock?.exchange ?? ''}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 8),
              _buildTradeFormUI(),
              const SizedBox(height: 40),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: actionColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _handleSave,
              child: const Text('取引を追加', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }

  Color _getActionColor() {
    switch (tradeAction) {
      case ActionType.buy:
        return const Color(0xFFE02020); // Buy Red (from screenshot button) or maybe standard Red
      case ActionType.sell:
        return const Color(0xFF00C853); // Sell Green
      case ActionType.dividend:
        return const Color(0xFF6200EA); // Dividend Purple
      default:
        return Colors.blue;
    }
  }

  Widget _buildActionSelectorUI() {
    return Row(
      children: [
        _buildActionBtn('購入', ActionType.buy),
        const SizedBox(width: 12),
        _buildActionBtn('売却', ActionType.sell),
        const SizedBox(width: 12),
        _buildActionBtn('配当', ActionType.dividend),
      ],
    );
  }

  void _setupSellMode() {
    if (selectedStockInfo == null) return;
    setState(() {
      selectedSellStockId = selectedStockInfo!.id;
      selectedSellStockCode = selectedStockInfo!.ticker ?? '';
      selectedSellStockName = selectedStockInfo!.name;
      selectedSellStockExchange = selectedStockInfo!.exchange ?? '';
      tradeAction = ActionType.sell;
    });
    // Load holdings (batches) for this stock
    // This populates sellBatches
    _loadSellHoldings(notNeedRefresh: true);
  }

  // FIFO Allocation for Simple UI
  void _autoDistributeSellQuantity() {
    if (tradeAction != ActionType.sell || sellTotalQty <= 0) return;
    
    // Check if user manually allocated (if using the old UI). 
    // In new UI, they can't, so we assume we must allocate.
    // If sellBatches is empty, we can't allocate (error state or no holdings).
    
    double remaining = sellTotalQty.toDouble();
    for (var batch in sellBatches) {
      if (remaining <= 0) {
        batch['sell'] = 0;
        continue;
      }
      
      double available = (batch['quantity'] as num).toDouble();
      double allocate = 0;
      if (remaining >= available) {
        allocate = available;
      } else {
        allocate = remaining;
      }
      
      batch['sell'] = allocate;
      remaining -= allocate;
    }
  }

  Widget _buildActionBtn(String label, ActionType type) {
    final isSelected = tradeAction == type;
    final color = _getActionColor(); // Use the current action color for border if selected
    // Actually typically tabs change color.
    // Screenshot 1 (Buy): "購入" is filled with Red bg? Or Border? 
    // Screenshot 1: "Purchase" button at top seems NOT filled. It has a Red Border? 
    // Actually looking closely at Screenshot 1 (Buy):
    // "Purchase" has a red outline/background. "Sell" / "Dividend" are grey.
    // Screenshot 2 (Sell): "Sell" is Green filled (or outlined).
    // Screenshot 3 (Dividend): "Dividend" is Purple filled.
    
    // I will use Outline for unselected, Filled for selected.
    
    Color activeColor;
    switch(type) {
        case ActionType.buy: activeColor = const Color(0xFFE02020); break;
        case ActionType.sell: activeColor = const Color(0xFF00C853); break;
        case ActionType.dividend: activeColor = const Color(0xFF6200EA); break;
        default: activeColor = Colors.white;
    }

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            tradeAction = type;
            // Clean up or setup based on type
            if (type == ActionType.sell) {
               _setupSellMode();
            } else {
               // Reset sell specific controllers if switching back to buy?
               // Maybe keeping them is fine.
               // Ensure buy controllers are synced if needed.
            }
          });
        },
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? Colors.transparent : Colors.grey[900],
            border: Border.all(color: isSelected ? activeColor : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? activeColor : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTradeFormUI() {
    final currency = selectedStockInfo?.currency ?? '';
    
    // Calculate total holding for display
    num holdingQty = 0;
    if (tradeAction == ActionType.sell) {
       for(var b in sellBatches) {
         holdingQty += (b['quantity'] as num);
       }
    }

    return Column(
      children: [
        _buildFormRow(
          label: '口座区分',
          child: DropdownButtonHideUnderline(
             child: DropdownButton<String>(
               value: tradeTypeCode,
               dropdownColor: const Color(0xFF1C1C1E),
               style: const TextStyle(color: Colors.white, fontSize: 16),
               icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
               onChanged: (v) {
                 if (v != null) setState(() => tradeTypeCode = v);
               },
               items: tradeTypes.map((e) => DropdownMenuItem(
                  value: e['code'] as String,
                  child: Text(e['name'] as String),
               )).toList(),
             )
          )
        ),
        
        _buildFormRow(
          label: '日付と時刻',
          child: Text(
             tradeDate ?? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
             style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          onTap: () async {
             final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
             );
             if (date != null) {
               setState(() {
                 tradeDate = DateFormat('yyyy-MM-dd').format(date);
               });
             }
          }
        ),
        
        if (tradeAction != ActionType.dividend) ...[
            _buildFormRow(
              label: tradeAction == ActionType.buy ? '未調整の購入価格 $currency' : '未調整の販売価格 $currency',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   SizedBox(
                     width: 100,
                     child: TextField(
                        controller: tradeAction == ActionType.sell ? _sellUnitPriceController : _unitPriceController,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.right,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(border: InputBorder.none, hintText: '0', hintStyle: TextStyle(color: Colors.grey)),
                        onChanged: (v) {
                             // Bind to value
                             final val = num.tryParse(v);
                             if(tradeAction == ActionType.sell) sellUnitPrice = val; else unitPriceValue = val;
                        },
                     ),
                   ),
                   const SizedBox(width: 8),
                   const Text('単価', style: TextStyle(color: Colors.white)),
                   const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
                ],
              )
            ),
            _buildFormRow(
              label: tradeAction == ActionType.buy ? '購入数量' : '売却数量',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   SizedBox(
                     width: 100,
                     child: TextField(
                        controller: _quantityController, // Using same controller for simplicity in this view
                        // Warning: Save logic might need this to be populated for Sell
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.right,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(border: InputBorder.none, hintText: '0', hintStyle: TextStyle(color: Colors.grey)),
                        onChanged: (v) {
                             final val = num.tryParse(v);
                             setState(() {
                               quantityValue = val;
                               // Also update sell logic if needed
                               if (tradeAction == ActionType.sell) sellTotalQty = val ?? 0;
                             });
                        },
                     ),
                   ),
                   if (tradeAction == ActionType.sell)
                      Text('保有数量: $holdingQty', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              )
            ),
            
            // Expected Amount Row (Auto-calc)
            _buildFormRow(
              label: tradeAction == ActionType.buy ? '概算支払額' : '概算受取額',
              child: Text(
                 AppUtils().formatMoney(
                    ((quantityValue ?? 0) * (tradeAction == ActionType.sell ? (sellUnitPrice ?? 0) : (unitPriceValue ?? 0)) 
                    + (tradeAction == ActionType.buy ? (commissionValue ?? 0) : -(sellCommissionValue ?? 0))).toDouble(), // Buy adds fee (cost basis?), actually payment = price*qty + fee. Sell receipt = price*qty - fee.
                    currency
                 ),
                 style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
              ),
            ),
        ],

        if (tradeAction == ActionType.dividend)
            _buildFormRow(
              label: '配当額',
              child: Row(mainAxisSize: MainAxisSize.min, children:[
                   SizedBox(
                     width: 100,
                     child: TextField(
                        controller: _amountController, // Using amount controller for dividend? 
                        // Existing logic for Dividend might use amount directly or calculate it.
                        // Let's assume user enters total dividend amount here.
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.right,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(border: InputBorder.none, hintText: '0', hintStyle: TextStyle(color: Colors.grey)),
                     ),
                   ),
                   const SizedBox(width: 8),
                   Text(currency, style: const TextStyle(color: Colors.white)),
                   const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
              ]),
            ),

        _buildFormRow(
          label: '手数料',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
               SizedBox(
                 width: 100,
                 child: TextField(
                    controller: tradeAction == ActionType.sell ? _sellCommissionController : _commissionController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.right,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(border: InputBorder.none, hintText: '0', hintStyle: TextStyle(color: Colors.grey)),
                    onChanged: (v) {
                        final val = num.tryParse(v);
                        if(tradeAction == ActionType.sell) sellCommissionValue = val; else commissionValue = val;
                    },
                 ),
               ),
               const SizedBox(width: 8),
               Text(commissionCurrency, style: const TextStyle(color: Colors.white)),
               const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
            ],
          )
        ),

        // Cash Toggle
        _buildFormRow(
           label: tradeAction == ActionType.buy ? '利用可能な現金$currencyから差し引く' : '利用可能な現金を追加する',
           child: Switch(
              value: _updateCashBalance,
              onChanged: (v) => setState(() => _updateCashBalance = v),
              activeColor: _getActionColor(),
           ),
        ),

        if (tradeAction == ActionType.dividend)
           _buildFormRow(
             label: '配当期間',
             child: Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.green)),
                    ),
                    child: const Text('その他', style: TextStyle(color: Colors.green)),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white),
               ],
             )
           ),

        ExpansionTile(
           title: const Text('その他の設定', style: TextStyle(color: Colors.white, fontSize: 14)),
           iconColor: Colors.white,
           collapsedIconColor: Colors.white,
           children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                   controller: tradeAction == ActionType.sell ? _sellMemoController : _memoController,
                   style: const TextStyle(color: Colors.white),
                   decoration: const InputDecoration(
                     filled: true,
                     fillColor: Color(0xFF1C1C1E),
                     hintText: 'メモ',
                     hintStyle: TextStyle(color: Colors.grey),
                     border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                   ),
                ),
              )
           ],
        ),
      ],
    );
  }

  Widget _buildFormRow({required String label, required Widget child, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(width: 16),
            Expanded(child: Align(alignment: Alignment.centerRight, child: child)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if we are in Stock Mode
    if (assetCategoryCode == 'stock' || widget.initialStock != null) {
       // Logic to ensure selectedStockInfo is set
       if (selectedStockInfo == null && widget.initialStock != null) {
          selectedStockInfo = widget.initialStock; 
          // might trigger build again if we set state, but we are in build. 
          // Ideally rely on initState logic, but if assetCategoryCode is stock, we serve this UI.
       }
       return _buildStockTradeUI();
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent, // 保证空白处也能响应
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Material(
        color: Colors.black, // Dark background
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            // 允许内容溢出时可滚动
            child: Padding(
              padding: const EdgeInsets.only(
                top: 0,
                left: 0,
                right: 0,
                bottom: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 靠左对齐
                children: [
                  // 顶部关闭与标题
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white, // White icon
                          ),
                          onPressed:
                              widget.onClose ?? () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '取引追加',
                          style: TextStyle(
                            color: Colors.white, // White text
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 主内容卡片
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GlassTab(
                      tabs: const ['資産', '負債'],
                      tabBarContentList: [_buildAssetForm(), _buildDebtForm()],
                    ),
                  ),
                  // 底部按钮
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                widget.onClose ?? () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              side: const BorderSide(color: Colors.transparent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              backgroundColor: const Color(
                                0xFF1C1C1E,
                              ), // Dark button
                            ),
                            child: const Text(
                              'キャンセル',
                              style: TextStyle(
                                color: Colors.white, // White text
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _handleSave,
                            icon: const Icon(Icons.save_alt_rounded, size: 20),
                            label: Text(
                              widget.mode == 'edit' ? '保存' : '追加',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              backgroundColor: const Color(0xFF4F8CFF),
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // 底部留白
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 共通方法：初始化数字输入框的格式化监听
  void addFocusFormatListener({
    required FocusNode focusNode,
    required TextEditingController controller,
    required NumberFormat numberFormatter,
    int? maxDecimal, // 可选：小数位数
    void Function()? afterFormat, // 可选：格式化后额外处理
  }) {
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        final value = controller.text;
        if (value.isEmpty) return;
        final num? n = num.tryParse(value.replaceAll(',', ''));
        if (n == null) return;

        String formatted;
        if (maxDecimal != null) {
          // 只用 toStringAsFixed，不做正则处理
          formatted = n.toStringAsFixed(maxDecimal);
          // 如果是整数，去掉多余的小数点
          if (formatted.contains('.')) {
            formatted = formatted.replaceFirst(RegExp(r'\.?0+$'), '');
          }
        } else {
          formatted = numberFormatter.format(n);
        }

        controller.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
        if (afterFormat != null) afterFormat();
      }
    });
  }

  // 通过输入股票代码获取股票候选项
  Future<void> _fetchSuggestions(String value, String exchange) async {
    setState(() {
      _stockLoading = true;
      _stockSuggestions = [];
    });
    _showOverlay();

    final dataSync = Provider.of<DataSyncService>(context, listen: false);
    final lastQueried = value;
    List<Stock> result = await dataSync.fetchStockSuggestions(value, exchange);

    // 页面可能已被销毁，检查 mounted
    if (!mounted) return;

    // 只处理最后一次输入的结果
    if (_lastQueriedValue != lastQueried) return;

    setState(() {
      _stockLoading = false;
      _stockSuggestions = result;
    });
    _showOverlay();
  }

  // 关闭股票候选项浮层
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // 显示股票候选项浮层
  void _showOverlay() {
    _removeOverlay();
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy + box.size.height,
        width: box.size.width,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(16),
          child: _stockLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              : _stockSuggestions.isEmpty
              ? const ListTile(title: Text('該当する銘柄が見つかりません'))
              : ListView(
                  shrinkWrap: true,
                  children: _stockSuggestions.map((stock) {
                    return ListTile(
                      title: Text(stock.ticker!),
                      subtitle: Text(stock.name),
                      onTap: () {
                        _stockCodeController.text = stock.ticker!;
                        _onStockSelected(stock);
                        _selectedFromDropdown = true;
                        _removeOverlay();
                        FocusScope.of(context).unfocus();
                      },
                    );
                  }).toList(),
                ),
        ),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  // 选择股票候选项的处理
  void _onStockSelected(Stock? stock) {
    setState(() {
      if (stock != null && stock.ticker!.isNotEmpty && stock.name.isNotEmpty) {
        selectedStockCode = stock.ticker!;
        selectedStockName = stock.name;
        selectedStockInfo = stock;
      } else {
        selectedStockCode = '';
        selectedStockName = '';
        selectedStockInfo = null;
      }
    });
  }

  // 输入股票代码变化的处理
  void _onStockCodeChanged(String value) {
    _lastQueriedValue = value;
    if (value.isEmpty) {
      setState(() => _stockSuggestions = []);
      _removeOverlay();
      _onStockSelected(null);
      return;
    }
    _fetchSuggestions(value, assetSubCategoryCode == 'jp_stock' ? 'JP' : 'US');
  }

  // 股票代码输入框失去焦点的处理
  void _onStockCodeFocusChange(bool hasFocus) {
    if (!hasFocus) {
      _debounceTimer?.cancel();
      _removeOverlay();

      // 如果是从候选项中选中的，就不清空输入
      if (_selectedFromDropdown) {
        _selectedFromDropdown = false;
        return;
      }

      final inputCode = _stockCodeController.text.trim();

      // 如果候选项中有完全匹配的，选中它
      for (var stock in _stockSuggestions) {
        if (stock.ticker! == inputCode) {
          _stockCodeController.text = stock.ticker!;
          _onStockSelected(stock);
          return;
        }
      }

      // 否则清空输入
      _stockCodeController.clear();
      _onStockSelected(null);
    }
  }

  // 显示股票候选项浮层
  void _showFundOverlay() {
    _removeFundOverlay();
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);
    _fundOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy + box.size.height,
        width: box.size.width,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(16),
          child: _fundLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              : _fundSuggestions.isEmpty
              ? const ListTile(title: Text('該当するファンドが見つかりません'))
              : ListView(
                  shrinkWrap: true,
                  children: _fundSuggestions.map((fund) {
                    return ListTile(
                      title: Text(fund.name),
                      subtitle: Text(fund.code),
                      onTap: () {
                        fundNameController.text = fund.name;
                        _onFundSelected(fund);
                        _fundSelectedFromDropdown = true;
                        _removeFundOverlay();
                        FocusScope.of(context).unfocus();
                      },
                    );
                  }).toList(),
                ),
        ),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_fundOverlayEntry!);
  }

  // 获取持仓数据
  Future<void> _loadSellHoldings({bool notNeedRefresh = false}) async {
    // capture globals/providers synchronously
    final assetType = assetCategoryCode;
    final exchange = assetSubCategoryCode == 'jp_stock' ? 'JP' : 'US';
    final dateStr = tradeDate;

    final holdings = await getMyHoldingStocks(assetType, exchange, dateStr);

    if (!mounted) return; // ensure widget still mounted

    final sellMappingsForEdit = <TradeSellMapping>[];
    if (widget.mode == 'edit') {
      final sellMappings =
          await (widget.db.tradeSellMappings.select()
                ..where((tbl) => tbl.sellId.equals(tradeId)))
              .get();
      sellMappingsForEdit.addAll(sellMappings);
    }

    setState(() {
      sellHoldings = holdings;
      //print('Loaded sell holdings: $sellHoldings');
      // 切换资产类型时清空已选
      if (notNeedRefresh) {
        final holding = sellHoldings.firstWhere(
          (h) => h['id'].toString() == selectedSellStockId.toString(),
          orElse: () => <String, dynamic>{},
        );
        final newSellBatches = (holding['batches'] is List)
            ? holding['batches']
            : [];
        if (newSellBatches.length == sellBatches.length) {
          return; // 如果持仓没有变化就不刷新
        }
        sellBatches = newSellBatches;
        // 初始化 controllers 和 focusNodes
        sellBatchControllers.clear();
        sellBatchFocusNodes.clear();
        for (var batch in sellBatches) {
          final key = batch['id'].toString();
          sellBatchControllers[key] = TextEditingController(
            text: widget.mode == 'edit'
                ? sellMappingsForEdit
                          .where((m) => m.buyId.toString() == key)
                          .firstOrNull
                          ?.quantity
                          .toString() ??
                      '0'
                : batch['sell']?.toString() ?? '0',
          );
          sellBatchFocusNodes[key] = FocusNode();
          sellBatchControllers[key]!.addListener(_updateSellTotalQty);
          addFocusFormatListener(
            focusNode: sellBatchFocusNodes[key]!,
            controller: sellBatchControllers[key]!,
            numberFormatter: _numberFormatter,
            maxDecimal: 4,
            afterFormat: _updateSellTotalQty,
          );
        }
        if (widget.mode == 'add') {
          sellTotalQty = 0;
        }
      } else if (!notNeedRefresh) {
        // reset selection
        sellBatches = [];
        sellBatchControllers.clear();
        sellTotalQty = 0;
        selectedSellStockId = null;
        selectedSellStockName = '';
        selectedSellStockExchange = '';
        _sellUnitPriceController.text = '';
        _sellAmountController.text = '¥0';
      }
    });
  }

  // 切换资产类型/子类型时，重新加载持仓
  void _onAssetCategoryChanged(String? v) {
    final subCategories = assetCategoriesWithSub[v] ?? [];
    setState(() {
      assetCategoryCode = v ?? '';
      assetSubCategoryCode = subCategories.length == 1
          ? subCategories[0]['code'] ?? ''
          : '';
      selectedStockCode = '';
      selectedStockName = '';
      selectedStockInfo = null;
    });
    if (tradeAction == ActionType.sell && assetCategoryCode == 'stock') {
      _loadSellHoldings();
    }
  }

  // 切换资产子类型时，重新加载持仓
  void _onAssetSubCategoryChanged(String? v) {
    setState(() {
      assetSubCategoryCode = v ?? '';
      selectedStockCode = '';
      selectedStockName = '';
      selectedStockInfo = null;
    });
    if (tradeAction == ActionType.sell &&
        assetCategoryCode == 'stock' &&
        (assetSubCategoryCode == 'jp_stock' ||
            assetSubCategoryCode == 'us_stock')) {
      _loadSellHoldings();
    }
  }

  // 选择卖出股票
  void _onSellStockChanged(String? v) {
    setState(() {
      selectedSellStockId = int.tryParse(v ?? '');
      final holding = sellHoldings.firstWhere(
        (h) => h['id'].toString() == v,
        orElse: () => <String, dynamic>{},
      );
      selectedSellStockName = holding['name'] ?? '';
      selectedSellStockExchange = holding['exchange'] ?? '';
      sellBatches = (holding['batches'] is List) ? holding['batches'] : [];
      // 初始化controller
      sellBatchControllers.clear();
      sellBatchFocusNodes.clear();
      for (var batch in sellBatches) {
        final key = batch['id'].toString();
        sellBatchControllers[key] = TextEditingController(
          text: batch['sell']?.toString() ?? '0',
        );
        sellBatchFocusNodes[key] = FocusNode();
        sellBatchControllers[key]!.addListener(_updateSellTotalQty);
        addFocusFormatListener(
          focusNode: sellBatchFocusNodes[key]!,
          controller: sellBatchControllers[key]!,
          numberFormatter: _numberFormatter,
          maxDecimal: 4,
          afterFormat: _updateSellTotalQty,
        );
      }
      _updateSellTotalQty();
      _sellUnitPriceController.text = '';
      _sellAmountController.text = '¥0';
      _sellUnitPriceController.addListener(_updateSellAmount);
    });
  }

  // 更新总卖出数量
  void _updateSellTotalQty() {
    num total = 0;
    for (int i = 0; i < sellBatches.length; i++) {
      final key = sellBatches[i]['id'].toString();
      final qty = num.tryParse(sellBatchControllers[key]?.text ?? '0') ?? 0;
      sellBatches[i]['sell'] = qty;
      total += qty;
    }
    setState(() {
      sellTotalQty = total;
    });
    _updateSellAmount();
  }

  // 更新卖出金额
  void _updateSellAmount() {
    final unitPrice =
        num.tryParse(_sellUnitPriceController.text.replaceAll(',', '')) ?? 0;
    setState(() {
      sellUnitPrice = unitPrice;
    });
    final amount = sellTotalQty * unitPrice;
    _sellAmountController.text = '¥${amount.toStringAsFixed(0)}';
  }

  // 資産tab内容
  Widget _buildAssetForm() {
    if (assetCategoryCode.isEmpty) {
      return _buildCategoryGrid(isAsset: true);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormHeader(
          title: assetCategories
              .firstWhere((e) => e.code == assetCategoryCode)
              .name,
          onBack: () {
            setState(() {
              assetCategoryCode = '';
              assetSubCategoryCode = '';
            });
          },
        ),
        const SizedBox(height: 16),
        // サブカテゴリ
        if (assetCategoriesWithSub[assetCategoryCode]?.isNotEmpty ?? false)
          _buildSubCategorySelector(isAsset: true),

        // 动态表单内容
        if (assetSubCategoryCode.isNotEmpty ||
            (assetCategoriesWithSub[assetCategoryCode]?.isEmpty ?? true))
          _buildAssetDynamicFields(),
      ],
    );
  }

  // 負債tab内容
  Widget _buildDebtForm() {
    if (debtCategoryCode.isEmpty) {
      return _buildCategoryGrid(isAsset: false);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormHeader(
          title: debtCategories
              .firstWhere((e) => e.code == debtCategoryCode)
              .name,
          onBack: () {
            setState(() {
              debtCategoryCode = '';
              debtSubCategoryCode = '';
            });
          },
        ),
        const SizedBox(height: 16),
        // サブカテゴリ
        if (debtCategoriesWithSub[debtCategoryCode]?.isNotEmpty ?? false)
          _buildSubCategorySelector(isAsset: false),

        // 动态表单内容
        if (debtSubCategoryCode.isNotEmpty ||
            (debtCategoriesWithSub[debtCategoryCode]?.isEmpty ?? true))
          _buildDebtDynamicFields(),
      ],
    );
  }

  Widget _buildCategoryGrid({required bool isAsset}) {
    final categories = isAsset ? assetCategories : debtCategories;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Material(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {
              setState(() {
                if (isAsset) {
                  _onAssetCategoryChanged(cat.code);
                } else {
                  debtCategoryCode = cat.code;
                  debtSubCategoryCode = '';
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(cat.code),
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  cat.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormHeader({
    required String title,
    required VoidCallback onBack,
  }) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              color: Colors.white70,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSubCategorySelector({required bool isAsset}) {
    final categoryCode = isAsset ? assetCategoryCode : debtCategoryCode;
    final subCategoryCode = isAsset
        ? assetSubCategoryCode
        : debtSubCategoryCode;
    final subCategories = isAsset
        ? assetCategoriesWithSub[categoryCode] ?? []
        : debtCategoriesWithSub[categoryCode] ?? [];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value:
              subCategoryCode.isNotEmpty &&
                  subCategories.any((e) => e['code'] == subCategoryCode)
              ? subCategoryCode
              : null,
          hint: const Text('サブカテゴリを選択', style: TextStyle(color: Colors.grey)),
          dropdownColor: const Color(0xFF2C2C2E),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          items: subCategories.map<DropdownMenuItem<String>>((e) {
            return DropdownMenuItem<String>(
              value: e['code'],
              child: Text(e['name']),
            );
          }).toList(),
          onChanged: (v) {
            if (isAsset) {
              _onAssetSubCategoryChanged(v);
            } else {
              setState(() {
                debtSubCategoryCode = v ?? '';
              });
            }
          },
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String code) {
    switch (code) {
      case 'crypto':
        return Icons.currency_bitcoin;
      case 'stock':
        return Icons.show_chart;
      case 'fund':
        return Icons.pie_chart;
      case 'cash':
        return Icons.attach_money;
      case 'bond':
        return Icons.bar_chart; // Index/Bond
      case 'other':
        return Icons.account_balance_wallet;
      default:
        return Icons.category;
    }
  }

  // 动态生成資産tab下的表单内容
  Widget _buildAssetDynamicFields() {
    // 株式（国内/米国），投資信託 的买入/卖出
    if (assetCategoryCode == 'stock' &&
            (assetSubCategoryCode == 'jp_stock' ||
                assetSubCategoryCode == 'us_stock') ||
        assetCategoryCode == 'fund' && assetSubCategoryCode == 'fund') {
      final children = {
        ActionType.buy: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 8,
          ), // Revert to standard padding
          child: Text(
            '買い',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: tradeAction == ActionType.buy
                  ? const Color(0xFFFF3B30) // Red accent
                  : Colors.grey,
            ),
          ),
        ),
        ActionType.sell: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            '売り',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: tradeAction == ActionType.sell
                  ? const Color(
                      0xFF4F8CFF,
                    ) // Blue? Or Red for Sell? sticking to standard or reversed?
                  // User said "Red accent" for the "Stock" form. Usually that means the primary action.
                  // Im going to assume red for selected, or standard financial colors (Red Sell / Blue Buy).
                  // But the user specially mentioned "Red accent color" in the context of the form.
                  // Let's just use Red for Buy as per request, or stick to financial colors but dark mode.
                  // I'll stick to financial colors (Buy: Blue/Green, Sell: Red) on dark background for safety,
                  // unless "Red accent" meant the whole UI theme.
                  // Wait, Screenshot 2 description: "tabs (Red accent)".
                  // I will make the ACTIVE tab Red.
                  : Colors.grey,
            ),
          ),
        ),
      };

      return StatefulBuilder(
        builder: (context, setInnerState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<ActionType>(
                groupValue: tradeAction,
                children: children,
                onValueChanged: (v) {
                  setState(() => tradeAction = v!);
                  if (tradeAction == ActionType.sell &&
                      assetCategoryCode == 'stock') {
                    _loadSellHoldings();
                  }
                },
                disabledChildren: widget.mode == 'edit'
                    ? {ActionType.buy, ActionType.sell}
                    : {},
                backgroundColor: const Color(0xFF2C2C2E),
                thumbColor: const Color(0xFF3A3A3C),
              ),
            ),
            const SizedBox(height: 24),
            if (tradeAction == ActionType.buy && assetCategoryCode == 'stock')
              _buildBuyFieldsForStock(),
            if (tradeAction == ActionType.sell && assetCategoryCode == 'stock')
              _buildSellFieldsForStock(),
            if (tradeAction == ActionType.buy && assetCategoryCode == 'fund')
              _buildBuyFieldsForFund(),
            //if (tradeAction == ActionType.sell && assetCategoryCode == 'fund')
            //  _buildSellFieldsForFund(),
          ],
        ),
      );
    }
    // 其它类型可按需补充
    return const SizedBox.shrink();
  }

  // 生成买入表单内容
  Widget _buildBuyFieldsForStock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '銘柄情報',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        // 銘柄コード（自动补全）
        CustomInputFormFieldBySuggestion(
          labelText: '銘柄コード',
          controller: _stockCodeController,
          focusNode: _stockCodeFocusNode,
          suggestions: _stockSuggestions.map((e) {
            return ListTile(
              title: Text(
                e.ticker!,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                e.name,
                style: const TextStyle(color: Colors.grey),
              ),
              onTap: () {
                _stockCodeController.text = e.ticker!;
                _onStockSelected(e);
                _selectedFromDropdown = true;
                _removeOverlay();
                FocusScope.of(context).unfocus();
              },
            );
          }).toList(),
          loading: _stockLoading,
          notFoundText: '該当する銘柄が見つかりません',
          onChanged: _onStockCodeChanged,
          onFocusChange: _onStockCodeFocusChange,
          disabled: widget.mode == 'edit',
        ),
        const SizedBox(height: 12),
        // 銘柄名
        TextFormField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: '銘柄名',
            labelStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF2C2C2E), // Dark
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          controller: TextEditingController(text: selectedStockName),
          readOnly: true,
          enabled: widget.mode != 'edit',
        ),
        const SizedBox(height: 24),
        const Text(
          '取引詳細',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        // 取引日
        CustomDateDropdownField(
          labelText: '取引日',
          value: tradeDate != null
              ? DateFormat('yyyy-MM-dd').parse(tradeDate!)
              : null,
          onChanged: (date) {
            setState(() {
              tradeDate = date != null
                  ? DateFormat('yyyy-MM-dd').format(date)
                  : null;
            });
          },
        ),
        const SizedBox(height: 12),
        // 口座区分
        ModernHudDropdown<String>(
          hintText: '口座区分を選択',
          selectedValue:
              tradeTypeCode.isNotEmpty &&
                  tradeTypes.any((e) => e['code']! == tradeTypeCode)
              ? tradeTypeCode
              : null,
          items: tradeTypes
              .map(
                (e) => DropdownMenuItem(
                  value: e['code'] as String,
                  child: Text(e['name']),
                ),
              )
              .toList(),
          onChanged: (v) {
            setState(() {
              tradeTypeCode = v ?? '';
            });
          },
        ),
        const SizedBox(height: 12),
        // 数量・単価
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '数量',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  CustomTextFormField(
                    controller: _quantityController,
                    focusNode: _quantityFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,4}'),
                      ),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        final text = newValue.text;
                        // 不能以小数点开头
                        if (text.startsWith('.')) return oldValue;
                        // 只允许一个小数点
                        if ('.'.allMatches(text).length > 1) {
                          return oldValue;
                        }
                        return newValue;
                      }),
                    ],
                    hintText: '例: 100',
                    onChanged: (value) {
                      final quantity = num.tryParse(value.replaceAll(',', ''));
                      setState(() {
                        quantityValue = quantity;
                      });
                      _updateAmount();
                    },
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
                    '単価',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  CustomTextFormField(
                    controller: _unitPriceController,
                    focusNode: _unitPriceFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,4}'),
                      ),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        final text = newValue.text;
                        // 不能以小数点开头
                        if (text.startsWith('.')) return oldValue;
                        // 只允许一个小数点
                        if ('.'.allMatches(text).length > 1) {
                          return oldValue;
                        }
                        return newValue;
                      }),
                    ],
                    hintText: '例: 2500',
                    onChanged: (value) {
                      final unitPrice = num.tryParse(value.replaceAll(',', ''));
                      setState(() {
                        unitPriceValue = unitPrice;
                      });
                      _updateAmount();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 金額（自動計算）
        const Text(
          '金額（自動計算）',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _amountController,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF2C2C2E), // Dark
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          readOnly: true,
        ),
        const SizedBox(height: 12),
        // 手数料・手数料通貨
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '手数料（任意）',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  CustomTextFormField(
                    controller: _commissionController,
                    focusNode: _commissionFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,4}'),
                      ),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        final text = newValue.text;
                        // 不能以小数点开头
                        if (text.startsWith('.')) return oldValue;
                        // 只允许一个小数点
                        if ('.'.allMatches(text).length > 1) {
                          return oldValue;
                        }
                        return newValue;
                      }),
                    ],
                    hintText: '例: 500',
                    onChanged: (value) {
                      final commission = num.tryParse(
                        value.replaceAll(',', ''),
                      );
                      setState(() {
                        commissionValue = commission;
                      });
                    },
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
                    '手数料通貨',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ModernHudDropdown<String>(
                    hintText: '通貨を選択',
                    selectedValue:
                        commissionCurrency.isNotEmpty &&
                            commissionCurrencies.any(
                              (e) => e == commissionCurrency,
                            )
                        ? commissionCurrency
                        : null,
                    items: commissionCurrencies
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        commissionCurrency = v ?? '';
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // メモ
        const Text(
          'メモ（任意）',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _memoController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '取引に関するメモを入力',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF2C2C2E), // Dark
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          maxLines: 2,
          onChanged: (value) {
            setState(() {
              memoValue = value;
            });
          },
        ),
      ],
    );
  }

  // 生成卖出表单内容
  Widget _buildSellFieldsForStock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '売却する銘柄',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8),
        ModernHudDropdown<String>(
          hintText: '売却する銘柄を選択してください',
          selectedValue:
              (selectedSellStockId != null &&
                  sellHoldings.any(
                    (h) => h['id'].toString() == selectedSellStockId.toString(),
                  ))
              ? selectedSellStockId.toString()
              : null,
          items: sellHoldings
              .map(
                (h) => DropdownMenuItem(
                  value: h['id'].toString(),
                  child: Text('${h['code']} - ${h['name']}'),
                ),
              )
              .toList(),
          onChanged: (v) => _onSellStockChanged(v),
          disabled: widget.mode == 'edit',
        ),
        if (selectedSellStockId != null && sellBatches.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '選択銘柄: $selectedSellStockName',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          const Text(
            '取引詳細',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          CustomDateDropdownField(
            labelText: '取引日',
            value: tradeDate != null
                ? DateFormat('yyyy-MM-dd').parse(tradeDate!)
                : null,
            onChanged: (date) {
              setState(() {
                tradeDate = date != null
                    ? DateFormat('yyyy-MM-dd').format(date)
                    : null;
              });
              _loadSellHoldings(notNeedRefresh: true);
            },
          ),
          const SizedBox(height: 12),
          const Text(
            '売却数量を選択',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          // 批次输入
          Column(
            children: List.generate(sellBatches.length, (i) {
              final batch = sellBatches[i];
              final key = batch['id'].toString();
              // 防御性处理：controller或focusNode未初始化时不渲染输入框
              if (!sellBatchControllers.containsKey(key) ||
                  !sellBatchFocusNodes.containsKey(key)) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            batch['date'] is DateTime
                                ? DateFormat('yyyy-MM-dd').format(batch['date'])
                                : batch['date'].toString(),
                            style: const TextStyle(
                              fontSize: AppTexts.fontSizeMedium,
                              fontWeight: FontWeight.w500,
                              color: Colors.white, // Text color
                            ),
                          ),
                          Text(
                            '${batch['quantity']}株 × ¥${batch['price']}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: CustomTextFormField(
                        controller: sellBatchControllers[key]!,
                        focusNode: sellBatchFocusNodes[key]!,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,4}'),
                          ),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final text = newValue.text;
                            // 不能以小数点开头
                            if (text.startsWith('.')) return oldValue;
                            // 只允许一个小数点
                            if ('.'.allMatches(text).length > 1) {
                              return oldValue;
                            }
                            // 限制最大值和负数
                            double? value = double.tryParse(text);
                            double maxQty = (batch['quantity'] is num)
                                ? (batch['quantity'] as num).toDouble()
                                : 0.0;
                            if (value != null &&
                                (value < 0 || value > maxQty)) {
                              return oldValue;
                            }
                            return newValue;
                          }),
                        ],
                        hintText: '例: 10',
                        onChanged: (value) {},
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          Text(
            '総売却数量: $sellTotalQty 株',
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          // 単価・売却金額
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '単価',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    CustomTextFormField(
                      controller: _sellUnitPriceController,
                      focusNode: _sellUnitPriceFocusNode,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,4}'),
                        ),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final text = newValue.text;
                          // 不能以小数点开头
                          if (text.startsWith('.')) return oldValue;
                          // 只允许一个小数点
                          if ('.'.allMatches(text).length > 1) {
                            return oldValue;
                          }
                          return newValue;
                        }),
                      ],
                      hintText: '例: 2500',
                      onChanged: (value) {},
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
                      '売却金額（自動計算）',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _sellAmountController,
                      readOnly: true,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF2C2C2E), // Dark
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 手数料・手数料通貨
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '手数料（任意）',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    CustomTextFormField(
                      controller: _sellCommissionController,
                      focusNode: _sellCommissionFocusNode,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,4}'),
                        ),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final text = newValue.text;
                          // 不能以小数点开头
                          if (text.startsWith('.')) return oldValue;
                          // 只允许一个小数点
                          if ('.'.allMatches(text).length > 1) {
                            return oldValue;
                          }
                          return newValue;
                        }),
                      ],
                      hintText: '例: 500',
                      onChanged: (value) {
                        final commission = num.tryParse(
                          value.replaceAll(',', ''),
                        );
                        setState(() {
                          sellCommissionValue = commission;
                        });
                      },
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
                      '手数料通貨',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),

                    ModernHudDropdown<String>(
                      hintText: '通貨を選択',
                      selectedValue:
                          sellCommissionCurrency.isNotEmpty &&
                              commissionCurrencies.any(
                                (e) => e == sellCommissionCurrency,
                              )
                          ? sellCommissionCurrency
                          : null,
                      items: commissionCurrencies
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          sellCommissionCurrency = v ?? '';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // メモ
          const Text(
            'メモ（任意）',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _sellMemoController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '取引に関するメモを入力',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF2C2C2E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            maxLines: 2,
            onChanged: (value) {
              setState(() {
                sellMemoValue = value;
              });
            },
          ),
        ],
      ],
    );
  }

  // 生成买入表单内容
  Widget _buildBuyFieldsForFund() {
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
            Expanded(
              child: _buildPurchaseTypeButtonForFund('saving-plan', '積立購入'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPurchaseTypeButtonForFund('one-time', '個別購入'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
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
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //const Text(
            //  'ファンド名',
            //  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            //),
            const SizedBox(height: 8),

            // ファンド名（自动补全）
            CustomInputFormFieldBySuggestion(
              labelText: selectedFund != null || _fundCodeFocusNode.hasFocus
                  ? '協会コード／ファンド名'
                  : '協会コードまたはファンド名を入力ください',
              controller: fundNameController,
              focusNode: _fundCodeFocusNode,
              suggestions: _fundSuggestions.map((e) {
                return ListTile(
                  title: Text(e.name),
                  subtitle: Text(e.code),
                  onTap: () {
                    fundNameController.text = e.name;
                    _onFundSelected(e);
                    _fundSelectedFromDropdown = true;
                    _removeFundOverlay();
                    FocusScope.of(context).unfocus();
                  },
                );
              }).toList(),
              loading: _fundLoading,
              notFoundText: '該当するファンドが見つかりません',
              onChanged: _onFundCodeChanged,
              onFocusChange: _onFundCodeFocusChange,
              disabled: widget.mode == 'edit',
            ),

            // 显示选中的基金信息
            if (selectedFund != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.appUpGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.appUpGreen.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedFund!.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${selectedFund!.code} • ${selectedFund!.name}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),

        // 只有选择了基金后才显示后续项目
        if (selectedFund != null) ...[
          // 积立购入的设定
          if (selectedPurchaseType == 'saving-plan') ...[
            _buildRecurringSettings(),
            const SizedBox(height: 20),
          ],

          // 个别购入的设定
          if (selectedPurchaseType == 'one-time') ...[
            //_buildAccountTypeSelector(),
            const SizedBox(height: 20),
            //_buildPurchaseDetails(),
            //const SizedBox(height: 20),
          ],

          // 备注
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'メモ（任意）',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: fundMemoController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: selectedPurchaseType == 'savting-plan'
                        ? '積立に関するメモを入力'
                        : '購入に関するメモを入力',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF2C2C2E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  maxLines: 2,
                  onChanged: (value) {
                    setState(() {
                      fundMemoValue = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // 积立设定
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
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: fundSelectedAccountType,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      //color: widget.isEditMode ? Colors.grey.shade500 : null,
                    ),
                    items: tradeTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type['code'],
                        child: Text(
                          type['name'],
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() => fundSelectedAccountType = newValue);
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
                          value: fundSelectedFrequencyType,
                          isExpanded: true,
                          isDense: true,
                          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                          items: frequencyTypes.map((Map<String, String> freq) {
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
                                fundSelectedFrequencyType = newValue;
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
                      child: CustomTextFormField(
                        controller: fundRecurringAmountController,
                        focusNode: fundRecurringAmountFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,4}'),
                          ),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final text = newValue.text;
                            // 不能以小数点开头
                            if (text.startsWith('.')) return oldValue;
                            // 只允许一个小数点
                            if ('.'.allMatches(text).length > 1) {
                              return oldValue;
                            }
                            return newValue;
                          }),
                        ],
                        hintText: '例: 100',
                        onChanged: (value) {
                          final amount = num.tryParse(
                            value.replaceAll(',', ''),
                          );
                          setState(() {
                            fundRecurringAmount = amount!;
                          });
                        },
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
                                AppUtils().formatDate(fundRecurringStartDate),
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
                                fundHasEndDate
                                    ? AppUtils().formatDate(
                                        fundRecurringEndDate,
                                      )
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

  // 选择基金候选项的处理
  void _onFundSelected(Fund? fund) {
    setState(() {
      if (fund != null) {
        //selectedFundCode = fund['code']!.toString();
        //selectedFundName = fund['name']!.toString();
        selectedFund = fund;
      } else {
        //selectedFundCode = '';
        //selectedFundName = '';
        selectedFund = null;
      }
    });
  }

  // 输入基金代码变化的处理
  void _onFundCodeChanged(String value) {
    _lastQueriedFundValue = value;
    if (value.isEmpty) {
      setState(() => _fundSuggestions = []);
      _removeFundOverlay();
      _onFundSelected(null);
      return;
    }
    _fetchSuggestionsForFund(value);
  }

  // 基金输入框失去焦点的处理
  void _onFundCodeFocusChange(bool hasFocus) {
    if (!hasFocus) {
      _fundDebounceTimer?.cancel();
      _removeOverlay();

      // 如果是从候选项中选中的，就不清空输入
      if (_fundSelectedFromDropdown) {
        _fundSelectedFromDropdown = false;
        return;
      }

      final inputName = fundNameController.text.trim();

      // 如果候选项中有完全匹配的，选中它
      for (var fund in _fundSuggestions) {
        if (fund.name == inputName) {
          fundNameController.text = fund.name;
          _onFundSelected(fund);
          return;
        }
      }

      // 否则清空输入
      fundNameController.clear();
      _onFundSelected(null);
    }
  }

  // 通过输入基金名称获取股票候选项
  Future<void> _fetchSuggestionsForFund(String value) async {
    setState(() {
      _fundLoading = true;
      _fundSuggestions = [];
    });
    _showFundOverlay();

    final dataSync = Provider.of<DataSyncService>(context, listen: false);
    final lastQueried = value;
    List<Fund> result = await dataSync.fetchFundSuggestions(value);

    // 页面可能已被销毁，检查 mounted
    if (!mounted) return;

    // 只处理最后一次输入的结果
    if (_lastQueriedFundValue != lastQueried) return;

    setState(() {
      _fundLoading = false;
      _fundSuggestions = result;
    });
    _showFundOverlay();
  }

  // 关闭股票候选项浮层
  void _removeFundOverlay() {
    _fundOverlayEntry?.remove();
    _fundOverlayEntry = null;
  }

  Widget _buildPurchaseTypeButtonForFund(String type, String label) {
    final isSelected = selectedPurchaseType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPurchaseType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
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

  // 初始化频度配置
  void _initializeFrequencyConfig(String frequencyType) {
    switch (frequencyType) {
      case 'daily':
        fundFrequencyConfig = {'type': 'daily'};
        break;
      case 'weekly':
        fundFrequencyConfig = {
          'type': 'weekly',
          'days': [1],
        }; // 默认周一
        break;
      case 'monthly':
        fundFrequencyConfig = {
          'type': 'monthly',
          'days': [1],
        }; // 默认每月1号
        break;
      case 'bimonthly':
        fundFrequencyConfig = {
          'type': 'bimonthly',
          'months': 'odd',
          'days': [1],
        }; // 默认奇数月1号
        break;
    }
  }

  // 频度详细设定UI
  Widget _buildFrequencyDetailSettings() {
    switch (fundSelectedFrequencyType) {
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
    final selectedDays = List<int>.from(fundFrequencyConfig['days'] ?? [1]);

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
          children: fundWeekDays.map((day) {
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
                  fundFrequencyConfig['days'] = selectedDays;
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
    final selectedDays = List<int>.from(fundFrequencyConfig['days'] ?? [1]);

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
                        fundFrequencyConfig['days'] = [];
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
                        fundFrequencyConfig['days'] = selectedDays;
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
    final selectedMonths = fundFrequencyConfig['months'] ?? 'odd';
    final selectedDays = List<int>.from(fundFrequencyConfig['days'] ?? [1]);

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
                    fundFrequencyConfig['months'] = 'odd';
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
                    fundFrequencyConfig['months'] = 'even';
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

  // 添加缺失的开始日期选择方法
  Future<void> _selectStartDate(int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fundRecurringStartDate,
      firstDate: DateTime.parse('2020-01-01'), //DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      locale: const Locale('ja', 'JP'),
    );
    if (picked != null) {
      setState(() {
        fundRecurringStartDate = picked;
      });
    }
  }

  // 添加缺失的结束日期选择方法
  Future<void> _selectEndDate(int index) async {
    final startDate = fundRecurringStartDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fundHasEndDate
          ? fundRecurringEndDate
          : startDate.add(const Duration(days: 365)),
      firstDate: startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      locale: const Locale('ja', 'JP'),
    );
    if (picked != null) {
      setState(() {
        fundRecurringEndDate = picked;
        fundHasEndDate = true;
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
                  fundHasEndDate = false;
                  fundRecurringEndDate = DateTime.now();
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
          fundFrequencyConfig['days'] = selectedDays;
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

  // 获取用户持有的股票列表及其批次信息
  Future<List<Map<String, dynamic>>> getMyHoldingStocks(
    String assetType,
    String exchange,
    String? tradeDateStr,
  ) async {
    final db = widget.db;
    final userId = GlobalStore().userId;
    final accountId = GlobalStore().accountId;

    if (userId == null || accountId == null) {
      return [];
    }

    // 解析tradeDateStr为DateTime
    DateTime? tradeDate;
    if (tradeDateStr != null && tradeDateStr.isNotEmpty) {
      try {
        tradeDate = DateTime.parse(tradeDateStr);
      } catch (_) {
        tradeDate = null;
      }
    }

    // 1. 查询所有买入批次
    final buyQuery =
        db.select(db.stocks).join([
            innerJoin(
              db.tradeRecords,
              db.tradeRecords.assetId.equalsExp(db.stocks.id),
            ),
          ])
          ..where(db.stocks.exchange.equals(exchange))
          ..where(db.tradeRecords.userId.equals(userId))
          ..where(db.tradeRecords.accountId.equals(accountId))
          ..where(db.tradeRecords.assetType.equals(assetType))
          ..where(db.tradeRecords.action.equals('buy'))
          ..orderBy([
            OrderingTerm.asc(db.stocks.ticker),
            OrderingTerm.asc(db.tradeRecords.tradeDate),
          ]);

    final buyRows = await buyQuery.get();

    // 2. 查询所有卖出mapping（buy_id -> 已卖出数量）
    final sellMappings = await (db.select(db.tradeSellMappings)).get();

    // 统计每个 buy_id 已卖出数量
    final Map<int, num> buyIdToSoldQty = {};
    for (final mapping in sellMappings) {
      if (widget.mode == 'edit' && mapping.sellId == tradeId) continue;
      buyIdToSoldQty[mapping.buyId] =
          (buyIdToSoldQty[mapping.buyId] ?? 0) + mapping.quantity;
    }

    // 3. 组装结果
    final result = <int, Map<String, dynamic>>{};
    for (final row in buyRows) {
      final stock = row.readTable(db.stocks);
      final trade = row.readTable(db.tradeRecords);

      // 判断是否在交易日之前（包含交易日）
      final buyDate = trade.tradeDate;
      bool isValid = true;
      if (tradeDate != null) {
        final buyDateOnly = DateTime(buyDate.year, buyDate.month, buyDate.day);
        final tradeDateOnly = DateTime(
          tradeDate.year,
          tradeDate.month,
          tradeDate.day,
        );
        if (buyDateOnly.isAfter(tradeDateOnly)) {
          isValid = false;
        }
      }

      if (!isValid) continue; // 交易日之后的批次直接跳过

      // 计算剩余可卖数量
      final buyId = trade.id;
      final buyQty = trade.quantity;
      final soldQty = buyIdToSoldQty[buyId] ?? 0;
      final remainQty = buyQty - soldQty;

      if (remainQty <= 0) continue; // 已全部卖出

      if (!result.containsKey(stock.id)) {
        result[stock.id] = {
          'id': stock.id,
          'code': stock.ticker,
          'name': stock.name,
          'exchange': stock.exchange,
          'batches': <Map<String, dynamic>>[],
        };
      }
      result[stock.id]?['batches'].add({
        'id': buyId,
        'date': trade.tradeDate,
        'quantity': remainQty,
        'price': trade.price,
        'sell': 0, // 初始卖出数量为0
      });
    }

    return result.values.toList();
  }

  // 动态生成負債tab下的表单内容
  Widget _buildDebtDynamicFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('日時', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        // ...日期选择控件...
        SizedBox(height: 16),
        Text('負債額', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        // ...金额输入框...
        SizedBox(height: 16),
        Text('メモ（任意）', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        // ...memo输入框...
      ],
    );
  }

  // 自动计算买入总金额
  void _updateAmount() {
    final quantity = num.tryParse(_quantityController.text);
    final unitPrice = num.tryParse(_unitPriceController.text);
    if (quantity != null && unitPrice != null) {
      final amount = quantity * unitPrice;
      // 整数显示整数，小数显示小数
      final formatted = _numberFormatter.format(amount);
      _amountController.text = formatted;
    } else {
      _amountController.text = '';
    }
  }

  // 保存按钮处理
  Future<void> _handleSave() async {
    // 显示处理中遮罩
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      if (GlobalStore().userId == null || GlobalStore().accountId == null) {
        //AppUtils().showSnackBar(
        //  context,
        //  'ユーザーIDまたはアカウントIDが設定されていません',
        //  isError: true,
        //);
        Navigator.of(context).pop(); // 关闭处理中遮罩
        return;
      }
      // 判断是否可以保存
      bool canSave = false;
      if (tabIndex == 0) {
        // 資産tab
        if (assetCategoryCode == 'stock' &&
            (assetSubCategoryCode == 'jp_stock' ||
                assetSubCategoryCode == 'us_stock')) {
          // 买入
          if (tradeAction == ActionType.buy) {
            canSave =
                assetCategoryCode.isNotEmpty &&
                assetSubCategoryCode.isNotEmpty &&
                selectedStockInfo != null &&
                tradeTypeCode.isNotEmpty &&
                tradeDate != null &&
                quantityValue != null &&
                unitPriceValue != null;
          } else if (tradeAction == ActionType.sell) {
            canSave =
                assetCategoryCode.isNotEmpty &&
                assetSubCategoryCode.isNotEmpty &&
                selectedSellStockId != null &&
                tradeDate != null &&
                sellTotalQty > 0 &&
                sellUnitPrice != null;
          }
        }
        // 投資信託
        else if (assetCategoryCode == 'fund' &&
            assetSubCategoryCode == 'fund') {
          // 積み立て
          if (selectedPurchaseType == 'saving-plan') {
            // 購入
            if (tradeAction == ActionType.buy) {
              canSave =
                  fundSelectedAccountType.isNotEmpty &&
                  selectedFund != null &&
                  fundSelectedFrequencyType.isNotEmpty &&
                  (fundSelectedFrequencyType == 'daily' ||
                      fundFrequencyConfig.containsKey('type') &&
                          fundFrequencyConfig.containsKey('days') &&
                          fundFrequencyConfig['days'] is List &&
                          fundSelectedFrequencyType ==
                              fundFrequencyConfig['type'].toString() &&
                          (fundFrequencyConfig['days'] as List).isNotEmpty) &&
                  fundRecurringAmount > 0 &&
                  (!fundHasEndDate ||
                      fundRecurringStartDate.isBefore(fundRecurringEndDate) ||
                      AppUtils().isSameDate(
                        fundRecurringStartDate,
                        fundRecurringEndDate,
                      ));
            }
          }
        }
      } else {
        // 負債tab
        canSave =
            debtCategoryCode.isNotEmpty &&
            debtSubCategoryCode.isNotEmpty &&
            tradeTypeCode.isNotEmpty &&
            tradeDate != null &&
            quantityValue != null &&
            unitPriceValue != null;
      }
      if (!canSave) {
        Navigator.of(context).pop(); // 关闭处理中遮罩
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('入力エラー'),
            content: const Text('必須項目を入力してください。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
      // 保存逻辑
      bool success = false;
      final dataSync = Provider.of<DataSyncService>(context, listen: false);

      // New UI Check: Auto-distribute sell quantity if needed
      if ((assetCategoryCode == 'stock' || widget.initialStock != null) && 
          tradeAction == ActionType.sell) {
             _autoDistributeSellQuantity();
      }

      // 資産tab保存逻辑
      if (tabIndex == 0) {
        // 株式（国内株式,米国株式）
        if (assetCategoryCode == 'stock' &&
            (assetSubCategoryCode == 'jp_stock' ||
                assetSubCategoryCode == 'us_stock')) {
          // 买入
          if (tradeAction == ActionType.buy) {
            if (widget.mode == 'add') {
              success = await dataSync.createOrUpdateStockTrade(
                'add',
                userId: GlobalStore().userId!,
                assetData: {
                  "account_id": GlobalStore().accountId!,
                  "asset_type": "stock",
                  "asset_id": selectedStockInfo!.id,
                  "asset_code": selectedStockInfo!.ticker,
                  "trade_date": tradeDate,
                  "exchange": selectedStockInfo!.exchange,
                  "action": 'buy',
                  "trade_type": tradeTypeCode,
                  "quantity": quantityValue,
                  "price": unitPriceValue,
                  "fee_amount": commissionValue,
                  "fee_currency": commissionCurrency,
                  "remark": memoValue,
                  "sell_mappings": [],
                },
                stockData: {
                  "id": selectedStockInfo!.id,
                  "ticker": selectedStockInfo!.ticker,
                  "exchange": selectedStockInfo!.exchange,
                  "name": selectedStockInfo!.name,
                  "currency": selectedStockInfo!.currency,
                  "country": selectedStockInfo!.country,
                  "status": selectedStockInfo!.status,
                  "last_price": selectedStockInfo!.lastPrice,
                  "lastPriceAt": selectedStockInfo!.lastPriceAt,
                  "nameUs": selectedStockInfo!.nameUs,
                  "sectorIndustryId": selectedStockInfo!.sectorIndustryId,
                  "logo": selectedStockInfo!.logo,
                },
              );
            } else {
              success = await dataSync.createOrUpdateStockTrade(
                'edit',
                userId: GlobalStore().userId!,
                assetData: {
                  "id": tradeId,
                  "account_id": GlobalStore().accountId!,
                  "trade_date": tradeDate,
                  "action": 'buy',
                  "trade_type": tradeTypeCode,
                  "quantity": quantityValue,
                  "exchange": selectedStockInfo!.exchange,
                  "price": unitPriceValue,
                  "fee_amount": commissionValue,
                  "fee_currency": commissionCurrency,
                  "remark": memoValue,
                  "sell_mappings": [],
                },
                stockData: null,
              );
            }
          }
          // 卖出
          else if (tradeAction == ActionType.sell) {
            if (widget.mode == 'add') {
              success = await dataSync.createOrUpdateStockTrade(
                'add',
                userId: GlobalStore().userId!,
                assetData: {
                  "account_id": GlobalStore().accountId!,
                  "asset_type": "stock",
                  "asset_id": selectedSellStockId,
                  "asset_code": selectedSellStockCode,
                  "trade_date": tradeDate,
                  "exchange": selectedSellStockExchange,
                  "action": 'sell',
                  "trade_type": null,
                  "quantity": sellTotalQty,
                  "price": sellUnitPrice,
                  "fee_amount": sellCommissionValue,
                  "fee_currency": sellCommissionCurrency,
                  "remark": sellMemoValue,
                  "sell_mappings": sellBatches
                      .where(
                        (b) =>
                            (b['sell'] ?? 0) != 0 &&
                            b['sell'] != null &&
                            b['sell'].toString() != '',
                      )
                      .map((b) => {"buy_id": b['id'], "quantity": b['sell']})
                      .toList(),
                },
                stockData: null,
              );
            } else {
              success = await dataSync.createOrUpdateStockTrade(
                'edit',
                userId: GlobalStore().userId!,
                assetData: {
                  "id": tradeId,
                  "account_id": GlobalStore().accountId!,
                  "trade_date": tradeDate,
                  "action": 'sell',
                  "quantity": sellTotalQty,
                  "price": sellUnitPrice,
                  "exchange": selectedSellStockExchange,
                  "fee_amount": sellCommissionValue,
                  "fee_currency": sellCommissionCurrency,
                  "remark": sellMemoValue,
                  "sell_mappings": sellBatches
                      .where(
                        (b) =>
                            (b['sell'] ?? 0) != 0 &&
                            b['sell'] != null &&
                            b['sell'].toString() != '',
                      )
                      .map((b) => {"buy_id": b['id'], "quantity": b['sell']})
                      .toList(),
                },
                stockData: null,
              );
            }
          }
        }
        // 投資信託
        if (assetCategoryCode == 'fund' && assetSubCategoryCode == 'fund') {
          // 積み立て
          if (selectedPurchaseType == 'saving-plan') {
            // 購入
            if (tradeAction == ActionType.buy) {
              if (widget.mode == 'add') {
                success = await dataSync.createOrUpdateFundTrade(
                  'add',
                  userId: GlobalStore().userId!,
                  fundTransactionData: {
                    "account_id": GlobalStore().accountId!,
                    "fund_id": selectedFund!.id,
                    "trade_date": AppUtils().formatDate(fundRecurringStartDate),
                    "action": 'buy',
                    "trade_type": 'recurring',
                    "account_type": fundSelectedAccountType,
                    "amount": fundRecurringAmount.toDouble(),
                    "recurring_frequency_type": fundSelectedFrequencyType,
                    "recurring_frequency_config": jsonEncode(
                      fundFrequencyConfig,
                    ),
                    "recurring_start_date": AppUtils().formatDate(
                      fundRecurringStartDate,
                    ),
                    "recurring_end_date": fundHasEndDate
                        ? AppUtils().formatDate(fundRecurringEndDate)
                        : null,
                    "recurring_status": 'active',
                    "remark": fundMemoValue,
                  },
                  fundData: selectedFund,
                );
              }
            }
          }
        }
      } else {
        // 負債tab保存逻辑
        // ...
      }

      if (!mounted) return; // 页面可能已被销毁，检查 mounted

      Navigator.of(context).pop(); // 关闭处理中遮罩

      if (success) {
        final dataSync = Provider.of<DataSyncService>(context, listen: false);
        // 刷新股票价格
        await dataSync.getStockPricesByYHFinanceAPI();
        // 刷新全局数据
        await AppUtils().calculateAndSavePortfolio(
          widget.db,
          GlobalStore().userId!,
          GlobalStore().accountId!,
        );
        // 刷新总资产和总成本
        await AppUtils().refreshTotalAssetsAndCosts(
          dataSync,
          forcedUpdate: true,
        );

        if (!mounted) return; // 页面可能已被销毁，检查 mounted
        await AppUtils().showSuccessHUD(context, message: '保存しました');
        if (!mounted) return;
        if (widget.mode == 'add') {
          Navigator.pop(context, true);
        } else {
          // 金额格式
          final currency = widget.record.currency;
          final stockPrices = GlobalStore().currentStockPrices;
          final quantity = tradeAction == ActionType.buy
              ? quantityValue!
              : sellTotalQty;
          final price = tradeAction == ActionType.buy
              ? unitPriceValue!
              : sellUnitPrice!;
          final feeAmount = tradeAction == ActionType.buy
              ? commissionValue
              : sellCommissionValue;
          final feeCurrency = tradeAction == ActionType.buy
              ? commissionCurrency
              : sellCommissionCurrency;
          final amount =
              quantity * price -
              (feeAmount ?? 0) *
                  (widget.record.action == ActionType.sell ? 1 : -1) *
                  (stockPrices['${feeCurrency == 'USD' ? '' : feeCurrency}$currency=X'] ??
                      1);
          final amountStr =
              '${widget.record.action == ActionType.dividend ? '+' : ''}${AppUtils().formatMoney(amount.toDouble(), currency)}';
          // 明细
          final formatter = NumberFormat("#,##0.##");
          final detail =
              '${formatter.format(quantity)}株 * ${AppUtils().formatMoney(price.toDouble(), currency)}';

          TradeRecordDisplay rtl = TradeRecordDisplay(
            id: widget.record.id,
            action: widget.record.action,
            tradeDate: tradeDate!,
            tradeType: widget.record.tradeType,
            amount: amountStr,
            detail: detail,
            assetType: widget.record.assetType,
            price: price.toDouble(),
            quantity: quantity.toDouble(),
            currency: widget.record.currency,
            feeAmount: feeAmount!.toDouble(),
            feeCurrency: feeCurrency,
            remark: tradeAction == ActionType.buy ? memoValue! : sellMemoValue!,
            stockInfo: widget.record.stockInfo,
          );
          Navigator.pop(context, rtl);
        }
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('エラー'),
            content: const Text('保存に失敗しました。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // 关闭处理中遮罩
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('エラー'),
          content: Text('保存に失敗しました。\n$e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // 显示保存成功弹窗，1秒后自动关闭
  Future<void> _showSuccessDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: 260,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF4F8CFF),
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '保存しました',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF222222),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // 1秒后自动关闭弹窗
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return; // 页面可能已被销毁，检查 mounted
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

// 这个类必须放在最外层，不能放在任何类的内部！
class _TabBarSliverDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _TabBarSliverDelegate({required this.child});
  @override
  double get minExtent => 64;
  @override
  double get maxExtent => 64;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _TabBarSliverDelegate oldDelegate) => false;
}
