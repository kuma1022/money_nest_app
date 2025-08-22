// trade_tab_page.dart
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:money_nest_app/l10n/l10n_util.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/util/provider/buy_records_provider.dart';
import 'package:money_nest_app/util/provider/market_data_provider.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/models/trade_action.dart';
import 'package:money_nest_app/pages/trade_detail/trade_add/trade_add_page.dart';
import 'package:money_nest_app/pages/trade_detail/trade_detail_page.dart';
import 'package:money_nest_app/util/provider/stocks_provider.dart';
import 'package:provider/provider.dart';

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

    if (!mounted) return; // 添加mounted判断
    context.read<BuyRecordsProvider>().loadRecords();
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
    final marketDataList = context.watch<MarketDataProvider>().marketData;
    final stocks = context.watch<StocksProvider>().stocks;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.appGreen,
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

          // 1. 交易时间降序
          records.sort((a, b) {
            final aDate = DateTime(
              a.tradeDate.year,
              a.tradeDate.month,
              a.tradeDate.day,
            );
            final bDate = DateTime(
              b.tradeDate.year,
              b.tradeDate.month,
              b.tradeDate.day,
            );
            final dateComparison = bDate.compareTo(aDate);
            if (dateComparison != 0) return dateComparison;

            // 动作（买入排前，卖出排后）
            final actionComparison = a.action.index.compareTo(b.action.index);
            if (actionComparison != 0) return actionComparison;

            // 代码升序
            return a.code.compareTo(b.code);
          });

          // 2. 按日期（不含时分秒）分组
          final Map<String, List<TradeRecord>> grouped =
              SplayTreeMap<String, List<TradeRecord>>(
                (a, b) => b.compareTo(a), // 保证日期降序
              );
          for (final r in records) {
            final dateKey = DateFormat(
              'yyyy-MM-dd',
            ).format(r.tradeDate.toLocal());
            grouped.putIfAbsent(dateKey, () => []).add(r);
          }

          // 3. 构建分组后的列表
          final List<_GroupItem> items = [];
          grouped.forEach((date, list) {
            items.add(_GroupItem.header(date));
            for (final r in list) {
              items.add(_GroupItem.record(r));
            }
          });

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, i) => const Divider(
              color: Color(0xFFE0E0E0),
              thickness: 1,
              height: 1,
            ),
            itemBuilder: (context, i) {
              final item = items[i];
              if (item.isHeader) {
                return Container(
                  color: const Color(0xFFF2F2F2), // 背景色与title一致
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 16,
                  ),
                  child: Text(
                    // 按当前手机时区格式，带星期
                    '${DateFormat.yMMMd().format(DateTime.parse(item.date!).toLocal())} '
                    '(${DateFormat.E().format(DateTime.parse(item.date!).toLocal())})',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  ),
                );
              } else {
                final r = item.record!;
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
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.confirmDeleteDialogCancel,
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.confirmDeleteDialogDelete,
                                  style: const TextStyle(color: Colors.red),
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
                    dense: true,
                    leading: Icon(
                      r.action == TradeAction.buy
                          ? Icons.add_circle_outline
                          : Icons.remove_circle_outline,
                      color: r.action == TradeAction.buy
                          ? Colors.green
                          : Colors.red,
                      size: 28,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${r.action.displayName(context)}  '
                            '${stocks.firstWhere((s) => s.code == r.code).name}'
                            '(${getL10nString(context, marketDataList.firstWhere((m) => m.code == r.marketCode).name)})',
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          // 数量和价格，靠右显示
                          '${AppLocalizations.of(context)!.tradeTabPageNumber}: ${NumberFormat.decimalPattern().format(r.quantity)}   '
                          '${AppLocalizations.of(context)!.tradeTabPagePrice}: ${NumberFormat.simpleCurrency(name: r.currency.displayName(context)).format(r.price)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                    onTap: () => _navigateToDetail(r),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

// 辅助类用于分组
class _GroupItem {
  final String? date;
  final TradeRecord? record;
  final bool isHeader;
  _GroupItem.header(this.date) : record = null, isHeader = true;
  _GroupItem.record(this.record) : date = null, isHeader = false;
}
