import 'package:flutter/material.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/services/data_sync_service.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:money_nest_app/util/global_store.dart';
import 'package:provider/provider.dart';

class CashEditPage extends StatefulWidget {
  final AppDatabase db;
  final bool isDeposit; // true for 入金, false for 出金

  const CashEditPage({
    super.key,
    required this.db,
    this.isDeposit = true,
  });

  @override
  State<CashEditPage> createState() => _CashEditPageState();
}

class _CashEditPageState extends State<CashEditPage> {
  late bool _isDeposit;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _currency = 'USD'; // Default currency
  double _currentBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _isDeposit = widget.isDeposit;
    _refreshBalance();
  }

  Future<void> _refreshBalance() async {
    final accountId = GlobalStore().accountId;
    if (accountId == null) return;

    final balanceRow = await (widget.db.select(widget.db.accountBalances)
      ..where((t) =>
          t.accountId.equals(accountId) & t.currency.equals(_currency)))
        .getSingleOrNull();

    if (mounted) {
      setState(() {
        _currentBalance = balanceRow?.amount ?? 0.0;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Color get _activeColor => _isDeposit ? Colors.red : const Color(0xFF00C853);

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('米ドル (USD)', style: TextStyle(color: Colors.white)),
                trailing: _currency == 'USD'
                    ? Icon(Icons.check, color: _activeColor)
                    : null,
                onTap: () {
                  setState(() => _currency = 'USD');
                  _refreshBalance();
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('日本円 (JPY)', style: TextStyle(color: Colors.white)),
                trailing: _currency == 'JPY'
                    ? Icon(Icons.check, color: _activeColor)
                    : null,
                onTap: () {
                  setState(() => _currency = 'JPY');
                  _refreshBalance();
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // Spacer for title centering
                  Column(
                    children: [
                      const Text(
                        '利用可能な現金',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      Text(
                        '合計残高: ${AppUtils().formatMoney(_currentBalance, _currency)}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // Toggle Buttons (Deposit / Withdrawal)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isDeposit = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isDeposit ? Colors.red.withOpacity(0.2) : Colors.transparent,
                          border: Border.all(
                            color: _isDeposit ? Colors.red : Colors.grey[800]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '入金',
                            style: TextStyle(
                              color: _isDeposit ? Colors.red : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isDeposit = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isDeposit ? const Color(0xFF00C853).withOpacity(0.2) : Colors.transparent,
                          border: Border.all(
                            color: !_isDeposit ? const Color(0xFF00C853) : Colors.grey[800]!,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '出金',
                            style: TextStyle(
                              color: !_isDeposit ? const Color(0xFF00C853) : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form Fields
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Currency Selector
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('通貨', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      subtitle: Text(
                        _currency == 'USD' ? '米ドル (USD)' : '日本円 (JPY)',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white),
                      onTap: _showCurrencyPicker,
                    ),
                    const Divider(color: Color(0xFF2C2C2E)),

                    // Date Time Picker
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('日付と時刻', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      subtitle: Text(
                        AppUtils().formatDate(_selectedDate), // Simple format
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: _activeColor,
                                  onPrimary: Colors.white,
                                  surface: const Color(0xFF1C1C1E),
                                  onSurface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          setState(() => _selectedDate = date);
                        }
                      },
                    ),
                    const Divider(color: Color(0xFF2C2C2E)),

                    // Amount Input
                    const SizedBox(height: 16),
                    const Text('金額', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      cursorColor: _activeColor,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2C2C2E))),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2C2C2E))),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Memo
                    const Text('メモ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    TextField(
                      controller: _memoController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      cursorColor: _activeColor,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2C2C2E))),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2C2C2E))),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Submit Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _activeColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final amountText = _amountController.text;
                    if (amountText.isEmpty) return;
                    final amount = double.tryParse(amountText);
                    if (amount == null || amount <= 0) return;

                    final dataSync = Provider.of<DataSyncService>(context, listen: false);
                    
                    try {
                      // Show Loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => const Center(child: CircularProgressIndicator()),
                      );

                      await dataSync.addCashTransaction(
                        isDeposit: _isDeposit,
                        amount: amount,
                        currency: _currency,
                        date: _selectedDate,
                        memo: _memoController.text,
                      );
                      
                      if (context.mounted) {
                        Navigator.of(context).pop(); // Dismiss loading
                        Navigator.of(context).pop(); // Back to list
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.of(context).pop(); // Dismiss loading
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: const Text(
                    '取引を追加',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
