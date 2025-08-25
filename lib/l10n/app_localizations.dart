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
  /// **'交易记录'**
  String get tradeRecords;

  /// No description provided for @confirmDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'确认删除'**
  String get confirmDeleteDialogTitle;

  /// No description provided for @confirmDeleteDialogContent.
  ///
  /// In en, this message translates to:
  /// **'确定要删除这条记录吗？'**
  String get confirmDeleteDialogContent;

  /// No description provided for @confirmDeleteDialogDelete.
  ///
  /// In en, this message translates to:
  /// **'删除'**
  String get confirmDeleteDialogDelete;

  /// No description provided for @confirmDeleteDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'取消'**
  String get confirmDeleteDialogCancel;

  /// No description provided for @marketDataJpLabel.
  ///
  /// In en, this message translates to:
  /// **'日股'**
  String get marketDataJpLabel;

  /// No description provided for @marketDataUsLabel.
  ///
  /// In en, this message translates to:
  /// **'美股'**
  String get marketDataUsLabel;

  /// No description provided for @marketDataFundLabel.
  ///
  /// In en, this message translates to:
  /// **'基金'**
  String get marketDataFundLabel;

  /// No description provided for @marketDataEtfLabel.
  ///
  /// In en, this message translates to:
  /// **'ETF'**
  String get marketDataEtfLabel;

  /// No description provided for @marketDataOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'期权'**
  String get marketDataOptionLabel;

  /// No description provided for @marketDataCryptoLabel.
  ///
  /// In en, this message translates to:
  /// **'加密货币'**
  String get marketDataCryptoLabel;

  /// No description provided for @marketDataForexLabel.
  ///
  /// In en, this message translates to:
  /// **'外汇'**
  String get marketDataForexLabel;

  /// No description provided for @marketDataShszLabel.
  ///
  /// In en, this message translates to:
  /// **'沪深'**
  String get marketDataShszLabel;

  /// No description provided for @marketDataHkLabel.
  ///
  /// In en, this message translates to:
  /// **'港股'**
  String get marketDataHkLabel;

  /// No description provided for @marketDataOtherLabel.
  ///
  /// In en, this message translates to:
  /// **'其他'**
  String get marketDataOtherLabel;

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

  /// No description provided for @mainPageAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'账户'**
  String get mainPageAccountTitle;

  /// No description provided for @mainPageTradeTitle.
  ///
  /// In en, this message translates to:
  /// **'交易记录'**
  String get mainPageTradeTitle;

  /// No description provided for @mainPageMarketTitle.
  ///
  /// In en, this message translates to:
  /// **'市场'**
  String get mainPageMarketTitle;

  /// No description provided for @mainPageMoreTitle.
  ///
  /// In en, this message translates to:
  /// **'更多'**
  String get mainPageMoreTitle;

  /// No description provided for @mainPageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'输入名称或代码搜索'**
  String get mainPageSearchHint;

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
  /// **'日期'**
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
  /// **'市场'**
  String get tradeAddPageCategoryLabel;

  /// No description provided for @tradeAddPageCategoryError.
  ///
  /// In en, this message translates to:
  /// **'请选择市场'**
  String get tradeAddPageCategoryError;

  /// No description provided for @tradeAddPageTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'类别'**
  String get tradeAddPageTypeLabel;

  /// No description provided for @tradeAddPageTypeError.
  ///
  /// In en, this message translates to:
  /// **'请选择类别'**
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
  /// **'交易货币'**
  String get tradeAddPageCurrencyLabel;

  /// No description provided for @tradeAddPageCurrencyError.
  ///
  /// In en, this message translates to:
  /// **'请选择币种'**
  String get tradeAddPageCurrencyError;

  /// No description provided for @tradeAddPagePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'交易单价'**
  String get tradeAddPagePriceLabel;

  /// No description provided for @tradeAddPagePriceError.
  ///
  /// In en, this message translates to:
  /// **'请输入单价'**
  String get tradeAddPagePriceError;

  /// No description provided for @tradeAddPageTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'交易总额'**
  String get tradeAddPageTotalLabel;

  /// No description provided for @tradeAddPageCurrencyUsedBuyLabel.
  ///
  /// In en, this message translates to:
  /// **'结算货币'**
  String get tradeAddPageCurrencyUsedBuyLabel;

  /// No description provided for @tradeAddPageCurrencyUsedSellLabel.
  ///
  /// In en, this message translates to:
  /// **'到账货币'**
  String get tradeAddPageCurrencyUsedSellLabel;

  /// No description provided for @tradeAddPageMoneyUsedBuyLabel.
  ///
  /// In en, this message translates to:
  /// **'结算金额'**
  String get tradeAddPageMoneyUsedBuyLabel;

  /// No description provided for @tradeAddPageMoneyUsedSellLabel.
  ///
  /// In en, this message translates to:
  /// **'到账金额'**
  String get tradeAddPageMoneyUsedSellLabel;

  /// No description provided for @tradeAddPageMoneyUsedBuyPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'请输入结算金额'**
  String get tradeAddPageMoneyUsedBuyPlaceholder;

  /// No description provided for @tradeAddPageMoneyUsedSellPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'请输入到账金额'**
  String get tradeAddPageMoneyUsedSellPlaceholder;

  /// No description provided for @tradeAddPageMoneyUsedBuyError.
  ///
  /// In en, this message translates to:
  /// **'请输入结算金额'**
  String get tradeAddPageMoneyUsedBuyError;

  /// No description provided for @tradeAddPageMoneyUsedSellError.
  ///
  /// In en, this message translates to:
  /// **'请输入到账金额'**
  String get tradeAddPageMoneyUsedSellError;

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
  /// **'日期'**
  String get tradeDetailPageTradeDateLabel;

  /// No description provided for @tradeDetailPageActionLabel.
  ///
  /// In en, this message translates to:
  /// **'操作'**
  String get tradeDetailPageActionLabel;

  /// No description provided for @tradeDetailPageCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'市场'**
  String get tradeDetailPageCategoryLabel;

  /// No description provided for @tradeDetailPageTradeTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'类别'**
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
  /// **'币种'**
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

  /// No description provided for @tradeEditPageTitle.
  ///
  /// In en, this message translates to:
  /// **'编辑交易记录'**
  String get tradeEditPageTitle;

  /// No description provided for @tradeEditPageTradeDateLabel.
  ///
  /// In en, this message translates to:
  /// **'日期'**
  String get tradeEditPageTradeDateLabel;

  /// No description provided for @tradeEditPageActionLabel.
  ///
  /// In en, this message translates to:
  /// **'操作'**
  String get tradeEditPageActionLabel;

  /// No description provided for @tradeEditPageActionError.
  ///
  /// In en, this message translates to:
  /// **'请选择动作'**
  String get tradeEditPageActionError;

  /// No description provided for @tradeEditPageCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'市场'**
  String get tradeEditPageCategoryLabel;

  /// No description provided for @tradeEditPageCategoryError.
  ///
  /// In en, this message translates to:
  /// **'请选择市场'**
  String get tradeEditPageCategoryError;

  /// No description provided for @tradeEditPageTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'类别'**
  String get tradeEditPageTypeLabel;

  /// No description provided for @tradeEditPageTypeError.
  ///
  /// In en, this message translates to:
  /// **'请选择类别'**
  String get tradeEditPageTypeError;

  /// No description provided for @tradeEditPageNameLabel.
  ///
  /// In en, this message translates to:
  /// **'名称'**
  String get tradeEditPageNameLabel;

  /// No description provided for @tradeEditPageNameError.
  ///
  /// In en, this message translates to:
  /// **'请输入名称'**
  String get tradeEditPageNameError;

  /// No description provided for @tradeEditPageCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'代码'**
  String get tradeEditPageCodeLabel;

  /// No description provided for @tradeEditPageQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'数量'**
  String get tradeEditPageQuantityLabel;

  /// No description provided for @tradeEditPageCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'币种'**
  String get tradeEditPageCurrencyLabel;

  /// No description provided for @tradeEditPageCurrencyError.
  ///
  /// In en, this message translates to:
  /// **'请选择币种'**
  String get tradeEditPageCurrencyError;

  /// No description provided for @tradeEditPagePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'单价'**
  String get tradeEditPagePriceLabel;

  /// No description provided for @tradeEditPageRateLabel.
  ///
  /// In en, this message translates to:
  /// **'汇率'**
  String get tradeEditPageRateLabel;

  /// No description provided for @tradeEditPageRemarkLabel.
  ///
  /// In en, this message translates to:
  /// **'备注'**
  String get tradeEditPageRemarkLabel;

  /// No description provided for @tradeEditPageSaveLabel.
  ///
  /// In en, this message translates to:
  /// **'保存'**
  String get tradeEditPageSaveLabel;

  /// No description provided for @tradeEditPageEditToolTip.
  ///
  /// In en, this message translates to:
  /// **'编辑'**
  String get tradeEditPageEditToolTip;

  /// No description provided for @tradeEditPageCancelToolTip.
  ///
  /// In en, this message translates to:
  /// **'取消'**
  String get tradeEditPageCancelToolTip;

  /// No description provided for @tradeEditPageUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'保存'**
  String get tradeEditPageUpdateButton;

  /// No description provided for @tradeEditPageQuantityError.
  ///
  /// In en, this message translates to:
  /// **'请输入数量'**
  String get tradeEditPageQuantityError;

  /// No description provided for @tradeEditPageCurrencyPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'请选择币种'**
  String get tradeEditPageCurrencyPlaceholder;

  /// No description provided for @tradeDetailPagePriceError.
  ///
  /// In en, this message translates to:
  /// **'请输入单价'**
  String get tradeDetailPagePriceError;

  /// No description provided for @tradeDetailPageRateError.
  ///
  /// In en, this message translates to:
  /// **'请输入汇率'**
  String get tradeDetailPageRateError;

  /// No description provided for @tradeDetailPageRemarkPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'（任意）输入备注'**
  String get tradeDetailPageRemarkPlaceholder;

  /// No description provided for @tradeDetailPageUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'更新成功'**
  String get tradeDetailPageUpdateSuccess;

  /// No description provided for @buyPositionSelectionPageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'输入名称或代码搜索'**
  String get buyPositionSelectionPageSearchHint;

  /// No description provided for @buyPositionSelectionPageConfirm.
  ///
  /// In en, this message translates to:
  /// **'确认选择'**
  String get buyPositionSelectionPageConfirm;

  /// No description provided for @buyPositionSelectionPageBackToSearch.
  ///
  /// In en, this message translates to:
  /// **'返回搜索'**
  String get buyPositionSelectionPageBackToSearch;

  /// No description provided for @tradeAddPageSellDateError.
  ///
  /// In en, this message translates to:
  /// **'卖出日期不能早于买入日期'**
  String get tradeAddPageSellDateError;

  /// No description provided for @tradeAddPageBuyPositionSelection.
  ///
  /// In en, this message translates to:
  /// **'选择要卖出的持仓'**
  String get tradeAddPageBuyPositionSelection;

  /// No description provided for @tradeAddPageSelectedPositions.
  ///
  /// In en, this message translates to:
  /// **'已选择持仓'**
  String get tradeAddPageSelectedPositions;

  /// No description provided for @currencyJpyLabel.
  ///
  /// In en, this message translates to:
  /// **'JPY'**
  String get currencyJpyLabel;

  /// No description provided for @currencyUsdLabel.
  ///
  /// In en, this message translates to:
  /// **'USD'**
  String get currencyUsdLabel;

  /// No description provided for @currencyCnyLabel.
  ///
  /// In en, this message translates to:
  /// **'CNY'**
  String get currencyCnyLabel;

  /// No description provided for @currencyHkdLabel.
  ///
  /// In en, this message translates to:
  /// **'HKD'**
  String get currencyHkdLabel;

  /// No description provided for @tradeActionBuyLabel.
  ///
  /// In en, this message translates to:
  /// **'买入'**
  String get tradeActionBuyLabel;

  /// No description provided for @tradeActionSellLabel.
  ///
  /// In en, this message translates to:
  /// **'卖出'**
  String get tradeActionSellLabel;

  /// No description provided for @tradeAddPageEditSelectedPositions.
  ///
  /// In en, this message translates to:
  /// **'修改'**
  String get tradeAddPageEditSelectedPositions;

  /// No description provided for @tradeAddPageConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'确定'**
  String get tradeAddPageConfirmLabel;

  /// No description provided for @tradeAddPageCancelLabel.
  ///
  /// In en, this message translates to:
  /// **'取消'**
  String get tradeAddPageCancelLabel;

  /// No description provided for @tradeAddPageTypePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'请选择类别'**
  String get tradeAddPageTypePlaceholder;

  /// No description provided for @tradeAddPageCategoryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'请选择市场'**
  String get tradeAddPageCategoryPlaceholder;

  /// No description provided for @tradeAddPageNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'请输入名称'**
  String get tradeAddPageNamePlaceholder;

  /// No description provided for @tradeAddPageCodePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'请输入代码'**
  String get tradeAddPageCodePlaceholder;

  /// No description provided for @tradeAddPageQuantityPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'请输入数量'**
  String get tradeAddPageQuantityPlaceholder;

  /// No description provided for @tradeAddPageCurrencyPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'请选择币种'**
  String get tradeAddPageCurrencyPlaceholder;

  /// No description provided for @tradeAddPagePricePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'请输入单价'**
  String get tradeAddPagePricePlaceholder;

  /// No description provided for @tradeAddPageRatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'请输入汇率'**
  String get tradeAddPageRatePlaceholder;

  /// No description provided for @tradeAddPageRemarkPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'（任意）输入备注'**
  String get tradeAddPageRemarkPlaceholder;

  /// No description provided for @totalCapitalTabPageTotalTitle.
  ///
  /// In en, this message translates to:
  /// **'总资产额'**
  String get totalCapitalTabPageTotalTitle;

  /// No description provided for @totalCapitalTabPageCashExcluedLabel.
  ///
  /// In en, this message translates to:
  /// **'现金除外'**
  String get totalCapitalTabPageCashExcluedLabel;

  /// No description provided for @totalCapitalTabPageCurrentProfitAndLossLabel.
  ///
  /// In en, this message translates to:
  /// **'当前盈亏'**
  String get totalCapitalTabPageCurrentProfitAndLossLabel;

  /// No description provided for @totalCapitalTabPageTotalRateTitle.
  ///
  /// In en, this message translates to:
  /// **'资产构成比率'**
  String get totalCapitalTabPageTotalRateTitle;

  /// No description provided for @accountTabPageTotalMoneyTitle.
  ///
  /// In en, this message translates to:
  /// **'总资产  ·  '**
  String get accountTabPageTotalMoneyTitle;

  /// No description provided for @accountTabPageAccountAnalyseLabel.
  ///
  /// In en, this message translates to:
  /// **'资产分析 >'**
  String get accountTabPageAccountAnalyseLabel;

  /// No description provided for @accountTabPageRefreshStatusIdleLabel.
  ///
  /// In en, this message translates to:
  /// **'下拉刷新'**
  String get accountTabPageRefreshStatusIdleLabel;

  /// No description provided for @accountTabPageRefreshStatusCanRefreshLabel.
  ///
  /// In en, this message translates to:
  /// **'释放立即刷新'**
  String get accountTabPageRefreshStatusCanRefreshLabel;

  /// No description provided for @accountTabPageRefreshStatusRefreshingLabel.
  ///
  /// In en, this message translates to:
  /// **'刷新中...'**
  String get accountTabPageRefreshStatusRefreshingLabel;

  /// No description provided for @accountTabPageRefreshStatusCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'刷新完成'**
  String get accountTabPageRefreshStatusCompletedLabel;

  /// No description provided for @accountTabPageUpadateAtTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'更新时间'**
  String get accountTabPageUpadateAtTimeLabel;

  /// No description provided for @accountTabPageStockWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'持仓'**
  String get accountTabPageStockWalletTitle;
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
