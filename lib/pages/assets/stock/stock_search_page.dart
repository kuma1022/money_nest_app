import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/pages/trade_history/trade_add_edit_page.dart';
import 'package:money_nest_app/pages/trade_history/trade_history_tab_page.dart';
import 'package:money_nest_app/services/data_sync_service.dart';
import 'package:money_nest_app/util/global_store.dart';
import 'package:money_nest_app/models/trade_type.dart';
import 'package:provider/provider.dart';

class StockSearchPage extends StatefulWidget {
  final String exchange; // 'JP' or 'US'
  final AppDatabase db;

  const StockSearchPage({super.key, required this.exchange, required this.db});

  @override
  State<StockSearchPage> createState() => _StockSearchPageState();
}

class _StockSearchPageState extends State<StockSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Stock> _searchResults = [];
  List<Stock> _holdings = [];
  bool _isLoading = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadHoldings();
  }

  Future<void> _loadHoldings() async {
    final userId = GlobalStore().userId;
    final accountId = GlobalStore().accountId;
    if (userId == null || accountId == null) return;

    // Fetch trade records to calculate holdings (simplified)
    // In a real app, this should be consistent with AssetsTabPage logic
    final records = await (widget.db.select(widget.db.tradeRecords)
          ..where((t) =>
              t.userId.equals(userId) &
              t.accountId.equals(accountId) &
              t.assetType.equals('stock')))
        .get();

    final Map<int, double> quantities = {};
    for (var r in records) {
      if (r.assetId == null) continue;
      double q = r.quantity;
      if (r.action == 'sell') q = -q;
      quantities[r.assetId!] = (quantities[r.assetId!] ?? 0) + q;
    }

    final heldAssetIds =
        quantities.entries.where((e) => e.value > 0.0001).map((e) => e.key).toList();

    if (heldAssetIds.isNotEmpty) {
      final stocks = await (widget.db.select(widget.db.stocks)
            ..where((s) =>
                s.id.isIn(heldAssetIds) & s.exchange.equals(widget.exchange)))
          .get();
      if (mounted) {
        setState(() {
          _holdings = stocks;
        });
      }
    }
  }

  Future<void> _onSearch(String query) async {
    setState(() {
      _query = query;
    });

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dataSync = Provider.of<DataSyncService>(context, listen: false);
      final results = await dataSync.fetchStockSuggestions(
        query,
        widget.exchange, // Position 2 match signature (String exchange)
        // limit is not supported in fetchStockSuggestions signature currently
      );
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      debugPrint('Error searching stocks: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onStockSelected(Stock stock) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TradeAddEditPage(
          db: widget.db,
          mode: 'add',
          type: 'asset',
          initialStock: stock,
          record: TradeRecordDisplay(
            id: 0,
            action: ActionType.buy,
            tradeDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            tradeType: 'general',
            amount: '',
            detail: '',
            assetType: 'stock',
            price: 0.0,
            quantity: 0.0,
            currency: stock.currency,
            feeAmount: 0.0,
            feeCurrency: stock.currency,
            stockInfo: stock,
            remark: '',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _query.isEmpty ? _holdings : _searchResults;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: '銘柄コードまたは社名で検索', // Search by ticker or name
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onChanged: _onSearch,
          autofocus: true,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final stock = displayList[index];
                return ListTile(
                  title: Text(
                    stock.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${stock.ticker} - ${stock.exchange}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: _query.isEmpty // Show icon/badge for holdings
                      ? const Icon(Icons.check_circle, color: Colors.green, size: 16)
                      : null,
                  onTap: () => _onStockSelected(stock),
                );
              },
            ),
    );
  }
}
