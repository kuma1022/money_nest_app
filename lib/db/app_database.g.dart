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
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assetTypeMeta = const VerificationMeta(
    'assetType',
  );
  @override
  late final GeneratedColumn<String> assetType = GeneratedColumn<String>(
    'asset_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<int> assetId = GeneratedColumn<int>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tradeTypeMeta = const VerificationMeta(
    'tradeType',
  );
  @override
  late final GeneratedColumn<String> tradeType = GeneratedColumn<String>(
    'trade_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feeAmountMeta = const VerificationMeta(
    'feeAmount',
  );
  @override
  late final GeneratedColumn<double> feeAmount = GeneratedColumn<double>(
    'fee_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _feeCurrencyMeta = const VerificationMeta(
    'feeCurrency',
  );
  @override
  late final GeneratedColumn<String> feeCurrency = GeneratedColumn<String>(
    'fee_currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionTypeMeta = const VerificationMeta(
    'positionType',
  );
  @override
  late final GeneratedColumn<String> positionType = GeneratedColumn<String>(
    'position_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _leverageMeta = const VerificationMeta(
    'leverage',
  );
  @override
  late final GeneratedColumn<double> leverage = GeneratedColumn<double>(
    'leverage',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _swapAmountMeta = const VerificationMeta(
    'swapAmount',
  );
  @override
  late final GeneratedColumn<double> swapAmount = GeneratedColumn<double>(
    'swap_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _swapCurrencyMeta = const VerificationMeta(
    'swapCurrency',
  );
  @override
  late final GeneratedColumn<String> swapCurrency = GeneratedColumn<String>(
    'swap_currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _manualRateInputMeta = const VerificationMeta(
    'manualRateInput',
  );
  @override
  late final GeneratedColumn<bool> manualRateInput = GeneratedColumn<bool>(
    'manual_rate_input',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("manual_rate_input" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _profitMeta = const VerificationMeta('profit');
  @override
  late final GeneratedColumn<double> profit = GeneratedColumn<double>(
    'profit',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    accountId,
    assetType,
    assetId,
    tradeDate,
    action,
    tradeType,
    quantity,
    price,
    feeAmount,
    feeCurrency,
    positionType,
    leverage,
    swapAmount,
    swapCurrency,
    manualRateInput,
    remark,
    createdAt,
    updatedAt,
    profit,
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
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('asset_type')) {
      context.handle(
        _assetTypeMeta,
        assetType.isAcceptableOrUnknown(data['asset_type']!, _assetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_assetTypeMeta);
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('trade_date')) {
      context.handle(
        _tradeDateMeta,
        tradeDate.isAcceptableOrUnknown(data['trade_date']!, _tradeDateMeta),
      );
    } else if (isInserting) {
      context.missing(_tradeDateMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('trade_type')) {
      context.handle(
        _tradeTypeMeta,
        tradeType.isAcceptableOrUnknown(data['trade_type']!, _tradeTypeMeta),
      );
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
    if (data.containsKey('fee_amount')) {
      context.handle(
        _feeAmountMeta,
        feeAmount.isAcceptableOrUnknown(data['fee_amount']!, _feeAmountMeta),
      );
    }
    if (data.containsKey('fee_currency')) {
      context.handle(
        _feeCurrencyMeta,
        feeCurrency.isAcceptableOrUnknown(
          data['fee_currency']!,
          _feeCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('position_type')) {
      context.handle(
        _positionTypeMeta,
        positionType.isAcceptableOrUnknown(
          data['position_type']!,
          _positionTypeMeta,
        ),
      );
    }
    if (data.containsKey('leverage')) {
      context.handle(
        _leverageMeta,
        leverage.isAcceptableOrUnknown(data['leverage']!, _leverageMeta),
      );
    }
    if (data.containsKey('swap_amount')) {
      context.handle(
        _swapAmountMeta,
        swapAmount.isAcceptableOrUnknown(data['swap_amount']!, _swapAmountMeta),
      );
    }
    if (data.containsKey('swap_currency')) {
      context.handle(
        _swapCurrencyMeta,
        swapCurrency.isAcceptableOrUnknown(
          data['swap_currency']!,
          _swapCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('manual_rate_input')) {
      context.handle(
        _manualRateInputMeta,
        manualRateInput.isAcceptableOrUnknown(
          data['manual_rate_input']!,
          _manualRateInputMeta,
        ),
      );
    }
    if (data.containsKey('remark')) {
      context.handle(
        _remarkMeta,
        remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('profit')) {
      context.handle(
        _profitMeta,
        profit.isAcceptableOrUnknown(data['profit']!, _profitMeta),
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
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      ),
      assetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_type'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asset_id'],
      )!,
      tradeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}trade_date'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      tradeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trade_type'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      feeAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fee_amount'],
      ),
      feeCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fee_currency'],
      ),
      positionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position_type'],
      ),
      leverage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}leverage'],
      ),
      swapAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}swap_amount'],
      ),
      swapCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}swap_currency'],
      ),
      manualRateInput: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}manual_rate_input'],
      ),
      remark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remark'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      profit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}profit'],
      ),
    );
  }

  @override
  $TradeRecordsTable createAlias(String alias) {
    return $TradeRecordsTable(attachedDatabase, alias);
  }
}

class TradeRecord extends DataClass implements Insertable<TradeRecord> {
  final int id;
  final String userId;
  final int? accountId;
  final String assetType;
  final int assetId;
  final DateTime tradeDate;
  final String action;
  final String? tradeType;
  final double quantity;
  final double price;
  final double? feeAmount;
  final String? feeCurrency;
  final String? positionType;
  final double? leverage;
  final double? swapAmount;
  final String? swapCurrency;
  final bool? manualRateInput;
  final String? remark;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? profit;
  const TradeRecord({
    required this.id,
    required this.userId,
    this.accountId,
    required this.assetType,
    required this.assetId,
    required this.tradeDate,
    required this.action,
    this.tradeType,
    required this.quantity,
    required this.price,
    this.feeAmount,
    this.feeCurrency,
    this.positionType,
    this.leverage,
    this.swapAmount,
    this.swapCurrency,
    this.manualRateInput,
    this.remark,
    required this.createdAt,
    required this.updatedAt,
    this.profit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    map['asset_type'] = Variable<String>(assetType);
    map['asset_id'] = Variable<int>(assetId);
    map['trade_date'] = Variable<DateTime>(tradeDate);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || tradeType != null) {
      map['trade_type'] = Variable<String>(tradeType);
    }
    map['quantity'] = Variable<double>(quantity);
    map['price'] = Variable<double>(price);
    if (!nullToAbsent || feeAmount != null) {
      map['fee_amount'] = Variable<double>(feeAmount);
    }
    if (!nullToAbsent || feeCurrency != null) {
      map['fee_currency'] = Variable<String>(feeCurrency);
    }
    if (!nullToAbsent || positionType != null) {
      map['position_type'] = Variable<String>(positionType);
    }
    if (!nullToAbsent || leverage != null) {
      map['leverage'] = Variable<double>(leverage);
    }
    if (!nullToAbsent || swapAmount != null) {
      map['swap_amount'] = Variable<double>(swapAmount);
    }
    if (!nullToAbsent || swapCurrency != null) {
      map['swap_currency'] = Variable<String>(swapCurrency);
    }
    if (!nullToAbsent || manualRateInput != null) {
      map['manual_rate_input'] = Variable<bool>(manualRateInput);
    }
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || profit != null) {
      map['profit'] = Variable<double>(profit);
    }
    return map;
  }

  TradeRecordsCompanion toCompanion(bool nullToAbsent) {
    return TradeRecordsCompanion(
      id: Value(id),
      userId: Value(userId),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      assetType: Value(assetType),
      assetId: Value(assetId),
      tradeDate: Value(tradeDate),
      action: Value(action),
      tradeType: tradeType == null && nullToAbsent
          ? const Value.absent()
          : Value(tradeType),
      quantity: Value(quantity),
      price: Value(price),
      feeAmount: feeAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(feeAmount),
      feeCurrency: feeCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(feeCurrency),
      positionType: positionType == null && nullToAbsent
          ? const Value.absent()
          : Value(positionType),
      leverage: leverage == null && nullToAbsent
          ? const Value.absent()
          : Value(leverage),
      swapAmount: swapAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(swapAmount),
      swapCurrency: swapCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(swapCurrency),
      manualRateInput: manualRateInput == null && nullToAbsent
          ? const Value.absent()
          : Value(manualRateInput),
      remark: remark == null && nullToAbsent
          ? const Value.absent()
          : Value(remark),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      profit: profit == null && nullToAbsent
          ? const Value.absent()
          : Value(profit),
    );
  }

  factory TradeRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TradeRecord(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      assetType: serializer.fromJson<String>(json['assetType']),
      assetId: serializer.fromJson<int>(json['assetId']),
      tradeDate: serializer.fromJson<DateTime>(json['tradeDate']),
      action: serializer.fromJson<String>(json['action']),
      tradeType: serializer.fromJson<String?>(json['tradeType']),
      quantity: serializer.fromJson<double>(json['quantity']),
      price: serializer.fromJson<double>(json['price']),
      feeAmount: serializer.fromJson<double?>(json['feeAmount']),
      feeCurrency: serializer.fromJson<String?>(json['feeCurrency']),
      positionType: serializer.fromJson<String?>(json['positionType']),
      leverage: serializer.fromJson<double?>(json['leverage']),
      swapAmount: serializer.fromJson<double?>(json['swapAmount']),
      swapCurrency: serializer.fromJson<String?>(json['swapCurrency']),
      manualRateInput: serializer.fromJson<bool?>(json['manualRateInput']),
      remark: serializer.fromJson<String?>(json['remark']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      profit: serializer.fromJson<double?>(json['profit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'accountId': serializer.toJson<int?>(accountId),
      'assetType': serializer.toJson<String>(assetType),
      'assetId': serializer.toJson<int>(assetId),
      'tradeDate': serializer.toJson<DateTime>(tradeDate),
      'action': serializer.toJson<String>(action),
      'tradeType': serializer.toJson<String?>(tradeType),
      'quantity': serializer.toJson<double>(quantity),
      'price': serializer.toJson<double>(price),
      'feeAmount': serializer.toJson<double?>(feeAmount),
      'feeCurrency': serializer.toJson<String?>(feeCurrency),
      'positionType': serializer.toJson<String?>(positionType),
      'leverage': serializer.toJson<double?>(leverage),
      'swapAmount': serializer.toJson<double?>(swapAmount),
      'swapCurrency': serializer.toJson<String?>(swapCurrency),
      'manualRateInput': serializer.toJson<bool?>(manualRateInput),
      'remark': serializer.toJson<String?>(remark),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'profit': serializer.toJson<double?>(profit),
    };
  }

  TradeRecord copyWith({
    int? id,
    String? userId,
    Value<int?> accountId = const Value.absent(),
    String? assetType,
    int? assetId,
    DateTime? tradeDate,
    String? action,
    Value<String?> tradeType = const Value.absent(),
    double? quantity,
    double? price,
    Value<double?> feeAmount = const Value.absent(),
    Value<String?> feeCurrency = const Value.absent(),
    Value<String?> positionType = const Value.absent(),
    Value<double?> leverage = const Value.absent(),
    Value<double?> swapAmount = const Value.absent(),
    Value<String?> swapCurrency = const Value.absent(),
    Value<bool?> manualRateInput = const Value.absent(),
    Value<String?> remark = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<double?> profit = const Value.absent(),
  }) => TradeRecord(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    accountId: accountId.present ? accountId.value : this.accountId,
    assetType: assetType ?? this.assetType,
    assetId: assetId ?? this.assetId,
    tradeDate: tradeDate ?? this.tradeDate,
    action: action ?? this.action,
    tradeType: tradeType.present ? tradeType.value : this.tradeType,
    quantity: quantity ?? this.quantity,
    price: price ?? this.price,
    feeAmount: feeAmount.present ? feeAmount.value : this.feeAmount,
    feeCurrency: feeCurrency.present ? feeCurrency.value : this.feeCurrency,
    positionType: positionType.present ? positionType.value : this.positionType,
    leverage: leverage.present ? leverage.value : this.leverage,
    swapAmount: swapAmount.present ? swapAmount.value : this.swapAmount,
    swapCurrency: swapCurrency.present ? swapCurrency.value : this.swapCurrency,
    manualRateInput: manualRateInput.present
        ? manualRateInput.value
        : this.manualRateInput,
    remark: remark.present ? remark.value : this.remark,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    profit: profit.present ? profit.value : this.profit,
  );
  TradeRecord copyWithCompanion(TradeRecordsCompanion data) {
    return TradeRecord(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      assetType: data.assetType.present ? data.assetType.value : this.assetType,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      tradeDate: data.tradeDate.present ? data.tradeDate.value : this.tradeDate,
      action: data.action.present ? data.action.value : this.action,
      tradeType: data.tradeType.present ? data.tradeType.value : this.tradeType,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      price: data.price.present ? data.price.value : this.price,
      feeAmount: data.feeAmount.present ? data.feeAmount.value : this.feeAmount,
      feeCurrency: data.feeCurrency.present
          ? data.feeCurrency.value
          : this.feeCurrency,
      positionType: data.positionType.present
          ? data.positionType.value
          : this.positionType,
      leverage: data.leverage.present ? data.leverage.value : this.leverage,
      swapAmount: data.swapAmount.present
          ? data.swapAmount.value
          : this.swapAmount,
      swapCurrency: data.swapCurrency.present
          ? data.swapCurrency.value
          : this.swapCurrency,
      manualRateInput: data.manualRateInput.present
          ? data.manualRateInput.value
          : this.manualRateInput,
      remark: data.remark.present ? data.remark.value : this.remark,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      profit: data.profit.present ? data.profit.value : this.profit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TradeRecord(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('accountId: $accountId, ')
          ..write('assetType: $assetType, ')
          ..write('assetId: $assetId, ')
          ..write('tradeDate: $tradeDate, ')
          ..write('action: $action, ')
          ..write('tradeType: $tradeType, ')
          ..write('quantity: $quantity, ')
          ..write('price: $price, ')
          ..write('feeAmount: $feeAmount, ')
          ..write('feeCurrency: $feeCurrency, ')
          ..write('positionType: $positionType, ')
          ..write('leverage: $leverage, ')
          ..write('swapAmount: $swapAmount, ')
          ..write('swapCurrency: $swapCurrency, ')
          ..write('manualRateInput: $manualRateInput, ')
          ..write('remark: $remark, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('profit: $profit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    userId,
    accountId,
    assetType,
    assetId,
    tradeDate,
    action,
    tradeType,
    quantity,
    price,
    feeAmount,
    feeCurrency,
    positionType,
    leverage,
    swapAmount,
    swapCurrency,
    manualRateInput,
    remark,
    createdAt,
    updatedAt,
    profit,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TradeRecord &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.accountId == this.accountId &&
          other.assetType == this.assetType &&
          other.assetId == this.assetId &&
          other.tradeDate == this.tradeDate &&
          other.action == this.action &&
          other.tradeType == this.tradeType &&
          other.quantity == this.quantity &&
          other.price == this.price &&
          other.feeAmount == this.feeAmount &&
          other.feeCurrency == this.feeCurrency &&
          other.positionType == this.positionType &&
          other.leverage == this.leverage &&
          other.swapAmount == this.swapAmount &&
          other.swapCurrency == this.swapCurrency &&
          other.manualRateInput == this.manualRateInput &&
          other.remark == this.remark &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.profit == this.profit);
}

class TradeRecordsCompanion extends UpdateCompanion<TradeRecord> {
  final Value<int> id;
  final Value<String> userId;
  final Value<int?> accountId;
  final Value<String> assetType;
  final Value<int> assetId;
  final Value<DateTime> tradeDate;
  final Value<String> action;
  final Value<String?> tradeType;
  final Value<double> quantity;
  final Value<double> price;
  final Value<double?> feeAmount;
  final Value<String?> feeCurrency;
  final Value<String?> positionType;
  final Value<double?> leverage;
  final Value<double?> swapAmount;
  final Value<String?> swapCurrency;
  final Value<bool?> manualRateInput;
  final Value<String?> remark;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<double?> profit;
  const TradeRecordsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.assetType = const Value.absent(),
    this.assetId = const Value.absent(),
    this.tradeDate = const Value.absent(),
    this.action = const Value.absent(),
    this.tradeType = const Value.absent(),
    this.quantity = const Value.absent(),
    this.price = const Value.absent(),
    this.feeAmount = const Value.absent(),
    this.feeCurrency = const Value.absent(),
    this.positionType = const Value.absent(),
    this.leverage = const Value.absent(),
    this.swapAmount = const Value.absent(),
    this.swapCurrency = const Value.absent(),
    this.manualRateInput = const Value.absent(),
    this.remark = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.profit = const Value.absent(),
  });
  TradeRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    this.accountId = const Value.absent(),
    required String assetType,
    required int assetId,
    required DateTime tradeDate,
    required String action,
    this.tradeType = const Value.absent(),
    required double quantity,
    required double price,
    this.feeAmount = const Value.absent(),
    this.feeCurrency = const Value.absent(),
    this.positionType = const Value.absent(),
    this.leverage = const Value.absent(),
    this.swapAmount = const Value.absent(),
    this.swapCurrency = const Value.absent(),
    this.manualRateInput = const Value.absent(),
    this.remark = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.profit = const Value.absent(),
  }) : userId = Value(userId),
       assetType = Value(assetType),
       assetId = Value(assetId),
       tradeDate = Value(tradeDate),
       action = Value(action),
       quantity = Value(quantity),
       price = Value(price);
  static Insertable<TradeRecord> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<int>? accountId,
    Expression<String>? assetType,
    Expression<int>? assetId,
    Expression<DateTime>? tradeDate,
    Expression<String>? action,
    Expression<String>? tradeType,
    Expression<double>? quantity,
    Expression<double>? price,
    Expression<double>? feeAmount,
    Expression<String>? feeCurrency,
    Expression<String>? positionType,
    Expression<double>? leverage,
    Expression<double>? swapAmount,
    Expression<String>? swapCurrency,
    Expression<bool>? manualRateInput,
    Expression<String>? remark,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<double>? profit,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (accountId != null) 'account_id': accountId,
      if (assetType != null) 'asset_type': assetType,
      if (assetId != null) 'asset_id': assetId,
      if (tradeDate != null) 'trade_date': tradeDate,
      if (action != null) 'action': action,
      if (tradeType != null) 'trade_type': tradeType,
      if (quantity != null) 'quantity': quantity,
      if (price != null) 'price': price,
      if (feeAmount != null) 'fee_amount': feeAmount,
      if (feeCurrency != null) 'fee_currency': feeCurrency,
      if (positionType != null) 'position_type': positionType,
      if (leverage != null) 'leverage': leverage,
      if (swapAmount != null) 'swap_amount': swapAmount,
      if (swapCurrency != null) 'swap_currency': swapCurrency,
      if (manualRateInput != null) 'manual_rate_input': manualRateInput,
      if (remark != null) 'remark': remark,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (profit != null) 'profit': profit,
    });
  }

  TradeRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<int?>? accountId,
    Value<String>? assetType,
    Value<int>? assetId,
    Value<DateTime>? tradeDate,
    Value<String>? action,
    Value<String?>? tradeType,
    Value<double>? quantity,
    Value<double>? price,
    Value<double?>? feeAmount,
    Value<String?>? feeCurrency,
    Value<String?>? positionType,
    Value<double?>? leverage,
    Value<double?>? swapAmount,
    Value<String?>? swapCurrency,
    Value<bool?>? manualRateInput,
    Value<String?>? remark,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<double?>? profit,
  }) {
    return TradeRecordsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      assetType: assetType ?? this.assetType,
      assetId: assetId ?? this.assetId,
      tradeDate: tradeDate ?? this.tradeDate,
      action: action ?? this.action,
      tradeType: tradeType ?? this.tradeType,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      feeAmount: feeAmount ?? this.feeAmount,
      feeCurrency: feeCurrency ?? this.feeCurrency,
      positionType: positionType ?? this.positionType,
      leverage: leverage ?? this.leverage,
      swapAmount: swapAmount ?? this.swapAmount,
      swapCurrency: swapCurrency ?? this.swapCurrency,
      manualRateInput: manualRateInput ?? this.manualRateInput,
      remark: remark ?? this.remark,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profit: profit ?? this.profit,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (assetType.present) {
      map['asset_type'] = Variable<String>(assetType.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<int>(assetId.value);
    }
    if (tradeDate.present) {
      map['trade_date'] = Variable<DateTime>(tradeDate.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (tradeType.present) {
      map['trade_type'] = Variable<String>(tradeType.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (feeAmount.present) {
      map['fee_amount'] = Variable<double>(feeAmount.value);
    }
    if (feeCurrency.present) {
      map['fee_currency'] = Variable<String>(feeCurrency.value);
    }
    if (positionType.present) {
      map['position_type'] = Variable<String>(positionType.value);
    }
    if (leverage.present) {
      map['leverage'] = Variable<double>(leverage.value);
    }
    if (swapAmount.present) {
      map['swap_amount'] = Variable<double>(swapAmount.value);
    }
    if (swapCurrency.present) {
      map['swap_currency'] = Variable<String>(swapCurrency.value);
    }
    if (manualRateInput.present) {
      map['manual_rate_input'] = Variable<bool>(manualRateInput.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (profit.present) {
      map['profit'] = Variable<double>(profit.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TradeRecordsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('accountId: $accountId, ')
          ..write('assetType: $assetType, ')
          ..write('assetId: $assetId, ')
          ..write('tradeDate: $tradeDate, ')
          ..write('action: $action, ')
          ..write('tradeType: $tradeType, ')
          ..write('quantity: $quantity, ')
          ..write('price: $price, ')
          ..write('feeAmount: $feeAmount, ')
          ..write('feeCurrency: $feeCurrency, ')
          ..write('positionType: $positionType, ')
          ..write('leverage: $leverage, ')
          ..write('swapAmount: $swapAmount, ')
          ..write('swapCurrency: $swapCurrency, ')
          ..write('manualRateInput: $manualRateInput, ')
          ..write('remark: $remark, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('profit: $profit')
          ..write(')'))
        .toString();
  }
}

class $StocksTable extends Stocks with TableInfo<$StocksTable, Stock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tickerMeta = const VerificationMeta('ticker');
  @override
  late final GeneratedColumn<String> ticker = GeneratedColumn<String>(
    'ticker',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exchangeMeta = const VerificationMeta(
    'exchange',
  );
  @override
  late final GeneratedColumn<String> exchange = GeneratedColumn<String>(
    'exchange',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameUsMeta = const VerificationMeta('nameUs');
  @override
  late final GeneratedColumn<String> nameUs = GeneratedColumn<String>(
    'name_us',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 8,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectorIndustryIdMeta = const VerificationMeta(
    'sectorIndustryId',
  );
  @override
  late final GeneratedColumn<int> sectorIndustryId = GeneratedColumn<int>(
    'sector_industry_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logoMeta = const VerificationMeta('logo');
  @override
  late final GeneratedColumn<String> logo = GeneratedColumn<String>(
    'logo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _lastPriceMeta = const VerificationMeta(
    'lastPrice',
  );
  @override
  late final GeneratedColumn<double> lastPrice = GeneratedColumn<double>(
    'last_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPriceAtMeta = const VerificationMeta(
    'lastPriceAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPriceAt = GeneratedColumn<DateTime>(
    'last_price_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ticker,
    exchange,
    name,
    nameUs,
    currency,
    country,
    sectorIndustryId,
    logo,
    status,
    lastPrice,
    lastPriceAt,
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
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ticker')) {
      context.handle(
        _tickerMeta,
        ticker.isAcceptableOrUnknown(data['ticker']!, _tickerMeta),
      );
    }
    if (data.containsKey('exchange')) {
      context.handle(
        _exchangeMeta,
        exchange.isAcceptableOrUnknown(data['exchange']!, _exchangeMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_us')) {
      context.handle(
        _nameUsMeta,
        nameUs.isAcceptableOrUnknown(data['name_us']!, _nameUsMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    } else if (isInserting) {
      context.missing(_countryMeta);
    }
    if (data.containsKey('sector_industry_id')) {
      context.handle(
        _sectorIndustryIdMeta,
        sectorIndustryId.isAcceptableOrUnknown(
          data['sector_industry_id']!,
          _sectorIndustryIdMeta,
        ),
      );
    }
    if (data.containsKey('logo')) {
      context.handle(
        _logoMeta,
        logo.isAcceptableOrUnknown(data['logo']!, _logoMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('last_price')) {
      context.handle(
        _lastPriceMeta,
        lastPrice.isAcceptableOrUnknown(data['last_price']!, _lastPriceMeta),
      );
    }
    if (data.containsKey('last_price_at')) {
      context.handle(
        _lastPriceAtMeta,
        lastPriceAt.isAcceptableOrUnknown(
          data['last_price_at']!,
          _lastPriceAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {ticker, exchange},
  ];
  @override
  Stock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Stock(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ticker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ticker'],
      ),
      exchange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exchange'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameUs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_us'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      )!,
      sectorIndustryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sector_industry_id'],
      ),
      logo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      lastPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_price'],
      ),
      lastPriceAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_price_at'],
      ),
    );
  }

  @override
  $StocksTable createAlias(String alias) {
    return $StocksTable(attachedDatabase, alias);
  }
}

class Stock extends DataClass implements Insertable<Stock> {
  final int id;
  final String? ticker;
  final String? exchange;
  final String name;
  final String? nameUs;
  final String currency;
  final String country;
  final int? sectorIndustryId;
  final String? logo;
  final String status;
  final double? lastPrice;
  final DateTime? lastPriceAt;
  const Stock({
    required this.id,
    this.ticker,
    this.exchange,
    required this.name,
    this.nameUs,
    required this.currency,
    required this.country,
    this.sectorIndustryId,
    this.logo,
    required this.status,
    this.lastPrice,
    this.lastPriceAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || ticker != null) {
      map['ticker'] = Variable<String>(ticker);
    }
    if (!nullToAbsent || exchange != null) {
      map['exchange'] = Variable<String>(exchange);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || nameUs != null) {
      map['name_us'] = Variable<String>(nameUs);
    }
    map['currency'] = Variable<String>(currency);
    map['country'] = Variable<String>(country);
    if (!nullToAbsent || sectorIndustryId != null) {
      map['sector_industry_id'] = Variable<int>(sectorIndustryId);
    }
    if (!nullToAbsent || logo != null) {
      map['logo'] = Variable<String>(logo);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastPrice != null) {
      map['last_price'] = Variable<double>(lastPrice);
    }
    if (!nullToAbsent || lastPriceAt != null) {
      map['last_price_at'] = Variable<DateTime>(lastPriceAt);
    }
    return map;
  }

  StocksCompanion toCompanion(bool nullToAbsent) {
    return StocksCompanion(
      id: Value(id),
      ticker: ticker == null && nullToAbsent
          ? const Value.absent()
          : Value(ticker),
      exchange: exchange == null && nullToAbsent
          ? const Value.absent()
          : Value(exchange),
      name: Value(name),
      nameUs: nameUs == null && nullToAbsent
          ? const Value.absent()
          : Value(nameUs),
      currency: Value(currency),
      country: Value(country),
      sectorIndustryId: sectorIndustryId == null && nullToAbsent
          ? const Value.absent()
          : Value(sectorIndustryId),
      logo: logo == null && nullToAbsent ? const Value.absent() : Value(logo),
      status: Value(status),
      lastPrice: lastPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPrice),
      lastPriceAt: lastPriceAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPriceAt),
    );
  }

  factory Stock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Stock(
      id: serializer.fromJson<int>(json['id']),
      ticker: serializer.fromJson<String?>(json['ticker']),
      exchange: serializer.fromJson<String?>(json['exchange']),
      name: serializer.fromJson<String>(json['name']),
      nameUs: serializer.fromJson<String?>(json['nameUs']),
      currency: serializer.fromJson<String>(json['currency']),
      country: serializer.fromJson<String>(json['country']),
      sectorIndustryId: serializer.fromJson<int?>(json['sectorIndustryId']),
      logo: serializer.fromJson<String?>(json['logo']),
      status: serializer.fromJson<String>(json['status']),
      lastPrice: serializer.fromJson<double?>(json['lastPrice']),
      lastPriceAt: serializer.fromJson<DateTime?>(json['lastPriceAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ticker': serializer.toJson<String?>(ticker),
      'exchange': serializer.toJson<String?>(exchange),
      'name': serializer.toJson<String>(name),
      'nameUs': serializer.toJson<String?>(nameUs),
      'currency': serializer.toJson<String>(currency),
      'country': serializer.toJson<String>(country),
      'sectorIndustryId': serializer.toJson<int?>(sectorIndustryId),
      'logo': serializer.toJson<String?>(logo),
      'status': serializer.toJson<String>(status),
      'lastPrice': serializer.toJson<double?>(lastPrice),
      'lastPriceAt': serializer.toJson<DateTime?>(lastPriceAt),
    };
  }

  Stock copyWith({
    int? id,
    Value<String?> ticker = const Value.absent(),
    Value<String?> exchange = const Value.absent(),
    String? name,
    Value<String?> nameUs = const Value.absent(),
    String? currency,
    String? country,
    Value<int?> sectorIndustryId = const Value.absent(),
    Value<String?> logo = const Value.absent(),
    String? status,
    Value<double?> lastPrice = const Value.absent(),
    Value<DateTime?> lastPriceAt = const Value.absent(),
  }) => Stock(
    id: id ?? this.id,
    ticker: ticker.present ? ticker.value : this.ticker,
    exchange: exchange.present ? exchange.value : this.exchange,
    name: name ?? this.name,
    nameUs: nameUs.present ? nameUs.value : this.nameUs,
    currency: currency ?? this.currency,
    country: country ?? this.country,
    sectorIndustryId: sectorIndustryId.present
        ? sectorIndustryId.value
        : this.sectorIndustryId,
    logo: logo.present ? logo.value : this.logo,
    status: status ?? this.status,
    lastPrice: lastPrice.present ? lastPrice.value : this.lastPrice,
    lastPriceAt: lastPriceAt.present ? lastPriceAt.value : this.lastPriceAt,
  );
  Stock copyWithCompanion(StocksCompanion data) {
    return Stock(
      id: data.id.present ? data.id.value : this.id,
      ticker: data.ticker.present ? data.ticker.value : this.ticker,
      exchange: data.exchange.present ? data.exchange.value : this.exchange,
      name: data.name.present ? data.name.value : this.name,
      nameUs: data.nameUs.present ? data.nameUs.value : this.nameUs,
      currency: data.currency.present ? data.currency.value : this.currency,
      country: data.country.present ? data.country.value : this.country,
      sectorIndustryId: data.sectorIndustryId.present
          ? data.sectorIndustryId.value
          : this.sectorIndustryId,
      logo: data.logo.present ? data.logo.value : this.logo,
      status: data.status.present ? data.status.value : this.status,
      lastPrice: data.lastPrice.present ? data.lastPrice.value : this.lastPrice,
      lastPriceAt: data.lastPriceAt.present
          ? data.lastPriceAt.value
          : this.lastPriceAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Stock(')
          ..write('id: $id, ')
          ..write('ticker: $ticker, ')
          ..write('exchange: $exchange, ')
          ..write('name: $name, ')
          ..write('nameUs: $nameUs, ')
          ..write('currency: $currency, ')
          ..write('country: $country, ')
          ..write('sectorIndustryId: $sectorIndustryId, ')
          ..write('logo: $logo, ')
          ..write('status: $status, ')
          ..write('lastPrice: $lastPrice, ')
          ..write('lastPriceAt: $lastPriceAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ticker,
    exchange,
    name,
    nameUs,
    currency,
    country,
    sectorIndustryId,
    logo,
    status,
    lastPrice,
    lastPriceAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Stock &&
          other.id == this.id &&
          other.ticker == this.ticker &&
          other.exchange == this.exchange &&
          other.name == this.name &&
          other.nameUs == this.nameUs &&
          other.currency == this.currency &&
          other.country == this.country &&
          other.sectorIndustryId == this.sectorIndustryId &&
          other.logo == this.logo &&
          other.status == this.status &&
          other.lastPrice == this.lastPrice &&
          other.lastPriceAt == this.lastPriceAt);
}

class StocksCompanion extends UpdateCompanion<Stock> {
  final Value<int> id;
  final Value<String?> ticker;
  final Value<String?> exchange;
  final Value<String> name;
  final Value<String?> nameUs;
  final Value<String> currency;
  final Value<String> country;
  final Value<int?> sectorIndustryId;
  final Value<String?> logo;
  final Value<String> status;
  final Value<double?> lastPrice;
  final Value<DateTime?> lastPriceAt;
  const StocksCompanion({
    this.id = const Value.absent(),
    this.ticker = const Value.absent(),
    this.exchange = const Value.absent(),
    this.name = const Value.absent(),
    this.nameUs = const Value.absent(),
    this.currency = const Value.absent(),
    this.country = const Value.absent(),
    this.sectorIndustryId = const Value.absent(),
    this.logo = const Value.absent(),
    this.status = const Value.absent(),
    this.lastPrice = const Value.absent(),
    this.lastPriceAt = const Value.absent(),
  });
  StocksCompanion.insert({
    this.id = const Value.absent(),
    this.ticker = const Value.absent(),
    this.exchange = const Value.absent(),
    required String name,
    this.nameUs = const Value.absent(),
    required String currency,
    required String country,
    this.sectorIndustryId = const Value.absent(),
    this.logo = const Value.absent(),
    this.status = const Value.absent(),
    this.lastPrice = const Value.absent(),
    this.lastPriceAt = const Value.absent(),
  }) : name = Value(name),
       currency = Value(currency),
       country = Value(country);
  static Insertable<Stock> custom({
    Expression<int>? id,
    Expression<String>? ticker,
    Expression<String>? exchange,
    Expression<String>? name,
    Expression<String>? nameUs,
    Expression<String>? currency,
    Expression<String>? country,
    Expression<int>? sectorIndustryId,
    Expression<String>? logo,
    Expression<String>? status,
    Expression<double>? lastPrice,
    Expression<DateTime>? lastPriceAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ticker != null) 'ticker': ticker,
      if (exchange != null) 'exchange': exchange,
      if (name != null) 'name': name,
      if (nameUs != null) 'name_us': nameUs,
      if (currency != null) 'currency': currency,
      if (country != null) 'country': country,
      if (sectorIndustryId != null) 'sector_industry_id': sectorIndustryId,
      if (logo != null) 'logo': logo,
      if (status != null) 'status': status,
      if (lastPrice != null) 'last_price': lastPrice,
      if (lastPriceAt != null) 'last_price_at': lastPriceAt,
    });
  }

  StocksCompanion copyWith({
    Value<int>? id,
    Value<String?>? ticker,
    Value<String?>? exchange,
    Value<String>? name,
    Value<String?>? nameUs,
    Value<String>? currency,
    Value<String>? country,
    Value<int?>? sectorIndustryId,
    Value<String?>? logo,
    Value<String>? status,
    Value<double?>? lastPrice,
    Value<DateTime?>? lastPriceAt,
  }) {
    return StocksCompanion(
      id: id ?? this.id,
      ticker: ticker ?? this.ticker,
      exchange: exchange ?? this.exchange,
      name: name ?? this.name,
      nameUs: nameUs ?? this.nameUs,
      currency: currency ?? this.currency,
      country: country ?? this.country,
      sectorIndustryId: sectorIndustryId ?? this.sectorIndustryId,
      logo: logo ?? this.logo,
      status: status ?? this.status,
      lastPrice: lastPrice ?? this.lastPrice,
      lastPriceAt: lastPriceAt ?? this.lastPriceAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ticker.present) {
      map['ticker'] = Variable<String>(ticker.value);
    }
    if (exchange.present) {
      map['exchange'] = Variable<String>(exchange.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameUs.present) {
      map['name_us'] = Variable<String>(nameUs.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (sectorIndustryId.present) {
      map['sector_industry_id'] = Variable<int>(sectorIndustryId.value);
    }
    if (logo.present) {
      map['logo'] = Variable<String>(logo.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastPrice.present) {
      map['last_price'] = Variable<double>(lastPrice.value);
    }
    if (lastPriceAt.present) {
      map['last_price_at'] = Variable<DateTime>(lastPriceAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StocksCompanion(')
          ..write('id: $id, ')
          ..write('ticker: $ticker, ')
          ..write('exchange: $exchange, ')
          ..write('name: $name, ')
          ..write('nameUs: $nameUs, ')
          ..write('currency: $currency, ')
          ..write('country: $country, ')
          ..write('sectorIndustryId: $sectorIndustryId, ')
          ..write('logo: $logo, ')
          ..write('status: $status, ')
          ..write('lastPrice: $lastPrice, ')
          ..write('lastPriceAt: $lastPriceAt')
          ..write(')'))
        .toString();
  }
}

class $FundsTable extends Funds with TableInfo<$FundsTable, Fund> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FundsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
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
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameUsMeta = const VerificationMeta('nameUs');
  @override
  late final GeneratedColumn<String> nameUs = GeneratedColumn<String>(
    'name_us',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _managementCompanyMeta = const VerificationMeta(
    'managementCompany',
  );
  @override
  late final GeneratedColumn<String> managementCompany =
      GeneratedColumn<String>(
        'management_company',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _foundationDateMeta = const VerificationMeta(
    'foundationDate',
  );
  @override
  late final GeneratedColumn<DateTime> foundationDate =
      GeneratedColumn<DateTime>(
        'foundation_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _tsumitateFlagMeta = const VerificationMeta(
    'tsumitateFlag',
  );
  @override
  late final GeneratedColumn<bool> tsumitateFlag = GeneratedColumn<bool>(
    'tsumitate_flag',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("tsumitate_flag" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isinCdMeta = const VerificationMeta('isinCd');
  @override
  late final GeneratedColumn<String> isinCd = GeneratedColumn<String>(
    'isin_cd',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    name,
    nameUs,
    managementCompany,
    foundationDate,
    tsumitateFlag,
    isinCd,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'funds';
  @override
  VerificationContext validateIntegrity(
    Insertable<Fund> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
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
    if (data.containsKey('name_us')) {
      context.handle(
        _nameUsMeta,
        nameUs.isAcceptableOrUnknown(data['name_us']!, _nameUsMeta),
      );
    }
    if (data.containsKey('management_company')) {
      context.handle(
        _managementCompanyMeta,
        managementCompany.isAcceptableOrUnknown(
          data['management_company']!,
          _managementCompanyMeta,
        ),
      );
    }
    if (data.containsKey('foundation_date')) {
      context.handle(
        _foundationDateMeta,
        foundationDate.isAcceptableOrUnknown(
          data['foundation_date']!,
          _foundationDateMeta,
        ),
      );
    }
    if (data.containsKey('tsumitate_flag')) {
      context.handle(
        _tsumitateFlagMeta,
        tsumitateFlag.isAcceptableOrUnknown(
          data['tsumitate_flag']!,
          _tsumitateFlagMeta,
        ),
      );
    }
    if (data.containsKey('isin_cd')) {
      context.handle(
        _isinCdMeta,
        isinCd.isAcceptableOrUnknown(data['isin_cd']!, _isinCdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Fund map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Fund(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameUs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_us'],
      ),
      managementCompany: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}management_company'],
      ),
      foundationDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}foundation_date'],
      ),
      tsumitateFlag: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}tsumitate_flag'],
      ),
      isinCd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isin_cd'],
      ),
    );
  }

  @override
  $FundsTable createAlias(String alias) {
    return $FundsTable(attachedDatabase, alias);
  }
}

class Fund extends DataClass implements Insertable<Fund> {
  final int id;
  final String code;
  final String name;
  final String? nameUs;
  final String? managementCompany;
  final DateTime? foundationDate;
  final bool? tsumitateFlag;
  final String? isinCd;
  const Fund({
    required this.id,
    required this.code,
    required this.name,
    this.nameUs,
    this.managementCompany,
    this.foundationDate,
    this.tsumitateFlag,
    this.isinCd,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || nameUs != null) {
      map['name_us'] = Variable<String>(nameUs);
    }
    if (!nullToAbsent || managementCompany != null) {
      map['management_company'] = Variable<String>(managementCompany);
    }
    if (!nullToAbsent || foundationDate != null) {
      map['foundation_date'] = Variable<DateTime>(foundationDate);
    }
    if (!nullToAbsent || tsumitateFlag != null) {
      map['tsumitate_flag'] = Variable<bool>(tsumitateFlag);
    }
    if (!nullToAbsent || isinCd != null) {
      map['isin_cd'] = Variable<String>(isinCd);
    }
    return map;
  }

  FundsCompanion toCompanion(bool nullToAbsent) {
    return FundsCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      nameUs: nameUs == null && nullToAbsent
          ? const Value.absent()
          : Value(nameUs),
      managementCompany: managementCompany == null && nullToAbsent
          ? const Value.absent()
          : Value(managementCompany),
      foundationDate: foundationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(foundationDate),
      tsumitateFlag: tsumitateFlag == null && nullToAbsent
          ? const Value.absent()
          : Value(tsumitateFlag),
      isinCd: isinCd == null && nullToAbsent
          ? const Value.absent()
          : Value(isinCd),
    );
  }

  factory Fund.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Fund(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      nameUs: serializer.fromJson<String?>(json['nameUs']),
      managementCompany: serializer.fromJson<String?>(
        json['managementCompany'],
      ),
      foundationDate: serializer.fromJson<DateTime?>(json['foundationDate']),
      tsumitateFlag: serializer.fromJson<bool?>(json['tsumitateFlag']),
      isinCd: serializer.fromJson<String?>(json['isinCd']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'nameUs': serializer.toJson<String?>(nameUs),
      'managementCompany': serializer.toJson<String?>(managementCompany),
      'foundationDate': serializer.toJson<DateTime?>(foundationDate),
      'tsumitateFlag': serializer.toJson<bool?>(tsumitateFlag),
      'isinCd': serializer.toJson<String?>(isinCd),
    };
  }

  Fund copyWith({
    int? id,
    String? code,
    String? name,
    Value<String?> nameUs = const Value.absent(),
    Value<String?> managementCompany = const Value.absent(),
    Value<DateTime?> foundationDate = const Value.absent(),
    Value<bool?> tsumitateFlag = const Value.absent(),
    Value<String?> isinCd = const Value.absent(),
  }) => Fund(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    nameUs: nameUs.present ? nameUs.value : this.nameUs,
    managementCompany: managementCompany.present
        ? managementCompany.value
        : this.managementCompany,
    foundationDate: foundationDate.present
        ? foundationDate.value
        : this.foundationDate,
    tsumitateFlag: tsumitateFlag.present
        ? tsumitateFlag.value
        : this.tsumitateFlag,
    isinCd: isinCd.present ? isinCd.value : this.isinCd,
  );
  Fund copyWithCompanion(FundsCompanion data) {
    return Fund(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      nameUs: data.nameUs.present ? data.nameUs.value : this.nameUs,
      managementCompany: data.managementCompany.present
          ? data.managementCompany.value
          : this.managementCompany,
      foundationDate: data.foundationDate.present
          ? data.foundationDate.value
          : this.foundationDate,
      tsumitateFlag: data.tsumitateFlag.present
          ? data.tsumitateFlag.value
          : this.tsumitateFlag,
      isinCd: data.isinCd.present ? data.isinCd.value : this.isinCd,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Fund(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('nameUs: $nameUs, ')
          ..write('managementCompany: $managementCompany, ')
          ..write('foundationDate: $foundationDate, ')
          ..write('tsumitateFlag: $tsumitateFlag, ')
          ..write('isinCd: $isinCd')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    name,
    nameUs,
    managementCompany,
    foundationDate,
    tsumitateFlag,
    isinCd,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Fund &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.nameUs == this.nameUs &&
          other.managementCompany == this.managementCompany &&
          other.foundationDate == this.foundationDate &&
          other.tsumitateFlag == this.tsumitateFlag &&
          other.isinCd == this.isinCd);
}

class FundsCompanion extends UpdateCompanion<Fund> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> name;
  final Value<String?> nameUs;
  final Value<String?> managementCompany;
  final Value<DateTime?> foundationDate;
  final Value<bool?> tsumitateFlag;
  final Value<String?> isinCd;
  final Value<int> rowid;
  const FundsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.nameUs = const Value.absent(),
    this.managementCompany = const Value.absent(),
    this.foundationDate = const Value.absent(),
    this.tsumitateFlag = const Value.absent(),
    this.isinCd = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FundsCompanion.insert({
    required int id,
    required String code,
    required String name,
    this.nameUs = const Value.absent(),
    this.managementCompany = const Value.absent(),
    this.foundationDate = const Value.absent(),
    this.tsumitateFlag = const Value.absent(),
    this.isinCd = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       name = Value(name);
  static Insertable<Fund> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? nameUs,
    Expression<String>? managementCompany,
    Expression<DateTime>? foundationDate,
    Expression<bool>? tsumitateFlag,
    Expression<String>? isinCd,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (nameUs != null) 'name_us': nameUs,
      if (managementCompany != null) 'management_company': managementCompany,
      if (foundationDate != null) 'foundation_date': foundationDate,
      if (tsumitateFlag != null) 'tsumitate_flag': tsumitateFlag,
      if (isinCd != null) 'isin_cd': isinCd,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FundsCompanion copyWith({
    Value<int>? id,
    Value<String>? code,
    Value<String>? name,
    Value<String?>? nameUs,
    Value<String?>? managementCompany,
    Value<DateTime?>? foundationDate,
    Value<bool?>? tsumitateFlag,
    Value<String?>? isinCd,
    Value<int>? rowid,
  }) {
    return FundsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      nameUs: nameUs ?? this.nameUs,
      managementCompany: managementCompany ?? this.managementCompany,
      foundationDate: foundationDate ?? this.foundationDate,
      tsumitateFlag: tsumitateFlag ?? this.tsumitateFlag,
      isinCd: isinCd ?? this.isinCd,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameUs.present) {
      map['name_us'] = Variable<String>(nameUs.value);
    }
    if (managementCompany.present) {
      map['management_company'] = Variable<String>(managementCompany.value);
    }
    if (foundationDate.present) {
      map['foundation_date'] = Variable<DateTime>(foundationDate.value);
    }
    if (tsumitateFlag.present) {
      map['tsumitate_flag'] = Variable<bool>(tsumitateFlag.value);
    }
    if (isinCd.present) {
      map['isin_cd'] = Variable<String>(isinCd.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FundsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('nameUs: $nameUs, ')
          ..write('managementCompany: $managementCompany, ')
          ..write('foundationDate: $foundationDate, ')
          ..write('tsumitateFlag: $tsumitateFlag, ')
          ..write('isinCd: $isinCd, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FundTransactionsTable extends FundTransactions
    with TableInfo<$FundTransactionsTable, FundTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FundTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fundIdMeta = const VerificationMeta('fundId');
  @override
  late final GeneratedColumn<int> fundId = GeneratedColumn<int>(
    'fund_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tradeTypeMeta = const VerificationMeta(
    'tradeType',
  );
  @override
  late final GeneratedColumn<String> tradeType = GeneratedColumn<String>(
    'trade_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountTypeMeta = const VerificationMeta(
    'accountType',
  );
  @override
  late final GeneratedColumn<String> accountType = GeneratedColumn<String>(
    'account_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feeAmountMeta = const VerificationMeta(
    'feeAmount',
  );
  @override
  late final GeneratedColumn<double> feeAmount = GeneratedColumn<double>(
    'fee_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feeCurrencyMeta = const VerificationMeta(
    'feeCurrency',
  );
  @override
  late final GeneratedColumn<String> feeCurrency = GeneratedColumn<String>(
    'fee_currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurringFrequencyTypeMeta =
      const VerificationMeta('recurringFrequencyType');
  @override
  late final GeneratedColumn<String> recurringFrequencyType =
      GeneratedColumn<String>(
        'recurring_frequency_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recurringFrequencyConfigMeta =
      const VerificationMeta('recurringFrequencyConfig');
  @override
  late final GeneratedColumn<String> recurringFrequencyConfig =
      GeneratedColumn<String>(
        'recurring_frequency_config',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recurringStartDateMeta =
      const VerificationMeta('recurringStartDate');
  @override
  late final GeneratedColumn<DateTime> recurringStartDate =
      GeneratedColumn<DateTime>(
        'recurring_start_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recurringEndDateMeta = const VerificationMeta(
    'recurringEndDate',
  );
  @override
  late final GeneratedColumn<DateTime> recurringEndDate =
      GeneratedColumn<DateTime>(
        'recurring_end_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recurringStatusMeta = const VerificationMeta(
    'recurringStatus',
  );
  @override
  late final GeneratedColumn<String> recurringStatus = GeneratedColumn<String>(
    'recurring_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    id,
    userId,
    accountId,
    fundId,
    tradeDate,
    action,
    tradeType,
    accountType,
    amount,
    quantity,
    price,
    feeAmount,
    feeCurrency,
    recurringFrequencyType,
    recurringFrequencyConfig,
    recurringStartDate,
    recurringEndDate,
    recurringStatus,
    remark,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fund_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FundTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('fund_id')) {
      context.handle(
        _fundIdMeta,
        fundId.isAcceptableOrUnknown(data['fund_id']!, _fundIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fundIdMeta);
    }
    if (data.containsKey('trade_date')) {
      context.handle(
        _tradeDateMeta,
        tradeDate.isAcceptableOrUnknown(data['trade_date']!, _tradeDateMeta),
      );
    } else if (isInserting) {
      context.missing(_tradeDateMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('trade_type')) {
      context.handle(
        _tradeTypeMeta,
        tradeType.isAcceptableOrUnknown(data['trade_type']!, _tradeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_tradeTypeMeta);
    }
    if (data.containsKey('account_type')) {
      context.handle(
        _accountTypeMeta,
        accountType.isAcceptableOrUnknown(
          data['account_type']!,
          _accountTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountTypeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('fee_amount')) {
      context.handle(
        _feeAmountMeta,
        feeAmount.isAcceptableOrUnknown(data['fee_amount']!, _feeAmountMeta),
      );
    }
    if (data.containsKey('fee_currency')) {
      context.handle(
        _feeCurrencyMeta,
        feeCurrency.isAcceptableOrUnknown(
          data['fee_currency']!,
          _feeCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('recurring_frequency_type')) {
      context.handle(
        _recurringFrequencyTypeMeta,
        recurringFrequencyType.isAcceptableOrUnknown(
          data['recurring_frequency_type']!,
          _recurringFrequencyTypeMeta,
        ),
      );
    }
    if (data.containsKey('recurring_frequency_config')) {
      context.handle(
        _recurringFrequencyConfigMeta,
        recurringFrequencyConfig.isAcceptableOrUnknown(
          data['recurring_frequency_config']!,
          _recurringFrequencyConfigMeta,
        ),
      );
    }
    if (data.containsKey('recurring_start_date')) {
      context.handle(
        _recurringStartDateMeta,
        recurringStartDate.isAcceptableOrUnknown(
          data['recurring_start_date']!,
          _recurringStartDateMeta,
        ),
      );
    }
    if (data.containsKey('recurring_end_date')) {
      context.handle(
        _recurringEndDateMeta,
        recurringEndDate.isAcceptableOrUnknown(
          data['recurring_end_date']!,
          _recurringEndDateMeta,
        ),
      );
    }
    if (data.containsKey('recurring_status')) {
      context.handle(
        _recurringStatusMeta,
        recurringStatus.isAcceptableOrUnknown(
          data['recurring_status']!,
          _recurringStatusMeta,
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
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  FundTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FundTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      fundId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fund_id'],
      )!,
      tradeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}trade_date'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      tradeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trade_type'],
      )!,
      accountType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      ),
      feeAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fee_amount'],
      ),
      feeCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fee_currency'],
      ),
      recurringFrequencyType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_frequency_type'],
      ),
      recurringFrequencyConfig: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_frequency_config'],
      ),
      recurringStartDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recurring_start_date'],
      ),
      recurringEndDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recurring_end_date'],
      ),
      recurringStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_status'],
      ),
      remark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remark'],
      ),
    );
  }

  @override
  $FundTransactionsTable createAlias(String alias) {
    return $FundTransactionsTable(attachedDatabase, alias);
  }
}

class FundTransaction extends DataClass implements Insertable<FundTransaction> {
  final int id;
  final String userId;
  final int accountId;
  final int fundId;
  final DateTime tradeDate;
  final String action;
  final String tradeType;
  final String accountType;
  final double? amount;
  final double? quantity;
  final double? price;
  final double? feeAmount;
  final String? feeCurrency;
  final String? recurringFrequencyType;
  final String? recurringFrequencyConfig;
  final DateTime? recurringStartDate;
  final DateTime? recurringEndDate;
  final String? recurringStatus;
  final String? remark;
  const FundTransaction({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.fundId,
    required this.tradeDate,
    required this.action,
    required this.tradeType,
    required this.accountType,
    this.amount,
    this.quantity,
    this.price,
    this.feeAmount,
    this.feeCurrency,
    this.recurringFrequencyType,
    this.recurringFrequencyConfig,
    this.recurringStartDate,
    this.recurringEndDate,
    this.recurringStatus,
    this.remark,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['account_id'] = Variable<int>(accountId);
    map['fund_id'] = Variable<int>(fundId);
    map['trade_date'] = Variable<DateTime>(tradeDate);
    map['action'] = Variable<String>(action);
    map['trade_type'] = Variable<String>(tradeType);
    map['account_type'] = Variable<String>(accountType);
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<double>(amount);
    }
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<double>(quantity);
    }
    if (!nullToAbsent || price != null) {
      map['price'] = Variable<double>(price);
    }
    if (!nullToAbsent || feeAmount != null) {
      map['fee_amount'] = Variable<double>(feeAmount);
    }
    if (!nullToAbsent || feeCurrency != null) {
      map['fee_currency'] = Variable<String>(feeCurrency);
    }
    if (!nullToAbsent || recurringFrequencyType != null) {
      map['recurring_frequency_type'] = Variable<String>(
        recurringFrequencyType,
      );
    }
    if (!nullToAbsent || recurringFrequencyConfig != null) {
      map['recurring_frequency_config'] = Variable<String>(
        recurringFrequencyConfig,
      );
    }
    if (!nullToAbsent || recurringStartDate != null) {
      map['recurring_start_date'] = Variable<DateTime>(recurringStartDate);
    }
    if (!nullToAbsent || recurringEndDate != null) {
      map['recurring_end_date'] = Variable<DateTime>(recurringEndDate);
    }
    if (!nullToAbsent || recurringStatus != null) {
      map['recurring_status'] = Variable<String>(recurringStatus);
    }
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    return map;
  }

  FundTransactionsCompanion toCompanion(bool nullToAbsent) {
    return FundTransactionsCompanion(
      id: Value(id),
      userId: Value(userId),
      accountId: Value(accountId),
      fundId: Value(fundId),
      tradeDate: Value(tradeDate),
      action: Value(action),
      tradeType: Value(tradeType),
      accountType: Value(accountType),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      price: price == null && nullToAbsent
          ? const Value.absent()
          : Value(price),
      feeAmount: feeAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(feeAmount),
      feeCurrency: feeCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(feeCurrency),
      recurringFrequencyType: recurringFrequencyType == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringFrequencyType),
      recurringFrequencyConfig: recurringFrequencyConfig == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringFrequencyConfig),
      recurringStartDate: recurringStartDate == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringStartDate),
      recurringEndDate: recurringEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringEndDate),
      recurringStatus: recurringStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringStatus),
      remark: remark == null && nullToAbsent
          ? const Value.absent()
          : Value(remark),
    );
  }

  factory FundTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FundTransaction(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      accountId: serializer.fromJson<int>(json['accountId']),
      fundId: serializer.fromJson<int>(json['fundId']),
      tradeDate: serializer.fromJson<DateTime>(json['tradeDate']),
      action: serializer.fromJson<String>(json['action']),
      tradeType: serializer.fromJson<String>(json['tradeType']),
      accountType: serializer.fromJson<String>(json['accountType']),
      amount: serializer.fromJson<double?>(json['amount']),
      quantity: serializer.fromJson<double?>(json['quantity']),
      price: serializer.fromJson<double?>(json['price']),
      feeAmount: serializer.fromJson<double?>(json['feeAmount']),
      feeCurrency: serializer.fromJson<String?>(json['feeCurrency']),
      recurringFrequencyType: serializer.fromJson<String?>(
        json['recurringFrequencyType'],
      ),
      recurringFrequencyConfig: serializer.fromJson<String?>(
        json['recurringFrequencyConfig'],
      ),
      recurringStartDate: serializer.fromJson<DateTime?>(
        json['recurringStartDate'],
      ),
      recurringEndDate: serializer.fromJson<DateTime?>(
        json['recurringEndDate'],
      ),
      recurringStatus: serializer.fromJson<String?>(json['recurringStatus']),
      remark: serializer.fromJson<String?>(json['remark']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'accountId': serializer.toJson<int>(accountId),
      'fundId': serializer.toJson<int>(fundId),
      'tradeDate': serializer.toJson<DateTime>(tradeDate),
      'action': serializer.toJson<String>(action),
      'tradeType': serializer.toJson<String>(tradeType),
      'accountType': serializer.toJson<String>(accountType),
      'amount': serializer.toJson<double?>(amount),
      'quantity': serializer.toJson<double?>(quantity),
      'price': serializer.toJson<double?>(price),
      'feeAmount': serializer.toJson<double?>(feeAmount),
      'feeCurrency': serializer.toJson<String?>(feeCurrency),
      'recurringFrequencyType': serializer.toJson<String?>(
        recurringFrequencyType,
      ),
      'recurringFrequencyConfig': serializer.toJson<String?>(
        recurringFrequencyConfig,
      ),
      'recurringStartDate': serializer.toJson<DateTime?>(recurringStartDate),
      'recurringEndDate': serializer.toJson<DateTime?>(recurringEndDate),
      'recurringStatus': serializer.toJson<String?>(recurringStatus),
      'remark': serializer.toJson<String?>(remark),
    };
  }

  FundTransaction copyWith({
    int? id,
    String? userId,
    int? accountId,
    int? fundId,
    DateTime? tradeDate,
    String? action,
    String? tradeType,
    String? accountType,
    Value<double?> amount = const Value.absent(),
    Value<double?> quantity = const Value.absent(),
    Value<double?> price = const Value.absent(),
    Value<double?> feeAmount = const Value.absent(),
    Value<String?> feeCurrency = const Value.absent(),
    Value<String?> recurringFrequencyType = const Value.absent(),
    Value<String?> recurringFrequencyConfig = const Value.absent(),
    Value<DateTime?> recurringStartDate = const Value.absent(),
    Value<DateTime?> recurringEndDate = const Value.absent(),
    Value<String?> recurringStatus = const Value.absent(),
    Value<String?> remark = const Value.absent(),
  }) => FundTransaction(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    accountId: accountId ?? this.accountId,
    fundId: fundId ?? this.fundId,
    tradeDate: tradeDate ?? this.tradeDate,
    action: action ?? this.action,
    tradeType: tradeType ?? this.tradeType,
    accountType: accountType ?? this.accountType,
    amount: amount.present ? amount.value : this.amount,
    quantity: quantity.present ? quantity.value : this.quantity,
    price: price.present ? price.value : this.price,
    feeAmount: feeAmount.present ? feeAmount.value : this.feeAmount,
    feeCurrency: feeCurrency.present ? feeCurrency.value : this.feeCurrency,
    recurringFrequencyType: recurringFrequencyType.present
        ? recurringFrequencyType.value
        : this.recurringFrequencyType,
    recurringFrequencyConfig: recurringFrequencyConfig.present
        ? recurringFrequencyConfig.value
        : this.recurringFrequencyConfig,
    recurringStartDate: recurringStartDate.present
        ? recurringStartDate.value
        : this.recurringStartDate,
    recurringEndDate: recurringEndDate.present
        ? recurringEndDate.value
        : this.recurringEndDate,
    recurringStatus: recurringStatus.present
        ? recurringStatus.value
        : this.recurringStatus,
    remark: remark.present ? remark.value : this.remark,
  );
  FundTransaction copyWithCompanion(FundTransactionsCompanion data) {
    return FundTransaction(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      fundId: data.fundId.present ? data.fundId.value : this.fundId,
      tradeDate: data.tradeDate.present ? data.tradeDate.value : this.tradeDate,
      action: data.action.present ? data.action.value : this.action,
      tradeType: data.tradeType.present ? data.tradeType.value : this.tradeType,
      accountType: data.accountType.present
          ? data.accountType.value
          : this.accountType,
      amount: data.amount.present ? data.amount.value : this.amount,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      price: data.price.present ? data.price.value : this.price,
      feeAmount: data.feeAmount.present ? data.feeAmount.value : this.feeAmount,
      feeCurrency: data.feeCurrency.present
          ? data.feeCurrency.value
          : this.feeCurrency,
      recurringFrequencyType: data.recurringFrequencyType.present
          ? data.recurringFrequencyType.value
          : this.recurringFrequencyType,
      recurringFrequencyConfig: data.recurringFrequencyConfig.present
          ? data.recurringFrequencyConfig.value
          : this.recurringFrequencyConfig,
      recurringStartDate: data.recurringStartDate.present
          ? data.recurringStartDate.value
          : this.recurringStartDate,
      recurringEndDate: data.recurringEndDate.present
          ? data.recurringEndDate.value
          : this.recurringEndDate,
      recurringStatus: data.recurringStatus.present
          ? data.recurringStatus.value
          : this.recurringStatus,
      remark: data.remark.present ? data.remark.value : this.remark,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FundTransaction(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('accountId: $accountId, ')
          ..write('fundId: $fundId, ')
          ..write('tradeDate: $tradeDate, ')
          ..write('action: $action, ')
          ..write('tradeType: $tradeType, ')
          ..write('accountType: $accountType, ')
          ..write('amount: $amount, ')
          ..write('quantity: $quantity, ')
          ..write('price: $price, ')
          ..write('feeAmount: $feeAmount, ')
          ..write('feeCurrency: $feeCurrency, ')
          ..write('recurringFrequencyType: $recurringFrequencyType, ')
          ..write('recurringFrequencyConfig: $recurringFrequencyConfig, ')
          ..write('recurringStartDate: $recurringStartDate, ')
          ..write('recurringEndDate: $recurringEndDate, ')
          ..write('recurringStatus: $recurringStatus, ')
          ..write('remark: $remark')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    accountId,
    fundId,
    tradeDate,
    action,
    tradeType,
    accountType,
    amount,
    quantity,
    price,
    feeAmount,
    feeCurrency,
    recurringFrequencyType,
    recurringFrequencyConfig,
    recurringStartDate,
    recurringEndDate,
    recurringStatus,
    remark,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FundTransaction &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.accountId == this.accountId &&
          other.fundId == this.fundId &&
          other.tradeDate == this.tradeDate &&
          other.action == this.action &&
          other.tradeType == this.tradeType &&
          other.accountType == this.accountType &&
          other.amount == this.amount &&
          other.quantity == this.quantity &&
          other.price == this.price &&
          other.feeAmount == this.feeAmount &&
          other.feeCurrency == this.feeCurrency &&
          other.recurringFrequencyType == this.recurringFrequencyType &&
          other.recurringFrequencyConfig == this.recurringFrequencyConfig &&
          other.recurringStartDate == this.recurringStartDate &&
          other.recurringEndDate == this.recurringEndDate &&
          other.recurringStatus == this.recurringStatus &&
          other.remark == this.remark);
}

class FundTransactionsCompanion extends UpdateCompanion<FundTransaction> {
  final Value<int> id;
  final Value<String> userId;
  final Value<int> accountId;
  final Value<int> fundId;
  final Value<DateTime> tradeDate;
  final Value<String> action;
  final Value<String> tradeType;
  final Value<String> accountType;
  final Value<double?> amount;
  final Value<double?> quantity;
  final Value<double?> price;
  final Value<double?> feeAmount;
  final Value<String?> feeCurrency;
  final Value<String?> recurringFrequencyType;
  final Value<String?> recurringFrequencyConfig;
  final Value<DateTime?> recurringStartDate;
  final Value<DateTime?> recurringEndDate;
  final Value<String?> recurringStatus;
  final Value<String?> remark;
  final Value<int> rowid;
  const FundTransactionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.fundId = const Value.absent(),
    this.tradeDate = const Value.absent(),
    this.action = const Value.absent(),
    this.tradeType = const Value.absent(),
    this.accountType = const Value.absent(),
    this.amount = const Value.absent(),
    this.quantity = const Value.absent(),
    this.price = const Value.absent(),
    this.feeAmount = const Value.absent(),
    this.feeCurrency = const Value.absent(),
    this.recurringFrequencyType = const Value.absent(),
    this.recurringFrequencyConfig = const Value.absent(),
    this.recurringStartDate = const Value.absent(),
    this.recurringEndDate = const Value.absent(),
    this.recurringStatus = const Value.absent(),
    this.remark = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FundTransactionsCompanion.insert({
    required int id,
    required String userId,
    required int accountId,
    required int fundId,
    required DateTime tradeDate,
    required String action,
    required String tradeType,
    required String accountType,
    this.amount = const Value.absent(),
    this.quantity = const Value.absent(),
    this.price = const Value.absent(),
    this.feeAmount = const Value.absent(),
    this.feeCurrency = const Value.absent(),
    this.recurringFrequencyType = const Value.absent(),
    this.recurringFrequencyConfig = const Value.absent(),
    this.recurringStartDate = const Value.absent(),
    this.recurringEndDate = const Value.absent(),
    this.recurringStatus = const Value.absent(),
    this.remark = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       accountId = Value(accountId),
       fundId = Value(fundId),
       tradeDate = Value(tradeDate),
       action = Value(action),
       tradeType = Value(tradeType),
       accountType = Value(accountType);
  static Insertable<FundTransaction> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<int>? accountId,
    Expression<int>? fundId,
    Expression<DateTime>? tradeDate,
    Expression<String>? action,
    Expression<String>? tradeType,
    Expression<String>? accountType,
    Expression<double>? amount,
    Expression<double>? quantity,
    Expression<double>? price,
    Expression<double>? feeAmount,
    Expression<String>? feeCurrency,
    Expression<String>? recurringFrequencyType,
    Expression<String>? recurringFrequencyConfig,
    Expression<DateTime>? recurringStartDate,
    Expression<DateTime>? recurringEndDate,
    Expression<String>? recurringStatus,
    Expression<String>? remark,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (accountId != null) 'account_id': accountId,
      if (fundId != null) 'fund_id': fundId,
      if (tradeDate != null) 'trade_date': tradeDate,
      if (action != null) 'action': action,
      if (tradeType != null) 'trade_type': tradeType,
      if (accountType != null) 'account_type': accountType,
      if (amount != null) 'amount': amount,
      if (quantity != null) 'quantity': quantity,
      if (price != null) 'price': price,
      if (feeAmount != null) 'fee_amount': feeAmount,
      if (feeCurrency != null) 'fee_currency': feeCurrency,
      if (recurringFrequencyType != null)
        'recurring_frequency_type': recurringFrequencyType,
      if (recurringFrequencyConfig != null)
        'recurring_frequency_config': recurringFrequencyConfig,
      if (recurringStartDate != null)
        'recurring_start_date': recurringStartDate,
      if (recurringEndDate != null) 'recurring_end_date': recurringEndDate,
      if (recurringStatus != null) 'recurring_status': recurringStatus,
      if (remark != null) 'remark': remark,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FundTransactionsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<int>? accountId,
    Value<int>? fundId,
    Value<DateTime>? tradeDate,
    Value<String>? action,
    Value<String>? tradeType,
    Value<String>? accountType,
    Value<double?>? amount,
    Value<double?>? quantity,
    Value<double?>? price,
    Value<double?>? feeAmount,
    Value<String?>? feeCurrency,
    Value<String?>? recurringFrequencyType,
    Value<String?>? recurringFrequencyConfig,
    Value<DateTime?>? recurringStartDate,
    Value<DateTime?>? recurringEndDate,
    Value<String?>? recurringStatus,
    Value<String?>? remark,
    Value<int>? rowid,
  }) {
    return FundTransactionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      fundId: fundId ?? this.fundId,
      tradeDate: tradeDate ?? this.tradeDate,
      action: action ?? this.action,
      tradeType: tradeType ?? this.tradeType,
      accountType: accountType ?? this.accountType,
      amount: amount ?? this.amount,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      feeAmount: feeAmount ?? this.feeAmount,
      feeCurrency: feeCurrency ?? this.feeCurrency,
      recurringFrequencyType:
          recurringFrequencyType ?? this.recurringFrequencyType,
      recurringFrequencyConfig:
          recurringFrequencyConfig ?? this.recurringFrequencyConfig,
      recurringStartDate: recurringStartDate ?? this.recurringStartDate,
      recurringEndDate: recurringEndDate ?? this.recurringEndDate,
      recurringStatus: recurringStatus ?? this.recurringStatus,
      remark: remark ?? this.remark,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (fundId.present) {
      map['fund_id'] = Variable<int>(fundId.value);
    }
    if (tradeDate.present) {
      map['trade_date'] = Variable<DateTime>(tradeDate.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (tradeType.present) {
      map['trade_type'] = Variable<String>(tradeType.value);
    }
    if (accountType.present) {
      map['account_type'] = Variable<String>(accountType.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (feeAmount.present) {
      map['fee_amount'] = Variable<double>(feeAmount.value);
    }
    if (feeCurrency.present) {
      map['fee_currency'] = Variable<String>(feeCurrency.value);
    }
    if (recurringFrequencyType.present) {
      map['recurring_frequency_type'] = Variable<String>(
        recurringFrequencyType.value,
      );
    }
    if (recurringFrequencyConfig.present) {
      map['recurring_frequency_config'] = Variable<String>(
        recurringFrequencyConfig.value,
      );
    }
    if (recurringStartDate.present) {
      map['recurring_start_date'] = Variable<DateTime>(
        recurringStartDate.value,
      );
    }
    if (recurringEndDate.present) {
      map['recurring_end_date'] = Variable<DateTime>(recurringEndDate.value);
    }
    if (recurringStatus.present) {
      map['recurring_status'] = Variable<String>(recurringStatus.value);
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
    return (StringBuffer('FundTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('accountId: $accountId, ')
          ..write('fundId: $fundId, ')
          ..write('tradeDate: $tradeDate, ')
          ..write('action: $action, ')
          ..write('tradeType: $tradeType, ')
          ..write('accountType: $accountType, ')
          ..write('amount: $amount, ')
          ..write('quantity: $quantity, ')
          ..write('price: $price, ')
          ..write('feeAmount: $feeAmount, ')
          ..write('feeCurrency: $feeCurrency, ')
          ..write('recurringFrequencyType: $recurringFrequencyType, ')
          ..write('recurringFrequencyConfig: $recurringFrequencyConfig, ')
          ..write('recurringStartDate: $recurringStartDate, ')
          ..write('recurringEndDate: $recurringEndDate, ')
          ..write('recurringStatus: $recurringStatus, ')
          ..write('remark: $remark, ')
          ..write('rowid: $rowid')
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
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _sellIdMeta = const VerificationMeta('sellId');
  @override
  late final GeneratedColumn<int> sellId = GeneratedColumn<int>(
    'sell_id',
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
  List<GeneratedColumn> get $columns => [id, buyId, sellId, quantity];
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
    if (data.containsKey('buy_id')) {
      context.handle(
        _buyIdMeta,
        buyId.isAcceptableOrUnknown(data['buy_id']!, _buyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_buyIdMeta);
    }
    if (data.containsKey('sell_id')) {
      context.handle(
        _sellIdMeta,
        sellId.isAcceptableOrUnknown(data['sell_id']!, _sellIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sellIdMeta);
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
      buyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}buy_id'],
      )!,
      sellId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sell_id'],
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
  final int buyId;
  final int sellId;
  final double quantity;
  const TradeSellMapping({
    required this.id,
    required this.buyId,
    required this.sellId,
    required this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['buy_id'] = Variable<int>(buyId);
    map['sell_id'] = Variable<int>(sellId);
    map['quantity'] = Variable<double>(quantity);
    return map;
  }

  TradeSellMappingsCompanion toCompanion(bool nullToAbsent) {
    return TradeSellMappingsCompanion(
      id: Value(id),
      buyId: Value(buyId),
      sellId: Value(sellId),
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
      buyId: serializer.fromJson<int>(json['buyId']),
      sellId: serializer.fromJson<int>(json['sellId']),
      quantity: serializer.fromJson<double>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'buyId': serializer.toJson<int>(buyId),
      'sellId': serializer.toJson<int>(sellId),
      'quantity': serializer.toJson<double>(quantity),
    };
  }

  TradeSellMapping copyWith({
    int? id,
    int? buyId,
    int? sellId,
    double? quantity,
  }) => TradeSellMapping(
    id: id ?? this.id,
    buyId: buyId ?? this.buyId,
    sellId: sellId ?? this.sellId,
    quantity: quantity ?? this.quantity,
  );
  TradeSellMapping copyWithCompanion(TradeSellMappingsCompanion data) {
    return TradeSellMapping(
      id: data.id.present ? data.id.value : this.id,
      buyId: data.buyId.present ? data.buyId.value : this.buyId,
      sellId: data.sellId.present ? data.sellId.value : this.sellId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TradeSellMapping(')
          ..write('id: $id, ')
          ..write('buyId: $buyId, ')
          ..write('sellId: $sellId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, buyId, sellId, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TradeSellMapping &&
          other.id == this.id &&
          other.buyId == this.buyId &&
          other.sellId == this.sellId &&
          other.quantity == this.quantity);
}

class TradeSellMappingsCompanion extends UpdateCompanion<TradeSellMapping> {
  final Value<int> id;
  final Value<int> buyId;
  final Value<int> sellId;
  final Value<double> quantity;
  const TradeSellMappingsCompanion({
    this.id = const Value.absent(),
    this.buyId = const Value.absent(),
    this.sellId = const Value.absent(),
    this.quantity = const Value.absent(),
  });
  TradeSellMappingsCompanion.insert({
    this.id = const Value.absent(),
    required int buyId,
    required int sellId,
    required double quantity,
  }) : buyId = Value(buyId),
       sellId = Value(sellId),
       quantity = Value(quantity);
  static Insertable<TradeSellMapping> custom({
    Expression<int>? id,
    Expression<int>? buyId,
    Expression<int>? sellId,
    Expression<double>? quantity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (buyId != null) 'buy_id': buyId,
      if (sellId != null) 'sell_id': sellId,
      if (quantity != null) 'quantity': quantity,
    });
  }

  TradeSellMappingsCompanion copyWith({
    Value<int>? id,
    Value<int>? buyId,
    Value<int>? sellId,
    Value<double>? quantity,
  }) {
    return TradeSellMappingsCompanion(
      id: id ?? this.id,
      buyId: buyId ?? this.buyId,
      sellId: sellId ?? this.sellId,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (buyId.present) {
      map['buy_id'] = Variable<int>(buyId.value);
    }
    if (sellId.present) {
      map['sell_id'] = Variable<int>(sellId.value);
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
          ..write('buyId: $buyId, ')
          ..write('sellId: $sellId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }
}

class $AccountsTable extends Accounts with TableInfo<$AccountsTable, Account> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, name, type, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Account> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Account map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Account(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class Account extends DataClass implements Insertable<Account> {
  final int id;
  final String userId;
  final String name;
  final String? type;
  final DateTime? createdAt;
  const Account({
    required this.id,
    required this.userId,
    required this.name,
    this.type,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory Account.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Account(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String?>(json['type']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String?>(type),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  Account copyWith({
    int? id,
    String? userId,
    String? name,
    Value<String?> type = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
  }) => Account(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    type: type.present ? type.value : this.type,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  Account copyWithCompanion(AccountsCompanion data) {
    return Account(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Account(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, name, type, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Account &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.type == this.type &&
          other.createdAt == this.createdAt);
}

class AccountsCompanion extends UpdateCompanion<Account> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String?> type;
  final Value<DateTime?> createdAt;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String name,
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : userId = Value(userId),
       name = Value(name);
  static Insertable<Account> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String?>? type,
    Value<DateTime?>? createdAt,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $StockPricesTable extends StockPrices
    with TableInfo<$StockPricesTable, StockPrice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockPricesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _stockIdMeta = const VerificationMeta(
    'stockId',
  );
  @override
  late final GeneratedColumn<int> stockId = GeneratedColumn<int>(
    'stock_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceAtMeta = const VerificationMeta(
    'priceAt',
  );
  @override
  late final GeneratedColumn<DateTime> priceAt = GeneratedColumn<DateTime>(
    'price_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    stockId,
    price,
    priceAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_prices';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockPrice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('stock_id')) {
      context.handle(
        _stockIdMeta,
        stockId.isAcceptableOrUnknown(data['stock_id']!, _stockIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stockIdMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('price_at')) {
      context.handle(
        _priceAtMeta,
        priceAt.isAcceptableOrUnknown(data['price_at']!, _priceAtMeta),
      );
    } else if (isInserting) {
      context.missing(_priceAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {stockId, priceAt},
  ];
  @override
  StockPrice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockPrice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      stockId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock_id'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      priceAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}price_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $StockPricesTable createAlias(String alias) {
    return $StockPricesTable(attachedDatabase, alias);
  }
}

class StockPrice extends DataClass implements Insertable<StockPrice> {
  final int id;
  final int stockId;
  final double price;
  final DateTime priceAt;
  final DateTime? createdAt;
  const StockPrice({
    required this.id,
    required this.stockId,
    required this.price,
    required this.priceAt,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['stock_id'] = Variable<int>(stockId);
    map['price'] = Variable<double>(price);
    map['price_at'] = Variable<DateTime>(priceAt);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  StockPricesCompanion toCompanion(bool nullToAbsent) {
    return StockPricesCompanion(
      id: Value(id),
      stockId: Value(stockId),
      price: Value(price),
      priceAt: Value(priceAt),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory StockPrice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockPrice(
      id: serializer.fromJson<int>(json['id']),
      stockId: serializer.fromJson<int>(json['stockId']),
      price: serializer.fromJson<double>(json['price']),
      priceAt: serializer.fromJson<DateTime>(json['priceAt']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'stockId': serializer.toJson<int>(stockId),
      'price': serializer.toJson<double>(price),
      'priceAt': serializer.toJson<DateTime>(priceAt),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  StockPrice copyWith({
    int? id,
    int? stockId,
    double? price,
    DateTime? priceAt,
    Value<DateTime?> createdAt = const Value.absent(),
  }) => StockPrice(
    id: id ?? this.id,
    stockId: stockId ?? this.stockId,
    price: price ?? this.price,
    priceAt: priceAt ?? this.priceAt,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  StockPrice copyWithCompanion(StockPricesCompanion data) {
    return StockPrice(
      id: data.id.present ? data.id.value : this.id,
      stockId: data.stockId.present ? data.stockId.value : this.stockId,
      price: data.price.present ? data.price.value : this.price,
      priceAt: data.priceAt.present ? data.priceAt.value : this.priceAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockPrice(')
          ..write('id: $id, ')
          ..write('stockId: $stockId, ')
          ..write('price: $price, ')
          ..write('priceAt: $priceAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, stockId, price, priceAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockPrice &&
          other.id == this.id &&
          other.stockId == this.stockId &&
          other.price == this.price &&
          other.priceAt == this.priceAt &&
          other.createdAt == this.createdAt);
}

class StockPricesCompanion extends UpdateCompanion<StockPrice> {
  final Value<int> id;
  final Value<int> stockId;
  final Value<double> price;
  final Value<DateTime> priceAt;
  final Value<DateTime?> createdAt;
  const StockPricesCompanion({
    this.id = const Value.absent(),
    this.stockId = const Value.absent(),
    this.price = const Value.absent(),
    this.priceAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  StockPricesCompanion.insert({
    this.id = const Value.absent(),
    required int stockId,
    required double price,
    required DateTime priceAt,
    this.createdAt = const Value.absent(),
  }) : stockId = Value(stockId),
       price = Value(price),
       priceAt = Value(priceAt);
  static Insertable<StockPrice> custom({
    Expression<int>? id,
    Expression<int>? stockId,
    Expression<double>? price,
    Expression<DateTime>? priceAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stockId != null) 'stock_id': stockId,
      if (price != null) 'price': price,
      if (priceAt != null) 'price_at': priceAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  StockPricesCompanion copyWith({
    Value<int>? id,
    Value<int>? stockId,
    Value<double>? price,
    Value<DateTime>? priceAt,
    Value<DateTime?>? createdAt,
  }) {
    return StockPricesCompanion(
      id: id ?? this.id,
      stockId: stockId ?? this.stockId,
      price: price ?? this.price,
      priceAt: priceAt ?? this.priceAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (stockId.present) {
      map['stock_id'] = Variable<int>(stockId.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (priceAt.present) {
      map['price_at'] = Variable<DateTime>(priceAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockPricesCompanion(')
          ..write('id: $id, ')
          ..write('stockId: $stockId, ')
          ..write('price: $price, ')
          ..write('priceAt: $priceAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FxRatesTable extends FxRates with TableInfo<$FxRatesTable, FxRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FxRatesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _fxPairIdMeta = const VerificationMeta(
    'fxPairId',
  );
  @override
  late final GeneratedColumn<int> fxPairId = GeneratedColumn<int>(
    'fx_pair_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateDateMeta = const VerificationMeta(
    'rateDate',
  );
  @override
  late final GeneratedColumn<DateTime> rateDate = GeneratedColumn<DateTime>(
    'rate_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, fxPairId, rateDate, rate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fx_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<FxRate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fx_pair_id')) {
      context.handle(
        _fxPairIdMeta,
        fxPairId.isAcceptableOrUnknown(data['fx_pair_id']!, _fxPairIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fxPairIdMeta);
    }
    if (data.containsKey('rate_date')) {
      context.handle(
        _rateDateMeta,
        rateDate.isAcceptableOrUnknown(data['rate_date']!, _rateDateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateDateMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {fxPairId, rateDate},
  ];
  @override
  FxRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FxRate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fxPairId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fx_pair_id'],
      )!,
      rateDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}rate_date'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate'],
      )!,
    );
  }

  @override
  $FxRatesTable createAlias(String alias) {
    return $FxRatesTable(attachedDatabase, alias);
  }
}

class FxRate extends DataClass implements Insertable<FxRate> {
  final int id;
  final int fxPairId;
  final DateTime rateDate;
  final double rate;
  const FxRate({
    required this.id,
    required this.fxPairId,
    required this.rateDate,
    required this.rate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fx_pair_id'] = Variable<int>(fxPairId);
    map['rate_date'] = Variable<DateTime>(rateDate);
    map['rate'] = Variable<double>(rate);
    return map;
  }

  FxRatesCompanion toCompanion(bool nullToAbsent) {
    return FxRatesCompanion(
      id: Value(id),
      fxPairId: Value(fxPairId),
      rateDate: Value(rateDate),
      rate: Value(rate),
    );
  }

  factory FxRate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FxRate(
      id: serializer.fromJson<int>(json['id']),
      fxPairId: serializer.fromJson<int>(json['fxPairId']),
      rateDate: serializer.fromJson<DateTime>(json['rateDate']),
      rate: serializer.fromJson<double>(json['rate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fxPairId': serializer.toJson<int>(fxPairId),
      'rateDate': serializer.toJson<DateTime>(rateDate),
      'rate': serializer.toJson<double>(rate),
    };
  }

  FxRate copyWith({int? id, int? fxPairId, DateTime? rateDate, double? rate}) =>
      FxRate(
        id: id ?? this.id,
        fxPairId: fxPairId ?? this.fxPairId,
        rateDate: rateDate ?? this.rateDate,
        rate: rate ?? this.rate,
      );
  FxRate copyWithCompanion(FxRatesCompanion data) {
    return FxRate(
      id: data.id.present ? data.id.value : this.id,
      fxPairId: data.fxPairId.present ? data.fxPairId.value : this.fxPairId,
      rateDate: data.rateDate.present ? data.rateDate.value : this.rateDate,
      rate: data.rate.present ? data.rate.value : this.rate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FxRate(')
          ..write('id: $id, ')
          ..write('fxPairId: $fxPairId, ')
          ..write('rateDate: $rateDate, ')
          ..write('rate: $rate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fxPairId, rateDate, rate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FxRate &&
          other.id == this.id &&
          other.fxPairId == this.fxPairId &&
          other.rateDate == this.rateDate &&
          other.rate == this.rate);
}

class FxRatesCompanion extends UpdateCompanion<FxRate> {
  final Value<int> id;
  final Value<int> fxPairId;
  final Value<DateTime> rateDate;
  final Value<double> rate;
  const FxRatesCompanion({
    this.id = const Value.absent(),
    this.fxPairId = const Value.absent(),
    this.rateDate = const Value.absent(),
    this.rate = const Value.absent(),
  });
  FxRatesCompanion.insert({
    this.id = const Value.absent(),
    required int fxPairId,
    required DateTime rateDate,
    required double rate,
  }) : fxPairId = Value(fxPairId),
       rateDate = Value(rateDate),
       rate = Value(rate);
  static Insertable<FxRate> custom({
    Expression<int>? id,
    Expression<int>? fxPairId,
    Expression<DateTime>? rateDate,
    Expression<double>? rate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fxPairId != null) 'fx_pair_id': fxPairId,
      if (rateDate != null) 'rate_date': rateDate,
      if (rate != null) 'rate': rate,
    });
  }

  FxRatesCompanion copyWith({
    Value<int>? id,
    Value<int>? fxPairId,
    Value<DateTime>? rateDate,
    Value<double>? rate,
  }) {
    return FxRatesCompanion(
      id: id ?? this.id,
      fxPairId: fxPairId ?? this.fxPairId,
      rateDate: rateDate ?? this.rateDate,
      rate: rate ?? this.rate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fxPairId.present) {
      map['fx_pair_id'] = Variable<int>(fxPairId.value);
    }
    if (rateDate.present) {
      map['rate_date'] = Variable<DateTime>(rateDate.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FxRatesCompanion(')
          ..write('id: $id, ')
          ..write('fxPairId: $fxPairId, ')
          ..write('rateDate: $rateDate, ')
          ..write('rate: $rate')
          ..write(')'))
        .toString();
  }
}

class $CryptoInfoTable extends CryptoInfo
    with TableInfo<$CryptoInfoTable, CryptoInfoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CryptoInfoTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cryptoExchangeMeta = const VerificationMeta(
    'cryptoExchange',
  );
  @override
  late final GeneratedColumn<String> cryptoExchange = GeneratedColumn<String>(
    'crypto_exchange',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _apiKeyMeta = const VerificationMeta('apiKey');
  @override
  late final GeneratedColumn<String> apiKey = GeneratedColumn<String>(
    'api_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _apiSecretMeta = const VerificationMeta(
    'apiSecret',
  );
  @override
  late final GeneratedColumn<String> apiSecret = GeneratedColumn<String>(
    'api_secret',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountId,
    cryptoExchange,
    apiKey,
    apiSecret,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crypto_info';
  @override
  VerificationContext validateIntegrity(
    Insertable<CryptoInfoData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('crypto_exchange')) {
      context.handle(
        _cryptoExchangeMeta,
        cryptoExchange.isAcceptableOrUnknown(
          data['crypto_exchange']!,
          _cryptoExchangeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cryptoExchangeMeta);
    }
    if (data.containsKey('api_key')) {
      context.handle(
        _apiKeyMeta,
        apiKey.isAcceptableOrUnknown(data['api_key']!, _apiKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_apiKeyMeta);
    }
    if (data.containsKey('api_secret')) {
      context.handle(
        _apiSecretMeta,
        apiSecret.isAcceptableOrUnknown(data['api_secret']!, _apiSecretMeta),
      );
    } else if (isInserting) {
      context.missing(_apiSecretMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {accountId, cryptoExchange},
  ];
  @override
  CryptoInfoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CryptoInfoData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      cryptoExchange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}crypto_exchange'],
      )!,
      apiKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}api_key'],
      )!,
      apiSecret: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}api_secret'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CryptoInfoTable createAlias(String alias) {
    return $CryptoInfoTable(attachedDatabase, alias);
  }
}

class CryptoInfoData extends DataClass implements Insertable<CryptoInfoData> {
  final int id;
  final int accountId;
  final String cryptoExchange;
  final String apiKey;
  final String apiSecret;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CryptoInfoData({
    required this.id,
    required this.accountId,
    required this.cryptoExchange,
    required this.apiKey,
    required this.apiSecret,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_id'] = Variable<int>(accountId);
    map['crypto_exchange'] = Variable<String>(cryptoExchange);
    map['api_key'] = Variable<String>(apiKey);
    map['api_secret'] = Variable<String>(apiSecret);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CryptoInfoCompanion toCompanion(bool nullToAbsent) {
    return CryptoInfoCompanion(
      id: Value(id),
      accountId: Value(accountId),
      cryptoExchange: Value(cryptoExchange),
      apiKey: Value(apiKey),
      apiSecret: Value(apiSecret),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CryptoInfoData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CryptoInfoData(
      id: serializer.fromJson<int>(json['id']),
      accountId: serializer.fromJson<int>(json['accountId']),
      cryptoExchange: serializer.fromJson<String>(json['cryptoExchange']),
      apiKey: serializer.fromJson<String>(json['apiKey']),
      apiSecret: serializer.fromJson<String>(json['apiSecret']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountId': serializer.toJson<int>(accountId),
      'cryptoExchange': serializer.toJson<String>(cryptoExchange),
      'apiKey': serializer.toJson<String>(apiKey),
      'apiSecret': serializer.toJson<String>(apiSecret),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CryptoInfoData copyWith({
    int? id,
    int? accountId,
    String? cryptoExchange,
    String? apiKey,
    String? apiSecret,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CryptoInfoData(
    id: id ?? this.id,
    accountId: accountId ?? this.accountId,
    cryptoExchange: cryptoExchange ?? this.cryptoExchange,
    apiKey: apiKey ?? this.apiKey,
    apiSecret: apiSecret ?? this.apiSecret,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CryptoInfoData copyWithCompanion(CryptoInfoCompanion data) {
    return CryptoInfoData(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      cryptoExchange: data.cryptoExchange.present
          ? data.cryptoExchange.value
          : this.cryptoExchange,
      apiKey: data.apiKey.present ? data.apiKey.value : this.apiKey,
      apiSecret: data.apiSecret.present ? data.apiSecret.value : this.apiSecret,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CryptoInfoData(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('cryptoExchange: $cryptoExchange, ')
          ..write('apiKey: $apiKey, ')
          ..write('apiSecret: $apiSecret, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accountId,
    cryptoExchange,
    apiKey,
    apiSecret,
    status,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CryptoInfoData &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.cryptoExchange == this.cryptoExchange &&
          other.apiKey == this.apiKey &&
          other.apiSecret == this.apiSecret &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CryptoInfoCompanion extends UpdateCompanion<CryptoInfoData> {
  final Value<int> id;
  final Value<int> accountId;
  final Value<String> cryptoExchange;
  final Value<String> apiKey;
  final Value<String> apiSecret;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CryptoInfoCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.cryptoExchange = const Value.absent(),
    this.apiKey = const Value.absent(),
    this.apiSecret = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CryptoInfoCompanion.insert({
    this.id = const Value.absent(),
    required int accountId,
    required String cryptoExchange,
    required String apiKey,
    required String apiSecret,
    this.status = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : accountId = Value(accountId),
       cryptoExchange = Value(cryptoExchange),
       apiKey = Value(apiKey),
       apiSecret = Value(apiSecret),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CryptoInfoData> custom({
    Expression<int>? id,
    Expression<int>? accountId,
    Expression<String>? cryptoExchange,
    Expression<String>? apiKey,
    Expression<String>? apiSecret,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (cryptoExchange != null) 'crypto_exchange': cryptoExchange,
      if (apiKey != null) 'api_key': apiKey,
      if (apiSecret != null) 'api_secret': apiSecret,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CryptoInfoCompanion copyWith({
    Value<int>? id,
    Value<int>? accountId,
    Value<String>? cryptoExchange,
    Value<String>? apiKey,
    Value<String>? apiSecret,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CryptoInfoCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      cryptoExchange: cryptoExchange ?? this.cryptoExchange,
      apiKey: apiKey ?? this.apiKey,
      apiSecret: apiSecret ?? this.apiSecret,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (cryptoExchange.present) {
      map['crypto_exchange'] = Variable<String>(cryptoExchange.value);
    }
    if (apiKey.present) {
      map['api_key'] = Variable<String>(apiKey.value);
    }
    if (apiSecret.present) {
      map['api_secret'] = Variable<String>(apiSecret.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CryptoInfoCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('cryptoExchange: $cryptoExchange, ')
          ..write('apiKey: $apiKey, ')
          ..write('apiSecret: $apiSecret, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TradeRecordsTable tradeRecords = $TradeRecordsTable(this);
  late final $StocksTable stocks = $StocksTable(this);
  late final $FundsTable funds = $FundsTable(this);
  late final $FundTransactionsTable fundTransactions = $FundTransactionsTable(
    this,
  );
  late final $TradeSellMappingsTable tradeSellMappings =
      $TradeSellMappingsTable(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $StockPricesTable stockPrices = $StockPricesTable(this);
  late final $FxRatesTable fxRates = $FxRatesTable(this);
  late final $CryptoInfoTable cryptoInfo = $CryptoInfoTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tradeRecords,
    stocks,
    funds,
    fundTransactions,
    tradeSellMappings,
    accounts,
    stockPrices,
    fxRates,
    cryptoInfo,
  ];
}

typedef $$TradeRecordsTableCreateCompanionBuilder =
    TradeRecordsCompanion Function({
      Value<int> id,
      required String userId,
      Value<int?> accountId,
      required String assetType,
      required int assetId,
      required DateTime tradeDate,
      required String action,
      Value<String?> tradeType,
      required double quantity,
      required double price,
      Value<double?> feeAmount,
      Value<String?> feeCurrency,
      Value<String?> positionType,
      Value<double?> leverage,
      Value<double?> swapAmount,
      Value<String?> swapCurrency,
      Value<bool?> manualRateInput,
      Value<String?> remark,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<double?> profit,
    });
typedef $$TradeRecordsTableUpdateCompanionBuilder =
    TradeRecordsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<int?> accountId,
      Value<String> assetType,
      Value<int> assetId,
      Value<DateTime> tradeDate,
      Value<String> action,
      Value<String?> tradeType,
      Value<double> quantity,
      Value<double> price,
      Value<double?> feeAmount,
      Value<String?> feeCurrency,
      Value<String?> positionType,
      Value<double?> leverage,
      Value<double?> swapAmount,
      Value<String?> swapCurrency,
      Value<bool?> manualRateInput,
      Value<String?> remark,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<double?> profit,
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetType => $composableBuilder(
    column: $table.assetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tradeDate => $composableBuilder(
    column: $table.tradeDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tradeType => $composableBuilder(
    column: $table.tradeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get feeAmount => $composableBuilder(
    column: $table.feeAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feeCurrency => $composableBuilder(
    column: $table.feeCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get positionType => $composableBuilder(
    column: $table.positionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get leverage => $composableBuilder(
    column: $table.leverage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get swapAmount => $composableBuilder(
    column: $table.swapAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get swapCurrency => $composableBuilder(
    column: $table.swapCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get manualRateInput => $composableBuilder(
    column: $table.manualRateInput,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get profit => $composableBuilder(
    column: $table.profit,
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetType => $composableBuilder(
    column: $table.assetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get assetId => $composableBuilder(
    column: $table.assetId,
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

  ColumnOrderings<String> get tradeType => $composableBuilder(
    column: $table.tradeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get feeAmount => $composableBuilder(
    column: $table.feeAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feeCurrency => $composableBuilder(
    column: $table.feeCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get positionType => $composableBuilder(
    column: $table.positionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get leverage => $composableBuilder(
    column: $table.leverage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get swapAmount => $composableBuilder(
    column: $table.swapAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get swapCurrency => $composableBuilder(
    column: $table.swapCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get manualRateInput => $composableBuilder(
    column: $table.manualRateInput,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get profit => $composableBuilder(
    column: $table.profit,
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

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get assetType =>
      $composableBuilder(column: $table.assetType, builder: (column) => column);

  GeneratedColumn<int> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<DateTime> get tradeDate =>
      $composableBuilder(column: $table.tradeDate, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get tradeType =>
      $composableBuilder(column: $table.tradeType, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get feeAmount =>
      $composableBuilder(column: $table.feeAmount, builder: (column) => column);

  GeneratedColumn<String> get feeCurrency => $composableBuilder(
    column: $table.feeCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get positionType => $composableBuilder(
    column: $table.positionType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get leverage =>
      $composableBuilder(column: $table.leverage, builder: (column) => column);

  GeneratedColumn<double> get swapAmount => $composableBuilder(
    column: $table.swapAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get swapCurrency => $composableBuilder(
    column: $table.swapCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get manualRateInput => $composableBuilder(
    column: $table.manualRateInput,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<double> get profit =>
      $composableBuilder(column: $table.profit, builder: (column) => column);
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
                Value<String> userId = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
                Value<String> assetType = const Value.absent(),
                Value<int> assetId = const Value.absent(),
                Value<DateTime> tradeDate = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> tradeType = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<double?> feeAmount = const Value.absent(),
                Value<String?> feeCurrency = const Value.absent(),
                Value<String?> positionType = const Value.absent(),
                Value<double?> leverage = const Value.absent(),
                Value<double?> swapAmount = const Value.absent(),
                Value<String?> swapCurrency = const Value.absent(),
                Value<bool?> manualRateInput = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<double?> profit = const Value.absent(),
              }) => TradeRecordsCompanion(
                id: id,
                userId: userId,
                accountId: accountId,
                assetType: assetType,
                assetId: assetId,
                tradeDate: tradeDate,
                action: action,
                tradeType: tradeType,
                quantity: quantity,
                price: price,
                feeAmount: feeAmount,
                feeCurrency: feeCurrency,
                positionType: positionType,
                leverage: leverage,
                swapAmount: swapAmount,
                swapCurrency: swapCurrency,
                manualRateInput: manualRateInput,
                remark: remark,
                createdAt: createdAt,
                updatedAt: updatedAt,
                profit: profit,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                Value<int?> accountId = const Value.absent(),
                required String assetType,
                required int assetId,
                required DateTime tradeDate,
                required String action,
                Value<String?> tradeType = const Value.absent(),
                required double quantity,
                required double price,
                Value<double?> feeAmount = const Value.absent(),
                Value<String?> feeCurrency = const Value.absent(),
                Value<String?> positionType = const Value.absent(),
                Value<double?> leverage = const Value.absent(),
                Value<double?> swapAmount = const Value.absent(),
                Value<String?> swapCurrency = const Value.absent(),
                Value<bool?> manualRateInput = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<double?> profit = const Value.absent(),
              }) => TradeRecordsCompanion.insert(
                id: id,
                userId: userId,
                accountId: accountId,
                assetType: assetType,
                assetId: assetId,
                tradeDate: tradeDate,
                action: action,
                tradeType: tradeType,
                quantity: quantity,
                price: price,
                feeAmount: feeAmount,
                feeCurrency: feeCurrency,
                positionType: positionType,
                leverage: leverage,
                swapAmount: swapAmount,
                swapCurrency: swapCurrency,
                manualRateInput: manualRateInput,
                remark: remark,
                createdAt: createdAt,
                updatedAt: updatedAt,
                profit: profit,
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
typedef $$StocksTableCreateCompanionBuilder =
    StocksCompanion Function({
      Value<int> id,
      Value<String?> ticker,
      Value<String?> exchange,
      required String name,
      Value<String?> nameUs,
      required String currency,
      required String country,
      Value<int?> sectorIndustryId,
      Value<String?> logo,
      Value<String> status,
      Value<double?> lastPrice,
      Value<DateTime?> lastPriceAt,
    });
typedef $$StocksTableUpdateCompanionBuilder =
    StocksCompanion Function({
      Value<int> id,
      Value<String?> ticker,
      Value<String?> exchange,
      Value<String> name,
      Value<String?> nameUs,
      Value<String> currency,
      Value<String> country,
      Value<int?> sectorIndustryId,
      Value<String?> logo,
      Value<String> status,
      Value<double?> lastPrice,
      Value<DateTime?> lastPriceAt,
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
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ticker => $composableBuilder(
    column: $table.ticker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exchange => $composableBuilder(
    column: $table.exchange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameUs => $composableBuilder(
    column: $table.nameUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sectorIndustryId => $composableBuilder(
    column: $table.sectorIndustryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logo => $composableBuilder(
    column: $table.logo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lastPrice => $composableBuilder(
    column: $table.lastPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPriceAt => $composableBuilder(
    column: $table.lastPriceAt,
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
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ticker => $composableBuilder(
    column: $table.ticker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exchange => $composableBuilder(
    column: $table.exchange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameUs => $composableBuilder(
    column: $table.nameUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sectorIndustryId => $composableBuilder(
    column: $table.sectorIndustryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logo => $composableBuilder(
    column: $table.logo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastPrice => $composableBuilder(
    column: $table.lastPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPriceAt => $composableBuilder(
    column: $table.lastPriceAt,
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ticker =>
      $composableBuilder(column: $table.ticker, builder: (column) => column);

  GeneratedColumn<String> get exchange =>
      $composableBuilder(column: $table.exchange, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameUs =>
      $composableBuilder(column: $table.nameUs, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<int> get sectorIndustryId => $composableBuilder(
    column: $table.sectorIndustryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get logo =>
      $composableBuilder(column: $table.logo, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get lastPrice =>
      $composableBuilder(column: $table.lastPrice, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPriceAt => $composableBuilder(
    column: $table.lastPriceAt,
    builder: (column) => column,
  );
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
                Value<int> id = const Value.absent(),
                Value<String?> ticker = const Value.absent(),
                Value<String?> exchange = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> nameUs = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<int?> sectorIndustryId = const Value.absent(),
                Value<String?> logo = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double?> lastPrice = const Value.absent(),
                Value<DateTime?> lastPriceAt = const Value.absent(),
              }) => StocksCompanion(
                id: id,
                ticker: ticker,
                exchange: exchange,
                name: name,
                nameUs: nameUs,
                currency: currency,
                country: country,
                sectorIndustryId: sectorIndustryId,
                logo: logo,
                status: status,
                lastPrice: lastPrice,
                lastPriceAt: lastPriceAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> ticker = const Value.absent(),
                Value<String?> exchange = const Value.absent(),
                required String name,
                Value<String?> nameUs = const Value.absent(),
                required String currency,
                required String country,
                Value<int?> sectorIndustryId = const Value.absent(),
                Value<String?> logo = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double?> lastPrice = const Value.absent(),
                Value<DateTime?> lastPriceAt = const Value.absent(),
              }) => StocksCompanion.insert(
                id: id,
                ticker: ticker,
                exchange: exchange,
                name: name,
                nameUs: nameUs,
                currency: currency,
                country: country,
                sectorIndustryId: sectorIndustryId,
                logo: logo,
                status: status,
                lastPrice: lastPrice,
                lastPriceAt: lastPriceAt,
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
typedef $$FundsTableCreateCompanionBuilder =
    FundsCompanion Function({
      required int id,
      required String code,
      required String name,
      Value<String?> nameUs,
      Value<String?> managementCompany,
      Value<DateTime?> foundationDate,
      Value<bool?> tsumitateFlag,
      Value<String?> isinCd,
      Value<int> rowid,
    });
typedef $$FundsTableUpdateCompanionBuilder =
    FundsCompanion Function({
      Value<int> id,
      Value<String> code,
      Value<String> name,
      Value<String?> nameUs,
      Value<String?> managementCompany,
      Value<DateTime?> foundationDate,
      Value<bool?> tsumitateFlag,
      Value<String?> isinCd,
      Value<int> rowid,
    });

class $$FundsTableFilterComposer extends Composer<_$AppDatabase, $FundsTable> {
  $$FundsTableFilterComposer({
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameUs => $composableBuilder(
    column: $table.nameUs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get managementCompany => $composableBuilder(
    column: $table.managementCompany,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get foundationDate => $composableBuilder(
    column: $table.foundationDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get tsumitateFlag => $composableBuilder(
    column: $table.tsumitateFlag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isinCd => $composableBuilder(
    column: $table.isinCd,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FundsTableOrderingComposer
    extends Composer<_$AppDatabase, $FundsTable> {
  $$FundsTableOrderingComposer({
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameUs => $composableBuilder(
    column: $table.nameUs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get managementCompany => $composableBuilder(
    column: $table.managementCompany,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get foundationDate => $composableBuilder(
    column: $table.foundationDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get tsumitateFlag => $composableBuilder(
    column: $table.tsumitateFlag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isinCd => $composableBuilder(
    column: $table.isinCd,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FundsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FundsTable> {
  $$FundsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameUs =>
      $composableBuilder(column: $table.nameUs, builder: (column) => column);

  GeneratedColumn<String> get managementCompany => $composableBuilder(
    column: $table.managementCompany,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get foundationDate => $composableBuilder(
    column: $table.foundationDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get tsumitateFlag => $composableBuilder(
    column: $table.tsumitateFlag,
    builder: (column) => column,
  );

  GeneratedColumn<String> get isinCd =>
      $composableBuilder(column: $table.isinCd, builder: (column) => column);
}

class $$FundsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FundsTable,
          Fund,
          $$FundsTableFilterComposer,
          $$FundsTableOrderingComposer,
          $$FundsTableAnnotationComposer,
          $$FundsTableCreateCompanionBuilder,
          $$FundsTableUpdateCompanionBuilder,
          (Fund, BaseReferences<_$AppDatabase, $FundsTable, Fund>),
          Fund,
          PrefetchHooks Function()
        > {
  $$FundsTableTableManager(_$AppDatabase db, $FundsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FundsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FundsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FundsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> nameUs = const Value.absent(),
                Value<String?> managementCompany = const Value.absent(),
                Value<DateTime?> foundationDate = const Value.absent(),
                Value<bool?> tsumitateFlag = const Value.absent(),
                Value<String?> isinCd = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FundsCompanion(
                id: id,
                code: code,
                name: name,
                nameUs: nameUs,
                managementCompany: managementCompany,
                foundationDate: foundationDate,
                tsumitateFlag: tsumitateFlag,
                isinCd: isinCd,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String code,
                required String name,
                Value<String?> nameUs = const Value.absent(),
                Value<String?> managementCompany = const Value.absent(),
                Value<DateTime?> foundationDate = const Value.absent(),
                Value<bool?> tsumitateFlag = const Value.absent(),
                Value<String?> isinCd = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FundsCompanion.insert(
                id: id,
                code: code,
                name: name,
                nameUs: nameUs,
                managementCompany: managementCompany,
                foundationDate: foundationDate,
                tsumitateFlag: tsumitateFlag,
                isinCd: isinCd,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FundsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FundsTable,
      Fund,
      $$FundsTableFilterComposer,
      $$FundsTableOrderingComposer,
      $$FundsTableAnnotationComposer,
      $$FundsTableCreateCompanionBuilder,
      $$FundsTableUpdateCompanionBuilder,
      (Fund, BaseReferences<_$AppDatabase, $FundsTable, Fund>),
      Fund,
      PrefetchHooks Function()
    >;
typedef $$FundTransactionsTableCreateCompanionBuilder =
    FundTransactionsCompanion Function({
      required int id,
      required String userId,
      required int accountId,
      required int fundId,
      required DateTime tradeDate,
      required String action,
      required String tradeType,
      required String accountType,
      Value<double?> amount,
      Value<double?> quantity,
      Value<double?> price,
      Value<double?> feeAmount,
      Value<String?> feeCurrency,
      Value<String?> recurringFrequencyType,
      Value<String?> recurringFrequencyConfig,
      Value<DateTime?> recurringStartDate,
      Value<DateTime?> recurringEndDate,
      Value<String?> recurringStatus,
      Value<String?> remark,
      Value<int> rowid,
    });
typedef $$FundTransactionsTableUpdateCompanionBuilder =
    FundTransactionsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<int> accountId,
      Value<int> fundId,
      Value<DateTime> tradeDate,
      Value<String> action,
      Value<String> tradeType,
      Value<String> accountType,
      Value<double?> amount,
      Value<double?> quantity,
      Value<double?> price,
      Value<double?> feeAmount,
      Value<String?> feeCurrency,
      Value<String?> recurringFrequencyType,
      Value<String?> recurringFrequencyConfig,
      Value<DateTime?> recurringStartDate,
      Value<DateTime?> recurringEndDate,
      Value<String?> recurringStatus,
      Value<String?> remark,
      Value<int> rowid,
    });

class $$FundTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $FundTransactionsTable> {
  $$FundTransactionsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fundId => $composableBuilder(
    column: $table.fundId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get tradeDate => $composableBuilder(
    column: $table.tradeDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tradeType => $composableBuilder(
    column: $table.tradeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountType => $composableBuilder(
    column: $table.accountType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get feeAmount => $composableBuilder(
    column: $table.feeAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feeCurrency => $composableBuilder(
    column: $table.feeCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurringFrequencyType => $composableBuilder(
    column: $table.recurringFrequencyType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurringFrequencyConfig => $composableBuilder(
    column: $table.recurringFrequencyConfig,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recurringStartDate => $composableBuilder(
    column: $table.recurringStartDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recurringEndDate => $composableBuilder(
    column: $table.recurringEndDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurringStatus => $composableBuilder(
    column: $table.recurringStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FundTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $FundTransactionsTable> {
  $$FundTransactionsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fundId => $composableBuilder(
    column: $table.fundId,
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

  ColumnOrderings<String> get tradeType => $composableBuilder(
    column: $table.tradeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountType => $composableBuilder(
    column: $table.accountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get feeAmount => $composableBuilder(
    column: $table.feeAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feeCurrency => $composableBuilder(
    column: $table.feeCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurringFrequencyType => $composableBuilder(
    column: $table.recurringFrequencyType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurringFrequencyConfig => $composableBuilder(
    column: $table.recurringFrequencyConfig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recurringStartDate => $composableBuilder(
    column: $table.recurringStartDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recurringEndDate => $composableBuilder(
    column: $table.recurringEndDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurringStatus => $composableBuilder(
    column: $table.recurringStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remark => $composableBuilder(
    column: $table.remark,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FundTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FundTransactionsTable> {
  $$FundTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get fundId =>
      $composableBuilder(column: $table.fundId, builder: (column) => column);

  GeneratedColumn<DateTime> get tradeDate =>
      $composableBuilder(column: $table.tradeDate, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get tradeType =>
      $composableBuilder(column: $table.tradeType, builder: (column) => column);

  GeneratedColumn<String> get accountType => $composableBuilder(
    column: $table.accountType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get feeAmount =>
      $composableBuilder(column: $table.feeAmount, builder: (column) => column);

  GeneratedColumn<String> get feeCurrency => $composableBuilder(
    column: $table.feeCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurringFrequencyType => $composableBuilder(
    column: $table.recurringFrequencyType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurringFrequencyConfig => $composableBuilder(
    column: $table.recurringFrequencyConfig,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recurringStartDate => $composableBuilder(
    column: $table.recurringStartDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recurringEndDate => $composableBuilder(
    column: $table.recurringEndDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurringStatus => $composableBuilder(
    column: $table.recurringStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);
}

class $$FundTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FundTransactionsTable,
          FundTransaction,
          $$FundTransactionsTableFilterComposer,
          $$FundTransactionsTableOrderingComposer,
          $$FundTransactionsTableAnnotationComposer,
          $$FundTransactionsTableCreateCompanionBuilder,
          $$FundTransactionsTableUpdateCompanionBuilder,
          (
            FundTransaction,
            BaseReferences<
              _$AppDatabase,
              $FundTransactionsTable,
              FundTransaction
            >,
          ),
          FundTransaction,
          PrefetchHooks Function()
        > {
  $$FundTransactionsTableTableManager(
    _$AppDatabase db,
    $FundTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FundTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FundTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FundTransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> accountId = const Value.absent(),
                Value<int> fundId = const Value.absent(),
                Value<DateTime> tradeDate = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> tradeType = const Value.absent(),
                Value<String> accountType = const Value.absent(),
                Value<double?> amount = const Value.absent(),
                Value<double?> quantity = const Value.absent(),
                Value<double?> price = const Value.absent(),
                Value<double?> feeAmount = const Value.absent(),
                Value<String?> feeCurrency = const Value.absent(),
                Value<String?> recurringFrequencyType = const Value.absent(),
                Value<String?> recurringFrequencyConfig = const Value.absent(),
                Value<DateTime?> recurringStartDate = const Value.absent(),
                Value<DateTime?> recurringEndDate = const Value.absent(),
                Value<String?> recurringStatus = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FundTransactionsCompanion(
                id: id,
                userId: userId,
                accountId: accountId,
                fundId: fundId,
                tradeDate: tradeDate,
                action: action,
                tradeType: tradeType,
                accountType: accountType,
                amount: amount,
                quantity: quantity,
                price: price,
                feeAmount: feeAmount,
                feeCurrency: feeCurrency,
                recurringFrequencyType: recurringFrequencyType,
                recurringFrequencyConfig: recurringFrequencyConfig,
                recurringStartDate: recurringStartDate,
                recurringEndDate: recurringEndDate,
                recurringStatus: recurringStatus,
                remark: remark,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String userId,
                required int accountId,
                required int fundId,
                required DateTime tradeDate,
                required String action,
                required String tradeType,
                required String accountType,
                Value<double?> amount = const Value.absent(),
                Value<double?> quantity = const Value.absent(),
                Value<double?> price = const Value.absent(),
                Value<double?> feeAmount = const Value.absent(),
                Value<String?> feeCurrency = const Value.absent(),
                Value<String?> recurringFrequencyType = const Value.absent(),
                Value<String?> recurringFrequencyConfig = const Value.absent(),
                Value<DateTime?> recurringStartDate = const Value.absent(),
                Value<DateTime?> recurringEndDate = const Value.absent(),
                Value<String?> recurringStatus = const Value.absent(),
                Value<String?> remark = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FundTransactionsCompanion.insert(
                id: id,
                userId: userId,
                accountId: accountId,
                fundId: fundId,
                tradeDate: tradeDate,
                action: action,
                tradeType: tradeType,
                accountType: accountType,
                amount: amount,
                quantity: quantity,
                price: price,
                feeAmount: feeAmount,
                feeCurrency: feeCurrency,
                recurringFrequencyType: recurringFrequencyType,
                recurringFrequencyConfig: recurringFrequencyConfig,
                recurringStartDate: recurringStartDate,
                recurringEndDate: recurringEndDate,
                recurringStatus: recurringStatus,
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

typedef $$FundTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FundTransactionsTable,
      FundTransaction,
      $$FundTransactionsTableFilterComposer,
      $$FundTransactionsTableOrderingComposer,
      $$FundTransactionsTableAnnotationComposer,
      $$FundTransactionsTableCreateCompanionBuilder,
      $$FundTransactionsTableUpdateCompanionBuilder,
      (
        FundTransaction,
        BaseReferences<_$AppDatabase, $FundTransactionsTable, FundTransaction>,
      ),
      FundTransaction,
      PrefetchHooks Function()
    >;
typedef $$TradeSellMappingsTableCreateCompanionBuilder =
    TradeSellMappingsCompanion Function({
      Value<int> id,
      required int buyId,
      required int sellId,
      required double quantity,
    });
typedef $$TradeSellMappingsTableUpdateCompanionBuilder =
    TradeSellMappingsCompanion Function({
      Value<int> id,
      Value<int> buyId,
      Value<int> sellId,
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

  ColumnFilters<int> get buyId => $composableBuilder(
    column: $table.buyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sellId => $composableBuilder(
    column: $table.sellId,
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

  ColumnOrderings<int> get buyId => $composableBuilder(
    column: $table.buyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sellId => $composableBuilder(
    column: $table.sellId,
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

  GeneratedColumn<int> get buyId =>
      $composableBuilder(column: $table.buyId, builder: (column) => column);

  GeneratedColumn<int> get sellId =>
      $composableBuilder(column: $table.sellId, builder: (column) => column);

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
                Value<int> buyId = const Value.absent(),
                Value<int> sellId = const Value.absent(),
                Value<double> quantity = const Value.absent(),
              }) => TradeSellMappingsCompanion(
                id: id,
                buyId: buyId,
                sellId: sellId,
                quantity: quantity,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int buyId,
                required int sellId,
                required double quantity,
              }) => TradeSellMappingsCompanion.insert(
                id: id,
                buyId: buyId,
                sellId: sellId,
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
typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      Value<int> id,
      required String userId,
      required String name,
      Value<String?> type,
      Value<DateTime?> createdAt,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> name,
      Value<String?> type,
      Value<DateTime?> createdAt,
    });

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          Account,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
          Account,
          PrefetchHooks Function()
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> type = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                userId: userId,
                name: name,
                type: type,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required String name,
                Value<String?> type = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                type: type,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      Account,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (Account, BaseReferences<_$AppDatabase, $AccountsTable, Account>),
      Account,
      PrefetchHooks Function()
    >;
typedef $$StockPricesTableCreateCompanionBuilder =
    StockPricesCompanion Function({
      Value<int> id,
      required int stockId,
      required double price,
      required DateTime priceAt,
      Value<DateTime?> createdAt,
    });
typedef $$StockPricesTableUpdateCompanionBuilder =
    StockPricesCompanion Function({
      Value<int> id,
      Value<int> stockId,
      Value<double> price,
      Value<DateTime> priceAt,
      Value<DateTime?> createdAt,
    });

class $$StockPricesTableFilterComposer
    extends Composer<_$AppDatabase, $StockPricesTable> {
  $$StockPricesTableFilterComposer({
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

  ColumnFilters<int> get stockId => $composableBuilder(
    column: $table.stockId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get priceAt => $composableBuilder(
    column: $table.priceAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StockPricesTableOrderingComposer
    extends Composer<_$AppDatabase, $StockPricesTable> {
  $$StockPricesTableOrderingComposer({
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

  ColumnOrderings<int> get stockId => $composableBuilder(
    column: $table.stockId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get priceAt => $composableBuilder(
    column: $table.priceAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockPricesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockPricesTable> {
  $$StockPricesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get stockId =>
      $composableBuilder(column: $table.stockId, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<DateTime> get priceAt =>
      $composableBuilder(column: $table.priceAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$StockPricesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockPricesTable,
          StockPrice,
          $$StockPricesTableFilterComposer,
          $$StockPricesTableOrderingComposer,
          $$StockPricesTableAnnotationComposer,
          $$StockPricesTableCreateCompanionBuilder,
          $$StockPricesTableUpdateCompanionBuilder,
          (
            StockPrice,
            BaseReferences<_$AppDatabase, $StockPricesTable, StockPrice>,
          ),
          StockPrice,
          PrefetchHooks Function()
        > {
  $$StockPricesTableTableManager(_$AppDatabase db, $StockPricesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockPricesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockPricesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockPricesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> stockId = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<DateTime> priceAt = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
              }) => StockPricesCompanion(
                id: id,
                stockId: stockId,
                price: price,
                priceAt: priceAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int stockId,
                required double price,
                required DateTime priceAt,
                Value<DateTime?> createdAt = const Value.absent(),
              }) => StockPricesCompanion.insert(
                id: id,
                stockId: stockId,
                price: price,
                priceAt: priceAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockPricesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockPricesTable,
      StockPrice,
      $$StockPricesTableFilterComposer,
      $$StockPricesTableOrderingComposer,
      $$StockPricesTableAnnotationComposer,
      $$StockPricesTableCreateCompanionBuilder,
      $$StockPricesTableUpdateCompanionBuilder,
      (
        StockPrice,
        BaseReferences<_$AppDatabase, $StockPricesTable, StockPrice>,
      ),
      StockPrice,
      PrefetchHooks Function()
    >;
typedef $$FxRatesTableCreateCompanionBuilder =
    FxRatesCompanion Function({
      Value<int> id,
      required int fxPairId,
      required DateTime rateDate,
      required double rate,
    });
typedef $$FxRatesTableUpdateCompanionBuilder =
    FxRatesCompanion Function({
      Value<int> id,
      Value<int> fxPairId,
      Value<DateTime> rateDate,
      Value<double> rate,
    });

class $$FxRatesTableFilterComposer
    extends Composer<_$AppDatabase, $FxRatesTable> {
  $$FxRatesTableFilterComposer({
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

  ColumnFilters<int> get fxPairId => $composableBuilder(
    column: $table.fxPairId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get rateDate => $composableBuilder(
    column: $table.rateDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FxRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $FxRatesTable> {
  $$FxRatesTableOrderingComposer({
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

  ColumnOrderings<int> get fxPairId => $composableBuilder(
    column: $table.fxPairId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get rateDate => $composableBuilder(
    column: $table.rateDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FxRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FxRatesTable> {
  $$FxRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get fxPairId =>
      $composableBuilder(column: $table.fxPairId, builder: (column) => column);

  GeneratedColumn<DateTime> get rateDate =>
      $composableBuilder(column: $table.rateDate, builder: (column) => column);

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);
}

class $$FxRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FxRatesTable,
          FxRate,
          $$FxRatesTableFilterComposer,
          $$FxRatesTableOrderingComposer,
          $$FxRatesTableAnnotationComposer,
          $$FxRatesTableCreateCompanionBuilder,
          $$FxRatesTableUpdateCompanionBuilder,
          (FxRate, BaseReferences<_$AppDatabase, $FxRatesTable, FxRate>),
          FxRate,
          PrefetchHooks Function()
        > {
  $$FxRatesTableTableManager(_$AppDatabase db, $FxRatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FxRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FxRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FxRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> fxPairId = const Value.absent(),
                Value<DateTime> rateDate = const Value.absent(),
                Value<double> rate = const Value.absent(),
              }) => FxRatesCompanion(
                id: id,
                fxPairId: fxPairId,
                rateDate: rateDate,
                rate: rate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int fxPairId,
                required DateTime rateDate,
                required double rate,
              }) => FxRatesCompanion.insert(
                id: id,
                fxPairId: fxPairId,
                rateDate: rateDate,
                rate: rate,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FxRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FxRatesTable,
      FxRate,
      $$FxRatesTableFilterComposer,
      $$FxRatesTableOrderingComposer,
      $$FxRatesTableAnnotationComposer,
      $$FxRatesTableCreateCompanionBuilder,
      $$FxRatesTableUpdateCompanionBuilder,
      (FxRate, BaseReferences<_$AppDatabase, $FxRatesTable, FxRate>),
      FxRate,
      PrefetchHooks Function()
    >;
typedef $$CryptoInfoTableCreateCompanionBuilder =
    CryptoInfoCompanion Function({
      Value<int> id,
      required int accountId,
      required String cryptoExchange,
      required String apiKey,
      required String apiSecret,
      Value<String> status,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$CryptoInfoTableUpdateCompanionBuilder =
    CryptoInfoCompanion Function({
      Value<int> id,
      Value<int> accountId,
      Value<String> cryptoExchange,
      Value<String> apiKey,
      Value<String> apiSecret,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$CryptoInfoTableFilterComposer
    extends Composer<_$AppDatabase, $CryptoInfoTable> {
  $$CryptoInfoTableFilterComposer({
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

  ColumnFilters<int> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cryptoExchange => $composableBuilder(
    column: $table.cryptoExchange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apiKey => $composableBuilder(
    column: $table.apiKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apiSecret => $composableBuilder(
    column: $table.apiSecret,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CryptoInfoTableOrderingComposer
    extends Composer<_$AppDatabase, $CryptoInfoTable> {
  $$CryptoInfoTableOrderingComposer({
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

  ColumnOrderings<int> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cryptoExchange => $composableBuilder(
    column: $table.cryptoExchange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apiKey => $composableBuilder(
    column: $table.apiKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apiSecret => $composableBuilder(
    column: $table.apiSecret,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CryptoInfoTableAnnotationComposer
    extends Composer<_$AppDatabase, $CryptoInfoTable> {
  $$CryptoInfoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get cryptoExchange => $composableBuilder(
    column: $table.cryptoExchange,
    builder: (column) => column,
  );

  GeneratedColumn<String> get apiKey =>
      $composableBuilder(column: $table.apiKey, builder: (column) => column);

  GeneratedColumn<String> get apiSecret =>
      $composableBuilder(column: $table.apiSecret, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CryptoInfoTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CryptoInfoTable,
          CryptoInfoData,
          $$CryptoInfoTableFilterComposer,
          $$CryptoInfoTableOrderingComposer,
          $$CryptoInfoTableAnnotationComposer,
          $$CryptoInfoTableCreateCompanionBuilder,
          $$CryptoInfoTableUpdateCompanionBuilder,
          (
            CryptoInfoData,
            BaseReferences<_$AppDatabase, $CryptoInfoTable, CryptoInfoData>,
          ),
          CryptoInfoData,
          PrefetchHooks Function()
        > {
  $$CryptoInfoTableTableManager(_$AppDatabase db, $CryptoInfoTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CryptoInfoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CryptoInfoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CryptoInfoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> accountId = const Value.absent(),
                Value<String> cryptoExchange = const Value.absent(),
                Value<String> apiKey = const Value.absent(),
                Value<String> apiSecret = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CryptoInfoCompanion(
                id: id,
                accountId: accountId,
                cryptoExchange: cryptoExchange,
                apiKey: apiKey,
                apiSecret: apiSecret,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int accountId,
                required String cryptoExchange,
                required String apiKey,
                required String apiSecret,
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => CryptoInfoCompanion.insert(
                id: id,
                accountId: accountId,
                cryptoExchange: cryptoExchange,
                apiKey: apiKey,
                apiSecret: apiSecret,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CryptoInfoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CryptoInfoTable,
      CryptoInfoData,
      $$CryptoInfoTableFilterComposer,
      $$CryptoInfoTableOrderingComposer,
      $$CryptoInfoTableAnnotationComposer,
      $$CryptoInfoTableCreateCompanionBuilder,
      $$CryptoInfoTableUpdateCompanionBuilder,
      (
        CryptoInfoData,
        BaseReferences<_$AppDatabase, $CryptoInfoTable, CryptoInfoData>,
      ),
      CryptoInfoData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TradeRecordsTableTableManager get tradeRecords =>
      $$TradeRecordsTableTableManager(_db, _db.tradeRecords);
  $$StocksTableTableManager get stocks =>
      $$StocksTableTableManager(_db, _db.stocks);
  $$FundsTableTableManager get funds =>
      $$FundsTableTableManager(_db, _db.funds);
  $$FundTransactionsTableTableManager get fundTransactions =>
      $$FundTransactionsTableTableManager(_db, _db.fundTransactions);
  $$TradeSellMappingsTableTableManager get tradeSellMappings =>
      $$TradeSellMappingsTableTableManager(_db, _db.tradeSellMappings);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$StockPricesTableTableManager get stockPrices =>
      $$StockPricesTableTableManager(_db, _db.stockPrices);
  $$FxRatesTableTableManager get fxRates =>
      $$FxRatesTableTableManager(_db, _db.fxRates);
  $$CryptoInfoTableTableManager get cryptoInfo =>
      $$CryptoInfoTableTableManager(_db, _db.cryptoInfo);
}
