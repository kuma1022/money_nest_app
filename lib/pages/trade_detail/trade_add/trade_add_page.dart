import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/models/select_buy_record.dart';
import 'package:money_nest_app/models/trade_action.dart';
import 'package:money_nest_app/models/trade_category.dart';
import 'package:money_nest_app/models/trade_type.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/pages/trade_detail/trade_add/buy_position_selector_page.dart';

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

  // 卖出tab新增变量
  List<SelectedBuyRecord> _selectedBuyRecords = [];
  String? _selectedCode;

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
    DateTime initialDate = isBuy
        ? (_buyTradeDate ?? DateTime.now())
        : (_sellTradeDate ?? DateTime.now());
    DateTime? pickedDate = initialDate;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 200,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initialDate,
                    minimumDate: DateTime(2000),
                    maximumDate: DateTime(2100),
                    onDateTimeChanged: (date) {
                      pickedDate = date;
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        AppLocalizations.of(context)!.tradeAddPageCancelLabel,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(pickedDate);
                      },
                      child: Text(
                        AppLocalizations.of(context)!.tradeAddPageConfirmLabel,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((date) {
      if (date != null && date is DateTime) {
        setState(() {
          if (isBuy) {
            _buyTradeDate = date;
          } else {
            _sellTradeDate = date;
          }
        });
      }
    });
  }

  Future<void> _selectBuyPositions() async {
    final selected = await showModalBottomSheet<List<SelectedBuyRecord>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.7,
        child: BuyPositionSelector(
          db: widget.db,
          onCodeSelected: (code) {
            setState(() {
              _selectedCode = code;
            });
          },
          selectedCode: _selectedCode,
          selectedRecords: _selectedBuyRecords,
        ),
      ),
    );
    if (selected != null) {
      setState(() {
        _selectedBuyRecords = selected;
      });
    }
  }

  Future<T?> showPickerSheet<T>({
    required BuildContext context,
    required List<T> options,
    required T? selected,
    required String Function(T) display,
  }) async {
    int initialIndex = selected != null ? options.indexOf(selected) : 0;
    T? picked = selected ?? options.first;
    return await showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: 250,
            child: Column(
              children: [
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: initialIndex,
                    ),
                    itemExtent: 36,
                    onSelectedItemChanged: (i) {
                      picked = options[i];
                    },
                    children: options
                        .map((e) => Center(child: Text(display(e))))
                        .toList(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        AppLocalizations.of(context)!.tradeAddPageCancelLabel,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(picked),
                      child: Text(
                        AppLocalizations.of(context)!.tradeAddPageConfirmLabel,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    final isBuy = _tabController.index == 0;
    final formKey = isBuy ? _buyFormKey : _sellFormKey;
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();

    if (isBuy) {
      // 买入逻辑不变
      final newRecord = TradeRecordsCompanion(
        tradeDate: Value(_buyTradeDate!),
        action: Value(TradeAction.buy),
        category: Value(_buyCategory!),
        tradeType: Value(_buyTradeType!),
        currency: Value(_buyCurrency!),
        name: Value(_buyNameController.text),
        code: Value(_buyCodeController.text),
        quantity: Value(double.tryParse(_buyQuantityController.text)),
        price: Value(double.tryParse(_buyPriceController.text)),
        rate: Value(double.tryParse(_buyRateController.text)),
        remark: Value(_buyRemarkController.text),
      );
      await widget.db.into(widget.db.tradeRecords).insert(newRecord);
      if (mounted) Navigator.pop(context, true);
      return;
    }

    // 卖出逻辑：每个选中的买入记录都生成一条卖出记录
    for (final buy in _selectedBuyRecords) {
      final sellRecord = TradeRecordsCompanion(
        tradeDate: Value(_sellTradeDate!),
        action: Value(TradeAction.sell),
        category: Value(buy.record.category), // 用买入记录的类别
        tradeType: Value(buy.record.tradeType), // 用买入记录的类型
        currency: Value(_sellCurrency!), // 卖出币种用表单设定
        name: Value(buy.record.name), // 用买入记录的名称
        code: Value(buy.record.code), // 用买入记录的代码
        quantity: Value(buy.quantity), // 卖出数量
        price: Value(double.tryParse(_sellPriceController.text)),
        rate: Value(double.tryParse(_sellRateController.text)),
        remark: Value(_sellRemarkController.text),
      );
      final sellId = await widget.db
          .into(widget.db.tradeRecords)
          .insert(sellRecord);

      // 保存买入和卖出的mapping
      await widget.db
          .into(widget.db.tradeSellMappings)
          .insert(
            TradeSellMappingsCompanion(
              buyId: Value(buy.record.id),
              sellId: Value(sellId),
              quantity: Value(buy.quantity),
            ),
          );
    }

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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              // 卖出tab新增选择持仓按钮
              if (!isBuy && _selectedBuyRecords.isEmpty)
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
                      onPressed: _selectBuyPositions,
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.tradeAddPageBuyPositionSelection,
                        style: const TextStyle(
                          fontSize: 16,
                          //fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

              // 卖出tab下，显示已选择的持仓信息
              if (!isBuy && _selectedBuyRecords.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.tradeAddPageSelectedPositions,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Color(0xFF34B363),
                          ),
                          tooltip: AppLocalizations.of(
                            context,
                          )!.tradeAddPageEditSelectedPositions, // 可在arb中添加多语言
                          onPressed: _selectBuyPositions,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ..._selectedBuyRecords.map(
                      (r) => Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${r.record.name}  ${r.record.code ?? ''}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  '${DateFormat.yMMMd(Localizations.localeOf(context).toString()).add_E().format(r.record.tradeDate.toLocal())} ',
                                  //'(${DateFormat.E().format(r.record.tradeDate.toLocal())})',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  NumberFormat.simpleCurrency(
                                    name: r.record.currency.displayName(
                                      context,
                                    ),
                                  ).format(r.record.price),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  NumberFormat.decimalPattern().format(
                                    r.quantity,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              if (isBuy || _selectedBuyRecords.isNotEmpty)
                // 日期
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.tradeAddPageTradeDateLabel,
                                style: const TextStyle(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickDate(isBuy),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    tradeDate != null
                                        ? DateFormat.yMMMd(
                                            Localizations.localeOf(
                                              context,
                                            ).toString(),
                                          ).add_E().format(tradeDate.toLocal())
                                        : AppLocalizations.of(
                                            context,
                                          )!.tradeAddPageTradeDatePlaceholder,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  size: 22,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (isBuy) ...[
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                // 类别
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.savings,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.tradeAddPageTypeLabel,
                                style: const TextStyle(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showPickerSheet<TradeType>(
                              context: context,
                              options: TradeType.values,
                              selected: tradeType,
                              display: (t) => t.displayName,
                            );
                            if (picked != null) {
                              setState(() {
                                if (isBuy) {
                                  _buyTradeType = picked;
                                } else {
                                  _sellTradeType = picked;
                                }
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    tradeType != null
                                        ? tradeType.displayName
                                        : AppLocalizations.of(
                                            context,
                                          )!.tradeAddPageTypePlaceholder,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: tradeType != null
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  size: 22,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                // 市场
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.public,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.tradeAddPageCategoryLabel,
                                style: const TextStyle(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showPickerSheet<TradeCategory>(
                              context: context,
                              options: TradeCategory.values,
                              selected: category,
                              display: (c) => c.displayName,
                            );
                            if (picked != null) {
                              setState(() {
                                if (isBuy) {
                                  _buyCategory = picked;
                                } else {
                                  _sellCategory = picked;
                                }
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    category != null
                                        ? category.displayName
                                        : AppLocalizations.of(
                                            context,
                                          )!.tradeAddPageCategoryPlaceholder,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: category != null
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  size: 22,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                // 名称
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.business,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.tradeAddPageNameLabel,
                                style: const TextStyle(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: nameController,
                          style: const TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(
                              context,
                            )!.tradeAddPageNamePlaceholder,
                            hintStyle: const TextStyle(fontSize: 15),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? AppLocalizations.of(
                                  context,
                                )!.tradeAddPageNameError
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                // 代码
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.confirmation_number,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.tradeAddPageCodeLabel,
                                style: const TextStyle(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          style: const TextStyle(fontSize: 15),
                          controller: codeController,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(
                              context,
                            )!.tradeAddPageCodePlaceholder,
                            hintStyle: const TextStyle(fontSize: 15),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                // 数量
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.confirmation_number,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.tradeAddPageQuantityLabel,
                                style: const TextStyle(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: quantityController,
                          style: const TextStyle(fontSize: 15),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(
                              context,
                            )!.tradeAddPageQuantityPlaceholder,
                            hintStyle: const TextStyle(fontSize: 15),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? AppLocalizations.of(
                                  context,
                                )!.tradeAddPageQuantityError
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (isBuy || _selectedBuyRecords.isNotEmpty) ...[
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.tradeAddPageCurrencyLabel,
                                style: const TextStyle(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showPickerSheet<Currency>(
                              context: context,
                              options: Currency.values,
                              selected: currency,
                              display: (c) => c.displayName(context),
                            );
                            if (picked != null) {
                              setState(() {
                                if (isBuy) {
                                  _buyCurrency = picked;
                                } else {
                                  _sellCurrency = picked;
                                }
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    currency != null
                                        ? currency.displayName(context)
                                        : AppLocalizations.of(
                                            context,
                                          )!.tradeAddPageCurrencyPlaceholder,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: currency != null
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  size: 22,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                // 价格
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.attach_money,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.tradeAddPagePriceLabel,
                                style: const TextStyle(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: priceController,
                          style: const TextStyle(fontSize: 15),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,6}'),
                            ),
                          ],
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(
                              context,
                            )!.tradeAddPagePricePlaceholder,
                            hintStyle: const TextStyle(fontSize: 15),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? AppLocalizations.of(
                                  context,
                                )!.tradeAddPagePriceError
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                // 汇率
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.swap_horiz,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.tradeAddPageRateLabel,
                                style: const TextStyle(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: rateController,
                          style: const TextStyle(fontSize: 15),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,6}'),
                            ),
                          ],
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(
                              context,
                            )!.tradeAddPageRatePlaceholder,
                            hintStyle: const TextStyle(fontSize: 15),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? AppLocalizations.of(
                                  context,
                                )!.tradeAddPageRateError
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                // 备注
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.note,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.tradeAddPageRemarkLabel,
                                style: const TextStyle(fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: remarkController,
                          style: const TextStyle(fontSize: 15),
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(
                              context,
                            )!.tradeAddPageRemarkPlaceholder,
                            hintStyle: const TextStyle(fontSize: 15),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 20),
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
                        if (_selectedBuyRecords.isNotEmpty) {
                          final minBuyDate = _selectedBuyRecords
                              .map((r) => r.record.tradeDate)
                              .reduce((a, b) => a.isBefore(b) ? a : b);
                          if (_sellTradeDate!.isBefore(minBuyDate)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.tradeAddPageSellDateError,
                                ),
                              ),
                            );
                            return;
                          }
                        }
                        _save();
                      },
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
            ],
          ),
        ),
      ),
    );
  }
}
