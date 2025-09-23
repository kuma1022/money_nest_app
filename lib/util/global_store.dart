import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class GlobalStore {
  static final GlobalStore _instance = GlobalStore._internal();
  factory GlobalStore() => _instance;
  GlobalStore._internal();

  String? userId;
  int? accountId;
  String? selectedCurrencyCode;
  List<dynamic> portfolio = []; // 持仓列表
  Map<String, double> currentStockPrices = {}; // 股票价格
  DateTime? stockPricesLastUpdated;

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    accountId = prefs.getInt('accountId');
    selectedCurrencyCode = prefs.getString('selectedCurrencyCode') ?? 'JPY';
    portfolio = jsonDecode(prefs.getString('portfolio') ?? '[]');
    currentStockPrices = Map<String, double>.from(
      jsonDecode(prefs.getString('stockPrices') ?? '{}'),
    );
    stockPricesLastUpdated = DateTime.tryParse(
      prefs.getString('stockPricesLastUpdated') ?? '',
    );
  }

  Future<void> saveUserIdToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (userId != null) {
      prefs.setString('userId', userId!);
    }
  }

  Future<void> saveAccountIdToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (accountId != null) {
      prefs.setInt('accountId', accountId!);
    }
  }

  Future<void> saveSelectedCurrencyCodeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (selectedCurrencyCode != null) {
      prefs.setString('selectedCurrencyCode', selectedCurrencyCode!);
    }
  }

  Future<void> saveStockPricesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (currentStockPrices.isNotEmpty) {
      prefs.setString('stockPrices', jsonEncode(currentStockPrices));
    }
  }

  Future<void> savePortfolioToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('portfolio', jsonEncode(portfolio));
  }

  Future<void> saveStockPricesLastUpdatedToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (stockPricesLastUpdated != null) {
      prefs.setString(
        'stockPricesLastUpdated',
        stockPricesLastUpdated!.toIso8601String(),
      );
    }
  }
}
