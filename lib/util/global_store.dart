import 'dart:convert';
import 'package:money_nest_app/services/supabase_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class GlobalStore extends ChangeNotifier {
  static final GlobalStore _instance = GlobalStore._internal();
  factory GlobalStore() => _instance;
  GlobalStore._internal();

  String? _userId;
  int? _accountId;

  // 用户ID
  String? get userId => _userId;
  set userId(dynamic value) {
    if (value == null) {
      _userId = null;
    } else if (value is String) {
      _userId = value;
    } else {
      print('Converting userId from ${value.runtimeType} to String');
      _userId = value.toString();
    }
    notifyListeners();
  }

  // 账户ID
  int? get accountId => _accountId;
  set accountId(dynamic value) {
    if (value == null) {
      _accountId = null;
    } else if (value is int) {
      _accountId = value;
    } else if (value is String) {
      _accountId = int.tryParse(value);
      if (_accountId == null) {
        print('Warning: Cannot parse accountId string: $value');
      }
    } else if (value is double) {
      _accountId = value.toInt();
    } else {
      print('Warning: Unexpected accountId type: ${value.runtimeType}');
      try {
        _accountId = int.tryParse(value.toString());
      } catch (e) {
        print('Failed to convert accountId: $e');
        _accountId = null;
      }
    }
    notifyListeners();
  }

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
  // 最近与交易所同步时间
  Map<String, DateTime> cryptoLastSyncTime = {};
  // 虚拟货币交易所的余额和历史数据的缓存
  Map<String, Map<String, List<dynamic>>> cryptoBalanceDataCache = {};
  // 最新的总资产和总成本，key 是 'stock' 或 'crypto'，value 是 {'totalAssets': num, 'totalCosts': num, 'details': {}}
  Map<String, dynamic> totalAssetsAndCostsMap = {};

  // -------------------------------------------------
  // 从 SharedPreferences 加载数据
  // -------------------------------------------------
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    _accountId = prefs.getInt('accountId');
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

    // 安全地加载 cryptoLastSyncTime
    final cryptoLastSyncTimeJson = jsonDecode(
      prefs.getString('cryptoLastSyncTime') ?? '{}',
    );
    cryptoLastSyncTime = {};
    if (cryptoLastSyncTimeJson is Map) {
      cryptoLastSyncTimeJson.forEach((key, value) {
        if (key is String && value is String) {
          final dateTime = DateTime.tryParse(value);
          if (dateTime != null) {
            cryptoLastSyncTime[key] = dateTime;
          }
        }
      });
    }

    // 安全地加载 cryptoBalanceDataCache
    final cryptoBalanceDataCacheJson = jsonDecode(
      prefs.getString('cryptoBalanceDataCache') ?? '{}',
    );
    cryptoBalanceDataCache = {};
    if (cryptoBalanceDataCacheJson is Map) {
      cryptoBalanceDataCacheJson.forEach((key, value) {
        if (key is String && value is Map) {
          final Map<String, List<dynamic>> dataMap = {};
          value.forEach((subKey, subValue) {
            if (subKey is String && subValue is List) {
              dataMap[subKey] = List<dynamic>.from(subValue);
            }
          });
          cryptoBalanceDataCache[key] = dataMap;
        }
      });
    }

    // 安全地加载 totalAssetsAndCostsMap
    final totalAssetsAndCostsMapJson = jsonDecode(
      prefs.getString('totalAssetsAndCostsMap') ?? '{}',
    );
    totalAssetsAndCostsMap = totalAssetsAndCostsMapJson is Map
        ? _parseMap(totalAssetsAndCostsMapJson)
        : {};
  }

  Map<String, dynamic> _parseMap(Map<dynamic, dynamic> jsonMap) {
    final result = <String, dynamic>{};
    jsonMap.forEach((key, value) {
      if (key is String) {
        if (value is num) {
          result[key] = value.toDouble();
        } else if (value is Map) {
          result[key] = _parseMap(value);
        }
      }
    });
    return result;
  }

  // -------------------------------------------------
  // 保存数据到 SharedPreferences userId
  // -------------------------------------------------
  Future<void> saveUserIdToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (_userId != null) {
      prefs.setString('userId', _userId!);
    }
  }

  // -------------------------------------------------
  // 保存数据到 SharedPreferences accountId
  // -------------------------------------------------
  Future<void> saveAccountIdToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (_accountId != null) {
      prefs.setInt('accountId', _accountId!);
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
    prefs.setString('lastSyncTime', lastSyncTime!.toIso8601String());
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

  // -------------------------------------------------
  // 保存数据到 SharedPreferences cryptoLastSyncTime
  // -------------------------------------------------
  Future<void> saveCryptoLastSyncTimeToPrefs(String exchange) async {
    final prefs = await SharedPreferences.getInstance();
    cryptoLastSyncTime[exchange] = DateTime.now();
    // 将 DateTime 转换为 ISO8601 字符串格式保存
    final Map<String, String> timeMap = {};
    cryptoLastSyncTime.forEach((key, value) {
      timeMap[key] = value.toIso8601String();
    });
    prefs.setString('cryptoLastSyncTime', jsonEncode(timeMap));
  }

  // -------------------------------------------------
  // 保存数据到 SharedPreferences cryptoBalanceDataCache
  // -------------------------------------------------
  Future<void> saveCryptoBalanceDataCacheToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'cryptoBalanceDataCache',
      jsonEncode(cryptoBalanceDataCache),
    );
  }

  // -------------------------------------------------
  // 保存数据到 SharedPreferences totalAssetsAndCostsMap
  // -------------------------------------------------
  Future<void> saveTotalAssetsAndCostsMapToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // 统一转换数字类型
    final normalizedMap = _normalizeMap(totalAssetsAndCostsMap);

    final jsonString = jsonEncode(normalizedMap);

    final success = await prefs.setString('totalAssetsAndCostsMap', jsonString);
    if (!success) {
      throw Exception('保存 totalAssetsAndCostsMap 到 SharedPreferences 失败');
    }
  }

  /// 递归将 Map 中的数字转换为 double
  Map<String, dynamic> _normalizeMap(Map<dynamic, dynamic> map) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      if (key is String) {
        if (value is num) {
          result[key] = value.toDouble();
        } else if (value is Map) {
          result[key] = _normalizeMap(value);
        } else if (value is List) {
          result[key] = value.map((e) {
            if (e is num) return e.toDouble();
            if (e is Map) return _normalizeMap(e);
            return e;
          }).toList();
        } else {
          result[key] = value;
        }
      }
    });
    return result;
  }

  // 清除用户ID
  Future<void> clearUserIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    _userId = null;
  }

  // 清除账户ID
  Future<void> clearAccountIdFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accountId');
    _accountId = null;
  }

  // 清除所有用户数据
  Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _userId = null;
    _accountId = null;
    selectedCurrencyCode = 'JPY';
    portfolio = [];
    historicalPortfolio = {};
    currentStockPrices = {};
    stockPricesLastUpdated = null;
    lastSyncTime = null;
    syncStartDate = null;
    syncEndDate = null;
    cryptoLastSyncTime = {};
    cryptoBalanceDataCache = {};
    totalAssetsAndCostsMap = {};
  }
}
