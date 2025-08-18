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
  DateTimeColumn get tradeDate => dateTime()(); // 交易时间
  TextColumn get action =>
      text().map(const TradeActionConverter())(); // 买入 / 卖出
  IntColumn get category => integer()(); // 交易市场ID
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

// 交易市场表
class TradeCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 32)(); // 显示名称
  IntColumn get colorHex => integer().nullable()(); // 颜色（如0xFF2196F3），可空
  IntColumn get sortOrder => integer().withDefault(const Constant(0))(); // 排序
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))(); // 是否有效
}

// 数据库类
@DriftDatabase(
  tables: [
    TradeRecords,
    TradeSellMappings,
    CashFlows,
    CashBalances,
    CashBalanceHistories,
    TradeCategories,
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
    beforeOpen: (details) async {
      await _initDefaultCategories();
    },
  );

  Future<void> _initDefaultCategories() async {
    // 检查表是否为空
    final count = await (select(tradeCategories)..limit(1)).get();
    if (count.isEmpty) {
      // 插入初始数据
      into(tradeCategories).insert(
        TradeCategoriesCompanion.insert(
          name: '美股',
          colorHex: Value(0xFF21CBF3),
          sortOrder: Value(1),
          isActive: Value(true),
        ),
      );
      into(tradeCategories).insert(
        TradeCategoriesCompanion.insert(
          name: '美股ETF',
          colorHex: Value(0xFF21F3B2),
          sortOrder: Value(2),
          isActive: Value(true),
        ),
      );
      into(tradeCategories).insert(
        TradeCategoriesCompanion.insert(
          name: '日股',
          colorHex: Value(0xFFB221F3),
          sortOrder: Value(3),
          isActive: Value(true),
        ),
      );
      into(tradeCategories).insert(
        TradeCategoriesCompanion.insert(
          name: '日股ETF',
          colorHex: Value(0xFFF3B221),
          sortOrder: Value(4),
          isActive: Value(true),
        ),
      );
      into(tradeCategories).insert(
        TradeCategoriesCompanion.insert(
          name: '港股',
          colorHex: Value(0xFFF3E721),
          sortOrder: Value(5),
          isActive: Value(true),
        ),
      );
      into(tradeCategories).insert(
        TradeCategoriesCompanion.insert(
          name: '期权',
          colorHex: Value(0xFF7E21F3),
          sortOrder: Value(6),
          isActive: Value(true),
        ),
      );
      into(tradeCategories).insert(
        TradeCategoriesCompanion.insert(
          name: '基金',
          colorHex: Value(0xFF96F321),
          sortOrder: Value(7),
          isActive: Value(true),
        ),
      );
      into(tradeCategories).insert(
        TradeCategoriesCompanion.insert(
          name: '黄金（ETF）',
          colorHex: Value(0xFFBFBFBF),
          sortOrder: Value(8),
          isActive: Value(true),
        ),
      );
      into(tradeCategories).insert(
        TradeCategoriesCompanion.insert(
          name: '不动产信托（J-REIT）',
          colorHex: Value(0xFFC4C0CE),
          sortOrder: Value(9),
          isActive: Value(true),
        ),
      );
      into(tradeCategories).insert(
        TradeCategoriesCompanion.insert(
          name: 'FX',
          colorHex: Value(0xFFD1BFD1),
          sortOrder: Value(10),
          isActive: Value(true),
        ),
      );
      into(tradeCategories).insert(
        TradeCategoriesCompanion.insert(
          name: '其他',
          colorHex: Value(0xFFD1D1BF),
          sortOrder: Value(11),
          isActive: Value(true),
        ),
      );
    }
  }

  Future<List<TradeCategory>> getAllTradeCategoryRecords() async {
    return await select(tradeCategories).get();
  }

  Future<List<TradeRecord>> searchTradeRecords(String keyword) {
    return (select(tradeRecords)..where(
          (tbl) => tbl.name.contains(keyword) | tbl.code.contains(keyword),
        ))
        .get();
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
      final remain = (b.quantity ?? 0) - sold;
      if (remain > 0) {
        result.add(b.copyWith(quantity: Value(remain)));
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
      final remain = (b.quantity ?? 0) - sold;
      if (remain > 0) {
        result.add(b.copyWith(quantity: Value(remain)));
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
