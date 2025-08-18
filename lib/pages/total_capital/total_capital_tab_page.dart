import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:money_nest_app/util/provider/buy_records_provider.dart';
import 'package:money_nest_app/util/provider/category_provider.dart';
import 'package:money_nest_app/db/app_database.dart';
import 'package:provider/provider.dart';

class TotalCapitalTabPage extends StatefulWidget {
  final AppDatabase db;
  const TotalCapitalTabPage({super.key, required this.db});
  @override
  State<TotalCapitalTabPage> createState() => _TotalCapitalTabPageState();
}

class _TotalCapitalTabPageState extends State<TotalCapitalTabPage> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final tradeCategoryList = context.watch<CategoryProvider>().categories;
    final buyRecordsList = context.watch<BuyRecordsProvider>().records;
    final double chartSize = MediaQuery.of(context).size.width / 2;
    double total = buyRecordsList.fold<double>(
      0,
      (sum, record) => sum + record.quantity! * record.price! * record.rate!,
    );

    return Scaffold(
      //appBar: AppBar(title: const Text('总资产分布')),
      body: Column(
        children: [
          //const SizedBox(height: 24),
          //const Divider(height: 1, color: Color(0xFFE0E0E0)),
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
                    tradeCategoryList,
                    buyRecordsList,
                  ),
                ),
              ),
            ),
          ),
          // 你可以在这里加图例或其它内容
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(
    double total,
    List<TradeCategory> tradeCategoryList,
    List<TradeRecord> buyRecordsList,
  ) {
    // 只保留有资产的类别
    final sections = <PieChartSectionData>[];
    int visibleIndex = 0;
    final formatter = NumberFormat('#,##0');
    for (int i = 0; i < tradeCategoryList.length; i++) {
      final asset = tradeCategoryList[i];
      double sumForCategory = buyRecordsList
          .where((record) => record.category == asset.id)
          .fold<double>(
            0,
            (sum, record) =>
                sum + record.quantity! * record.price! * record.rate!,
          );
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
}
