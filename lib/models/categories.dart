// カテゴリ（資産・負債共通）
enum Categoryies {
  stock(id: 1, name: '株式', type: 'asset', displayOrder: 1),
  fx(id: 2, name: 'FX（為替）', type: 'asset', displayOrder: 2),
  crypto(id: 3, name: '暗号資産', type: 'asset', displayOrder: 3),
  metal(id: 4, name: '貴金属', type: 'asset', displayOrder: 4),
  otherAsset(id: 5, name: 'その他資産', type: 'asset', displayOrder: 5),
  loan(id: 6, name: 'ローン', type: 'liability', displayOrder: 6),
  debt(id: 7, name: '借金', type: 'liability', displayOrder: 7);

  final int id;
  final String name;
  final String type;
  final int displayOrder;
  const Categoryies({
    required this.id,
    required this.name,
    required this.type,
    required this.displayOrder,
  });
}
