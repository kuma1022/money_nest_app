import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:money_nest_app/components/card_section.dart';
import 'package:money_nest_app/pages/trade_history/trade_add_page.dart';
import 'package:money_nest_app/pages/trade_history/trade_detail_page.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:money_nest_app/util/global_store.dart';
import 'package:intl/intl.dart';

class TradeHistoryPage extends StatefulWidget {
  final VoidCallback? onAddPressed;

  const TradeHistoryPage({super.key, this.onAddPressed});

  @override
  State<TradeHistoryPage> createState() => _TradeHistoryPageState();
}

class _TradeHistoryPageState extends State<TradeHistoryPage> {
  final GlobalKey<_TradeRecordListState> _listKey =
      GlobalKey<_TradeRecordListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 顶部栏
              Row(
                children: [
                  const Text(
                    '取引履歴',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      //widget.onAddPressed, // 用回调
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TradeAddPage()),
                      );

                      if (result == true) {
                        // 刷新数据
                        // 调用子组件的刷新方法
                        _listKey.currentState?._fetchRecords();
                      }
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('追加'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 筛选卡片
              CardSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.filter_alt_outlined,
                          size: 18,
                          color: Colors.black54,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'フィルター',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 搜索框
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.appBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: const TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '銘柄名・コードで検索',
                          hintStyle: TextStyle(color: Colors.grey),
                          icon: Icon(Icons.search, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 下拉筛选
                    Row(
                      children: [
                        Expanded(
                          child: _FilterDropdown(
                            items: const ['all', '買い', '売り', '配当'],
                            value: 'all',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _FilterDropdown(
                            items: const [
                              'all',
                              '株式',
                              'FX（為替）',
                              '暗号資産',
                              '貴金属',
                              'その他資産',
                            ],
                            value: 'all',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 日期筛选
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '年 / 月 / 日',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 交易记录列表
              _TradeRecordList(key: _listKey),
            ],
          ),
        ),
      ),
    );
  }
}

// 筛选下拉
class _FilterDropdown extends StatelessWidget {
  final List<String> items;
  final String value;
  const _FilterDropdown({required this.items, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.appBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        isExpanded: true,
        icon: const Icon(Icons.expand_more),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (_) {},
      ),
    );
  }
}

// 交易记录列表
class _TradeRecordList extends StatefulWidget {
  const _TradeRecordList({super.key});

  @override
  State<_TradeRecordList> createState() => _TradeRecordListState();
}

class _TradeRecordListState extends State<_TradeRecordList> {
  List<TradeRecord> records = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    final db = AppDatabase();
    final userId = GlobalStore().userId;
    final accountId = GlobalStore().accountId;

    if (userId == null || accountId == null) {
      setState(() {
        records = [];
        loading = false;
      });
      return;
    }

    // 联合查询 TradeRecords 和 Stocks
    final query =
        db.select(db.tradeRecords).join([
            innerJoin(
              db.stocks,
              db.stocks.id.equalsExp(db.tradeRecords.assetId),
            ),
          ])
          ..where(db.tradeRecords.userId.equals(userId))
          ..where(db.tradeRecords.accountId.equals(accountId))
          ..where(db.tradeRecords.assetType.equals('stock'))
          ..orderBy([OrderingTerm.desc(db.tradeRecords.tradeDate)]);

    final rows = await query.get();

    final formatter = NumberFormat("#,##0.##");

    final result = rows.map((row) {
      final trade = row.readTable(db.tradeRecords);
      final stock = row.readTable(db.stocks);

      // 交易类型
      ActionType type;
      switch (trade.action) {
        case 'buy':
          type = ActionType.buy;
          break;
        case 'sell':
          type = ActionType.sell;
          break;
        case 'dividend':
          type = ActionType.dividend;
          break;
        default:
          type = ActionType.buy;
      }

      // 金额格式
      final currency = stock.currency;
      final stockPrices = GlobalStore().currentStockPrices;
      final amount =
          trade.quantity * trade.price -
          (trade.feeAmount ?? 0) *
              (trade.action == 'sell' ? 1 : -1) *
              (stockPrices['${trade.feeCurrency == 'USD' ? '' : trade.feeCurrency}${stock.currency}=X'] ??
                  1);
      final amountStr =
          '${type == ActionType.dividend ? '+' : ''}${AppUtils().formatMoney(amount, currency)}';

      // 明细
      final detail =
          '${formatter.format(trade.quantity)}株 * ${AppUtils().formatMoney(trade.price, currency)}';

      return TradeRecord(
        type: type,
        code: stock.ticker ?? '',
        name: stock.name,
        date: DateFormat('yyyy-MM-dd').format(trade.tradeDate),
        amount: amountStr,
        price: trade.price,
        quantity: trade.quantity,
        currency: currency,
        feeAmount: trade.feeAmount ?? 0,
        feeCurrency: trade.feeCurrency ?? currency,
        detail: type == ActionType.dividend ? '' : detail,
        exchange: stock.exchange ?? '',
        assetType: trade.assetType,
      );
    }).toList();

    setState(() {
      records = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (records.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text('データがありません')),
      );
    }
    return Column(
      children: records.map((r) => _TradeRecordCard(record: r)).toList(),
    );
  }
}

// 交易记录卡片
class _TradeRecordCard extends StatelessWidget {
  final TradeRecord record;
  const _TradeRecordCard({required this.record});

  Color get typeColor {
    switch (record.type) {
      case ActionType.buy:
        return AppColors.appUpGreen;
      case ActionType.sell:
        return AppColors.appDownRed;
      case ActionType.dividend:
        return AppColors.appBlue;
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

  IconData get typeIcon {
    switch (record.type) {
      case ActionType.buy:
        return Icons.add_outlined;
      case ActionType.sell:
        return Icons.remove_outlined;
      case ActionType.dividend:
        return Icons.card_giftcard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TradeDetailPage(record: record)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E6EA), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(typeIcon, color: typeColor, size: 20),
            ),
            const SizedBox(width: 10),
            // 主要内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        record.code,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                            color: typeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        record.amount,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: record.type == ActionType.dividend
                              ? const Color(0xFF388E3C)
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        record.name,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        record.detail,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    record.date,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 交易记录数据结构
enum ActionType { buy, sell, dividend }

class TradeRecord {
  final ActionType type;
  final String code;
  final String name;
  final String exchange;
  final String date;
  final String amount;
  final String detail;
  final String assetType;
  final double price;
  final double quantity;
  final String currency;
  final double feeAmount;
  final String feeCurrency;
  TradeRecord({
    required this.type,
    required this.code,
    required this.name,
    required this.exchange,
    required this.date,
    required this.amount,
    required this.detail,
    required this.assetType,
    required this.price,
    required this.quantity,
    required this.currency,
    required this.feeAmount,
    required this.feeCurrency,
  });
}
