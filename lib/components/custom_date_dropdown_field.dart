import 'package:flutter/material.dart';

class CustomDateDropdownField extends StatefulWidget {
  final DateTime? value;
  final void Function(DateTime?) onChanged;
  final String labelText;
  final String hintText;

  const CustomDateDropdownField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.labelText,
    this.hintText = '日付を選択',
  });

  @override
  State<CustomDateDropdownField> createState() =>
      _CustomDateDropdownFieldState();
}

class _CustomDateDropdownFieldState extends State<CustomDateDropdownField> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  void _showOverlay() {
    _removeOverlay();
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 全屏透明层，点击关闭日历
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _removeOverlay,
            child: Container(
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
          // 日历浮层
          Positioned(
            left: position.dx,
            top: position.dy + box.size.height + 4,
            width: box.size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, box.size.height + 4),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: CalendarDatePicker(
                    initialDate: widget.value ?? DateTime.now(),
                    firstDate: DateTime(2016, 1, 1), // 可选的最早日期
                    lastDate: DateTime.now(), // 可选的最晚日期（今天）
                    onDateChanged: (date) {
                      widget.onChanged(date);
                      _removeOverlay();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _showOverlay,
        child: AbsorbPointer(
          child: TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              filled: true,
              fillColor: const Color(0xFFF5F6FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
            ),
            controller: TextEditingController(
              text: widget.value != null
                  ? "${widget.value!.year}-${widget.value!.month.toString().padLeft(2, '0')}-${widget.value!.day.toString().padLeft(2, '0')}"
                  : '',
            ),
          ),
        ),
      ),
    );
  }
}
