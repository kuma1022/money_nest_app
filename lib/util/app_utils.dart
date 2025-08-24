import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:money_nest_app/db/app_database.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtils {
  factory AppUtils() {
    return _singleton;
  }

  AppUtils._internal();
  static final AppUtils _singleton = AppUtils._internal();

  double degreeToRadian(double degree) {
    return degree * math.pi / 180;
  }

  double radianToDegree(double radian) {
    return radian * 180 / math.pi;
  }

  Future<bool> tryToLaunchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  Future<Map<String, double>> getStockPricesByYHFinanceAPI(
    List<Stock> stocks,
    List<MarketDataData> marketDataList,
  ) async {
    final tickers = stocks
        .map(
          (s) =>
              '${s.code}${marketDataList.firstWhere(
                (m) => m.code == s.marketCode,
                orElse: () => MarketDataData(code: '', name: '', surfix: '', sortOrder: 0, isActive: true),
              ).surfix}',
        )
        .join(',');

    // 这里调用你的股票价格 API
    final response = await http.get(
      Uri.parse(
        'https://yahoo-finance15.p.rapidapi.com/api/v1/markets/stock/quotes?ticker=$tickers',
      ),
      headers: {
        'x-rapidapi-key': '003c4869d0msh2ea657dbb66bd59p1e94f4jsn72dabcb8d29a',
        'x-rapidapi-host': 'yahoo-finance15.p.rapidapi.com',
      },
    );

    final data = jsonDecode(response.body);
    // 解析返回的股票价格数据
    return {
      for (var stock in data['body'])
        stock['symbol']:
            (stock['regularMarketPrice'] as num?)?.toDouble() ?? 0.0,
    };
  }
}
