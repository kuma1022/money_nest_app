import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';

enum Currency {
  jpy, // 日元
  usd, // 美元
}

extension CurrencyExtension on Currency {
  String displayName(BuildContext context) {
    switch (this) {
      case Currency.jpy:
        return AppLocalizations.of(context)!.currencyJpyLabel;
      case Currency.usd:
        return AppLocalizations.of(context)!.currencyUsdLabel;
    }
  }

  String get code {
    switch (this) {
      case Currency.jpy:
        return 'JPY';
      case Currency.usd:
        return 'USD';
    }
  }

  String get symbol {
    switch (this) {
      case Currency.jpy:
        return '¥';
      case Currency.usd:
        return '\$';
    }
  }

  String get locale {
    switch (this) {
      case Currency.jpy:
        return 'ja_JP';
      case Currency.usd:
        return 'en_US';
    }
  }
}

class CurrencyConverter extends TypeConverter<Currency, String> {
  const CurrencyConverter();

  @override
  Currency fromSql(String fromDb) =>
      Currency.values.byName(fromDb.toLowerCase());

  @override
  String toSql(Currency value) => value.name;
}
