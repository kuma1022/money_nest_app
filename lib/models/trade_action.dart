import 'package:drift/drift.dart';

// 1. 定义你的枚举
enum TradeAction { buy, sell }

// 2. (可选但强烈推荐) 为枚举创建扩展，方便获取显示名称
extension TradeActionExtension on TradeAction {
  String get displayName {
    switch (this) {
      case TradeAction.buy:
        return '买入';
      case TradeAction.sell:
        return '卖出';
    }
  }
}

// 3. 创建一个 TypeConverter，告诉 drift 如何将 enum 存入数据库
// 我们这里将 enum 的名称 (如 'buy') 作为字符串存储
class TradeActionConverter extends TypeConverter<TradeAction, String> {
  const TradeActionConverter();

  @override
  TradeAction fromSql(String fromDb) {
    // 从数据库读取字符串，并转换为枚举
    return TradeAction.values.byName(fromDb);
  }

  @override
  String toSql(TradeAction value) {
    // 将枚举转换为字符串存入数据库
    return value.name;
  }
}
