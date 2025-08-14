import 'package:money_nest_app/db/app_database.dart';

class SelectedBuyRecord {
  final TradeRecord record;
  final double quantity;
  SelectedBuyRecord(this.record, this.quantity);
}
