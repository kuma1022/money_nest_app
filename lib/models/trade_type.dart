import 'package:drift/drift.dart';

enum TradeType {
  normal, // 一般
  specific, // 特定
  nisa, // NISA（成長枠）
  nisaTsumitate, // NISA（積み立て）
}

extension TradeTypeExtension on TradeType {
  String get code {
    switch (this) {
      case TradeType.normal:
        return 'normal';
      case TradeType.specific:
        return 'specific';
      case TradeType.nisa:
        return 'nisa';
      case TradeType.nisaTsumitate:
        return 'nisa_tsumitate';
    }
  }

  String get displayName {
    switch (this) {
      case TradeType.normal:
        return '一般';
      case TradeType.specific:
        return '特定';
      case TradeType.nisa:
        return 'NISA（成長）';
      case TradeType.nisaTsumitate:
        return 'NISA（つみたて）';
    }
  }
}

class TradeTypeConverter extends TypeConverter<TradeType, String> {
  const TradeTypeConverter();

  @override
  TradeType fromSql(String fromDb) => TradeType.values.byName(fromDb);

  @override
  String toSql(TradeType value) => value.name;
}
