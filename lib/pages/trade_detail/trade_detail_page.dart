import 'package:drift/drift.dart' hide Column;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/util/provider/buy_records_provider.dart';
import 'package:money_nest_app/util/provider/market_data_provider.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/models/trade_action.dart';
import 'package:money_nest_app/models/trade_type.dart';
import 'package:money_nest_app/util/provider/stocks_provider.dart';
import 'package:provider/provider.dart';

class TradeRecordDetailPage extends StatefulWidget {
  final AppDatabase db;
  final TradeRecord record;
  final ScrollController? scrollController;

  const TradeRecordDetailPage({
    super.key,
    required this.db,
    required this.record,
    this.scrollController,
  });

  @override
  State<TradeRecordDetailPage> createState() => _TradeRecordDetailPageState();
}

class _TradeRecordDetailPageState extends State<TradeRecordDetailPage> {
  Currency? currency;
  late TextEditingController _quantityController;
  late TextEditingController _currencyController;
  late TextEditingController _priceController;
  late TextEditingController _remarkController;

  late FocusNode _quantityFocusNode;
  late FocusNode _priceFocusNode;

  void _onQuantityFocusChange(
    TextEditingController controller,
    FocusNode focusNode,
  ) {
    // 数量字段（整数）
    if (focusNode.hasFocus) {
      final text = controller.text.replaceAll(',', '');
      controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    } else {
      final text = controller.text.replaceAll(',', '');
      if (text.isNotEmpty) {
        final number = int.tryParse(text);
        if (number != null) {
          controller.text = NumberFormat('#,###').format(number);
        }
      }
    }
  }

  void _onPriceFocusChange(
    TextEditingController controller,
    FocusNode focusNode,
  ) {
    if (focusNode.hasFocus) {
      final text = controller.text.replaceAll(',', '');
      if (text.isNotEmpty) {
        final number = double.tryParse(text);
        if (number != null) {
          // 去掉多余的零和小数点
          String plain = number.toString();
          if (plain.contains('.')) {
            plain = plain.replaceFirst(RegExp(r'\.?0*$'), '');
          }
          controller.value = TextEditingValue(
            text: plain,
            selection: TextSelection.collapsed(offset: plain.length),
          );
        } else {
          controller.value = TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
        }
      }
    } else {
      final text = controller.text.replaceAll(',', '');
      if (text.isNotEmpty) {
        final number = double.tryParse(text);
        if (number != null) {
          // 用 '#,##0.##' 自动去掉多余的零
          controller.text = NumberFormat('#,##0.00').format(number);
        }
      }
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

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.record.quantity.toInt().toString(),
    );
    _quantityFocusNode = FocusNode();
    _quantityFocusNode.addListener(
      () => _onQuantityFocusChange(_quantityController, _quantityFocusNode),
    );
    _currencyController = TextEditingController(
      text: widget.record.currency.name,
    );

    _priceController = TextEditingController(
      text: NumberFormat('#,##0.00').format(widget.record.price),
    );

    _priceFocusNode = FocusNode();
    _priceFocusNode.addListener(
      () => _onPriceFocusChange(_priceController, _priceFocusNode),
    );
    _remarkController = TextEditingController(text: widget.record.remark ?? '');
    currency = widget.record.currency;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _quantityFocusNode.removeListener(
      () => _onQuantityFocusChange(_quantityController, _quantityFocusNode),
    );
    _quantityFocusNode.dispose();
    _currencyController.dispose();
    _priceController.dispose();
    _priceFocusNode.removeListener(
      () => _onPriceFocusChange(_priceController, _priceFocusNode),
    );
    _priceFocusNode.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final marketDataList = context.watch<MarketDataProvider>().marketData;
    final stocks = context.watch<StocksProvider>().stocks;

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
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
                // 标题
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Text(
                          AppLocalizations.of(context)!.tradeDetailPageTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      top: 0,
                    ),
                    child: ListView(
                      controller: widget.scrollController,
                      children: [
                        // 操作
                        _buildRow(
                          AppLocalizations.of(
                            context,
                          )!.tradeDetailPageActionLabel,
                          'text',
                          value: widget.record.action.displayName(context),
                          editable: false,
                          icon: Icons.swap_horiz,
                        ),

                        const Divider(height: 1, color: Color(0xFFE0E0E0)),
                        // 日期
                        _buildRow(
                          AppLocalizations.of(
                            context,
                          )!.tradeDetailPageTradeDateLabel,
                          'text',
                          value: DateFormat.yMMMd(
                            Localizations.localeOf(context).toString(),
                          ).add_E().format(widget.record.tradeDate.toLocal()),
                          editable: false,
                          icon: Icons.calendar_today,
                        ),

                        const Divider(height: 1, color: Color(0xFFE0E0E0)),
                        // 类别
                        _buildRow(
                          AppLocalizations.of(
                            context,
                          )!.tradeDetailPageTradeTypeLabel,
                          'text',
                          value: widget.record.tradeType.displayName,
                          editable: false,
                          icon: Icons.savings,
                        ),

                        const Divider(height: 1, color: Color(0xFFE0E0E0)),
                        // 市场
                        _buildRow(
                          AppLocalizations.of(
                            context,
                          )!.tradeDetailPageCategoryLabel,
                          'text',
                          value: marketDataList
                              .firstWhere(
                                (market) =>
                                    market.code == widget.record.marketCode,
                                orElse: () => MarketDataData(
                                  code: '',
                                  name: '',
                                  sortOrder: 0,
                                  isActive: false,
                                  currency: '',
                                ),
                              )
                              .name,
                          editable: false,
                          icon: Icons.public,
                        ),

                        const Divider(height: 1, color: Color(0xFFE0E0E0)),
                        // 名称
                        FutureBuilder<MarketDataData?>(
                          future: widget.db.getMarketDataByCode(
                            widget.record.marketCode,
                          ),
                          builder: (context, snapshot) {
                            String name = '';
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              name = '...';
                            } else if (snapshot.hasData &&
                                snapshot.data != null) {
                              name = snapshot.data!.name;
                            }
                            return _buildRow(
                              AppLocalizations.of(
                                context,
                              )!.tradeDetailPageNameLabel,
                              'text',
                              value: name,
                              editable: false,
                              icon: Icons.business,
                            );
                          },
                        ),

                        const Divider(height: 1, color: Color(0xFFE0E0E0)),
                        // 代码
                        _buildRow(
                          AppLocalizations.of(
                            context,
                          )!.tradeDetailPageCodeLabel,
                          'text',
                          value: widget.record.code,
                          editable: false,
                          icon: Icons.confirmation_number,
                        ),

                        const Divider(height: 1, color: Color(0xFFE0E0E0)),
                        // 数量
                        _buildRow(
                          AppLocalizations.of(
                            context,
                          )!.tradeDetailPageNumberLabel,
                          'text',
                          controller: _quantityController,
                          editable: true,
                          icon: Icons.numbers,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          hintText: AppLocalizations.of(
                            context,
                          )!.tradeAddPageQuantityPlaceholder,
                          validatorMessage: AppLocalizations.of(
                            context,
                          )!.tradeEditPageQuantityError,
                          focusNode: _quantityFocusNode,
                        ),

                        const Divider(height: 1, color: Color(0xFFE0E0E0)),
                        // 币种
                        _buildRow(
                          AppLocalizations.of(
                            context,
                          )!.tradeDetailPageCurrencyLabel,
                          'dropdown',
                          controller: _currencyController,
                          editable: true,
                          icon: Icons.monetization_on,
                          hintText: AppLocalizations.of(
                            context,
                          )!.tradeEditPageCurrencyPlaceholder,
                        ),

                        const Divider(height: 1, color: Color(0xFFE0E0E0)),
                        // 单价
                        _buildRow(
                          AppLocalizations.of(
                            context,
                          )!.tradeDetailPagePriceLabel,
                          'text',
                          controller: _priceController,
                          editable: true,
                          icon: Icons.attach_money,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,6}'),
                            ),
                          ],
                          hintText: AppLocalizations.of(
                            context,
                          )!.tradeDetailPagePriceLabel,
                          validatorMessage: AppLocalizations.of(
                            context,
                          )!.tradeDetailPagePriceError,
                          focusNode: _priceFocusNode,
                        ),

                        const Divider(height: 1, color: Color(0xFFE0E0E0)),
                        // 备注
                        _buildRow(
                          AppLocalizations.of(
                            context,
                          )!.tradeDetailPageRemarkLabel,
                          'text',
                          controller: _remarkController,
                          editable: true,
                          icon: Icons.note,
                          keyboardType: TextInputType.multiline,
                          hintText: AppLocalizations.of(
                            context,
                          )!.tradeDetailPageRemarkPlaceholder,
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
                                  AppColors.appGreen,
                                ),
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5),
                                    ),
                                  ),
                                ),
                                padding: WidgetStatePropertyAll(
                                  EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                              onPressed: () {
                                _save();
                              },
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                )!.tradeEditPageUpdateButton,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String type, {
    String? value,
    TextEditingController? controller,
    bool editable = false,
    IconData? icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String hintText = '',
    String validatorMessage = '',
    FocusNode? focusNode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Row(
              children: [
                Icon(icon, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: type == 'text'
                ? (editable
                      ? TextFormField(
                          controller: controller,
                          focusNode: focusNode ?? FocusNode(),
                          style: const TextStyle(
                            fontSize: 15,
                            //color: Colors.black
                          ),
                          keyboardType: keyboardType,
                          inputFormatters: inputFormatters ?? [],
                          enabled: editable, // 只读时禁用
                          decoration: InputDecoration(
                            hintText: hintText,
                            hintStyle: const TextStyle(fontSize: 15),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                          ),
                          validator: validatorMessage != ''
                              ? (v) => v == null || v.isEmpty
                                    ? validatorMessage
                                    : null
                              : null,
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          child: Text(
                            value ?? '',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                        ))
                : GestureDetector(
                    onTap: () async {
                      final picked = await showPickerSheet<Currency>(
                        context: context,
                        options: Currency.values,
                        selected: currency,
                        display: (c) => c.displayName(context),
                      );
                      if (!mounted) return;
                      if (picked != null) {
                        setState(() {
                          currency = picked;
                        });
                      }
                      // 再次确保没有输入框获得焦点
                      FocusScope.of(context).requestFocus(FocusNode());
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
                                  ? currency!.displayName(context)
                                  : AppLocalizations.of(
                                      context,
                                    )!.tradeEditPageCurrencyPlaceholder,
                              style: TextStyle(
                                fontSize: 15,
                                color: controller?.text != null
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
    );
  }

  void _save() async {
    // 校验数量
    final quantityText = _quantityController.text.replaceAll(',', '');
    final priceText = _priceController.text.replaceAll(',', '');

    final quantity = int.tryParse(quantityText);
    final price = double.tryParse(priceText);

    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.tradeEditPageQuantityError,
          ),
        ),
      );
      return;
    }
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.tradeDetailPagePriceError,
          ),
        ),
      );
      return;
    }
    if (currency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.tradeEditPageCurrencyError,
          ),
        ),
      );
      return;
    }

    final updated = TradeRecordsCompanion(
      id: Value(widget.record.id),
      tradeDate: Value(widget.record.tradeDate),
      action: Value(widget.record.action),
      marketCode: Value(widget.record.marketCode),
      tradeType: Value(widget.record.tradeType),
      code: Value(widget.record.code),
      quantity: Value(quantity.toDouble()),
      currency: Value(currency!),
      price: Value(price),
      remark: Value(_remarkController.text),
    );

    await widget.db.update(widget.db.tradeRecords).replace(updated);

    if (!mounted) return; // 添加mounted判断
    context.read<BuyRecordsProvider>().loadRecords();
    Navigator.pop(context, true);
  }
}
