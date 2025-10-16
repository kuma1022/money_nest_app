import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:money_nest_app/util/global_store.dart';

class BitflyerApi {
  late final String apiKey;
  late final String apiSecret;

  // コンストラクタで GlobalStore から API キーとシークレットを取得
  BitflyerApi() {
    apiKey = GlobalStore().cryptoApiKeys['bitflyer']?['apiKey'] ?? '';
    apiSecret = GlobalStore().cryptoApiKeys['bitflyer']?['apiSecret'] ?? '';
    if (apiKey.isEmpty || apiSecret.isEmpty) {
      throw Exception('Bitflyer API key or secret is not set in GlobalStore');
    }
  }

  // 残高の取得
  Future<List<dynamic>> getBalances() async {
    try {
      // APIリクエスト
      final List<dynamic> response = await getRequest('/v1/me/getbalance', {});
      // レスポンスの処理
      return response;
    } catch (e) {
      print('Error fetching balances: $e');
      rethrow;
    }
  }

  // 残高履歴の取得
  Future<List<dynamic>> getBalanceHistory({
    String currencyCode = 'JPY',
    int count = 100,
    int? before,
    int? after,
  }) async {
    try {
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
}
