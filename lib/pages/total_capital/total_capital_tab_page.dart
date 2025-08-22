import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import 'package:money_nest_app/l10n/app_localizations.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/util/provider/buy_records_provider.dart';
import 'package:money_nest_app/util/provider/market_data_provider.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:money_nest_app/widgets/indicator.dart';
import 'package:provider/provider.dart';

class TotalCapitalTabPage extends StatefulWidget {
  final AppDatabase db;
  const TotalCapitalTabPage({super.key, required this.db});
  @override
  State<TotalCapitalTabPage> createState() => _TotalCapitalTabPageState();
}

class _TotalCapitalTabPageState extends State<TotalCapitalTabPage> {
  int touchedIndex = -1;
  bool isCashExcluded = false;

  @override
  Widget build(BuildContext context) {
    final marketDataList = context.watch<MarketDataProvider>().marketData;
    final buyRecordsList = context.watch<BuyRecordsProvider>().records;
    final double chartSize = MediaQuery.of(context).size.width / 2;
    double total = buyRecordsList.fold<double>(
      0,
      (sum, record) => sum + record.moneyUsed,
    );

    return Scaffold(
      //appBar: AppBar(title: const Text('')),
      body: Column(
        children: [
          //const SizedBox(height: 24),
          //const Divider(height: 1, color: Color(0xFFE0E0E0)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.totalCapitalTabPageTotalTitle,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Spacer(), // 左侧留空
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.totalCapitalTabPageCashExcluedLabel,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    FlutterSwitch(
                      value: isCashExcluded,
                      width: 44,
                      height: 24,
                      toggleSize: 20,
                      borderRadius: 16.0,
                      activeColor: Color(0xFF34B363),
                      inactiveColor: Colors.grey[300]!,
                      toggleColor: Colors.white,
                      padding: 2,
                      onToggle: (v) {
                        setState(() {
                          isCashExcluded = v;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat(
                        'yyyy-MM-dd HH:mm',
                      ).format(DateTime.now()), // 更新时间
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Text(
                      '¥${NumberFormat('#,##0').format(total)}', // 当前总资产金额
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(
                        context,
                      )!.totalCapitalTabPageCurrentProfitAndLossLabel,
                      style: const TextStyle(fontSize: 16),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+¥12,345', // 这里填你的盈亏金额
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red, // 盈利红色，亏损绿色
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '+8.2%', // 这里填你的盈亏率
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 32),
                Text(
                  AppLocalizations.of(
                    context,
                  )!.totalCapitalTabPageTotalRateTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Center(
            child: SizedBox(
              height: chartSize,
              width: chartSize,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!
                            .touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: showingSections(
                    total,
                    marketDataList,
                    buyRecordsList,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              getIndicator(
                AppColors.contentColorBlue,
                'One',
                touchedIndex == 0,
              ),

              getIndicator(
                AppColors.contentColorYellow,
                'Two',
                touchedIndex == 1,
              ),

              getIndicator(
                AppColors.contentColorPink,
                'Three',
                touchedIndex == 2,
              ),
              getIndicator(
                AppColors.contentColorGreen,
                'Four',
                touchedIndex == 3,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(
    double total,
    List<MarketDataData> marketDataList,
    List<TradeRecord> buyRecordsList,
  ) {
    // 只保留有资产的类别
    final sections = <PieChartSectionData>[];
    int visibleIndex = 0;
    final formatter = NumberFormat('#,##0');
    for (int i = 0; i < marketDataList.length; i++) {
      final asset = marketDataList[i];
      double sumForCategory = buyRecordsList
          .where((record) => record.marketCode == asset.code)
          .fold<double>(0, (sum, record) => sum + record.moneyUsed);
      if (sumForCategory == 0) continue; // 跳过无资产类别

      final isTouched = visibleIndex == touchedIndex;
      final fontSize = isTouched ? 16.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      final percent = total == 0 ? 0 : (sumForCategory / total * 100);

      sections.add(
        PieChartSectionData(
          color: asset.colorHex != null ? Color(asset.colorHex!) : Colors.grey,
          value: sumForCategory,
          title: '', // 不用title
          badgeWidget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${asset.name} ${percent.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              Text(
                '¥${formatter.format(sumForCategory)}',
                style: TextStyle(
                  fontSize: fontSize - 2,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                  height: 1,
                ),
              ),
            ],
          ),
          badgePositionPercentageOffset: .98, // 居中
          radius: radius,
        ),
      );
      visibleIndex++;
    }
    return sections;
  }

  Indicator getIndicator(Color color, String text, bool isTouched) {
    return Indicator(
      color: color,
      text: text,
      isSquare: false,
      size: isTouched ? 18 : 16,
      textColor: isTouched ? Color(0xFF34B363) : Colors.black,
    );
  }
}
