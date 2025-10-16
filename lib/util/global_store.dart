import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalStore {
  static final GlobalStore _instance = GlobalStore._internal();
  factory GlobalStore() => _instance;
  GlobalStore._internal();

  // 用户ID
  String? userId;
  // 账户ID
  int? accountId;
  // 选中的货币代码
  String selectedCurrencyCode = 'JPY';
  // 当前持仓
  List<dynamic> portfolio = [];
  // 历史持仓，key 是日期，value 是{持仓列表，成本基础，总资产}
  Map<DateTime, dynamic> historicalPortfolio = {};
  // 当前股票价格，key 是股票代码，value 是价格
  Map<String, double> currentStockPrices = {};
  // 最近获取股票价格的时间
  DateTime? stockPricesLastUpdated;
  // 最近与服务器同步时间
  DateTime? lastSyncTime;
  // 同步区间的开始日期
  DateTime? syncStartDate;
  // 同步区间的结束日期
  DateTime? syncEndDate;

  // -------------------------------------------------
  // 从 SharedPreferences 加载数据
  // -------------------------------------------------
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    accountId = prefs.getInt('accountId');
    selectedCurrencyCode = prefs.getString('selectedCurrencyCode') ?? 'JPY';
    portfolio = jsonDecode(prefs.getString('portfolio') ?? '[]');
    historicalPortfolio =
        jsonDecode(
          prefs.getString('historicalPortfolio') ?? '{}',
        ).map<DateTime, dynamic>(
          (key, value) => MapEntry(DateTime.parse(key), value),
        );
    currentStockPrices = Map<String, double>.from(
      jsonDecode(prefs.getString('currentStockPrices') ?? '{}'),
    );
    stockPricesLastUpdated = DateTime.tryParse(
      prefs.getString('stockPricesLastUpdated') ?? '',
    );
    lastSyncTime = DateTime.tryParse(prefs.getString('lastSyncTime') ?? '');
    syncStartDate = DateTime.tryParse(prefs.getString('syncStartDate') ?? '');
    syncEndDate = DateTime.tryParse(prefs.getString('syncEndDate') ?? '');
  }

  // -------------------------------------------------
  // 保存数据到 SharedPreferences userId
  // -------------------------------------------------
  Future<void> saveUserIdToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (userId != null) {
      prefs.setString('userId', userId!);
    }
  }

  // -------------------------------------------------
  // 保存数据到 SharedPreferences accountId
  // -------------------------------------------------
  Future<void> saveAccountIdToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (accountId != null) {
      prefs.setInt('accountId', accountId!);
    }
  }

  // -------------------------------------------------
  // 保存数据到 SharedPreferences selectedCurrencyCode
  // -------------------------------------------------
  Future<void> saveSelectedCurrencyCodeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedCurrencyCode', selectedCurrencyCode);
  }

  // -------------------------------------------------
  // 保存数据到 SharedPreferences portfolio
  // -------------------------------------------------
  Future<void> savePortfolioToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('portfolio', jsonEncode(portfolio));
  }

  // -------------------------------------------------
  // 保存数据到 SharedPreferences historicalPortfolio
  // -------------------------------------------------
  Future<void> saveHistoricalPortfolioToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'historicalPortfolio',
      jsonEncode(
        historicalPortfolio.map<String, dynamic>(
          (key, value) => MapEntry(key.toIso8601String(), value),
        ),
      ),
    );
  }

  // -------------------------------------------------
  // 保存数据到 SharedPreferences currentStockPrices
  // -------------------------------------------------
  Future<void> saveCurrentStockPricesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (currentStockPrices.isNotEmpty) {
      prefs.setString('currentStockPrices', jsonEncode(currentStockPrices));
    }
  }

  // -------------------------------------------------
  // 保存数据到 SharedPreferences stockPricesLastUpdated
  // -------------------------------------------------
  Future<void> saveStockPricesLastUpdatedToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (stockPricesLastUpdated != null) {
      prefs.setString(
        'stockPricesLastUpdated',
        stockPricesLastUpdated!.toIso8601String(),
      );
    }
  }

  // -------------------------------------------------
  // 保存数据到 SharedPreferences lastSyncTime
  // -------------------------------------------------
  Future<void> saveLastSyncTimeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('lastSyncTime', DateTime.now().toIso8601String());
  }

  // -------------------------------------------------
  // 保存数据到 SharedPreferences syncStartDate 和 syncEndDate
  // -------------------------------------------------
  Future<void> saveSyncDateToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (syncStartDate != null) {
      prefs.setString('syncStartDate', syncStartDate!.toIso8601String());
    }
    if (syncEndDate != null) {
      prefs.setString('syncEndDate', syncEndDate!.toIso8601String());
    }
  }
}
