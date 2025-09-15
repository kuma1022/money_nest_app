// サブカテゴリ
enum SubCategoryType {
  // 株式
  jpStock(id: 1, categoryId: 1, name: '国内株式（ETF含む）', displayOrder: 1),
  usStock(id: 2, categoryId: 1, name: '米国株式（ETF含む）', displayOrder: 2),
  otherStock(id: 3, categoryId: 1, name: 'その他（海外株式など）', displayOrder: 3),
  // FX
  fx(id: 4, categoryId: 2, name: 'FX', displayOrder: 1),
  // 暗号資産
  crypto(id: 5, categoryId: 3, name: '暗号資産', displayOrder: 1),
  // 貴金属
  gold(id: 6, categoryId: 4, name: '金', displayOrder: 1),
  silver(id: 7, categoryId: 4, name: '銀', displayOrder: 2),
  platinum(id: 8, categoryId: 4, name: 'プラチナ', displayOrder: 3),
  // その他資産
  bank(id: 9, categoryId: 5, name: '銀行預金', displayOrder: 1),
  cash(id: 10, categoryId: 5, name: '現金', displayOrder: 2),
  realEstate(id: 11, categoryId: 5, name: '不動産', displayOrder: 3),
  fund(id: 12, categoryId: 5, name: '投資信託', displayOrder: 4),
  bond(id: 13, categoryId: 5, name: '債券', displayOrder: 5),
  otherAsset(id: 14, categoryId: 5, name: 'その他', displayOrder: 6),
  // ローン
  mortgage(id: 15, categoryId: 6, name: '住宅ローン', displayOrder: 1),
  autoLoan(id: 16, categoryId: 6, name: '自動車ローン', displayOrder: 2),
  educationLoan(id: 17, categoryId: 6, name: '教育ローン', displayOrder: 3),
  otherLoan(id: 18, categoryId: 6, name: 'その他ローン', displayOrder: 4),
  // 借金
  creditCard(id: 19, categoryId: 7, name: 'クレジットカード', displayOrder: 1),
  consumerFinance(id: 20, categoryId: 7, name: '消費者金融/その他', displayOrder: 2);

  final int id;
  final int categoryId;
  final String name;
  final int displayOrder;
  const SubCategoryType({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.displayOrder,
  });
}
