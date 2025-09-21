import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:money_nest_app/components/custom_date_dropdown_field.dart';
import 'package:money_nest_app/components/custom_dropdown_button_form_field.dart';
import 'package:money_nest_app/components/glass_tab.dart';
import 'package:money_nest_app/models/categories.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/models/stock_info.dart';
import 'package:money_nest_app/models/trade_type.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'trade_history_tab_page.dart';
import 'package:flutter/services.dart'; // 顶部import

class TradeAddPage extends StatefulWidget {
  final TradeRecord? record; // 支持编辑模式
  final VoidCallback? onClose;
  const TradeAddPage({super.key, this.onClose, this.record});

  @override
  State<TradeAddPage> createState() => _TradeAddPageState();
}

class _TradeAddPageState extends State<TradeAddPage> {
  int tabIndex = 0; // 0: 資産, 1: 負債

  // 資産用
  String assetCategoryCode = '';
  String assetSubCategoryCode = '';

  // 負債用
  String debtCategoryCode = '';
  String debtSubCategoryCode = '';

  String selectedStockCode = '';
  String selectedStockName = '';

  // カテゴリ・サブカテゴリ数据
  late final List<Categories> assetCategories;
  late final List<Categories> debtCategories;
  late final Map<String, List<Map<String, dynamic>>> assetCategoriesWithSub;
  late final Map<String, List<Map<String, dynamic>>> debtCategoriesWithSub;
  // 取引種別
  String tradeTypeCode = '';
  late final List<dynamic> tradeTypes;
  // 取引日
  DateTime? tradeDate;
  // 手数料通貨
  String commissionCurrency = '';
  late final List<String> commissionCurrencies =
      Currency.values.map((e) => e.code).toList()
        ..sort((a, b) => a.compareTo(b));

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

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
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    _amountController.dispose();
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
                  const SizedBox(height: 32),
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
                            onPressed: () {
                              // TODO: 保存逻辑
                            },
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
            fontSize: 15,
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
                          (e) => e['code'] as String == assetSubCategoryCode,
                        ) ==
                        true
                ? assetSubCategoryCode
                : null,
            onChanged: (v) {
              setState(() {
                assetSubCategoryCode = v ?? '';
                selectedStockCode = '';
                selectedStockName = '';
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
        const Text('カテゴリ', style: TextStyle(fontWeight: FontWeight.bold)),
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
        const SizedBox(height: 16),
        // サブカテゴリ
        if (debtCategoryCode.isNotEmpty)
          CustomDropdownButtonFormField<String>(
            hintText: 'サブカテゴリを選択',
            selectedValue:
                debtSubCategoryCode.isNotEmpty &&
                    debtCategoriesWithSub[debtCategoryCode]?.any(
                          (e) => e['code'] as String == debtSubCategoryCode,
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
      String tradeType = 'buy'; // 默认买入
      return StatefulBuilder(
        builder: (context, setInnerState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            //const Text('取引種別', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            CupertinoSlidingSegmentedControl<String>(
              groupValue: tradeType,
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
                      color: tradeType == 'buy'
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
                      color: tradeType == 'sell'
                          ? Color(0xFF4F8CFF)
                          : Color(0xFF888888),
                    ),
                  ),
                ),
              },
              onValueChanged: (v) => setInnerState(() => tradeType = v!),
              backgroundColor: Colors.white.withOpacity(0.85),
              thumbColor: Colors.white,
            ),
            const SizedBox(height: 16),
            if (tradeType == 'buy')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '銘柄情報',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // 銘柄コード（自动补全）
                  StockCodeAutocomplete(
                    exchange: assetSubCategoryCode == 'jp_stock' ? 'JP' : 'US',
                    onSelected: (stock) {
                      setState(() {
                        if (stock.code.isNotEmpty && stock.name.isNotEmpty) {
                          selectedStockCode = stock.code;
                          selectedStockName = stock.name;
                        } else {
                          selectedStockCode = '';
                          selectedStockName = '';
                        }
                      });
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
                    value: tradeDate,
                    onChanged: (date) {
                      setState(() {
                        tradeDate = date;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // 口座区分
                  CustomDropdownButtonFormField<String>(
                    hintText: '口座区分を選択',
                    selectedValue:
                        tradeTypeCode.isNotEmpty &&
                            tradeTypes.any(
                              (e) => e['code'] as String == tradeTypeCode,
                            )
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
                            TextFormField(
                              controller: _quantityController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*'),
                                ),
                                TextInputFormatter.withFunction((
                                  oldValue,
                                  newValue,
                                ) {
                                  final text = newValue.text;
                                  // 不能以小数点开头
                                  if (text.startsWith('.')) return oldValue;
                                  // 只允许一个小数点
                                  if ('.'.allMatches(text).length > 1)
                                    return oldValue;
                                  return newValue;
                                }),
                              ],
                              decoration: InputDecoration(
                                hintText: '例: 100',
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
                              onChanged: (value) {
                                if (value.isEmpty) return;
                                final num? n = num.tryParse(value);
                                if (n == null) return;
                                final formatted = n % 1 == 0
                                    ? n.toInt().toString()
                                    : n.toString();
                                if (formatted != value) {
                                  _quantityController.value = TextEditingValue(
                                    text: formatted,
                                    selection: TextSelection.collapsed(
                                      offset: formatted.length,
                                    ),
                                  );
                                }
                                _updateAmount();
                              },
                              onEditingComplete: _updateAmount,
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
                            TextFormField(
                              controller: _unitPriceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*'),
                                ),
                                TextInputFormatter.withFunction((
                                  oldValue,
                                  newValue,
                                ) {
                                  final text = newValue.text;
                                  // 不能以小数点开头
                                  if (text.startsWith('.')) return oldValue;
                                  // 只允许一个小数点
                                  if ('.'.allMatches(text).length > 1)
                                    return oldValue;
                                  return newValue;
                                }),
                              ],
                              decoration: InputDecoration(
                                hintText: '例: 2500',
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
                              onChanged: (value) {
                                if (value.isEmpty) return;
                                final num? n = num.tryParse(value);
                                if (n == null) return;
                                final formatted = n % 1 == 0
                                    ? n.toInt().toString()
                                    : n.toString();
                                if (formatted != value) {
                                  _unitPriceController.value = TextEditingValue(
                                    text: formatted,
                                    selection: TextSelection.collapsed(
                                      offset: formatted.length,
                                    ),
                                  );
                                }
                                _updateAmount();
                              },
                              onEditingComplete: _updateAmount,
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
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: '例: 500',
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
                  ),
                ],
              ),
            if (tradeType == 'sell')
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
                    value: tradeDate,
                    onChanged: (date) {
                      setState(() {
                        tradeDate = date;
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
      final formatted = amount % 1 == 0
          ? amount.toInt().toString()
          : amount.toString();
      _amountController.text = formatted;
    } else {
      _amountController.text = '';
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

class StockCodeAutocomplete extends StatefulWidget {
  final void Function(StockInfo) onSelected;
  final String exchange;
  const StockCodeAutocomplete({
    super.key,
    required this.onSelected,
    required this.exchange,
  });

  @override
  State<StockCodeAutocomplete> createState() => _StockCodeAutocompleteState();
}

class _StockCodeAutocompleteState extends State<StockCodeAutocomplete> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  List<StockInfo> _suggestions = [];
  bool _loading = false;
  bool _selectedFromDropdown = false;

  Timer? _debounceTimer;
  String _lastQueriedValue = '';

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _removeOverlay();
    _debounceTimer?.cancel();
    super.dispose();
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
          child: _loading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              : _suggestions.isEmpty
              ? const ListTile(title: Text('該当する銘柄が見つかりません'))
              : ListView(
                  shrinkWrap: true,
                  children: _suggestions.map((stock) {
                    return ListTile(
                      title: Text(stock.code),
                      subtitle: Text(stock.name),
                      onTap: () {
                        _controller.text = stock.code;
                        widget.onSelected(stock);
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

  void _onChanged(String value) {
    _lastQueriedValue = value;
    if (value.isEmpty) {
      setState(() => _suggestions = []);
      _removeOverlay();
      widget.onSelected(StockInfo('', ''));
      return;
    }
    _fetchSuggestions(value, widget.exchange);
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

      final inputCode = _controller.text.trim();

      // 如果候选项中有完全匹配的，选中它
      for (var stock in _suggestions) {
        if (stock.code == inputCode) {
          _controller.text = stock.code;
          widget.onSelected(stock);
          return;
        }
      }

      // 否则清空输入
      _controller.clear();
      widget.onSelected(StockInfo('', ''));
    }
  }

  Future<void> _fetchSuggestions(String value, String exchange) async {
    setState(() {
      _loading = true;
      _suggestions = [];
    });
    _showOverlay();

    List<StockInfo> result = await AppUtils().fetchStockSuggestions(
      value,
      exchange,
    );

    // 只处理最后一次输入的结果
    if (_lastQueriedValue != value) return;

    setState(() {
      _loading = false;
      _suggestions = result;
    });
    _showOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: _onFocusChange,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: '銘柄コード',
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
        onChanged: _onChanged,
      ),
    );
  }
}
