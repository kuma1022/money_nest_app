import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/models/trade_action.dart';
import 'package:money_nest_app/models/trade_category.dart';
import 'package:money_nest_app/models/trade_type.dart';
import 'package:money_nest_app/models/currency.dart';

class TradeRecordAddPage extends StatefulWidget {
  final AppDatabase db;
  const TradeRecordAddPage({super.key, required this.db});

  @override
  State<TradeRecordAddPage> createState() => _TradeRecordAddPageState();
}

class _TradeRecordAddPageState extends State<TradeRecordAddPage>
    with SingleTickerProviderStateMixin {
  final _buyFormKey = GlobalKey<FormState>();
  final _sellFormKey = GlobalKey<FormState>();
  late TabController _tabController;

  // 买入tab的输入内容
  DateTime? _buyTradeDate;
  TradeCategory? _buyCategory;
  TradeType? _buyTradeType;
  Currency? _buyCurrency;
  final _buyNameController = TextEditingController();
  final _buyCodeController = TextEditingController();
  final _buyQuantityController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _buyRateController = TextEditingController();
  final _buyRemarkController = TextEditingController();

  // 卖出tab的输入内容
  DateTime? _sellTradeDate;
  TradeCategory? _sellCategory;
  TradeType? _sellTradeType;
  Currency? _sellCurrency;
  final _sellNameController = TextEditingController();
  final _sellCodeController = TextEditingController();
  final _sellQuantityController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _sellRateController = TextEditingController();
  final _sellRemarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _buyTradeDate = DateTime.now();
    _sellTradeDate = DateTime.now();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _buyNameController.dispose();
    _buyCodeController.dispose();
    _buyQuantityController.dispose();
    _buyPriceController.dispose();
    _buyRateController.dispose();
    _buyRemarkController.dispose();
    _sellNameController.dispose();
    _sellCodeController.dispose();
    _sellQuantityController.dispose();
    _sellPriceController.dispose();
    _sellRateController.dispose();
    _sellRemarkController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isBuy) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isBuy
          ? (_buyTradeDate ?? DateTime.now())
          : (_sellTradeDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        if (isBuy) {
          _buyTradeDate = date;
        } else {
          _sellTradeDate = date;
        }
      });
    }
  }

  Future<void> _save() async {
    final isBuy = _tabController.index == 0;
    final formKey = isBuy ? _buyFormKey : _sellFormKey;
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();

    final newRecord = TradeRecordsCompanion(
      tradeDate: Value(isBuy ? _buyTradeDate! : _sellTradeDate!),
      action: Value(isBuy ? TradeAction.buy : TradeAction.sell),
      category: Value(isBuy ? _buyCategory! : _sellCategory!),
      tradeType: Value(isBuy ? _buyTradeType! : _sellTradeType!),
      currency: Value(isBuy ? _buyCurrency! : _sellCurrency!),
      name: Value(isBuy ? _buyNameController.text : _sellNameController.text),
      code: Value(isBuy ? _buyCodeController.text : _sellCodeController.text),
      quantity: Value(
        isBuy
            ? double.tryParse(_buyQuantityController.text)
            : double.tryParse(_sellQuantityController.text),
      ),
      price: Value(
        isBuy
            ? double.tryParse(_buyPriceController.text)
            : double.tryParse(_sellPriceController.text),
      ),
      rate: Value(
        isBuy
            ? double.tryParse(_buyRateController.text)
            : double.tryParse(_sellRateController.text),
      ),
      remark: Value(
        isBuy ? _buyRemarkController.text : _sellRemarkController.text,
      ),
    );

    await widget.db.into(widget.db.tradeRecords).insert(newRecord);
    if (mounted) Navigator.pop(context, true);
  }

  void closeToListPage(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(); // 先关闭 edit
      // 再判断还能不能 pop
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // 再关闭 detail
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.tradeAddPageTitle,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => closeToListPage(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.tradeAddPageBuyTab),
            Tab(text: AppLocalizations.of(context)!.tradeAddPageSellTab),
          ],
          labelColor: const Color(0xFF34B363),
          unselectedLabelColor: Colors.grey,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(width: 3.0, color: Color(0xFF34B363)),
            insets: EdgeInsets.zero,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildForm(context, true), _buildForm(context, false)],
      ),
    );
  }

  Widget _buildForm(BuildContext context, bool isBuy) {
    final formKey = isBuy ? _buyFormKey : _sellFormKey;
    final tradeDate = isBuy ? _buyTradeDate : _sellTradeDate;
    final category = isBuy ? _buyCategory : _sellCategory;
    final tradeType = isBuy ? _buyTradeType : _sellTradeType;
    final currency = isBuy ? _buyCurrency : _sellCurrency;
    final nameController = isBuy ? _buyNameController : _sellNameController;
    final codeController = isBuy ? _buyCodeController : _sellCodeController;
    final quantityController = isBuy
        ? _buyQuantityController
        : _sellQuantityController;
    final priceController = isBuy ? _buyPriceController : _sellPriceController;
    final rateController = isBuy ? _buyRateController : _sellRateController;
    final remarkController = isBuy
        ? _buyRemarkController
        : _sellRemarkController;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            // 交易时间
            Row(
              children: [
                Text(AppLocalizations.of(context)!.tradeAddPageTradeDateLabel),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _pickDate(isBuy),
                  child: Text(
                    tradeDate != null
                        ? tradeDate.toLocal().toString().split(' ')[0]
                        : AppLocalizations.of(
                            context,
                          )!.tradeAddPageTradeDatePlaceholder,
                  ),
                ),
              ],
            ),
            DropdownButtonFormField<TradeCategory>(
              value: category,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(
                  context,
                )!.tradeAddPageCategoryLabel,
              ),
              items: TradeCategory.values
                  .map(
                    (c) =>
                        DropdownMenuItem(value: c, child: Text(c.displayName)),
                  )
                  .toList(),
              onChanged: (v) => setState(() {
                if (isBuy) {
                  _buyCategory = v;
                } else {
                  _sellCategory = v;
                }
              }),
              validator: (v) => v == null
                  ? AppLocalizations.of(context)!.tradeAddPageCategoryError
                  : null,
              selectedItemBuilder: (context) =>
                  TradeCategory.values.map((c) => Text(c.displayName)).toList(),
            ),
            DropdownButtonFormField<TradeType>(
              value: tradeType,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.tradeAddPageTypeLabel,
              ),
              items: TradeType.values
                  .map(
                    (t) =>
                        DropdownMenuItem(value: t, child: Text(t.displayName)),
                  )
                  .toList(),
              onChanged: (v) => setState(() {
                if (isBuy) {
                  _buyTradeType = v;
                } else {
                  _sellTradeType = v;
                }
              }),
              validator: (v) => v == null
                  ? AppLocalizations.of(context)!.tradeAddPageTypeError
                  : null,
              selectedItemBuilder: (context) =>
                  TradeType.values.map((t) => Text(t.displayName)).toList(),
            ),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.tradeAddPageNameLabel,
              ),
              validator: (v) => v == null || v.isEmpty
                  ? AppLocalizations.of(context)!.tradeAddPageNameError
                  : null,
            ),
            TextFormField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.tradeAddPageCodeLabel,
              ),
            ),
            TextFormField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(
                  context,
                )!.tradeAddPageQuantityLabel,
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (v) => v == null || v.isEmpty
                  ? AppLocalizations.of(context)!.tradeAddPageQuantityError
                  : null,
            ),
            DropdownButtonFormField<Currency>(
              value: currency,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(
                  context,
                )!.tradeAddPageCurrencyLabel,
              ),
              items: Currency.values
                  .map(
                    (c) =>
                        DropdownMenuItem(value: c, child: Text(c.displayName)),
                  )
                  .toList(),
              onChanged: (v) => setState(() {
                if (isBuy) {
                  _buyCurrency = v;
                } else {
                  _sellCurrency = v;
                }
              }),
              validator: (v) => v == null
                  ? AppLocalizations.of(context)!.tradeAddPageCurrencyError
                  : null,
              selectedItemBuilder: (context) =>
                  Currency.values.map((c) => Text(c.displayName)).toList(),
            ),
            TextFormField(
              controller: priceController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.tradeAddPagePriceLabel,
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (v) => v == null || v.isEmpty
                  ? AppLocalizations.of(context)!.tradeAddPagePriceError
                  : null,
            ),
            TextFormField(
              controller: rateController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.tradeAddPageRateLabel,
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (v) => v == null || v.isEmpty
                  ? AppLocalizations.of(context)!.tradeAddPageRateError
                  : null,
            ),
            TextFormField(
              controller: remarkController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(
                  context,
                )!.tradeAddPageRemarkLabel,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Color(0xFF34B363)),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                    ),
                    padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                  onPressed: _save,
                  child: Text(
                    AppLocalizations.of(context)!.tradeAddPageSaveLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      //fontWeight: FontWeight.bold,
                      color: Colors.white,
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
