import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:money_nest_app/components/glass_panel.dart';
import 'package:money_nest_app/components/total_asset_analysis_card.dart';
import 'package:money_nest_app/pages/assets/stock_detail_page.dart';
import 'package:money_nest_app/pages/assets/other_asset_manage_page.dart';
import 'package:money_nest_app/presentation/resources/app_texts.dart';

class AssetsTabPage extends StatefulWidget {
  final ValueChanged<double>? onScroll;
  final ScrollController? scrollController;

  const AssetsTabPage({super.key, this.onScroll, this.scrollController});

  @override
  State<AssetsTabPage> createState() => _AssetsTabPageState();
}

class _AssetsTabPageState extends State<AssetsTabPage> {
  int _tabIndex = 0; // 0:概要 1:日本株 2:米国株 3:その他
  String _overviewType = '品類';

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE3E6F3),
                    Color(0xFFB8BFD8),
                    Color(0xFF9CA3BA),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 8, bottomPadding),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                double pixels = 0.0;
                if (notification is ScrollUpdateNotification ||
                    notification is OverscrollNotification) {
                  pixels = notification.metrics.pixels;
                  if (pixels < 0) pixels = 0; // 只允许正数（如需overscroll缩放可不处理）
                  widget.onScroll?.call(pixels);
                }
                return false;
              },
              child: SingleChildScrollView(
                controller: widget.scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 总资产额卡片
                    GlassPanel(
                      margin: const EdgeInsets.only(bottom: 18),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 18,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Text(
                                    '資産総額',
                                    style: TextStyle(
                                      fontSize: AppTexts.fontSizeLarge,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    '¥1,600,000',
                                    style: TextStyle(
                                      fontSize: AppTexts.fontSizeHuge,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.trending_up,
                                        color: Color(0xFF43A047),
                                        size: AppTexts.fontSizeMedium,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        '¥250,000 (+25%)',
                                        style: TextStyle(
                                          color: Color(0xFF43A047),
                                          fontSize: AppTexts.fontSizeMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 资产总览区块
                    TotalAssetAnalysisCard(),
                    // tab切换栏（独立于资产总览）
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: List.generate(4, (i) {
                          final tabs = ['概要', '日本株', '米国株', 'その他'];
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _tabIndex = i),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _tabIndex == i
                                      ? const Color(0xFFF5F6FA)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _tabIndex == i
                                        ? const Color(0xFF1976D2)
                                        : const Color(0xFFE5E6EA),
                                    width: 1.2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    tabs[i],
                                    style: TextStyle(
                                      color: _tabIndex == i
                                          ? const Color(0xFF1976D2)
                                          : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    // tab内容区块
                    if (_tabIndex == 0) ...[
                      // 概要tab
                      _AssetCategoryCard(
                        title: '日本株',
                        amount: '¥750,000',
                        profit: '+¥125,000 (20%)',
                        profitColor: const Color(0xFF388E3C),
                        profitBg: const Color(0xFFE6F9F0),
                        items: const [
                          _AssetItem(
                            code: '7203',
                            name: 'トヨタ自動車',
                            amount: '¥250,000',
                            profit: '+¥50,000',
                            profitColor: Color(0xFF388E3C),
                          ),
                          _AssetItem(
                            code: '6758',
                            name: 'ソニー',
                            amount: '¥400,000',
                            profit: '+¥75,000',
                            profitColor: Color(0xFF388E3C),
                          ),
                          _AssetItem(
                            code: '9984',
                            name: 'ソフトバンク',
                            amount: '¥100,000',
                            profit: '+¥0',
                            profitColor: Color(0xFF757575),
                          ),
                        ],
                      ),
                      _AssetCategoryCard(
                        title: '米国株',
                        amount: '¥450,000',
                        profit: '+¥75,000 (20%)',
                        profitColor: const Color(0xFF388E3C),
                        profitBg: const Color(0xFFE6F9F0),
                        items: const [
                          _AssetItem(
                            code: 'AAPL',
                            name: 'Apple Inc.',
                            amount: '¥180,000',
                            profit: '+¥30,000',
                            profitColor: Color(0xFF388E3C),
                          ),
                          _AssetItem(
                            code: 'MSFT',
                            name: 'Microsoft',
                            amount: '¥210,000',
                            profit: '+¥35,000',
                            profitColor: Color(0xFF388E3C),
                          ),
                          _AssetItem(
                            code: 'GOOGL',
                            name: 'Alphabet',
                            amount: '¥60,000',
                            profit: '+¥10,000',
                            profitColor: Color(0xFF388E3C),
                          ),
                        ],
                      ),
                      _AssetCategoryCard(
                        title: '現金',
                        amount: '¥250,000',
                        profit: '+¥0 (0%)',
                        profitColor: const Color(0xFF757575),
                        profitBg: const Color(0xFFF5F6FA),
                        items: const [],
                      ),
                      _CardSection(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'その他資産',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1976D2),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('管理'),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const OtherAssetManagePage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '¥4,870,000',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _OtherAssetItem(
                              label: '銀行預金',
                              subLabel: '現金',
                              amount: '¥250,000',
                            ),
                            _OtherAssetItem(
                              label: '金 (GOLD)',
                              subLabel: '貴金属',
                              amount: '¥120,000',
                            ),
                            _OtherAssetItem(
                              label: 'ドル預金',
                              subLabel: '外貨',
                              amount: '¥30,000',
                              subAmount: '→¥4,500,000',
                            ),
                          ],
                        ),
                      ),
                    ] else if (_tabIndex == 1) ...[
                      // 日本株tab
                      _CardSection(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  '日本株',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                const Text(
                                  '¥750,000',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6F9F0),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Text(
                                    '+¥125,000 (20%)',
                                    style: TextStyle(
                                      color: Color(0xFF388E3C),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // 日本株tab按钮布局：购买按钮大，配当按钮小且右侧
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF1976D2),
                                      side: const BorderSide(
                                        color: Color(0xFF1976D2),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    icon: const Icon(Icons.add),
                                    label: const Text('購入'),
                                    onPressed: () {},
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF1976D2),
                                      side: const BorderSide(
                                        color: Color(0xFF1976D2),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.card_giftcard,
                                      size: 18,
                                    ),
                                    label: const Text('配当'),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _AssetItem(
                              code: '7203',
                              name: 'トヨタ自動車',
                              amount: '¥250,000',
                              profit: '+¥50,000',
                              profitColor: const Color(0xFF388E3C),
                            ),
                            _AssetItem(
                              code: '6758',
                              name: 'ソニー',
                              amount: '¥400,000',
                              profit: '+¥75,000',
                              profitColor: const Color(0xFF388E3C),
                            ),
                            _AssetItem(
                              code: '9984',
                              name: 'ソフトバンク',
                              amount: '¥100,000',
                              profit: '+¥0',
                              profitColor: const Color(0xFF757575),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_tabIndex == 2) ...[
                      // 米国株tab
                      _CardSection(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  '米国株',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                const Text(
                                  '¥450,000',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6F9F0),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Text(
                                    '+¥75,000 (20%)',
                                    style: TextStyle(
                                      color: Color(0xFF388E3C),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // 米国株tab按钮布局：两个按钮等宽
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF1976D2),
                                      side: const BorderSide(
                                        color: Color(0xFF1976D2),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    icon: const Icon(Icons.add),
                                    label: const Text('購入'),
                                    onPressed: () {},
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF1976D2),
                                      side: const BorderSide(
                                        color: Color(0xFF1976D2),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.card_giftcard,
                                      size: 18,
                                    ),
                                    label: const Text('配当'),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _AssetItem(
                              code: 'AAPL',
                              name: 'Apple Inc.',
                              amount: '¥180,000',
                              profit: '+¥30,000',
                              profitColor: const Color(0xFF388E3C),
                            ),
                            _AssetItem(
                              code: 'MSFT',
                              name: 'Microsoft',
                              amount: '¥210,000',
                              profit: '+¥35,000',
                              profitColor: const Color(0xFF388E3C),
                            ),
                            _AssetItem(
                              code: 'GOOGL',
                              name: 'Alphabet',
                              amount: '¥60,000',
                              profit: '+¥10,000',
                              profitColor: const Color(0xFF388E3C),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_tabIndex == 3) ...[
                      // その他tab
                      _CardSection(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'その他資産',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1976D2),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('管理'),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const OtherAssetManagePage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '¥4,870,000',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _OtherAssetItem(
                              label: '銀行預金',
                              subLabel: '現金',
                              amount: '¥250,000',
                            ),
                            _OtherAssetItem(
                              label: '金 (GOLD)',
                              subLabel: '貴金属',
                              amount: '¥120,000',
                            ),
                            _OtherAssetItem(
                              label: 'ドル預金',
                              subLabel: '外貨',
                              amount: '¥30,000',
                              subAmount: '→¥4,500,000',
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 卡片通用外框
class _CardSection extends StatelessWidget {
  final Widget child;
  const _CardSection({required this.child, super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E6EA), width: 1),
      ),
      child: child,
    );
  }
}

// 资产总览tab按钮
class _OverviewTabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _OverviewTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF5F6FA) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF1976D2) : const Color(0xFFE5E6EA),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF1976D2) : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// 资产总览图例
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final String percent;
  const _LegendDot({
    required this.color,
    required this.label,
    required this.percent,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 2),
        Text(percent, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }
}

// 分类资产卡片
class _AssetCategoryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String profit;
  final Color profitColor;
  final Color profitBg;
  final List<_AssetItem> items;
  const _AssetCategoryCard({
    required this.title,
    required this.amount,
    required this.profit,
    required this.profitColor,
    required this.profitBg,
    required this.items,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      margin: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: profitBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  profit,
                  style: TextStyle(
                    color: profitColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 8),
            Column(children: items),
          ],
        ],
      ),
    );
  }
}

// 分类资产明细
class _AssetItem extends StatelessWidget {
  final String code;
  final String name;
  final String amount;
  final String profit;
  final Color profitColor;
  const _AssetItem({
    required this.code,
    required this.name,
    required this.amount,
    required this.profit,
    required this.profitColor,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StockDetailPage(
              code: code,
              name: name,
              amount: amount,
              profit: profit,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  name,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  profit,
                  style: TextStyle(
                    fontSize: 13,
                    color: profitColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// 其它资产明细
class _OtherAssetItem extends StatelessWidget {
  final String label;
  final String subLabel;
  final String amount;
  final String? subAmount;
  const _OtherAssetItem({
    required this.label,
    required this.subLabel,
    required this.amount,
    this.subAmount,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                subLabel,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (subAmount != null)
                Text(
                  subAmount!,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
