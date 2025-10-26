import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:money_nest_app/presentation/resources/app_resources.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:money_nest_app/util/bitflyer_api.dart';
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
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final t0 = DateTime.now();
  final db = AppDatabase();

  await GlobalStore().loadFromPrefs();
  //final t1 = DateTime.now();
  //print('Load prefs time: ${t1.difference(t0).inMilliseconds} ms');
  // 这里提前初始化 userID 和 accountID
  //String userId = 'e226aa2d-1680-468c-8a41-33a3dad9874f'; // 自己用的 userId
  //int accountId = 1; // 自己用的 accountId
  //GlobalStore().userId = userId;
  //GlobalStore().accountId = accountId;
  //GlobalStore().selectedCurrencyCode = 'JPY'; // 默认日元
  //GlobalStore().cryptoApiKeys = {
  //  'bitflyer': {
  //    'apiKey': '3XQ54WjxVseYCK8q4MMwpx',
  //    'apiSecret': 's/SeVD0jTuK6e5D2wsm7xqdg1pg9+pbCsNhcQARjb0I=',
  //  },
  //};
  //await GlobalStore().saveUserIdToPrefs();
  //await GlobalStore().saveAccountIdToPrefs();
  //await GlobalStore().saveSelectedCurrencyCodeToPrefs();
  //await GlobalStore().saveCryptoApiKeysToPrefs();

  final t2 = DateTime.now();
  //print(
  //  'Init userId and accountId time: ${t2.difference(t1).inMilliseconds} ms',
  //);

  final marketDataProvider = MarketDataProvider(db);
  final buyRecordsProvider = BuyRecordsProvider(db);
  final stocksProvider = StocksProvider(db);
  await marketDataProvider.loadMarketData();
  await buyRecordsProvider.loadRecords();
  await stocksProvider.loadStocks();

  WidgetsFlutterBinding.ensureInitialized();
  // 初始化 Supabase
  await Supabase.initialize(
    url: 'https://yeciaqfdlznrstjhqfxu.supabase.co', // 替换为你的 Supabase URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InllY2lhcWZkbHpucnN0amhxZnh1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MDE3NTIsImV4cCI6MjA3MTk3Nzc1Mn0.QXWNGKbr9qjeBLYRWQHEEBMT1nfNKZS3vne-Za38bOc', // 替换为你的 Supabase anon key
  );

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
  final t6 = DateTime.now();
  print('[PERF] runApp: ${t6.difference(t2).inMilliseconds} ms');
  print('[PERF] main() total: ${t6.difference(t0).inMilliseconds} ms');
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
