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
  // 备注
  TextColumn get remark => text().nullable()();
  // 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  // 更新时间
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // 收益
  RealColumn get profit => real().nullable()();

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

// 投资信托（基金）表
class Funds extends Table {
  // ID
  IntColumn get id => integer()();

  // 基金代码（Supabase: code）
  TextColumn get code => text().withLength(min: 1, max: 20)();

  // 名称
  TextColumn get name => text().withLength(min: 1, max: 255)();

  // 英文名称（可选）
  TextColumn get nameUs => text().nullable()();

  // 管理公司（可选）
  TextColumn get managementCompany => text().nullable()();

  // 设立日（可选）
  DateTimeColumn get foundationDate => dateTime().nullable()();

  // 是否为积立NISA对应基金（可选）
  BoolColumn get tsumitateFlag => boolean().nullable()();

  // ISIN 代码（可选）
  TextColumn get isinCd => text().nullable()();
}

// 基金交易表
class FundTransactions extends Table {
  // ID
  IntColumn get id => integer()();

  // 用户ID
  TextColumn get userId => text()();

  // 账户ID
  IntColumn get accountId => integer()();

  // 基金ID
  IntColumn get fundId => integer()();

  // 交易日期
  DateTimeColumn get tradeDate => dateTime()();

  // 操作：buy / sell
  TextColumn get action => text()();

  // 交易类型：individual / recurring
  TextColumn get tradeType => text()();

  // 账户类型：nisaTsumitate, nisa, specific, normal
  TextColumn get accountType => text()();

  // 金额
  RealColumn get amount => real().nullable()();

  // 数量
  RealColumn get quantity => real().nullable()();

  // 单价
  RealColumn get price => real().nullable()();

  // 手续费金额
  RealColumn get feeAmount => real().nullable()();

  // 手续费币种
  TextColumn get feeCurrency => text().nullable()();

  // 定投频率类型：daily, weekly, monthly, bimonthly
  TextColumn get recurringFrequencyType => text().nullable()();

  // 定投配置JSON
  TextColumn get recurringFrequencyConfig =>
      text().nullable()(); // Drift不直接支持jsonb，可存String

  // 定投开始日期
  DateTimeColumn get recurringStartDate => dateTime().nullable()();

  // 定投结束日期
  DateTimeColumn get recurringEndDate => dateTime().nullable()();

  // 定投状态：active, paused, stopped, completed
  TextColumn get recurringStatus => text().nullable()();

  // 备注
  TextColumn get remark => text().nullable()();
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

// 账户余额表
class AccountBalances extends Table {
  // ID
  IntColumn get id => integer()();
  // 账户ID
  IntColumn get accountId => integer()();
  // 用户ID
  TextColumn get userId => text()();
  // 货币
  TextColumn get currency => text()();
  // 金额
  RealColumn get amount => real().withDefault(const Constant(0))();
  // 更新时间
  DateTimeColumn get updatedAt => dateTime().nullable().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {accountId, currency},
  ];
}

// 现金交易表
class CashTransactions extends Table {
  // ID
  IntColumn get id => integer()();
  // 用户ID
  TextColumn get userId => text()();
  // 账户ID
  IntColumn get accountId => integer()();
  // 货币
  TextColumn get currency => text()();
  // 金额
  RealColumn get amount => real()();
  // 类型 deposit, withdraw, etc.
  TextColumn get type => text()();
  // 关联交易ID (可选)
  IntColumn get tradeId => integer().nullable()();
  // 交易日期
  DateTimeColumn get transactionDate => dateTime().withDefault(currentDateAndTime)();
  // 备注
  TextColumn get remark => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
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

// --- Custom Assets Tables ---

class CustomAssetCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get iconPoint => integer().nullable()(); 
  TextColumn get colorHex => text().nullable()(); 
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class CustomAssets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  IntColumn get categoryId => integer().references(CustomAssetCategories, #id)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('JPY'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class CustomAssetHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get assetId => integer().references(CustomAssets, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get recordDate => dateTime()();
  RealColumn get value => real().withDefault(const Constant(0.0))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  List<Set<Column>> get uniqueKeys => [
    {assetId, recordDate},
  ];
}

// 数据库类
@DriftDatabase(
  tables: [
    TradeRecords,
    Stocks,
    Funds,
    FundTransactions,
    TradeSellMappings,
    Accounts,
    StockPrices,
    FxRates,
    CryptoInfo,
    AccountBalances,
    CashTransactions,
    CustomAssetCategories,
    CustomAssets,
    CustomAssetHistory,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(accountBalances);
        await m.createTable(cashTransactions);
      }
      if (from < 3) {
        await m.createTable(customAssetCategories);
        await m.createTable(customAssets);
        await m.createTable(customAssetHistory);
      }
    },
  );

  // 完整的数据库初始化方法
  Future<void> initialize() async {
    try {
      print('AppDatabase: Initializing');

      // 1. 确保数据库连接正常
      await _ensureDbConnection();

      // 2. 清理旧的缓存数据（如果需要）
      await _cleanupOldData();

      print('AppDatabase: User initialization completed successfully');
    } catch (e) {
      print('AppDatabase: Error during user initialization: $e');
      rethrow;
    }
  }

  // 确保数据库连接
  Future<void> _ensureDbConnection() async {
    try {
      // 执行一个简单的查询来确保数据库连接正常
      await customSelect('SELECT 1').get();
      print('AppDatabase: Database connection verified');
    } catch (e) {
      print('AppDatabase: Database connection failed: $e');
      rethrow;
    }
  }

  // 清理旧数据（可选）
  Future<void> _cleanupOldData() async {
    try {
      await delete(tradeRecords).go();
      await delete(stocks).go();
      await delete(tradeSellMappings).go();
      await delete(accounts).go();
      await delete(stockPrices).go();
      await delete(fxRates).go();
      await delete(cryptoInfo).go();
      print('AppDatabase: Old data cleanup completed');
    } catch (e) {
      print('AppDatabase: Error during cleanup: $e');
      // 清理失败不应该阻止初始化
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File('${dbFolder.path}/app.db');
    return NativeDatabase(file);
  });
}
