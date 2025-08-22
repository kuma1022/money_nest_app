import 'package:flutter/material.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';

String getL10nString(BuildContext context, String key) {
  final l10n = AppLocalizations.of(context)!;
  final map = <String, String>{
    'marketDataJpLabel': l10n.marketDataJpLabel,
    'marketDataUsLabel': l10n.marketDataUsLabel,
    'marketDataFundLabel': l10n.marketDataFundLabel,
    'marketDataEtfLabel': l10n.marketDataEtfLabel,
    'marketDataOptionLabel': l10n.marketDataOptionLabel,
    'marketDataCryptoLabel': l10n.marketDataCryptoLabel,
    'marketDataForexLabel': l10n.marketDataForexLabel,
    'marketDataShszLabel': l10n.marketDataShszLabel,
    'marketDataHkLabel': l10n.marketDataHkLabel,
    'marketDataOtherLabel': l10n.marketDataOtherLabel,
    // ...按需添加其它key
  };
  return map[key] ?? key;
}
