import 'package:flutter/material.dart';
import 'package:money_nest_app/pages/assets/cash/cash_edit_page.dart';
import 'package:money_nest_app/pages/assets/stock/stock_search_page.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/util/global_store.dart';

import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/pages/assets/stock/stock_search_page.dart';
import 'package:money_nest_app/pages/assets/cash/cash_edit_page.dart';
import 'package:money_nest_app/util/global_store.dart';

class AssetTypeSelectionPage extends StatelessWidget {
  final AppDatabase db;
  const AssetTypeSelectionPage({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('どの資産タイプを追加したいですか？', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildAssetCard(
              context,
              icon: Icons.currency_yen, // Placeholder for JP Stock
              label: '日本株',
              desc: 'Japanese Stock',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => StockSearchPage(exchange: 'JP', db: db)),
                );
              },
            ),
            _buildAssetCard(
              context,
              icon: Icons.attach_money, // Placeholder for US Stock
              label: '米国株',
              desc: 'US Stock',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => StockSearchPage(exchange: 'US', db: db)),
                );
              },
            ),
            _buildAssetCard(
              context,
              icon: Icons.money,
              label: '現金',
              desc: 'Cash',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CashEditPage(db: db)),
                );
              },
            ),
            _buildAssetCard(
              context,
              icon: Icons.more_horiz,
              label: 'その他資産',
              desc: 'Others',
              onTap: () {
                // Placeholder
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetCard(BuildContext context,
      {required IconData icon,
      required String label,
      required String desc,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            //Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
