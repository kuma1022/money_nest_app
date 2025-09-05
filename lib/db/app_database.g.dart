// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TradeRecordsTable extends TradeRecords
    with TableInfo<$TradeRecordsTable, TradeRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TradeRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tradeDateMeta = const VerificationMeta(
    'tradeDate',
  );
  @override
  late final GeneratedColumn<DateTime> tradeDate = GeneratedColumn<DateTime>(
    'trade_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TradeAction, String> action =
      GeneratedColumn<String>(
        'action',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TradeAction>($TradeRecordsTable.$converteraction);
  static const VerificationMeta _marketCodeMeta = const VerificationMeta(
    'marketCode',
  );
  @override
  late final GeneratedColumn<String> marketCode = GeneratedColumn<String>(
    'market_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TradeType, String> tradeType =
      GeneratedColumn<String>(
        'trade_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TradeType>($TradeRecordsTable.$convertertradeType);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Currency, String> currency =
      GeneratedColumn<String>(
        'currency',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Currency>($TradeRecordsTable.$convertercurrency);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Currency, String> currencyUsed =
      GeneratedColumn<String>(
        'currency_used',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Currency>($TradeRecordsTable.$convertercurrencyUsed);
  static const VerificationMeta _moneyUsedMeta = const VerificationMeta(
    'moneyUsed',
  );
  @override
  late final GeneratedColumn<double> moneyUsed = GeneratedColumn<double>(
    'money_used',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
    'remark',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tradeDate,
    action,
    marketCode,
    tradeType,
    code,
    quantity,
    currency,
    price,
    currencyUsed,
    moneyUsed,
    remark,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trade_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<TradeRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('trade_date')) {
      context.handle(
        _tradeDateMeta,
        tradeDate.isAcceptableOrUnknown(data['trade_date']!, _tradeDateMeta),
      );
    } else if (isInserting) {
      context.missing(_tradeDateMeta);
    }
    if (data.containsKey('market_code')) {
      context.handle(
        _marketCodeMeta,
        marketCode.isAcceptableOrUnknown(data['market_code']!, _marketCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_marketCodeMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('money_used')) {
      context.handle(
        _moneyUsedMeta,
        moneyUsed.isAcceptableOrUnknown(data['money_used']!, _moneyUsedMeta),
      );
    } else if (isInserting) {
      context.missing(_moneyUsedMeta);
    }
    if (data.containsKey('remark')) {
      context.handle(
        _remarkMeta,
        remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TradeRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TradeRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tradeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}trade_date'],
      )!,
      action: $TradeRecordsTable.$converteraction.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}action'],
        )!,
      ),
      marketCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}market_code'],
      )!,
      tradeType: $TradeRecordsTable.$convertertradeType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}trade_type'],
        )!,
      ),
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      currency: $TradeRecordsTable.$convertercurrency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}currency'],
        )!,
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      currencyUsed: $TradeRecordsTable.$convertercurrencyUsed.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}currency_used'],
        )!,
      ),
      moneyUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}money_used'],
      )!,
      remark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remark'],
      ),
    );
  }

  @override
  $TradeRecordsTable createAlias(String alias) {
    return $TradeRecordsTable(attachedDatabase, alias);
  }

  static TypeConverter<TradeAction, String> $converteraction =
      const TradeActionConverter();
  static TypeConverter<TradeType, String> $convertertradeType =
      const TradeTypeConverter();
  static TypeConverter<Currency, String> $convertercurrency =
      const CurrencyConverter();
  static TypeConverter<Currency, String> $convertercurrencyUsed =
      const CurrencyConverter();
}

class TradeRecord extends DataClass implements Insertable<TradeRecord> {
  final int id;
  final DateTime tradeDate;
  final TradeAction action;
  final String marketCode;
  final TradeType tradeType;
  final String code;
  final double quantity;
  final Currency currency;
  final double price;
  final Currency currencyUsed;
  final double moneyUsed;
  final String? remark;
  const TradeRecord({
    required this.id,
    required this.tradeDate,
    required this.action,
    required this.marketCode,
    required this.tradeType,
    required this.code,
    required this.quantity,
    required this.currency,
    required this.price,
    required this.currencyUsed,
    required this.moneyUsed,
    this.remark,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['trade_date'] = Variable<DateTime>(tradeDate);
    {
      map['action'] = Variable<String>(
        $TradeRecordsTable.$converteraction.toSql(action),
      );
    }
    map['market_code'] = Variable<String>(marketCode);
    {
      map['trade_type'] = Variable<String>(
        $TradeRecordsTable.$convertertradeType.toSql(tradeType),
      );
    }
    map['code'] = Variable<String>(code);
    map['quantity'] = Variable<double>(quantity);
    {
      map['currency'] = Variable<String>(
        $TradeRecordsTable.$convertercurrency.toSql(currency),
      );
    }
    map['price'] = Variable<double>(price);
    {
      map['currency_used'] = Variable<String>(
        $TradeRecordsTable.$convertercurrencyUsed.toSql(currencyUsed),
      );
    }
    map['money_used'] = Variable<double>(moneyUsed);
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    return map;
  }

  TradeRecordsCompanion toCompanion(bool nullToAbsent) {
    return TradeRecordsCompanion(
      id: Value(id),
      tradeDate: Value(tradeDate),
      action: Value(action),
      marketCode: Value(marketCode),
      tradeType: Value(tradeType),
      code: Value(code),
      quantity: Value(quantity),
      currency: Value(currency),
      price: Value(price),
      currencyUsed: Value(currencyUsed),
      moneyUsed: Value(moneyUsed),
      remark: remark == null && nullToAbsent
          ? const Value.absent()
          : Value(remark),
    );
  }

  factory TradeRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TradeRecord(
      id: serializer.fromJson<int>(json['id']),
      tradeDate: serializer.fromJson<DateTime>(json['tradeDate']),
      action: serializer.fromJson<TradeAction>(json['action']),
      marketCode: serializer.fromJson<String>(json['marketCode']),
      tradeType: serializer.fromJson<TradeType>(json['tradeType']),
      code: serializer.fromJson<String>(json['code']),
      quantity: serializer.fromJson<double>(json['quantity']),
      currency: serializer.fromJson<Currency>(json['currency']),
      price: serializer.fromJson<double>(json['price']),
      currencyUsed: serializer.fromJson<Currency>(json['currencyUsed']),
      moneyUsed: serializer.fromJson<double>(json['moneyUsed']),
      remark: serializer.fromJson<String?>(json['remark']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tradeDate': serializer.toJson<DateTime>(tradeDate),
      'action': serializer.toJson<TradeAction>(action),
      'marketCode': serializer.toJson<String>(marketCode),
      'tradeType': serializer.toJson<TradeType>(tradeType),
      'code': serializer.toJson<String>(code),
      'quantity': serializer.toJson<double>(quantity),
      'currency': serializer.toJson<Currency>(currency),
      'price': serializer.toJson<double>(price),
      'currencyUsed': serializer.toJson<Currency>(currencyUsed),
      'moneyUsed': serializer.toJson<double>(moneyUsed),
      'remark': serializer.toJson<String?>(remark),
    };
  }

  TradeRecord copyWith({
    int? id,
    DateTime? tradeDate,
    TradeAction? action,
    String? marketCode,
    TradeType? tradeType,
    String? code,
    double? quantity,
    Currency? currency,
    double? price,
    Currency? currencyUsed,
    double? moneyUsed,
    Value<String?> remark = const Value.absent(),
  }) => TradeRecord(
    id: id ?? this.id,
    tradeDate: tradeDate ?? this.tradeDate,
    action: action ?? this.action,
    marketCode: marketCode ?? this.marketCode,
    tradeType: tradeType ?? this.tradeType,
    code: code ?? this.code,
    quantity: quantity ?? this.quantity,
    currency: currency ?? this.currency,
    price: price ?? this.price,
    currencyUsed: currencyUsed ?? this.currencyUsed,
    moneyUsed: moneyUsed ?? this.moneyUsed,
    remark: remark.present ? remark.value : this.remark,
  );
  TradeRecord copyWithCompanion(TradeRecordsCompanion data) {
    return TradeRecord(
      id: data.id.present ? data.id.value : this.id,
      tradeDate: data.tradeDate.present ? data.tradeDate.value : this.tradeDate,
      action: data.action.present ? data.action.value : this.action,
      marketCode: data.marketCode.present
          ? data.marketCode.value
          : this.marketCode,
      tradeType: data.tradeType.present ? data.tradeType.value : this.tradeType,
      code: data.code.present ? data.code.value : this.code,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      currency: data.currency.present ? data.currency.value : this.currency,
      price: data.price.present ? data.price.value : this.price,
      currencyUsed: data.currencyUsed.present
          ? data.currencyUsed.value
          : this.currencyUsed,
      moneyUsed: data.moneyUsed.present ? data.moneyUsed.value : this.moneyUsed,
      remark: data.remark.present ? data.remark.value : this.remark,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TradeRecord(')
          ..write('id: $id, ')
          ..write('tradeDate: $tradeDate, ')
          ..write('action: $action, ')
          ..write('marketCode: $marketCode, ')
          ..write('tradeType: $tradeType, ')
          ..write('code: $code, ')
          ..write('quantity: $quantity, ')
          ..write('currency: $currency, ')
          ..write('price: $price, ')
          ..write('currencyUsed: $currencyUsed, ')
          ..write('moneyUsed: $moneyUsed, ')
          ..write('remark: $remark')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tradeDate,
    action,
    marketCode,
    tradeType,
    code,
    quantity,
    currency,
    price,
    currencyUsed,
    moneyUsed,
    remark,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TradeRecord &&
          other.id == this.id &&
          other.tradeDate == this.tradeDate &&
          other.action == this.action &&
          other.marketCode == this.marketCode &&
          other.tradeType == this.tradeType &&
          other.code == this.code &&
          other.quantity == this.quantity &&
          other.currency == this.currency &&
          other.price == this.price &&
          other.currencyUsed == this.currencyUsed &&
          other.moneyUsed == this.moneyUsed &&
          other.remark == this.remark);
}

class TradeRecordsCompanion extends UpdateCompanion<TradeRecord> {
  final Value<int> id;
  final Value<DateTime> tradeDate;
  final Value<TradeAction> action;
  final Value<String> marketCode;
  final Value<TradeType> tradeType;
  final Value<String> code;
  final Value<double> quantity;
  final Value<Currency> currency;
  final Value<double> price;
  final Value<Currency> currencyUsed;
  final Value<double> moneyUsed;
  final Value<String?> remark;
  const TradeRecordsCompanion({
    this.id = const Value.absent(),
    this.tradeDate = const Value.absent(),
    this.action = const Value.absent(),
    this.marketCode = const Value.absent(),
    this.tradeType = const Value.absent(),
    this.code = const Value.absent(),
    this.quantity = const Value.absent(),
    this.currency = const Value.absent(),
    this.price = const Value.absent(),
    this.currencyUsed = const Value.absent(),
    this.moneyUsed = const Value.absent(),
    this.remark = const Value.absent(),
  });
  TradeRecordsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime tradeDate,
    required TradeAction action,
    required String marketCode,
    required TradeType tradeType,
    required String code,
    required double quantity,
    required Currency currency,
    required double price,
    required Currency currencyUsed,
    required double moneyUsed,
    this.remark = const Value.absent(),
  }) : tradeDate = Value(tradeDate),
       action = Value(action),
       marketCode = Value(marketCode),
       tradeType = Value(tradeType),
       code = Value(code),
       quantity = Value(quantity),
       currency = Value(currency),
       price = Value(price),
       currencyUsed = Value(currencyUsed),
       moneyUsed = Value(moneyUsed);
  static Insertable<TradeRecord> custom({
    Expression<int>? id,
    Expression<DateTime>? tradeDate,
    Expression<String>? action,
    Expression<String>? marketCode,
    Expression<String>? tradeType,
    Expression<String>? code,
    Expression<double>? quantity,
    Expression<String>? currency,
    Expression<double>? price,
    Expression<String>? currencyUsed,
    Expression<double>? moneyUsed,
    Expression<String>? remark,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tradeDate != null) 'trade_date': tradeDate,
      if (action != null) 'action': action,
      if (marketCode != null) 'market_code': marketCode,
      if (tradeType != null) 'trade_type': tradeType,
      if (code != null) 'code': code,
      if (quantity != null) 'quantity': quantity,
      if (currency != null) 'currency': currency,
      if (price != null) 'price': price,
      if (currencyUsed != null) 'currency_used': currencyUsed,
      if (moneyUsed != null) 'money_used': moneyUsed,
      if (remark != null) 'remark': remark,
    });
  }

  TradeRecordsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? tradeDate,
    Value<TradeAction>? action,
    Value<String>? marketCode,
    Value<TradeType>? tradeType,
    Value<String>? code,
    Value<double>? quantity,
    Value<Currency>? currency,
    Value<double>? price,
    Value<Currency>? currencyUsed,
    Value<double>? moneyUsed,
    Value<String?>? remark,
  }) {
    return TradeRecordsCompanion(
      id: id ?? this.id,
      tradeDate: tradeDate ?? this.tradeDate,
      action: action ?? this.action,
      marketCode: marketCode ?? this.marketCode,
      tradeType: tradeType ?? this.tradeType,
      code: code ?? this.code,
      quantity: quantity ?? this.quantity,
      currency: currency ?? this.currency,
      price: price ?? this.price,
      currencyUsed: currencyUsed ?? this.currencyUsed,
      moneyUsed: moneyUsed ?? this.moneyUsed,
      remark: remark ?? this.remark,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tradeDate.present) {
      map['trade_date'] = Variable<DateTime>(tradeDate.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(
        $TradeRecordsTable.$converteraction.toSql(action.value),
      );
    }
    if (marketCode.present) {
      map['market_code'] = Variable<String>(marketCode.value);
    }
    if (tradeType.present) {
      map['trade_type'] = Variable<String>(
        $TradeRecordsTable.$convertertradeType.toSql(tradeType.value),
      );
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(
        $TradeRecordsTable.$convertercurrency.toSql(currency.value),
      );
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (currencyUsed.present) {
      map['currency_used'] = Variable<String>(
        $TradeRecordsTable.$convertercurrencyUsed.toSql(currencyUsed.value),
      );
    }
    if (moneyUsed.present) {
      map['money_used'] = Variable<double>(moneyUsed.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TradeRecordsCompanion(')
          ..write('id: $id, ')
          ..write('tradeDate: $tradeDate, ')
          ..write('action: $action, ')
          ..write('marketCode: $marketCode, ')
          ..write('tradeType: $tradeType, ')
          ..write('code: $code, ')
          ..write('quantity: $quantity, ')
          ..write('currency: $currency, ')
          ..write('price: $price, ')
          ..write('currencyUsed: $currencyUsed, ')
          ..write('moneyUsed: $moneyUsed, ')
          ..write('remark: $remark')
          ..write(')'))
        .toString();
  }
}

class $TradeSellMappingsTable extends TradeSellMappings
    with TableInfo<$TradeSellMappingsTable, TradeSellMapping> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TradeSellMappingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sellIdMeta = const VerificationMeta('sellId');
  @override
  late final GeneratedColumn<int> sellId = GeneratedColumn<int>(
    'sell_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _buyIdMeta = const VerificationMeta('buyId');
  @override
  late final GeneratedColumn<int> buyId = GeneratedColumn<int>(
    'buy_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, sellId, buyId, quantity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trade_sell_mappings';
  @override
  VerificationContext validateIntegrity(
    Insertable<TradeSellMapping> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sell_id')) {
      context.handle(
        _sellIdMeta,
        sellId.isAcceptableOrUnknown(data['sell_id']!, _sellIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sellIdMeta);
    }
    if (data.containsKey('buy_id')) {
      context.handle(
        _buyIdMeta,
        buyId.isAcceptableOrUnknown(data['buy_id']!, _buyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_buyIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TradeSellMapping map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TradeSellMapping(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sellId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sell_id'],
      )!,
      buyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}buy_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
    );
  }

  @override
  $TradeSellMappingsTable createAlias(String alias) {
    return $TradeSellMappingsTable(attachedDatabase, alias);
  }
}

class TradeSellMapping extends DataClass
    implements Insertable<TradeSellMapping> {
  final int id;
  final int sellId;
  final int buyId;
  final double quantity;
  const TradeSellMapping({
    required this.id,
    required this.sellId,
    required this.buyId,
    required this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sell_id'] = Variable<int>(sellId);
    map['buy_id'] = Variable<int>(buyId);
    map['quantity'] = Variable<double>(quantity);
    return map;
  }

  TradeSellMappingsCompanion toCompanion(bool nullToAbsent) {
    return TradeSellMappingsCompanion(
      id: Value(id),
      sellId: Value(sellId),
      buyId: Value(buyId),
      quantity: Value(quantity),
    );
  }

  factory TradeSellMapping.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TradeSellMapping(
      id: serializer.fromJson<int>(json['id']),
      sellId: serializer.fromJson<int>(json['sellId']),
      buyId: serializer.fromJson<int>(json['buyId']),
      quantity: serializer.fromJson<double>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sellId': serializer.toJson<int>(sellId),
      'buyId': serializer.toJson<int>(buyId),
      'quantity': serializer.toJson<double>(quantity),
    };
  }

  TradeSellMapping copyWith({
    int? id,
    int? sellId,
    int? buyId,
    double? quantity,
  }) => TradeSellMapping(
    id: id ?? this.id,
    sellId: sellId ?? this.sellId,
    buyId: buyId ?? this.buyId,
    quantity: quantity ?? this.quantity,
  );
  TradeSellMapping copyWithCompanion(TradeSellMappingsCompanion data) {
    return TradeSellMapping(
      id: data.id.present ? data.id.value : this.id,
      sellId: data.sellId.present ? data.sellId.value : this.sellId,
      buyId: data.buyId.present ? data.buyId.value : this.buyId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TradeSellMapping(')
          ..write('id: $id, ')
          ..write('sellId: $sellId, ')
          ..write('buyId: $buyId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sellId, buyId, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TradeSellMapping &&
          other.id == this.id &&
          other.sellId == this.sellId &&
          other.buyId == this.buyId &&
          other.quantity == this.quantity);
}

class TradeSellMappingsCompanion extends UpdateCompanion<TradeSellMapping> {
  final Value<int> id;
  final Value<int> sellId;
  final Value<int> buyId;
  final Value<double> quantity;
  const TradeSellMappingsCompanion({
    this.id = const Value.absent(),
    this.sellId = const Value.absent(),
    this.buyId = const Value.absent(),
    this.quantity = const Value.absent(),
  });
  TradeSellMappingsCompanion.insert({
    this.id = const Value.absent(),
    required int sellId,
    required int buyId,
    required double quantity,
  }) : sellId = Value(sellId),
       buyId = Value(buyId),
       quantity = Value(quantity);
  static Insertable<TradeSellMapping> custom({
    Expression<int>? id,
    Expression<int>? sellId,
    Expression<int>? buyId,
    Expression<double>? quantity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sellId != null) 'sell_id': sellId,
      if (buyId != null) 'buy_id': buyId,
      if (quantity != null) 'quantity': quantity,
    });
  }

  TradeSellMappingsCompanion copyWith({
    Value<int>? id,
    Value<int>? sellId,
    Value<int>? buyId,
    Value<double>? quantity,
  }) {
    return TradeSellMappingsCompanion(
      id: id ?? this.id,
      sellId: sellId ?? this.sellId,
      buyId: buyId ?? this.buyId,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sellId.present) {
      map['sell_id'] = Variable<int>(sellId.value);
    }
    if (buyId.present) {
      map['buy_id'] = Variable<int>(buyId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TradeSellMappingsCompanion(')
          ..write('id: $id, ')
          ..write('sellId: $sellId, ')
          ..write('buyId: $buyId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }
}

class $CashFlowsTable extends CashFlows
    with TableInfo<$CashFlowsTable, CashFlow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashFlowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Currency, String> currency =
      GeneratedColumn<String>(
        'currency',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Currency>($CashFlowsTable.$convertercurrency);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
    'remark',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    type,
    currency,
    amount,
    remark,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_flows';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashFlow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('remark')) {
      context.handle(
        _remarkMeta,
        remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashFlow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashFlow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      currency: $CashFlowsTable.$convertercurrency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}currency'],
        )!,
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      remark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remark'],
      ),
    );
  }

  @override
  $CashFlowsTable createAlias(String alias) {
    return $CashFlowsTable(attachedDatabase, alias);
  }

  static TypeConverter<Currency, String> $convertercurrency =
      const CurrencyConverter();
}

class CashFlow extends DataClass implements Insertable<CashFlow> {
  final int id;
  final DateTime date;
  final String type;
  final Currency currency;
  final double amount;
  final String? remark;
  const CashFlow({
    required this.id,
    required this.date,
    required this.type,
    required this.currency,
    required this.amount,
    this.remark,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['type'] = Variable<String>(type);
    {
      map['currency'] = Variable<String>(
        $CashFlowsTable.$convertercurrency.toSql(currency),
      );
    }
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    return map;
  }

  CashFlowsCompanion toCompanion(bool nullToAbsent) {
    return CashFlowsCompanion(
      id: Value(id),
      date: Value(date),
      type: Value(type),
      currency: Value(currency),
      amount: Value(amount),
      remark: remark == null && nullToAbsent
          ? const Value.absent()
          : Value(remark),
    );
  }

  factory CashFlow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashFlow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      type: serializer.fromJson<String>(json['type']),
      currency: serializer.fromJson<Currency>(json['currency']),
      amount: serializer.fromJson<double>(json['amount']),
      remark: serializer.fromJson<String?>(json['remark']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'type': serializer.toJson<String>(type),
      'currency': serializer.toJson<Currency>(currency),
      'amount': serializer.toJson<double>(amount),
      'remark': serializer.toJson<String?>(remark),
    };
  }

  CashFlow copyWith({
    int? id,
    DateTime? date,
    String? type,
    Currency? currency,
    double? amount,
    Value<String?> remark = const Value.absent(),
  }) => CashFlow(
    id: id ?? this.id,
    date: date ?? this.date,
    type: type ?? this.type,
    currency: currency ?? this.currency,
    amount: amount ?? this.amount,
    remark: remark.present ? remark.value : this.remark,
  );
  CashFlow copyWithCompanion(CashFlowsCompanion data) {
    return CashFlow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      currency: data.currency.present ? data.currency.value : this.currency,
      amount: data.amount.present ? data.amount.value : this.amount,
      remark: data.remark.present ? data.remark.value : this.remark,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashFlow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('amount: $amount, ')
          ..write('remark: $remark')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, type, currency, amount, remark);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashFlow &&
          other.id == this.id &&
          other.date == this.date &&
          other.type == this.type &&
          other.currency == this.currency &&
          other.amount == this.amount &&
          other.remark == this.remark);
}

class CashFlowsCompanion extends UpdateCompanion<CashFlow> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> type;
  final Value<Currency> currency;
  final Value<double> amount;
  final Value<String?> remark;
  const CashFlowsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.currency = const Value.absent(),
    this.amount = const Value.absent(),
    this.remark = const Value.absent(),
  });
  CashFlowsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String type,
    required Currency currency,
    required double amount,
    this.remark = const Value.absent(),
  }) : date = Value(date),
       type = Value(type),
       currency = Value(currency),
       amount = Value(amount);
  static Insertable<CashFlow> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? type,
    Expression<String>? currency,
    Expression<double>? amount,
    Expression<String>? remark,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (currency != null) 'currency': currency,
      if (amount != null) 'amount': amount,
      if (remark != null) 'remark': remark,
    });
  }

  CashFlowsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<String>? type,
    Value<Currency>? currency,
    Value<double>? amount,
    Value<String?>? remark,
  }) {
    return CashFlowsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      amount: amount ?? this.amount,
      remark: remark ?? this.remark,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(
        $CashFlowsTable.$convertercurrency.toSql(currency.value),
      );
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashFlowsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('currency: $currency, ')
          ..write('amount: $amount, ')
          ..write('remark: $remark')
          ..write(')'))
        .toString();
  }
}

class $CashBalancesTable extends CashBalances
    with TableInfo<$CashBalancesTable, CashBalance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashBalancesTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<Currency, String> currency =
      GeneratedColumn<String>(
        'currency',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Currency>($CashBalancesTable.$convertercurrency);
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
    'remark',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [currency, balance, updatedAt, remark];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_balances';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashBalance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    } else if (isInserting) {
      context.missing(_balanceMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('remark')) {
      context.handle(
        _remarkMeta,
        remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {currency};
  @override
  CashBalance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashBalance(
      currency: $CashBalancesTable.$convertercurrency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}currency'],
        )!,
      ),
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      remark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remark'],
      ),
    );
  }

  @override
  $CashBalancesTable createAlias(String alias) {
    return $CashBalancesTable(attachedDatabase, alias);
  }

  static TypeConverter<Currency, String> $convertercurrency =
      const CurrencyConverter();
}

class CashBalance extends DataClass implements Insertable<CashBalance> {
  final Currency currency;
  final double balance;
  final DateTime? updatedAt;
  final String? remark;
  const CashBalance({
    required this.currency,
    required this.balance,
    this.updatedAt,
    this.remark,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['currency'] = Variable<String>(
        $CashBalancesTable.$convertercurrency.toSql(currency),
      );
    }
    map['balance'] = Variable<double>(balance);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    return map;
  }

  CashBalancesCompanion toCompanion(bool nullToAbsent) {
    return CashBalancesCompanion(
      currency: Value(currency),
      balance: Value(balance),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      remark: remark == null && nullToAbsent
          ? const Value.absent()
          : Value(remark),
    );
  }

  factory CashBalance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashBalance(
      currency: serializer.fromJson<Currency>(json['currency']),
      balance: serializer.fromJson<double>(json['balance']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      remark: serializer.fromJson<String?>(json['remark']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'currency': serializer.toJson<Currency>(currency),
      'balance': serializer.toJson<double>(balance),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'remark': serializer.toJson<String?>(remark),
    };
  }

  CashBalance copyWith({
    Currency? currency,
    double? balance,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<String?> remark = const Value.absent(),
  }) => CashBalance(
    currency: currency ?? this.currency,
    balance: balance ?? this.balance,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    remark: remark.present ? remark.value : this.remark,
  );
  CashBalance copyWithCompanion(CashBalancesCompanion data) {
    return CashBalance(
      currency: data.currency.present ? data.currency.value : this.currency,
      balance: data.balance.present ? data.balance.value : this.balance,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      remark: data.remark.present ? data.remark.value : this.remark,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashBalance(')
          ..write('currency: $currency, ')
          ..write('balance: $balance, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remark: $remark')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(currency, balance, updatedAt, remark);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashBalance &&
          other.currency == this.currency &&
          other.balance == this.balance &&
          other.updatedAt == this.updatedAt &&
          other.remark == this.remark);
}

class CashBalancesCompanion extends UpdateCompanion<CashBalance> {
  final Value<Currency> currency;
  final Value<double> balance;
  final Value<DateTime?> updatedAt;
  final Value<String?> remark;
  final Value<int> rowid;
  const CashBalancesCompanion({
    this.currency = const Value.absent(),
    this.balance = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.remark = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CashBalancesCompanion.insert({
    required Currency currency,
    required double balance,
    this.updatedAt = const Value.absent(),
    this.remark = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : currency = Value(currency),
       balance = Value(balance);
  static Insertable<CashBalance> custom({
    Expression<String>? currency,
    Expression<double>? balance,
    Expression<DateTime>? updatedAt,
    Expression<String>? remark,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (currency != null) 'currency': currency,
      if (balance != null) 'balance': balance,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (remark != null) 'remark': remark,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CashBalancesCompanion copyWith({
    Value<Currency>? currency,
    Value<double>? balance,
    Value<DateTime?>? updatedAt,
    Value<String?>? remark,
    Value<int>? rowid,
  }) {
    return CashBalancesCompanion(
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      updatedAt: updatedAt ?? this.updatedAt,
      remark: remark ?? this.remark,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (currency.present) {
      map['currency'] = Variable<String>(
        $CashBalancesTable.$convertercurrency.toSql(currency.value),
      );
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashBalancesCompanion(')
          ..write('currency: $currency, ')
          ..write('balance: $balance, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remark: $remark, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CashBalanceHistoriesTable extends CashBalanceHistories
    with TableInfo<$CashBalanceHistoriesTable, CashBalanceHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashBalanceHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Currency, String> currency =
      GeneratedColumn<String>(
        'currency',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Currency>($CashBalanceHistoriesTable.$convertercurrency);
  static const VerificationMeta _balanceMeta = const VerificationMeta(
    'balance',
  );
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
    'remark',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currency,
    balance,
    timestamp,
    remark,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_balance_histories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashBalanceHistory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('balance')) {
      context.handle(
        _balanceMeta,
        balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta),
      );
    } else if (isInserting) {
      context.missing(_balanceMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('remark')) {
      context.handle(
        _remarkMeta,
        remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashBalanceHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashBalanceHistory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      currency: $CashBalanceHistoriesTable.$convertercurrency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}currency'],
        )!,
      ),
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}balance'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      remark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remark'],
      ),
    );
  }

  @override
  $CashBalanceHistoriesTable createAlias(String alias) {
    return $CashBalanceHistoriesTable(attachedDatabase, alias);
  }

  static TypeConverter<Currency, String> $convertercurrency =
      const CurrencyConverter();
}

class CashBalanceHistory extends DataClass
    implements Insertable<CashBalanceHistory> {
  final int id;
  final Currency currency;
  final double balance;
  final DateTime timestamp;
  final String? remark;
  const CashBalanceHistory({
    required this.id,
    required this.currency,
    required this.balance,
    required this.timestamp,
    this.remark,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['currency'] = Variable<String>(
        $CashBalanceHistoriesTable.$convertercurrency.toSql(currency),
      );
    }
    map['balance'] = Variable<double>(balance);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    return map;
  }

  CashBalanceHistoriesCompanion toCompanion(bool nullToAbsent) {
    return CashBalanceHistoriesCompanion(
      id: Value(id),
      currency: Value(currency),
      balance: Value(balance),
      timestamp: Value(timestamp),
      remark: remark == null && nullToAbsent
          ? const Value.absent()
          : Value(remark),
    );
  }

  factory CashBalanceHistory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashBalanceHistory(
      id: serializer.fromJson<int>(json['id']),
      currency: serializer.fromJson<Currency>(json['currency']),
      balance: serializer.fromJson<double>(json['balance']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      remark: serializer.fromJson<String?>(json['remark']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'currency': serializer.toJson<Currency>(currency),
      'balance': serializer.toJson<double>(balance),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'remark': serializer.toJson<String?>(remark),
    };
  }

  CashBalanceHistory copyWith({
    int? id,
    Currency? currency,
    double? balance,
    DateTime? timestamp,
    Value<String?> remark = const Value.absent(),
  }) => CashBalanceHistory(
    id: id ?? this.id,
    currency: currency ?? this.currency,
    balance: balance ?? this.balance,
    timestamp: timestamp ?? this.timestamp,
    remark: remark.present ? remark.value : this.remark,
  );
  CashBalanceHistory copyWithCompanion(CashBalanceHistoriesCompanion data) {
    return CashBalanceHistory(
      id: data.id.present ? data.id.value : this.id,
      currency: data.currency.present ? data.currency.value : this.currency,
      balance: data.balance.present ? data.balance.value : this.balance,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      remark: data.remark.present ? data.remark.value : this.remark,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashBalanceHistory(')
          ..write('id: $id, ')
          ..write('currency: $currency, ')
          ..write('balance: $balance, ')
          ..write('timestamp: $timestamp, ')
          ..write('remark: $remark')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, currency, balance, timestamp, remark);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashBalanceHistory &&
          other.id == this.id &&
          other.currency == this.currency &&
          other.balance == this.balance &&
          other.timestamp == this.timestamp &&
          other.remark == this.remark);
}

class CashBalanceHistoriesCompanion
    extends UpdateCompanion<CashBalanceHistory> {
  final Value<int> id;
  final Value<Currency> currency;
  final Value<double> balance;
  final Value<DateTime> timestamp;
  final Value<String?> remark;
  const CashBalanceHistoriesCompanion({
    this.id = const Value.absent(),
    this.currency = const Value.absent(),
    this.balance = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.remark = const Value.absent(),
  });
  CashBalanceHistoriesCompanion.insert({
    this.id = const Value.absent(),
    required Currency currency,
    required double balance,
    required DateTime timestamp,
    this.remark = const Value.absent(),
  }) : currency = Value(currency),
       balance = Value(balance),
       timestamp = Value(timestamp);
  static Insertable<CashBalanceHistory> custom({
    Expression<int>? id,
    Expression<String>? currency,
    Expression<double>? balance,
    Expression<DateTime>? timestamp,
    Expression<String>? remark,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currency != null) 'currency': currency,
      if (balance != null) 'balance': balance,
      if (timestamp != null) 'timestamp': timestamp,
      if (remark != null) 'remark': remark,
    });
  }

  CashBalanceHistoriesCompanion copyWith({
    Value<int>? id,
    Value<Currency>? currency,
    Value<double>? balance,
    Value<DateTime>? timestamp,
    Value<String?>? remark,
  }) {
    return CashBalanceHistoriesCompanion(
      id: id ?? this.id,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      timestamp: timestamp ?? this.timestamp,
      remark: remark ?? this.remark,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(
        $CashBalanceHistoriesTable.$convertercurrency.toSql(currency.value),
      );
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashBalanceHistoriesCompanion(')
          ..write('id: $id, ')
          ..write('currency: $currency, ')
          ..write('balance: $balance, ')
          ..write('timestamp: $timestamp, ')
          ..write('remark: $remark')
          ..write(')'))
        .toString();
  }
}

class $MarketDataTable extends MarketData
    with TableInfo<$MarketDataTable, MarketDataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MarketDataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _surfixMeta = const VerificationMeta('surfix');
  @override
  late final GeneratedColumn<String> surfix = GeneratedColumn<String>(
    'surfix',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<int> colorHex = GeneratedColumn<int>(
    'color_hex',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    name,
    currency,
    surfix,
    colorHex,
    sortOrder,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'market_data';
  @override
  VerificationContext validateIntegrity(
    Insertable<MarketDataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('surfix')) {
      context.handle(
        _surfixMeta,
        surfix.isAcceptableOrUnknown(data['surfix']!, _surfixMeta),
      );
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  MarketDataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MarketDataData(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      ),
      surfix: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surfix'],
      ),
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_hex'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $MarketDataTable createAlias(String alias) {
    return $MarketDataTable(attachedDatabase, alias);
  }
}

class MarketDataData extends DataClass implements Insertable<MarketDataData> {
  final String code;
  final String name;
  final String? currency;
  final String? surfix;
  final int? colorHex;
  final int sortOrder;
  final bool isActive;
  const MarketDataData({
    required this.code,
    required this.name,
    this.currency,
    this.surfix,
    this.colorHex,
    required this.sortOrder,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    if (!nullToAbsent || surfix != null) {
      map['surfix'] = Variable<String>(surfix);
    }
    if (!nullToAbsent || colorHex != null) {
      map['color_hex'] = Variable<int>(colorHex);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  MarketDataCompanion toCompanion(bool nullToAbsent) {
    return MarketDataCompanion(
      code: Value(code),
      name: Value(name),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
      surfix: surfix == null && nullToAbsent
          ? const Value.absent()
          : Value(surfix),
      colorHex: colorHex == null && nullToAbsent
          ? const Value.absent()
          : Value(colorHex),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
    );
  }

  factory MarketDataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MarketDataData(
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      currency: serializer.fromJson<String?>(json['currency']),
      surfix: serializer.fromJson<String?>(json['surfix']),
      colorHex: serializer.fromJson<int?>(json['colorHex']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'currency': serializer.toJson<String?>(currency),
      'surfix': serializer.toJson<String?>(surfix),
      'colorHex': serializer.toJson<int?>(colorHex),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  MarketDataData copyWith({
    String? code,
    String? name,
    Value<String?> currency = const Value.absent(),
    Value<String?> surfix = const Value.absent(),
    Value<int?> colorHex = const Value.absent(),
    int? sortOrder,
    bool? isActive,
  }) => MarketDataData(
    code: code ?? this.code,
    name: name ?? this.name,
    currency: currency.present ? currency.value : this.currency,
    surfix: surfix.present ? surfix.value : this.surfix,
    colorHex: colorHex.present ? colorHex.value : this.colorHex,
    sortOrder: sortOrder ?? this.sortOrder,
    isActive: isActive ?? this.isActive,
  );
  MarketDataData copyWithCompanion(MarketDataCompanion data) {
    return MarketDataData(
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      currency: data.currency.present ? data.currency.value : this.currency,
      surfix: data.surfix.present ? data.surfix.value : this.surfix,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MarketDataData(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('currency: $currency, ')
          ..write('surfix: $surfix, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(code, name, currency, surfix, colorHex, sortOrder, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MarketDataData &&
          other.code == this.code &&
          other.name == this.name &&
          other.currency == this.currency &&
          other.surfix == this.surfix &&
          other.colorHex == this.colorHex &&
          other.sortOrder == this.sortOrder &&
          other.isActive == this.isActive);
}

class MarketDataCompanion extends UpdateCompanion<MarketDataData> {
  final Value<String> code;
  final Value<String> name;
  final Value<String?> currency;
  final Value<String?> surfix;
  final Value<int?> colorHex;
  final Value<int> sortOrder;
  final Value<bool> isActive;
  final Value<int> rowid;
  const MarketDataCompanion({
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.currency = const Value.absent(),
    this.surfix = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MarketDataCompanion.insert({
    required String code,
    required String name,
    this.currency = const Value.absent(),
    this.surfix = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       name = Value(name);
  static Insertable<MarketDataData> custom({
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? currency,
    Expression<String>? surfix,
    Expression<int>? colorHex,
    Expression<int>? sortOrder,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (currency != null) 'currency': currency,
      if (surfix != null) 'surfix': surfix,
      if (colorHex != null) 'color_hex': colorHex,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MarketDataCompanion copyWith({
    Value<String>? code,
    Value<String>? name,
    Value<String?>? currency,
    Value<String?>? surfix,
    Value<int?>? colorHex,
    Value<int>? sortOrder,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return MarketDataCompanion(
      code: code ?? this.code,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      surfix: surfix ?? this.surfix,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (surfix.present) {
      map['surfix'] = Variable<String>(surfix.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<int>(colorHex.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MarketDataCompanion(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('currency: $currency, ')
          ..write('surfix: $surfix, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StocksTable extends Stocks with TableInfo<$StocksTable, Stock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marketCodeMeta = const VerificationMeta(
    'marketCode',
  );
  @override
  late final GeneratedColumn<String> marketCode = GeneratedColumn<String>(
    'market_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 8,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentPriceMeta = const VerificationMeta(
    'currentPrice',
  );
  @override
  late final GeneratedColumn<double> currentPrice = GeneratedColumn<double>(
    'current_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceUpdatedAtMeta = const VerificationMeta(
    'priceUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> priceUpdatedAt =
      GeneratedColumn<DateTime>(
        'price_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
    'remark',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    name,
    marketCode,
    currency,
    currentPrice,
    priceUpdatedAt,
    remark,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Stock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('market_code')) {
      context.handle(
        _marketCodeMeta,
        marketCode.isAcceptableOrUnknown(data['market_code']!, _marketCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_marketCodeMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('current_price')) {
      context.handle(
        _currentPriceMeta,
        currentPrice.isAcceptableOrUnknown(
          data['current_price']!,
          _currentPriceMeta,
        ),
      );
    }
    if (data.containsKey('price_updated_at')) {
      context.handle(
        _priceUpdatedAtMeta,
        priceUpdatedAt.isAcceptableOrUnknown(
          data['price_updated_at']!,
          _priceUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('remark')) {
      context.handle(
        _remarkMeta,
        remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  Stock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Stock(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      marketCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}market_code'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      currentPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_price'],
      ),
      priceUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}price_updated_at'],
      ),
      remark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remark'],
      ),
    );
  }

  @override
  $StocksTable createAlias(String alias) {
    return $StocksTable(attachedDatabase, alias);
  }
}

class Stock extends DataClass implements Insertable<Stock> {
  final String code;
  final String name;
  final String marketCode;
  final String currency;
  final double? currentPrice;
  final DateTime? priceUpdatedAt;
  final String? remark;
  const Stock({
    required this.code,
    required this.name,
    required this.marketCode,
    required this.currency,
    this.currentPrice,
    this.priceUpdatedAt,
    this.remark,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['market_code'] = Variable<String>(marketCode);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || currentPrice != null) {
      map['current_price'] = Variable<double>(currentPrice);
    }
    if (!nullToAbsent || priceUpdatedAt != null) {
      map['price_updated_at'] = Variable<DateTime>(priceUpdatedAt);
    }
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    return map;
  }

  StocksCompanion toCompanion(bool nullToAbsent) {
    return StocksCompanion(
      code: Value(code),
      name: Value(name),
      marketCode: Value(marketCode),
      currency: Value(currency),
      currentPrice: currentPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(currentPrice),
      priceUpdatedAt: priceUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(priceUpdatedAt),
      remark: remark == null && nullToAbsent
          ? const Value.absent()
          : Value(remark),
    );
  }

  factory Stock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Stock(
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      marketCode: serializer.fromJson<String>(json['marketCode']),
      currency: serializer.fromJson<String>(json['currency']),
      currentPrice: serializer.fromJson<double?>(json['currentPrice']),
      priceUpdatedAt: serializer.fromJson<DateTime?>(json['priceUpdatedAt']),
      remark: serializer.fromJson<String?>(json['remark']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'marketCode': serializer.toJson<String>(marketCode),
      'currency': serializer.toJson<String>(currency),
      'currentPrice': serializer.toJson<double?>(currentPrice),
      'priceUpdatedAt': serializer.toJson<DateTime?>(priceUpdatedAt),
      'remark': serializer.toJson<String?>(remark),
    };
  }

  Stock copyWith({
    String? code,
    String? name,
    String? marketCode,
    String? currency,
    Value<double?> currentPrice = const Value.absent(),
    Value<DateTime?> priceUpdatedAt = const Value.absent(),
    Value<String?> remark = const Value.absent(),
  }) => Stock(
    code: code ?? this.code,
    name: name ?? this.name,
    marketCode: marketCode ?? this.marketCode,
    currency: currency ?? this.currency,
    currentPrice: currentPrice.present ? currentPrice.value : this.currentPrice,
    priceUpdatedAt: priceUpdatedAt.present
        ? priceUpdatedAt.value
        : this.priceUpdatedAt,
    remark: remark.present ? remark.value : this.remark,
  );
  Stock copyWithCompanion(StocksCompanion data) {
    return Stock(
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      marketCode: data.marketCode.present
          ? data.marketCode.value
          : this.marketCode,
      currency: data.currency.present ? data.currency.value : this.currency,
      currentPrice: data.currentPrice.present
          ? data.currentPrice.value
          : this.currentPrice,
      priceUpdatedAt: data.priceUpdatedAt.present
          ? data.priceUpdatedAt.value
          : this.priceUpdatedAt,
      remark: data.remark.present ? data.remark.value : this.remark,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Stock(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('marketCode: $marketCode, ')
          ..write('currency: $currency, ')
          ..write('currentPrice: $currentPrice, ')
          ..write('priceUpdatedAt: $priceUpdatedAt, ')
          ..write('remark: $remark')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    code,
    name,
    marketCode,
    currency,
    currentPrice,
    priceUpdatedAt,
    remark,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Stock &&
          other.code == this.code &&
          other.name == this.name &&
          other.marketCode == this.marketCode &&
          other.currency == this.currency &&
          other.currentPrice == this.currentPrice &&
          other.priceUpdatedAt == this.priceUpdatedAt &&
          other.remark == this.remark);
}

class StocksCompanion extends UpdateCompanion<Stock> {
  final Value<String> code;
  final Value<String> name;
  final Value<String> marketCode;
  final Value<String> currency;
  final Value<double?> currentPrice;
  final Value<DateTime?> priceUpdatedAt;
  final Value<String?> remark;
  final Value<int> rowid;
  const StocksCompanion({
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.marketCode = const Value.absent(),
    this.currency = const Value.absent(),
    this.currentPrice = const Value.absent(),
    this.priceUpdatedAt = const Value.absent(),
    this.remark = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StocksCompanion.insert({
    required String code,
    required String name,
    required String marketCode,
    required String currency,
    this.currentPrice = const Value.absent(),
    this.priceUpdatedAt = const Value.absent(),
    this.remark = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       name = Value(name),
       marketCode = Value(marketCode),
       currency = Value(currency);
  static Insertable<Stock> custom({
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? marketCode,
    Expression<String>? currency,
    Expression<double>? currentPrice,
    Expression<DateTime>? priceUpdatedAt,
    Expression<String>? remark,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (marketCode != null) 'market_code': marketCode,
      if (currency != null) 'currency': currency,
      if (currentPrice != null) 'current_price': currentPrice,
      if (priceUpdatedAt != null) 'price_updated_at': priceUpdatedAt,
      if (remark != null) 'remark': remark,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StocksCompanion copyWith({
    Value<String>? code,
    Value<String>? name,
    Value<String>? marketCode,
    Value<String>? currency,
    Value<double?>? currentPrice,
    Value<DateTime?>? priceUpdatedAt,
    Value<String?>? remark,
    Value<int>? rowid,
  }) {
    return StocksCompanion(
      code: code ?? this.code,
      name: name ?? this.name,
      marketCode: marketCode ?? this.marketCode,
      currency: currency ?? this.currency,
      currentPrice: currentPrice ?? this.currentPrice,
      priceUpdatedAt: priceUpdatedAt ?? this.priceUpdatedAt,
      remark: remark ?? this.remark,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (marketCode.present) {
      map['market_code'] = Variable<String>(marketCode.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (currentPrice.present) {
      map['current_price'] = Variable<double>(currentPrice.value);
    }
    if (priceUpdatedAt.present) {
      map['price_updated_at'] = Variable<DateTime>(priceUpdatedAt.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StocksCompanion(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('marketCode: $marketCode, ')
          ..write('currency: $currency, ')
          ..write('currentPrice: $currentPrice, ')
          ..write('priceUpdatedAt: $priceUpdatedAt, ')
          ..write('remark: $remark, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExchangeRatesTable extends ExchangeRates
    with TableInfo<$ExchangeRatesTable, ExchangeRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExchangeRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Currency, String> fromCurrency =
      GeneratedColumn<String>(
        'from_currency',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Currency>($ExchangeRatesTable.$converterfromCurrency);
  @override
  late final GeneratedColumnWithTypeConverter<Currency, String> toCurrency =
      GeneratedColumn<String>(
        'to_currency',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Currency>($ExchangeRatesTable.$convertertoCurrency);
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
    'remark',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    fromCurrency,
    toCurrency,
    rate,
    updatedAt,
    remark,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exchange_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExchangeRate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('remark')) {
      context.handle(
        _remarkMeta,
        remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExchangeRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExchangeRate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      fromCurrency: $ExchangeRatesTable.$converterfromCurrency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}from_currency'],
        )!,
      ),
      toCurrency: $ExchangeRatesTable.$convertertoCurrency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}to_currency'],
        )!,
      ),
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      remark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remark'],
      ),
    );
  }

  @override
  $ExchangeRatesTable createAlias(String alias) {
    return $ExchangeRatesTable(attachedDatabase, alias);
  }

  static TypeConverter<Currency, String> $converterfromCurrency =
      const CurrencyConverter();
  static TypeConverter<Currency, String> $convertertoCurrency =
      const CurrencyConverter();
}

class ExchangeRate extends DataClass implements Insertable<ExchangeRate> {
  final int id;
  final DateTime date;
  final Currency fromCurrency;
  final Currency toCurrency;
  final double rate;
  final DateTime updatedAt;
  final String? remark;
  const ExchangeRate({
    required this.id,
    required this.date,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.updatedAt,
    this.remark,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    {
      map['from_currency'] = Variable<String>(
        $ExchangeRatesTable.$converterfromCurrency.toSql(fromCurrency),
      );
    }
    {
      map['to_currency'] = Variable<String>(
        $ExchangeRatesTable.$convertertoCurrency.toSql(toCurrency),
      );
    }
    map['rate'] = Variable<double>(rate);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    return map;
  }

  ExchangeRatesCompanion toCompanion(bool nullToAbsent) {
    return ExchangeRatesCompanion(
      id: Value(id),
      date: Value(date),
      fromCurrency: Value(fromCurrency),
      toCurrency: Value(toCurrency),
      rate: Value(rate),
      updatedAt: Value(updatedAt),
      remark: remark == null && nullToAbsent
          ? const Value.absent()
          : Value(remark),
    );
  }

  factory ExchangeRate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExchangeRate(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      fromCurrency: serializer.fromJson<Currency>(json['fromCurrency']),
      toCurrency: serializer.fromJson<Currency>(json['toCurrency']),
      rate: serializer.fromJson<double>(json['rate']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      remark: serializer.fromJson<String?>(json['remark']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'fromCurrency': serializer.toJson<Currency>(fromCurrency),
      'toCurrency': serializer.toJson<Currency>(toCurrency),
      'rate': serializer.toJson<double>(rate),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'remark': serializer.toJson<String?>(remark),
    };
  }

  ExchangeRate copyWith({
    int? id,
    DateTime? date,
    Currency? fromCurrency,
    Currency? toCurrency,
    double? rate,
    DateTime? updatedAt,
    Value<String?> remark = const Value.absent(),
  }) => ExchangeRate(
    id: id ?? this.id,
    date: date ?? this.date,
    fromCurrency: fromCurrency ?? this.fromCurrency,
    toCurrency: toCurrency ?? this.toCurrency,
    rate: rate ?? this.rate,
    updatedAt: updatedAt ?? this.updatedAt,
    remark: remark.present ? remark.value : this.remark,
  );
  ExchangeRate copyWithCompanion(ExchangeRatesCompanion data) {
    return ExchangeRate(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      fromCurrency: data.fromCurrency.present
          ? data.fromCurrency.value
          : this.fromCurrency,
      toCurrency: data.toCurrency.present
          ? data.toCurrency.value
          : this.toCurrency,
      rate: data.rate.present ? data.rate.value : this.rate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      remark: data.remark.present ? data.remark.value : this.remark,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRate(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('fromCurrency: $fromCurrency, ')
          ..write('toCurrency: $toCurrency, ')
          ..write('rate: $rate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remark: $remark')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, fromCurrency, toCurrency, rate, updatedAt, remark);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExchangeRate &&
          other.id == this.id &&
          other.date == this.date &&
          other.fromCurrency == this.fromCurrency &&
          other.toCurrency == this.toCurrency &&
          other.rate == this.rate &&
          other.updatedAt == this.updatedAt &&
          other.remark == this.remark);
}

class ExchangeRatesCompanion extends UpdateCompanion<ExchangeRate> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<Currency> fromCurrency;
  final Value<Currency> toCurrency;
  final Value<double> rate;
  final Value<DateTime> updatedAt;
  final Value<String?> remark;
  const ExchangeRatesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.fromCurrency = const Value.absent(),
    this.toCurrency = const Value.absent(),
    this.rate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.remark = const Value.absent(),
  });
  ExchangeRatesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required Currency fromCurrency,
    required Currency toCurrency,
    required double rate,
    required DateTime updatedAt,
    this.remark = const Value.absent(),
  }) : date = Value(date),
       fromCurrency = Value(fromCurrency),
       toCurrency = Value(toCurrency),
       rate = Value(rate),
       updatedAt = Value(updatedAt);
  static Insertable<ExchangeRate> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? fromCurrency,
    Expression<String>? toCurrency,
    Expression<double>? rate,
    Expression<DateTime>? updatedAt,
    Expression<String>? remark,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (fromCurrency != null) 'from_currency': fromCurrency,
      if (toCurrency != null) 'to_currency': toCurrency,
      if (rate != null) 'rate': rate,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (remark != null) 'remark': remark,
    });
  }

  ExchangeRatesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<Currency>? fromCurrency,
    Value<Currency>? toCurrency,
    Value<double>? rate,
    Value<DateTime>? updatedAt,
    Value<String?>? remark,
  }) {
    return ExchangeRatesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      rate: rate ?? this.rate,
      updatedAt: updatedAt ?? this.updatedAt,
      remark: remark ?? this.remark,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (fromCurrency.present) {
      map['from_currency'] = Variable<String>(
        $ExchangeRatesTable.$converterfromCurrency.toSql(fromCurrency.value),
      );
    }
    if (toCurrency.present) {
      map['to_currency'] = Variable<String>(
        $ExchangeRatesTable.$convertertoCurrency.toSql(toCurrency.value),
      );
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRatesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('fromCurrency: $fromCurrency, ')
          ..write('toCurrency: $toCurrency, ')
          ..write('rate: $rate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('remark: $remark')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TradeRecordsTable tradeRecords = $TradeRecordsTable(this);
  late final $TradeSellMappingsTable tradeSellMappings =
      $TradeSellMappingsTable(this);
  late final $CashFlowsTable cashFlows = $CashFlowsTable(this);
  late final $CashBalancesTable cashBalances = $CashBalancesTable(this);
  late final $CashBalanceHistoriesTable cashBalanceHistories =
      $CashBalanceHistoriesTable(this);
  late final $MarketDataTable marketData = $MarketDataTable(this);
  late final $StocksTable stocks = $StocksTable(this);
  late final $ExchangeRatesTable exchangeRates = $ExchangeRatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tradeRecords,
    tradeSellMappings,
    cashFlows,
    cashBalances,
    cashBalanceHistories,
    marketData,
    stocks,
    exchangeRates,
  ];
}

typedef $$TradeRecordsTableCreateCompanionBuilder =
    TradeRecordsCompanion Function({
      Value<int> id,
      required DateTime tradeDate,
      required TradeAction action,
      required String marketCode,
      required TradeType tradeType,
      required String code,
      required double quantity,
      required Currency currency,
      required double price,
      required Currency currencyUsed,
      required double moneyUsed,
      Value<String?> remark,
    });
typedef $$TradeRecordsTableUpdateCompanionBuilder =
    TradeRecordsCompanion Function({
      Value<int> id,
      Value<DateTime> tradeDate,
      Value<TradeAction> action,
      Value<String> marketCode,
      Value<TradeType> tradeType,
      Value<String> code,
      Value<double> quantity,
      Value<Currency> currency,
      Value<double> price,
      Value<Currency> currencyUsed,
      Value<double> moneyUsed,
      Value<String?> remark,
    });

class $$TradeRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $TradeRecordsTable> {
  $$TradeRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tradeDate => $composableBuilder(
    column: $table.tradeDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TradeAction, TradeAction, String> get action =>
      $composableBuilder(
        column: $table.action,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get marketCode => $composableBuilder(
    column: $table.marketCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TradeType, TradeType, String> get tradeType =>
      $composableBuilder(
        column: $table.tradeType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Currency, Currency, String> get currency =>
      $composableBuilder(
        column: $table.currency,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Currency, Currency, String> get currencyUsed =>
      $composableBuilder(
        column: $table.currencyUsed,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get moneyUsed => $composableBuilder(
    column: $table.moneyUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TradeRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $TradeRecordsTable> {
  $$TradeRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get tradeDate => $composableBuilder(
    column: $table.tradeDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marketCode => $composableBuilder(
    column: $table.marketCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tradeType => $composableBuilder(
    column: $table.tradeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyUsed => $composableBuilder(
    column: $table.currencyUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get moneyUsed => $composableBuilder(
    column: $table.moneyUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TradeRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TradeRecordsTable> {
  $$TradeRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get tradeDate =>
      $composableBuilder(column: $table.tradeDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TradeAction, String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get marketCode => $composableBuilder(
    column: $table.marketCode,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TradeType, String> get tradeType =>
      $composableBuilder(column: $table.tradeType, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Currency, String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Currency, String> get currencyUsed =>
      $composableBuilder(
        column: $table.currencyUsed,
        builder: (column) => column,
      );

  GeneratedColumn<double> get moneyUsed =>
      $composableBuilder(column: $table.moneyUsed, builder: (column) => column);

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);
}

class $$TradeRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TradeRecordsTable,
          TradeRecord,
          $$TradeRecordsTableFilterComposer,
          $$TradeRecordsTableOrderingComposer,
          $$TradeRecordsTableAnnotationComposer,
          $$TradeRecordsTableCreateCompanionBuilder,
          $$TradeRecordsTableUpdateCompanionBuilder,
          (
            TradeRecord,
            BaseReferences<_$AppDatabase, $TradeRecordsTable, TradeRecord>,
          ),
          TradeRecord,
          PrefetchHooks Function()
        > {
  $$TradeRecordsTableTableManager(_$AppDatabase db, $TradeRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TradeRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TradeRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TradeRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> tradeDate = const Value.absent(),
                Value<TradeAction> action = const Value.absent(),
                Value<String> marketCode = const Value.absent(),
                Value<TradeType> tradeType = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<Currency> currency = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<Currency> currencyUsed = const Value.absent(),
                Value<double> moneyUsed = const Value.absent(),
                Value<String?> remark = const Value.absent(),
              }) => TradeRecordsCompanion(
                id: id,
                tradeDate: tradeDate,
                action: action,
                marketCode: marketCode,
                tradeType: tradeType,
                code: code,
                quantity: quantity,
                currency: currency,
                price: price,
                currencyUsed: currencyUsed,
                moneyUsed: moneyUsed,
                remark: remark,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime tradeDate,
                required TradeAction action,
                required String marketCode,
                required TradeType tradeType,
                required String code,
                required double quantity,
                required Currency currency,
                required double price,
                required Currency currencyUsed,
                required double moneyUsed,
                Value<String?> remark = const Value.absent(),
              }) => TradeRecordsCompanion.insert(
                id: id,
                tradeDate: tradeDate,
                action: action,
                marketCode: marketCode,
                tradeType: tradeType,
                code: code,
                quantity: quantity,
                currency: currency,
                price: price,
                currencyUsed: currencyUsed,
                moneyUsed: moneyUsed,
                remark: remark,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TradeRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TradeRecordsTable,
      TradeRecord,
      $$TradeRecordsTableFilterComposer,
      $$TradeRecordsTableOrderingComposer,
      $$TradeRecordsTableAnnotationComposer,
      $$TradeRecordsTableCreateCompanionBuilder,
      $$TradeRecordsTableUpdateCompanionBuilder,
      (
        TradeRecord,
        BaseReferences<_$AppDatabase, $TradeRecordsTable, TradeRecord>,
      ),
      TradeRecord,
      PrefetchHooks Function()
    >;
typedef $$TradeSellMappingsTableCreateCompanionBuilder =
    TradeSellMappingsCompanion Function({
      Value<int> id,
      required int sellId,
      required int buyId,
      required double quantity,
    });
typedef $$TradeSellMappingsTableUpdateCompanionBuilder =
    TradeSellMappingsCompanion Function({
      Value<int> id,
      Value<int> sellId,
      Value<int> buyId,
      Value<double> quantity,
    });

class $$TradeSellMappingsTableFilterComposer
    extends Composer<_$AppDatabase, $TradeSellMappingsTable> {
  $$TradeSellMappingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sellId => $composableBuilder(
    column: $table.sellId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get buyId => $composableBuilder(
    column: $table.buyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TradeSellMappingsTableOrderingComposer
    extends Composer<_$AppDatabase, $TradeSellMappingsTable> {
  $$TradeSellMappingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sellId => $composableBuilder(
    column: $table.sellId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get buyId => $composableBuilder(
    column: $table.buyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TradeSellMappingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TradeSellMappingsTable> {
  $$TradeSellMappingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sellId =>
      $composableBuilder(column: $table.sellId, builder: (column) => column);

  GeneratedColumn<int> get buyId =>
      $composableBuilder(column: $table.buyId, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);
}

class $$TradeSellMappingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TradeSellMappingsTable,
          TradeSellMapping,
          $$TradeSellMappingsTableFilterComposer,
          $$TradeSellMappingsTableOrderingComposer,
          $$TradeSellMappingsTableAnnotationComposer,
          $$TradeSellMappingsTableCreateCompanionBuilder,
          $$TradeSellMappingsTableUpdateCompanionBuilder,
          (
            TradeSellMapping,
            BaseReferences<
              _$AppDatabase,
              $TradeSellMappingsTable,
              TradeSellMapping
            >,
          ),
          TradeSellMapping,
          PrefetchHooks Function()
        > {
  $$TradeSellMappingsTableTableManager(
    _$AppDatabase db,
    $TradeSellMappingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TradeSellMappingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TradeSellMappingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TradeSellMappingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sellId = const Value.absent(),
                Value<int> buyId = const Value.absent(),
                Value<double> quantity = const Value.absent(),
              }) => TradeSellMappingsCompanion(
                id: id,
                sellId: sellId,
                buyId: buyId,
                quantity: quantity,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sellId,
                required int buyId,
                required double quantity,
              }) => TradeSellMappingsCompanion.insert(
                id: id,
                sellId: sellId,
                buyId: buyId,
                quantity: quantity,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TradeSellMappingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TradeSellMappingsTable,
      TradeSellMapping,
      $$TradeSellMappingsTableFilterComposer,
      $$TradeSellMappingsTableOrderingComposer,
      $$TradeSellMappingsTableAnnotationComposer,
      $$TradeSellMappingsTableCreateCompanionBuilder,
      $$TradeSellMappingsTableUpdateCompanionBuilder,
      (
        TradeSellMapping,
        BaseReferences<
          _$AppDatabase,
          $TradeSellMappingsTable,
          TradeSellMapping
        >,
      ),
      TradeSellMapping,
      PrefetchHooks Function()
    >;
typedef $$CashFlowsTableCreateCompanionBuilder =
    CashFlowsCompanion Function({
      Value<int> id,
      required DateTime date,
      required String type,
      required Currency currency,
      required double amount,
      Value<String?> remark,
    });
typedef $$CashFlowsTableUpdateCompanionBuilder =
    CashFlowsCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<String> type,
      Value<Currency> currency,
      Value<double> amount,
      Value<String?> remark,
    });

class $$CashFlowsTableFilterComposer
    extends Composer<_$AppDatabase, $CashFlowsTable> {
  $$CashFlowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Currency, Currency, String> get currency =>
      $composableBuilder(
        column: $table.currency,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CashFlowsTableOrderingComposer
    extends Composer<_$AppDatabase, $CashFlowsTable> {
  $$CashFlowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CashFlowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashFlowsTable> {
  $$CashFlowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Currency, String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);
}

class $$CashFlowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashFlowsTable,
          CashFlow,
          $$CashFlowsTableFilterComposer,
          $$CashFlowsTableOrderingComposer,
          $$CashFlowsTableAnnotationComposer,
          $$CashFlowsTableCreateCompanionBuilder,
          $$CashFlowsTableUpdateCompanionBuilder,
          (CashFlow, BaseReferences<_$AppDatabase, $CashFlowsTable, CashFlow>),
          CashFlow,
          PrefetchHooks Function()
        > {
  $$CashFlowsTableTableManager(_$AppDatabase db, $CashFlowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashFlowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashFlowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashFlowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<Currency> currency = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String?> remark = const Value.absent(),
              }) => CashFlowsCompanion(
                id: id,
                date: date,
                type: type,
                currency: currency,
                amount: amount,
                remark: remark,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required String type,
                required Currency currency,
                required double amount,
                Value<String?> remark = const Value.absent(),
              }) => CashFlowsCompanion.insert(
                id: id,
                date: date,
                type: type,
                currency: currency,
                amount: amount,
                remark: remark,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CashFlowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashFlowsTable,
      CashFlow,
      $$CashFlowsTableFilterComposer,
      $$CashFlowsTableOrderingComposer,
      $$CashFlowsTableAnnotationComposer,
      $$CashFlowsTableCreateCompanionBuilder,
      $$CashFlowsTableUpdateCompanionBuilder,
      (CashFlow, BaseReferences<_$AppDatabase, $CashFlowsTable, CashFlow>),
      CashFlow,
      PrefetchHooks Function()
    >;
typedef $$CashBalancesTableCreateCompanionBuilder =
    CashBalancesCompanion Function({
      required Currency currency,
      required double balance,
      Value<DateTime?> updatedAt,
      Value<String?> remark,
      Value<int> rowid,
    });
typedef $$CashBalancesTableUpdateCompanionBuilder =
    CashBalancesCompanion Function({
      Value<Currency> currency,
      Value<double> balance,
      Value<DateTime?> updatedAt,
      Value<String?> remark,
      Value<int> rowid,
    });

class $$CashBalancesTableFilterComposer
    extends Composer<_$AppDatabase, $CashBalancesTable> {
  $$CashBalancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<Currency, Currency, String> get currency =>
      $composableBuilder(
        column: $table.currency,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CashBalancesTableOrderingComposer
    extends Composer<_$AppDatabase, $CashBalancesTable> {
  $$CashBalancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CashBalancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashBalancesTable> {
  $$CashBalancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<Currency, String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);
}

class $$CashBalancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashBalancesTable,
          CashBalance,
          $$CashBalancesTableFilterComposer,
          $$CashBalancesTableOrderingComposer,
          $$CashBalancesTableAnnotationComposer,
          $$CashBalancesTableCreateCompanionBuilder,
          $$CashBalancesTableUpdateCompanionBuilder,
          (
            CashBalance,
            BaseReferences<_$AppDatabase, $CashBalancesTable, CashBalance>,
          ),
          CashBalance,
          PrefetchHooks Function()
        > {
  $$CashBalancesTableTableManager(_$AppDatabase db, $CashBalancesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashBalancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashBalancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashBalancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<Currency> currency = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashBalancesCompanion(
                currency: currency,
                balance: balance,
                updatedAt: updatedAt,
                remark: remark,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required Currency currency,
                required double balance,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CashBalancesCompanion.insert(
                currency: currency,
                balance: balance,
                updatedAt: updatedAt,
                remark: remark,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CashBalancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashBalancesTable,
      CashBalance,
      $$CashBalancesTableFilterComposer,
      $$CashBalancesTableOrderingComposer,
      $$CashBalancesTableAnnotationComposer,
      $$CashBalancesTableCreateCompanionBuilder,
      $$CashBalancesTableUpdateCompanionBuilder,
      (
        CashBalance,
        BaseReferences<_$AppDatabase, $CashBalancesTable, CashBalance>,
      ),
      CashBalance,
      PrefetchHooks Function()
    >;
typedef $$CashBalanceHistoriesTableCreateCompanionBuilder =
    CashBalanceHistoriesCompanion Function({
      Value<int> id,
      required Currency currency,
      required double balance,
      required DateTime timestamp,
      Value<String?> remark,
    });
typedef $$CashBalanceHistoriesTableUpdateCompanionBuilder =
    CashBalanceHistoriesCompanion Function({
      Value<int> id,
      Value<Currency> currency,
      Value<double> balance,
      Value<DateTime> timestamp,
      Value<String?> remark,
    });

class $$CashBalanceHistoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CashBalanceHistoriesTable> {
  $$CashBalanceHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Currency, Currency, String> get currency =>
      $composableBuilder(
        column: $table.currency,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CashBalanceHistoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CashBalanceHistoriesTable> {
  $$CashBalanceHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get balance => $composableBuilder(
    column: $table.balance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CashBalanceHistoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashBalanceHistoriesTable> {
  $$CashBalanceHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Currency, String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);
}

class $$CashBalanceHistoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashBalanceHistoriesTable,
          CashBalanceHistory,
          $$CashBalanceHistoriesTableFilterComposer,
          $$CashBalanceHistoriesTableOrderingComposer,
          $$CashBalanceHistoriesTableAnnotationComposer,
          $$CashBalanceHistoriesTableCreateCompanionBuilder,
          $$CashBalanceHistoriesTableUpdateCompanionBuilder,
          (
            CashBalanceHistory,
            BaseReferences<
              _$AppDatabase,
              $CashBalanceHistoriesTable,
              CashBalanceHistory
            >,
          ),
          CashBalanceHistory,
          PrefetchHooks Function()
        > {
  $$CashBalanceHistoriesTableTableManager(
    _$AppDatabase db,
    $CashBalanceHistoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashBalanceHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashBalanceHistoriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CashBalanceHistoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<Currency> currency = const Value.absent(),
                Value<double> balance = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> remark = const Value.absent(),
              }) => CashBalanceHistoriesCompanion(
                id: id,
                currency: currency,
                balance: balance,
                timestamp: timestamp,
                remark: remark,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required Currency currency,
                required double balance,
                required DateTime timestamp,
                Value<String?> remark = const Value.absent(),
              }) => CashBalanceHistoriesCompanion.insert(
                id: id,
                currency: currency,
                balance: balance,
                timestamp: timestamp,
                remark: remark,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CashBalanceHistoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashBalanceHistoriesTable,
      CashBalanceHistory,
      $$CashBalanceHistoriesTableFilterComposer,
      $$CashBalanceHistoriesTableOrderingComposer,
      $$CashBalanceHistoriesTableAnnotationComposer,
      $$CashBalanceHistoriesTableCreateCompanionBuilder,
      $$CashBalanceHistoriesTableUpdateCompanionBuilder,
      (
        CashBalanceHistory,
        BaseReferences<
          _$AppDatabase,
          $CashBalanceHistoriesTable,
          CashBalanceHistory
        >,
      ),
      CashBalanceHistory,
      PrefetchHooks Function()
    >;
typedef $$MarketDataTableCreateCompanionBuilder =
    MarketDataCompanion Function({
      required String code,
      required String name,
      Value<String?> currency,
      Value<String?> surfix,
      Value<int?> colorHex,
      Value<int> sortOrder,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$MarketDataTableUpdateCompanionBuilder =
    MarketDataCompanion Function({
      Value<String> code,
      Value<String> name,
      Value<String?> currency,
      Value<String?> surfix,
      Value<int?> colorHex,
      Value<int> sortOrder,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$MarketDataTableFilterComposer
    extends Composer<_$AppDatabase, $MarketDataTable> {
  $$MarketDataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surfix => $composableBuilder(
    column: $table.surfix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MarketDataTableOrderingComposer
    extends Composer<_$AppDatabase, $MarketDataTable> {
  $$MarketDataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surfix => $composableBuilder(
    column: $table.surfix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MarketDataTableAnnotationComposer
    extends Composer<_$AppDatabase, $MarketDataTable> {
  $$MarketDataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get surfix =>
      $composableBuilder(column: $table.surfix, builder: (column) => column);

  GeneratedColumn<int> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$MarketDataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MarketDataTable,
          MarketDataData,
          $$MarketDataTableFilterComposer,
          $$MarketDataTableOrderingComposer,
          $$MarketDataTableAnnotationComposer,
          $$MarketDataTableCreateCompanionBuilder,
          $$MarketDataTableUpdateCompanionBuilder,
          (
            MarketDataData,
            BaseReferences<_$AppDatabase, $MarketDataTable, MarketDataData>,
          ),
          MarketDataData,
          PrefetchHooks Function()
        > {
  $$MarketDataTableTableManager(_$AppDatabase db, $MarketDataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MarketDataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MarketDataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MarketDataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<String?> surfix = const Value.absent(),
                Value<int?> colorHex = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MarketDataCompanion(
                code: code,
                name: name,
                currency: currency,
                surfix: surfix,
                colorHex: colorHex,
                sortOrder: sortOrder,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String name,
                Value<String?> currency = const Value.absent(),
                Value<String?> surfix = const Value.absent(),
                Value<int?> colorHex = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MarketDataCompanion.insert(
                code: code,
                name: name,
                currency: currency,
                surfix: surfix,
                colorHex: colorHex,
                sortOrder: sortOrder,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MarketDataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MarketDataTable,
      MarketDataData,
      $$MarketDataTableFilterComposer,
      $$MarketDataTableOrderingComposer,
      $$MarketDataTableAnnotationComposer,
      $$MarketDataTableCreateCompanionBuilder,
      $$MarketDataTableUpdateCompanionBuilder,
      (
        MarketDataData,
        BaseReferences<_$AppDatabase, $MarketDataTable, MarketDataData>,
      ),
      MarketDataData,
      PrefetchHooks Function()
    >;
typedef $$StocksTableCreateCompanionBuilder =
    StocksCompanion Function({
      required String code,
      required String name,
      required String marketCode,
      required String currency,
      Value<double?> currentPrice,
      Value<DateTime?> priceUpdatedAt,
      Value<String?> remark,
      Value<int> rowid,
    });
typedef $$StocksTableUpdateCompanionBuilder =
    StocksCompanion Function({
      Value<String> code,
      Value<String> name,
      Value<String> marketCode,
      Value<String> currency,
      Value<double?> currentPrice,
      Value<DateTime?> priceUpdatedAt,
      Value<String?> remark,
      Value<int> rowid,
    });

class $$StocksTableFilterComposer
    extends Composer<_$AppDatabase, $StocksTable> {
  $$StocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get marketCode => $composableBuilder(
    column: $table.marketCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentPrice => $composableBuilder(
    column: $table.currentPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get priceUpdatedAt => $composableBuilder(
    column: $table.priceUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StocksTableOrderingComposer
    extends Composer<_$AppDatabase, $StocksTable> {
  $$StocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marketCode => $composableBuilder(
    column: $table.marketCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentPrice => $composableBuilder(
    column: $table.currentPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get priceUpdatedAt => $composableBuilder(
    column: $table.priceUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $StocksTable> {
  $$StocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get marketCode => $composableBuilder(
    column: $table.marketCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<double> get currentPrice => $composableBuilder(
    column: $table.currentPrice,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get priceUpdatedAt => $composableBuilder(
    column: $table.priceUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);
}

class $$StocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StocksTable,
          Stock,
          $$StocksTableFilterComposer,
          $$StocksTableOrderingComposer,
          $$StocksTableAnnotationComposer,
          $$StocksTableCreateCompanionBuilder,
          $$StocksTableUpdateCompanionBuilder,
          (Stock, BaseReferences<_$AppDatabase, $StocksTable, Stock>),
          Stock,
          PrefetchHooks Function()
        > {
  $$StocksTableTableManager(_$AppDatabase db, $StocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> marketCode = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<double?> currentPrice = const Value.absent(),
                Value<DateTime?> priceUpdatedAt = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StocksCompanion(
                code: code,
                name: name,
                marketCode: marketCode,
                currency: currency,
                currentPrice: currentPrice,
                priceUpdatedAt: priceUpdatedAt,
                remark: remark,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String name,
                required String marketCode,
                required String currency,
                Value<double?> currentPrice = const Value.absent(),
                Value<DateTime?> priceUpdatedAt = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StocksCompanion.insert(
                code: code,
                name: name,
                marketCode: marketCode,
                currency: currency,
                currentPrice: currentPrice,
                priceUpdatedAt: priceUpdatedAt,
                remark: remark,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StocksTable,
      Stock,
      $$StocksTableFilterComposer,
      $$StocksTableOrderingComposer,
      $$StocksTableAnnotationComposer,
      $$StocksTableCreateCompanionBuilder,
      $$StocksTableUpdateCompanionBuilder,
      (Stock, BaseReferences<_$AppDatabase, $StocksTable, Stock>),
      Stock,
      PrefetchHooks Function()
    >;
typedef $$ExchangeRatesTableCreateCompanionBuilder =
    ExchangeRatesCompanion Function({
      Value<int> id,
      required DateTime date,
      required Currency fromCurrency,
      required Currency toCurrency,
      required double rate,
      required DateTime updatedAt,
      Value<String?> remark,
    });
typedef $$ExchangeRatesTableUpdateCompanionBuilder =
    ExchangeRatesCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<Currency> fromCurrency,
      Value<Currency> toCurrency,
      Value<double> rate,
      Value<DateTime> updatedAt,
      Value<String?> remark,
    });

class $$ExchangeRatesTableFilterComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Currency, Currency, String> get fromCurrency =>
      $composableBuilder(
        column: $table.fromCurrency,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Currency, Currency, String> get toCurrency =>
      $composableBuilder(
        column: $table.toCurrency,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExchangeRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromCurrency => $composableBuilder(
    column: $table.fromCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toCurrency => $composableBuilder(
    column: $table.toCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExchangeRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Currency, String> get fromCurrency =>
      $composableBuilder(
        column: $table.fromCurrency,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Currency, String> get toCurrency =>
      $composableBuilder(
        column: $table.toCurrency,
        builder: (column) => column,
      );

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);
}

class $$ExchangeRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExchangeRatesTable,
          ExchangeRate,
          $$ExchangeRatesTableFilterComposer,
          $$ExchangeRatesTableOrderingComposer,
          $$ExchangeRatesTableAnnotationComposer,
          $$ExchangeRatesTableCreateCompanionBuilder,
          $$ExchangeRatesTableUpdateCompanionBuilder,
          (
            ExchangeRate,
            BaseReferences<_$AppDatabase, $ExchangeRatesTable, ExchangeRate>,
          ),
          ExchangeRate,
          PrefetchHooks Function()
        > {
  $$ExchangeRatesTableTableManager(_$AppDatabase db, $ExchangeRatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExchangeRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExchangeRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExchangeRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<Currency> fromCurrency = const Value.absent(),
                Value<Currency> toCurrency = const Value.absent(),
                Value<double> rate = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> remark = const Value.absent(),
              }) => ExchangeRatesCompanion(
                id: id,
                date: date,
                fromCurrency: fromCurrency,
                toCurrency: toCurrency,
                rate: rate,
                updatedAt: updatedAt,
                remark: remark,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required Currency fromCurrency,
                required Currency toCurrency,
                required double rate,
                required DateTime updatedAt,
                Value<String?> remark = const Value.absent(),
              }) => ExchangeRatesCompanion.insert(
                id: id,
                date: date,
                fromCurrency: fromCurrency,
                toCurrency: toCurrency,
                rate: rate,
                updatedAt: updatedAt,
                remark: remark,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExchangeRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExchangeRatesTable,
      ExchangeRate,
      $$ExchangeRatesTableFilterComposer,
      $$ExchangeRatesTableOrderingComposer,
      $$ExchangeRatesTableAnnotationComposer,
      $$ExchangeRatesTableCreateCompanionBuilder,
      $$ExchangeRatesTableUpdateCompanionBuilder,
      (
        ExchangeRate,
        BaseReferences<_$AppDatabase, $ExchangeRatesTable, ExchangeRate>,
      ),
      ExchangeRate,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TradeRecordsTableTableManager get tradeRecords =>
      $$TradeRecordsTableTableManager(_db, _db.tradeRecords);
  $$TradeSellMappingsTableTableManager get tradeSellMappings =>
      $$TradeSellMappingsTableTableManager(_db, _db.tradeSellMappings);
  $$CashFlowsTableTableManager get cashFlows =>
      $$CashFlowsTableTableManager(_db, _db.cashFlows);
  $$CashBalancesTableTableManager get cashBalances =>
      $$CashBalancesTableTableManager(_db, _db.cashBalances);
  $$CashBalanceHistoriesTableTableManager get cashBalanceHistories =>
      $$CashBalanceHistoriesTableTableManager(_db, _db.cashBalanceHistories);
  $$MarketDataTableTableManager get marketData =>
      $$MarketDataTableTableManager(_db, _db.marketData);
  $$StocksTableTableManager get stocks =>
      $$StocksTableTableManager(_db, _db.stocks);
  $$ExchangeRatesTableTableManager get exchangeRates =>
      $$ExchangeRatesTableTableManager(_db, _db.exchangeRates);
}
