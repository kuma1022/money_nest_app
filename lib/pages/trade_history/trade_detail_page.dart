import 'package:flutter/material.dart';
import 'package:money_nest_app/pages/trade_history/trade_add_page.dart';
import 'trade_history_tab_page.dart'; // 导入 TradeRecord/TradeType

class TradeDetailPage extends StatelessWidget {
  final TradeRecord record;
  const TradeDetailPage({required this.record, super.key});

  String get category =>
      record.code == 'AAPL' || record.code == 'MSFT' ? '米国株' : '日本株';

  Color get typeColor {
    switch (record.type) {
      case ActionType.buy:
        return const Color(0xFFEF5350);
      case ActionType.sell:
        return const Color(0xFF43A047);
      case ActionType.dividend:
        return const Color(0xFF1976D2);
    }
  }

  IconData get typeIcon {
    switch (record.type) {
      case ActionType.buy:
        return Icons.arrow_downward;
      case ActionType.sell:
        return Icons.arrow_upward;
      case ActionType.dividend:
        return Icons.card_giftcard;
    }
  }

  String get typeLabel {
    switch (record.type) {
      case ActionType.buy:
        return '買い';
      case ActionType.sell:
        return '売り';
      case ActionType.dividend:
        return '配当';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 示例数据
    final detail = record.detail.split('*');
    final qty = detail.length > 0
        ? detail[0].replaceAll(RegExp(r'\D'), '')
        : '1';
    final unit = detail.length > 1
        ? detail[1].replaceAll(RegExp(r'\D'), '')
        : '';
    final fee = record.type == ActionType.dividend
        ? '¥0'
        : (record.code == 'AAPL' ? '¥500' : '¥300');
    final total = record.type == ActionType.dividend
        ? record.amount
        : record.code == 'AAPL'
        ? '¥88,000'
        : '¥120,300';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            children: [
              // 返回
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    '戻る',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '取引詳細',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Chip(
                  label: Text(
                    typeLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(color: typeColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5E6EA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(typeIcon, color: typeColor, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          '${record.code} - ${record.name}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '取引日',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                record.date,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'カテゴリ',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                category,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '数量',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${qty}株',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '単価',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                unit.isNotEmpty ? '¥$unit' : '-',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '取引金額',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                record.amount,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '手数料',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(fee, style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '合計金額',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          total,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F6FA),
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Color(0xFFF5F6FA)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        // 跳转到编辑页面
                        //Navigator.of(context).push(
                        //  MaterialPageRoute(
                        //    builder: (_) => TradeAddPage(record: record),
                        //  ),
                        //);
                      },
                      child: const Text(
                        '編集',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        // 弹窗确认
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('削除確認'),
                            content: const Text('この取引記録を削除しますか？'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('キャンセル'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text(
                                  '削除',
                                  style: TextStyle(color: Color(0xFFE53935)),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (result == true) {
                          // 删除后返回上一页
                          Navigator.of(context).pop();
                          // 可以加上删除逻辑
                        }
                      },
                      child: const Text(
                        '削除',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
