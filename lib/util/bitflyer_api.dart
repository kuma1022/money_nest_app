import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class BitflyerApi {
  final String apiKey;
  final String apiSecret;

  BitflyerApi(this.apiKey, this.apiSecret);

  /// childOrderState: "ACTIVE", "COMPLETED", "CANCELED", "EXPIRED", "REJECTED"
  Future<List<dynamic>> getChildOrders({
    String productCode = 'BTC_JPY',
    String? childOrderState,
    int? count,
  }) async {
    final timestamp = (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000)
        .toString();
    final method = 'GET';
    final path = '/v1/me/getchildorders';
    final body = ''; // GET は空文字

    // 🔑 署名文字列
    final text = timestamp + method + path + body;
    print('SIGN_TEXT: $text');

    // 🔑 HMAC-SHA256 署名
    final hmacSha256 = Hmac(sha256, utf8.encode(apiSecret));
    final sign = hmacSha256.convert(utf8.encode(text)).toString();
    print('SIGN: $sign');

    // クエリパラメータ
    final queryParameters = <String, String>{'product_code': productCode};
    if (childOrderState != null) {
      queryParameters['child_order_state'] = childOrderState;
    }
    if (count != null) {
      queryParameters['count'] = count.toString();
    }

    final uri = Uri.https('api.bitflyer.com', path, queryParameters);

    final response = await http.get(
      uri,
      headers: {
        'ACCESS-KEY': apiKey,
        'ACCESS-TIMESTAMP': timestamp,
        'ACCESS-SIGN': sign,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
