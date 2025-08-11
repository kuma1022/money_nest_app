import 'package:drift/drift.dart';

// 1. 定义你的枚举
enum TradeCategory {
  usStock, // 美股
  usEtf, // 美股ETF
  jpStock, // 日股
  jpEtf, // 日股ETF
  hkStock, // 港股
  option, // 期权
  fund, // 基金
  goldEtf, // 黄金（ETF）
  jreit, // 不动产信托（J-REIT）
  fx, // FX
}

// 2. 扩展：显示名称
extension TradeCategoryExtension on TradeCategory {
  String get displayName {
    switch (this) {
      case TradeCategory.usStock:
        return '美股';
      case TradeCategory.usEtf:
        return '美股ETF';
      case TradeCategory.jpStock:
        return '日股';
      case TradeCategory.jpEtf:
        return '日股ETF';
      case TradeCategory.hkStock:
        return '港股';
      case TradeCategory.option:
        return '期权';
      case TradeCategory.fund:
        return '基金';
      case TradeCategory.goldEtf:
        return '黄金（ETF）';
      case TradeCategory.jreit:
        return '不动产信托（J-REIT）';
      case TradeCategory.fx:
        return 'FX';
    }
  }
}

// 3. TypeConverter，方便 drift 存储
class TradeCategoryConverter extends TypeConverter<TradeCategory, String> {
  const TradeCategoryConverter();

  @override
  TradeCategory fromSql(String fromDb) {
    return TradeCategory.values.byName(fromDb);
  }

  @override
  String toSql(TradeCategory value) {
    return value.name;
  }
}
