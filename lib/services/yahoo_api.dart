import 'dart:convert';
import 'package:http/http.dart' as http;

/// Yahoo Finance 简单封装（占位）
class YahooApi {
  final http.Client httpClient;
  final String baseUrl;
  // API Keys and URLs
  final String apiKey = '003c4869d0msh2ea657dbb66bd59p1e94f4jsn72dabcb8d29a';
  final String apiHost = 'yahoo-finance15.p.rapidapi.com';
  final String apiUrl =
      'https://yahoo-finance15.p.rapidapi.com/api/v1/markets/stock/quotes';

  YahooApi({http.Client? httpClient, required this.baseUrl})
    : httpClient = httpClient ?? http.Client();

  /// 批量请求多个 symbol 的最新报价。
  /// 返回 map: symbol -> { price: double, currency: String, source: 'yahoo', updatedAt: DateTime }
  Future<dynamic> fetchBatchQuotes(List<String> symbols) async {
    dynamic result = {};
    if (symbols.isEmpty) return result;

    try {
      final tickers = symbols.join(',');

      // 这里调用你的股票价格 API
      final resp = await http.get(
        Uri.parse('$apiUrl?ticker=$tickers'),
        headers: {'x-rapidapi-key': apiKey, 'x-rapidapi-host': apiHost},
      );

      if (resp.statusCode == 200) {
        result = jsonDecode(resp.body);
      }
    } catch (e) {
      // log / retry
    }

    return result;
  }
}
