import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/models/select_buy_record.dart';

class BuyPositionSelector extends StatefulWidget {
  final AppDatabase db;
  final String? selectedCode;
  final List<SelectedBuyRecord> selectedRecords;
  final ValueChanged<String> onCodeSelected;
  const BuyPositionSelector({
    super.key,
    required this.db,
    required this.onCodeSelected,
    this.selectedCode,
    this.selectedRecords = const [],
  });

  @override
  State<BuyPositionSelector> createState() => _BuyPositionSelectorState();
}

class _BuyPositionSelectorState extends State<BuyPositionSelector> {
  final TextEditingController _searchController = TextEditingController();
  List<TradeRecord> _allRecords = [];
  List<TradeRecord> _searchResults = [];
  String? _selectedCode;
  Map<int, double> _selectedBuyQuantities = {}; // key: buyId, value: 卖出数量

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.selectedCode;
    _selectedBuyQuantities = Map<int, double>.from(
      widget.selectedRecords.fold({}, (acc, record) {
        acc[record.record.id] = record.quantity;
        return acc;
      }),
    );
    _loadAllRecords();
  }

  List<T> uniqueByCode<T>(List<T> records, String? Function(T) codeGetter) {
    final Set<String> seenCodes = {};
    final List<T> uniqueRecords = [];
    for (final r in records) {
      final code = codeGetter(r);
      if (code != null && seenCodes.add(code)) {
        uniqueRecords.add(r);
      }
    }
    return uniqueRecords
      ..sort((a, b) => codeGetter(a)!.compareTo(codeGetter(b)!));
  }

  Future<void> _loadAllRecords() async {
    // 查询所有未完全卖出的买入持仓
    final records = await widget.db.getAllAvailableBuyRecords();
    setState(() {
      _allRecords = records;
      _searchResults = uniqueByCode(records, (r) => r.code);
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchResults = uniqueByCode(_allRecords, (r) => r.code)
          .where(
            (r) =>
                (r.name?.contains(value) ?? false) ||
                (r.code?.contains(value) ?? false),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 下拉指示短线
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 0, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 搜索框
            if (_selectedCode == null)
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: AppLocalizations.of(
                    context,
                  )!.buyPositionSelectionPageSearchHint,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                ),
                onChanged: _onSearchChanged,
              ),
            // 搜索结果
            if (_selectedCode == null)
              Expanded(
                child: ListView.separated(
                  itemCount: _searchResults.length,
                  separatorBuilder: (context, i) => const Divider(
                    color: Color(0xFFE0E0E0),
                    thickness: 1,
                    height: 1,
                  ),
                  itemBuilder: (context, i) {
                    final r = _searchResults[i];
                    return ListTile(
                      //dense: true,
                      title: Text(r.name),
                      subtitle: Text('${r.code}'),
                      onTap: () {
                        setState(() {
                          _selectedCode = r.code;
                          widget.onCodeSelected(_selectedCode!);
                        });
                      },
                    );
                  },
                ),
              ),
            // 买入记录多选+数量
            if (_selectedCode != null)
              Expanded(
                child: FutureBuilder<List<TradeRecord>>(
                  future: widget.db.getAvailableBuyRecordsByCode(
                    _selectedCode!,
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final buyRecords = snapshot.data!;

                    // 交易时间降序
                    buyRecords.sort((a, b) {
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

                      // 代码升序
                      return (a.code ?? '').compareTo(b.code ?? '');
                    });

                    // 按日期（不含时分秒）分组
                    final Map<String, List<TradeRecord>> grouped =
                        SplayTreeMap<String, List<TradeRecord>>(
                          (a, b) => a.compareTo(b), // 保证日期升序
                        );
                    for (final r in buyRecords) {
                      final dateKey = DateFormat(
                        'yyyy-MM-dd',
                      ).format(r.tradeDate.toLocal());
                      grouped.putIfAbsent(dateKey, () => []).add(r);
                    }

                    // 构建分组后的列表
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
                            color: const Color(0xFFE0E0E0), // 背景色与title一致
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
                          final buy = item.record!;
                          final selected = _selectedBuyQuantities.containsKey(
                            buy.id,
                          );
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0,
                            ), // 左右都为0右侧正常
                            leading: Checkbox(
                              value: selected,
                              onChanged: (v) {
                                setState(() {
                                  if (v == true) {
                                    _selectedBuyQuantities[buy.id] =
                                        buy.quantity ?? 0;
                                  } else {
                                    _selectedBuyQuantities.remove(buy.id);
                                  }
                                });
                              },
                            ),
                            title: Text(
                              '${buy.name}(${buy.categoryId})  ${buy.code}',
                              style: const TextStyle(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              // 数量和价格，靠右显示
                              '${AppLocalizations.of(context)!.tradeTabPageNumber}: ${buy.quantity == null ? "-" : NumberFormat.decimalPattern().format(buy.quantity)}   '
                              '${AppLocalizations.of(context)!.tradeTabPagePrice}: ${buy.price == null ? "-" : NumberFormat.simpleCurrency(name: buy.currency.displayName(context)).format(buy.price)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            trailing: selected
                                ? IntrinsicWidth(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove,
                                            size: 20,
                                          ),
                                          onPressed:
                                              (_selectedBuyQuantities[buy.id]
                                                          ?.toInt() ??
                                                      1) <=
                                                  1
                                              ? null
                                              : () {
                                                  setState(() {
                                                    final current =
                                                        _selectedBuyQuantities[buy
                                                            .id] ??
                                                        1;
                                                    if (current > 1) {
                                                      _selectedBuyQuantities[buy
                                                              .id] =
                                                          current - 1;
                                                    }
                                                  });
                                                },
                                          constraints: const BoxConstraints(
                                            maxWidth: 32,
                                          ), // 限制按钮宽度
                                          padding: EdgeInsets.zero,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: Text(
                                            '${_selectedBuyQuantities[buy.id]?.toInt() ?? 1}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add, size: 20),
                                          onPressed:
                                              (_selectedBuyQuantities[buy.id]
                                                          ?.toInt() ??
                                                      1) >=
                                                  (buy.quantity?.toInt() ?? 1)
                                              ? null
                                              : () {
                                                  setState(() {
                                                    final current =
                                                        _selectedBuyQuantities[buy
                                                            .id] ??
                                                        1;
                                                    final max =
                                                        buy.quantity?.toInt() ??
                                                        1;
                                                    if (current < max) {
                                                      _selectedBuyQuantities[buy
                                                              .id] =
                                                          current + 1;
                                                    }
                                                  });
                                                },
                                          constraints: const BoxConstraints(
                                            maxWidth: 32,
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                  )
                                : null,
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            // 确认按钮
            if (_selectedCode != null)
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Color(0xFF34B363),
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                      ),
                      padding: WidgetStatePropertyAll(
                        EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                    onPressed: () {
                      final selected = _selectedBuyQuantities.entries
                          .where((e) => e.value > 0)
                          .map(
                            (e) => SelectedBuyRecord(
                              _allRecords.firstWhere((r) => r.id == e.key),
                              e.value,
                            ),
                          )
                          .toList();
                      Navigator.pop(context, selected);
                    },
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!.buyPositionSelectionPageConfirm,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            // 增加间距
            if (_selectedCode != null) const SizedBox(height: 8),
            // 返回搜索按钮
            if (_selectedCode != null)
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Align(
                    alignment: Alignment.center, // 或 Alignment.center
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCode = null;
                          _selectedBuyQuantities.clear();
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero, // 去除按钮自带的内边距
                        minimumSize: Size(0, 0), // 去除最小尺寸限制
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.buyPositionSelectionPageBackToSearch,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF34B363),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
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
