import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// 交易记录表
class TradeRecords extends Table {
  // -------- 共通字段 --------
  // ID
  IntColumn get id => integer()();
  // 用户ID（多用户时用）
  TextColumn get userId => text()();
  // 账户ID（可选，用于多账户）
  IntColumn get accountId => integer().nullable()();
  // 资产类别（股票 / 基金 / 加密货币 等 'stock','fx','crypto','metal'）
  TextColumn get assetType => text()();
  // 资产ID（可选，关联具体资产，如股票ID等）
  IntColumn get assetId => integer()();
  // 日期
  DateTimeColumn get tradeDate => dateTime()();
  // 交易类型（buy / sell）
  TextColumn get action => text()();
  // 类别（一般 / 特定 / NISA 等）
  TextColumn get tradeType => text().nullable()();
  // 交易数量
  RealColumn get quantity => real()();
  // 交易单价（每股成交价，交易货币计）
  RealColumn get price => real()();
  // 手续费（可选）
  RealColumn get feeAmount =>
      real().nullable().withDefault(const Constant(0))();
  // 手续费货币（可选，USD / JPY 等）
  TextColumn get feeCurrency => text().nullable()();

  // -------- FX专用字段 --------
  // 头寸类型（可选，'long' / 'short' 等）
  TextColumn get positionType => text().nullable()();
  // レバレッジ
  RealColumn get leverage => real().nullable()();
  // swap point（可选）
  RealColumn get swapAmount =>
      real().nullable().withDefault(const Constant(0))();
  // swap货币（可选，USD / JPY 等）
  TextColumn get swapCurrency => text().nullable()();

  // -------- FX，暗号，贵金属专用字段 --------
  // 手动输入汇率（可选，买入时的汇率）
  BoolColumn get manualRateInput =>
      boolean().nullable().withDefault(const Constant(false))();

  // 备注
  TextColumn get remark => text().nullable()();
  // 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  // 更新时间
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 股票表
class Stocks extends Table {
  // ID
  IntColumn get id => integer()();
  // 股票代码，如AAPL, 7203等
  TextColumn get ticker => text().nullable()();
  // 交易所，如JP, US等
  TextColumn get exchange => text().nullable()();
  // 名称
  TextColumn get name => text()();
  // 英文名称
  TextColumn get nameUs => text().nullable()();
  // 货币，如JPY, USD等
  TextColumn get currency => text().withLength(min: 1, max: 8)();
  // 国家，如JP, US等
  TextColumn get country => text().withLength(min: 1, max: 8)();
  // 行业ID（可选，关联行业表）
  IntColumn get sectorIndustryId => integer().nullable()();
  // Logo URL（可选）
  TextColumn get logo => text().nullable()();
  // 股票状态，如active, delisted等
  TextColumn get status => text().withDefault(const Constant('active'))();
  // 最新价格
  RealColumn get lastPrice => real().nullable()();
  // 最新价格更新时间
  DateTimeColumn get lastPriceAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {ticker, exchange}, // unique (ticker, exchange)
  ];
}

// 账户表
class Accounts extends Table {
  // ID
  IntColumn get id => integer()();
  // 用户ID（多用户时用）
  TextColumn get userId => text()();
  // 名称
  TextColumn get name => text()();
  // 类型（现金账户 / 证券账户 / 退休账户 等）
  TextColumn get type => text().nullable()();
  // 创建时间
  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// 卖出配对表
class TradeSellMappings extends Table {
  // ID
  IntColumn get id => integer()();
  // 对应买入的交易ID
  IntColumn get buyId => integer()();
  // 卖出的交易ID
  IntColumn get sellId => integer()();
  // 卖出对应的买入数量
  RealColumn get quantity => real()();

  @override
  Set<Column> get primaryKey => {id};
}

// 股票价格历史表
class StockPrices extends Table {
  // ID
  IntColumn get id => integer().autoIncrement()();
  // 股票ID，关联Stocks表
  IntColumn get stockId => integer()();
  // 价格
  RealColumn get price => real()();
  // 价格日期
  DateTimeColumn get priceAt => dateTime()();
  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {stockId, priceAt}, // unique (stock_id, price_at)
  ];
}

// 汇率表
class FxRates extends Table {
  // 主键ID
  IntColumn get id => integer().autoIncrement()();

  // fx_pair_id，关联 fx_pairs 表
  IntColumn get fxPairId => integer()();

  // 汇率日期（仅日期，无时间）
  DateTimeColumn get rateDate => dateTime()();

  // 汇率
  RealColumn get rate => real()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {fxPairId, rateDate}, // unique (fx_pair_id, rate_date)
  ];
}

// 加密货币信息表
class CryptoInfo extends Table {
  // ID
  IntColumn get id => integer().autoIncrement()();

  // アカウントID（int8）
  IntColumn get accountId => integer()();

  // 取引所（例：binance, bitflyerなど）
  TextColumn get cryptoExchange => text()();

  // APIキー
  TextColumn get apiKey => text()();

  // APIシークレット
  TextColumn get apiSecret => text()();

  // ステータス（active, inactiveなど）
  TextColumn get status => text().withDefault(const Constant('active'))();

  // 作成日時（UTC）
  DateTimeColumn get createdAt => dateTime()();

  // 更新日時（UTC）
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {accountId, cryptoExchange}, // unique (account_id, crypto_exchange)
  ];
}

// ----------以下需要修改----------
/*
// 汇率表（可选，用于多货币转换）
class ExchangeRates extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()(); // 日期
  TextColumn get fromCurrency => text().map(const CurrencyConverter())();
  TextColumn get toCurrency => text().map(const CurrencyConverter())();
  RealColumn get rate => real()(); // 汇率
  DateTimeColumn get updatedAt => dateTime()(); // 更新时间
  TextColumn get remark => text().nullable()();
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
*/

// 交易市场表
class MarketData extends Table {
  TextColumn get code => text().withLength(min: 1, max: 32)();
  TextColumn get name => text().withLength(min: 1, max: 32)(); // 显示名称
  TextColumn get currency => text().nullable()(); // 货币
  TextColumn get surfix => text().nullable()(); // 后缀
  IntColumn get colorHex => integer().nullable()(); // 颜色（如0xFF2196F3），可空
  IntColumn get sortOrder => integer().withDefault(const Constant(0))(); // 排序
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))(); // 是否有效

  @override
  Set<Column> get primaryKey => {code}; // 以股票代码作为主键
}

// 数据库类
@DriftDatabase(
  tables: [
    TradeRecords,
    Stocks,
    TradeSellMappings,
    Accounts,
    StockPrices,
    FxRates,
    CryptoInfo,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File('${dbFolder.path}/app.db');
    return NativeDatabase(file);
  });
}
