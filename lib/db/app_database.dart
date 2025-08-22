import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:money_nest_app/models/trade_action.dart';
import 'package:money_nest_app/models/trade_type.dart';
import 'package:money_nest_app/models/currency.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// 交易记录表
class TradeRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  // 日期
  DateTimeColumn get tradeDate => dateTime()();
  // 交易类型（买入 / 卖出）
  TextColumn get action => text().map(const TradeActionConverter())();
  // 市场code
  TextColumn get marketCode => text().withLength(min: 1, max: 32)();
  // 类别（一般 / 特定 / NISA 等）
  TextColumn get tradeType => text().map(const TradeTypeConverter())();
  // 代码
  TextColumn get code => text().withLength(min: 1, max: 32)();
  // 交易数量
  RealColumn get quantity => real()();
  // 交易货币（USD / JPY / HKD 等）
  TextColumn get currency => text().map(const CurrencyConverter())();
  // 交易单价（每股成交价，交易货币计）
  RealColumn get price => real()();
  // 资金货币（买入时=结算货币，卖出时=到账货币）
  TextColumn get currencyUsed => text().map(const CurrencyConverter())();
  // 资金金额（买入时=结算金额，卖出时=到账金额）
  RealColumn get moneyUsed => real()();
  // 备注
  TextColumn get remark => text().nullable()();
}

// 卖出配对表
class TradeSellMappings extends Table {
  IntColumn get id => integer().autoIncrement()();
  // 卖出的交易ID
  IntColumn get sellId => integer()();
  // 对应买入的交易ID
  IntColumn get buyId => integer()();
  // 卖出对应的买入数量
  RealColumn get quantity => real()();
}

// 现金流表
class CashFlows extends Table {
  IntColumn get id => integer().autoIncrement()();
  // 日期
  DateTimeColumn get date => dateTime()();
  // 入金 / 出金
  TextColumn get type => text()();
  // 货币（JPY / USD 等）
  TextColumn get currency => text().map(const CurrencyConverter())();
  // 金额
  RealColumn get amount => real()();
  // 备注
  TextColumn get remark => text().nullable()();
}

// 当前余额快照表
class CashBalances extends Table {
  // 货币代码，主键
  TextColumn get currency => text().map(const CurrencyConverter())();
  // 当前余额
  RealColumn get balance => real()();
  // 最近更新时间（现金流表的入金/出金时间）
  DateTimeColumn get updatedAt => dateTime().nullable()();
  // 备注
  TextColumn get remark => text().nullable()();

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

// 交易市场表
class MarketData extends Table {
  TextColumn get code => text().withLength(min: 1, max: 32)();
  TextColumn get name => text().withLength(min: 1, max: 32)(); // 显示名称
  IntColumn get colorHex => integer().nullable()(); // 颜色（如0xFF2196F3），可空
  IntColumn get sortOrder => integer().withDefault(const Constant(0))(); // 排序
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))(); // 是否有效

  @override
  Set<Column> get primaryKey => {code}; // 以股票代码作为主键
}

// 资产标的表
class Stocks extends Table {
  // 代码
  TextColumn get code => text().withLength(min: 1, max: 32)();
  // 名称
  TextColumn get name => text().withLength(min: 1, max: 64)();
  // 市场（如JP, US, HK等）
  TextColumn get marketCode => text().withLength(min: 1, max: 32)();
  TextColumn get currency => text().withLength(min: 1, max: 8)(); // 货币
  RealColumn get currentPrice => real().nullable()(); // 当前股价
  DateTimeColumn get priceUpdatedAt => dateTime().nullable()(); // 股价更新时间
  TextColumn get remark => text().nullable()(); // 备注，可选
  // 你可以根据需要添加更多字段，如行业、logo等

  @override
  Set<Column> get primaryKey => {code}; // 以股票代码作为主键
}

// 数据库类
@DriftDatabase(
  tables: [
    TradeRecords,
    TradeSellMappings,
    CashFlows,
    CashBalances,
    CashBalanceHistories,
    MarketData,
    Stocks,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
  );

  Future<List<MarketDataData>> getAllMarketDataRecords() async {
    return await select(marketData).get();
  }

  Future<List<Stock>> getAllStocksRecords() async {
    return await select(stocks).get();
  }

  Future<MarketDataData?> getMarketDataByCode(String code) async {
    final market = await (select(
      marketData,
    )..where((tbl) => tbl.code.equals(code))).getSingleOrNull();
    return market;
  }

  Future<List<TradeRecord>> searchTradeRecords(String keyword) async {
    // 1. 在Stocks表中检索code或name
    final stockCodes =
        await (select(stocks)..where(
              (tbl) => tbl.code.contains(keyword) | tbl.name.contains(keyword),
            ))
            .map((s) => s.code)
            .get();

    if (stockCodes.isEmpty) {
      // 没有匹配的股票，直接返回空
      return [];
    }

    // 2. 用所有匹配的code去TradeRecords表中查找
    return (select(
      tradeRecords,
    )..where((tbl) => tbl.code.isIn(stockCodes))).get();
  }

  Future<List<TradeRecord>> getAllAvailableBuyRecords() async {
    // 查所有买入记录
    final buys =
        await (select(tradeRecords)..where(
              (tbl) =>
                  tbl.action.equals(TradeAction.buy.name) &
                  tbl.quantity.isNotNull(),
            ))
            .get();

    // 查所有卖出mapping
    final mappings = await select(tradeSellMappings).get();

    // 统计每个买入id已卖出的数量
    final Map<int, double> soldMap = {};
    for (final m in mappings) {
      soldMap[m.buyId] = (soldMap[m.buyId] ?? 0) + (m.quantity ?? 0);
    }

    // 只返回剩余数量>0的买入记录，并把剩余数量写入quantity字段
    final result = <TradeRecord>[];
    for (final b in buys) {
      final sold = soldMap[b.id] ?? 0;
      final remain = b.quantity - sold;
      if (remain > 0) {
        result.add(b.copyWith(quantity: remain));
      }
    }
    return result;
  }

  Future<List<TradeRecord>> getAvailableBuyRecordsByCode(String code) async {
    // 查指定 code 的所有买入记录
    final buys =
        await (select(tradeRecords)..where(
              (tbl) =>
                  tbl.action.equals(TradeAction.buy.name) &
                  tbl.code.equals(code) &
                  tbl.quantity.isNotNull(),
            ))
            .get();

    // 查所有卖出mapping
    final mappings = await select(tradeSellMappings).get();

    // 统计每个买入id已卖出的数量
    final Map<int, double> soldMap = {};
    for (final m in mappings) {
      soldMap[m.buyId] = (soldMap[m.buyId] ?? 0) + (m.quantity ?? 0);
    }

    // 只返回剩余数量>0的买入记录，并把剩余数量写入quantity字段
    final result = <TradeRecord>[];
    for (final b in buys) {
      final sold = soldMap[b.id] ?? 0;
      final remain = b.quantity - sold;
      if (remain > 0) {
        result.add(b.copyWith(quantity: remain));
      }
    }
    return result;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File('${dbFolder.path}/app.db');
    return NativeDatabase(file);
  });
}
