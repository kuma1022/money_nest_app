import 'dart:async';
import 'dart:ui'; // 新增
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
          onChanged: (v) {
            setState(() {
              assetCategoryCode = v ?? '';
              assetSubCategoryCode = '';
              selectedStockCode = '';
              selectedStockName = '';
              selectedStockInfo = null;
              // 如有其它相关字段也一并清空
            });
          },
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
            onChanged: (v) {
              setState(() {
                assetSubCategoryCode = v ?? '';
                selectedStockCode = '';
                selectedStockName = '';
                selectedStockInfo = null;
                // 如有其它相关字段也一并清空
              });
            },
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
    // 这里只举例：株式（国内株式（ETF含む））的买入
    if (assetCategoryCode == 'stock' &&
        (assetSubCategoryCode == 'jp_stock' ||
            assetSubCategoryCode == 'us_stock')) {
      // 取引種別
      return StatefulBuilder(
        builder: (context, setInnerState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            //const Text('取引種別', style: TextStyle(fontWeight: FontWeight.bold)),
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
            if (tradeAction == 'buy')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '銘柄情報',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                  const Text(
                    '取引詳細',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,4}'),
                                ),
                                TextInputFormatter.withFunction((
                                  oldValue,
                                  newValue,
                                ) {
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
                                final quantity = num.tryParse(
                                  value.replaceAll(',', ''),
                                );
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
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,4}'),
                                ),
                                TextInputFormatter.withFunction((
                                  oldValue,
                                  newValue,
                                ) {
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
                                final unitPrice = num.tryParse(
                                  value.replaceAll(',', ''),
                                );
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
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,4}'),
                                ),
                                TextInputFormatter.withFunction((
                                  oldValue,
                                  newValue,
                                ) {
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
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
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
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
              ),
            if (tradeAction == 'sell')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '売却する株式を選択',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // TODO: 下拉选择持有的股票
                  DropdownButtonFormField<String>(
                    value: null,
                    items: const [
                      // TODO: 用实际持仓数据填充
                      DropdownMenuItem(value: 'AAPL', child: Text('AAPL')),
                      DropdownMenuItem(value: '7203', child: Text('7203')),
                    ],
                    onChanged: (v) {},
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
                  const SizedBox(height: 12),
                  // 銘柄名（自动显示）
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
                    readOnly: true,
                    controller: /* TODO: 銘柄名controller */
                        TextEditingController(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '取引詳細',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
                  // 売却数量を選択（多批次选择，动态计算总数量）
                  // TODO: 用ListView或自定义控件展示所有买入批次，用户输入每批卖出数量
                  const Text(
                    '売却数量を選択（複数ロット対応）',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // ...批次选择控件...
                  const SizedBox(height: 12),
                  // 総売却数量（自动计算显示）
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '総売却数量（自動計算）',
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
                    controller: /* TODO: 总数量controller */
                        TextEditingController(),
                  ),
                  const SizedBox(height: 12),
                  // 単価
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '単価',
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
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  // 売却金額（自动计算显示，不可编辑）
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '売却金額（自動計算）',
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
                    controller: /* TODO: 金额controller */
                        TextEditingController(),
                  ),
                  const SizedBox(height: 12),
                  // 手数料（任意）
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '手数料（任意）',
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
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  // 手数料通貨
                  DropdownButtonFormField<String>(
                    value: null,
                    items: const [
                      DropdownMenuItem(value: 'JPY', child: Text('JPY')),
                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                    ],
                    onChanged: (v) {},
                    decoration: InputDecoration(
                      labelText: '手数料通貨',
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
                  const SizedBox(height: 12),
                  // メモ（任意）
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'メモ（任意）',
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
                  ),
                ],
              ),
          ],
        ),
      );
    }
    // 其它类型可按需补充
    return const SizedBox.shrink();
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
