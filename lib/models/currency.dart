import 'package:drift/drift.dart';

enum Currency {
  jpy, // 日元
  usd, // 美元
  cny, // 人民币
  hkd, // 港币
}

extension CurrencyExtension on Currency {
  String get displayName {
    switch (this) {
      case Currency.jpy:
        return 'JPY';
      case Currency.usd:
        return 'USD';
      case Currency.cny:
        return 'CNY';
      case Currency.hkd:
        return 'HKD';
    }
  }
}

class CurrencyConverter extends TypeConverter<Currency, String> {
  const CurrencyConverter();

  @override
  Currency fromSql(String fromDb) => Currency.values.byName(fromDb);

  @override
  String toSql(Currency value) => value.name;
}
