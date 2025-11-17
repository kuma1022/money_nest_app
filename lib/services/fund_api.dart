import 'dart:convert';
import 'package:http/http.dart' as http;

class FundApi {
  static const String apiUrl =
      "https://toushin-lib.fwg.ne.jp/FdsWeb/FDST999900/fundDataSearch";

  static const Map<String, String> apiHeaders = {
    "Accept": "application/json, text/javascript, */*; q=0.01",
    "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
  };

  /// Search fund info with keyword
  /// [maxCount] 控制最大取得件数（默认 20）
  static Future<List<Map<String, dynamic>>> fetchFundList(
    String name, {
    int maxCount = 5,
  }) async {
    final encodedName = Uri.encodeComponent(name);

    final dataRaw =
        "s_keyword=$encodedName"
        "&s_kensakuKbn=1"
        "&s_supplementKindCd=1"
        "&f_etfKBun=1"
        "&s_standardPriceCond1=0"
        "&s_standardPriceCond2=0"
        "&s_riskCond1=0"
        "&s_riskCond2=0"
        "&s_sharpCond1=0"
        "&s_sharpCond2=0"
        "&s_buyFee=1"
        "&s_trustReward=1"
        "&s_monthlyCancelCreateVal=1"
        "&startNo=0"
        "&draw=2"
        "&searchBtnClickFlg=true";

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: apiHeaders,
      body: dataRaw,
      encoding: Encoding.getByName("utf-8"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch fund info");
    }

    final jsonData = json.decode(response.body);

    final list = jsonData["resultInfoMapList"];
    if (list == null) return [];

    // 保险处理：只返回 maxCount 件
    return List<Map<String, dynamic>>.from(list).take(maxCount).toList();
  }
}
