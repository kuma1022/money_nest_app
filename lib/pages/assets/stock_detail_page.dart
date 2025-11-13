import 'package:flutter/material.dart';
import 'package:money_nest_app/db/app_database.dart';

class StockDetailPage extends StatelessWidget {
  final String code;
  final String name;
  final String amount;
  final String profit;

  const StockDetailPage({
    required this.code,
    required this.name,
    required this.amount,
    required this.profit,
    super.key,
    required AppDatabase db,
  });

  // 示例数据（实际应从数据源获取）
  bool get isJapanStock => code != 'AAPL' && code != 'MSFT';

  @override
  Widget build(BuildContext context) {
    // 示例数据
    final price = isJapanStock ? 2500 : 18000;
    final priceDiff = isJapanStock ? -80 : -29;
    final priceDiffRate = isJapanStock ? -3.10 : -0.16;
    final priceDiffColor = priceDiff < 0 ? Colors.red : Colors.green;
    final prevClose = isJapanStock ? 2580 : 18029;
    final volume = isJapanStock ? '1022K' : '987K';
    final high = isJapanStock ? 2567 : 18114;
    final low = isJapanStock ? 2444 : 17973;

    final holdingQty = isJapanStock ? 100 : 10;
    final avgCost = isJapanStock ? 2000 : 15000;
    final currentValue = isJapanStock ? 250000 : 180000;
    final evalProfit = isJapanStock ? 50000 : 30000;
    final evalProfitRate = isJapanStock ? 0.25 : 0.20;
    final investRate = isJapanStock ? 0.172 : 0.124;

    final recentTrades = isJapanStock
        ? [
            {'type': '買い', 'date': '2024-08-20', 'qty': 50, 'price': 2400},
            {'type': '買い', 'date': '2024-07-15', 'qty': 30, 'price': 2200},
            {'type': '買い', 'date': '2024-06-10', 'qty': 20, 'price': 2000},
          ]
        : [
            {'type': '買い', 'date': '2024-08-20', 'qty': 50, 'price': 17900},
            {'type': '買い', 'date': '2024-07-15', 'qty': 30, 'price': 17700},
            {'type': '買い', 'date': '2024-06-10', 'qty': 20, 'price': 17500},
          ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              Center(
                child: Column(
                  children: [
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '¥${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${priceDiff >= 0 ? '+' : ''}¥${priceDiff.abs()} (${priceDiffRate >= 0 ? '+' : ''}${priceDiffRate.toStringAsFixed(2)}%)',
                      style: TextStyle(
                        fontSize: 18,
                        color: priceDiffColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '今日の値動き',
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 市場情報
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5E6EA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '市場情報',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '前日終値',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '¥${prevClose.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
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
                                '出来高',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                volume,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '日高',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '¥${high.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
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
                                '日安',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '¥${low.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 保有情報
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5E6EA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '保有情報',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '保有株数',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$holdingQty株',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '平均取得価格',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '¥${avgCost.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '現在価値',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '¥${currentValue.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '評価損益',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '¥${evalProfit.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} (${(evalProfitRate * 100).toStringAsFixed(1)}%)',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF43A047),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '投資比率',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${(investRate * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),
              // 最近の取引
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5E6EA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '最近の取引',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...recentTrades.map(
                      (trade) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3EFFF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                (trade['type'] as String),
                                style: const TextStyle(
                                  color: Color(0xFF1976D2),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              trade['date'] as String,
                              style: const TextStyle(fontSize: 15),
                            ),
                            const Spacer(),
                            Text(
                              '${trade['qty']}株',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '¥${trade['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 底部按钮
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F6FA),
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Color(0xFFF5F6FA)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      onPressed: () {
                        // 跳转到卖出页面
                      },
                      child: const Text(
                        '売却',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4385F5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // 跳转到追加購入页面
                      },
                      child: const Text(
                        '追加購入',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F6FA),
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Color(0xFFF5F6FA)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      icon: const Icon(
                        Icons.card_giftcard,
                        color: Color(0xFF1976D2),
                      ),
                      label: const Text(
                        '配当',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        // 跳转到配当页面
                      },
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
