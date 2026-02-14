import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_nest_app/components/card_section.dart';
import 'package:money_nest_app/components/custom_line_chart.dart';
import 'package:money_nest_app/presentation/resources/app_colors.dart';
import 'package:money_nest_app/util/app_utils.dart'; // Ensure this exists or use standard intl
import 'package:fl_chart/fl_chart.dart';

class FundInvestmentPlanTab extends StatefulWidget {
  const FundInvestmentPlanTab({super.key});

  @override
  State<FundInvestmentPlanTab> createState() => _FundInvestmentPlanTabState();
}

class _FundInvestmentPlanTabState extends State<FundInvestmentPlanTab> {
  final double monthlyTarget = 150000;
  
  // Mock Data for "Investment Plan" (Excel 1)
  final List<Map<String, dynamic>> planData = [
    {
      'category': '成長型株式',
      'accountType': 'NISA積立',
      'assetName': 'eMAXIS Slim 米国株式(S&P500)',
      'allocation_cat_total': 40,
      'allocation': 15,
      'range_min': 12,
      'range_max': 18,
      'amount': 22500,
      'freq': '取引日（自動）',
      'yield_annual': 10.0,
    },
    {
      'category': '成長型株式',
      'accountType': 'NISA積立',
      'assetName': 'eMAXIS Slim 国内株式(日経平均)',
      'allocation_cat_total': null, // Merged cell logic simulation
      'allocation': 10,
      'range_min': 7,
      'range_max': 13,
      'amount': 15000,
      'freq': '取引日（自動）',
      'yield_annual': 8.0,
    },
    {
      'category': '成長型株式',
      'accountType': 'NISA成長',
      'assetName': 'eMAXIS NASDAQ100',
      'allocation_cat_total': null,
      'allocation': 5,
      'range_min': 2,
      'range_max': 8,
      'amount': 7500,
      'freq': '取引日（自動）',
      'yield_annual': 12.0,
    },
     {
      'category': '成長型株式',
      'accountType': 'NISA成長',
      'assetName': '04311181 (FANG+)',
      'allocation_cat_total': null,
      'allocation': 5,
      'range_min': 2,
      'range_max': 8,
      'amount': 7500,
      'freq': '取引日（自動）',
      'yield_annual': 15.0,
    },
    {
      'category': '成長型株式',
      'accountType': 'NISA成長',
      'assetName': 'SMH',
      'allocation_cat_total': null,
      'allocation': 5,
      'range_min': 2,
      'range_max': 8,
      'amount': 7500,
      'freq': '毎週一（手動）',
      'yield_annual': 15.0,
    },
    // High Dividend
     {
      'category': '高配当株式',
      'accountType': 'NISA成長',
      'assetName': 'HDV',
      'allocation_cat_total': 35,
      'allocation': 12,
      'range_min': 10,
      'range_max': 14,
      'amount': 18000,
      'freq': '毎週一（手動）',
      'yield_annual': 5.0,
    },
     {
      'category': '高配当株式',
      'accountType': '一般',
      'assetName': 'JEPQ',
      'allocation_cat_total': null,
      'allocation': 10,
      'range_min': 8,
      'range_max': 12,
      'amount': 15000,
      'freq': '毎週一（手動）',
      'yield_annual': 7.0,
    },
    {
      'category': '高配当株式',
      'accountType': 'NISA成長',
      'assetName': '1489 NEXT FUNDS 日経平均高配当株50指数連動型',
      'allocation_cat_total': null,
      'allocation': 8,
      'range_min': 6,
      'range_max': 10,
      'amount': 12000,
      'freq': '毎週一（手動）',
      'yield_annual': 5.0,
    },
    {
      'category': '高配当株式',
      'accountType': 'NISA成長',
      'assetName': '435A iFreeETF 日本株配当ローテーション戦略',
      'allocation_cat_total': null,
      'allocation': 5,
      'range_min': 3,
      'range_max': 7,
      'amount': 7500,
      'freq': '毎週一（手動）',
      'yield_annual': 6.0,
    },
    // Bond & Gold & REIT
     {
      'category': '債券',
      'accountType': '一般',
      'assetName': 'JPST',
      'allocation_cat_total': 5,
      'allocation': 5,
      'range_min': 3,
      'range_max': 10,
      'amount': 7500,
      'freq': '毎週一（手動）',
      'yield_annual': 1.0,
    },
    {
      'category': '金',
      'accountType': 'NISA成長',
      'assetName': 'iShares Gold',
      'allocation_cat_total': 12,
      'allocation': 12,
      'range_min': 9,
      'range_max': 15,
      'amount': 18000,
      'freq': '取引日（自動）',
      'yield_annual': 5.0,
    },
    {
      'category': 'REIT',
      'accountType': 'NISA成長',
      'assetName': 'eMAXIS Slim 国内REIT',
      'allocation_cat_total': 8,
      'allocation': 4,
      'range_min': 3,
      'range_max': 5,
      'amount': 6000,
      'freq': '取引日（自動）',
      'yield_annual': 2.0,
    },
      {
      'category': 'REIT',
      'accountType': 'NISA成長',
      'assetName': 'eMAXIS Slim 新興国REIT',
      'allocation_cat_total': null,
      'allocation': 2,
      'range_min': 1,
      'range_max': 3,
      'amount': 3000,
      'freq': '取引日（自動）',
      'yield_annual': 3.0,
    },
      {
      'category': 'REIT',
      'accountType': 'NISA成長',
      'assetName': 'eMAXIS Slim 米国REIT',
      'allocation_cat_total': null,
      'allocation': 2,
      'range_min': 1,
      'range_max': 3,
      'amount': 3000,
      'freq': '取引日（自動）',
      'yield_annual': 2.5,
    },
  ];

  // Mock Data for "Annual Summary" (Excel 3 & 4)
  final List<Map<String, dynamic>> simulationData = [
    {'date': '2026/01', 'invest_plan': 150000, 'val_plan': 150876, 'invest_act': 149847, 'val_act': 151331},
    {'date': '2026/02', 'invest_plan': 300000, 'val_plan': 302634, 'invest_act': 183330, 'val_act': 184500},
    {'date': '2026/03', 'invest_plan': 450000, 'val_plan': 455278, 'invest_act': null, 'val_act': null},
    {'date': '2026/04', 'invest_plan': 600000, 'val_plan': 608814, 'invest_act': null, 'val_act': null},
    {'date': '2026/05', 'invest_plan': 750000, 'val_plan': 763247, 'invest_act': null, 'val_act': null},
    {'date': '2026/06', 'invest_plan': 900000, 'val_plan': 918582, 'invest_act': null, 'val_act': null},
    {'date': '2026/07', 'invest_plan': 1050000, 'val_plan': 1074825, 'invest_act': null, 'val_act': null},
    {'date': '2026/08', 'invest_plan': 1200000, 'val_plan': 1231980, 'invest_act': null, 'val_act': null},
    {'date': '2026/09', 'invest_plan': 1350000, 'val_plan': 1390054, 'invest_act': null, 'val_act': null},
    {'date': '2026/10', 'invest_plan': 1500000, 'val_plan': 1549051, 'invest_act': null, 'val_act': null},
    {'date': '2026/11', 'invest_plan': 1650000, 'val_plan': 1708976, 'invest_act': null, 'val_act': null},
    {'date': '2026/12', 'invest_plan': 1800000, 'val_plan': 1869836, 'invest_act': null, 'val_act': null},
  ];


  @override
  Widget build(BuildContext context) {
    return Column( // Removed SingleChildScrollView to avoid nesting
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryHeader(),
        const SizedBox(height: 16),
        _buildProjectionChart(),
         const SizedBox(height: 16),
        _buildPlanTable(),
        const SizedBox(height: 16),
        _buildSimulationTable(),
      ],
    );
  }

  Widget _buildSummaryHeader() {
    return CardSection(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const Text('毎月投資額', style: TextStyle(color: Colors.grey, fontSize: 14)),
               const SizedBox(height: 4),
               Text(
                 '¥${NumberFormat('#,###').format(monthlyTarget)}',
                 style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                 ),
               ),
             ],
           ),
           Column(
             crossAxisAlignment: CrossAxisAlignment.end,
             children: [
                const Text('予想年間収益率', style: TextStyle(color: Colors.grey, fontSize: 14)),
                 const SizedBox(height: 4),
                 Text(
                   '7.24%',
                   style: TextStyle(
                      color: AppColors.appUpGreen,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                   ),
                 ),
             ],
           )
        ],
      ),
    );
  }

  Widget _buildPlanTable() {
    return CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ポートフォリオ構成',
             style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
             ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(const Color(0xFF2C2C2E)),
              columnSpacing: 20,
              columns: const [
                DataColumn(label: Text('分類', style: TextStyle(color: Colors.grey))),
                DataColumn(label: Text('資産', style: TextStyle(color: Colors.grey))),
                DataColumn(label: Text('比率', style: TextStyle(color: Colors.grey))),
                DataColumn(label: Text('投資額', style: TextStyle(color: Colors.grey))),
                DataColumn(label: Text('頻度', style: TextStyle(color: Colors.grey))),
                DataColumn(label: Text('予想利回', style: TextStyle(color: Colors.grey))),
              ],
              rows: planData.map((data) {
                return DataRow(
                  cells: [
                     DataCell(Text(data['category'], style: const TextStyle(color: Colors.white))),
                     DataCell(
                       SizedBox(
                         width: 140,
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Text(data['assetName'], style: const TextStyle(color: Colors.white, fontSize: 12), overflow: TextOverflow.ellipsis),
                             Text(data['accountType'], style: const TextStyle(color: Colors.grey, fontSize: 10)),
                           ],
                         ),
                       )
                     ),
                     DataCell(Text('${data['allocation']}%', style: const TextStyle(color: Colors.white))),
                     DataCell(Text('¥${NumberFormat('#,###').format(data['amount'])}', style: const TextStyle(color: Colors.white))),
                     DataCell(Text(data['freq'], style: const TextStyle(color: Colors.white, fontSize: 11))),
                     DataCell(Text('${data['yield_annual']}%', style: const TextStyle(color: AppColors.appUpGreen))),
                  ]
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionChart() {
    final dateFormat = DateFormat('yyyy/MM');
    // Prepare Data for Chart
    List<(DateTime, double)> investPlan = [];
    List<(DateTime, double)> valPlan = [];
    List<(DateTime, double)> investAct = [];
    List<(DateTime, double)> valAct = [];

    for (var i = 0; i < simulationData.length; i++) {
      final d = simulationData[i];
      final dt = dateFormat.parse(d['date']);
      
      investPlan.add((dt, (d['invest_plan'] as num).toDouble()));
      valPlan.add((dt, (d['val_plan'] as num).toDouble()));

      if (d['invest_act'] != null) investAct.add((dt, (d['invest_act'] as num).toDouble()));
      if (d['val_act'] != null) valAct.add((dt, (d['val_act'] as num).toDouble()));
    }

    final chartData = [
      {'dataList': investPlan, 'lineColor': Colors.blue},
      {'dataList': valPlan, 'lineColor': Colors.red},
      {'dataList': investAct, 'lineColor': Colors.green},
      //{'dataList': valAct, 'lineColor': Colors.purple}, // Optional
    ];

    return CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'シミュレーション (投資額 vs 評価額)',
             style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
             ),
          ),
          const SizedBox(height: 16),
          LineChartSample12(
            datas: chartData,
            currencyCode: 'JPY',
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('投資額(予定)', Colors.blue),
              const SizedBox(width: 12),
              _buildLegendItem('評価額(予定)', Colors.red),
              const SizedBox(width: 12),
              _buildLegendItem('投資額(実績)', Colors.green),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }


  Widget _buildSimulationTable() {
    return CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '月次詳細シミュレーション',
             style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
             ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(const Color(0xFF2C2C2E)),
              columnSpacing: 16,
              columns: const [
                DataColumn(label: Text('年度', style: TextStyle(color: Colors.grey))),
                DataColumn(label: Text('投資額(予)', style: TextStyle(color: Colors.grey))),
                DataColumn(label: Text('評価額(予)', style: TextStyle(color: Colors.grey))),
                DataColumn(label: Text('投資額(実)', style: TextStyle(color: Colors.grey))),
                DataColumn(label: Text('差額', style: TextStyle(color: Colors.grey))),
              ],
              rows: simulationData.take(6).map((data) {
                final investAct = data['invest_act'];
                final diff = investAct != null ? (investAct - data['invest_plan']) : null;
                
                return DataRow(
                  cells: [
                     DataCell(Text(data['date'], style: const TextStyle(color: Colors.white))),
                     DataCell(Text('¥${NumberFormat('#,###').format(data['invest_plan'])}', style: const TextStyle(color: Colors.white))),
                     DataCell(Text('¥${NumberFormat('#,###').format(data['val_plan'])}', style: const TextStyle(color: Colors.white))),
                     DataCell(
                       investAct != null 
                       ? Text('¥${NumberFormat('#,###').format(investAct)}', style: const TextStyle(color: Colors.white))
                       : const Text('-', style: TextStyle(color: Colors.grey))
                     ),
                     DataCell(
                       diff != null
                       ? Text(
                         '¥${NumberFormat('#,###').format(diff)}', 
                         style: TextStyle(color: diff >= 0 ? AppColors.appUpGreen : AppColors.appDownRed)
                       )
                       : const Text('-', style: TextStyle(color: Colors.grey))
                     ),
                  ]
                );
              }).toList(),
            ),
          ),
          if (simulationData.length > 6)
            Padding(
               padding: const EdgeInsets.only(top: 8),
               child: Center(
                 child: TextButton(
                   onPressed: (){}, 
                   child: const Text('もっと見る', style: TextStyle(color: Colors.blueAccent))
                 ),
               ),
            )
        ],
      ),
    );
  }
}
