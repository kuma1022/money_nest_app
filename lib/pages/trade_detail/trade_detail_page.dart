import 'package:flutter/material.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/models/trade_action.dart';
import 'package:money_nest_app/models/trade_category.dart';
import 'package:money_nest_app/models/trade_type.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/pages/trade_detail/trade_edit_page.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class TradeRecordDetailPage extends StatelessWidget {
  final AppDatabase db;
  final TradeRecord record;
  final ScrollController? scrollController; // 新增

  const TradeRecordDetailPage({
    super.key,
    required this.db,
    required this.record,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.tradeDetailPageTitle,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false, // 不显示返回按钮
        leading: IconButton(
          icon: const Icon(Icons.edit),
          tooltip: '编辑',
          onPressed: () async {
            await showBarModalBottomSheet(
              context: context,
              expand: false,
              backgroundColor: Colors.transparent,
              topControl: Container(), // 不显示顶部控制条
              builder: (context) => Container(
                height: MediaQuery.of(context).size.height * 0.9,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: TradeRecordEditPage(db: db, record: record),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          controller: scrollController, // 支持底部弹窗滚动
          children: [
            _buildRow(
              AppLocalizations.of(context)!.tradeDetailPageTradeDateLabel,
              record.tradeDate.toLocal().toString().split(' ')[0],
            ),
            _buildRow(
              AppLocalizations.of(context)!.tradeDetailPageActionLabel,
              record.action.displayName(context),
            ),
            _buildRow(
              AppLocalizations.of(context)!.tradeDetailPageCategoryLabel,
              record.category.displayName,
            ),
            _buildRow(
              AppLocalizations.of(context)!.tradeDetailPageTradeTypeLabel,
              record.tradeType.displayName,
            ),
            _buildRow(
              AppLocalizations.of(context)!.tradeDetailPageNameLabel,
              record.name,
            ),
            _buildRow(
              AppLocalizations.of(context)!.tradeDetailPageCodeLabel,
              record.code ?? '',
            ),
            _buildRow(
              AppLocalizations.of(context)!.tradeDetailPageNumberLabel,
              record.quantity?.toString() ?? '',
            ),
            _buildRow(
              AppLocalizations.of(context)!.tradeDetailPageCurrencyLabel,
              record.currency.displayName(context),
            ),
            _buildRow(
              AppLocalizations.of(context)!.tradeDetailPagePriceLabel,
              record.price?.toString() ?? '',
            ),
            _buildRow(
              AppLocalizations.of(context)!.tradeDetailPageRateLabel,
              record.rate?.toString() ?? '',
            ),
            _buildRow(
              AppLocalizations.of(context)!.tradeDetailPageRemarkLabel,
              record.remark ?? '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
