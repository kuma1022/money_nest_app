import 'package:flutter/material.dart';
import 'package:money_nest_app/presentation/resources/app_texts.dart';
import 'summary_sub_category_card.dart';

class SummaryCategoryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color dotColor;
  final String rateLabel;
  final String profitText;
  final String profitRateText;
  final Color profitColor;
  final List<SummarySubCategoryCard> subCategories;
  final VoidCallback? onCategoryTap;

  const SummaryCategoryCard({
    required this.label,
    required this.value,
    required this.dotColor,
    required this.rateLabel,
    required this.profitText,
    required this.profitRateText,
    required this.profitColor,
    required this.subCategories,
    this.onCategoryTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: onCategoryTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // 主内容行
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 左侧：圆点+分类名+比例
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 6,
                                    right: 10,
                                  ),
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: dotColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      label,
                                      style: const TextStyle(
                                        fontSize: AppTexts.fontSizeLarge,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      rateLabel,
                                      style: TextStyle(
                                        fontSize: AppTexts.fontSizeSmall,
                                        color: Colors.black.withValues(
                                          alpha: 0.45,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // 金额
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              // 涨跌信息靠右显示
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 6,
                                    right: 6,
                                  ),
                                  child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 4,
                                    children: [
                                      Icon(
                                        Icons.trending_up,
                                        color: profitColor,
                                        size: 16,
                                      ),
                                      Text(
                                        profitText,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: profitColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        profitRateText,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: profitColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // 箭头
                          Icon(
                            Icons.chevron_right,
                            color: Colors.black26,
                            size: 26,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // 子分类卡片
                ...subCategories.map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: e,
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
