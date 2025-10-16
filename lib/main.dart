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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final t0 = DateTime.now();
  final db = AppDatabase();

  await GlobalStore().loadFromPrefs();
  final t1 = DateTime.now();
  print('Load prefs time: ${t1.difference(t0).inMilliseconds} ms');
  // 这里提前初始化 userID 和 accountID
  String userId = 'e226aa2d-1680-468c-8a41-33a3dad9874f'; // 自己用的 userId
  int accountId = 1; // 自己用的 accountId
  //String userId = '85963d3d-9b09-4a15-840c-05d1ded31c18'; // 测试用的 userId
  //int accountId = 2; // 测试用的 accountId
  GlobalStore().userId = userId;
  GlobalStore().accountId = accountId;
  GlobalStore().selectedCurrencyCode = 'JPY'; // 默认日元
  await GlobalStore().saveUserIdToPrefs();
  await GlobalStore().saveAccountIdToPrefs();
  await GlobalStore().saveSelectedCurrencyCodeToPrefs();
  final t2 = DateTime.now();
  print(
    'Init userId and accountId time: ${t2.difference(t1).inMilliseconds} ms',
  );

  // 判断是否同步服务器，如果没有同步，则进行同步
  if (GlobalStore().lastSyncTime == null) {
    await AppUtils().syncDataWithSupabase(userId, accountId, db);
    final t3_1 = DateTime.now();
    print('Sync data time: ${t3_1.difference(t2).inMilliseconds} ms');
    await GlobalStore().saveLastSyncTimeToPrefs();
    final t3_2 = DateTime.now();
    print('Save last sync time: ${t3_2.difference(t3_1).inMilliseconds} ms');
  }
  final t3 = DateTime.now();
  print('Sync data time: ${t3.difference(t2).inMilliseconds} ms');

  // 计算持仓并更新到 GlobalStore
  await AppUtils().calculatePortfolioValue(userId, accountId);
  await AppUtils().getStockPricesByYHFinanceAPI();
  await AppUtils().calculateAndSaveHistoricalPortfolioToPrefs();
  final t4 = DateTime.now();
  print('Calculate portfolio time: ${t4.difference(t3).inMilliseconds} ms');

  final marketDataProvider = MarketDataProvider(db);
  final buyRecordsProvider = BuyRecordsProvider(db);
  final stocksProvider = StocksProvider(db);
  await marketDataProvider.loadMarketData();
  await buyRecordsProvider.loadRecords();
  await stocksProvider.loadStocks();
  final t5 = DateTime.now();
  print('Load providers time: ${t5.difference(t4).inMilliseconds} ms');

  final api = BitflyerApi(
    '3XQ54WjxVseYCK8q4MMwpx',
    's/SeVD0jTuK6e5D2wsm7xqdg1pg9+pbCsNhcQARjb0I=',
  );
  fetchOrders(api);

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
  print('[PERF] runApp: ${t6.difference(t5).inMilliseconds} ms');
  print('[PERF] main() total: ${t6.difference(t0).inMilliseconds} ms');
}

void fetchOrders(api) async {
  try {
    final orders = await api.getbalancehistory(count: 10);
    //GlobalStore().textForDebug = orders.toString();
    //await GlobalStore().saveTextForDebugToPrefs();
    print('取得結果: $orders');
  } catch (e) {
    //GlobalStore().textForDebug = 'エラー: $e';
    //await GlobalStore().saveTextForDebugToPrefs();
    print('エラー: $e');
  }
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
