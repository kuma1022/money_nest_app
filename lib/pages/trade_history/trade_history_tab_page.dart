import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:money_nest_app/components/card_section.dart';
import 'package:money_nest_app/components/floating_button.dart';
import 'package:money_nest_app/pages/trade_history/trade_add_edit_page.dart';
import 'package:money_nest_app/pages/trade_history/trade_detail_page.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:money_nest_app/util/global_store.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TradeHistoryPage extends StatefulWidget {
  final VoidCallback? onAddPressed;
  final ValueChanged<double>? onScroll;
  final ScrollController? scrollController;
  final AppDatabase db;

  const TradeHistoryPage({
    super.key,
    this.onAddPressed,
    this.onScroll,
    this.scrollController,
    required this.db,
  });

  @override
  State<TradeHistoryPage> createState() => TradeHistoryPageState();
}

class TradeHistoryPageState extends State<TradeHistoryPage> {
  final RefreshController _refreshController = RefreshController();
  RefreshController get refreshController => _refreshController;
  List<TradeRecordDisplay> records = [];
  bool _isInitializing = false; // 添加初始化状态

  // 异步初始化数据的方法
  Future<void> _initializeData() async {
    await _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    print('TradeHistoryTabPage: _fetchRecords()');

    setState(() {
      _isInitializing = true;
    });

    final db = widget.db;
    final userId = GlobalStore().userId;
    final accountId = GlobalStore().accountId;

    if (userId == null || accountId == null) {
      setState(() {
        records = [];
        _isInitializing = false;
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
      _isInitializing = false;
    });
  }

  // 手动刷新数据
  Future<void> onRefresh() async {
    await _initializeData();
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  double pixels = 0.0;
                  if (notification is ScrollUpdateNotification ||
                      notification is OverscrollNotification) {
                    pixels = notification.metrics.pixels;
                    if (pixels < 0) pixels = 0;
                    widget.onScroll?.call(pixels);
                  }
                  return false;
                },
                child: SmartRefresher(
                  controller: _refreshController,
                  onRefresh: onRefresh,
                  header: const WaterDropHeader(waterDropColor: Colors.grey),
                  child: SingleChildScrollView(
                    controller: widget.scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 60),
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () => Navigator.maybePop(context),
                            ),
                            const Text(
                              'Trade History',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF1C1C1E),
                              ),
                              child: const Icon(
                                Icons.filter_list, // Filter icon
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Search Bar (Optional, can be integrated into filter)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1E),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const TextField(
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              icon: Icon(Icons.search, color: Colors.grey),
                              hintText: 'Search by ticker or name',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Date Header (Example, assuming grouped by date or just a list)
                        const Text(
                          'Transactions',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // 交易记录列表
                        if (records.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 60),
                            child: Center(
                                child: Text('No transactions found',
                                    style: TextStyle(color: Colors.grey))),
                          ),
                        if (records.isNotEmpty)
                          Column(
                            children: records
                                .map((r) => buildTradeRecordCard(r))
                                .toList(),
                          ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // 全屏加载层
            if (_isInitializing)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            // 浮动追加按钮
            Positioned(
              right: 16,
              bottom: 16 + bottomPadding + 40,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () async {
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
                    await onRefresh();
                  }
                },
                child: const Icon(Icons.add, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTradeRecordCard(TradeRecordDisplay record) {
    final typeColor = {
      ActionType.buy: AppColors.appUpGreen,
      ActionType.sell: AppColors.appDownRed,
      ActionType.dividend: AppColors.appBlue,
    };
    final typeLabel = {
      ActionType.buy: 'Buy',
      ActionType.sell: 'Sell',
      ActionType.dividend: 'Dividend',
    };
    // Icons
    // buy: arrow down left (incoming asset?) or simple arrow
    // sell: arrow up right
    // or keep simple circle icons

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TradeDetailPage(db: widget.db, record: record),
          ),
        );

        if (result == true) {
          await onRefresh();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (typeColor[record.action] ?? Colors.grey).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                record.action == ActionType.buy
                    ? Icons.south_west
                    : record.action == ActionType.sell
                        ? Icons.north_east
                        : Icons.savings,
                color: typeColor[record.action],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.stockInfo.ticker ?? record.stockInfo.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        typeLabel[record.action]!,
                        style: TextStyle(
                          color: typeColor[record.action],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('yyyy-MM-dd')
                            .format(DateTime.parse(record.tradeDate)),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  record.amount,
                  style: TextStyle(
                    color: record.action == ActionType.buy
                        ? Colors.white
                        : record.action == ActionType.sell
                            ? AppColors.appDownRed
                            : AppColors.appUpGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                 '${record.quantity} @ ${record.price}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
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
