// カテゴリ（資産・負債共通）
import 'dart:convert';
import 'dart:ui';

import 'package:money_nest_app/presentation/resources/app_colors.dart';

enum Categories {
  stock(
    id: 1,
    code: 'stock',
    name: '株式',
    type: 'asset',
    displayOrder: 1,
    dotColor: AppColors.appChartGreen,
  ),
  fund(
    id: 2,
    code: 'fund',
    name: '投資信託',
    type: 'asset',
    displayOrder: 2,
    dotColor: AppColors.appDarkGrey,
  ),
  fx(
    id: 3,
    code: 'fx',
    name: 'FX（為替）',
    type: 'asset',
    displayOrder: 3,
    dotColor: AppColors.appChartBlue,
  ),
  crypto(
    id: 4,
    code: 'crypto',
    name: '暗号資産',
    type: 'asset',
    displayOrder: 4,
    dotColor: AppColors.appChartPurple,
  ),
  metal(
    id: 5,
    code: 'metal',
    name: '貴金属',
    type: 'asset',
    displayOrder: 5,
    dotColor: AppColors.appChartOrange,
  ),
  otherAsset(
    id: 6,
    code: 'other_asset',
    name: 'その他資産',
    type: 'asset',
    displayOrder: 6,
    dotColor: AppColors.appChartLightBlue,
  ),
  loan(
    id: 7,
    code: 'loan',
    name: 'ローン',
    type: 'liability',
    displayOrder: 7,
    dotColor: AppColors.appDarkGrey,
  ),
  debt(
    id: 8,
    code: 'debt',
    name: '借金',
    type: 'liability',
    displayOrder: 8,
    dotColor: AppColors.appDarkGrey,
  );

  final int id;
  final String code;
  final String name;
  final String type;
  final int displayOrder;
  final Color dotColor;
  const Categories({
    required this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.displayOrder,
    required this.dotColor,
  });
}

// サブカテゴリ（資産・負債共通）
enum Subcategories {
  jpStock(
    id: 2,
    categoryId: 1,
    code: 'jp_stock',
    name: '国内株式（ETF含む）',
    displayOrder: 1,
  ),
  usStock(
    id: 3,
    categoryId: 1,
    code: 'us_stock',
    name: '米国株式（ETF含む）',
    displayOrder: 2,
  ),
  otherStock(
    id: 4,
    categoryId: 1,
    code: 'other_stock',
    name: 'その他（海外株式など）',
    displayOrder: 3,
  ),
  fx(id: 5, categoryId: 2, code: 'fx', name: 'FX', displayOrder: 1),
  crypto(id: 6, categoryId: 3, code: 'crypto', name: '暗号資産', displayOrder: 1),
  gold(id: 7, categoryId: 4, code: 'gold', name: '金', displayOrder: 1),
  silver(id: 8, categoryId: 4, code: 'silver', name: '銀', displayOrder: 2),
  platinum(
    id: 9,
    categoryId: 4,
    code: 'platinum',
    name: 'プラチナ',
    displayOrder: 3,
  ),
  bank(id: 10, categoryId: 5, code: 'bank', name: '銀行預金', displayOrder: 1),
  cash(id: 11, categoryId: 5, code: 'cash', name: '現金', displayOrder: 2),
  realEstate(
    id: 12,
    categoryId: 5,
    code: 'real_estate',
    name: '不動産',
    displayOrder: 3,
  ),
  bond(id: 14, categoryId: 5, code: 'bond', name: '債券', displayOrder: 4),
  mortgage(
    id: 15,
    categoryId: 6,
    code: 'mortgage',
    name: '住宅ローン',
    displayOrder: 1,
  ),
  autoLoan(
    id: 16,
    categoryId: 6,
    code: 'auto_loan',
    name: '自動車ローン',
    displayOrder: 2,
  ),
  educationLoan(
    id: 17,
    categoryId: 6,
    code: 'education_loan',
    name: '教育ローン',
    displayOrder: 3,
  ),
  otherLoan(
    id: 18,
    categoryId: 6,
    code: 'other_loan',
    name: 'その他ローン',
    displayOrder: 4,
  ),
  creditCard(
    id: 19,
    categoryId: 7,
    code: 'credit_card',
    name: 'クレジットカード',
    displayOrder: 1,
  ),
  consumerFinance(
    id: 20,
    categoryId: 6,
    code: 'consumer_finance',
    name: '消費者金融/その他',
    displayOrder: 2,
  );

  final int id;
  final int categoryId;
  final String code;
  final String name;
  final int displayOrder;

  const Subcategories({
    required this.id,
    required this.categoryId,
    required this.code,
    required this.name,
    required this.displayOrder,
  });
}
