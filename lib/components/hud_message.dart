import 'package:flutter/material.dart';

class HUDMessage extends StatefulWidget {
  final String message;
  final Duration duration;

  const HUDMessage({super.key, required this.message, required this.duration});

  @override
  State<HUDMessage> createState() => _HUDMessageState();
}

class _HUDMessageState extends State<HUDMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    // 先淡入
    _controller.forward();

    // 到时间后淡出并销毁
    Future.delayed(widget.duration - const Duration(milliseconds: 300), () {
      if (mounted) _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Material(
        color: Colors.black.withOpacity(0.1),
        child: Center(
          child: FadeTransition(
            opacity: _opacity,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 28),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
