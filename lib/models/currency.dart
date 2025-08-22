import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';

enum Currency {
  JPY, // 日元
  USD, // 美元
  CNY, // 人民币
  HKD, // 港币
}

extension CurrencyExtension on Currency {
  String displayName(BuildContext context) {
    switch (this) {
      case Currency.JPY:
        return AppLocalizations.of(context)!.currencyJpyLabel;
      case Currency.USD:
        return AppLocalizations.of(context)!.currencyUsdLabel;
      case Currency.CNY:
        return AppLocalizations.of(context)!.currencyCnyLabel;
      case Currency.HKD:
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
