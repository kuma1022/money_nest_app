import 'package:flutter/material.dart';

class AccountTabPage extends StatelessWidget {
  const AccountTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // 总资产卡片
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '总资产 · JPY',
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.analytics, size: 18),
                        label: const Text(
                          '资产分析',
                          style: TextStyle(fontSize: 13),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orange,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '2,441,290.33',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // 资产走势图（用占位图）
                  SizedBox(height: 40, child: Placeholder()),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _AccountActionButton(
                        icon: Icons.account_balance_wallet,
                        label: '存入资金',
                      ),
                      _AccountActionButton(
                        icon: Icons.currency_exchange,
                        label: '货币兑换',
                      ),
                      _AccountActionButton(icon: Icons.list, label: '全部'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 全部账户
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Text(
                        '全部账户(3)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Icon(Icons.expand_more),
                    ],
                  ),
                  const Divider(height: 20),
                  // 账户1
                  _AccountItem(
                    name: '现金及股票账户(1571)',
                    total: '2,441,286.57',
                    profit: '-18,439.71',
                    profitRate: '-0.75%',
                    currency: 'JPY',
                    subAccounts: [
                      _SubAccountItem(name: '日股', value: '1,323,778.00 JPY'),
                      _SubAccountItem(name: '美股', value: '7,520.27 USD'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 账户2
                  _AccountItem(
                    name: '期权交易账户(6857)',
                    total: '0.00',
                    profit: '+0.00',
                    profitRate: '',
                    currency: 'USD',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _AccountActionButton({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.orange.shade50,
          child: Icon(icon, color: Colors.orange),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _AccountItem extends StatelessWidget {
  final String name;
  final String total;
  final String profit;
  final String profitRate;
  final String currency;
  final List<_SubAccountItem>? subAccounts;

  const _AccountItem({
    required this.name,
    required this.total,
    required this.profit,
    required this.profitRate,
    required this.currency,
    this.subAccounts,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.account_balance_wallet, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '总资产 · $currency',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  total,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      profit,
                      style: TextStyle(
                        color: profit.startsWith('-')
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                    if (profitRate.isNotEmpty)
                      Text(
                        '  $profitRate',
                        style: TextStyle(
                          color: profit.startsWith('-')
                              ? Colors.red
                              : Colors.green,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
        if (subAccounts != null) ...[
          const SizedBox(height: 12),
          ...subAccounts!,
        ],
      ],
    );
  }
}

class _SubAccountItem extends StatelessWidget {
  final String name;
  final String value;
  const _SubAccountItem({required this.name, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(name, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
