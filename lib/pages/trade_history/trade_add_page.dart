import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:money_nest_app/components/card_section.dart';
import 'package:money_nest_app/components/glass_tab.dart';
import 'package:money_nest_app/components/glass_tab_bar_only';
import 'package:money_nest_app/models/categories.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'trade_history_tab_page.dart'; // 导入 TradeRecord/TradeType

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
  String? assetCategory;
  String? assetSubCategory;

  // 負債用
  String? debtCategory;
  String? debtSubCategory;

  String? _selectedStockCode;
  String? _selectedStockName;

  // 下拉选项
  final List assetCategoryList = Categoryies.values
      .where((cat) => cat.type == 'asset')
      .toList();
  final List liabilityCategoryList = Categoryies.values
      .where((cat) => cat.type == 'liability')
      .toList();

  final assetCategories = {
    '株式': ['国内株式（ETF含む）', '米国株式（ETF含む）', 'その他（海外株式など）'],
    'FX（為替）': ['FX'],
    '暗号資産': ['暗号資産'],
    '貴金属': ['金', '銀', 'プラチナ'],
    'その他資産': ['銀行預金', '現金', '不動産', '投資信託', '債券', 'その他'],
  };

  final debtCategories = {
    'ローン': ['住宅ローン', '自動車ローン', '教育ローン', 'その他ローン'],
    '借金': ['クレジットカード', '消費者金融/その他'],
  };

  @override
  Widget build(BuildContext context) {
    return Material(
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
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
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

                /*Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    child: GlassTab(
                      tabs: const ['資産', '負債'],
                      tabBarContentList: [_buildAssetForm(), _buildDebtForm()],
                    ),
                  ),
                ),*/
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
    );
  }

  // 資産tab内容
  Widget _buildAssetForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // カテゴリ
        const Text('カテゴリ', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: assetCategory,
          items: assetCategories.keys
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            setState(() {
              assetCategory = v;
              assetSubCategory = null;
            });
          },
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        // サブカテゴリ
        if (assetCategory != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'サブカテゴリ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: assetSubCategory,
                items: assetCategories[assetCategory]!
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    assetSubCategory = v;
                  });
                },
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        // 动态表单内容
        if (assetCategory != null && assetSubCategory != null)
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
        DropdownButtonFormField<String>(
          value: debtCategory,
          items: debtCategories.keys
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            setState(() {
              debtCategory = v;
              debtSubCategory = null;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F6FA), // 浅灰色背景
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16), // 圆角
              borderSide: BorderSide.none, // 无边框
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ), // 内边距
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFFB0B0B0),
          ), // 下拉箭头
          style: const TextStyle(fontSize: 16, color: Colors.black87),
          dropdownColor: const Color(0xFFF5F6FA), // 下拉菜单背景色
        ),
        const SizedBox(height: 16),
        // サブカテゴリ
        if (debtCategory != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'サブカテゴリ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: debtSubCategory,
                items: debtCategories[debtCategory]!
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    debtSubCategory = v;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF5F6FA), // 浅灰色背景
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16), // 圆角
                    borderSide: BorderSide.none, // 无边框
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ), // 内边距
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFFB0B0B0),
                ), // 下拉箭头
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                dropdownColor: const Color(0xFFF5F6FA), // 下拉菜单背景色
              ),
              const SizedBox(height: 16),
            ],
          ),
        // 动态表单内容
        if (debtCategory != null && debtSubCategory != null)
          _buildDebtDynamicFields(),
      ],
    );
  }

  // 动态生成資産tab下的表单内容
  Widget _buildAssetDynamicFields() {
    // 这里只举例：株式（国内株式（ETF含む））的买入
    if (assetCategory == '株式' &&
        (assetSubCategory == '国内株式（ETF含む）' ||
            assetSubCategory == '米国株式（ETF含む）')) {
      // 取引種別
      String tradeType = 'buy'; // 默认买入
      return StatefulBuilder(
        builder: (context, setInnerState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('取引種別', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: tradeType,
              items: const [
                DropdownMenuItem(value: 'buy', child: Text('買い')),
                DropdownMenuItem(value: 'sell', child: Text('売り')),
              ],
              onChanged: (v) => setInnerState(() => tradeType = v!),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF5F6FA), // 浅灰色背景
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16), // 圆角
                  borderSide: BorderSide.none, // 无边框
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ), // 内边距
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFFB0B0B0),
              ), // 下拉箭头
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              dropdownColor: const Color(0xFFF5F6FA), // 下拉菜单背景色
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
                  /*TextFormField(
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
                    // TODO: 实现输入后自动补全、选中后自动填充銘柄名
                  ),*/
                  // 銘柄コード（自动补全）
                  StockCodeAutocomplete(
                    onSelected: (stock) {
                      setState(() {
                        _selectedStockCode = stock.code;
                        _selectedStockName = stock.name;
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
                    controller: TextEditingController(text: _selectedStockName),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '取引詳細',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // 取引日
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '取引日',
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
                    onTap: () async {
                      // TODO: 弹出日期选择
                    },
                  ),
                  const SizedBox(height: 12),
                  // 口座区分
                  DropdownButtonFormField<String>(
                    value: null,
                    items: const [
                      DropdownMenuItem(value: '一般', child: Text('一般')),
                      DropdownMenuItem(value: 'NISA', child: Text('NISA')),
                      DropdownMenuItem(value: '特定', child: Text('特定')),
                    ],
                    onChanged: (v) {},
                    decoration: InputDecoration(
                      labelText: '口座区分',
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
                  // 数量
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '数量',
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
                    // TODO: onChanged时动态计算金额
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
                    // TODO: onChanged时动态计算金额
                  ),
                  const SizedBox(height: 12),
                  // 金額（自动计算显示，不可编辑）
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '金額（自動計算）',
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
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '取引日',
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
                    onTap: () async {
                      // TODO: 弹出日期选择
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

class StockInfo {
  final String code;
  final String name;
  StockInfo(this.code, this.name);
}

class StockCodeAutocomplete extends StatefulWidget {
  final void Function(StockInfo) onSelected;
  const StockCodeAutocomplete({super.key, required this.onSelected});

  @override
  State<StockCodeAutocomplete> createState() => _StockCodeAutocompleteState();
}

class _StockCodeAutocompleteState extends State<StockCodeAutocomplete> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  List<StockInfo> _suggestions = [];
  bool _loading = false;

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
              : ListView(
                  shrinkWrap: true,
                  children: _suggestions.map((stock) {
                    return ListTile(
                      title: Text(stock.code),
                      subtitle: Text(stock.name),
                      onTap: () {
                        _controller.text = stock.code;
                        widget.onSelected(stock);
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

  Future<void> _fetchSuggestions(String value) async {
    if (value.isEmpty) {
      setState(() => _suggestions = []);
      _removeOverlay();
      return;
    }
    setState(() {
      _loading = true;
      _suggestions = [];
    });
    _showOverlay();

    final url = Uri.parse(
      'https://yeciaqfdlznrstjhqfxu.supabase.co/functions/v1/money_grow_api/stock-search?q=$value&exchange=US&limit=5',
    );
    final response = await http.get(
      url,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InllY2lhcWZkbHpucnN0amhxZnh1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MDE3NTIsImV4cCI6MjA3MTk3Nzc1Mn0.QXWNGKbr9qjeBLYRWQHEEBMT1nfNKZS3vne-Za38bOc',
      },
    );

    List<StockInfo> result = [];
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] is List) {
        result = (data['results'] as List)
            .map((item) => StockInfo(item['ticker'] ?? '', item['name'] ?? ''))
            .toList();
      }
    }

    setState(() {
      _loading = false;
      _suggestions = result;
    });
    _showOverlay();
  }

  void _onChanged(String value) {
    _debounceTimer?.cancel();
    if (value.isEmpty) {
      setState(() => _suggestions = []);
      _removeOverlay();
      return;
    }
    // 1秒防抖
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      _lastQueriedValue = value;
      _fetchSuggestions(value);
    });
  }

  void _onFocusChange(bool hasFocus) {
    if (!hasFocus) {
      _debounceTimer?.cancel();
      _removeOverlay(); // 只关闭下拉，不再请求API
    }
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
