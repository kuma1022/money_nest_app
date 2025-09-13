import 'package:flutter/material.dart';

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
  bool _highlight = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _highlight = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _highlight = false);
    // 延长到250ms，动画更明显
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onTap();
        });
      }
    });
  }

  void _handleTapCancel() {
    setState(() => _highlight = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool showGreen = _highlight || widget.selected;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {}, // 必须有，否则 onTapUp 不会触发
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250), // 动画时间同步延长
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: showGreen ? const Color(0xFFF3FBF5) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: showGreen ? const Color(0xFFB7E6C6) : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 26,
                color: showGreen
                    ? const Color(0xFFB7E6C6)
                    : (widget.iconColor ?? Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  color: showGreen
                      ? const Color(0xFFB7E6C6)
                      : (widget.iconColor ?? Colors.black87),
                  //fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
