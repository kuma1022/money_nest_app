import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:money_nest_app/util/global_store.dart';

class BitflyerApi {
  late final String apiKey;
  late final String apiSecret;

  // コンストラクタで GlobalStore から API キーとシークレットを取得
  BitflyerApi(this.apiKey, this.apiSecret);

  Future<bool> checkApiKeyAndSecret() async {
    if (apiKey.isEmpty || apiSecret.isEmpty) {
      print('Bitflyer API key or secret is missing.');
      return false;
    }
    List<String> permissions = await getpermissions();
    if (permissions.isNotEmpty &&
        !permissions.contains('/v1/me/getbalance') &&
        !permissions.contains('/v1/me/getbalancehistory')) {
      return true;
    }
    return false;
  }

  bool checkLastSyncTime() {
    final DateTime lastSyncTime =
        GlobalStore().bitflyerLastSyncTime ??
        DateTime.fromMillisecondsSinceEpoch(0);
    // 如果上次同步时间距现在超过0.5秒，则进行同步
    if (DateTime.now().difference(lastSyncTime) >
        const Duration(milliseconds: 500)) {
      // 更新最后同步时间
      GlobalStore().saveBitflyerLastSyncTimeToPrefs();
      return true;
    }
    return false;
  }

  Future<List<String>> getpermissions() async {
    try {
      // APIリクエスト
      final List<dynamic> response = await getRequest(
        '/v1/me/getpermissions',
        {},
      );

      // レスポンスの処理
      return response.map((e) => e.toString()).toList();
    } catch (e) {
      print('Error fetching permissions: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getTicker(
    bool forceRefresh,
    String productCode,
  ) async {
    try {
      if (!forceRefresh && !checkLastSyncTime()) {
        print('Using cached balances, no need to fetch from Bitflyer API');
        throw Exception('Using cached balances');
      }
      // APIリクエスト
      final Map<String, dynamic> response = await getRequestWithoutAuth(
        '/v1/ticker',
        {'product_code': productCode},
      );

      print('Ticker data for $productCode: $response');

      // レスポンスの処理
      return response;
    } catch (e) {
      print('Exception during BitFlyer Ticker API call: $e');
      rethrow;
    }
  }

  // 残高の取得
  Future<List<dynamic>> getBalances(bool forceRefresh) async {
    try {
      if (!forceRefresh && !checkLastSyncTime()) {
        print('Using cached balances, no need to fetch from Bitflyer API');
        throw Exception('Using cached balances');
      }
      // APIリクエスト
      final List<dynamic> response = await getRequest('/v1/me/getbalance', {});

      // レスポンスの処理
      GlobalStore().bitflyerBalanceCache = response.asMap().map(
        (index, value) =>
            MapEntry(value['currency_code'], value['amount'] as double),
      );
      await GlobalStore().saveBitflyerBalanceCacheToPrefs();
      return response;
    } catch (e) {
      print('Error fetching balances: $e');
      rethrow;
    }
  }

  // 残高履歴の取得
  Future<List<dynamic>> getBalanceHistory(
    bool forceRefresh, {
    String currencyCode = 'JPY',
    int count = 100,
    int? before,
    int? after,
  }) async {
    try {
      if (!forceRefresh && !checkLastSyncTime()) {
        print(
          'Using cached balance history, no need to fetch from Bitflyer API',
        );
        throw Exception('Using cached balance history');
      }
      // APIリクエスト
      final List<dynamic> response =
          await getRequest('/v1/me/getbalancehistory', {
            'currency_code': currencyCode,
            'count': count.toString(),
            if (before != null) 'before': before.toString(),
            if (after != null) 'after': after.toString(),
          });
      // レスポンスの処理
      return response;
    } catch (e) {
      print('Error fetching balance history: $e');
      rethrow;
    }
  }

  Future<dynamic> getRequest(
    String basePath,
    Map<String, String> queryParamsMap,
  ) async {
    // 1. タイムスタンプ（ミリ秒単位）
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    // 2. HTTP メソッド & パス
    final method = 'GET';
    String queryParams = queryParamsMap.isEmpty
        ? ''
        : '?${queryParamsMap.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    final body = ''; // GET は空文字列

    // 3. 署名文字列
    final text = '$timestamp$method$basePath$queryParams$body';
    print('Text for signature: $text');

    // 4. HMAC-SHA256 署名
    final hmacSha256 = Hmac(sha256, utf8.encode(apiSecret));
    final sign = hmacSha256.convert(utf8.encode(text)).toString();
    print('Generated Signature: $sign');

    final uri = Uri.https('api.bitflyer.com', basePath, queryParamsMap);

    try {
      final response = await http.get(
        uri,
        headers: {
          'ACCESS-KEY': apiKey,
          'ACCESS-TIMESTAMP': timestamp,
          'ACCESS-SIGN': sign,
        },
      );

      if (response.statusCode == 200) {
        print('Successful response from BitFlyer API');
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        print('Error ${response.statusCode}: ${response.body}');
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Exception during BitFlyer API call: $e');
      rethrow;
    }
  }

  Future<dynamic> getRequestWithoutAuth(
    String basePath,
    Map<String, String> queryParamsMap,
  ) async {
    try {
      final uri = Uri.https('api.bitflyer.com', basePath, queryParamsMap);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        print('Successful response from BitFlyer API');
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Error ${response.statusCode}: ${response.body}');
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Exception during BitFlyer API call: $e');
      rethrow;
    }
  }
}
