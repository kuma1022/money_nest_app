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

  String get code {
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

  String get symbol {
    switch (this) {
      case Currency.jpy:
        return '¥';
      case Currency.usd:
        return '\$';
      case Currency.cny:
        return '¥';
      case Currency.hkd:
        return '\$';
    }
  }

  String get locale {
    switch (this) {
      case Currency.jpy:
        return 'ja_JP';
      case Currency.usd:
        return 'en_US';
      case Currency.cny:
        return 'zh_CN';
      case Currency.hkd:
        return 'zh_HK';
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
