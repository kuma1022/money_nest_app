import 'package:flutter/material.dart';
import 'package:money_nest_app/db/app_database.dart';

class CategoryProvider extends ChangeNotifier {
  final AppDatabase db;
  List<TradeCategory> categories = [];

  CategoryProvider(this.db);

  Future<void> loadCategories() async {
    categories = await db.getAllTradeCategoryRecords();
    notifyListeners();
  }
}
