import 'package:flutter/material.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/pages/assets/cash/cash_edit_page.dart';
import 'package:money_nest_app/util/app_utils.dart';

class CashPage extends StatefulWidget {
  final AppDatabase db;

  const CashPage({super.key, required this.db});

  @override
  State<CashPage> createState() => _CashPageState();
}

class _CashPageState extends State<CashPage> {
  // Demo Data
  final double _totalBalance = 4.96;
  final String _currency = 'USD';
  
  final List<Map<String, dynamic>> _demoTransactions = [
    {
      'date': '2026-02-09',
      'title': '1シェアあたり\$0.26のAAPL配当 (四半期)',
      'amount': 0.26,
    },
    {
      'date': '2025-12-24',
      'title': '1シェアあたり\$0.24のMETA配当',
      'amount': 0.24,
    },
    {
      'date': '2025-12-15',
      'title': '1シェアあたり\$0.52のMETA配当 (四半期)',
      'amount': 0.52,
    },
    {
      'date': '2025-11-10',
      'title': '1シェアあたり\$0.26のAAPL配当 (四半期)',
      'amount': 0.26,
    },
    {
      'date': '2025-09-24',
      'title': '1シェアあたり\$0.14のMETA配当',
      'amount': 0.14,
    },
    {
      'date': '2025-09-22',
      'title': '1シェアあたり\$0.52のMETA配当 (四半期)',
      'amount': 0.52,
    },
     {
      'date': '2025-08-11',
      'title': '1シェアあたり\$0.26のAAPL配当 (四半期)',
      'amount': 0.26,
    },
     {
      'date': '2025-05-12',
      'title': '1シェアあたり\$0.26のAAPL配当 (四半期)',
      'amount': 0.26,
    },
  ];

  void _openEditPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CashEditPage(db: widget.db, isDeposit: true),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              '利用可能な現金',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '合計残高: ${AppUtils().formatMoney(_totalBalance, _currency)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildSummaryCard(),
            const SizedBox(height: 32),
            
            // New Transaction Button Row
            InkWell(
              onTap: () => _openEditPage(context),
              child: Row(
                children: [
                  Container(
                    width: 48, 
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF2C2C2E),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Text('新しい取引', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),

            // Timelined List
            Stack(
              children: [
                // Vertical Line
                Positioned(
                  left: 23, // Center of width 48 is 24. Minus 1/2 line width (1) approx 23.5
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: const Color(0xFF2C2C2E),
                  ),
                ),
                // Items
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _demoTransactions.length,
                  itemBuilder: (context, index) {
                    final item = _demoTransactions[index];
                    final dateLines = (item['date'] as String).split('-');
                    final formattedDate = "${int.parse(dateLines[2])} ${dateLines[1]}月 ${dateLines[0]}";
                    
                    return Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon container centered on 48px width
                          SizedBox(
                            width: 48,
                            child: Center(
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.black, // Mask the line behind
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                                child: const Center(
                                  child: Text(
                                    'i',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      fontFamily: 'serif',
                                      height: 1.0, 
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$formattedDate ${item['title']}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flag Icon
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
               color: Color(0xFF002a8f), // US Blue approx
            ),
             child: const Center(child: Text("🇺🇸", style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(height: 12),
          Text(
            AppUtils().formatMoney(_totalBalance, _currency),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '利用可能なUSD',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}