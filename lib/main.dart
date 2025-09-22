import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/models/trade_action.dart';
import 'package:money_nest_app/models/trade_type.dart';
import 'package:money_nest_app/presentation/resources/app_resources.dart';
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

  // 这里提前初始化 userID 和 accountID
  GlobalStore().userId = 'e226aa2d-1680-468c-8a41-33a3dad9874f'; // 测试用的 userId
  GlobalStore().accountId = 1; // 测试用的 accountId

  // 这里提前初始化 marketData
  //await _initDefaultCategories(db);
  // 这里提前初始化 stocks
  //await _initDefaultStocks(db);
  // 这里提前初始化 buyRecords（为了测试）
  //await _initDefaultBuyRecords(db);

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
/*
Future<void> _initDefaultCategories(AppDatabase db) async {
  final count = await db.select(db.marketData).get();
  if (count.isEmpty) {
    await db
        .into(db.marketData)
        .insert(
          MarketDataCompanion.insert(
            code: 'JP',
            name: 'marketDataJpLabel',
            currency: Value('JPY'),
            surfix: Value('.T'),
            colorHex: Value(0xFF21CBF3),
            sortOrder: Value(1),
            isActive: Value(true),
          ),
        );
    await db
        .into(db.marketData)
        .insert(
          MarketDataCompanion.insert(
            code: 'US',
            name: 'marketDataUsLabel',
            currency: Value('USD'),
            surfix: Value(''),
            colorHex: Value(0xFF21F3B2),
            sortOrder: Value(2),
            isActive: Value(true),
          ),
        );
    await db
        .into(db.marketData)
        .insert(
          MarketDataCompanion.insert(
            code: 'FUND',
            name: 'marketDataFundLabel',
            currency: Value(''),
            surfix: Value(''),
            colorHex: Value(0xFFB221F3),
            sortOrder: Value(3),
            isActive: Value(true),
          ),
        );
    await db
        .into(db.marketData)
        .insert(
          MarketDataCompanion.insert(
            code: 'ETF',
            name: 'marketDataEtfLabel',
            currency: Value(''),
            surfix: Value(''),
            colorHex: Value(0xFFF3B221),
            sortOrder: Value(4),
            isActive: Value(true),
          ),
        );
    await db
        .into(db.marketData)
        .insert(
          MarketDataCompanion.insert(
            code: 'OPTION',
            name: 'marketDataOptionLabel',
            currency: Value(''),
            surfix: Value(''),
            colorHex: Value(0xFFF3E721),
            sortOrder: Value(5),
            isActive: Value(true),
          ),
        );
    await db
        .into(db.marketData)
        .insert(
          MarketDataCompanion.insert(
            code: 'CRYPTO',
            name: 'marketDataCryptoLabel',
            currency: Value(''),
            surfix: Value('-USD'),
            colorHex: Value(0xFF7E21F3),
            sortOrder: Value(6),
            isActive: Value(true),
          ),
        );
    await db
        .into(db.marketData)
        .insert(
          MarketDataCompanion.insert(
            code: 'FOREX',
            name: 'marketDataForexLabel',
            currency: Value(''),
            surfix: Value('=X'),
            colorHex: Value(0xFF96F321),
            sortOrder: Value(7),
            isActive: Value(true),
          ),
        );
    await db
        .into(db.marketData)
        .insert(
          MarketDataCompanion.insert(
            code: 'HK',
            name: 'marketDataHkLabel',
            currency: Value('HKD'),
            surfix: Value('.HK'),
            colorHex: Value(0xFFBFBFBF),
            sortOrder: Value(8),
            isActive: Value(true),
          ),
        );
    await db
        .into(db.marketData)
        .insert(
          MarketDataCompanion.insert(
            code: 'OTHER',
            name: 'marketDataOtherLabel',
            currency: Value(''),
            colorHex: Value(0xFFD1BFD1),
            sortOrder: Value(10),
            isActive: Value(true),
          ),
        );
  }
}
*/
/*Future<void> _initDefaultStocks(AppDatabase db) async {
  for (final fromCurrency in Currency.values) {
    for (final toCurrency in Currency.values) {
      if (fromCurrency == toCurrency) continue;
      // 这里提前初始化 stocks（fromCurrency, toCurrency）
      final code = fromCurrency.code == Currency.usd.code
          ? toCurrency.code
          : '${fromCurrency.code}${toCurrency.code}';
      // 判断是否已经存在数据
      final isExists = await db.isStockExists(code);
      if (isExists) continue;
      await db
          .into(db.stocks)
          .insert(
            StocksCompanion.insert(
              code: code,
              name: code,
              marketCode: 'FOREX',
              currency: toCurrency.code,
            ),
          );
    }
  }
}*/

Future<void> _initDefaultBuyRecords(AppDatabase db) async {
  if ((await db.select(db.tradeRecords).get()).isNotEmpty) {
    return;
  }
  final stockData = [
    {
      'code': '7453',
      'name': '良品计划',
      'marketCode': 'JP',
      'currencyCode': Currency.jpy.code,
    },
    {
      'code': 'KO',
      'name': '可口可乐',
      'marketCode': 'US',
      'currencyCode': Currency.usd.code,
    },
    {
      'code': 'UNH',
      'name': '联合健康',
      'marketCode': 'US',
      'currencyCode': Currency.usd.code,
    },
    {
      'code': 'BABA',
      'name': '阿里巴巴',
      'marketCode': 'US',
      'currencyCode': Currency.usd.code,
    },
    {
      'code': 'ACN',
      'name': '埃森哲',
      'marketCode': 'US',
      'currencyCode': Currency.usd.code,
    },
    {
      'code': 'AAPL',
      'name': '苹果',
      'marketCode': 'US',
      'currencyCode': Currency.usd.code,
    },
    {
      'code': 'TSLA',
      'name': '特斯拉',
      'marketCode': 'US',
      'currencyCode': Currency.usd.code,
    },
    {
      'code': 'NVDA',
      'name': '英伟达',
      'marketCode': 'US',
      'currencyCode': Currency.usd.code,
    },
    {
      'code': 'WRD',
      'name': '文远知行',
      'marketCode': 'US',
      'currencyCode': Currency.usd.code,
    },
    {
      'code': 'PONY',
      'name': '小马智行',
      'marketCode': 'US',
      'currencyCode': Currency.usd.code,
    },
    {
      'code': 'BRK-B',
      'name': '伯克希尔-B',
      'marketCode': 'US',
      'currencyCode': Currency.usd.code,
    },
    {
      'code': 'COST',
      'name': '好市多',
      'marketCode': 'US',
      'currencyCode': Currency.usd.code,
    },
    {
      'code': 'QQQ',
      'name': '纳指100ETF',
      'marketCode': 'US',
      'currencyCode': Currency.usd.code,
    },
    {
      'code': 'VOO',
      'name': '标普500ETF',
      'marketCode': 'US',
      'currencyCode': Currency.usd.code,
    },
    {
      'code': '2432',
      'name': 'DeNA',
      'marketCode': 'JP',
      'currencyCode': Currency.jpy.code,
    },
    {
      'code': '1306',
      'name': 'TOPIX連動型上場投信',
      'marketCode': 'JP',
      'currencyCode': Currency.jpy.code,
    },
    {
      'code': '1489',
      'name': '日経平均高配当株50指数連動型上場投信',
      'marketCode': 'JP',
      'currencyCode': Currency.jpy.code,
    },
    {
      'code': '3269',
      'name': 'アドバンス・レジデンス投資法人 投資証券',
      'marketCode': 'JP',
      'currencyCode': Currency.jpy.code,
    },
    {
      'code': '8953',
      'name': '日本都市ファンド投資法人 投資証券',
      'marketCode': 'JP',
      'currencyCode': Currency.jpy.code,
    },
    {
      'code': '8963',
      'name': 'インヴィンシブル投資法人',
      'marketCode': 'JP',
      'currencyCode': Currency.jpy.code,
    },
  ];

  /*for (final s in stockData) {
    await db
        .into(db.stocks)
        .insert(
          StocksCompanion.insert(
            code: s['code'] ?? '',
            name: s['name'] ?? '',
            marketCode: s['marketCode'] ?? '',
            currency: s['currencyCode'] ?? '',
          ),
        );
  }*/

  final tradeRecordList = [
    {
      'tradeDate': DateTime(2025, 7, 23),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'JP',
      'code': '7453',
      'quantity': 100,
      'price': 6800,
      'currency': Currency.jpy,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 680000,
    },
    {
      'tradeDate': DateTime(2025, 7, 28),
      'action': TradeAction.sell,
      'tradeType': TradeType.normal,
      'marketCode': 'JP',
      'code': '7453',
      'quantity': 100,
      'price': 7200,
      'currency': Currency.jpy,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 720000,
    },
    {
      'tradeDate': DateTime(2025, 8, 21),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'JP',
      'code': '7453',
      'quantity': 200,
      'price': 3493,
      'currency': Currency.jpy,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 698500,
    },
    {
      'tradeDate': DateTime(2020, 12, 9),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'US',
      'currency': Currency.usd,
      'code': 'BABA',
      'quantity': 3,
      'price': 265,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 83423,
    },
    {
      'tradeDate': DateTime(2020, 12, 10),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'US',
      'currency': Currency.usd,
      'code': 'BABA',
      'quantity': 2,
      'price': 264,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 55458,
    },
    {
      'tradeDate': DateTime(2023, 11, 1),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'US',
      'currency': Currency.usd,
      'code': 'ACN',
      'quantity': 11,
      'price': 255.15,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 453044,
    },
    {
      'tradeDate': DateTime(2024, 5, 1),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'US',
      'currency': Currency.usd,
      'code': 'ACN',
      'quantity': 15,
      'price': 255.68,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 655058,
    },
    {
      'tradeDate': DateTime(2024, 11, 1),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'US',
      'currency': Currency.usd,
      'code': 'ACN',
      'quantity': 12,
      'price': 294.49,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 577500,
    },
    {
      'tradeDate': DateTime(2025, 5, 1),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'US',
      'currency': Currency.usd,
      'code': 'ACN',
      'quantity': 19,
      'price': 256.39,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 715730,
    },
    {
      'tradeDate': DateTime(2025, 6, 24),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'US',
      'currency': Currency.usd,
      'code': 'ACN',
      'quantity': 4,
      'price': 290.305,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 169363,
    },
    {
      'tradeDate': DateTime(2025, 1, 28),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'US',
      'currency': Currency.usd,
      'code': 'AAPL',
      'quantity': 5,
      'price': 226,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 176617,
    },
    {
      'tradeDate': DateTime(2025, 4, 8),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'US',
      'currency': Currency.usd,
      'code': 'AAPL',
      'quantity': 2,
      'price': 176.845,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 52278,
    },
    {
      'tradeDate': DateTime(2025, 8, 4),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'US',
      'currency': Currency.usd,
      'code': 'AAPL',
      'quantity': 2,
      'price': 205,
      'currencyUsed': Currency.usd,
      'moneyUsed': 412.02,
    },
    {
      'tradeDate': DateTime(2025, 1, 30),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'US',
      'currency': Currency.usd,
      'code': 'TSLA',
      'quantity': 3,
      'price': 393,
      'currencyUsed': Currency.usd,
      'moneyUsed': 1179,
    },
    {
      'tradeDate': DateTime(2025, 4, 8),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'US',
      'currency': Currency.usd,
      'code': 'TSLA',
      'quantity': 1,
      'price': 226,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 33405,
    },
    {
      'tradeDate': DateTime(2025, 4, 23),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'US',
      'currency': Currency.usd,
      'code': 'NVDA',
      'quantity': 14,
      'price': 98.77,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 196728,
    },
    {
      'tradeDate': DateTime(2025, 5, 13),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'US',
      'currency': Currency.usd,
      'code': 'KO',
      'quantity': 9,
      'price': 69.2991,
      'currencyUsed': Currency.usd,
      'moneyUsed': 623.7,
    },
    {
      'tradeDate': DateTime(2025, 8, 4),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'US',
      'currency': Currency.usd,
      'code': 'KO',
      'quantity': 3,
      'price': 68.55,
      'currencyUsed': Currency.usd,
      'moneyUsed': 205.65,
    },
    {
      'tradeDate': DateTime(2025, 5, 16),
      'action': TradeAction.buy,
      'tradeType': TradeType.nisa,
      'marketCode': 'US',
      'currency': Currency.usd,
      'code': 'WRD',
      'quantity': 50,
      'price': 8.72,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 63385,
    },
    {
      'tradeDate': DateTime(2025, 6, 6),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'US',
      'currency': Currency.usd,
      'code': 'PONY',
      'quantity': 100,
      'price': 12.735,
      'currencyUsed': Currency.usd,
      'moneyUsed': 1279.8,
    },
    {
      'tradeDate': DateTime(2025, 8, 4),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'US',
      'currency': Currency.usd,
      'code': 'BRK-B',
      'quantity': 1,
      'price': 459.445,
      'currencyUsed': Currency.usd,
      'moneyUsed': 461.72,
    },
    {
      'tradeDate': DateTime(2025, 8, 4),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'US',
      'currency': Currency.usd,
      'code': 'COST',
      'quantity': 1,
      'price': 952,
      'currencyUsed': Currency.usd,
      'moneyUsed': 956.71,
    },
    {
      'tradeDate': DateTime(2025, 8, 18),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'US',
      'code': 'UNH',
      'quantity': 2,
      'price': 309.5,
      'currency': Currency.usd,
      'currencyUsed': Currency.usd,
      'moneyUsed': 619,
    },
    {
      'tradeDate': DateTime(2025, 8, 18),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'US',
      'code': 'UNH',
      'quantity': 2,
      'price': 311,
      'currency': Currency.usd,
      'currencyUsed': Currency.usd,
      'moneyUsed': 622,
    },
    {
      'tradeDate': DateTime(2025, 4, 8),
      'action': TradeAction.buy,
      'tradeType': TradeType.nisa,
      'marketCode': 'US',
      'code': 'QQQ',
      'quantity': 2,
      'price': 417.3278,
      'currency': Currency.usd,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 123371,
    },
    {
      'tradeDate': DateTime(2025, 4, 8),
      'action': TradeAction.buy,
      'tradeType': TradeType.nisa,
      'marketCode': 'US',
      'code': 'VOO',
      'quantity': 3,
      'price': 454,
      'currency': Currency.usd,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 201317,
    },
    {
      'tradeDate': DateTime(2025, 5, 12),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'JP',
      'code': '2432',
      'quantity': 100,
      'price': 3049.5,
      'currency': Currency.jpy,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 304950,
    },
    {
      'tradeDate': DateTime(2025, 4, 7),
      'action': TradeAction.buy,
      'tradeType': TradeType.nisa,
      'marketCode': 'JP',
      'code': '1306',
      'quantity': 50,
      'price': 2465,
      'currency': Currency.jpy,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 123250,
    },
    {
      'tradeDate': DateTime(2025, 4, 7),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'JP',
      'code': '1489',
      'quantity': 80,
      'price': 1950,
      'currency': Currency.jpy,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 156000,
    },
    {
      'tradeDate': DateTime(2025, 4, 7),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'JP',
      'code': '3269',
      'quantity': 1,
      'price': 141500,
      'currency': Currency.jpy,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 141500,
    },
    {
      'tradeDate': DateTime(2025, 4, 7),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'JP',
      'code': '8953',
      'quantity': 1,
      'price': 93570,
      'currency': Currency.jpy,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 93570,
    },
    {
      'tradeDate': DateTime(2025, 4, 7),
      'action': TradeAction.buy,
      'tradeType': TradeType.normal,
      'marketCode': 'JP',
      'code': '8963',
      'quantity': 2,
      'price': 58490,
      'currency': Currency.jpy,
      'currencyUsed': Currency.jpy,
      'moneyUsed': 116980,
    },
  ];

  /*for (final t in tradeRecordList) {
    await db
        .into(db.tradeRecords)
        .insert(
          TradeRecordsCompanion.insert(
            tradeDate: t['tradeDate'] as DateTime,
            action: t['action'] as TradeAction,
            tradeType: t['tradeType'] as TradeType,
            code: t['code'] as String,
            quantity: (t['quantity'] as num).toDouble(),
            price: (t['price'] as num).toDouble(),
            currency: t['currency'] as Currency,
            currencyUsed: t['currencyUsed'] as Currency,
            moneyUsed: (t['moneyUsed'] as num).toDouble(),
            marketCode: t['marketCode'] as String,
          ),
        );
  }*/

  await db
      .into(db.tradeSellMappings)
      .insert(
        TradeSellMappingsCompanion.insert(buyId: 1, sellId: 2, quantity: 100),
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          IconButton(icon: Icon(Icons.notifications_none), onPressed: () {}),
          IconButton(icon: Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
