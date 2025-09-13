import 'package:flutter/material.dart';
import 'package:money_nest_app/components/card_section.dart';
import 'package:money_nest_app/pages/trade_history/trade_add_page.dart';
import 'package:money_nest_app/pages/trade_history/trade_detail_page.dart';

class TradeHistoryPage extends StatefulWidget {
  const TradeHistoryPage({super.key});

  @override
  State<TradeHistoryPage> createState() => _TradeHistoryPageState();
}

class _TradeHistoryPageState extends State<TradeHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 顶部栏
            Row(
              children: [
                const Text(
                  '取引履歴',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('追加'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TradeAddPage()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 筛选卡片
            CardSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.filter_alt_outlined,
                        size: 18,
                        color: Colors.black54,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'フィルター',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 搜索框
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '銘柄名・コードで検索',
                        hintStyle: TextStyle(color: Colors.grey),
                        icon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 下拉筛选
                  Row(
                    children: [
                      Expanded(
                        child: _FilterDropdown(
                          items: const ['all', '買い', '売り', '配当'],
                          value: 'all',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FilterDropdown(
                          items: const ['all', '日本株', '米国株'],
                          value: 'all',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 日期筛选
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '年 / 月 / 日',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 交易记录列表
            _TradeRecordList(),
          ],
        ),
      ),
    );
  }
}

// 筛选下拉
class _FilterDropdown extends StatelessWidget {
  final List<String> items;
  final String value;
  const _FilterDropdown({required this.items, required this.value, super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        isExpanded: true,
        icon: const Icon(Icons.expand_more),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (_) {},
      ),
    );
  }
}

// 交易记录列表
class _TradeRecordList extends StatelessWidget {
  const _TradeRecordList({super.key});

  @override
  Widget build(BuildContext context) {
    // 示例数据
    final records = [
      TradeRecord(
        type: TradeType.buy,
        code: 'AAPL',
        name: 'Apple Inc.',
        date: '2024-08-25',
        amount: '¥87,500',
        detail: '5株 * ¥17,500',
      ),
      TradeRecord(
        type: TradeType.sell,
        code: '7203',
        name: 'トヨタ自動車',
        date: '2024-08-20',
        amount: '¥120,000',
        detail: '50株 * ¥2,400',
      ),
      TradeRecord(
        type: TradeType.buy,
        code: 'MSFT',
        name: 'Microsoft',
        date: '2024-08-15',
        amount: '¥120,000',
        detail: '3株 * ¥40,000',
      ),
      TradeRecord(
        type: TradeType.dividend,
        code: '6758',
        name: 'ソニー配当',
        date: '2024-08-10',
        amount: '+¥5,000',
        detail: '',
      ),
      TradeRecord(
        type: TradeType.buy,
        code: '6758',
        name: 'ソニー',
        date: '2024-08-05',
        amount: '¥375,000',
        detail: '50株 * ¥7,500',
      ),
    ];

    return Column(
      children: records.map((r) => _TradeRecordCard(record: r)).toList(),
    );
  }
}

// 交易记录卡片
class _TradeRecordCard extends StatelessWidget {
  final TradeRecord record;
  const _TradeRecordCard({required this.record, super.key});

  Color get typeColor {
    switch (record.type) {
      case TradeType.buy:
        return const Color(0xFFEF5350);
      case TradeType.sell:
        return const Color(0xFF43A047);
      case TradeType.dividend:
        return const Color(0xFF1976D2);
    }
  }

  String get typeLabel {
    switch (record.type) {
      case TradeType.buy:
        return '買い';
      case TradeType.sell:
        return '売り';
      case TradeType.dividend:
        return '配当';
    }
  }

  IconData get typeIcon {
    switch (record.type) {
      case TradeType.buy:
        return Icons.arrow_downward;
      case TradeType.sell:
        return Icons.arrow_upward;
      case TradeType.dividend:
        return Icons.card_giftcard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TradeDetailPage(record: record)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E6EA), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(typeIcon, color: typeColor, size: 20),
            ),
            const SizedBox(width: 10),
            // 主要内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        record.code,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                            color: typeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        record.amount,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: record.type == TradeType.dividend
                              ? const Color(0xFF388E3C)
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    record.name,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  if (record.detail.isNotEmpty)
                    Text(
                      record.detail,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  Text(
                    record.date,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 交易记录数据结构
enum TradeType { buy, sell, dividend }

class TradeRecord {
  final TradeType type;
  final String code;
  final String name;
  final String date;
  final String amount;
  final String detail;
  TradeRecord({
    required this.type,
    required this.code,
    required this.name,
    required this.date,
    required this.amount,
    required this.detail,
  });
}
