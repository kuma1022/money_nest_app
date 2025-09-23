import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:money_nest_app/presentation/resources/app_resources.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:money_nest_app/util/global_store.dart';
import 'package:money_nest_app/util/provider/buy_records_provider.dart';
import 'package:money_nest_app/util/provider/market_data_provider.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/pages/main_page.dart';
import 'package:money_nest_app/util/provider/portfolio_provider.dart';
import 'package:money_nest_app/util/provider/stocks_provider.dart';
import 'package:money_nest_app/util/provider/total_asset_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();

  await GlobalStore().loadFromPrefs();
  // 这里提前初始化 userID 和 accountID
  String userId = 'e226aa2d-1680-468c-8a41-33a3dad9874f'; // 测试用的 userId
  int accountId = 1; // 测试用的 accountId
  GlobalStore().userId = userId;
  GlobalStore().accountId = accountId;
  GlobalStore().selectedCurrencyCode = 'JPY'; // 默认日元
  await GlobalStore().saveUserIdToPrefs();
  await GlobalStore().saveAccountIdToPrefs();
  await GlobalStore().saveSelectedCurrencyCodeToPrefs();
  // 计算持仓并更新到 GlobalStore
  await AppUtils().calculatePortfolioValue(userId, accountId, db);
  await AppUtils().getStockPricesByYHFinanceAPI(db);

  final marketDataProvider = MarketDataProvider(db);
  final buyRecordsProvider = BuyRecordsProvider(db);
  final stocksProvider = StocksProvider(db);
  await marketDataProvider.loadMarketData();
  await buyRecordsProvider.loadRecords();
  await stocksProvider.loadStocks();
  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: db),
        ChangeNotifierProvider<MarketDataProvider>.value(
          value: marketDataProvider,
        ),
        ChangeNotifierProvider<BuyRecordsProvider>.value(
          value: buyRecordsProvider,
        ),
        ChangeNotifierProvider<StocksProvider>.value(value: stocksProvider),
        ChangeNotifierProvider(create: (_) => TotalAssetProvider()),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
      ],
      child: MyApp(db: db),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppDatabase db;
  const MyApp({super.key, required this.db});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppTexts.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.appWhite, // 整体背景颜色
        fontFamily: 'NotoSansJP', // 日文
        fontFamilyFallback: [
          'NotoSansSC', // 简体中文
          'NotoSansTC', // 繁体中文
          'NotoSans', // 英文
          'Roboto',
          'sans-serif',
        ],
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // 英文
        Locale('zh'), // 中文
        Locale('ja'), // 日文
      ],
      home: MainPage(db: db),
    );
  }
}
