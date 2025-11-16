import 'package:flutter/material.dart';

// 浮动追加按钮（带缩放 + 水波纹效果）
class FloatingButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Icon icon;
  const FloatingButton({
    required this.onPressed,
    required this.icon,
    super.key,
  });

  @override
  State<FloatingButton> createState() => _FloatingAddButtonState();
}

class _FloatingAddButtonState extends State<FloatingButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0, // 按下缩小 10%
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Material(
          shape: const CircleBorder(),
          color: const Color(0xFF1976D2),
          elevation: _pressed ? 4 : 8, // 按下阴影减小
          child: InkWell(
            customBorder: const CircleBorder(),
            splashColor: Colors.white24,
            highlightColor: Colors.transparent,
            onTap: widget.onPressed,
            child: SizedBox(width: 56, height: 56, child: widget.icon),
          ),
        ),
      ),
    );
  }
}
