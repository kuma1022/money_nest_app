import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/models/trade_action.dart';

class SearchResultList extends StatelessWidget {
  final AppDatabase db;
  final String keyword;
  const SearchResultList({super.key, required this.db, required this.keyword});

  @override
  Widget build(BuildContext context) {
    if (keyword.isEmpty) {
      return Center(child: Text('请输入关键字进行搜索'));
    }
    // 假设你有一个方法 db.searchTradeRecords(keyword)
    return FutureBuilder<List<TradeRecord>>(
      future: db.searchTradeRecords(keyword),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final records = snapshot.data!;
        if (records.isEmpty) {
          return Center(child: Text('没有找到相关记录'));
        }

        return ListView.separated(
          itemCount: records.length,
          separatorBuilder: (context, i) =>
              const Divider(color: Color(0xFFE0E0E0), thickness: 1, height: 1),
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
                //  _deleteRecord(r.id);
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
                  '${r.action.displayName}  ${r.name}(${r.categoryId})',
                ),
                subtitle: Text(
                  '${DateFormat.yMMMd().format(r.tradeDate.toLocal())}   '
                  '${AppLocalizations.of(context)!.tradeTabPageNumber}: ${r.quantity == null ? "-" : NumberFormat.decimalPattern().format(r.quantity)}   '
                  '${AppLocalizations.of(context)!.tradeTabPagePrice}: ${r.price == null ? "-" : NumberFormat.simpleCurrency(name: r.currency.displayName(context)).format(r.price)}',
                ),
                //onTap: () => _navigateToDetail(r),
              ),
            );
          },
        );
      },
    );
  }
}
