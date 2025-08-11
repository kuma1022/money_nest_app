// trade_tab_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/models/trade_action.dart';
import 'package:money_nest_app/models/trade_category.dart';
import 'package:money_nest_app/pages/trade_detail/trade_add_page.dart';
import 'package:money_nest_app/pages/trade_detail/trade_detail_page.dart';

class TradeTabPage extends StatefulWidget {
  final AppDatabase db;
  const TradeTabPage({super.key, required this.db});
  @override
  State<TradeTabPage> createState() => _TradeTabPageState();
}

class _TradeTabPageState extends State<TradeTabPage> {
  Future<void> _deleteRecord(int id) async {
    // 删除操作会自动触发 Stream 更新，UI 会自动刷新
    await (widget.db.delete(
      widget.db.tradeRecords,
    )..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> _navigateToDetail(TradeRecord record) async {
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
        child: TradeRecordDetailPage(db: widget.db, record: record),
      ),
    );
  }

  Future<void> _navigateToAdd() async {
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
        child: TradeRecordAddPage(db: widget.db),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF34B363),
        onPressed: _navigateToAdd,
        shape: const CircleBorder(),
        //elevation: 1, // 关闭阴影，边缘更干净
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      body: StreamBuilder<List<TradeRecord>>(
        stream: widget.db.select(widget.db.tradeRecords).watch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${AppLocalizations.of(context)!.error}: ${snapshot.error}',
              ),
            );
          }
          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.noTradeRecords),
            );
          }
          return ListView.separated(
            itemCount: records.length,
            separatorBuilder: (context, i) => const Divider(
              color: Color(0xFFE0E0E0),
              thickness: 1,
              height: 1,
            ),
            itemBuilder: (context, i) {
              final r = records[i];
              return Dismissible(
                key: ValueKey(r.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  color: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  // 可选：弹窗确认
                  return await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            AppLocalizations.of(
                              context,
                            )!.confirmDeleteDialogTitle,
                          ),
                          content: Text(
                            AppLocalizations.of(
                              context,
                            )!.confirmDeleteDialogContent,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.confirmDeleteDialogCancel,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.confirmDeleteDialogDelete,
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ) ??
                      false;
                },
                onDismissed: (direction) {
                  _deleteRecord(r.id);
                },
                child: ListTile(
                  leading: Icon(
                    r.action == TradeAction.buy
                        ? Icons.add_circle_outline
                        : Icons.remove_circle_outline,
                    color: r.action == TradeAction.buy
                        ? Colors.green
                        : Colors.red,
                    size: 28,
                  ),
                  title: Text(
                    '${r.action.displayName}  ${r.name}(${r.category.displayName})',
                  ),
                  subtitle: Text(
                    '${DateFormat.yMMMd().format(r.tradeDate.toLocal())}   '
                    '${AppLocalizations.of(context)!.tradeTabPageNumber}: ${r.quantity == null ? "-" : NumberFormat.decimalPattern().format(r.quantity)}   '
                    '${AppLocalizations.of(context)!.tradeTabPagePrice}: ${r.price == null ? "-" : NumberFormat.simpleCurrency(name: r.currency.displayName).format(r.price)}',
                  ),
                  onTap: () => _navigateToDetail(r),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
