import 'package:flutter/material.dart';

// 毛玻璃快捷操作栏项
class GlassQuickBarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? iconColor;
  const GlassQuickBarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.iconColor,
    super.key,
  });

  @override
  State<GlassQuickBarItem> createState() => _GlassQuickBarItemState();
}

class _GlassQuickBarItemState extends State<GlassQuickBarItem> {
  bool _pressed = false;
  bool _tapping = false;

  void _handleTapDown(TapDownDetails details) {
    if (_tapping) return;
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (_tapping) return;
    setState(() => _pressed = false);
    _tapping = true;
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) widget.onTap();
      _tapping = false;
    });
  }

  void _handleTapCancel() {
    setState(() => _pressed = false);
    _tapping = false;
  }

  @override
  Widget build(BuildContext context) {
    final bool highlight = widget.selected || _pressed;
    final Color borderColor = highlight
        ? (widget.iconColor ?? const Color(0xFF1976D2)).withOpacity(0.22)
        : Colors.transparent;
    final Color iconAndTextColor = _pressed
        ? (widget.iconColor ?? Theme.of(context).primaryColor)
        : (widget.iconColor ?? Colors.black87);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: highlight
                ? Colors.white.withOpacity(0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              top: _pressed ? 6 : 0,
              bottom: _pressed ? 0 : 6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 24, color: iconAndTextColor),
                const SizedBox(height: 2),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: iconAndTextColor,
                    fontWeight: _pressed ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
