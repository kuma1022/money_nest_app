import 'package:flutter/material.dart';
import 'package:money_nest_app/db/app_database.dart';

class MarketDataProvider extends ChangeNotifier {
  final AppDatabase db;
  //List<MarketDataData> marketData = [];

  MarketDataProvider(this.db);

  Future<void> loadMarketData() async {
    //marketData = [];
    //await db.getAllMarketDataRecords();
    notifyListeners();
  }
}
