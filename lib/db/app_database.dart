import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:money_nest_app/models/trade_action.dart';
import 'package:money_nest_app/models/trade_category.dart';
import 'package:money_nest_app/models/trade_type.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// 交易记录表
class TradeRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get tradeDate => dateTime()(); // 交易时间
  TextColumn get action =>
      text().map(const TradeActionConverter())(); // 买入 / 卖出
  TextColumn get category =>
      text().map(const TradeCategoryConverter())(); // 交易类型
  // 交易类型（股票 / 基金 / ETF 等），使用 TradeCategoryConverter
  TextColumn get tradeType =>
      text().map(const TradeTypeConverter())(); // 交易类别（一般 / 特定 / NISA）
  TextColumn get name => text()(); // 名称
  TextColumn get code => text().nullable()(); // 代码
  RealColumn get quantity => real().nullable()(); // 数量
  TextColumn get currency => text().map(const CurrencyConverter())(); // 交易货币
  RealColumn get price => real().nullable()(); // 单价（交易货币）
  RealColumn get rate =>
      real().nullable()(); // 汇率（交易货币兑设定默认货币，比如交易USD默认JPY的话，汇率就为1USD对多少JPY）
  TextColumn get remark => text().nullable()(); // 备注
}

// 卖出配对表
class TradeSellMappings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sellId => integer()(); // 卖出的交易ID
  IntColumn get buyId => integer()(); // 对应买入的交易ID
  RealColumn get quantity => real()(); // 卖出对应的买入数量
}

// 现金流表
class CashFlows extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get type => text()(); // 入金 / 出金
  TextColumn get currency =>
      text().map(const CurrencyConverter())(); // 货币（JPY / USD 等）
  RealColumn get amount => real()(); // 金额
  TextColumn get remark => text().nullable()();
}

// 当前余额快照表
class CashBalances extends Table {
  TextColumn get currency => text().map(const CurrencyConverter())(); // 货币代码，主键
  RealColumn get balance => real()(); // 当前余额
  DateTimeColumn get updatedAt =>
      dateTime().nullable()(); // 最近更新时间（现金流表的入金/出金时间）
  TextColumn get remark => text().nullable()(); // 备注
  @override
  Set<Column> get primaryKey => {currency}; // 以货币代码作为主键
}

// 余额历史记录表
class CashBalanceHistories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get currency => text().map(const CurrencyConverter())();
  RealColumn get balance => real()();
  DateTimeColumn get timestamp => dateTime()(); // 记录时间（现金流表的入金/出金时间）
  TextColumn get remark => text().nullable()();

  // 可加索引提高查询性能
  // 索引(currency, timestamp)
}

// 数据库类
@DriftDatabase(
  tables: [
    TradeRecords,
    TradeSellMappings,
    CashFlows,
    CashBalances,
    CashBalanceHistories,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<TradeRecord>> searchTradeRecords(String keyword) {
    return (select(tradeRecords)..where(
          (tbl) => tbl.name.contains(keyword) | tbl.code.contains(keyword),
        ))
        .get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File('${dbFolder.path}/app.db');
    return NativeDatabase(file);
  });
}
