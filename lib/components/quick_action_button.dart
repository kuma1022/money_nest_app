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
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fontColor,
        side: const BorderSide(color: AppColors.appLightGrey, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.zero,
      ),
      onPressed: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}
