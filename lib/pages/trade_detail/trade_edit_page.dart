import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/models/trade_action.dart';
import 'package:money_nest_app/models/trade_category.dart';
import 'package:money_nest_app/models/trade_type.dart';

class TradeRecordEditPage extends StatefulWidget {
  final AppDatabase db;
  final TradeRecord record;

  const TradeRecordEditPage({
    super.key,
    required this.db,
    required this.record,
  });

  @override
  State<TradeRecordEditPage> createState() => _TradeRecordEditPageState();
}

class _TradeRecordEditPageState extends State<TradeRecordEditPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _tradeDate;
  late TradeAction? _action;
  TradeCategory? _category;
  TradeType? _tradeType;
  late String _name;
  String? _code;
  double? _quantity;
  Currency? _currency;
  double? _price;
  double? _rate;
  String? _remark;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _tradeDate = r.tradeDate;
    _action = r.action;
    _category = r.category;
    _tradeType = r.tradeType;
    _name = r.name;
    _code = r.code;
    _quantity = r.quantity;
    _currency = r.currency;
    _price = r.price;
    _rate = r.rate;
    _remark = r.remark;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final updated = TradeRecordsCompanion(
      id: Value(widget.record.id),
      tradeDate: Value(_tradeDate),
      action: Value(_action!),
      category: Value(_category!),
      tradeType: Value(_tradeType!),
      name: Value(_name),
      code: Value(_code),
      quantity: Value(_quantity),
      currency: Value(_currency!),
      price: Value(_price),
      rate: Value(_rate),
      remark: Value(_remark),
    );

    await widget.db.update(widget.db.tradeRecords).replace(updated);
    if (mounted) closeToListPage(context);

    //Navigator.pop(context, true);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _tradeDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _tradeDate = date);
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
        title: Text(AppLocalizations.of(context)!.tradeEditPageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => closeToListPage(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.tradeEditPageTradeDateLabel,
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text(_tradeDate.toLocal().toString().split(' ')[0]),
                  ),
                ],
              ),
              DropdownButtonFormField<TradeAction>(
                value: _action,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(
                    context,
                  )!.tradeEditPageActionLabel,
                ),
                items: TradeAction.values
                    .map(
                      (a) => DropdownMenuItem(
                        value: a,
                        child: Text(a.displayName(context)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _action = v),
                validator: (v) => v == null
                    ? AppLocalizations.of(context)!.tradeEditPageActionError
                    : null,
                selectedItemBuilder: (context) => TradeAction.values
                    .map((a) => Text(a.displayName(context)))
                    .toList(),
              ),
              DropdownButtonFormField<TradeCategory>(
                value: _category,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(
                    context,
                  )!.tradeEditPageCategoryLabel,
                ),
                items: TradeCategory.values
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _category = v),
                validator: (v) => v == null
                    ? AppLocalizations.of(context)!.tradeEditPageCategoryError
                    : null,
                selectedItemBuilder: (context) => TradeCategory.values
                    .map((c) => Text(c.displayName))
                    .toList(),
              ),
              DropdownButtonFormField<TradeType>(
                value: _tradeType,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(
                    context,
                  )!.tradeEditPageTypeLabel,
                ),
                items: TradeType.values
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _tradeType = v),
                validator: (v) => v == null
                    ? AppLocalizations.of(context)!.tradeEditPageTypeError
                    : null,
                selectedItemBuilder: (context) =>
                    TradeType.values.map((c) => Text(c.displayName)).toList(),
              ),
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(
                    context,
                  )!.tradeEditPageNameLabel,
                ),
                onSaved: (v) => _name = v ?? '',
                validator: (v) => v == null || v.isEmpty
                    ? AppLocalizations.of(context)!.tradeEditPageNameError
                    : null,
              ),
              TextFormField(
                initialValue: _code,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(
                    context,
                  )!.tradeEditPageCodeLabel,
                ),
                onSaved: (v) => _code = v,
              ),
              TextFormField(
                initialValue: _quantity?.toString(),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(
                    context,
                  )!.tradeEditPageQuantityLabel,
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSaved: (v) => _quantity = v != null && v.isNotEmpty
                    ? double.tryParse(v)
                    : null,
              ),
              DropdownButtonFormField<Currency>(
                value: _currency,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(
                    context,
                  )!.tradeEditPageCurrencyLabel,
                ),
                items: Currency.values
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.displayName(context)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _currency = v),
                validator: (v) => v == null
                    ? AppLocalizations.of(context)!.tradeEditPageCurrencyError
                    : null,
                selectedItemBuilder: (context) => Currency.values
                    .map((c) => Text(c.displayName(context)))
                    .toList(),
              ),
              TextFormField(
                initialValue: _price?.toString(),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(
                    context,
                  )!.tradeEditPagePriceLabel,
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSaved: (v) => _price = v != null && v.isNotEmpty
                    ? double.tryParse(v)
                    : null,
              ),
              TextFormField(
                initialValue: _rate?.toString(),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(
                    context,
                  )!.tradeEditPageRateLabel,
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSaved: (v) => _rate = v != null && v.isNotEmpty
                    ? double.tryParse(v)
                    : null,
              ),
              TextFormField(
                initialValue: _remark,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(
                    context,
                  )!.tradeEditPageRemarkLabel,
                ),
                onSaved: (v) => _remark = v,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: Text(
                  AppLocalizations.of(context)!.tradeEditPageSaveLabel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
