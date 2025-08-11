import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh')
  ];

  /// No description provided for @tradeRecords.
  ///
  /// In en, this message translates to:
  /// **'Trade Records'**
  String get tradeRecords;

  /// No description provided for @confirmDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Confirmation'**
  String get confirmDeleteDialogTitle;

  /// No description provided for @confirmDeleteDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this record?'**
  String get confirmDeleteDialogContent;

  /// No description provided for @confirmDeleteDialogDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get confirmDeleteDialogDelete;

  /// No description provided for @confirmDeleteDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get confirmDeleteDialogCancel;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'发生错误'**
  String get error;

  /// No description provided for @noTradeRecords.
  ///
  /// In en, this message translates to:
  /// **'暂无交易记录'**
  String get noTradeRecords;

  /// No description provided for @tradeTabPageNumber.
  ///
  /// In en, this message translates to:
  /// **'数量'**
  String get tradeTabPageNumber;

  /// No description provided for @tradeTabPagePrice.
  ///
  /// In en, this message translates to:
  /// **'价格'**
  String get tradeTabPagePrice;

  /// No description provided for @mainPageTopTitle.
  ///
  /// In en, this message translates to:
  /// **'TOP'**
  String get mainPageTopTitle;

  /// No description provided for @mainPageTradeTitle.
  ///
  /// In en, this message translates to:
  /// **'交易记录'**
  String get mainPageTradeTitle;

  /// No description provided for @mainPageCashTitle.
  ///
  /// In en, this message translates to:
  /// **'现金仓'**
  String get mainPageCashTitle;

  /// No description provided for @mainPageBookTitle.
  ///
  /// In en, this message translates to:
  /// **'我的账本'**
  String get mainPageBookTitle;

  /// No description provided for @mainPageWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'总资产'**
  String get mainPageWalletTitle;

  /// No description provided for @mainPageMoreTitle.
  ///
  /// In en, this message translates to:
  /// **'更多'**
  String get mainPageMoreTitle;

  /// No description provided for @mainPageSearch.
  ///
  /// In en, this message translates to:
  /// **'搜索'**
  String get mainPageSearch;

  /// No description provided for @mainPageSearchCancel.
  ///
  /// In en, this message translates to:
  /// **'取消'**
  String get mainPageSearchCancel;

  /// No description provided for @tradeAddPageTitle.
  ///
  /// In en, this message translates to:
  /// **'添加交易记录'**
  String get tradeAddPageTitle;

  /// No description provided for @tradeAddPageTradeDateLabel.
  ///
  /// In en, this message translates to:
  /// **'交易时间'**
  String get tradeAddPageTradeDateLabel;

  /// No description provided for @tradeAddPageTradeDatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'请选择日期'**
  String get tradeAddPageTradeDatePlaceholder;

  /// No description provided for @tradeAddPageActionLabel.
  ///
  /// In en, this message translates to:
  /// **'操作'**
  String get tradeAddPageActionLabel;

  /// No description provided for @tradeAddPageActionError.
  ///
  /// In en, this message translates to:
  /// **'请选择操作'**
  String get tradeAddPageActionError;

  /// No description provided for @tradeAddPageCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'类型'**
  String get tradeAddPageCategoryLabel;

  /// No description provided for @tradeAddPageCategoryError.
  ///
  /// In en, this message translates to:
  /// **'请选择类型'**
  String get tradeAddPageCategoryError;

  /// No description provided for @tradeAddPageTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'交易类别'**
  String get tradeAddPageTypeLabel;

  /// No description provided for @tradeAddPageTypeError.
  ///
  /// In en, this message translates to:
  /// **'请选择交易类别'**
  String get tradeAddPageTypeError;

  /// No description provided for @tradeAddPageNameLabel.
  ///
  /// In en, this message translates to:
  /// **'名称'**
  String get tradeAddPageNameLabel;

  /// No description provided for @tradeAddPageNameError.
  ///
  /// In en, this message translates to:
  /// **'请输入名称'**
  String get tradeAddPageNameError;

  /// No description provided for @tradeAddPageCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'代码'**
  String get tradeAddPageCodeLabel;

  /// No description provided for @tradeAddPageQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'数量'**
  String get tradeAddPageQuantityLabel;

  /// No description provided for @tradeAddPageQuantityError.
  ///
  /// In en, this message translates to:
  /// **'请输入数量'**
  String get tradeAddPageQuantityError;

  /// No description provided for @tradeAddPageCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'货币'**
  String get tradeAddPageCurrencyLabel;

  /// No description provided for @tradeAddPageCurrencyError.
  ///
  /// In en, this message translates to:
  /// **'请选择货币'**
  String get tradeAddPageCurrencyError;

  /// No description provided for @tradeAddPagePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'单价'**
  String get tradeAddPagePriceLabel;

  /// No description provided for @tradeAddPagePriceError.
  ///
  /// In en, this message translates to:
  /// **'请输入单价'**
  String get tradeAddPagePriceError;

  /// No description provided for @tradeAddPageRateLabel.
  ///
  /// In en, this message translates to:
  /// **'汇率'**
  String get tradeAddPageRateLabel;

  /// No description provided for @tradeAddPageRateError.
  ///
  /// In en, this message translates to:
  /// **'请输入汇率'**
  String get tradeAddPageRateError;

  /// No description provided for @tradeAddPageRemarkLabel.
  ///
  /// In en, this message translates to:
  /// **'备注'**
  String get tradeAddPageRemarkLabel;

  /// No description provided for @tradeAddPageSaveLabel.
  ///
  /// In en, this message translates to:
  /// **'保存'**
  String get tradeAddPageSaveLabel;

  /// No description provided for @tradeAddPageBuyTab.
  ///
  /// In en, this message translates to:
  /// **'买入'**
  String get tradeAddPageBuyTab;

  /// No description provided for @tradeAddPageSellTab.
  ///
  /// In en, this message translates to:
  /// **'卖出'**
  String get tradeAddPageSellTab;

  /// No description provided for @tradeDetailPageTitle.
  ///
  /// In en, this message translates to:
  /// **'交易记录详情'**
  String get tradeDetailPageTitle;

  /// No description provided for @tradeDetailPageTradeDateLabel.
  ///
  /// In en, this message translates to:
  /// **'交易时间'**
  String get tradeDetailPageTradeDateLabel;

  /// No description provided for @tradeDetailPageActionLabel.
  ///
  /// In en, this message translates to:
  /// **'操作'**
  String get tradeDetailPageActionLabel;

  /// No description provided for @tradeDetailPageCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'类型'**
  String get tradeDetailPageCategoryLabel;

  /// No description provided for @tradeDetailPageTradeTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'交易类别'**
  String get tradeDetailPageTradeTypeLabel;

  /// No description provided for @tradeDetailPageNameLabel.
  ///
  /// In en, this message translates to:
  /// **'名称'**
  String get tradeDetailPageNameLabel;

  /// No description provided for @tradeDetailPageCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'代码'**
  String get tradeDetailPageCodeLabel;

  /// No description provided for @tradeDetailPageNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'数量'**
  String get tradeDetailPageNumberLabel;

  /// No description provided for @tradeDetailPageCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'货币'**
  String get tradeDetailPageCurrencyLabel;

  /// No description provided for @tradeDetailPagePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'单价'**
  String get tradeDetailPagePriceLabel;

  /// No description provided for @tradeDetailPageRateLabel.
  ///
  /// In en, this message translates to:
  /// **'汇率'**
  String get tradeDetailPageRateLabel;

  /// No description provided for @tradeDetailPageRemarkLabel.
  ///
  /// In en, this message translates to:
  /// **'备注'**
  String get tradeDetailPageRemarkLabel;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ja': return AppLocalizationsJa();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
