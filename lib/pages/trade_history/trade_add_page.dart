import 'package:flutter/material.dart';
import 'package:money_nest_app/components/glass_tab.dart';
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
            GlassTab(
              tabs: const ['資産', '負債'],
              //initialIndex: tabIndex,
              //onChanged: (i) {
              //  setState(() {
              //    tabIndex = i;
              //    // 切换tab时重置选择
              //    assetCategory = null;
              //    assetSubCategory = null;
              //    debtCategory = null;
              //    debtSubCategory = null;
              //  });
              //},
              tabBarContentList: [_buildAssetForm(), _buildDebtForm()],
            ),
            //const SizedBox(height: 12),
            //Expanded(
            //  child: SingleChildScrollView(
            //    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            //   child: tabIndex == 0 ? _buildAssetForm() : _buildDebtForm(),
            // ),
            //),
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
      String? tradeType;
      return StatefulBuilder(
        builder: (context, setInnerState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('取引種別', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: tradeType,
              items: const [
                DropdownMenuItem(value: '買い', child: Text('買い')),
                DropdownMenuItem(value: '売り', child: Text('売り')),
              ],
              onChanged: (v) => setInnerState(() => tradeType = v),
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
            if (tradeType == '買い')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '銘柄情報',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // ...后续表单内容...
                ],
              ),
            if (tradeType == '売り')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '売却する株式を選択',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // ...后续表单内容...
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
