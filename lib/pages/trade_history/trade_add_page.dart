import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:money_nest_app/components/glass_tab.dart';
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
        child: Column(
          children: [
            // 顶部关闭与标题
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black87),
                    onPressed: widget.onClose ?? () => Navigator.pop(context),
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
            const Divider(height: 1),
            // glass_tab
            Expanded(
              child: GlassTab(
                tabs: const ['資産', '負債'],
                tabBarContentList: [
                  _buildAssetForm(), // 直接传Column
                  _buildDebtForm(),
                ],
              ),
            ),
          ],
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
          initialValue: assetCategory,
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
          initialValue: debtCategory,
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
                initialValue: debtSubCategory,
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
              initialValue: tradeType,
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
                  TextFormField(
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
