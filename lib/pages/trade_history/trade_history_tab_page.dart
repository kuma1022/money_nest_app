import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:money_nest_app/components/card_section.dart';
import 'package:money_nest_app/pages/trade_history/trade_add_edit_page.dart';
import 'package:money_nest_app/pages/trade_history/trade_detail_page.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:money_nest_app/util/global_store.dart';
import 'package:intl/intl.dart';

class TradeHistoryPage extends StatefulWidget {
  final VoidCallback? onAddPressed;
  final AppDatabase db;

  const TradeHistoryPage({super.key, this.onAddPressed, required this.db});

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
                        MaterialPageRoute(
                          builder: (_) => TradeAddEditPage(
                            db: widget.db,
                            mode: 'add',
                            type: 'asset',
                            record: TradeRecordDisplay(
                              id: 0,
                              action: ActionType.buy,
                              tradeDate: '',
                              tradeType: '',
                              amount: '',
                              detail: '',
                              assetType: '',
                              price: 0.0,
                              quantity: 0.0,
                              currency: '',
                              feeAmount: 0.0,
                              feeCurrency: '',
                              remark: '',
                              stockInfo: Stock(
                                id: 0,
                                name: '',
                                nameUs: '',
                                exchange: 'JP',
                                logo: '',
                                currency: '',
                                country: '',
                                status: '',
                              ),
                            ),
                          ),
                        ),
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
              _TradeRecordList(db: widget.db, key: _listKey),
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
  final AppDatabase db;

  const _TradeRecordList({required this.db, super.key});

  @override
  State<_TradeRecordList> createState() => _TradeRecordListState();
}

class _TradeRecordListState extends State<_TradeRecordList> {
  List<TradeRecordDisplay> records = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    print('Fetching trade records...');
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
      ActionType action;
      switch (trade.action) {
        case 'buy':
          action = ActionType.buy;
          break;
        case 'sell':
          action = ActionType.sell;
          break;
        case 'dividend':
          action = ActionType.dividend;
          break;
        default:
          action = ActionType.buy;
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
          '${action == ActionType.dividend ? '+' : ''}${AppUtils().formatMoney(amount, currency)}';

      // 明细
      final detail =
          '${formatter.format(trade.quantity)}株 * ${AppUtils().formatMoney(trade.price, currency)}';

      return TradeRecordDisplay(
        id: trade.id,
        action: action,
        tradeDate: DateFormat('yyyy-MM-dd').format(trade.tradeDate),
        tradeType: trade.tradeType ?? '',
        amount: amountStr,
        price: trade.price,
        quantity: trade.quantity,
        currency: currency,
        feeAmount: trade.feeAmount ?? 0,
        feeCurrency: trade.feeCurrency ?? currency,
        remark: trade.remark ?? '',
        detail: action == ActionType.dividend ? '' : detail,
        assetType: trade.assetType,
        stockInfo: stock,
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
      children: records.map((r) => buildTradeRecordCard(r)).toList(),
    );
  }

  Widget buildTradeRecordCard(TradeRecordDisplay record) {
    final typeColor = {
      ActionType.buy: AppColors.appUpGreen,
      ActionType.sell: AppColors.appDownRed,
      ActionType.dividend: AppColors.appBlue,
    };
    final typeLabel = {
      ActionType.buy: '買い',
      ActionType.sell: '売り',
      ActionType.dividend: '配当',
    };
    final typeIcon = {
      ActionType.buy: Icons.add_outlined,
      ActionType.sell: Icons.remove_outlined,
      ActionType.dividend: Icons.card_giftcard,
    };

    return GestureDetector(
      onTap: () async {
        // 用回调
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TradeDetailPage(db: widget.db, record: record),
          ),
        );
        print('Returned from TradeDetailPage with result: $result');

        if (result == true) {
          // 刷新数据
          // 调用子组件的刷新方法
          _fetchRecords();
        }
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
                color: typeColor[record.action]?.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                typeIcon[record.action],
                color: typeColor[record.action],
                size: 20,
              ),
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
                        record.stockInfo.ticker ?? '',
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
                          color: typeColor[record.action]?.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          typeLabel[record.action]!,
                          style: TextStyle(
                            color: typeColor[record.action],
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
                          color: record.action == ActionType.dividend
                              ? const Color(0xFF388E3C)
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          record.stockInfo.name,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        record.detail,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                  Text(
                    record.tradeDate,
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

class TradeRecordDisplay {
  final int id;
  final ActionType action;
  final String tradeDate;
  final String tradeType;
  final String amount;
  final String detail;
  final String assetType;
  final double price;
  final double quantity;
  final String currency;
  final double feeAmount;
  final String feeCurrency;
  final String remark;
  final Stock stockInfo;
  TradeRecordDisplay({
    required this.id,
    required this.action,
    required this.tradeDate,
    required this.tradeType,
    required this.amount,
    required this.detail,
    required this.assetType,
    required this.price,
    required this.quantity,
    required this.currency,
    required this.feeAmount,
    required this.feeCurrency,
    required this.remark,
    required this.stockInfo,
  });
}
