import 'package:money_nest_app/util/app_helper.dart';

class AppAssets {
  static String getChartIcon(ChartType type) {
    switch (type) {
      case ChartType.line:
        return 'assets/icon/ic_line_chart.svg';
      case ChartType.bar:
        return 'assets/icon/ic_bar_chart.svg';
      case ChartType.pie:
        return 'assets/icon/ic_pie_chart.svg';
      case ChartType.scatter:
        return 'assets/icon/ic_scatter_chart.svg';
      case ChartType.radar:
        return 'assets/icon/ic_radar_chart.svg';
      case ChartType.candlestick:
        return 'assets/icon/ic_candle_chart.svg';
    }
  }
}
