import 'package:flutter/material.dart';
import 'package:money_nest_app/db/app_database.dart';

class StocksProvider extends ChangeNotifier {
  final AppDatabase db;
  List<Stock> stocks = [];

  StocksProvider(this.db);

  Future<void> loadStocks() async {
    stocks = [];
    //await db.getAllStocksRecords();
    notifyListeners();
  }
}
