import 'package:flutter/material.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color bgColor;
  final Color fontColor;
  const QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = Colors.black,
    this.bgColor = AppColors.appLightLightGrey,
    this.fontColor = Colors.black,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Ink(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          splashColor: Colors.grey.withAlpha(120),
          highlightColor: Colors.grey.withAlpha(38), // 点击时变灰
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: fontColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
