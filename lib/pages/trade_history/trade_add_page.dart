import 'dart:async';
import 'dart:ui'; // 新增
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' hide Column;
import 'package:intl/intl.dart';
import 'package:money_nest_app/components/custom_date_dropdown_field.dart';
import 'package:money_nest_app/components/custom_dropdown_button_form_field.dart';
import 'package:money_nest_app/components/custom_input_form_field_by_suggestion.dart';
import 'package:money_nest_app/components/custom_text_form_field.dart';
import 'package:money_nest_app/components/glass_tab.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/models/categories.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/models/trade_type.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/presentation/resources/app_texts.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:money_nest_app/util/global_store.dart';
import 'package:flutter/services.dart';

class TradeAddPage extends StatefulWidget {
  //final TradeRecord? record; // 支持编辑模式
  final VoidCallback? onClose;
  const TradeAddPage({super.key, this.onClose}); //this.record});

  @override
  State<TradeAddPage> createState() => _TradeAddPageState();
}

class _TradeAddPageState extends State<TradeAddPage> {
  int tabIndex = 0; // 0: 資産, 1: 負債

  // カテゴリ・サブカテゴリ
  late final List<Categories> assetCategories;
  late final List<Categories> debtCategories;
  late final Map<String, List<Map<String, dynamic>>> assetCategoriesWithSub;
  late final Map<String, List<Map<String, dynamic>>> debtCategoriesWithSub;
  String assetCategoryCode = '';
  String assetSubCategoryCode = '';
  String debtCategoryCode = '';
  String debtSubCategoryCode = '';
  // 操作タイプ（買い or 売り）
  String tradeAction = 'buy';

  // 买入
  // 銘柄情報
  final TextEditingController _stockCodeController = TextEditingController();
  final FocusNode _stockCodeFocusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  List<Stock> _stockSuggestions = [];
  bool _stockLoading = false;
  Timer? _debounceTimer;
  String _lastQueriedValue = '';
  bool _selectedFromDropdown = false;
  String selectedStockCode = '';
  String selectedStockName = '';
  Stock? selectedStockInfo;
  // 取引種別
  String tradeTypeCode = '';
  late final List<dynamic> tradeTypes;
  // 取引日
  String? tradeDate;
  // 数量
  num? quantityValue;
  final TextEditingController _quantityController = TextEditingController();
  final FocusNode _quantityFocusNode = FocusNode();
  final _numberFormatter = NumberFormat("#,##0.####");
  // 単価
  num? unitPriceValue;
  final TextEditingController _unitPriceController = TextEditingController();
  final FocusNode _unitPriceFocusNode = FocusNode();
  // 金額（自動计算）
  final TextEditingController _amountController = TextEditingController();
  // 手数料
  num? commissionValue;
  final TextEditingController _commissionController = TextEditingController();
  final FocusNode _commissionFocusNode = FocusNode();
  // 手数料通貨
  String commissionCurrency = '';
  late final List<String> commissionCurrencies =
      Currency.values.map((e) => e.code).toList()
        ..sort((a, b) => a.compareTo(b));
  // メモ
  String? memoValue;

  // 卖出相关 State
  List<Map<String, dynamic>> sellHoldings = [];
  List<dynamic> sellBatches = [];
  num sellTotalQty = 0;
  num sellUnitPrice = 0;
  final TextEditingController sellUnitPriceController = TextEditingController();
  final TextEditingController sellAmountController = TextEditingController(
    text: '¥0',
  );
  final FocusNode sellUnitPriceFocusNode = FocusNode();
  // 銘柄情報（从持仓中选择）
  String selectedSellStockCode = '';
  String selectedSellStockName = '';
  int? selectedSellStockId;
  // 批次选择
  Map<String, TextEditingController> sellBatchControllers = {};
  Map<String, FocusNode> sellBatchFocusNodes = {};
  // 手数料
  num? sellCommissionValue;
  final TextEditingController _sellCommissionController =
      TextEditingController();
  final FocusNode _sellCommissionFocusNode = FocusNode();
  // 手数料通貨
  String sellCommissionCurrency = '';
  // メモ
  String? sellMemoValue;

  // 示例：异步获取候选
  Future<void> _fetchSuggestions(String value, String exchange) async {
    setState(() {
      _stockLoading = true;
      _stockSuggestions = [];
    });
    _showOverlay();

    List<Stock> result = await AppUtils().fetchStockSuggestions(
      value,
      exchange,
    );

    // 只处理最后一次输入的结果
    if (_lastQueriedValue != value) return;

    setState(() {
      _stockLoading = false;
      _stockSuggestions = result;
    });
    _showOverlay();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

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

  void _onFocusChange(bool hasFocus) {
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

  @override
  void initState() {
    super.initState();
    assetCategories =
        Categories.values.where((cat) => cat.type == 'asset').toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    debtCategories =
        Categories.values.where((cat) => cat.type == 'liability').toList()
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
    tradeTypes = TradeType.values
        .map((e) => {'code': e.code, 'name': e.displayName})
        .toList();
    _quantityFocusNode.addListener(() {
      if (!_quantityFocusNode.hasFocus) {
        // 输入框失去焦点时执行格式化
        final value = _quantityController.text;
        if (value.isEmpty) return;
        final num? n = num.tryParse(value.replaceAll(',', ''));
        if (n == null) return;

        final formatted = _numberFormatter.format(n);

        _quantityController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );

        _updateAmount();
      }
    });
    _unitPriceFocusNode.addListener(() {
      if (!_unitPriceFocusNode.hasFocus) {
        // 输入框失去焦点时执行格式化
        final value = _unitPriceController.text;
        if (value.isEmpty) return;
        final num? n = num.tryParse(value.replaceAll(',', ''));
        if (n == null) return;

        final formatted = _numberFormatter.format(n);

        _unitPriceController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );

        _updateAmount();
      }
    });
    _commissionFocusNode.addListener(() {
      if (!_commissionFocusNode.hasFocus) {
        // 输入框失去焦点时执行格式化
        final value = _commissionController.text;
        if (value.isEmpty) return;
        final num? n = num.tryParse(value.replaceAll(',', ''));
        if (n == null) return;

        final formatted = _numberFormatter.format(n);

        _commissionController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    });
    sellUnitPriceFocusNode.addListener(() {
      if (!sellUnitPriceFocusNode.hasFocus) {
        // 输入框失去焦点时执行格式化
        final value = sellUnitPriceController.text;
        if (value.isEmpty) return;
        final num? n = num.tryParse(value.replaceAll(',', ''));
        if (n == null) return;

        final formatted = _numberFormatter.format(n);

        sellUnitPriceController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );

        _updateSellAmount();
      }
    });
    _sellCommissionFocusNode.addListener(() {
      if (!_sellCommissionFocusNode.hasFocus) {
        // 输入框失去焦点时执行格式化
        final value = _sellCommissionController.text;
        if (value.isEmpty) return;
        final num? n = num.tryParse(value.replaceAll(',', ''));
        if (n == null) return;

        final formatted = _numberFormatter.format(n);

        _sellCommissionController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    });
    // 初始化卖出持仓
    _loadSellHoldings();
  }

  // 获取持仓数据
  Future<void> _loadSellHoldings() async {
    sellHoldings = await getMyHoldingStocks(
      assetCategoryCode,
      assetSubCategoryCode == 'jp_stock' ? 'JP' : 'US',
    );
    // 切换资产类型时清空已选
    setState(() {
      selectedSellStockId = null;
      selectedSellStockName = '';
      sellBatches = [];
      sellBatchControllers.clear();
      sellTotalQty = 0;
      sellUnitPriceController.text = '';
      sellAmountController.text = '¥0';
    });
  }

  // 切换资产类型/子类型时，重新加载持仓
  void _onAssetCategoryChanged(String? v) {
    setState(() {
      assetCategoryCode = v ?? '';
      assetSubCategoryCode = '';
      selectedStockCode = '';
      selectedStockName = '';
      selectedStockInfo = null;
    });
    _loadSellHoldings();
  }

  void _onAssetSubCategoryChanged(String? v) {
    setState(() {
      assetSubCategoryCode = v ?? '';
      selectedStockCode = '';
      selectedStockName = '';
      selectedStockInfo = null;
    });
    _loadSellHoldings();
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
        sellBatchFocusNodes[key]!.addListener(() {
          if (!sellBatchFocusNodes[key]!.hasFocus) {
            // 输入框失去焦点时执行格式化
            final value = sellBatchControllers[key]!.text;
            if (value.isEmpty) return;
            final num? n = num.tryParse(value.replaceAll(',', ''));
            if (n == null) return;

            final formatted = _numberFormatter.format(n);

            sellBatchControllers[key]!.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );

            _updateSellTotalQty();
          }
        });
      }
      _updateSellTotalQty();
      sellUnitPriceController.text = '';
      sellAmountController.text = '¥0';
      sellUnitPriceController.addListener(_updateSellAmount);
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
        num.tryParse(sellUnitPriceController.text.replaceAll(',', '')) ?? 0;
    setState(() {
      sellUnitPrice = unitPrice;
    });
    final amount = sellTotalQty * unitPrice;
    sellAmountController.text = '¥${amount.toStringAsFixed(0)}';
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
    _sellCommissionController.dispose();
    _sellCommissionFocusNode.dispose();
    _removeOverlay();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent, // 保证空白处也能响应
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Material(
        color: AppColors.appBackground,
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
                            color: Colors.black87,
                          ),
                          onPressed:
                              widget.onClose ?? () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '取引追加',
                          style: TextStyle(
                            color: Color(0xFF222222),
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
                              backgroundColor: Colors.white,
                            ),
                            child: const Text(
                              'キャンセル',
                              style: TextStyle(
                                color: Colors.black87,
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
                            label: const Text(
                              '保存',
                              style: TextStyle(
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

  // 資産tab内容
  Widget _buildAssetForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // カテゴリ
        const Text(
          'カテゴリ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: AppTexts.fontSizeMedium,
          ),
        ),
        const SizedBox(height: 6),
        CustomDropdownButtonFormField<String>(
          hintText: 'カテゴリを選択',
          selectedValue:
              assetCategoryCode.isNotEmpty &&
                  assetCategories.any((e) => e.code == assetCategoryCode)
              ? assetCategoryCode
              : null,
          items: assetCategories
              .map((e) => DropdownMenuItem(value: e.code, child: Text(e.name)))
              .toList(),
          onChanged: (v) => _onAssetCategoryChanged(v),
        ),
        const SizedBox(height: 6),
        // サブカテゴリ
        if (assetCategoryCode.isNotEmpty)
          CustomDropdownButtonFormField<String>(
            hintText: 'サブカテゴリを選択',
            selectedValue:
                assetSubCategoryCode.isNotEmpty &&
                    assetCategoriesWithSub[assetCategoryCode]?.any(
                          (e) => e['code']! == assetSubCategoryCode,
                        ) ==
                        true
                ? assetSubCategoryCode
                : null,
            onChanged: (v) => _onAssetSubCategoryChanged(v),
            items: (assetCategoriesWithSub[assetCategoryCode] ?? [])
                .map<DropdownMenuItem<String>>(
                  (e) => DropdownMenuItem(
                    value: e['code'],
                    child: Text(e['name']),
                  ),
                )
                .toList(),
          ),
        // 动态表单内容
        if (assetCategoryCode.isNotEmpty && assetSubCategoryCode.isNotEmpty)
          _buildAssetDynamicFields(),
      ],
    );
  }

  // 負債tab内容
  Widget _buildDebtForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // カテゴリ
        const Text(
          'カテゴリ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: AppTexts.fontSizeMedium,
          ),
        ),
        const SizedBox(height: 6),
        CustomDropdownButtonFormField<String>(
          hintText: 'カテゴリを選択',
          selectedValue:
              debtCategoryCode.isNotEmpty &&
                  debtCategories.any((e) => e.code == debtCategoryCode)
              ? debtCategoryCode
              : null,
          items: debtCategories
              .map((e) => DropdownMenuItem(value: e.code, child: Text(e.name)))
              .toList(),
          onChanged: (v) {
            setState(() {
              debtCategoryCode = v ?? '';
              debtSubCategoryCode = '';
            });
          },
        ),
        const SizedBox(height: 6),
        // サブカテゴリ
        if (debtCategoryCode.isNotEmpty)
          CustomDropdownButtonFormField<String>(
            hintText: 'サブカテゴリを選択',
            selectedValue:
                debtSubCategoryCode.isNotEmpty &&
                    debtCategoriesWithSub[debtCategoryCode]?.any(
                          (e) => e['code']! == debtSubCategoryCode,
                        ) ==
                        true
                ? debtSubCategoryCode
                : null,
            items: (debtCategoriesWithSub[debtCategoryCode] ?? [])
                .map<DropdownMenuItem<String>>(
                  (e) => DropdownMenuItem(
                    value: e['code'],
                    child: Text(e['name']),
                  ),
                )
                .toList(),
            onChanged: (v) {
              setState(() {
                debtSubCategoryCode = v ?? '';
              });
            },
          ),
        // 动态表单内容
        if (debtCategoryCode.isNotEmpty && debtSubCategoryCode.isNotEmpty)
          _buildDebtDynamicFields(),
      ],
    );
  }

  // 动态生成資産tab下的表单内容
  Widget _buildAssetDynamicFields() {
    // 这里只举例：株式（国内株式（ETF含む））的买入/卖出
    if (assetCategoryCode == 'stock' &&
        (assetSubCategoryCode == 'jp_stock' ||
            assetSubCategoryCode == 'us_stock')) {
      // 取引種別
      return StatefulBuilder(
        builder: (context, setInnerState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            const SizedBox(height: 6),
            CupertinoSlidingSegmentedControl<String>(
              groupValue: tradeAction,
              children: {
                'buy': Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Text(
                    '買い',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: tradeAction == 'buy'
                          ? Color(0xFF4F8CFF)
                          : Color(0xFF888888),
                    ),
                  ),
                ),
                'sell': Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Text(
                    '売り',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: tradeAction == 'sell'
                          ? Color(0xFF4F8CFF)
                          : Color(0xFF888888),
                    ),
                  ),
                ),
              },
              onValueChanged: (v) => setState(() => tradeAction = v!),
              backgroundColor: Colors.white.withOpacity(0.85),
              thumbColor: Colors.white,
            ),
            const SizedBox(height: 16),
            if (tradeAction == 'buy') _buildBuyFields(),
            if (tradeAction == 'sell') _buildSellFields2(),
          ],
        ),
      );
    }
    // 其它类型可按需补充
    return const SizedBox.shrink();
  }

  Widget _buildBuyFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('銘柄情報', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        // 銘柄コード（自动补全）
        CustomInputFormFieldBySuggestion(
          labelText: '銘柄コード',
          controller: _stockCodeController,
          focusNode: _stockCodeFocusNode,
          suggestions: [..._stockSuggestions],
          loading: _stockLoading,
          notFoundText: '該当する銘柄が見つかりません',
          onChanged: _onStockCodeChanged,
          onFocusChange: _onFocusChange,
          onSuggestionTap: (stock) {
            _stockCodeController.text = stock.ticker!;
            _onStockSelected(stock);
            _selectedFromDropdown = true;
            _removeOverlay();
            FocusScope.of(context).unfocus();
          },
        ),
        const SizedBox(height: 12),
        // 銘柄名
        TextFormField(
          decoration: InputDecoration(
            labelText: '銘柄名',
            filled: true,
            fillColor: const Color(0xFFF5F6FA),
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
        ),
        const SizedBox(height: 16),
        const Text('取引詳細', style: TextStyle(fontWeight: FontWeight.bold)),
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
        CustomDropdownButtonFormField<String>(
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
                    style: TextStyle(fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontWeight: FontWeight.bold),
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
        const Text('金額（自動計算）', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextFormField(
          controller: _amountController,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F6FA),
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
                    style: TextStyle(fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  CustomDropdownButtonFormField<String>(
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
        const Text('メモ（任意）', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextFormField(
          decoration: InputDecoration(
            hintText: '取引に関するメモを入力',
            filled: true,
            fillColor: const Color(0xFFF5F6FA),
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

  // 新的卖出表单
  Widget _buildSellFields2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('売却する銘柄', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        CustomDropdownButtonFormField<String>(
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
        ),
        if (selectedSellStockId != null && sellBatches.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '選択銘柄: $selectedSellStockName',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          const Text('取引詳細', style: TextStyle(fontWeight: FontWeight.bold)),
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
            },
          ),
          const SizedBox(height: 12),
          const Text('売却数量を選択', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          // 批次输入
          Column(
            children: List.generate(sellBatches.length, (i) {
              final batch = sellBatches[i];
              final key = batch['id'].toString();
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
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    CustomTextFormField(
                      controller: sellUnitPriceController,
                      focusNode: sellUnitPriceFocusNode,
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
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: sellAmountController,
                      readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF5F6FA),
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
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),

                    CustomDropdownButtonFormField<String>(
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
          const Text('メモ（任意）', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextFormField(
            decoration: InputDecoration(
              hintText: '取引に関するメモを入力',
              filled: true,
              fillColor: const Color(0xFFF5F6FA),
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

  Future<List<Map<String, dynamic>>> getMyHoldingStocks(
    String assetType,
    String exchange,
  ) async {
    final db = AppDatabase();
    final userId = GlobalStore().userId;
    final accountId = GlobalStore().accountId;

    if (userId == null || accountId == null) {
      return [];
    }

    // 联合查询 TradeRecords 和 Stocks
    final query =
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
          ..orderBy([
            OrderingTerm.asc(db.stocks.ticker),
            OrderingTerm.asc(db.tradeRecords.tradeDate),
          ]);

    final rows = await query.get();

    final result = <int, Map<String, dynamic>>{};
    for (final row in rows) {
      final stock = row.readTable(db.stocks);
      final trade = row.readTable(db.tradeRecords);
      if (!result.containsKey(stock.id)) {
        result[stock.id] = {
          'id': stock.id,
          'code': stock.ticker,
          'name': stock.name,
          'batches': <Map<String, dynamic>>[],
        };
      }
      result[stock.id]?['batches'].add({
        'id': trade.id,
        'date': trade.tradeDate,
        'quantity': trade.quantity,
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

  // 自动计算金额
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
        canSave =
            assetCategoryCode.isNotEmpty &&
            assetSubCategoryCode.isNotEmpty &&
            selectedStockInfo != null &&
            tradeTypeCode.isNotEmpty &&
            tradeDate != null &&
            quantityValue != null &&
            unitPriceValue != null;
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
        //AppUtils().showSnackBar(
        //  context,
        //  '必須項目を入力してください',
        //  isError: true,
        //);
        Navigator.of(context).pop(); // 关闭处理中遮罩
        return;
      }
      // 保存逻辑
      bool success = false;
      if (tabIndex == 0 &&
          assetCategoryCode == 'stock' &&
          (assetSubCategoryCode == 'jp_stock' ||
              assetSubCategoryCode == 'us_stock') &&
          tradeAction == 'buy') {
        success = await AppUtils().createAsset(
          userId: GlobalStore().userId!,
          assetData: {
            "account_id": GlobalStore().accountId!,
            "asset_type": "stock",
            "asset_id": selectedStockInfo!.id,
            "trade_date": tradeDate,
            "action": tradeAction,
            "trade_type": tradeTypeCode,
            "position_type": null,
            "quantity": quantityValue,
            "price": unitPriceValue,
            "leverage": null,
            "swap_amount": null,
            "swap_currency": null,
            "fee_amount": commissionValue,
            "fee_currency": commissionCurrency,
            "manual_rate_input": false,
            "remark": memoValue,
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
      }
      Navigator.of(context).pop(); // 关闭处理中遮罩

      if (success) {
        await _showSuccessDialog();
        widget.onClose != null
            ? widget.onClose!()
            : Navigator.pop(context, true);
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

    // 2秒后自动关闭弹窗
    await Future.delayed(const Duration(seconds: 2));
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
