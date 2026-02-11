import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:money_nest_app/presentation/resources/app_resources.dart';
import 'package:money_nest_app/services/data_sync_service.dart';
import 'package:money_nest_app/services/supabase_api.dart';
import 'package:money_nest_app/services/yahoo_api.dart';
import 'package:money_nest_app/util/app_utils.dart';
import 'package:money_nest_app/util/global_store.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/pages/main_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final t0 = DateTime.now();

  // 加载全局设置
  await GlobalStore().loadFromPrefs();

  // 初始化本地数据库
  final db = AppDatabase();

  // 初始化 SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // 初始化 Supabase
  await Supabase.initialize(
    url: 'https://yeciaqfdlznrstjhqfxu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InllY2lhcWZkbHpucnN0amhxZnh1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY0MDE3NTIsImV4cCI6MjA3MTk3Nzc1Mn0.QXWNGKbr9qjeBLYRWQHEEBMT1nfNKZS3vne-Za38bOc',
  );
  final supabaseClient = Supabase.instance.client;
  final supabaseApi = SupabaseApi(supabaseClient);

  // 初始化 Yahoo API
  final yahooApi = YahooApi(
    baseUrl: 'https://your-yahoo-proxy-or-endpoint.com',
  );

  // 初始化 DataSyncService
  final dataSync = DataSyncService(
    supabaseApi: supabaseApi,
    yahooApi: yahooApi,
    db: db,
    prefs: prefs,
  );

  runApp(
    MultiProvider(
      providers: [Provider<DataSyncService>.value(value: dataSync)],
      child: MyApp(db: db),
    ),
  );
  final t6 = DateTime.now();
  print('[PERF] main() total: ${t6.difference(t0).inMilliseconds} ms');
}

class MyApp extends StatefulWidget {
  final AppDatabase db;
  const MyApp({required this.db, super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _firstStart = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // cold start initialization — capture services synchronously
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dataSync = Provider.of<DataSyncService>(context, listen: false);
      if (_firstStart) {
        _firstStart = false;
        // 初始化应用数据（App cold start）
        await AppUtils().initializeAppData(dataSync, false);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    // 当从后台回到前台时触发（轻量校验/按 TTL 刷新）
    if (state == AppLifecycleState.resumed) {
      print('AppLifecycleState.resumed - refreshing data as needed');
      final dataSync = Provider.of<DataSyncService>(context, listen: false);
      await AppUtils().initializeAppData(dataSync, false);
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppTexts.appName,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
          surface: const Color(0xFF1C1C1E),
          background: Colors.black,
        ),
        useMaterial3: true,
        fontFamily: 'NotoSansJP', // 日文
        fontFamilyFallback: [
          'NotoSansSC', // 简体中文
          'NotoSansTC', // 繁体中文
          'NotoSans', // 英文
          'Roboto',
          'sans-serif',
        ],
        dialogTheme: const DialogTheme(
          backgroundColor: Color(0xFF1C1C1E),
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: const CardTheme(
          color: Color(0xFF1C1C1E),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2E),
          labelStyle: const TextStyle(color: Colors.grey),
          hintStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(12),
             borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(12),
             borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
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
      home: MainPage(db: widget.db),
    );
  }
}
