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
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
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
    categoryId,
    tradeType,
    name,
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
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      tradeType: $TradeRecordsTable.$convertertradeType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}trade_type'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
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
  final int categoryId;
  final TradeType tradeType;
  final String name;
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
    required this.categoryId,
    required this.tradeType,
    required this.name,
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
    map['category_id'] = Variable<int>(categoryId);
    {
      map['trade_type'] = Variable<String>(
        $TradeRecordsTable.$convertertradeType.toSql(tradeType),
      );
    }
    map['name'] = Variable<String>(name);
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
      categoryId: Value(categoryId),
      tradeType: Value(tradeType),
      name: Value(name),
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
      categoryId: serializer.fromJson<int>(json['categoryId']),
      tradeType: serializer.fromJson<TradeType>(json['tradeType']),
      name: serializer.fromJson<String>(json['name']),
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
      'categoryId': serializer.toJson<int>(categoryId),
      'tradeType': serializer.toJson<TradeType>(tradeType),
      'name': serializer.toJson<String>(name),
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
    int? categoryId,
    TradeType? tradeType,
    String? name,
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
    categoryId: categoryId ?? this.categoryId,
    tradeType: tradeType ?? this.tradeType,
    name: name ?? this.name,
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
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      tradeType: data.tradeType.present ? data.tradeType.value : this.tradeType,
      name: data.name.present ? data.name.value : this.name,
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
          ..write('categoryId: $categoryId, ')
          ..write('tradeType: $tradeType, ')
          ..write('name: $name, ')
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
    categoryId,
    tradeType,
    name,
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
          other.categoryId == this.categoryId &&
          other.tradeType == this.tradeType &&
          other.name == this.name &&
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
  final Value<int> categoryId;
  final Value<TradeType> tradeType;
  final Value<String> name;
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
    this.categoryId = const Value.absent(),
    this.tradeType = const Value.absent(),
    this.name = const Value.absent(),
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
    required int categoryId,
    required TradeType tradeType,
    required String name,
    required String code,
    required double quantity,
    required Currency currency,
    required double price,
    required Currency currencyUsed,
    required double moneyUsed,
    this.remark = const Value.absent(),
  }) : tradeDate = Value(tradeDate),
       action = Value(action),
       categoryId = Value(categoryId),
       tradeType = Value(tradeType),
       name = Value(name),
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
    Expression<int>? categoryId,
    Expression<String>? tradeType,
    Expression<String>? name,
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
      if (categoryId != null) 'category_id': categoryId,
      if (tradeType != null) 'trade_type': tradeType,
      if (name != null) 'name': name,
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
    Value<int>? categoryId,
    Value<TradeType>? tradeType,
    Value<String>? name,
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
      categoryId: categoryId ?? this.categoryId,
      tradeType: tradeType ?? this.tradeType,
      name: name ?? this.name,
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
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (tradeType.present) {
      map['trade_type'] = Variable<String>(
        $TradeRecordsTable.$convertertradeType.toSql(tradeType.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
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
          ..write('categoryId: $categoryId, ')
          ..write('tradeType: $tradeType, ')
          ..write('name: $name, ')
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

class $TradeCategoriesTable extends TradeCategories
    with TableInfo<$TradeCategoriesTable, TradeCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TradeCategoriesTable(this.attachedDatabase, [this._alias]);
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
    id,
    name,
    colorHex,
    sortOrder,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trade_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<TradeCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TradeCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TradeCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
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
  $TradeCategoriesTable createAlias(String alias) {
    return $TradeCategoriesTable(attachedDatabase, alias);
  }
}

class TradeCategory extends DataClass implements Insertable<TradeCategory> {
  final int id;
  final String name;
  final int? colorHex;
  final int sortOrder;
  final bool isActive;
  const TradeCategory({
    required this.id,
    required this.name,
    this.colorHex,
    required this.sortOrder,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || colorHex != null) {
      map['color_hex'] = Variable<int>(colorHex);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  TradeCategoriesCompanion toCompanion(bool nullToAbsent) {
    return TradeCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      colorHex: colorHex == null && nullToAbsent
          ? const Value.absent()
          : Value(colorHex),
      sortOrder: Value(sortOrder),
      isActive: Value(isActive),
    );
  }

  factory TradeCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TradeCategory(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorHex: serializer.fromJson<int?>(json['colorHex']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'colorHex': serializer.toJson<int?>(colorHex),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  TradeCategory copyWith({
    int? id,
    String? name,
    Value<int?> colorHex = const Value.absent(),
    int? sortOrder,
    bool? isActive,
  }) => TradeCategory(
    id: id ?? this.id,
    name: name ?? this.name,
    colorHex: colorHex.present ? colorHex.value : this.colorHex,
    sortOrder: sortOrder ?? this.sortOrder,
    isActive: isActive ?? this.isActive,
  );
  TradeCategory copyWithCompanion(TradeCategoriesCompanion data) {
    return TradeCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TradeCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, colorHex, sortOrder, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TradeCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorHex == this.colorHex &&
          other.sortOrder == this.sortOrder &&
          other.isActive == this.isActive);
}

class TradeCategoriesCompanion extends UpdateCompanion<TradeCategory> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> colorHex;
  final Value<int> sortOrder;
  final Value<bool> isActive;
  const TradeCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  TradeCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : name = Value(name);
  static Insertable<TradeCategory> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? colorHex,
    Expression<int>? sortOrder,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorHex != null) 'color_hex': colorHex,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isActive != null) 'is_active': isActive,
    });
  }

  TradeCategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? colorHex,
    Value<int>? sortOrder,
    Value<bool>? isActive,
  }) {
    return TradeCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TradeCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isActive: $isActive')
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
  late final $TradeCategoriesTable tradeCategories = $TradeCategoriesTable(
    this,
  );
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
    tradeCategories,
  ];
}

typedef $$TradeRecordsTableCreateCompanionBuilder =
    TradeRecordsCompanion Function({
      Value<int> id,
      required DateTime tradeDate,
      required TradeAction action,
      required int categoryId,
      required TradeType tradeType,
      required String name,
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
      Value<int> categoryId,
      Value<TradeType> tradeType,
      Value<String> name,
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

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TradeType, TradeType, String> get tradeType =>
      $composableBuilder(
        column: $table.tradeType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
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

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tradeType => $composableBuilder(
    column: $table.tradeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
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

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TradeType, String> get tradeType =>
      $composableBuilder(column: $table.tradeType, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

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
                Value<int> categoryId = const Value.absent(),
                Value<TradeType> tradeType = const Value.absent(),
                Value<String> name = const Value.absent(),
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
                categoryId: categoryId,
                tradeType: tradeType,
                name: name,
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
                required int categoryId,
                required TradeType tradeType,
                required String name,
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
                categoryId: categoryId,
                tradeType: tradeType,
                name: name,
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
typedef $$TradeCategoriesTableCreateCompanionBuilder =
    TradeCategoriesCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> colorHex,
      Value<int> sortOrder,
      Value<bool> isActive,
    });
typedef $$TradeCategoriesTableUpdateCompanionBuilder =
    TradeCategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> colorHex,
      Value<int> sortOrder,
      Value<bool> isActive,
    });

class $$TradeCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $TradeCategoriesTable> {
  $$TradeCategoriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
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

class $$TradeCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TradeCategoriesTable> {
  $$TradeCategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
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

class $$TradeCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TradeCategoriesTable> {
  $$TradeCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$TradeCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TradeCategoriesTable,
          TradeCategory,
          $$TradeCategoriesTableFilterComposer,
          $$TradeCategoriesTableOrderingComposer,
          $$TradeCategoriesTableAnnotationComposer,
          $$TradeCategoriesTableCreateCompanionBuilder,
          $$TradeCategoriesTableUpdateCompanionBuilder,
          (
            TradeCategory,
            BaseReferences<_$AppDatabase, $TradeCategoriesTable, TradeCategory>,
          ),
          TradeCategory,
          PrefetchHooks Function()
        > {
  $$TradeCategoriesTableTableManager(
    _$AppDatabase db,
    $TradeCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TradeCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TradeCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TradeCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> colorHex = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => TradeCategoriesCompanion(
                id: id,
                name: name,
                colorHex: colorHex,
                sortOrder: sortOrder,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> colorHex = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => TradeCategoriesCompanion.insert(
                id: id,
                name: name,
                colorHex: colorHex,
                sortOrder: sortOrder,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TradeCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TradeCategoriesTable,
      TradeCategory,
      $$TradeCategoriesTableFilterComposer,
      $$TradeCategoriesTableOrderingComposer,
      $$TradeCategoriesTableAnnotationComposer,
      $$TradeCategoriesTableCreateCompanionBuilder,
      $$TradeCategoriesTableUpdateCompanionBuilder,
      (
        TradeCategory,
        BaseReferences<_$AppDatabase, $TradeCategoriesTable, TradeCategory>,
      ),
      TradeCategory,
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
  $$TradeCategoriesTableTableManager get tradeCategories =>
      $$TradeCategoriesTableTableManager(_db, _db.tradeCategories);
}
