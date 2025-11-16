import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

/// 通用按钮定义：可以携带返回值 T
class HudDialogButton<T> {
  final String text;
  final Color? color; // 按钮文字颜色，默认使用 theme 的 color
  final FutureOr<T?> Function()? onPressed;

  HudDialogButton({required this.text, this.color, this.onPressed});
}

/// 通用 HUD 弹窗
class HudDialog {
  /// show 返回 Future<T?>，当用户按下按钮且 onPressed 返回值不为空时，会把值带回。
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    Widget? content,
    List<HudDialogButton<T>>? actions,
    bool barrierDismissible = true,
    double widthFactor = 0.75, // 宽度占比
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: '',
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, secAnim, child) {
        final opacity = CurvedAnimation(parent: anim, curve: Curves.easeOut);

        return FadeTransition(
          opacity: opacity,
          child: ScaleTransition(
            scale: Tween(begin: 0.98, end: 1.0).animate(opacity),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: _DialogBody<T>(
                    ctx: ctx,
                    width: MediaQuery.of(context).size.width * widthFactor,
                    title: title,
                    content: content,
                    actions: actions,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DialogBody<T> extends StatelessWidget {
  final BuildContext ctx;
  final double width;
  final String? title;
  final Widget? content;
  final List<HudDialogButton<T>>? actions;

  const _DialogBody({
    required this.ctx,
    required this.width,
    this.title,
    this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      // 使用透明 material 来保证按下效果正常
      color: Colors.transparent,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: theme.dialogBackgroundColor.withOpacity(
            0.95,
          ), // 与系统 dialog 背景更一致
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 18),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Text(
                title!,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (content != null)
              DefaultTextStyle(
                style: theme.textTheme.bodyMedium!.copyWith(
                  decoration: TextDecoration.none,
                ),
                child: content!,
              ),
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: 18),
              _buildActions(context, theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme) {
    // 横向排列按钮，按数量自动等分或固定间隔
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: actions!.map((btn) {
        final btnColor =
            btn.color ??
            theme.textTheme.labelLarge?.color ??
            theme.primaryColor;
        // 文本样式，明确取消任何下划线
        final textStyle = TextStyle(
          fontSize: 15,
          color: btnColor,
          decoration: TextDecoration.none,
        );

        return TextButton(
          style: TextButton.styleFrom(
            foregroundColor: btnColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: textStyle,
          ),
          onPressed: () async {
            // 如果按钮提供异步回调，先执行回调拿到返回值，再关闭弹窗并带回返回值
            T? result;
            if (btn.onPressed != null) {
              try {
                final r = await btn.onPressed!();
                if (r is T) result = r;
              } catch (e) {
                // 回调异常时，仍然关闭弹窗（你可以改成不关闭或显示错误）
                // print('HudDialog button callback error: $e');
              }
            }
            Navigator.of(context).pop(result);
          },
          child: Text(btn.text, style: textStyle),
        );
      }).toList(),
    );
  }
}
