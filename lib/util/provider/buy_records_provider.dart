import 'package:flutter/material.dart';
import 'package:money_nest_app/db/app_database.dart';

class BuyRecordsProvider extends ChangeNotifier {
  final AppDatabase db;
  List<TradeRecord> records = [];

  BuyRecordsProvider(this.db);

  Future<void> loadRecords() async {
    records = await db.getAllAvailableBuyRecords();
    notifyListeners();
  }
}
