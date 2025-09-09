import 'package:flutter/material.dart';
import 'trade_history_tab_page.dart'; // 导入 TradeRecord/TradeType

class TradeAddPage extends StatefulWidget {
  final TradeRecord? record; // 新增：支持编辑模式

  const TradeAddPage({super.key, this.record});

  @override
  State<TradeAddPage> createState() => _TradeAddPageState();
}

class _TradeAddPageState extends State<TradeAddPage> {
  int? tradeType;
  int? category;
  DateTime selectedDate = DateTime.now();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController feeController = TextEditingController();
  final TextEditingController memoController = TextEditingController();
  String feeCurrency = 'JPY';

  @override
  void initState() {
    super.initState();
    // 编辑模式下填充初始值
    if (widget.record != null) {
      final r = widget.record!;
      tradeType = r.type == TradeType.buy
          ? 0
          : r.type == TradeType.sell
          ? 1
          : null;
      category = (r.code == 'AAPL' || r.code == 'MSFT') ? 1 : 0;
      codeController.text = r.code;
      nameController.text = r.name;
      selectedDate = DateTime.tryParse(r.date) ?? DateTime.now();
      // 假设 detail 格式为 "5株*17500円"
      final detail = r.detail.split('*');
      if (detail.isNotEmpty) {
        // 数量
        // unitPriceController 只填单价
        if (detail.length > 1) {
          unitPriceController.text = detail[1].replaceAll(RegExp(r'\D'), '');
        }
      }
      // 假设手续费和币种可从 r 取出或用默认
      feeController.text = r.code == 'AAPL' ? '500' : '300';
      feeCurrency = 'JPY';
      memoController.text = '';
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ja'),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.record != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? '取引編集' : '取引追加',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          children: [
            // 取引種別
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '取引種別',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: tradeType,
                        hint: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '取引種別を選択',
                            style: TextStyle(color: Color(0xFF757575)),
                          ),
                        ),
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(12),
                        icon: const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.keyboard_arrow_down_rounded),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 0,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('買付'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('売却'),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => tradeType = v),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 銘柄情報
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '銘柄情報',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '銘柄コード',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  _InputField(
                    controller: codeController,
                    hintText: '例: 7203, AAPL',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '銘柄名',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  _InputField(
                    controller: nameController,
                    hintText: '例: トヨタ自動車',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'カテゴリ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: category,
                        hint: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'カテゴリを選択',
                            style: TextStyle(color: Color(0xFF757575)),
                          ),
                        ),
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(12),
                        icon: const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.keyboard_arrow_down_rounded),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 0,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('日本株'),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('米国株'),
                            ),
                          ),
                        ],
                        onChanged: (v) => setState(() => category = v),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 取引詳細
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '取引詳細',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '取引日',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            '${selectedDate.year}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Color(0xFF757575),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '単価',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  _InputField(
                    controller: unitPriceController,
                    hintText: '例: 2500',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '手数料（任意）',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _InputField(
                              controller: feeController,
                              hintText: '例: 500',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '手数料通貨',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F6FA),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: feeCurrency,
                                  isExpanded: true,
                                  borderRadius: BorderRadius.circular(12),
                                  icon: const Padding(
                                    padding: EdgeInsets.only(right: 12),
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'JPY',
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Text('JPY'),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'USD',
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Text('USD'),
                                      ),
                                    ),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => feeCurrency = v ?? 'JPY'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'メモ（任意）',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  _InputField(
                    controller: memoController,
                    hintText: '取引に関するメモを入力',
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F6FA),
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Color(0xFFF5F6FA)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'キャンセル',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4385F5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.save_alt, size: 22),
                    label: Text(
                      isEdit ? '保存' : '保存',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      // 保存或更新逻辑
                      // 可根据 isEdit 判断是新增还是编辑
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E6EA)),
      ),
      child: child,
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  const _InputField({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.keyboardType,
  });
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
        filled: true,
        fillColor: const Color(0xFFF5F6FA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        isDense: true,
      ),
    );
  }
}
