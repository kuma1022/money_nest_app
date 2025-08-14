import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';

enum Currency {
  jpy, // 日元
  usd, // 美元
  cny, // 人民币
  hkd, // 港币
}

extension CurrencyExtension on Currency {
  String displayName(BuildContext context) {
    switch (this) {
      case Currency.jpy:
        return AppLocalizations.of(context)!.currencyJpyLabel;
      case Currency.usd:
        return AppLocalizations.of(context)!.currencyUsdLabel;
      case Currency.cny:
        return AppLocalizations.of(context)!.currencyCnyLabel;
      case Currency.hkd:
        return AppLocalizations.of(context)!.currencyHkdLabel;
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
