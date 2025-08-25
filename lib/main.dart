import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:money_nest_app/models/trade_action.dart';
import 'package:money_nest_app/models/trade_type.dart';
import 'package:money_nest_app/presentation/resources/app_resources.dart';
import 'package:money_nest_app/util/provider/buy_records_provider.dart';
import 'package:money_nest_app/util/provider/market_data_provider.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/pages/main_page.dart';
import 'package:money_nest_app/util/provider/stocks_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();

  // 这里提前初始化 marketData
  await _initDefaultCategories(db);
  // 这里提前初始化 stocks
  await _initDefaultStocks(db);
  // 这里提前初始化 buyRecords（为了测试）
  await _initDefaultBuyRecords(db);

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
      ],
      child: MyApp(db: db),
    ),
  );
}

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

Future<void> _initDefaultStocks(AppDatabase db) async {
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
}

Future<void> _initDefaultBuyRecords(AppDatabase db) async {
  if ((await db.select(db.tradeRecords).get()).isNotEmpty) {
    return;
  }
  await db
      .into(db.stocks)
      .insert(
        StocksCompanion.insert(
          code: '7453',
          name: '良品计划',
          marketCode: 'JP',
          currency: Currency.jpy.code,
        ),
      );
  await db
      .into(db.stocks)
      .insert(
        StocksCompanion.insert(
          code: 'KO',
          name: '可口可乐',
          marketCode: 'US',
          currency: Currency.usd.code,
        ),
      );
  await db
      .into(db.stocks)
      .insert(
        StocksCompanion.insert(
          code: 'UNH',
          name: '联合健康',
          marketCode: 'US',
          currency: Currency.usd.code,
        ),
      );
  await db
      .into(db.tradeRecords)
      .insert(
        TradeRecordsCompanion.insert(
          tradeDate: DateTime(2025, 7, 23),
          action: TradeAction.buy,
          tradeType: TradeType.normal,
          code: '7453',
          quantity: 100,
          price: 6800,
          currency: Currency.jpy,
          currencyUsed: Currency.jpy,
          moneyUsed: 680000,
          marketCode: 'JP',
        ),
      );
  await db
      .into(db.tradeRecords)
      .insert(
        TradeRecordsCompanion.insert(
          tradeDate: DateTime(2025, 7, 28),
          action: TradeAction.sell,
          tradeType: TradeType.normal,
          code: '7453',
          quantity: 100,
          price: 7200,
          currency: Currency.jpy,
          currencyUsed: Currency.jpy,
          moneyUsed: 720000,
          marketCode: 'JP',
        ),
      );
  await db
      .into(db.tradeSellMappings)
      .insert(
        TradeSellMappingsCompanion.insert(buyId: 1, sellId: 2, quantity: 100),
      );
  await db
      .into(db.tradeRecords)
      .insert(
        TradeRecordsCompanion.insert(
          tradeDate: DateTime(2025, 8, 4),
          action: TradeAction.buy,
          tradeType: TradeType.normal,
          code: 'KO',
          quantity: 3,
          price: 68.55,
          currency: Currency.usd,
          currencyUsed: Currency.usd,
          moneyUsed: 205.65,
          marketCode: 'US',
        ),
      );
  await db
      .into(db.tradeRecords)
      .insert(
        TradeRecordsCompanion.insert(
          tradeDate: DateTime(2025, 8, 18),
          action: TradeAction.buy,
          tradeType: TradeType.normal,
          code: 'UNH',
          quantity: 2,
          price: 309.5,
          currency: Currency.usd,
          currencyUsed: Currency.usd,
          moneyUsed: 619,
          marketCode: 'US',
        ),
      );
  await db
      .into(db.tradeRecords)
      .insert(
        TradeRecordsCompanion.insert(
          tradeDate: DateTime(2025, 8, 18),
          action: TradeAction.buy,
          tradeType: TradeType.normal,
          code: 'UNH',
          quantity: 2,
          price: 311,
          currency: Currency.usd,
          currencyUsed: Currency.usd,
          moneyUsed: 622,
          marketCode: 'US',
        ),
      );
  await db
      .into(db.tradeRecords)
      .insert(
        TradeRecordsCompanion.insert(
          tradeDate: DateTime(2025, 8, 21),
          action: TradeAction.buy,
          tradeType: TradeType.normal,
          code: '7453',
          quantity: 100,
          price: 6985,
          currency: Currency.jpy,
          currencyUsed: Currency.jpy,
          moneyUsed: 698500,
          marketCode: 'JP',
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
        fontFamilyFallback: [
          'PingFang SC', // 中文
          'Hiragino Sans', // 日文
          'San Francisco', // 英文
          'Helvetica Neue',
          'Arial',
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
      home: TradeRecordListPage(db: db),
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
