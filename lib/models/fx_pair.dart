import 'package:drift/drift.dart';

enum FxPair {
  usdJpy, // USD/JPY
  // 以后可扩展更多币种对
}

extension FxPairExtension on FxPair {
  int get id {
    switch (this) {
      case FxPair.usdJpy:
        return 1;
    }
  }

  String get baseCurrency {
    switch (this) {
      case FxPair.usdJpy:
        return 'USD';
    }
  }

  String get quoteCurrency {
    switch (this) {
      case FxPair.usdJpy:
        return 'JPY';
    }
  }

  String get symbol {
    switch (this) {
      case FxPair.usdJpy:
        return 'USD/JPY';
    }
  }

  bool get isActive {
    switch (this) {
      case FxPair.usdJpy:
        return true;
    }
  }
}

class FxPairConverter extends TypeConverter<FxPair, int> {
  const FxPairConverter();

  @override
  FxPair fromSql(int fromDb) {
    switch (fromDb) {
      case 1:
        return FxPair.usdJpy;
      default:
        throw ArgumentError('Unknown fx_pair_id: $fromDb');
    }
  }

  @override
  int toSql(FxPair value) => value.id;
}
