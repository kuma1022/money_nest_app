import 'package:flutter/material.dart';
import 'package:money_nest_app/presentation/resources/app_texts.dart';

// サブカテゴリ別サマリーカード
class SummarySubCategoryCard extends StatelessWidget {
  final String label;
  final String value;
  final String rateLabel;
  final String profitText;
  final String profitRateText;
  final Color profitColor;
  final VoidCallback? onTap;

  const SummarySubCategoryCard({
    required this.label,
    required this.value,
    required this.rateLabel,
    required this.profitText,
    required this.profitRateText,
    required this.profitColor,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 左侧内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: AppTexts.fontSizeSmall,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rateLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              // 金额和涨跌
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: AppTexts.fontSizeSmall,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: profitColor,
                        size: AppTexts.fontSizeSmall,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        profitText,
                        style: TextStyle(
                          fontSize: AppTexts.fontSizeSmall,
                          color: profitColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profitRateText,
                        style: TextStyle(
                          fontSize: AppTexts.fontSizeSmall,
                          color: profitColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // 箭头
              const SizedBox(width: 5),
              Icon(
                Icons.chevron_right,
                color: Colors.black26,
                size: AppTexts.fontSizeExtraLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
