import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class BitflyerApi {
  final String apiKey;
  final String apiSecret;

  BitflyerApi(this.apiKey, this.apiSecret);

  Future<List<dynamic>> getbalancehistory({
    String productCode = 'BTC_JPY',
    int? count,
  }) async {
    // 1. タイムスタンプ（ミリ秒単位）
    final now = DateTime.now();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    print('Local DateTime: $now');
    print('Unix Timestamp (ms): $timestamp');

    // 2. HTTP メソッド & パス
    final method = 'GET';
    final path = '/v1/me/getbalancehistory';
    final body = ''; // GET は空文字列

    // 3. 署名文字列
    final text = '$timestamp$method$path$body';
    print('Text for signature: $text');

    // 4. HMAC-SHA256 署名
    final hmacSha256 = Hmac(sha256, utf8.encode(apiSecret));
    final sign = hmacSha256.convert(utf8.encode(text)).toString();
    print('Generated Signature: $sign');

    final uri = Uri.https('api.bitflyer.com', path);

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
