// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $LotsTable extends Lots with TableInfo<$LotsTable, LotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LotsTable(this.attachedDatabase, [this._alias]);
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
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameFoldMeta = const VerificationMeta(
    'nameFold',
  );
  @override
  late final GeneratedColumn<String> nameFold = GeneratedColumn<String>(
    'name_fold',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultPriceMeta = const VerificationMeta(
    'defaultPrice',
  );
  @override
  late final GeneratedColumn<int> defaultPrice = GeneratedColumn<int>(
    'default_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _capacityMeta = const VerificationMeta(
    'capacity',
  );
  @override
  late final GeneratedColumn<int> capacity = GeneratedColumn<int>(
    'capacity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    nameFold,
    address,
    defaultPrice,
    capacity,
    notes,
    isActive,
    sortOrder,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lots';
  @override
  VerificationContext validateIntegrity(
    Insertable<LotRow> instance, {
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
    if (data.containsKey('name_fold')) {
      context.handle(
        _nameFoldMeta,
        nameFold.isAcceptableOrUnknown(data['name_fold']!, _nameFoldMeta),
      );
    } else if (isInserting) {
      context.missing(_nameFoldMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('default_price')) {
      context.handle(
        _defaultPriceMeta,
        defaultPrice.isAcceptableOrUnknown(
          data['default_price']!,
          _defaultPriceMeta,
        ),
      );
    }
    if (data.containsKey('capacity')) {
      context.handle(
        _capacityMeta,
        capacity.isAcceptableOrUnknown(data['capacity']!, _capacityMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LotRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameFold: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_fold'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      defaultPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_price'],
      )!,
      capacity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capacity'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LotsTable createAlias(String alias) {
    return $LotsTable(attachedDatabase, alias);
  }
}

class LotRow extends DataClass implements Insertable<LotRow> {
  final int id;
  final String name;

  /// `viFold(name)` — cột phụ có index để tìm kiếm không phân biệt dấu.
  final String nameFold;
  final String? address;

  /// Giá thuê chỗ mặc định, VND/tháng. Dùng để điền sẵn khi thêm xe mới.
  final int defaultPrice;

  /// Sức chứa của bãi. Đặc tả không liệt kê trường này ở mục 2, nhưng mục 10
  /// yêu cầu "tỷ lệ lấp đầy từng bãi" — không có sức chứa thì không tính được.
  /// Cho phép để trống; khi trống thì màn hình thống kê **ẩn** chỉ số lấp đầy
  /// thay vì hiện một con số sai.
  final int? capacity;
  final String? notes;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const LotRow({
    required this.id,
    required this.name,
    required this.nameFold,
    this.address,
    required this.defaultPrice,
    this.capacity,
    this.notes,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['name_fold'] = Variable<String>(nameFold);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['default_price'] = Variable<int>(defaultPrice);
    if (!nullToAbsent || capacity != null) {
      map['capacity'] = Variable<int>(capacity);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  LotsCompanion toCompanion(bool nullToAbsent) {
    return LotsCompanion(
      id: Value(id),
      name: Value(name),
      nameFold: Value(nameFold),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      defaultPrice: Value(defaultPrice),
      capacity: capacity == null && nullToAbsent
          ? const Value.absent()
          : Value(capacity),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LotRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameFold: serializer.fromJson<String>(json['nameFold']),
      address: serializer.fromJson<String?>(json['address']),
      defaultPrice: serializer.fromJson<int>(json['defaultPrice']),
      capacity: serializer.fromJson<int?>(json['capacity']),
      notes: serializer.fromJson<String?>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nameFold': serializer.toJson<String>(nameFold),
      'address': serializer.toJson<String?>(address),
      'defaultPrice': serializer.toJson<int>(defaultPrice),
      'capacity': serializer.toJson<int?>(capacity),
      'notes': serializer.toJson<String?>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  LotRow copyWith({
    int? id,
    String? name,
    String? nameFold,
    Value<String?> address = const Value.absent(),
    int? defaultPrice,
    Value<int?> capacity = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => LotRow(
    id: id ?? this.id,
    name: name ?? this.name,
    nameFold: nameFold ?? this.nameFold,
    address: address.present ? address.value : this.address,
    defaultPrice: defaultPrice ?? this.defaultPrice,
    capacity: capacity.present ? capacity.value : this.capacity,
    notes: notes.present ? notes.value : this.notes,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  LotRow copyWithCompanion(LotsCompanion data) {
    return LotRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameFold: data.nameFold.present ? data.nameFold.value : this.nameFold,
      address: data.address.present ? data.address.value : this.address,
      defaultPrice: data.defaultPrice.present
          ? data.defaultPrice.value
          : this.defaultPrice,
      capacity: data.capacity.present ? data.capacity.value : this.capacity,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LotRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameFold: $nameFold, ')
          ..write('address: $address, ')
          ..write('defaultPrice: $defaultPrice, ')
          ..write('capacity: $capacity, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    nameFold,
    address,
    defaultPrice,
    capacity,
    notes,
    isActive,
    sortOrder,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LotRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameFold == this.nameFold &&
          other.address == this.address &&
          other.defaultPrice == this.defaultPrice &&
          other.capacity == this.capacity &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class LotsCompanion extends UpdateCompanion<LotRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> nameFold;
  final Value<String?> address;
  final Value<int> defaultPrice;
  final Value<int?> capacity;
  final Value<String?> notes;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const LotsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameFold = const Value.absent(),
    this.address = const Value.absent(),
    this.defaultPrice = const Value.absent(),
    this.capacity = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  LotsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String nameFold,
    this.address = const Value.absent(),
    this.defaultPrice = const Value.absent(),
    this.capacity = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
  }) : name = Value(name),
       nameFold = Value(nameFold),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LotRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nameFold,
    Expression<String>? address,
    Expression<int>? defaultPrice,
    Expression<int>? capacity,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameFold != null) 'name_fold': nameFold,
      if (address != null) 'address': address,
      if (defaultPrice != null) 'default_price': defaultPrice,
      if (capacity != null) 'capacity': capacity,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  LotsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? nameFold,
    Value<String?>? address,
    Value<int>? defaultPrice,
    Value<int?>? capacity,
    Value<String?>? notes,
    Value<bool>? isActive,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return LotsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameFold: nameFold ?? this.nameFold,
      address: address ?? this.address,
      defaultPrice: defaultPrice ?? this.defaultPrice,
      capacity: capacity ?? this.capacity,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
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
    if (nameFold.present) {
      map['name_fold'] = Variable<String>(nameFold.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (defaultPrice.present) {
      map['default_price'] = Variable<int>(defaultPrice.value);
    }
    if (capacity.present) {
      map['capacity'] = Variable<int>(capacity.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LotsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameFold: $nameFold, ')
          ..write('address: $address, ')
          ..write('defaultPrice: $defaultPrice, ')
          ..write('capacity: $capacity, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $VehiclesTable extends Vehicles
    with TableInfo<$VehiclesTable, VehicleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<int> lotId = GeneratedColumn<int>(
    'lot_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES lots (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _ownerNameMeta = const VerificationMeta(
    'ownerName',
  );
  @override
  late final GeneratedColumn<String> ownerName = GeneratedColumn<String>(
    'owner_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerNameFoldMeta = const VerificationMeta(
    'ownerNameFold',
  );
  @override
  late final GeneratedColumn<String> ownerNameFold = GeneratedColumn<String>(
    'owner_name_fold',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneDigitsMeta = const VerificationMeta(
    'phoneDigits',
  );
  @override
  late final GeneratedColumn<String> phoneDigits = GeneratedColumn<String>(
    'phone_digits',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<VehicleType, int> vehicleType =
      GeneratedColumn<int>(
        'vehicle_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<VehicleType>($VehiclesTable.$convertervehicleType);
  static const VerificationMeta _plateMeta = const VerificationMeta('plate');
  @override
  late final GeneratedColumn<String> plate = GeneratedColumn<String>(
    'plate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plateNormalizedMeta = const VerificationMeta(
    'plateNormalized',
  );
  @override
  late final GeneratedColumn<String> plateNormalized = GeneratedColumn<String>(
    'plate_normalized',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyPriceMeta = const VerificationMeta(
    'monthlyPrice',
  );
  @override
  late final GeneratedColumn<int> monthlyPrice = GeneratedColumn<int>(
    'monthly_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Day, DateTime> startDate =
      GeneratedColumn<DateTime>(
        'start_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      ).withConverter<Day>($VehiclesTable.$converterstartDate);
  static const VerificationMeta _anchorDayMeta = const VerificationMeta(
    'anchorDay',
  );
  @override
  late final GeneratedColumn<int> anchorDay = GeneratedColumn<int>(
    'anchor_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<VehicleStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<VehicleStatus>($VehiclesTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<Day?, DateTime> leftOn =
      GeneratedColumn<DateTime>(
        'left_on',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      ).withConverter<Day?>($VehiclesTable.$converterleftOnn);
  @override
  late final GeneratedColumnWithTypeConverter<Day?, DateTime> currentPeriodEnd =
      GeneratedColumn<DateTime>(
        'current_period_end',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      ).withConverter<Day?>($VehiclesTable.$convertercurrentPeriodEndn);
  @override
  late final GeneratedColumnWithTypeConverter<Day?, DateTime> lastPaymentDate =
      GeneratedColumn<DateTime>(
        'last_payment_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      ).withConverter<Day?>($VehiclesTable.$converterlastPaymentDaten);
  static const VerificationMeta _totalMonthsPaidMeta = const VerificationMeta(
    'totalMonthsPaid',
  );
  @override
  late final GeneratedColumn<int> totalMonthsPaid = GeneratedColumn<int>(
    'total_months_paid',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalPaidMeta = const VerificationMeta(
    'totalPaid',
  );
  @override
  late final GeneratedColumn<int> totalPaid = GeneratedColumn<int>(
    'total_paid',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastRemindedAtMeta = const VerificationMeta(
    'lastRemindedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastRemindedAt =
      GeneratedColumn<DateTime>(
        'last_reminded_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<Day?, DateTime>
  remindedForPeriodEnd = GeneratedColumn<DateTime>(
    'reminded_for_period_end',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  ).withConverter<Day?>($VehiclesTable.$converterremindedForPeriodEndn);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lotId,
    ownerName,
    ownerNameFold,
    phone,
    phoneDigits,
    vehicleType,
    plate,
    plateNormalized,
    monthlyPrice,
    startDate,
    anchorDay,
    status,
    leftOn,
    currentPeriodEnd,
    lastPaymentDate,
    totalMonthsPaid,
    totalPaid,
    lastRemindedAt,
    remindedForPeriodEnd,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehicleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lot_id')) {
      context.handle(
        _lotIdMeta,
        lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lotIdMeta);
    }
    if (data.containsKey('owner_name')) {
      context.handle(
        _ownerNameMeta,
        ownerName.isAcceptableOrUnknown(data['owner_name']!, _ownerNameMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerNameMeta);
    }
    if (data.containsKey('owner_name_fold')) {
      context.handle(
        _ownerNameFoldMeta,
        ownerNameFold.isAcceptableOrUnknown(
          data['owner_name_fold']!,
          _ownerNameFoldMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerNameFoldMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('phone_digits')) {
      context.handle(
        _phoneDigitsMeta,
        phoneDigits.isAcceptableOrUnknown(
          data['phone_digits']!,
          _phoneDigitsMeta,
        ),
      );
    }
    if (data.containsKey('plate')) {
      context.handle(
        _plateMeta,
        plate.isAcceptableOrUnknown(data['plate']!, _plateMeta),
      );
    } else if (isInserting) {
      context.missing(_plateMeta);
    }
    if (data.containsKey('plate_normalized')) {
      context.handle(
        _plateNormalizedMeta,
        plateNormalized.isAcceptableOrUnknown(
          data['plate_normalized']!,
          _plateNormalizedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plateNormalizedMeta);
    }
    if (data.containsKey('monthly_price')) {
      context.handle(
        _monthlyPriceMeta,
        monthlyPrice.isAcceptableOrUnknown(
          data['monthly_price']!,
          _monthlyPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthlyPriceMeta);
    }
    if (data.containsKey('anchor_day')) {
      context.handle(
        _anchorDayMeta,
        anchorDay.isAcceptableOrUnknown(data['anchor_day']!, _anchorDayMeta),
      );
    } else if (isInserting) {
      context.missing(_anchorDayMeta);
    }
    if (data.containsKey('total_months_paid')) {
      context.handle(
        _totalMonthsPaidMeta,
        totalMonthsPaid.isAcceptableOrUnknown(
          data['total_months_paid']!,
          _totalMonthsPaidMeta,
        ),
      );
    }
    if (data.containsKey('total_paid')) {
      context.handle(
        _totalPaidMeta,
        totalPaid.isAcceptableOrUnknown(data['total_paid']!, _totalPaidMeta),
      );
    }
    if (data.containsKey('last_reminded_at')) {
      context.handle(
        _lastRemindedAtMeta,
        lastRemindedAt.isAcceptableOrUnknown(
          data['last_reminded_at']!,
          _lastRemindedAtMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VehicleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehicleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lot_id'],
      )!,
      ownerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_name'],
      )!,
      ownerNameFold: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_name_fold'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      phoneDigits: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_digits'],
      ),
      vehicleType: $VehiclesTable.$convertervehicleType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}vehicle_type'],
        )!,
      ),
      plate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plate'],
      )!,
      plateNormalized: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plate_normalized'],
      )!,
      monthlyPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_price'],
      )!,
      startDate: $VehiclesTable.$converterstartDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}start_date'],
        )!,
      ),
      anchorDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anchor_day'],
      )!,
      status: $VehiclesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      leftOn: $VehiclesTable.$converterleftOnn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}left_on'],
        ),
      ),
      currentPeriodEnd: $VehiclesTable.$convertercurrentPeriodEndn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}current_period_end'],
        ),
      ),
      lastPaymentDate: $VehiclesTable.$converterlastPaymentDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}last_payment_date'],
        ),
      ),
      totalMonthsPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_months_paid'],
      )!,
      totalPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_paid'],
      )!,
      lastRemindedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reminded_at'],
      ),
      remindedForPeriodEnd: $VehiclesTable.$converterremindedForPeriodEndn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.dateTime,
              data['${effectivePrefix}reminded_for_period_end'],
            ),
          ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<VehicleType, int, int> $convertervehicleType =
      const EnumIndexConverter<VehicleType>(VehicleType.values);
  static JsonTypeConverter2<Day, DateTime, DateTime> $converterstartDate =
      const DayConverter();
  static JsonTypeConverter2<VehicleStatus, int, int> $converterstatus =
      const EnumIndexConverter<VehicleStatus>(VehicleStatus.values);
  static JsonTypeConverter2<Day, DateTime, DateTime> $converterleftOn =
      const DayConverter();
  static JsonTypeConverter2<Day?, DateTime?, DateTime?> $converterleftOnn =
      JsonTypeConverter2.asNullable($converterleftOn);
  static JsonTypeConverter2<Day, DateTime, DateTime>
  $convertercurrentPeriodEnd = const DayConverter();
  static JsonTypeConverter2<Day?, DateTime?, DateTime?>
  $convertercurrentPeriodEndn = JsonTypeConverter2.asNullable(
    $convertercurrentPeriodEnd,
  );
  static JsonTypeConverter2<Day, DateTime, DateTime> $converterlastPaymentDate =
      const DayConverter();
  static JsonTypeConverter2<Day?, DateTime?, DateTime?>
  $converterlastPaymentDaten = JsonTypeConverter2.asNullable(
    $converterlastPaymentDate,
  );
  static JsonTypeConverter2<Day, DateTime, DateTime>
  $converterremindedForPeriodEnd = const DayConverter();
  static JsonTypeConverter2<Day?, DateTime?, DateTime?>
  $converterremindedForPeriodEndn = JsonTypeConverter2.asNullable(
    $converterremindedForPeriodEnd,
  );
}

class VehicleRow extends DataClass implements Insertable<VehicleRow> {
  final int id;
  final int lotId;
  final String ownerName;

  /// `viFold(ownerName)` — để gõ "nguyen" tìm ra "Nguyễn".
  final String ownerNameFold;

  /// Số điện thoại đúng như người dùng gõ, ví dụ `0912 345 678`.
  final String? phone;

  /// Chỉ chữ số — dùng cho tìm kiếm và cho `tel:`.
  final String? phoneDigits;
  final VehicleType vehicleType;

  /// Biển số hiển thị, giữ nguyên định dạng người dùng gõ: `59A1-234.56`.
  final String plate;

  /// Biển số đã chuẩn hoá: `59A123456`. Dùng cho index chống trùng và tìm kiếm.
  final String plateNormalized;

  /// Giá thuê hiện hành, VND/tháng.
  final int monthlyPrice;
  final Day startDate;

  /// Ngày trong tháng của [startDate] gốc, 1..31.
  ///
  /// Neo chu kỳ vào ngày này thay vì vào ngày của kỳ trước, để cái kẹp ngày
  /// cuối tháng không bị dính vĩnh viễn: xe bắt đầu ngày 31 sau khi qua tháng 2
  /// phải quay lại ngày 31, chứ không tụt xuống 28 rồi ở đó mãi.
  final int anchorDay;
  final VehicleStatus status;

  /// Ngày xe rời bãi — "ngày kết thúc" trong đặc tả.
  final Day? leftOn;

  /// `MAX(payments.periodEnd)`. Là mốc **loại trừ**: hết hạn khi
  /// `today >= currentPeriodEnd`.
  final Day? currentPeriodEnd;
  final Day? lastPaymentDate;
  final int totalMonthsPaid;
  final int totalPaid;
  final DateTime? lastRemindedAt;

  /// Đã nhắc cho kỳ hạn nào. So sánh với [currentPeriodEnd] để dấu "đã nhắc"
  /// **tự xoá** khi xe được gia hạn — nếu không, người dùng sẽ tưởng đã nhắc
  /// rồi trong khi thực ra đó là lần nhắc của kỳ trước.
  final Day? remindedForPeriodEnd;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const VehicleRow({
    required this.id,
    required this.lotId,
    required this.ownerName,
    required this.ownerNameFold,
    this.phone,
    this.phoneDigits,
    required this.vehicleType,
    required this.plate,
    required this.plateNormalized,
    required this.monthlyPrice,
    required this.startDate,
    required this.anchorDay,
    required this.status,
    this.leftOn,
    this.currentPeriodEnd,
    this.lastPaymentDate,
    required this.totalMonthsPaid,
    required this.totalPaid,
    this.lastRemindedAt,
    this.remindedForPeriodEnd,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['lot_id'] = Variable<int>(lotId);
    map['owner_name'] = Variable<String>(ownerName);
    map['owner_name_fold'] = Variable<String>(ownerNameFold);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || phoneDigits != null) {
      map['phone_digits'] = Variable<String>(phoneDigits);
    }
    {
      map['vehicle_type'] = Variable<int>(
        $VehiclesTable.$convertervehicleType.toSql(vehicleType),
      );
    }
    map['plate'] = Variable<String>(plate);
    map['plate_normalized'] = Variable<String>(plateNormalized);
    map['monthly_price'] = Variable<int>(monthlyPrice);
    {
      map['start_date'] = Variable<DateTime>(
        $VehiclesTable.$converterstartDate.toSql(startDate),
      );
    }
    map['anchor_day'] = Variable<int>(anchorDay);
    {
      map['status'] = Variable<int>(
        $VehiclesTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || leftOn != null) {
      map['left_on'] = Variable<DateTime>(
        $VehiclesTable.$converterleftOnn.toSql(leftOn),
      );
    }
    if (!nullToAbsent || currentPeriodEnd != null) {
      map['current_period_end'] = Variable<DateTime>(
        $VehiclesTable.$convertercurrentPeriodEndn.toSql(currentPeriodEnd),
      );
    }
    if (!nullToAbsent || lastPaymentDate != null) {
      map['last_payment_date'] = Variable<DateTime>(
        $VehiclesTable.$converterlastPaymentDaten.toSql(lastPaymentDate),
      );
    }
    map['total_months_paid'] = Variable<int>(totalMonthsPaid);
    map['total_paid'] = Variable<int>(totalPaid);
    if (!nullToAbsent || lastRemindedAt != null) {
      map['last_reminded_at'] = Variable<DateTime>(lastRemindedAt);
    }
    if (!nullToAbsent || remindedForPeriodEnd != null) {
      map['reminded_for_period_end'] = Variable<DateTime>(
        $VehiclesTable.$converterremindedForPeriodEndn.toSql(
          remindedForPeriodEnd,
        ),
      );
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      id: Value(id),
      lotId: Value(lotId),
      ownerName: Value(ownerName),
      ownerNameFold: Value(ownerNameFold),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      phoneDigits: phoneDigits == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneDigits),
      vehicleType: Value(vehicleType),
      plate: Value(plate),
      plateNormalized: Value(plateNormalized),
      monthlyPrice: Value(monthlyPrice),
      startDate: Value(startDate),
      anchorDay: Value(anchorDay),
      status: Value(status),
      leftOn: leftOn == null && nullToAbsent
          ? const Value.absent()
          : Value(leftOn),
      currentPeriodEnd: currentPeriodEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(currentPeriodEnd),
      lastPaymentDate: lastPaymentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPaymentDate),
      totalMonthsPaid: Value(totalMonthsPaid),
      totalPaid: Value(totalPaid),
      lastRemindedAt: lastRemindedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRemindedAt),
      remindedForPeriodEnd: remindedForPeriodEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(remindedForPeriodEnd),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory VehicleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehicleRow(
      id: serializer.fromJson<int>(json['id']),
      lotId: serializer.fromJson<int>(json['lotId']),
      ownerName: serializer.fromJson<String>(json['ownerName']),
      ownerNameFold: serializer.fromJson<String>(json['ownerNameFold']),
      phone: serializer.fromJson<String?>(json['phone']),
      phoneDigits: serializer.fromJson<String?>(json['phoneDigits']),
      vehicleType: $VehiclesTable.$convertervehicleType.fromJson(
        serializer.fromJson<int>(json['vehicleType']),
      ),
      plate: serializer.fromJson<String>(json['plate']),
      plateNormalized: serializer.fromJson<String>(json['plateNormalized']),
      monthlyPrice: serializer.fromJson<int>(json['monthlyPrice']),
      startDate: $VehiclesTable.$converterstartDate.fromJson(
        serializer.fromJson<DateTime>(json['startDate']),
      ),
      anchorDay: serializer.fromJson<int>(json['anchorDay']),
      status: $VehiclesTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      leftOn: $VehiclesTable.$converterleftOnn.fromJson(
        serializer.fromJson<DateTime?>(json['leftOn']),
      ),
      currentPeriodEnd: $VehiclesTable.$convertercurrentPeriodEndn.fromJson(
        serializer.fromJson<DateTime?>(json['currentPeriodEnd']),
      ),
      lastPaymentDate: $VehiclesTable.$converterlastPaymentDaten.fromJson(
        serializer.fromJson<DateTime?>(json['lastPaymentDate']),
      ),
      totalMonthsPaid: serializer.fromJson<int>(json['totalMonthsPaid']),
      totalPaid: serializer.fromJson<int>(json['totalPaid']),
      lastRemindedAt: serializer.fromJson<DateTime?>(json['lastRemindedAt']),
      remindedForPeriodEnd: $VehiclesTable.$converterremindedForPeriodEndn
          .fromJson(
            serializer.fromJson<DateTime?>(json['remindedForPeriodEnd']),
          ),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lotId': serializer.toJson<int>(lotId),
      'ownerName': serializer.toJson<String>(ownerName),
      'ownerNameFold': serializer.toJson<String>(ownerNameFold),
      'phone': serializer.toJson<String?>(phone),
      'phoneDigits': serializer.toJson<String?>(phoneDigits),
      'vehicleType': serializer.toJson<int>(
        $VehiclesTable.$convertervehicleType.toJson(vehicleType),
      ),
      'plate': serializer.toJson<String>(plate),
      'plateNormalized': serializer.toJson<String>(plateNormalized),
      'monthlyPrice': serializer.toJson<int>(monthlyPrice),
      'startDate': serializer.toJson<DateTime>(
        $VehiclesTable.$converterstartDate.toJson(startDate),
      ),
      'anchorDay': serializer.toJson<int>(anchorDay),
      'status': serializer.toJson<int>(
        $VehiclesTable.$converterstatus.toJson(status),
      ),
      'leftOn': serializer.toJson<DateTime?>(
        $VehiclesTable.$converterleftOnn.toJson(leftOn),
      ),
      'currentPeriodEnd': serializer.toJson<DateTime?>(
        $VehiclesTable.$convertercurrentPeriodEndn.toJson(currentPeriodEnd),
      ),
      'lastPaymentDate': serializer.toJson<DateTime?>(
        $VehiclesTable.$converterlastPaymentDaten.toJson(lastPaymentDate),
      ),
      'totalMonthsPaid': serializer.toJson<int>(totalMonthsPaid),
      'totalPaid': serializer.toJson<int>(totalPaid),
      'lastRemindedAt': serializer.toJson<DateTime?>(lastRemindedAt),
      'remindedForPeriodEnd': serializer.toJson<DateTime?>(
        $VehiclesTable.$converterremindedForPeriodEndn.toJson(
          remindedForPeriodEnd,
        ),
      ),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  VehicleRow copyWith({
    int? id,
    int? lotId,
    String? ownerName,
    String? ownerNameFold,
    Value<String?> phone = const Value.absent(),
    Value<String?> phoneDigits = const Value.absent(),
    VehicleType? vehicleType,
    String? plate,
    String? plateNormalized,
    int? monthlyPrice,
    Day? startDate,
    int? anchorDay,
    VehicleStatus? status,
    Value<Day?> leftOn = const Value.absent(),
    Value<Day?> currentPeriodEnd = const Value.absent(),
    Value<Day?> lastPaymentDate = const Value.absent(),
    int? totalMonthsPaid,
    int? totalPaid,
    Value<DateTime?> lastRemindedAt = const Value.absent(),
    Value<Day?> remindedForPeriodEnd = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => VehicleRow(
    id: id ?? this.id,
    lotId: lotId ?? this.lotId,
    ownerName: ownerName ?? this.ownerName,
    ownerNameFold: ownerNameFold ?? this.ownerNameFold,
    phone: phone.present ? phone.value : this.phone,
    phoneDigits: phoneDigits.present ? phoneDigits.value : this.phoneDigits,
    vehicleType: vehicleType ?? this.vehicleType,
    plate: plate ?? this.plate,
    plateNormalized: plateNormalized ?? this.plateNormalized,
    monthlyPrice: monthlyPrice ?? this.monthlyPrice,
    startDate: startDate ?? this.startDate,
    anchorDay: anchorDay ?? this.anchorDay,
    status: status ?? this.status,
    leftOn: leftOn.present ? leftOn.value : this.leftOn,
    currentPeriodEnd: currentPeriodEnd.present
        ? currentPeriodEnd.value
        : this.currentPeriodEnd,
    lastPaymentDate: lastPaymentDate.present
        ? lastPaymentDate.value
        : this.lastPaymentDate,
    totalMonthsPaid: totalMonthsPaid ?? this.totalMonthsPaid,
    totalPaid: totalPaid ?? this.totalPaid,
    lastRemindedAt: lastRemindedAt.present
        ? lastRemindedAt.value
        : this.lastRemindedAt,
    remindedForPeriodEnd: remindedForPeriodEnd.present
        ? remindedForPeriodEnd.value
        : this.remindedForPeriodEnd,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  VehicleRow copyWithCompanion(VehiclesCompanion data) {
    return VehicleRow(
      id: data.id.present ? data.id.value : this.id,
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      ownerName: data.ownerName.present ? data.ownerName.value : this.ownerName,
      ownerNameFold: data.ownerNameFold.present
          ? data.ownerNameFold.value
          : this.ownerNameFold,
      phone: data.phone.present ? data.phone.value : this.phone,
      phoneDigits: data.phoneDigits.present
          ? data.phoneDigits.value
          : this.phoneDigits,
      vehicleType: data.vehicleType.present
          ? data.vehicleType.value
          : this.vehicleType,
      plate: data.plate.present ? data.plate.value : this.plate,
      plateNormalized: data.plateNormalized.present
          ? data.plateNormalized.value
          : this.plateNormalized,
      monthlyPrice: data.monthlyPrice.present
          ? data.monthlyPrice.value
          : this.monthlyPrice,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      anchorDay: data.anchorDay.present ? data.anchorDay.value : this.anchorDay,
      status: data.status.present ? data.status.value : this.status,
      leftOn: data.leftOn.present ? data.leftOn.value : this.leftOn,
      currentPeriodEnd: data.currentPeriodEnd.present
          ? data.currentPeriodEnd.value
          : this.currentPeriodEnd,
      lastPaymentDate: data.lastPaymentDate.present
          ? data.lastPaymentDate.value
          : this.lastPaymentDate,
      totalMonthsPaid: data.totalMonthsPaid.present
          ? data.totalMonthsPaid.value
          : this.totalMonthsPaid,
      totalPaid: data.totalPaid.present ? data.totalPaid.value : this.totalPaid,
      lastRemindedAt: data.lastRemindedAt.present
          ? data.lastRemindedAt.value
          : this.lastRemindedAt,
      remindedForPeriodEnd: data.remindedForPeriodEnd.present
          ? data.remindedForPeriodEnd.value
          : this.remindedForPeriodEnd,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehicleRow(')
          ..write('id: $id, ')
          ..write('lotId: $lotId, ')
          ..write('ownerName: $ownerName, ')
          ..write('ownerNameFold: $ownerNameFold, ')
          ..write('phone: $phone, ')
          ..write('phoneDigits: $phoneDigits, ')
          ..write('vehicleType: $vehicleType, ')
          ..write('plate: $plate, ')
          ..write('plateNormalized: $plateNormalized, ')
          ..write('monthlyPrice: $monthlyPrice, ')
          ..write('startDate: $startDate, ')
          ..write('anchorDay: $anchorDay, ')
          ..write('status: $status, ')
          ..write('leftOn: $leftOn, ')
          ..write('currentPeriodEnd: $currentPeriodEnd, ')
          ..write('lastPaymentDate: $lastPaymentDate, ')
          ..write('totalMonthsPaid: $totalMonthsPaid, ')
          ..write('totalPaid: $totalPaid, ')
          ..write('lastRemindedAt: $lastRemindedAt, ')
          ..write('remindedForPeriodEnd: $remindedForPeriodEnd, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    lotId,
    ownerName,
    ownerNameFold,
    phone,
    phoneDigits,
    vehicleType,
    plate,
    plateNormalized,
    monthlyPrice,
    startDate,
    anchorDay,
    status,
    leftOn,
    currentPeriodEnd,
    lastPaymentDate,
    totalMonthsPaid,
    totalPaid,
    lastRemindedAt,
    remindedForPeriodEnd,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehicleRow &&
          other.id == this.id &&
          other.lotId == this.lotId &&
          other.ownerName == this.ownerName &&
          other.ownerNameFold == this.ownerNameFold &&
          other.phone == this.phone &&
          other.phoneDigits == this.phoneDigits &&
          other.vehicleType == this.vehicleType &&
          other.plate == this.plate &&
          other.plateNormalized == this.plateNormalized &&
          other.monthlyPrice == this.monthlyPrice &&
          other.startDate == this.startDate &&
          other.anchorDay == this.anchorDay &&
          other.status == this.status &&
          other.leftOn == this.leftOn &&
          other.currentPeriodEnd == this.currentPeriodEnd &&
          other.lastPaymentDate == this.lastPaymentDate &&
          other.totalMonthsPaid == this.totalMonthsPaid &&
          other.totalPaid == this.totalPaid &&
          other.lastRemindedAt == this.lastRemindedAt &&
          other.remindedForPeriodEnd == this.remindedForPeriodEnd &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class VehiclesCompanion extends UpdateCompanion<VehicleRow> {
  final Value<int> id;
  final Value<int> lotId;
  final Value<String> ownerName;
  final Value<String> ownerNameFold;
  final Value<String?> phone;
  final Value<String?> phoneDigits;
  final Value<VehicleType> vehicleType;
  final Value<String> plate;
  final Value<String> plateNormalized;
  final Value<int> monthlyPrice;
  final Value<Day> startDate;
  final Value<int> anchorDay;
  final Value<VehicleStatus> status;
  final Value<Day?> leftOn;
  final Value<Day?> currentPeriodEnd;
  final Value<Day?> lastPaymentDate;
  final Value<int> totalMonthsPaid;
  final Value<int> totalPaid;
  final Value<DateTime?> lastRemindedAt;
  final Value<Day?> remindedForPeriodEnd;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const VehiclesCompanion({
    this.id = const Value.absent(),
    this.lotId = const Value.absent(),
    this.ownerName = const Value.absent(),
    this.ownerNameFold = const Value.absent(),
    this.phone = const Value.absent(),
    this.phoneDigits = const Value.absent(),
    this.vehicleType = const Value.absent(),
    this.plate = const Value.absent(),
    this.plateNormalized = const Value.absent(),
    this.monthlyPrice = const Value.absent(),
    this.startDate = const Value.absent(),
    this.anchorDay = const Value.absent(),
    this.status = const Value.absent(),
    this.leftOn = const Value.absent(),
    this.currentPeriodEnd = const Value.absent(),
    this.lastPaymentDate = const Value.absent(),
    this.totalMonthsPaid = const Value.absent(),
    this.totalPaid = const Value.absent(),
    this.lastRemindedAt = const Value.absent(),
    this.remindedForPeriodEnd = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  VehiclesCompanion.insert({
    this.id = const Value.absent(),
    required int lotId,
    required String ownerName,
    required String ownerNameFold,
    this.phone = const Value.absent(),
    this.phoneDigits = const Value.absent(),
    required VehicleType vehicleType,
    required String plate,
    required String plateNormalized,
    required int monthlyPrice,
    required Day startDate,
    required int anchorDay,
    this.status = const Value.absent(),
    this.leftOn = const Value.absent(),
    this.currentPeriodEnd = const Value.absent(),
    this.lastPaymentDate = const Value.absent(),
    this.totalMonthsPaid = const Value.absent(),
    this.totalPaid = const Value.absent(),
    this.lastRemindedAt = const Value.absent(),
    this.remindedForPeriodEnd = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
  }) : lotId = Value(lotId),
       ownerName = Value(ownerName),
       ownerNameFold = Value(ownerNameFold),
       vehicleType = Value(vehicleType),
       plate = Value(plate),
       plateNormalized = Value(plateNormalized),
       monthlyPrice = Value(monthlyPrice),
       startDate = Value(startDate),
       anchorDay = Value(anchorDay),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<VehicleRow> custom({
    Expression<int>? id,
    Expression<int>? lotId,
    Expression<String>? ownerName,
    Expression<String>? ownerNameFold,
    Expression<String>? phone,
    Expression<String>? phoneDigits,
    Expression<int>? vehicleType,
    Expression<String>? plate,
    Expression<String>? plateNormalized,
    Expression<int>? monthlyPrice,
    Expression<DateTime>? startDate,
    Expression<int>? anchorDay,
    Expression<int>? status,
    Expression<DateTime>? leftOn,
    Expression<DateTime>? currentPeriodEnd,
    Expression<DateTime>? lastPaymentDate,
    Expression<int>? totalMonthsPaid,
    Expression<int>? totalPaid,
    Expression<DateTime>? lastRemindedAt,
    Expression<DateTime>? remindedForPeriodEnd,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lotId != null) 'lot_id': lotId,
      if (ownerName != null) 'owner_name': ownerName,
      if (ownerNameFold != null) 'owner_name_fold': ownerNameFold,
      if (phone != null) 'phone': phone,
      if (phoneDigits != null) 'phone_digits': phoneDigits,
      if (vehicleType != null) 'vehicle_type': vehicleType,
      if (plate != null) 'plate': plate,
      if (plateNormalized != null) 'plate_normalized': plateNormalized,
      if (monthlyPrice != null) 'monthly_price': monthlyPrice,
      if (startDate != null) 'start_date': startDate,
      if (anchorDay != null) 'anchor_day': anchorDay,
      if (status != null) 'status': status,
      if (leftOn != null) 'left_on': leftOn,
      if (currentPeriodEnd != null) 'current_period_end': currentPeriodEnd,
      if (lastPaymentDate != null) 'last_payment_date': lastPaymentDate,
      if (totalMonthsPaid != null) 'total_months_paid': totalMonthsPaid,
      if (totalPaid != null) 'total_paid': totalPaid,
      if (lastRemindedAt != null) 'last_reminded_at': lastRemindedAt,
      if (remindedForPeriodEnd != null)
        'reminded_for_period_end': remindedForPeriodEnd,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  VehiclesCompanion copyWith({
    Value<int>? id,
    Value<int>? lotId,
    Value<String>? ownerName,
    Value<String>? ownerNameFold,
    Value<String?>? phone,
    Value<String?>? phoneDigits,
    Value<VehicleType>? vehicleType,
    Value<String>? plate,
    Value<String>? plateNormalized,
    Value<int>? monthlyPrice,
    Value<Day>? startDate,
    Value<int>? anchorDay,
    Value<VehicleStatus>? status,
    Value<Day?>? leftOn,
    Value<Day?>? currentPeriodEnd,
    Value<Day?>? lastPaymentDate,
    Value<int>? totalMonthsPaid,
    Value<int>? totalPaid,
    Value<DateTime?>? lastRemindedAt,
    Value<Day?>? remindedForPeriodEnd,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return VehiclesCompanion(
      id: id ?? this.id,
      lotId: lotId ?? this.lotId,
      ownerName: ownerName ?? this.ownerName,
      ownerNameFold: ownerNameFold ?? this.ownerNameFold,
      phone: phone ?? this.phone,
      phoneDigits: phoneDigits ?? this.phoneDigits,
      vehicleType: vehicleType ?? this.vehicleType,
      plate: plate ?? this.plate,
      plateNormalized: plateNormalized ?? this.plateNormalized,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      startDate: startDate ?? this.startDate,
      anchorDay: anchorDay ?? this.anchorDay,
      status: status ?? this.status,
      leftOn: leftOn ?? this.leftOn,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      totalMonthsPaid: totalMonthsPaid ?? this.totalMonthsPaid,
      totalPaid: totalPaid ?? this.totalPaid,
      lastRemindedAt: lastRemindedAt ?? this.lastRemindedAt,
      remindedForPeriodEnd: remindedForPeriodEnd ?? this.remindedForPeriodEnd,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lotId.present) {
      map['lot_id'] = Variable<int>(lotId.value);
    }
    if (ownerName.present) {
      map['owner_name'] = Variable<String>(ownerName.value);
    }
    if (ownerNameFold.present) {
      map['owner_name_fold'] = Variable<String>(ownerNameFold.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (phoneDigits.present) {
      map['phone_digits'] = Variable<String>(phoneDigits.value);
    }
    if (vehicleType.present) {
      map['vehicle_type'] = Variable<int>(
        $VehiclesTable.$convertervehicleType.toSql(vehicleType.value),
      );
    }
    if (plate.present) {
      map['plate'] = Variable<String>(plate.value);
    }
    if (plateNormalized.present) {
      map['plate_normalized'] = Variable<String>(plateNormalized.value);
    }
    if (monthlyPrice.present) {
      map['monthly_price'] = Variable<int>(monthlyPrice.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(
        $VehiclesTable.$converterstartDate.toSql(startDate.value),
      );
    }
    if (anchorDay.present) {
      map['anchor_day'] = Variable<int>(anchorDay.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $VehiclesTable.$converterstatus.toSql(status.value),
      );
    }
    if (leftOn.present) {
      map['left_on'] = Variable<DateTime>(
        $VehiclesTable.$converterleftOnn.toSql(leftOn.value),
      );
    }
    if (currentPeriodEnd.present) {
      map['current_period_end'] = Variable<DateTime>(
        $VehiclesTable.$convertercurrentPeriodEndn.toSql(
          currentPeriodEnd.value,
        ),
      );
    }
    if (lastPaymentDate.present) {
      map['last_payment_date'] = Variable<DateTime>(
        $VehiclesTable.$converterlastPaymentDaten.toSql(lastPaymentDate.value),
      );
    }
    if (totalMonthsPaid.present) {
      map['total_months_paid'] = Variable<int>(totalMonthsPaid.value);
    }
    if (totalPaid.present) {
      map['total_paid'] = Variable<int>(totalPaid.value);
    }
    if (lastRemindedAt.present) {
      map['last_reminded_at'] = Variable<DateTime>(lastRemindedAt.value);
    }
    if (remindedForPeriodEnd.present) {
      map['reminded_for_period_end'] = Variable<DateTime>(
        $VehiclesTable.$converterremindedForPeriodEndn.toSql(
          remindedForPeriodEnd.value,
        ),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCompanion(')
          ..write('id: $id, ')
          ..write('lotId: $lotId, ')
          ..write('ownerName: $ownerName, ')
          ..write('ownerNameFold: $ownerNameFold, ')
          ..write('phone: $phone, ')
          ..write('phoneDigits: $phoneDigits, ')
          ..write('vehicleType: $vehicleType, ')
          ..write('plate: $plate, ')
          ..write('plateNormalized: $plateNormalized, ')
          ..write('monthlyPrice: $monthlyPrice, ')
          ..write('startDate: $startDate, ')
          ..write('anchorDay: $anchorDay, ')
          ..write('status: $status, ')
          ..write('leftOn: $leftOn, ')
          ..write('currentPeriodEnd: $currentPeriodEnd, ')
          ..write('lastPaymentDate: $lastPaymentDate, ')
          ..write('totalMonthsPaid: $totalMonthsPaid, ')
          ..write('totalPaid: $totalPaid, ')
          ..write('lastRemindedAt: $lastRemindedAt, ')
          ..write('remindedForPeriodEnd: $remindedForPeriodEnd, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments
    with TableInfo<$PaymentsTable, PaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<int> lotId = GeneratedColumn<int>(
    'lot_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES lots (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthsPaidMeta = const VerificationMeta(
    'monthsPaid',
  );
  @override
  late final GeneratedColumn<int> monthsPaid = GeneratedColumn<int>(
    'months_paid',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<int> unitPrice = GeneratedColumn<int>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Day, DateTime> paidAt =
      GeneratedColumn<DateTime>(
        'paid_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      ).withConverter<Day>($PaymentsTable.$converterpaidAt);
  @override
  late final GeneratedColumnWithTypeConverter<Day, DateTime> periodStart =
      GeneratedColumn<DateTime>(
        'period_start',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      ).withConverter<Day>($PaymentsTable.$converterperiodStart);
  @override
  late final GeneratedColumnWithTypeConverter<Day, DateTime> periodEnd =
      GeneratedColumn<DateTime>(
        'period_end',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      ).withConverter<Day>($PaymentsTable.$converterperiodEnd);
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMethod, int> method =
      GeneratedColumn<int>(
        'method',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<PaymentMethod>($PaymentsTable.$convertermethod);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidedAtMeta = const VerificationMeta(
    'voidedAt',
  );
  @override
  late final GeneratedColumn<DateTime> voidedAt = GeneratedColumn<DateTime>(
    'voided_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
    vehicleId,
    lotId,
    amount,
    monthsPaid,
    unitPrice,
    paidAt,
    periodStart,
    periodEnd,
    method,
    note,
    voidedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('lot_id')) {
      context.handle(
        _lotIdMeta,
        lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lotIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('months_paid')) {
      context.handle(
        _monthsPaidMeta,
        monthsPaid.isAcceptableOrUnknown(data['months_paid']!, _monthsPaidMeta),
      );
    } else if (isInserting) {
      context.missing(_monthsPaidMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('voided_at')) {
      context.handle(
        _voidedAtMeta,
        voidedAt.isAcceptableOrUnknown(data['voided_at']!, _voidedAtMeta),
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
  PaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
      lotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lot_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      monthsPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}months_paid'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price'],
      )!,
      paidAt: $PaymentsTable.$converterpaidAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}paid_at'],
        )!,
      ),
      periodStart: $PaymentsTable.$converterperiodStart.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}period_start'],
        )!,
      ),
      periodEnd: $PaymentsTable.$converterperiodEnd.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}period_end'],
        )!,
      ),
      method: $PaymentsTable.$convertermethod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}method'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      voidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}voided_at'],
      ),
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
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Day, DateTime, DateTime> $converterpaidAt =
      const DayConverter();
  static JsonTypeConverter2<Day, DateTime, DateTime> $converterperiodStart =
      const DayConverter();
  static JsonTypeConverter2<Day, DateTime, DateTime> $converterperiodEnd =
      const DayConverter();
  static JsonTypeConverter2<PaymentMethod, int, int> $convertermethod =
      const EnumIndexConverter<PaymentMethod>(PaymentMethod.values);
}

class PaymentRow extends DataClass implements Insertable<PaymentRow> {
  final int id;
  final int vehicleId;

  /// **Ảnh chụp** bãi tại thời điểm thu tiền, không phải bãi hiện tại của xe.
  ///
  /// Không có cột này thì chuyển một xe từ Bãi A sang Bãi B sẽ **viết lại quá
  /// khứ** doanh thu của Bãi A. Báo cáo tài chính theo bãi phải là lịch sử bất
  /// biến.
  final int lotId;

  /// Tổng số tiền thực nhận, VND.
  final int amount;

  /// Số tháng đóng, >= 1.
  final int monthsPaid;

  /// **Ảnh chụp** đơn giá tại thời điểm thu. Tăng giá bãi không được làm đổi
  /// nội dung biên lai cũ. Ngoài ra khi `amount != monthsPaid * unitPrice` thì
  /// đó là trường hợp bớt giá / làm tròn cho khách, đọc ra được ngay, chứ
  /// không phải một lỗi dữ liệu bí ẩn.
  final int unitPrice;

  /// Ngày thu tiền — nguồn của **doanh thu thực thu**.
  final Day paidAt;
  final Day periodStart;

  /// Mốc kết thúc **loại trừ** — ngày đầu tiên không còn được bao phủ.
  /// Đóng 3 tháng từ 01/08/2026 thì giá trị này là 01/11/2026, đúng như câu
  /// "hết hạn 01/11/2026" của đặc tả. Nhờ loại trừ, `periodStart` của lần đóng
  /// kế tiếp **chính là** giá trị này, không cộng trừ 1 ngày ở đâu cả.
  final Day periodEnd;
  final PaymentMethod method;
  final String? note;

  /// Huỷ mềm thay vì xoá cứng. Chủ bãi bấm nhầm một biên lai vài triệu thì cần
  /// dấu vết để hoàn tác, và nhật ký thao tác thành vô nghĩa nếu bản ghi được
  /// tham chiếu biến mất. Mọi truy vấn doanh thu lọc `voidedAt IS NULL`.
  final DateTime? voidedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PaymentRow({
    required this.id,
    required this.vehicleId,
    required this.lotId,
    required this.amount,
    required this.monthsPaid,
    required this.unitPrice,
    required this.paidAt,
    required this.periodStart,
    required this.periodEnd,
    required this.method,
    this.note,
    this.voidedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['lot_id'] = Variable<int>(lotId);
    map['amount'] = Variable<int>(amount);
    map['months_paid'] = Variable<int>(monthsPaid);
    map['unit_price'] = Variable<int>(unitPrice);
    {
      map['paid_at'] = Variable<DateTime>(
        $PaymentsTable.$converterpaidAt.toSql(paidAt),
      );
    }
    {
      map['period_start'] = Variable<DateTime>(
        $PaymentsTable.$converterperiodStart.toSql(periodStart),
      );
    }
    {
      map['period_end'] = Variable<DateTime>(
        $PaymentsTable.$converterperiodEnd.toSql(periodEnd),
      );
    }
    {
      map['method'] = Variable<int>(
        $PaymentsTable.$convertermethod.toSql(method),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || voidedAt != null) {
      map['voided_at'] = Variable<DateTime>(voidedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      lotId: Value(lotId),
      amount: Value(amount),
      monthsPaid: Value(monthsPaid),
      unitPrice: Value(unitPrice),
      paidAt: Value(paidAt),
      periodStart: Value(periodStart),
      periodEnd: Value(periodEnd),
      method: Value(method),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      voidedAt: voidedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PaymentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentRow(
      id: serializer.fromJson<int>(json['id']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      lotId: serializer.fromJson<int>(json['lotId']),
      amount: serializer.fromJson<int>(json['amount']),
      monthsPaid: serializer.fromJson<int>(json['monthsPaid']),
      unitPrice: serializer.fromJson<int>(json['unitPrice']),
      paidAt: $PaymentsTable.$converterpaidAt.fromJson(
        serializer.fromJson<DateTime>(json['paidAt']),
      ),
      periodStart: $PaymentsTable.$converterperiodStart.fromJson(
        serializer.fromJson<DateTime>(json['periodStart']),
      ),
      periodEnd: $PaymentsTable.$converterperiodEnd.fromJson(
        serializer.fromJson<DateTime>(json['periodEnd']),
      ),
      method: $PaymentsTable.$convertermethod.fromJson(
        serializer.fromJson<int>(json['method']),
      ),
      note: serializer.fromJson<String?>(json['note']),
      voidedAt: serializer.fromJson<DateTime?>(json['voidedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'lotId': serializer.toJson<int>(lotId),
      'amount': serializer.toJson<int>(amount),
      'monthsPaid': serializer.toJson<int>(monthsPaid),
      'unitPrice': serializer.toJson<int>(unitPrice),
      'paidAt': serializer.toJson<DateTime>(
        $PaymentsTable.$converterpaidAt.toJson(paidAt),
      ),
      'periodStart': serializer.toJson<DateTime>(
        $PaymentsTable.$converterperiodStart.toJson(periodStart),
      ),
      'periodEnd': serializer.toJson<DateTime>(
        $PaymentsTable.$converterperiodEnd.toJson(periodEnd),
      ),
      'method': serializer.toJson<int>(
        $PaymentsTable.$convertermethod.toJson(method),
      ),
      'note': serializer.toJson<String?>(note),
      'voidedAt': serializer.toJson<DateTime?>(voidedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PaymentRow copyWith({
    int? id,
    int? vehicleId,
    int? lotId,
    int? amount,
    int? monthsPaid,
    int? unitPrice,
    Day? paidAt,
    Day? periodStart,
    Day? periodEnd,
    PaymentMethod? method,
    Value<String?> note = const Value.absent(),
    Value<DateTime?> voidedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PaymentRow(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    lotId: lotId ?? this.lotId,
    amount: amount ?? this.amount,
    monthsPaid: monthsPaid ?? this.monthsPaid,
    unitPrice: unitPrice ?? this.unitPrice,
    paidAt: paidAt ?? this.paidAt,
    periodStart: periodStart ?? this.periodStart,
    periodEnd: periodEnd ?? this.periodEnd,
    method: method ?? this.method,
    note: note.present ? note.value : this.note,
    voidedAt: voidedAt.present ? voidedAt.value : this.voidedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PaymentRow copyWithCompanion(PaymentsCompanion data) {
    return PaymentRow(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      amount: data.amount.present ? data.amount.value : this.amount,
      monthsPaid: data.monthsPaid.present
          ? data.monthsPaid.value
          : this.monthsPaid,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
      periodStart: data.periodStart.present
          ? data.periodStart.value
          : this.periodStart,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
      method: data.method.present ? data.method.value : this.method,
      note: data.note.present ? data.note.value : this.note,
      voidedAt: data.voidedAt.present ? data.voidedAt.value : this.voidedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentRow(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('lotId: $lotId, ')
          ..write('amount: $amount, ')
          ..write('monthsPaid: $monthsPaid, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('paidAt: $paidAt, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('method: $method, ')
          ..write('note: $note, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vehicleId,
    lotId,
    amount,
    monthsPaid,
    unitPrice,
    paidAt,
    periodStart,
    periodEnd,
    method,
    note,
    voidedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentRow &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.lotId == this.lotId &&
          other.amount == this.amount &&
          other.monthsPaid == this.monthsPaid &&
          other.unitPrice == this.unitPrice &&
          other.paidAt == this.paidAt &&
          other.periodStart == this.periodStart &&
          other.periodEnd == this.periodEnd &&
          other.method == this.method &&
          other.note == this.note &&
          other.voidedAt == this.voidedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PaymentsCompanion extends UpdateCompanion<PaymentRow> {
  final Value<int> id;
  final Value<int> vehicleId;
  final Value<int> lotId;
  final Value<int> amount;
  final Value<int> monthsPaid;
  final Value<int> unitPrice;
  final Value<Day> paidAt;
  final Value<Day> periodStart;
  final Value<Day> periodEnd;
  final Value<PaymentMethod> method;
  final Value<String?> note;
  final Value<DateTime?> voidedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.lotId = const Value.absent(),
    this.amount = const Value.absent(),
    this.monthsPaid = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.method = const Value.absent(),
    this.note = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int vehicleId,
    required int lotId,
    required int amount,
    required int monthsPaid,
    required int unitPrice,
    required Day paidAt,
    required Day periodStart,
    required Day periodEnd,
    this.method = const Value.absent(),
    this.note = const Value.absent(),
    this.voidedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : vehicleId = Value(vehicleId),
       lotId = Value(lotId),
       amount = Value(amount),
       monthsPaid = Value(monthsPaid),
       unitPrice = Value(unitPrice),
       paidAt = Value(paidAt),
       periodStart = Value(periodStart),
       periodEnd = Value(periodEnd),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PaymentRow> custom({
    Expression<int>? id,
    Expression<int>? vehicleId,
    Expression<int>? lotId,
    Expression<int>? amount,
    Expression<int>? monthsPaid,
    Expression<int>? unitPrice,
    Expression<DateTime>? paidAt,
    Expression<DateTime>? periodStart,
    Expression<DateTime>? periodEnd,
    Expression<int>? method,
    Expression<String>? note,
    Expression<DateTime>? voidedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (lotId != null) 'lot_id': lotId,
      if (amount != null) 'amount': amount,
      if (monthsPaid != null) 'months_paid': monthsPaid,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (paidAt != null) 'paid_at': paidAt,
      if (periodStart != null) 'period_start': periodStart,
      if (periodEnd != null) 'period_end': periodEnd,
      if (method != null) 'method': method,
      if (note != null) 'note': note,
      if (voidedAt != null) 'voided_at': voidedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PaymentsCompanion copyWith({
    Value<int>? id,
    Value<int>? vehicleId,
    Value<int>? lotId,
    Value<int>? amount,
    Value<int>? monthsPaid,
    Value<int>? unitPrice,
    Value<Day>? paidAt,
    Value<Day>? periodStart,
    Value<Day>? periodEnd,
    Value<PaymentMethod>? method,
    Value<String?>? note,
    Value<DateTime?>? voidedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      lotId: lotId ?? this.lotId,
      amount: amount ?? this.amount,
      monthsPaid: monthsPaid ?? this.monthsPaid,
      unitPrice: unitPrice ?? this.unitPrice,
      paidAt: paidAt ?? this.paidAt,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      method: method ?? this.method,
      note: note ?? this.note,
      voidedAt: voidedAt ?? this.voidedAt,
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
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (lotId.present) {
      map['lot_id'] = Variable<int>(lotId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (monthsPaid.present) {
      map['months_paid'] = Variable<int>(monthsPaid.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<int>(unitPrice.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(
        $PaymentsTable.$converterpaidAt.toSql(paidAt.value),
      );
    }
    if (periodStart.present) {
      map['period_start'] = Variable<DateTime>(
        $PaymentsTable.$converterperiodStart.toSql(periodStart.value),
      );
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<DateTime>(
        $PaymentsTable.$converterperiodEnd.toSql(periodEnd.value),
      );
    }
    if (method.present) {
      map['method'] = Variable<int>(
        $PaymentsTable.$convertermethod.toSql(method.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (voidedAt.present) {
      map['voided_at'] = Variable<DateTime>(voidedAt.value);
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
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('lotId: $lotId, ')
          ..write('amount: $amount, ')
          ..write('monthsPaid: $monthsPaid, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('paidAt: $paidAt, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('method: $method, ')
          ..write('note: $note, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PaymentAllocationsTable extends PaymentAllocations
    with TableInfo<$PaymentAllocationsTable, PaymentAllocationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentAllocationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _paymentIdMeta = const VerificationMeta(
    'paymentId',
  );
  @override
  late final GeneratedColumn<int> paymentId = GeneratedColumn<int>(
    'payment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES payments (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<int> lotId = GeneratedColumn<int>(
    'lot_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodMonthMeta = const VerificationMeta(
    'periodMonth',
  );
  @override
  late final GeneratedColumn<String> periodMonth = GeneratedColumn<String>(
    'period_month',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 7,
      maxTextLength: 7,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Day, DateTime> periodMonthStart =
      GeneratedColumn<DateTime>(
        'period_month_start',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      ).withConverter<Day>($PaymentAllocationsTable.$converterperiodMonthStart);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    paymentId,
    lotId,
    vehicleId,
    periodMonth,
    periodMonthStart,
    amount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payment_allocations';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentAllocationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('payment_id')) {
      context.handle(
        _paymentIdMeta,
        paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_paymentIdMeta);
    }
    if (data.containsKey('lot_id')) {
      context.handle(
        _lotIdMeta,
        lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lotIdMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('period_month')) {
      context.handle(
        _periodMonthMeta,
        periodMonth.isAcceptableOrUnknown(
          data['period_month']!,
          _periodMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodMonthMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {paymentId, periodMonth},
  ];
  @override
  PaymentAllocationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentAllocationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_id'],
      )!,
      lotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lot_id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
      periodMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_month'],
      )!,
      periodMonthStart: $PaymentAllocationsTable.$converterperiodMonthStart
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.dateTime,
              data['${effectivePrefix}period_month_start'],
            )!,
          ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
    );
  }

  @override
  $PaymentAllocationsTable createAlias(String alias) {
    return $PaymentAllocationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Day, DateTime, DateTime>
  $converterperiodMonthStart = const DayConverter();
}

class PaymentAllocationRow extends DataClass
    implements Insertable<PaymentAllocationRow> {
  final int id;
  final int paymentId;

  /// Sao chép để `GROUP BY` theo bãi không cần join.
  final int lotId;
  final int vehicleId;

  /// Tháng kế toán `YYYY-MM`. Lưu chuỗi vì nó sắp xếp theo thứ tự từ điển đúng
  /// bằng thứ tự thời gian, nên `BETWEEN` và `ORDER BY` chạy thẳng trên index.
  final String periodMonth;

  /// Ngày đầu tháng — trục hoành của biểu đồ xu hướng.
  final Day periodMonthStart;
  final int amount;
  const PaymentAllocationRow({
    required this.id,
    required this.paymentId,
    required this.lotId,
    required this.vehicleId,
    required this.periodMonth,
    required this.periodMonthStart,
    required this.amount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['payment_id'] = Variable<int>(paymentId);
    map['lot_id'] = Variable<int>(lotId);
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['period_month'] = Variable<String>(periodMonth);
    {
      map['period_month_start'] = Variable<DateTime>(
        $PaymentAllocationsTable.$converterperiodMonthStart.toSql(
          periodMonthStart,
        ),
      );
    }
    map['amount'] = Variable<int>(amount);
    return map;
  }

  PaymentAllocationsCompanion toCompanion(bool nullToAbsent) {
    return PaymentAllocationsCompanion(
      id: Value(id),
      paymentId: Value(paymentId),
      lotId: Value(lotId),
      vehicleId: Value(vehicleId),
      periodMonth: Value(periodMonth),
      periodMonthStart: Value(periodMonthStart),
      amount: Value(amount),
    );
  }

  factory PaymentAllocationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentAllocationRow(
      id: serializer.fromJson<int>(json['id']),
      paymentId: serializer.fromJson<int>(json['paymentId']),
      lotId: serializer.fromJson<int>(json['lotId']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      periodMonth: serializer.fromJson<String>(json['periodMonth']),
      periodMonthStart: $PaymentAllocationsTable.$converterperiodMonthStart
          .fromJson(serializer.fromJson<DateTime>(json['periodMonthStart'])),
      amount: serializer.fromJson<int>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'paymentId': serializer.toJson<int>(paymentId),
      'lotId': serializer.toJson<int>(lotId),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'periodMonth': serializer.toJson<String>(periodMonth),
      'periodMonthStart': serializer.toJson<DateTime>(
        $PaymentAllocationsTable.$converterperiodMonthStart.toJson(
          periodMonthStart,
        ),
      ),
      'amount': serializer.toJson<int>(amount),
    };
  }

  PaymentAllocationRow copyWith({
    int? id,
    int? paymentId,
    int? lotId,
    int? vehicleId,
    String? periodMonth,
    Day? periodMonthStart,
    int? amount,
  }) => PaymentAllocationRow(
    id: id ?? this.id,
    paymentId: paymentId ?? this.paymentId,
    lotId: lotId ?? this.lotId,
    vehicleId: vehicleId ?? this.vehicleId,
    periodMonth: periodMonth ?? this.periodMonth,
    periodMonthStart: periodMonthStart ?? this.periodMonthStart,
    amount: amount ?? this.amount,
  );
  PaymentAllocationRow copyWithCompanion(PaymentAllocationsCompanion data) {
    return PaymentAllocationRow(
      id: data.id.present ? data.id.value : this.id,
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      periodMonth: data.periodMonth.present
          ? data.periodMonth.value
          : this.periodMonth,
      periodMonthStart: data.periodMonthStart.present
          ? data.periodMonthStart.value
          : this.periodMonthStart,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentAllocationRow(')
          ..write('id: $id, ')
          ..write('paymentId: $paymentId, ')
          ..write('lotId: $lotId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('periodMonth: $periodMonth, ')
          ..write('periodMonthStart: $periodMonthStart, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    paymentId,
    lotId,
    vehicleId,
    periodMonth,
    periodMonthStart,
    amount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentAllocationRow &&
          other.id == this.id &&
          other.paymentId == this.paymentId &&
          other.lotId == this.lotId &&
          other.vehicleId == this.vehicleId &&
          other.periodMonth == this.periodMonth &&
          other.periodMonthStart == this.periodMonthStart &&
          other.amount == this.amount);
}

class PaymentAllocationsCompanion
    extends UpdateCompanion<PaymentAllocationRow> {
  final Value<int> id;
  final Value<int> paymentId;
  final Value<int> lotId;
  final Value<int> vehicleId;
  final Value<String> periodMonth;
  final Value<Day> periodMonthStart;
  final Value<int> amount;
  const PaymentAllocationsCompanion({
    this.id = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.lotId = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.periodMonth = const Value.absent(),
    this.periodMonthStart = const Value.absent(),
    this.amount = const Value.absent(),
  });
  PaymentAllocationsCompanion.insert({
    this.id = const Value.absent(),
    required int paymentId,
    required int lotId,
    required int vehicleId,
    required String periodMonth,
    required Day periodMonthStart,
    required int amount,
  }) : paymentId = Value(paymentId),
       lotId = Value(lotId),
       vehicleId = Value(vehicleId),
       periodMonth = Value(periodMonth),
       periodMonthStart = Value(periodMonthStart),
       amount = Value(amount);
  static Insertable<PaymentAllocationRow> custom({
    Expression<int>? id,
    Expression<int>? paymentId,
    Expression<int>? lotId,
    Expression<int>? vehicleId,
    Expression<String>? periodMonth,
    Expression<DateTime>? periodMonthStart,
    Expression<int>? amount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (paymentId != null) 'payment_id': paymentId,
      if (lotId != null) 'lot_id': lotId,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (periodMonth != null) 'period_month': periodMonth,
      if (periodMonthStart != null) 'period_month_start': periodMonthStart,
      if (amount != null) 'amount': amount,
    });
  }

  PaymentAllocationsCompanion copyWith({
    Value<int>? id,
    Value<int>? paymentId,
    Value<int>? lotId,
    Value<int>? vehicleId,
    Value<String>? periodMonth,
    Value<Day>? periodMonthStart,
    Value<int>? amount,
  }) {
    return PaymentAllocationsCompanion(
      id: id ?? this.id,
      paymentId: paymentId ?? this.paymentId,
      lotId: lotId ?? this.lotId,
      vehicleId: vehicleId ?? this.vehicleId,
      periodMonth: periodMonth ?? this.periodMonth,
      periodMonthStart: periodMonthStart ?? this.periodMonthStart,
      amount: amount ?? this.amount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (paymentId.present) {
      map['payment_id'] = Variable<int>(paymentId.value);
    }
    if (lotId.present) {
      map['lot_id'] = Variable<int>(lotId.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (periodMonth.present) {
      map['period_month'] = Variable<String>(periodMonth.value);
    }
    if (periodMonthStart.present) {
      map['period_month_start'] = Variable<DateTime>(
        $PaymentAllocationsTable.$converterperiodMonthStart.toSql(
          periodMonthStart.value,
        ),
      );
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentAllocationsCompanion(')
          ..write('id: $id, ')
          ..write('paymentId: $paymentId, ')
          ..write('lotId: $lotId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('periodMonth: $periodMonth, ')
          ..write('periodMonthStart: $periodMonthStart, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }
}

class $RecurringCostTemplatesTable extends RecurringCostTemplates
    with TableInfo<$RecurringCostTemplatesTable, RecurringCostTemplateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringCostTemplatesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<int> lotId = GeneratedColumn<int>(
    'lot_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES lots (id) ON DELETE CASCADE',
    ),
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
  @override
  late final GeneratedColumnWithTypeConverter<CostCategory, int> category =
      GeneratedColumn<int>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<CostCategory>(
        $RecurringCostTemplatesTable.$convertercategory,
      );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayOfMonthMeta = const VerificationMeta(
    'dayOfMonth',
  );
  @override
  late final GeneratedColumn<int> dayOfMonth = GeneratedColumn<int>(
    'day_of_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _startMonthMeta = const VerificationMeta(
    'startMonth',
  );
  @override
  late final GeneratedColumn<String> startMonth = GeneratedColumn<String>(
    'start_month',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 7,
      maxTextLength: 7,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMonthMeta = const VerificationMeta(
    'endMonth',
  );
  @override
  late final GeneratedColumn<String> endMonth = GeneratedColumn<String>(
    'end_month',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 7,
      maxTextLength: 7,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
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
    lotId,
    name,
    category,
    amount,
    dayOfMonth,
    startMonth,
    endMonth,
    isActive,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_cost_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringCostTemplateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lot_id')) {
      context.handle(
        _lotIdMeta,
        lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lotIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('day_of_month')) {
      context.handle(
        _dayOfMonthMeta,
        dayOfMonth.isAcceptableOrUnknown(
          data['day_of_month']!,
          _dayOfMonthMeta,
        ),
      );
    }
    if (data.containsKey('start_month')) {
      context.handle(
        _startMonthMeta,
        startMonth.isAcceptableOrUnknown(data['start_month']!, _startMonthMeta),
      );
    } else if (isInserting) {
      context.missing(_startMonthMeta);
    }
    if (data.containsKey('end_month')) {
      context.handle(
        _endMonthMeta,
        endMonth.isAcceptableOrUnknown(data['end_month']!, _endMonthMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
  RecurringCostTemplateRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringCostTemplateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lot_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: $RecurringCostTemplatesTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}category'],
        )!,
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      dayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_month'],
      )!,
      startMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_month'],
      )!,
      endMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_month'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
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
  $RecurringCostTemplatesTable createAlias(String alias) {
    return $RecurringCostTemplatesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CostCategory, int, int> $convertercategory =
      const EnumIndexConverter<CostCategory>(CostCategory.values);
}

class RecurringCostTemplateRow extends DataClass
    implements Insertable<RecurringCostTemplateRow> {
  final int id;
  final int lotId;
  final String name;
  final CostCategory category;

  /// Số tiền ước tính hàng tháng, VND. Người dùng sửa lại được cho từng tháng
  /// cụ thể ở bảng `expenses` mà không ảnh hưởng tới mẫu này.
  final int amount;

  /// Ngày trong tháng gán cho chi phí, kẹp trong 1..28 để tháng nào cũng có.
  final int dayOfMonth;

  /// `YYYY-MM` — tháng đầu tiên áp dụng.
  final String startMonth;

  /// `YYYY-MM` — tháng cuối cùng áp dụng, **bao gồm**. `null` = còn hiệu lực.
  final String? endMonth;
  final bool isActive;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  const RecurringCostTemplateRow({
    required this.id,
    required this.lotId,
    required this.name,
    required this.category,
    required this.amount,
    required this.dayOfMonth,
    required this.startMonth,
    this.endMonth,
    required this.isActive,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['lot_id'] = Variable<int>(lotId);
    map['name'] = Variable<String>(name);
    {
      map['category'] = Variable<int>(
        $RecurringCostTemplatesTable.$convertercategory.toSql(category),
      );
    }
    map['amount'] = Variable<int>(amount);
    map['day_of_month'] = Variable<int>(dayOfMonth);
    map['start_month'] = Variable<String>(startMonth);
    if (!nullToAbsent || endMonth != null) {
      map['end_month'] = Variable<String>(endMonth);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RecurringCostTemplatesCompanion toCompanion(bool nullToAbsent) {
    return RecurringCostTemplatesCompanion(
      id: Value(id),
      lotId: Value(lotId),
      name: Value(name),
      category: Value(category),
      amount: Value(amount),
      dayOfMonth: Value(dayOfMonth),
      startMonth: Value(startMonth),
      endMonth: endMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(endMonth),
      isActive: Value(isActive),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RecurringCostTemplateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringCostTemplateRow(
      id: serializer.fromJson<int>(json['id']),
      lotId: serializer.fromJson<int>(json['lotId']),
      name: serializer.fromJson<String>(json['name']),
      category: $RecurringCostTemplatesTable.$convertercategory.fromJson(
        serializer.fromJson<int>(json['category']),
      ),
      amount: serializer.fromJson<int>(json['amount']),
      dayOfMonth: serializer.fromJson<int>(json['dayOfMonth']),
      startMonth: serializer.fromJson<String>(json['startMonth']),
      endMonth: serializer.fromJson<String?>(json['endMonth']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lotId': serializer.toJson<int>(lotId),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<int>(
        $RecurringCostTemplatesTable.$convertercategory.toJson(category),
      ),
      'amount': serializer.toJson<int>(amount),
      'dayOfMonth': serializer.toJson<int>(dayOfMonth),
      'startMonth': serializer.toJson<String>(startMonth),
      'endMonth': serializer.toJson<String?>(endMonth),
      'isActive': serializer.toJson<bool>(isActive),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RecurringCostTemplateRow copyWith({
    int? id,
    int? lotId,
    String? name,
    CostCategory? category,
    int? amount,
    int? dayOfMonth,
    String? startMonth,
    Value<String?> endMonth = const Value.absent(),
    bool? isActive,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => RecurringCostTemplateRow(
    id: id ?? this.id,
    lotId: lotId ?? this.lotId,
    name: name ?? this.name,
    category: category ?? this.category,
    amount: amount ?? this.amount,
    dayOfMonth: dayOfMonth ?? this.dayOfMonth,
    startMonth: startMonth ?? this.startMonth,
    endMonth: endMonth.present ? endMonth.value : this.endMonth,
    isActive: isActive ?? this.isActive,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RecurringCostTemplateRow copyWithCompanion(
    RecurringCostTemplatesCompanion data,
  ) {
    return RecurringCostTemplateRow(
      id: data.id.present ? data.id.value : this.id,
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      dayOfMonth: data.dayOfMonth.present
          ? data.dayOfMonth.value
          : this.dayOfMonth,
      startMonth: data.startMonth.present
          ? data.startMonth.value
          : this.startMonth,
      endMonth: data.endMonth.present ? data.endMonth.value : this.endMonth,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringCostTemplateRow(')
          ..write('id: $id, ')
          ..write('lotId: $lotId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('startMonth: $startMonth, ')
          ..write('endMonth: $endMonth, ')
          ..write('isActive: $isActive, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lotId,
    name,
    category,
    amount,
    dayOfMonth,
    startMonth,
    endMonth,
    isActive,
    note,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringCostTemplateRow &&
          other.id == this.id &&
          other.lotId == this.lotId &&
          other.name == this.name &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.dayOfMonth == this.dayOfMonth &&
          other.startMonth == this.startMonth &&
          other.endMonth == this.endMonth &&
          other.isActive == this.isActive &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RecurringCostTemplatesCompanion
    extends UpdateCompanion<RecurringCostTemplateRow> {
  final Value<int> id;
  final Value<int> lotId;
  final Value<String> name;
  final Value<CostCategory> category;
  final Value<int> amount;
  final Value<int> dayOfMonth;
  final Value<String> startMonth;
  final Value<String?> endMonth;
  final Value<bool> isActive;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const RecurringCostTemplatesCompanion({
    this.id = const Value.absent(),
    this.lotId = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.startMonth = const Value.absent(),
    this.endMonth = const Value.absent(),
    this.isActive = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  RecurringCostTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required int lotId,
    required String name,
    required CostCategory category,
    required int amount,
    this.dayOfMonth = const Value.absent(),
    required String startMonth,
    this.endMonth = const Value.absent(),
    this.isActive = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : lotId = Value(lotId),
       name = Value(name),
       category = Value(category),
       amount = Value(amount),
       startMonth = Value(startMonth),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RecurringCostTemplateRow> custom({
    Expression<int>? id,
    Expression<int>? lotId,
    Expression<String>? name,
    Expression<int>? category,
    Expression<int>? amount,
    Expression<int>? dayOfMonth,
    Expression<String>? startMonth,
    Expression<String>? endMonth,
    Expression<bool>? isActive,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lotId != null) 'lot_id': lotId,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (startMonth != null) 'start_month': startMonth,
      if (endMonth != null) 'end_month': endMonth,
      if (isActive != null) 'is_active': isActive,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  RecurringCostTemplatesCompanion copyWith({
    Value<int>? id,
    Value<int>? lotId,
    Value<String>? name,
    Value<CostCategory>? category,
    Value<int>? amount,
    Value<int>? dayOfMonth,
    Value<String>? startMonth,
    Value<String?>? endMonth,
    Value<bool>? isActive,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return RecurringCostTemplatesCompanion(
      id: id ?? this.id,
      lotId: lotId ?? this.lotId,
      name: name ?? this.name,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      startMonth: startMonth ?? this.startMonth,
      endMonth: endMonth ?? this.endMonth,
      isActive: isActive ?? this.isActive,
      note: note ?? this.note,
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
    if (lotId.present) {
      map['lot_id'] = Variable<int>(lotId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<int>(
        $RecurringCostTemplatesTable.$convertercategory.toSql(category.value),
      );
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (dayOfMonth.present) {
      map['day_of_month'] = Variable<int>(dayOfMonth.value);
    }
    if (startMonth.present) {
      map['start_month'] = Variable<String>(startMonth.value);
    }
    if (endMonth.present) {
      map['end_month'] = Variable<String>(endMonth.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
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
    return (StringBuffer('RecurringCostTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('lotId: $lotId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('startMonth: $startMonth, ')
          ..write('endMonth: $endMonth, ')
          ..write('isActive: $isActive, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses
    with TableInfo<$ExpensesTable, ExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<int> lotId = GeneratedColumn<int>(
    'lot_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES lots (id) ON DELETE RESTRICT',
    ),
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
  @override
  late final GeneratedColumnWithTypeConverter<CostCategory, int> category =
      GeneratedColumn<int>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<CostCategory>($ExpensesTable.$convertercategory);
  @override
  late final GeneratedColumnWithTypeConverter<ExpenseKind, int> kind =
      GeneratedColumn<int>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ExpenseKind>($ExpensesTable.$converterkind);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Day, DateTime> incurredOn =
      GeneratedColumn<DateTime>(
        'incurred_on',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      ).withConverter<Day>($ExpensesTable.$converterincurredOn);
  static const VerificationMeta _periodMonthMeta = const VerificationMeta(
    'periodMonth',
  );
  @override
  late final GeneratedColumn<String> periodMonth = GeneratedColumn<String>(
    'period_month',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 7,
      maxTextLength: 7,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTemplateIdMeta = const VerificationMeta(
    'sourceTemplateId',
  );
  @override
  late final GeneratedColumn<int> sourceTemplateId = GeneratedColumn<int>(
    'source_template_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recurring_cost_templates (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _isEditedMeta = const VerificationMeta(
    'isEdited',
  );
  @override
  late final GeneratedColumn<bool> isEdited = GeneratedColumn<bool>(
    'is_edited',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_edited" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lotId,
    name,
    category,
    kind,
    amount,
    incurredOn,
    periodMonth,
    sourceTemplateId,
    isEdited,
    note,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lot_id')) {
      context.handle(
        _lotIdMeta,
        lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lotIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('period_month')) {
      context.handle(
        _periodMonthMeta,
        periodMonth.isAcceptableOrUnknown(
          data['period_month']!,
          _periodMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodMonthMeta);
    }
    if (data.containsKey('source_template_id')) {
      context.handle(
        _sourceTemplateIdMeta,
        sourceTemplateId.isAcceptableOrUnknown(
          data['source_template_id']!,
          _sourceTemplateIdMeta,
        ),
      );
    }
    if (data.containsKey('is_edited')) {
      context.handle(
        _isEditedMeta,
        isEdited.isAcceptableOrUnknown(data['is_edited']!, _isEditedMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lot_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: $ExpensesTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}category'],
        )!,
      ),
      kind: $ExpensesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}kind'],
        )!,
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      incurredOn: $ExpensesTable.$converterincurredOn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}incurred_on'],
        )!,
      ),
      periodMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_month'],
      )!,
      sourceTemplateId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_template_id'],
      ),
      isEdited: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_edited'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CostCategory, int, int> $convertercategory =
      const EnumIndexConverter<CostCategory>(CostCategory.values);
  static JsonTypeConverter2<ExpenseKind, int, int> $converterkind =
      const EnumIndexConverter<ExpenseKind>(ExpenseKind.values);
  static JsonTypeConverter2<Day, DateTime, DateTime> $converterincurredOn =
      const DayConverter();
}

class ExpenseRow extends DataClass implements Insertable<ExpenseRow> {
  final int id;
  final int lotId;
  final String name;
  final CostCategory category;
  final ExpenseKind kind;
  final int amount;

  /// Ngày chi tiền thực tế.
  final Day incurredOn;

  /// Tháng kế toán `YYYY-MM` — tách riêng khỏi [incurredOn] để người dùng ghi
  /// hoá đơn điện tháng 8 với ngày trả 03/09 nhưng vẫn hạch toán vào tháng 8.
  /// Đó chính là cách hoá đơn tiện ích hoạt động ngoài đời; không tách ra thì
  /// con số lợi nhuận theo tháng sẽ chập chờn.
  final String periodMonth;

  /// Trỏ về mẫu đã sinh ra dòng này. `null` = chi phí phát sinh nhập tay.
  ///
  /// `ON DELETE SET NULL`: xoá mẫu thì chi phí lịch sử vẫn còn — tiền đó đã
  /// thực sự chi ra rồi.
  final int? sourceTemplateId;

  /// Người dùng đã sửa lại số tiền so với ước tính của mẫu. Dòng chưa sửa được
  /// hiển thị kèm nhãn "ước tính" để biết hoá đơn nào chưa xác nhận.
  final bool isEdited;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const ExpenseRow({
    required this.id,
    required this.lotId,
    required this.name,
    required this.category,
    required this.kind,
    required this.amount,
    required this.incurredOn,
    required this.periodMonth,
    this.sourceTemplateId,
    required this.isEdited,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['lot_id'] = Variable<int>(lotId);
    map['name'] = Variable<String>(name);
    {
      map['category'] = Variable<int>(
        $ExpensesTable.$convertercategory.toSql(category),
      );
    }
    {
      map['kind'] = Variable<int>($ExpensesTable.$converterkind.toSql(kind));
    }
    map['amount'] = Variable<int>(amount);
    {
      map['incurred_on'] = Variable<DateTime>(
        $ExpensesTable.$converterincurredOn.toSql(incurredOn),
      );
    }
    map['period_month'] = Variable<String>(periodMonth);
    if (!nullToAbsent || sourceTemplateId != null) {
      map['source_template_id'] = Variable<int>(sourceTemplateId);
    }
    map['is_edited'] = Variable<bool>(isEdited);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      lotId: Value(lotId),
      name: Value(name),
      category: Value(category),
      kind: Value(kind),
      amount: Value(amount),
      incurredOn: Value(incurredOn),
      periodMonth: Value(periodMonth),
      sourceTemplateId: sourceTemplateId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceTemplateId),
      isEdited: Value(isEdited),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ExpenseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseRow(
      id: serializer.fromJson<int>(json['id']),
      lotId: serializer.fromJson<int>(json['lotId']),
      name: serializer.fromJson<String>(json['name']),
      category: $ExpensesTable.$convertercategory.fromJson(
        serializer.fromJson<int>(json['category']),
      ),
      kind: $ExpensesTable.$converterkind.fromJson(
        serializer.fromJson<int>(json['kind']),
      ),
      amount: serializer.fromJson<int>(json['amount']),
      incurredOn: $ExpensesTable.$converterincurredOn.fromJson(
        serializer.fromJson<DateTime>(json['incurredOn']),
      ),
      periodMonth: serializer.fromJson<String>(json['periodMonth']),
      sourceTemplateId: serializer.fromJson<int?>(json['sourceTemplateId']),
      isEdited: serializer.fromJson<bool>(json['isEdited']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lotId': serializer.toJson<int>(lotId),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<int>(
        $ExpensesTable.$convertercategory.toJson(category),
      ),
      'kind': serializer.toJson<int>(
        $ExpensesTable.$converterkind.toJson(kind),
      ),
      'amount': serializer.toJson<int>(amount),
      'incurredOn': serializer.toJson<DateTime>(
        $ExpensesTable.$converterincurredOn.toJson(incurredOn),
      ),
      'periodMonth': serializer.toJson<String>(periodMonth),
      'sourceTemplateId': serializer.toJson<int?>(sourceTemplateId),
      'isEdited': serializer.toJson<bool>(isEdited),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ExpenseRow copyWith({
    int? id,
    int? lotId,
    String? name,
    CostCategory? category,
    ExpenseKind? kind,
    int? amount,
    Day? incurredOn,
    String? periodMonth,
    Value<int?> sourceTemplateId = const Value.absent(),
    bool? isEdited,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ExpenseRow(
    id: id ?? this.id,
    lotId: lotId ?? this.lotId,
    name: name ?? this.name,
    category: category ?? this.category,
    kind: kind ?? this.kind,
    amount: amount ?? this.amount,
    incurredOn: incurredOn ?? this.incurredOn,
    periodMonth: periodMonth ?? this.periodMonth,
    sourceTemplateId: sourceTemplateId.present
        ? sourceTemplateId.value
        : this.sourceTemplateId,
    isEdited: isEdited ?? this.isEdited,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ExpenseRow copyWithCompanion(ExpensesCompanion data) {
    return ExpenseRow(
      id: data.id.present ? data.id.value : this.id,
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      kind: data.kind.present ? data.kind.value : this.kind,
      amount: data.amount.present ? data.amount.value : this.amount,
      incurredOn: data.incurredOn.present
          ? data.incurredOn.value
          : this.incurredOn,
      periodMonth: data.periodMonth.present
          ? data.periodMonth.value
          : this.periodMonth,
      sourceTemplateId: data.sourceTemplateId.present
          ? data.sourceTemplateId.value
          : this.sourceTemplateId,
      isEdited: data.isEdited.present ? data.isEdited.value : this.isEdited,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseRow(')
          ..write('id: $id, ')
          ..write('lotId: $lotId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('kind: $kind, ')
          ..write('amount: $amount, ')
          ..write('incurredOn: $incurredOn, ')
          ..write('periodMonth: $periodMonth, ')
          ..write('sourceTemplateId: $sourceTemplateId, ')
          ..write('isEdited: $isEdited, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lotId,
    name,
    category,
    kind,
    amount,
    incurredOn,
    periodMonth,
    sourceTemplateId,
    isEdited,
    note,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseRow &&
          other.id == this.id &&
          other.lotId == this.lotId &&
          other.name == this.name &&
          other.category == this.category &&
          other.kind == this.kind &&
          other.amount == this.amount &&
          other.incurredOn == this.incurredOn &&
          other.periodMonth == this.periodMonth &&
          other.sourceTemplateId == this.sourceTemplateId &&
          other.isEdited == this.isEdited &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ExpensesCompanion extends UpdateCompanion<ExpenseRow> {
  final Value<int> id;
  final Value<int> lotId;
  final Value<String> name;
  final Value<CostCategory> category;
  final Value<ExpenseKind> kind;
  final Value<int> amount;
  final Value<Day> incurredOn;
  final Value<String> periodMonth;
  final Value<int?> sourceTemplateId;
  final Value<bool> isEdited;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.lotId = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.kind = const Value.absent(),
    this.amount = const Value.absent(),
    this.incurredOn = const Value.absent(),
    this.periodMonth = const Value.absent(),
    this.sourceTemplateId = const Value.absent(),
    this.isEdited = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.id = const Value.absent(),
    required int lotId,
    required String name,
    required CostCategory category,
    required ExpenseKind kind,
    required int amount,
    required Day incurredOn,
    required String periodMonth,
    this.sourceTemplateId = const Value.absent(),
    this.isEdited = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
  }) : lotId = Value(lotId),
       name = Value(name),
       category = Value(category),
       kind = Value(kind),
       amount = Value(amount),
       incurredOn = Value(incurredOn),
       periodMonth = Value(periodMonth),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ExpenseRow> custom({
    Expression<int>? id,
    Expression<int>? lotId,
    Expression<String>? name,
    Expression<int>? category,
    Expression<int>? kind,
    Expression<int>? amount,
    Expression<DateTime>? incurredOn,
    Expression<String>? periodMonth,
    Expression<int>? sourceTemplateId,
    Expression<bool>? isEdited,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lotId != null) 'lot_id': lotId,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (kind != null) 'kind': kind,
      if (amount != null) 'amount': amount,
      if (incurredOn != null) 'incurred_on': incurredOn,
      if (periodMonth != null) 'period_month': periodMonth,
      if (sourceTemplateId != null) 'source_template_id': sourceTemplateId,
      if (isEdited != null) 'is_edited': isEdited,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  ExpensesCompanion copyWith({
    Value<int>? id,
    Value<int>? lotId,
    Value<String>? name,
    Value<CostCategory>? category,
    Value<ExpenseKind>? kind,
    Value<int>? amount,
    Value<Day>? incurredOn,
    Value<String>? periodMonth,
    Value<int?>? sourceTemplateId,
    Value<bool>? isEdited,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      lotId: lotId ?? this.lotId,
      name: name ?? this.name,
      category: category ?? this.category,
      kind: kind ?? this.kind,
      amount: amount ?? this.amount,
      incurredOn: incurredOn ?? this.incurredOn,
      periodMonth: periodMonth ?? this.periodMonth,
      sourceTemplateId: sourceTemplateId ?? this.sourceTemplateId,
      isEdited: isEdited ?? this.isEdited,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lotId.present) {
      map['lot_id'] = Variable<int>(lotId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<int>(
        $ExpensesTable.$convertercategory.toSql(category.value),
      );
    }
    if (kind.present) {
      map['kind'] = Variable<int>(
        $ExpensesTable.$converterkind.toSql(kind.value),
      );
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (incurredOn.present) {
      map['incurred_on'] = Variable<DateTime>(
        $ExpensesTable.$converterincurredOn.toSql(incurredOn.value),
      );
    }
    if (periodMonth.present) {
      map['period_month'] = Variable<String>(periodMonth.value);
    }
    if (sourceTemplateId.present) {
      map['source_template_id'] = Variable<int>(sourceTemplateId.value);
    }
    if (isEdited.present) {
      map['is_edited'] = Variable<bool>(isEdited.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('lotId: $lotId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('kind: $kind, ')
          ..write('amount: $amount, ')
          ..write('incurredOn: $incurredOn, ')
          ..write('periodMonth: $periodMonth, ')
          ..write('sourceTemplateId: $sourceTemplateId, ')
          ..write('isEdited: $isEdited, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $ActivityLogTable extends ActivityLog
    with TableInfo<$ActivityLogTable, ActivityLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityLogTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LogAction, int> action =
      GeneratedColumn<int>(
        'action',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<LogAction>($ActivityLogTable.$converteraction);
  @override
  late final GeneratedColumnWithTypeConverter<LogEntity, int> entityType =
      GeneratedColumn<int>(
        'entity_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<LogEntity>($ActivityLogTable.$converterentityType);
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<int> entityId = GeneratedColumn<int>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lotIdMeta = const VerificationMeta('lotId');
  @override
  late final GeneratedColumn<int> lotId = GeneratedColumn<int>(
    'lot_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailsJsonMeta = const VerificationMeta(
    'detailsJson',
  );
  @override
  late final GeneratedColumn<String> detailsJson = GeneratedColumn<String>(
    'details_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    at,
    action,
    entityType,
    entityId,
    lotId,
    summary,
    detailsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('lot_id')) {
      context.handle(
        _lotIdMeta,
        lotId.isAcceptableOrUnknown(data['lot_id']!, _lotIdMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('details_json')) {
      context.handle(
        _detailsJsonMeta,
        detailsJson.isAcceptableOrUnknown(
          data['details_json']!,
          _detailsJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      action: $ActivityLogTable.$converteraction.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}action'],
        )!,
      ),
      entityType: $ActivityLogTable.$converterentityType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}entity_type'],
        )!,
      ),
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entity_id'],
      ),
      lotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lot_id'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      detailsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details_json'],
      ),
    );
  }

  @override
  $ActivityLogTable createAlias(String alias) {
    return $ActivityLogTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LogAction, int, int> $converteraction =
      const EnumIndexConverter<LogAction>(LogAction.values);
  static JsonTypeConverter2<LogEntity, int, int> $converterentityType =
      const EnumIndexConverter<LogEntity>(LogEntity.values);
}

class ActivityLogRow extends DataClass implements Insertable<ActivityLogRow> {
  final int id;
  final DateTime at;
  final LogAction action;
  final LogEntity entityType;
  final int? entityId;
  final int? lotId;

  /// Câu tiếng Việt đã dựng sẵn, hiển thị thẳng lên màn hình.
  ///
  /// Dựng sẵn chứ không dựng lúc đọc, vì hai lẽ: màn hình nhật ký vẽ được mà
  /// **không cần join** bảng nào, và câu chữ vẫn đọc đúng sau khi cái xe được
  /// nhắc tới đã bị xoá — đây chính là cách nhật ký thao tác hay hỏng nhất.
  final String summary;

  /// JSON mô tả thay đổi trước/sau, cho trường hợp cần soi chi tiết.
  final String? detailsJson;
  const ActivityLogRow({
    required this.id,
    required this.at,
    required this.action,
    required this.entityType,
    this.entityId,
    this.lotId,
    required this.summary,
    this.detailsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['at'] = Variable<DateTime>(at);
    {
      map['action'] = Variable<int>(
        $ActivityLogTable.$converteraction.toSql(action),
      );
    }
    {
      map['entity_type'] = Variable<int>(
        $ActivityLogTable.$converterentityType.toSql(entityType),
      );
    }
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<int>(entityId);
    }
    if (!nullToAbsent || lotId != null) {
      map['lot_id'] = Variable<int>(lotId);
    }
    map['summary'] = Variable<String>(summary);
    if (!nullToAbsent || detailsJson != null) {
      map['details_json'] = Variable<String>(detailsJson);
    }
    return map;
  }

  ActivityLogCompanion toCompanion(bool nullToAbsent) {
    return ActivityLogCompanion(
      id: Value(id),
      at: Value(at),
      action: Value(action),
      entityType: Value(entityType),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      lotId: lotId == null && nullToAbsent
          ? const Value.absent()
          : Value(lotId),
      summary: Value(summary),
      detailsJson: detailsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(detailsJson),
    );
  }

  factory ActivityLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityLogRow(
      id: serializer.fromJson<int>(json['id']),
      at: serializer.fromJson<DateTime>(json['at']),
      action: $ActivityLogTable.$converteraction.fromJson(
        serializer.fromJson<int>(json['action']),
      ),
      entityType: $ActivityLogTable.$converterentityType.fromJson(
        serializer.fromJson<int>(json['entityType']),
      ),
      entityId: serializer.fromJson<int?>(json['entityId']),
      lotId: serializer.fromJson<int?>(json['lotId']),
      summary: serializer.fromJson<String>(json['summary']),
      detailsJson: serializer.fromJson<String?>(json['detailsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'at': serializer.toJson<DateTime>(at),
      'action': serializer.toJson<int>(
        $ActivityLogTable.$converteraction.toJson(action),
      ),
      'entityType': serializer.toJson<int>(
        $ActivityLogTable.$converterentityType.toJson(entityType),
      ),
      'entityId': serializer.toJson<int?>(entityId),
      'lotId': serializer.toJson<int?>(lotId),
      'summary': serializer.toJson<String>(summary),
      'detailsJson': serializer.toJson<String?>(detailsJson),
    };
  }

  ActivityLogRow copyWith({
    int? id,
    DateTime? at,
    LogAction? action,
    LogEntity? entityType,
    Value<int?> entityId = const Value.absent(),
    Value<int?> lotId = const Value.absent(),
    String? summary,
    Value<String?> detailsJson = const Value.absent(),
  }) => ActivityLogRow(
    id: id ?? this.id,
    at: at ?? this.at,
    action: action ?? this.action,
    entityType: entityType ?? this.entityType,
    entityId: entityId.present ? entityId.value : this.entityId,
    lotId: lotId.present ? lotId.value : this.lotId,
    summary: summary ?? this.summary,
    detailsJson: detailsJson.present ? detailsJson.value : this.detailsJson,
  );
  ActivityLogRow copyWithCompanion(ActivityLogCompanion data) {
    return ActivityLogRow(
      id: data.id.present ? data.id.value : this.id,
      at: data.at.present ? data.at.value : this.at,
      action: data.action.present ? data.action.value : this.action,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      lotId: data.lotId.present ? data.lotId.value : this.lotId,
      summary: data.summary.present ? data.summary.value : this.summary,
      detailsJson: data.detailsJson.present
          ? data.detailsJson.value
          : this.detailsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLogRow(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('lotId: $lotId, ')
          ..write('summary: $summary, ')
          ..write('detailsJson: $detailsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    at,
    action,
    entityType,
    entityId,
    lotId,
    summary,
    detailsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityLogRow &&
          other.id == this.id &&
          other.at == this.at &&
          other.action == this.action &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.lotId == this.lotId &&
          other.summary == this.summary &&
          other.detailsJson == this.detailsJson);
}

class ActivityLogCompanion extends UpdateCompanion<ActivityLogRow> {
  final Value<int> id;
  final Value<DateTime> at;
  final Value<LogAction> action;
  final Value<LogEntity> entityType;
  final Value<int?> entityId;
  final Value<int?> lotId;
  final Value<String> summary;
  final Value<String?> detailsJson;
  const ActivityLogCompanion({
    this.id = const Value.absent(),
    this.at = const Value.absent(),
    this.action = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.lotId = const Value.absent(),
    this.summary = const Value.absent(),
    this.detailsJson = const Value.absent(),
  });
  ActivityLogCompanion.insert({
    this.id = const Value.absent(),
    required DateTime at,
    required LogAction action,
    required LogEntity entityType,
    this.entityId = const Value.absent(),
    this.lotId = const Value.absent(),
    required String summary,
    this.detailsJson = const Value.absent(),
  }) : at = Value(at),
       action = Value(action),
       entityType = Value(entityType),
       summary = Value(summary);
  static Insertable<ActivityLogRow> custom({
    Expression<int>? id,
    Expression<DateTime>? at,
    Expression<int>? action,
    Expression<int>? entityType,
    Expression<int>? entityId,
    Expression<int>? lotId,
    Expression<String>? summary,
    Expression<String>? detailsJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (at != null) 'at': at,
      if (action != null) 'action': action,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (lotId != null) 'lot_id': lotId,
      if (summary != null) 'summary': summary,
      if (detailsJson != null) 'details_json': detailsJson,
    });
  }

  ActivityLogCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? at,
    Value<LogAction>? action,
    Value<LogEntity>? entityType,
    Value<int?>? entityId,
    Value<int?>? lotId,
    Value<String>? summary,
    Value<String?>? detailsJson,
  }) {
    return ActivityLogCompanion(
      id: id ?? this.id,
      at: at ?? this.at,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      lotId: lotId ?? this.lotId,
      summary: summary ?? this.summary,
      detailsJson: detailsJson ?? this.detailsJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (action.present) {
      map['action'] = Variable<int>(
        $ActivityLogTable.$converteraction.toSql(action.value),
      );
    }
    if (entityType.present) {
      map['entity_type'] = Variable<int>(
        $ActivityLogTable.$converterentityType.toSql(entityType.value),
      );
    }
    if (entityId.present) {
      map['entity_id'] = Variable<int>(entityId.value);
    }
    if (lotId.present) {
      map['lot_id'] = Variable<int>(lotId.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (detailsJson.present) {
      map['details_json'] = Variable<String>(detailsJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLogCompanion(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('action: $action, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('lotId: $lotId, ')
          ..write('summary: $summary, ')
          ..write('detailsJson: $detailsJson')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String key;
  final String value;
  const AppSettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingRow copyWith({String? key, String? value}) =>
      AppSettingRow(key: key ?? this.key, value: value ?? this.value);
  AppSettingRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LotsTable lots = $LotsTable(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $PaymentAllocationsTable paymentAllocations =
      $PaymentAllocationsTable(this);
  late final $RecurringCostTemplatesTable recurringCostTemplates =
      $RecurringCostTemplatesTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final Index idxVehiclesLotStatus = Index(
    'idx_vehicles_lot_status',
    'CREATE INDEX idx_vehicles_lot_status ON vehicles (lot_id, status, deleted_at)',
  );
  late final Index idxVehiclesPeriodEnd = Index(
    'idx_vehicles_period_end',
    'CREATE INDEX idx_vehicles_period_end ON vehicles (current_period_end)',
  );
  late final Index idxVehiclesPlateNorm = Index(
    'idx_vehicles_plate_norm',
    'CREATE INDEX idx_vehicles_plate_norm ON vehicles (plate_normalized)',
  );
  late final Index idxVehiclesOwnerFold = Index(
    'idx_vehicles_owner_fold',
    'CREATE INDEX idx_vehicles_owner_fold ON vehicles (owner_name_fold)',
  );
  late final Index idxVehiclesPhoneDigits = Index(
    'idx_vehicles_phone_digits',
    'CREATE INDEX idx_vehicles_phone_digits ON vehicles (phone_digits)',
  );
  late final Index uqVehiclesActivePlate = Index(
    'uq_vehicles_active_plate',
    'CREATE UNIQUE INDEX uq_vehicles_active_plate ON vehicles (lot_id, plate_normalized) WHERE status = 0 AND deleted_at IS NULL',
  );
  late final Index idxPaymentsVehicle = Index(
    'idx_payments_vehicle',
    'CREATE INDEX idx_payments_vehicle ON payments (vehicle_id, period_end)',
  );
  late final Index idxPaymentsLotPaid = Index(
    'idx_payments_lot_paid',
    'CREATE INDEX idx_payments_lot_paid ON payments (lot_id, paid_at) WHERE voided_at IS NULL',
  );
  late final Index idxPaymentsPaid = Index(
    'idx_payments_paid',
    'CREATE INDEX idx_payments_paid ON payments (paid_at) WHERE voided_at IS NULL',
  );
  late final Index idxAllocMonth = Index(
    'idx_alloc_month',
    'CREATE INDEX idx_alloc_month ON payment_allocations (period_month)',
  );
  late final Index idxAllocLotMonth = Index(
    'idx_alloc_lot_month',
    'CREATE INDEX idx_alloc_lot_month ON payment_allocations (lot_id, period_month)',
  );
  late final Index idxExpensesLotMonth = Index(
    'idx_expenses_lot_month',
    'CREATE INDEX idx_expenses_lot_month ON expenses (lot_id, period_month) WHERE deleted_at IS NULL',
  );
  late final Index idxExpensesIncurred = Index(
    'idx_expenses_incurred',
    'CREATE INDEX idx_expenses_incurred ON expenses (incurred_on) WHERE deleted_at IS NULL',
  );
  late final Index uqExpenseTemplateMonth = Index(
    'uq_expense_template_month',
    'CREATE UNIQUE INDEX uq_expense_template_month ON expenses (source_template_id, period_month) WHERE source_template_id IS NOT NULL',
  );
  late final $ActivityLogTable activityLog = $ActivityLogTable(this);
  late final Index idxLogAt = Index(
    'idx_log_at',
    'CREATE INDEX idx_log_at ON activity_log (at DESC)',
  );
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  Selectable<RevenueCashByDayResult> revenueCashByDay({
    required Day from,
    required Day to,
    RevenueCashByDay$lotFilter? lotFilter,
  }) {
    var $arrayStartIndex = 3;
    final generatedlotFilter = $write(
      lotFilter?.call(this.payments) ?? const CustomExpression('(TRUE)'),
      startIndex: $arrayStartIndex,
    );
    $arrayStartIndex += generatedlotFilter.amountOfVariables;
    return customSelect(
      'SELECT strftime(\'%Y-%m-%d\', paid_at, \'unixepoch\') AS ym, SUM(amount) AS total FROM payments WHERE voided_at IS NULL AND paid_at >= ?1 AND paid_at < ?2 AND ${generatedlotFilter.sql} GROUP BY ym ORDER BY ym',
      variables: [
        Variable<DateTime>($PaymentsTable.$converterpaidAt.toSql(from)),
        Variable<DateTime>($PaymentsTable.$converterpaidAt.toSql(to)),
        ...generatedlotFilter.introducedVariables,
      ],
      readsFrom: {this.payments, ...generatedlotFilter.watchedTables},
    ).map(
      (QueryRow row) => RevenueCashByDayResult(
        ym: row.read<String>('ym'),
        total: row.readNullable<int>('total'),
      ),
    );
  }

  Selectable<RevenueCashByMonthResult> revenueCashByMonth({
    required Day from,
    required Day to,
    RevenueCashByMonth$lotFilter? lotFilter,
  }) {
    var $arrayStartIndex = 3;
    final generatedlotFilter = $write(
      lotFilter?.call(this.payments) ?? const CustomExpression('(TRUE)'),
      startIndex: $arrayStartIndex,
    );
    $arrayStartIndex += generatedlotFilter.amountOfVariables;
    return customSelect(
      'SELECT strftime(\'%Y-%m\', paid_at, \'unixepoch\') AS ym, SUM(amount) AS total FROM payments WHERE voided_at IS NULL AND paid_at >= ?1 AND paid_at < ?2 AND ${generatedlotFilter.sql} GROUP BY ym ORDER BY ym',
      variables: [
        Variable<DateTime>($PaymentsTable.$converterpaidAt.toSql(from)),
        Variable<DateTime>($PaymentsTable.$converterpaidAt.toSql(to)),
        ...generatedlotFilter.introducedVariables,
      ],
      readsFrom: {this.payments, ...generatedlotFilter.watchedTables},
    ).map(
      (QueryRow row) => RevenueCashByMonthResult(
        ym: row.read<String>('ym'),
        total: row.readNullable<int>('total'),
      ),
    );
  }

  Selectable<RevenueCashByQuarterResult> revenueCashByQuarter({
    required Day from,
    required Day to,
    RevenueCashByQuarter$lotFilter? lotFilter,
  }) {
    var $arrayStartIndex = 3;
    final generatedlotFilter = $write(
      lotFilter?.call(this.payments) ?? const CustomExpression('(TRUE)'),
      startIndex: $arrayStartIndex,
    );
    $arrayStartIndex += generatedlotFilter.amountOfVariables;
    return customSelect(
      'SELECT strftime(\'%Y\', paid_at, \'unixepoch\') || \'-Q\' ||((CAST(strftime(\'%m\', paid_at, \'unixepoch\') AS INTEGER) + 2)/ 3)AS ym, SUM(amount) AS total FROM payments WHERE voided_at IS NULL AND paid_at >= ?1 AND paid_at < ?2 AND ${generatedlotFilter.sql} GROUP BY ym ORDER BY ym',
      variables: [
        Variable<DateTime>($PaymentsTable.$converterpaidAt.toSql(from)),
        Variable<DateTime>($PaymentsTable.$converterpaidAt.toSql(to)),
        ...generatedlotFilter.introducedVariables,
      ],
      readsFrom: {this.payments, ...generatedlotFilter.watchedTables},
    ).map(
      (QueryRow row) => RevenueCashByQuarterResult(
        ym: row.read<String>('ym'),
        total: row.readNullable<int>('total'),
      ),
    );
  }

  Selectable<RevenueCashByYearResult> revenueCashByYear({
    required Day from,
    required Day to,
    RevenueCashByYear$lotFilter? lotFilter,
  }) {
    var $arrayStartIndex = 3;
    final generatedlotFilter = $write(
      lotFilter?.call(this.payments) ?? const CustomExpression('(TRUE)'),
      startIndex: $arrayStartIndex,
    );
    $arrayStartIndex += generatedlotFilter.amountOfVariables;
    return customSelect(
      'SELECT strftime(\'%Y\', paid_at, \'unixepoch\') AS ym, SUM(amount) AS total FROM payments WHERE voided_at IS NULL AND paid_at >= ?1 AND paid_at < ?2 AND ${generatedlotFilter.sql} GROUP BY ym ORDER BY ym',
      variables: [
        Variable<DateTime>($PaymentsTable.$converterpaidAt.toSql(from)),
        Variable<DateTime>($PaymentsTable.$converterpaidAt.toSql(to)),
        ...generatedlotFilter.introducedVariables,
      ],
      readsFrom: {this.payments, ...generatedlotFilter.watchedTables},
    ).map(
      (QueryRow row) => RevenueCashByYearResult(
        ym: row.read<String>('ym'),
        total: row.readNullable<int>('total'),
      ),
    );
  }

  Selectable<RevenueAccrualByMonthResult> revenueAccrualByMonth({
    required String fromYm,
    required String toYm,
    RevenueAccrualByMonth$lotFilter? lotFilter,
  }) {
    var $arrayStartIndex = 3;
    final generatedlotFilter = $write(
      lotFilter?.call(
            alias(this.paymentAllocations, 'a'),
            alias(this.payments, 'p'),
          ) ??
          const CustomExpression('(TRUE)'),
      hasMultipleTables: true,
      startIndex: $arrayStartIndex,
    );
    $arrayStartIndex += generatedlotFilter.amountOfVariables;
    return customSelect(
      'SELECT a.period_month AS ym, SUM(a.amount) AS total FROM payment_allocations AS a JOIN payments AS p ON p.id = a.payment_id AND p.voided_at IS NULL WHERE a.period_month >= ?1 AND a.period_month <= ?2 AND ${generatedlotFilter.sql} GROUP BY ym ORDER BY ym',
      variables: [
        Variable<String>(fromYm),
        Variable<String>(toYm),
        ...generatedlotFilter.introducedVariables,
      ],
      readsFrom: {
        this.paymentAllocations,
        this.payments,
        ...generatedlotFilter.watchedTables,
      },
    ).map(
      (QueryRow row) => RevenueAccrualByMonthResult(
        ym: row.read<String>('ym'),
        total: row.readNullable<int>('total'),
      ),
    );
  }

  Selectable<RevenueAccrualByQuarterResult> revenueAccrualByQuarter({
    required String fromYm,
    required String toYm,
    RevenueAccrualByQuarter$lotFilter? lotFilter,
  }) {
    var $arrayStartIndex = 3;
    final generatedlotFilter = $write(
      lotFilter?.call(
            alias(this.paymentAllocations, 'a'),
            alias(this.payments, 'p'),
          ) ??
          const CustomExpression('(TRUE)'),
      hasMultipleTables: true,
      startIndex: $arrayStartIndex,
    );
    $arrayStartIndex += generatedlotFilter.amountOfVariables;
    return customSelect(
      'SELECT substr(a.period_month, 1, 4) || \'-Q\' ||((CAST(substr(a.period_month, 6, 2) AS INTEGER) + 2)/ 3)AS ym, SUM(a.amount) AS total FROM payment_allocations AS a JOIN payments AS p ON p.id = a.payment_id AND p.voided_at IS NULL WHERE a.period_month >= ?1 AND a.period_month <= ?2 AND ${generatedlotFilter.sql} GROUP BY ym ORDER BY ym',
      variables: [
        Variable<String>(fromYm),
        Variable<String>(toYm),
        ...generatedlotFilter.introducedVariables,
      ],
      readsFrom: {
        this.paymentAllocations,
        this.payments,
        ...generatedlotFilter.watchedTables,
      },
    ).map(
      (QueryRow row) => RevenueAccrualByQuarterResult(
        ym: row.read<String>('ym'),
        total: row.readNullable<int>('total'),
      ),
    );
  }

  Selectable<RevenueAccrualByYearResult> revenueAccrualByYear({
    required String fromYm,
    required String toYm,
    RevenueAccrualByYear$lotFilter? lotFilter,
  }) {
    var $arrayStartIndex = 3;
    final generatedlotFilter = $write(
      lotFilter?.call(
            alias(this.paymentAllocations, 'a'),
            alias(this.payments, 'p'),
          ) ??
          const CustomExpression('(TRUE)'),
      hasMultipleTables: true,
      startIndex: $arrayStartIndex,
    );
    $arrayStartIndex += generatedlotFilter.amountOfVariables;
    return customSelect(
      'SELECT substr(a.period_month, 1, 4) AS ym, SUM(a.amount) AS total FROM payment_allocations AS a JOIN payments AS p ON p.id = a.payment_id AND p.voided_at IS NULL WHERE a.period_month >= ?1 AND a.period_month <= ?2 AND ${generatedlotFilter.sql} GROUP BY ym ORDER BY ym',
      variables: [
        Variable<String>(fromYm),
        Variable<String>(toYm),
        ...generatedlotFilter.introducedVariables,
      ],
      readsFrom: {
        this.paymentAllocations,
        this.payments,
        ...generatedlotFilter.watchedTables,
      },
    ).map(
      (QueryRow row) => RevenueAccrualByYearResult(
        ym: row.read<String>('ym'),
        total: row.readNullable<int>('total'),
      ),
    );
  }

  Selectable<ExpensesByMonthResult> expensesByMonth({
    required String fromYm,
    required String toYm,
    ExpensesByMonth$lotFilter? lotFilter,
  }) {
    var $arrayStartIndex = 3;
    final generatedlotFilter = $write(
      lotFilter?.call(this.expenses) ?? const CustomExpression('(TRUE)'),
      startIndex: $arrayStartIndex,
    );
    $arrayStartIndex += generatedlotFilter.amountOfVariables;
    return customSelect(
      'SELECT period_month AS ym, SUM(amount) AS total FROM expenses WHERE deleted_at IS NULL AND period_month >= ?1 AND period_month <= ?2 AND ${generatedlotFilter.sql} GROUP BY ym ORDER BY ym',
      variables: [
        Variable<String>(fromYm),
        Variable<String>(toYm),
        ...generatedlotFilter.introducedVariables,
      ],
      readsFrom: {this.expenses, ...generatedlotFilter.watchedTables},
    ).map(
      (QueryRow row) => ExpensesByMonthResult(
        ym: row.read<String>('ym'),
        total: row.readNullable<int>('total'),
      ),
    );
  }

  Selectable<ExpensesByQuarterResult> expensesByQuarter({
    required String fromYm,
    required String toYm,
    ExpensesByQuarter$lotFilter? lotFilter,
  }) {
    var $arrayStartIndex = 3;
    final generatedlotFilter = $write(
      lotFilter?.call(this.expenses) ?? const CustomExpression('(TRUE)'),
      startIndex: $arrayStartIndex,
    );
    $arrayStartIndex += generatedlotFilter.amountOfVariables;
    return customSelect(
      'SELECT substr(period_month, 1, 4) || \'-Q\' ||((CAST(substr(period_month, 6, 2) AS INTEGER) + 2)/ 3)AS ym, SUM(amount) AS total FROM expenses WHERE deleted_at IS NULL AND period_month >= ?1 AND period_month <= ?2 AND ${generatedlotFilter.sql} GROUP BY ym ORDER BY ym',
      variables: [
        Variable<String>(fromYm),
        Variable<String>(toYm),
        ...generatedlotFilter.introducedVariables,
      ],
      readsFrom: {this.expenses, ...generatedlotFilter.watchedTables},
    ).map(
      (QueryRow row) => ExpensesByQuarterResult(
        ym: row.read<String>('ym'),
        total: row.readNullable<int>('total'),
      ),
    );
  }

  Selectable<ExpensesByYearResult> expensesByYear({
    required String fromYm,
    required String toYm,
    ExpensesByYear$lotFilter? lotFilter,
  }) {
    var $arrayStartIndex = 3;
    final generatedlotFilter = $write(
      lotFilter?.call(this.expenses) ?? const CustomExpression('(TRUE)'),
      startIndex: $arrayStartIndex,
    );
    $arrayStartIndex += generatedlotFilter.amountOfVariables;
    return customSelect(
      'SELECT substr(period_month, 1, 4) AS ym, SUM(amount) AS total FROM expenses WHERE deleted_at IS NULL AND period_month >= ?1 AND period_month <= ?2 AND ${generatedlotFilter.sql} GROUP BY ym ORDER BY ym',
      variables: [
        Variable<String>(fromYm),
        Variable<String>(toYm),
        ...generatedlotFilter.introducedVariables,
      ],
      readsFrom: {this.expenses, ...generatedlotFilter.watchedTables},
    ).map(
      (QueryRow row) => ExpensesByYearResult(
        ym: row.read<String>('ym'),
        total: row.readNullable<int>('total'),
      ),
    );
  }

  Selectable<ExpensesByDayResult> expensesByDay({
    required Day from,
    required Day to,
    ExpensesByDay$lotFilter? lotFilter,
  }) {
    var $arrayStartIndex = 3;
    final generatedlotFilter = $write(
      lotFilter?.call(this.expenses) ?? const CustomExpression('(TRUE)'),
      startIndex: $arrayStartIndex,
    );
    $arrayStartIndex += generatedlotFilter.amountOfVariables;
    return customSelect(
      'SELECT strftime(\'%Y-%m-%d\', incurred_on, \'unixepoch\') AS ym, SUM(amount) AS total FROM expenses WHERE deleted_at IS NULL AND incurred_on >= ?1 AND incurred_on < ?2 AND ${generatedlotFilter.sql} GROUP BY ym ORDER BY ym',
      variables: [
        Variable<DateTime>($ExpensesTable.$converterincurredOn.toSql(from)),
        Variable<DateTime>($ExpensesTable.$converterincurredOn.toSql(to)),
        ...generatedlotFilter.introducedVariables,
      ],
      readsFrom: {this.expenses, ...generatedlotFilter.watchedTables},
    ).map(
      (QueryRow row) => ExpensesByDayResult(
        ym: row.read<String>('ym'),
        total: row.readNullable<int>('total'),
      ),
    );
  }

  Selectable<ExpensesByCategoryResult> expensesByCategory({
    required String fromYm,
    required String toYm,
    ExpensesByCategory$lotFilter? lotFilter,
  }) {
    var $arrayStartIndex = 3;
    final generatedlotFilter = $write(
      lotFilter?.call(this.expenses) ?? const CustomExpression('(TRUE)'),
      startIndex: $arrayStartIndex,
    );
    $arrayStartIndex += generatedlotFilter.amountOfVariables;
    return customSelect(
      'SELECT category, SUM(amount) AS total FROM expenses WHERE deleted_at IS NULL AND period_month >= ?1 AND period_month <= ?2 AND ${generatedlotFilter.sql} GROUP BY category ORDER BY total DESC',
      variables: [
        Variable<String>(fromYm),
        Variable<String>(toYm),
        ...generatedlotFilter.introducedVariables,
      ],
      readsFrom: {this.expenses, ...generatedlotFilter.watchedTables},
    ).map(
      (QueryRow row) => ExpensesByCategoryResult(
        category: $ExpensesTable.$convertercategory.fromSql(
          row.read<int>('category'),
        ),
        total: row.readNullable<int>('total'),
      ),
    );
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    lots,
    vehicles,
    payments,
    paymentAllocations,
    recurringCostTemplates,
    expenses,
    idxVehiclesLotStatus,
    idxVehiclesPeriodEnd,
    idxVehiclesPlateNorm,
    idxVehiclesOwnerFold,
    idxVehiclesPhoneDigits,
    uqVehiclesActivePlate,
    idxPaymentsVehicle,
    idxPaymentsLotPaid,
    idxPaymentsPaid,
    idxAllocMonth,
    idxAllocLotMonth,
    idxExpensesLotMonth,
    idxExpensesIncurred,
    uqExpenseTemplateMonth,
    activityLog,
    idxLogAt,
    appSettings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vehicles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('payments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'payments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('payment_allocations', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'lots',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('recurring_cost_templates', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recurring_cost_templates',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('expenses', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$LotsTableCreateCompanionBuilder = LotsCompanion Function({
  Value<int> id,
  required String name,
  required String nameFold,
  Value<String?> address,
  Value<int> defaultPrice,
  Value<int?> capacity,
  Value<String?> notes,
  Value<bool> isActive,
  Value<int> sortOrder,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
});
typedef $$LotsTableUpdateCompanionBuilder = LotsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> nameFold,
  Value<String?> address,
  Value<int> defaultPrice,
  Value<int?> capacity,
  Value<String?> notes,
  Value<bool> isActive,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
});

final class $$LotsTableReferences
    extends BaseReferences<_$AppDatabase, $LotsTable, LotRow> {
  $$LotsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VehiclesTable, List<VehicleRow>>
  _vehiclesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.vehicles,
    aliasName: 'lots__id__vehicles__lot_id',
  );

  $$VehiclesTableProcessedTableManager get vehiclesRefs {
    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.lotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_vehiclesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<PaymentRow>>
  _paymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: 'lots__id__payments__lot_id',
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.lotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RecurringCostTemplatesTable,
    List<RecurringCostTemplateRow>
  >
  _recurringCostTemplatesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurringCostTemplates,
        aliasName: 'lots__id__recurring_cost_templates__lot_id',
      );

  $$RecurringCostTemplatesTableProcessedTableManager
  get recurringCostTemplatesRefs {
    final manager = $$RecurringCostTemplatesTableTableManager(
      $_db,
      $_db.recurringCostTemplates,
    ).filter((f) => f.lotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recurringCostTemplatesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<ExpenseRow>>
  _expensesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'lots__id__expenses__lot_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.lotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LotsTableFilterComposer extends Composer<_$AppDatabase, $LotsTable> {
  $$LotsTableFilterComposer({
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

  ColumnFilters<String> get nameFold => $composableBuilder(
    column: $table.nameFold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultPrice => $composableBuilder(
    column: $table.defaultPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> vehiclesRefs(
    Expression<bool> Function($$VehiclesTableFilterComposer f) f,
  ) {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.lotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.lotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recurringCostTemplatesRefs(
    Expression<bool> Function($$RecurringCostTemplatesTableFilterComposer f) f,
  ) {
    final $$RecurringCostTemplatesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringCostTemplates,
          getReferencedColumn: (t) => t.lotId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringCostTemplatesTableFilterComposer(
                $db: $db,
                $table: $db.recurringCostTemplates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.lotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LotsTableOrderingComposer extends Composer<_$AppDatabase, $LotsTable> {
  $$LotsTableOrderingComposer({
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

  ColumnOrderings<String> get nameFold => $composableBuilder(
    column: $table.nameFold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultPrice => $composableBuilder(
    column: $table.defaultPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LotsTable> {
  $$LotsTableAnnotationComposer({
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

  GeneratedColumn<String> get nameFold =>
      $composableBuilder(column: $table.nameFold, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<int> get defaultPrice => $composableBuilder(
    column: $table.defaultPrice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get capacity =>
      $composableBuilder(column: $table.capacity, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> vehiclesRefs<T extends Object>(
    Expression<T> Function($$VehiclesTableAnnotationComposer a) f,
  ) {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.lotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.lotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recurringCostTemplatesRefs<T extends Object>(
    Expression<T> Function($$RecurringCostTemplatesTableAnnotationComposer a) f,
  ) {
    final $$RecurringCostTemplatesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringCostTemplates,
          getReferencedColumn: (t) => t.lotId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringCostTemplatesTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringCostTemplates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.lotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LotsTable,
          LotRow,
          $$LotsTableFilterComposer,
          $$LotsTableOrderingComposer,
          $$LotsTableAnnotationComposer,
          $$LotsTableCreateCompanionBuilder,
          $$LotsTableUpdateCompanionBuilder,
          (LotRow, $$LotsTableReferences),
          LotRow,
          PrefetchHooks Function({
            bool vehiclesRefs,
            bool paymentsRefs,
            bool recurringCostTemplatesRefs,
            bool expensesRefs,
          })
        > {
  $$LotsTableTableManager(_$AppDatabase db, $LotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameFold = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<int> defaultPrice = const Value.absent(),
                Value<int?> capacity = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => LotsCompanion(
                id: id,
                name: name,
                nameFold: nameFold,
                address: address,
                defaultPrice: defaultPrice,
                capacity: capacity,
                notes: notes,
                isActive: isActive,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String nameFold,
                Value<String?> address = const Value.absent(),
                Value<int> defaultPrice = const Value.absent(),
                Value<int?> capacity = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => LotsCompanion.insert(
                id: id,
                name: name,
                nameFold: nameFold,
                address: address,
                defaultPrice: defaultPrice,
                capacity: capacity,
                notes: notes,
                isActive: isActive,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LotsTable, LotRow>(table),
                  $$LotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                vehiclesRefs = false,
                paymentsRefs = false,
                recurringCostTemplatesRefs = false,
                expensesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (vehiclesRefs) db.vehicles,
                    if (paymentsRefs) db.payments,
                    if (recurringCostTemplatesRefs) db.recurringCostTemplates,
                    if (expensesRefs) db.expenses,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (vehiclesRefs)
                        await $_getPrefetchedData<
                          LotRow,
                          $LotsTable,
                          VehicleRow
                        >(
                          currentTable: table,
                          referencedTable: $$LotsTableReferences
                              ._vehiclesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LotsTableReferences(db, table, p0).vehiclesRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.lotId == item.id),
                          typedResults: items,
                        ),
                      if (paymentsRefs)
                        await $_getPrefetchedData<
                          LotRow,
                          $LotsTable,
                          PaymentRow
                        >(
                          currentTable: table,
                          referencedTable: $$LotsTableReferences
                              ._paymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LotsTableReferences(db, table, p0).paymentsRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.lotId == item.id),
                          typedResults: items,
                        ),
                      if (recurringCostTemplatesRefs)
                        await $_getPrefetchedData<
                          LotRow,
                          $LotsTable,
                          RecurringCostTemplateRow
                        >(
                          currentTable: table,
                          referencedTable: $$LotsTableReferences
                              ._recurringCostTemplatesRefsTable(db),
                          managerFromTypedResult: (p0) => $$LotsTableReferences(
                            db,
                            table,
                            p0,
                          ).recurringCostTemplatesRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.lotId == item.id),
                          typedResults: items,
                        ),
                      if (expensesRefs)
                        await $_getPrefetchedData<
                          LotRow,
                          $LotsTable,
                          ExpenseRow
                        >(
                          currentTable: table,
                          referencedTable: $$LotsTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LotsTableReferences(db, table, p0).expensesRefs,
                          referencedItemsForCurrentItem: (
                            item,
                            referencedItems,
                          ) => referencedItems.where((e) => e.lotId == item.id),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LotsTable,
      LotRow,
      $$LotsTableFilterComposer,
      $$LotsTableOrderingComposer,
      $$LotsTableAnnotationComposer,
      $$LotsTableCreateCompanionBuilder,
      $$LotsTableUpdateCompanionBuilder,
      (LotRow, $$LotsTableReferences),
      LotRow,
      PrefetchHooks Function({
        bool vehiclesRefs,
        bool paymentsRefs,
        bool recurringCostTemplatesRefs,
        bool expensesRefs,
      })
    >;
typedef $$VehiclesTableCreateCompanionBuilder = VehiclesCompanion Function({
  Value<int> id,
  required int lotId,
  required String ownerName,
  required String ownerNameFold,
  Value<String?> phone,
  Value<String?> phoneDigits,
  required VehicleType vehicleType,
  required String plate,
  required String plateNormalized,
  required int monthlyPrice,
  required Day startDate,
  required int anchorDay,
  Value<VehicleStatus> status,
  Value<Day?> leftOn,
  Value<Day?> currentPeriodEnd,
  Value<Day?> lastPaymentDate,
  Value<int> totalMonthsPaid,
  Value<int> totalPaid,
  Value<DateTime?> lastRemindedAt,
  Value<Day?> remindedForPeriodEnd,
  Value<String?> notes,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
});
typedef $$VehiclesTableUpdateCompanionBuilder = VehiclesCompanion Function({
  Value<int> id,
  Value<int> lotId,
  Value<String> ownerName,
  Value<String> ownerNameFold,
  Value<String?> phone,
  Value<String?> phoneDigits,
  Value<VehicleType> vehicleType,
  Value<String> plate,
  Value<String> plateNormalized,
  Value<int> monthlyPrice,
  Value<Day> startDate,
  Value<int> anchorDay,
  Value<VehicleStatus> status,
  Value<Day?> leftOn,
  Value<Day?> currentPeriodEnd,
  Value<Day?> lastPaymentDate,
  Value<int> totalMonthsPaid,
  Value<int> totalPaid,
  Value<DateTime?> lastRemindedAt,
  Value<Day?> remindedForPeriodEnd,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
});

final class $$VehiclesTableReferences
    extends BaseReferences<_$AppDatabase, $VehiclesTable, VehicleRow> {
  $$VehiclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LotsTable _lotIdTable(_$AppDatabase db) =>
      db.lots.createAlias('vehicles__lot_id__lots__id');

  $$LotsTableProcessedTableManager get lotId {
    final $_column = $_itemColumn<int>('lot_id')!;

    final manager = $$LotsTableTableManager(
      $_db,
      $_db.lots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<PaymentRow>>
  _paymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: 'vehicles__id__payments__vehicle_id',
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
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

  ColumnFilters<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerNameFold => $composableBuilder(
    column: $table.ownerNameFold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneDigits => $composableBuilder(
    column: $table.phoneDigits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<VehicleType, VehicleType, int>
  get vehicleType => $composableBuilder(
    column: $table.vehicleType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get plate => $composableBuilder(
    column: $table.plate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plateNormalized => $composableBuilder(
    column: $table.plateNormalized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlyPrice => $composableBuilder(
    column: $table.monthlyPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Day, Day, DateTime> get startDate =>
      $composableBuilder(
        column: $table.startDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get anchorDay => $composableBuilder(
    column: $table.anchorDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<VehicleStatus, VehicleStatus, int>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Day?, Day, DateTime> get leftOn =>
      $composableBuilder(
        column: $table.leftOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Day?, Day, DateTime> get currentPeriodEnd =>
      $composableBuilder(
        column: $table.currentPeriodEnd,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Day?, Day, DateTime> get lastPaymentDate =>
      $composableBuilder(
        column: $table.lastPaymentDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get totalMonthsPaid => $composableBuilder(
    column: $table.totalMonthsPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPaid => $composableBuilder(
    column: $table.totalPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastRemindedAt => $composableBuilder(
    column: $table.lastRemindedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Day?, Day, DateTime>
  get remindedForPeriodEnd => $composableBuilder(
    column: $table.remindedForPeriodEnd,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LotsTableFilterComposer get lotId {
    final $$LotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lotId,
      referencedTable: $db.lots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotsTableFilterComposer(
            $db: $db,
            $table: $db.lots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
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

  ColumnOrderings<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerNameFold => $composableBuilder(
    column: $table.ownerNameFold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneDigits => $composableBuilder(
    column: $table.phoneDigits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vehicleType => $composableBuilder(
    column: $table.vehicleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plate => $composableBuilder(
    column: $table.plate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plateNormalized => $composableBuilder(
    column: $table.plateNormalized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlyPrice => $composableBuilder(
    column: $table.monthlyPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anchorDay => $composableBuilder(
    column: $table.anchorDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get leftOn => $composableBuilder(
    column: $table.leftOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get currentPeriodEnd => $composableBuilder(
    column: $table.currentPeriodEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPaymentDate => $composableBuilder(
    column: $table.lastPaymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMonthsPaid => $composableBuilder(
    column: $table.totalMonthsPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPaid => $composableBuilder(
    column: $table.totalPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastRemindedAt => $composableBuilder(
    column: $table.lastRemindedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get remindedForPeriodEnd => $composableBuilder(
    column: $table.remindedForPeriodEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LotsTableOrderingComposer get lotId {
    final $$LotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lotId,
      referencedTable: $db.lots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotsTableOrderingComposer(
            $db: $db,
            $table: $db.lots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerName =>
      $composableBuilder(column: $table.ownerName, builder: (column) => column);

  GeneratedColumn<String> get ownerNameFold => $composableBuilder(
    column: $table.ownerNameFold,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get phoneDigits => $composableBuilder(
    column: $table.phoneDigits,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<VehicleType, int> get vehicleType =>
      $composableBuilder(
        column: $table.vehicleType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get plate =>
      $composableBuilder(column: $table.plate, builder: (column) => column);

  GeneratedColumn<String> get plateNormalized => $composableBuilder(
    column: $table.plateNormalized,
    builder: (column) => column,
  );

  GeneratedColumn<int> get monthlyPrice => $composableBuilder(
    column: $table.monthlyPrice,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Day, DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get anchorDay =>
      $composableBuilder(column: $table.anchorDay, builder: (column) => column);

  GeneratedColumnWithTypeConverter<VehicleStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Day?, DateTime> get leftOn =>
      $composableBuilder(column: $table.leftOn, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Day?, DateTime> get currentPeriodEnd =>
      $composableBuilder(
        column: $table.currentPeriodEnd,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Day?, DateTime> get lastPaymentDate =>
      $composableBuilder(
        column: $table.lastPaymentDate,
        builder: (column) => column,
      );

  GeneratedColumn<int> get totalMonthsPaid => $composableBuilder(
    column: $table.totalMonthsPaid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalPaid =>
      $composableBuilder(column: $table.totalPaid, builder: (column) => column);

  GeneratedColumn<DateTime> get lastRemindedAt => $composableBuilder(
    column: $table.lastRemindedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Day?, DateTime> get remindedForPeriodEnd =>
      $composableBuilder(
        column: $table.remindedForPeriodEnd,
        builder: (column) => column,
      );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$LotsTableAnnotationComposer get lotId {
    final $$LotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lotId,
      referencedTable: $db.lots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotsTableAnnotationComposer(
            $db: $db,
            $table: $db.lots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiclesTable,
          VehicleRow,
          $$VehiclesTableFilterComposer,
          $$VehiclesTableOrderingComposer,
          $$VehiclesTableAnnotationComposer,
          $$VehiclesTableCreateCompanionBuilder,
          $$VehiclesTableUpdateCompanionBuilder,
          (VehicleRow, $$VehiclesTableReferences),
          VehicleRow,
          PrefetchHooks Function({bool lotId, bool paymentsRefs})
        > {
  $$VehiclesTableTableManager(_$AppDatabase db, $VehiclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> lotId = const Value.absent(),
                Value<String> ownerName = const Value.absent(),
                Value<String> ownerNameFold = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> phoneDigits = const Value.absent(),
                Value<VehicleType> vehicleType = const Value.absent(),
                Value<String> plate = const Value.absent(),
                Value<String> plateNormalized = const Value.absent(),
                Value<int> monthlyPrice = const Value.absent(),
                Value<Day> startDate = const Value.absent(),
                Value<int> anchorDay = const Value.absent(),
                Value<VehicleStatus> status = const Value.absent(),
                Value<Day?> leftOn = const Value.absent(),
                Value<Day?> currentPeriodEnd = const Value.absent(),
                Value<Day?> lastPaymentDate = const Value.absent(),
                Value<int> totalMonthsPaid = const Value.absent(),
                Value<int> totalPaid = const Value.absent(),
                Value<DateTime?> lastRemindedAt = const Value.absent(),
                Value<Day?> remindedForPeriodEnd = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => VehiclesCompanion(
                id: id,
                lotId: lotId,
                ownerName: ownerName,
                ownerNameFold: ownerNameFold,
                phone: phone,
                phoneDigits: phoneDigits,
                vehicleType: vehicleType,
                plate: plate,
                plateNormalized: plateNormalized,
                monthlyPrice: monthlyPrice,
                startDate: startDate,
                anchorDay: anchorDay,
                status: status,
                leftOn: leftOn,
                currentPeriodEnd: currentPeriodEnd,
                lastPaymentDate: lastPaymentDate,
                totalMonthsPaid: totalMonthsPaid,
                totalPaid: totalPaid,
                lastRemindedAt: lastRemindedAt,
                remindedForPeriodEnd: remindedForPeriodEnd,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int lotId,
                required String ownerName,
                required String ownerNameFold,
                Value<String?> phone = const Value.absent(),
                Value<String?> phoneDigits = const Value.absent(),
                required VehicleType vehicleType,
                required String plate,
                required String plateNormalized,
                required int monthlyPrice,
                required Day startDate,
                required int anchorDay,
                Value<VehicleStatus> status = const Value.absent(),
                Value<Day?> leftOn = const Value.absent(),
                Value<Day?> currentPeriodEnd = const Value.absent(),
                Value<Day?> lastPaymentDate = const Value.absent(),
                Value<int> totalMonthsPaid = const Value.absent(),
                Value<int> totalPaid = const Value.absent(),
                Value<DateTime?> lastRemindedAt = const Value.absent(),
                Value<Day?> remindedForPeriodEnd = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => VehiclesCompanion.insert(
                id: id,
                lotId: lotId,
                ownerName: ownerName,
                ownerNameFold: ownerNameFold,
                phone: phone,
                phoneDigits: phoneDigits,
                vehicleType: vehicleType,
                plate: plate,
                plateNormalized: plateNormalized,
                monthlyPrice: monthlyPrice,
                startDate: startDate,
                anchorDay: anchorDay,
                status: status,
                leftOn: leftOn,
                currentPeriodEnd: currentPeriodEnd,
                lastPaymentDate: lastPaymentDate,
                totalMonthsPaid: totalMonthsPaid,
                totalPaid: totalPaid,
                lastRemindedAt: lastRemindedAt,
                remindedForPeriodEnd: remindedForPeriodEnd,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VehiclesTable, VehicleRow>(table),
                  $$VehiclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({lotId = false, paymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (paymentsRefs) db.payments],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (lotId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.lotId,
                        referencedTable: $$VehiclesTableReferences._lotIdTable(
                          db,
                        ),
                        referencedColumn: $$VehiclesTableReferences
                            ._lotIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (paymentsRefs)
                    await $_getPrefetchedData<
                      VehicleRow,
                      $VehiclesTable,
                      PaymentRow
                    >(
                      currentTable: table,
                      referencedTable: $$VehiclesTableReferences
                          ._paymentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$VehiclesTableReferences(db, table, p0).paymentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.vehicleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiclesTable,
      VehicleRow,
      $$VehiclesTableFilterComposer,
      $$VehiclesTableOrderingComposer,
      $$VehiclesTableAnnotationComposer,
      $$VehiclesTableCreateCompanionBuilder,
      $$VehiclesTableUpdateCompanionBuilder,
      (VehicleRow, $$VehiclesTableReferences),
      VehicleRow,
      PrefetchHooks Function({bool lotId, bool paymentsRefs})
    >;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  Value<int> id,
  required int vehicleId,
  required int lotId,
  required int amount,
  required int monthsPaid,
  required int unitPrice,
  required Day paidAt,
  required Day periodStart,
  required Day periodEnd,
  Value<PaymentMethod> method,
  Value<String?> note,
  Value<DateTime?> voidedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<int> id,
  Value<int> vehicleId,
  Value<int> lotId,
  Value<int> amount,
  Value<int> monthsPaid,
  Value<int> unitPrice,
  Value<Day> paidAt,
  Value<Day> periodStart,
  Value<Day> periodEnd,
  Value<PaymentMethod> method,
  Value<String?> note,
  Value<DateTime?> voidedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, PaymentRow> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias('payments__vehicle_id__vehicles__id');

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LotsTable _lotIdTable(_$AppDatabase db) =>
      db.lots.createAlias('payments__lot_id__lots__id');

  $$LotsTableProcessedTableManager get lotId {
    final $_column = $_itemColumn<int>('lot_id')!;

    final manager = $$LotsTableTableManager(
      $_db,
      $_db.lots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $PaymentAllocationsTable,
    List<PaymentAllocationRow>
  >
  _paymentAllocationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.paymentAllocations,
        aliasName: 'payments__id__payment_allocations__payment_id',
      );

  $$PaymentAllocationsTableProcessedTableManager get paymentAllocationsRefs {
    final manager = $$PaymentAllocationsTableTableManager(
      $_db,
      $_db.paymentAllocations,
    ).filter((f) => f.paymentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _paymentAllocationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
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

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthsPaid => $composableBuilder(
    column: $table.monthsPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Day, Day, DateTime> get paidAt =>
      $composableBuilder(
        column: $table.paidAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Day, Day, DateTime> get periodStart =>
      $composableBuilder(
        column: $table.periodStart,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Day, Day, DateTime> get periodEnd =>
      $composableBuilder(
        column: $table.periodEnd,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<PaymentMethod, PaymentMethod, int>
  get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
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

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LotsTableFilterComposer get lotId {
    final $$LotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lotId,
      referencedTable: $db.lots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotsTableFilterComposer(
            $db: $db,
            $table: $db.lots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paymentAllocationsRefs(
    Expression<bool> Function($$PaymentAllocationsTableFilterComposer f) f,
  ) {
    final $$PaymentAllocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentAllocations,
      getReferencedColumn: (t) => t.paymentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentAllocationsTableFilterComposer(
            $db: $db,
            $table: $db.paymentAllocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
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

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthsPaid => $composableBuilder(
    column: $table.monthsPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get periodEnd => $composableBuilder(
    column: $table.periodEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
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

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LotsTableOrderingComposer get lotId {
    final $$LotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lotId,
      referencedTable: $db.lots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotsTableOrderingComposer(
            $db: $db,
            $table: $db.lots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get monthsPaid => $composableBuilder(
    column: $table.monthsPaid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Day, DateTime> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Day, DateTime> get periodStart =>
      $composableBuilder(
        column: $table.periodStart,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Day, DateTime> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentMethod, int> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get voidedAt =>
      $composableBuilder(column: $table.voidedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LotsTableAnnotationComposer get lotId {
    final $$LotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lotId,
      referencedTable: $db.lots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotsTableAnnotationComposer(
            $db: $db,
            $table: $db.lots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paymentAllocationsRefs<T extends Object>(
    Expression<T> Function($$PaymentAllocationsTableAnnotationComposer a) f,
  ) {
    final $$PaymentAllocationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.paymentAllocations,
          getReferencedColumn: (t) => t.paymentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PaymentAllocationsTableAnnotationComposer(
                $db: $db,
                $table: $db.paymentAllocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          PaymentRow,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (PaymentRow, $$PaymentsTableReferences),
          PaymentRow,
          PrefetchHooks Function({
            bool vehicleId,
            bool lotId,
            bool paymentAllocationsRefs,
          })
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> vehicleId = const Value.absent(),
                Value<int> lotId = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<int> monthsPaid = const Value.absent(),
                Value<int> unitPrice = const Value.absent(),
                Value<Day> paidAt = const Value.absent(),
                Value<Day> periodStart = const Value.absent(),
                Value<Day> periodEnd = const Value.absent(),
                Value<PaymentMethod> method = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime?> voidedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                vehicleId: vehicleId,
                lotId: lotId,
                amount: amount,
                monthsPaid: monthsPaid,
                unitPrice: unitPrice,
                paidAt: paidAt,
                periodStart: periodStart,
                periodEnd: periodEnd,
                method: method,
                note: note,
                voidedAt: voidedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int vehicleId,
                required int lotId,
                required int amount,
                required int monthsPaid,
                required int unitPrice,
                required Day paidAt,
                required Day periodStart,
                required Day periodEnd,
                Value<PaymentMethod> method = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime?> voidedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => PaymentsCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                lotId: lotId,
                amount: amount,
                monthsPaid: monthsPaid,
                unitPrice: unitPrice,
                paidAt: paidAt,
                periodStart: periodStart,
                periodEnd: periodEnd,
                method: method,
                note: note,
                voidedAt: voidedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PaymentsTable, PaymentRow>(table),
                  $$PaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                vehicleId = false,
                lotId = false,
                paymentAllocationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paymentAllocationsRefs) db.paymentAllocations,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (vehicleId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.vehicleId,
                            referencedTable: $$PaymentsTableReferences
                                ._vehicleIdTable(db),
                            referencedColumn: $$PaymentsTableReferences
                                ._vehicleIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (lotId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.lotId,
                            referencedTable: $$PaymentsTableReferences
                                ._lotIdTable(db),
                            referencedColumn: $$PaymentsTableReferences
                                ._lotIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paymentAllocationsRefs)
                        await $_getPrefetchedData<
                          PaymentRow,
                          $PaymentsTable,
                          PaymentAllocationRow
                        >(
                          currentTable: table,
                          referencedTable: $$PaymentsTableReferences
                              ._paymentAllocationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PaymentsTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentAllocationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.paymentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      PaymentRow,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (PaymentRow, $$PaymentsTableReferences),
      PaymentRow,
      PrefetchHooks Function({
        bool vehicleId,
        bool lotId,
        bool paymentAllocationsRefs,
      })
    >;
typedef $$PaymentAllocationsTableCreateCompanionBuilder =
    PaymentAllocationsCompanion Function({
      Value<int> id,
      required int paymentId,
      required int lotId,
      required int vehicleId,
      required String periodMonth,
      required Day periodMonthStart,
      required int amount,
    });
typedef $$PaymentAllocationsTableUpdateCompanionBuilder =
    PaymentAllocationsCompanion Function({
      Value<int> id,
      Value<int> paymentId,
      Value<int> lotId,
      Value<int> vehicleId,
      Value<String> periodMonth,
      Value<Day> periodMonthStart,
      Value<int> amount,
    });

final class $$PaymentAllocationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PaymentAllocationsTable,
          PaymentAllocationRow
        > {
  $$PaymentAllocationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PaymentsTable _paymentIdTable(_$AppDatabase db) =>
      db.payments.createAlias('payment_allocations__payment_id__payments__id');

  $$PaymentsTableProcessedTableManager get paymentId {
    final $_column = $_itemColumn<int>('payment_id')!;

    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paymentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentAllocationsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentAllocationsTable> {
  $$PaymentAllocationsTableFilterComposer({
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

  ColumnFilters<int> get lotId => $composableBuilder(
    column: $table.lotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodMonth => $composableBuilder(
    column: $table.periodMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Day, Day, DateTime> get periodMonthStart =>
      $composableBuilder(
        column: $table.periodMonthStart,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  $$PaymentsTableFilterComposer get paymentId {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentAllocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentAllocationsTable> {
  $$PaymentAllocationsTableOrderingComposer({
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

  ColumnOrderings<int> get lotId => $composableBuilder(
    column: $table.lotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodMonth => $composableBuilder(
    column: $table.periodMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get periodMonthStart => $composableBuilder(
    column: $table.periodMonthStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  $$PaymentsTableOrderingComposer get paymentId {
    final $$PaymentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableOrderingComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentAllocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentAllocationsTable> {
  $$PaymentAllocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lotId =>
      $composableBuilder(column: $table.lotId, builder: (column) => column);

  GeneratedColumn<int> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<String> get periodMonth => $composableBuilder(
    column: $table.periodMonth,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Day, DateTime> get periodMonthStart =>
      $composableBuilder(
        column: $table.periodMonthStart,
        builder: (column) => column,
      );

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  $$PaymentsTableAnnotationComposer get paymentId {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentAllocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentAllocationsTable,
          PaymentAllocationRow,
          $$PaymentAllocationsTableFilterComposer,
          $$PaymentAllocationsTableOrderingComposer,
          $$PaymentAllocationsTableAnnotationComposer,
          $$PaymentAllocationsTableCreateCompanionBuilder,
          $$PaymentAllocationsTableUpdateCompanionBuilder,
          (PaymentAllocationRow, $$PaymentAllocationsTableReferences),
          PaymentAllocationRow,
          PrefetchHooks Function({bool paymentId})
        > {
  $$PaymentAllocationsTableTableManager(
    _$AppDatabase db,
    $PaymentAllocationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentAllocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentAllocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentAllocationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> paymentId = const Value.absent(),
                Value<int> lotId = const Value.absent(),
                Value<int> vehicleId = const Value.absent(),
                Value<String> periodMonth = const Value.absent(),
                Value<Day> periodMonthStart = const Value.absent(),
                Value<int> amount = const Value.absent(),
              }) => PaymentAllocationsCompanion(
                id: id,
                paymentId: paymentId,
                lotId: lotId,
                vehicleId: vehicleId,
                periodMonth: periodMonth,
                periodMonthStart: periodMonthStart,
                amount: amount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int paymentId,
                required int lotId,
                required int vehicleId,
                required String periodMonth,
                required Day periodMonthStart,
                required int amount,
              }) => PaymentAllocationsCompanion.insert(
                id: id,
                paymentId: paymentId,
                lotId: lotId,
                vehicleId: vehicleId,
                periodMonth: periodMonth,
                periodMonthStart: periodMonthStart,
                amount: amount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PaymentAllocationsTable, PaymentAllocationRow>(
                    table,
                  ),
                  $$PaymentAllocationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({paymentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (paymentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.paymentId,
                        referencedTable: $$PaymentAllocationsTableReferences
                            ._paymentIdTable(db),
                        referencedColumn: $$PaymentAllocationsTableReferences
                            ._paymentIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PaymentAllocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentAllocationsTable,
      PaymentAllocationRow,
      $$PaymentAllocationsTableFilterComposer,
      $$PaymentAllocationsTableOrderingComposer,
      $$PaymentAllocationsTableAnnotationComposer,
      $$PaymentAllocationsTableCreateCompanionBuilder,
      $$PaymentAllocationsTableUpdateCompanionBuilder,
      (PaymentAllocationRow, $$PaymentAllocationsTableReferences),
      PaymentAllocationRow,
      PrefetchHooks Function({bool paymentId})
    >;
typedef $$RecurringCostTemplatesTableCreateCompanionBuilder =
    RecurringCostTemplatesCompanion Function({
      Value<int> id,
      required int lotId,
      required String name,
      required CostCategory category,
      required int amount,
      Value<int> dayOfMonth,
      required String startMonth,
      Value<String?> endMonth,
      Value<bool> isActive,
      Value<String?> note,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$RecurringCostTemplatesTableUpdateCompanionBuilder =
    RecurringCostTemplatesCompanion Function({
      Value<int> id,
      Value<int> lotId,
      Value<String> name,
      Value<CostCategory> category,
      Value<int> amount,
      Value<int> dayOfMonth,
      Value<String> startMonth,
      Value<String?> endMonth,
      Value<bool> isActive,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$RecurringCostTemplatesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RecurringCostTemplatesTable,
          RecurringCostTemplateRow
        > {
  $$RecurringCostTemplatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LotsTable _lotIdTable(_$AppDatabase db) =>
      db.lots.createAlias('recurring_cost_templates__lot_id__lots__id');

  $$LotsTableProcessedTableManager get lotId {
    final $_column = $_itemColumn<int>('lot_id')!;

    final manager = $$LotsTableTableManager(
      $_db,
      $_db.lots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<ExpenseRow>>
  _expensesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'recurring_cost_templates__id__expenses__source_template_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.sourceTemplateId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecurringCostTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringCostTemplatesTable> {
  $$RecurringCostTemplatesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<CostCategory, CostCategory, int>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startMonth => $composableBuilder(
    column: $table.startMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endMonth => $composableBuilder(
    column: $table.endMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
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

  $$LotsTableFilterComposer get lotId {
    final $$LotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lotId,
      referencedTable: $db.lots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotsTableFilterComposer(
            $db: $db,
            $table: $db.lots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.sourceTemplateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecurringCostTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringCostTemplatesTable> {
  $$RecurringCostTemplatesTableOrderingComposer({
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

  ColumnOrderings<int> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startMonth => $composableBuilder(
    column: $table.startMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endMonth => $composableBuilder(
    column: $table.endMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
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

  $$LotsTableOrderingComposer get lotId {
    final $$LotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lotId,
      referencedTable: $db.lots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotsTableOrderingComposer(
            $db: $db,
            $table: $db.lots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringCostTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringCostTemplatesTable> {
  $$RecurringCostTemplatesTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<CostCategory, int> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startMonth => $composableBuilder(
    column: $table.startMonth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endMonth =>
      $composableBuilder(column: $table.endMonth, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$LotsTableAnnotationComposer get lotId {
    final $$LotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lotId,
      referencedTable: $db.lots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotsTableAnnotationComposer(
            $db: $db,
            $table: $db.lots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.sourceTemplateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecurringCostTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringCostTemplatesTable,
          RecurringCostTemplateRow,
          $$RecurringCostTemplatesTableFilterComposer,
          $$RecurringCostTemplatesTableOrderingComposer,
          $$RecurringCostTemplatesTableAnnotationComposer,
          $$RecurringCostTemplatesTableCreateCompanionBuilder,
          $$RecurringCostTemplatesTableUpdateCompanionBuilder,
          (RecurringCostTemplateRow, $$RecurringCostTemplatesTableReferences),
          RecurringCostTemplateRow,
          PrefetchHooks Function({bool lotId, bool expensesRefs})
        > {
  $$RecurringCostTemplatesTableTableManager(
    _$AppDatabase db,
    $RecurringCostTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringCostTemplatesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RecurringCostTemplatesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecurringCostTemplatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> lotId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<CostCategory> category = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<int> dayOfMonth = const Value.absent(),
                Value<String> startMonth = const Value.absent(),
                Value<String?> endMonth = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RecurringCostTemplatesCompanion(
                id: id,
                lotId: lotId,
                name: name,
                category: category,
                amount: amount,
                dayOfMonth: dayOfMonth,
                startMonth: startMonth,
                endMonth: endMonth,
                isActive: isActive,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int lotId,
                required String name,
                required CostCategory category,
                required int amount,
                Value<int> dayOfMonth = const Value.absent(),
                required String startMonth,
                Value<String?> endMonth = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => RecurringCostTemplatesCompanion.insert(
                id: id,
                lotId: lotId,
                name: name,
                category: category,
                amount: amount,
                dayOfMonth: dayOfMonth,
                startMonth: startMonth,
                endMonth: endMonth,
                isActive: isActive,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $RecurringCostTemplatesTable,
                    RecurringCostTemplateRow
                  >(table),
                  $$RecurringCostTemplatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({lotId = false, expensesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (expensesRefs) db.expenses],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (lotId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.lotId,
                        referencedTable: $$RecurringCostTemplatesTableReferences
                            ._lotIdTable(db),
                        referencedColumn:
                            $$RecurringCostTemplatesTableReferences
                                ._lotIdTable(db)
                                .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expensesRefs)
                    await $_getPrefetchedData<
                      RecurringCostTemplateRow,
                      $RecurringCostTemplatesTable,
                      ExpenseRow
                    >(
                      currentTable: table,
                      referencedTable: $$RecurringCostTemplatesTableReferences
                          ._expensesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RecurringCostTemplatesTableReferences(
                            db,
                            table,
                            p0,
                          ).expensesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.sourceTemplateId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RecurringCostTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringCostTemplatesTable,
      RecurringCostTemplateRow,
      $$RecurringCostTemplatesTableFilterComposer,
      $$RecurringCostTemplatesTableOrderingComposer,
      $$RecurringCostTemplatesTableAnnotationComposer,
      $$RecurringCostTemplatesTableCreateCompanionBuilder,
      $$RecurringCostTemplatesTableUpdateCompanionBuilder,
      (RecurringCostTemplateRow, $$RecurringCostTemplatesTableReferences),
      RecurringCostTemplateRow,
      PrefetchHooks Function({bool lotId, bool expensesRefs})
    >;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  required int lotId,
  required String name,
  required CostCategory category,
  required ExpenseKind kind,
  required int amount,
  required Day incurredOn,
  required String periodMonth,
  Value<int?> sourceTemplateId,
  Value<bool> isEdited,
  Value<String?> note,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  Value<int> lotId,
  Value<String> name,
  Value<CostCategory> category,
  Value<ExpenseKind> kind,
  Value<int> amount,
  Value<Day> incurredOn,
  Value<String> periodMonth,
  Value<int?> sourceTemplateId,
  Value<bool> isEdited,
  Value<String?> note,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
});

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, ExpenseRow> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LotsTable _lotIdTable(_$AppDatabase db) =>
      db.lots.createAlias('expenses__lot_id__lots__id');

  $$LotsTableProcessedTableManager get lotId {
    final $_column = $_itemColumn<int>('lot_id')!;

    final manager = $$LotsTableTableManager(
      $_db,
      $_db.lots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RecurringCostTemplatesTable _sourceTemplateIdTable(
    _$AppDatabase db,
  ) => db.recurringCostTemplates.createAlias(
    'expenses__source_template_id__recurring_cost_templates__id',
  );

  $$RecurringCostTemplatesTableProcessedTableManager? get sourceTemplateId {
    final $_column = $_itemColumn<int>('source_template_id');
    if ($_column == null) return null;
    final manager = $$RecurringCostTemplatesTableTableManager(
      $_db,
      $_db.recurringCostTemplates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceTemplateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
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

  ColumnWithTypeConverterFilters<CostCategory, CostCategory, int>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ExpenseKind, ExpenseKind, int> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Day, Day, DateTime> get incurredOn =>
      $composableBuilder(
        column: $table.incurredOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get periodMonth => $composableBuilder(
    column: $table.periodMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEdited => $composableBuilder(
    column: $table.isEdited,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LotsTableFilterComposer get lotId {
    final $$LotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lotId,
      referencedTable: $db.lots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotsTableFilterComposer(
            $db: $db,
            $table: $db.lots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringCostTemplatesTableFilterComposer get sourceTemplateId {
    final $$RecurringCostTemplatesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sourceTemplateId,
          referencedTable: $db.recurringCostTemplates,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringCostTemplatesTableFilterComposer(
                $db: $db,
                $table: $db.recurringCostTemplates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
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

  ColumnOrderings<int> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get incurredOn => $composableBuilder(
    column: $table.incurredOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodMonth => $composableBuilder(
    column: $table.periodMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEdited => $composableBuilder(
    column: $table.isEdited,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LotsTableOrderingComposer get lotId {
    final $$LotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lotId,
      referencedTable: $db.lots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotsTableOrderingComposer(
            $db: $db,
            $table: $db.lots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringCostTemplatesTableOrderingComposer get sourceTemplateId {
    final $$RecurringCostTemplatesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sourceTemplateId,
          referencedTable: $db.recurringCostTemplates,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringCostTemplatesTableOrderingComposer(
                $db: $db,
                $table: $db.recurringCostTemplates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<CostCategory, int> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExpenseKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Day, DateTime> get incurredOn =>
      $composableBuilder(
        column: $table.incurredOn,
        builder: (column) => column,
      );

  GeneratedColumn<String> get periodMonth => $composableBuilder(
    column: $table.periodMonth,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEdited =>
      $composableBuilder(column: $table.isEdited, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$LotsTableAnnotationComposer get lotId {
    final $$LotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lotId,
      referencedTable: $db.lots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LotsTableAnnotationComposer(
            $db: $db,
            $table: $db.lots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringCostTemplatesTableAnnotationComposer get sourceTemplateId {
    final $$RecurringCostTemplatesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.sourceTemplateId,
          referencedTable: $db.recurringCostTemplates,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringCostTemplatesTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringCostTemplates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          ExpenseRow,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (ExpenseRow, $$ExpensesTableReferences),
          ExpenseRow,
          PrefetchHooks Function({bool lotId, bool sourceTemplateId})
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> lotId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<CostCategory> category = const Value.absent(),
                Value<ExpenseKind> kind = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<Day> incurredOn = const Value.absent(),
                Value<String> periodMonth = const Value.absent(),
                Value<int?> sourceTemplateId = const Value.absent(),
                Value<bool> isEdited = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                lotId: lotId,
                name: name,
                category: category,
                kind: kind,
                amount: amount,
                incurredOn: incurredOn,
                periodMonth: periodMonth,
                sourceTemplateId: sourceTemplateId,
                isEdited: isEdited,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int lotId,
                required String name,
                required CostCategory category,
                required ExpenseKind kind,
                required int amount,
                required Day incurredOn,
                required String periodMonth,
                Value<int?> sourceTemplateId = const Value.absent(),
                Value<bool> isEdited = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                lotId: lotId,
                name: name,
                category: category,
                kind: kind,
                amount: amount,
                incurredOn: incurredOn,
                periodMonth: periodMonth,
                sourceTemplateId: sourceTemplateId,
                isEdited: isEdited,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpensesTable, ExpenseRow>(table),
                  $$ExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({lotId = false, sourceTemplateId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (lotId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.lotId,
                        referencedTable: $$ExpensesTableReferences._lotIdTable(
                          db,
                        ),
                        referencedColumn: $$ExpensesTableReferences
                            ._lotIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (sourceTemplateId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sourceTemplateId,
                        referencedTable: $$ExpensesTableReferences
                            ._sourceTemplateIdTable(db),
                        referencedColumn: $$ExpensesTableReferences
                            ._sourceTemplateIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      ExpenseRow,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (ExpenseRow, $$ExpensesTableReferences),
      ExpenseRow,
      PrefetchHooks Function({bool lotId, bool sourceTemplateId})
    >;
typedef $$ActivityLogTableCreateCompanionBuilder =
    ActivityLogCompanion Function({
      Value<int> id,
      required DateTime at,
      required LogAction action,
      required LogEntity entityType,
      Value<int?> entityId,
      Value<int?> lotId,
      required String summary,
      Value<String?> detailsJson,
    });
typedef $$ActivityLogTableUpdateCompanionBuilder =
    ActivityLogCompanion Function({
      Value<int> id,
      Value<DateTime> at,
      Value<LogAction> action,
      Value<LogEntity> entityType,
      Value<int?> entityId,
      Value<int?> lotId,
      Value<String> summary,
      Value<String?> detailsJson,
    });

class $$ActivityLogTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityLogTable> {
  $$ActivityLogTableFilterComposer({
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

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LogAction, LogAction, int> get action =>
      $composableBuilder(
        column: $table.action,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<LogEntity, LogEntity, int> get entityType =>
      $composableBuilder(
        column: $table.entityType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lotId => $composableBuilder(
    column: $table.lotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivityLogTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityLogTable> {
  $$ActivityLogTableOrderingComposer({
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

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lotId => $composableBuilder(
    column: $table.lotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivityLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityLogTable> {
  $$ActivityLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LogAction, int> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LogEntity, int> get entityType =>
      $composableBuilder(
        column: $table.entityType,
        builder: (column) => column,
      );

  GeneratedColumn<int> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<int> get lotId =>
      $composableBuilder(column: $table.lotId, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => column,
  );
}

class $$ActivityLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivityLogTable,
          ActivityLogRow,
          $$ActivityLogTableFilterComposer,
          $$ActivityLogTableOrderingComposer,
          $$ActivityLogTableAnnotationComposer,
          $$ActivityLogTableCreateCompanionBuilder,
          $$ActivityLogTableUpdateCompanionBuilder,
          (
            ActivityLogRow,
            BaseReferences<_$AppDatabase, $ActivityLogTable, ActivityLogRow>,
          ),
          ActivityLogRow,
          PrefetchHooks Function()
        > {
  $$ActivityLogTableTableManager(_$AppDatabase db, $ActivityLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<LogAction> action = const Value.absent(),
                Value<LogEntity> entityType = const Value.absent(),
                Value<int?> entityId = const Value.absent(),
                Value<int?> lotId = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String?> detailsJson = const Value.absent(),
              }) => ActivityLogCompanion(
                id: id,
                at: at,
                action: action,
                entityType: entityType,
                entityId: entityId,
                lotId: lotId,
                summary: summary,
                detailsJson: detailsJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime at,
                required LogAction action,
                required LogEntity entityType,
                Value<int?> entityId = const Value.absent(),
                Value<int?> lotId = const Value.absent(),
                required String summary,
                Value<String?> detailsJson = const Value.absent(),
              }) => ActivityLogCompanion.insert(
                id: id,
                at: at,
                action: action,
                entityType: entityType,
                entityId: entityId,
                lotId: lotId,
                summary: summary,
                detailsJson: detailsJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActivityLogTable, ActivityLogRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ActivityLogTable,
                    ActivityLogRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivityLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivityLogTable,
      ActivityLogRow,
      $$ActivityLogTableFilterComposer,
      $$ActivityLogTableOrderingComposer,
      $$ActivityLogTableAnnotationComposer,
      $$ActivityLogTableCreateCompanionBuilder,
      $$ActivityLogTableUpdateCompanionBuilder,
      (
        ActivityLogRow,
        BaseReferences<_$AppDatabase, $ActivityLogTable, ActivityLogRow>,
      ),
      ActivityLogRow,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
          ),
          AppSettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSettingRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppSettingsTable,
                    AppSettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
      ),
      AppSettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LotsTableTableManager get lots => $$LotsTableTableManager(_db, _db.lots);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$PaymentAllocationsTableTableManager get paymentAllocations =>
      $$PaymentAllocationsTableTableManager(_db, _db.paymentAllocations);
  $$RecurringCostTemplatesTableTableManager get recurringCostTemplates =>
      $$RecurringCostTemplatesTableTableManager(
        _db,
        _db.recurringCostTemplates,
      );
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$ActivityLogTableTableManager get activityLog =>
      $$ActivityLogTableTableManager(_db, _db.activityLog);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}

class RevenueCashByDayResult {
  final String ym;
  final int? total;
  RevenueCashByDayResult({required this.ym, this.total});
}

typedef RevenueCashByDay$lotFilter = Expression<bool> Function(
  $PaymentsTable payments,
);

class RevenueCashByMonthResult {
  final String ym;
  final int? total;
  RevenueCashByMonthResult({required this.ym, this.total});
}

typedef RevenueCashByMonth$lotFilter = Expression<bool> Function(
  $PaymentsTable payments,
);

class RevenueCashByQuarterResult {
  final String ym;
  final int? total;
  RevenueCashByQuarterResult({required this.ym, this.total});
}

typedef RevenueCashByQuarter$lotFilter = Expression<bool> Function(
  $PaymentsTable payments,
);

class RevenueCashByYearResult {
  final String ym;
  final int? total;
  RevenueCashByYearResult({required this.ym, this.total});
}

typedef RevenueCashByYear$lotFilter = Expression<bool> Function(
  $PaymentsTable payments,
);

class RevenueAccrualByMonthResult {
  final String ym;
  final int? total;
  RevenueAccrualByMonthResult({required this.ym, this.total});
}

typedef RevenueAccrualByMonth$lotFilter = Expression<bool> Function(
  $PaymentAllocationsTable a,
  $PaymentsTable p,
);

class RevenueAccrualByQuarterResult {
  final String ym;
  final int? total;
  RevenueAccrualByQuarterResult({required this.ym, this.total});
}

typedef RevenueAccrualByQuarter$lotFilter = Expression<bool> Function(
  $PaymentAllocationsTable a,
  $PaymentsTable p,
);

class RevenueAccrualByYearResult {
  final String ym;
  final int? total;
  RevenueAccrualByYearResult({required this.ym, this.total});
}

typedef RevenueAccrualByYear$lotFilter = Expression<bool> Function(
  $PaymentAllocationsTable a,
  $PaymentsTable p,
);

class ExpensesByMonthResult {
  final String ym;
  final int? total;
  ExpensesByMonthResult({required this.ym, this.total});
}

typedef ExpensesByMonth$lotFilter = Expression<bool> Function(
  $ExpensesTable expenses,
);

class ExpensesByQuarterResult {
  final String ym;
  final int? total;
  ExpensesByQuarterResult({required this.ym, this.total});
}

typedef ExpensesByQuarter$lotFilter = Expression<bool> Function(
  $ExpensesTable expenses,
);

class ExpensesByYearResult {
  final String ym;
  final int? total;
  ExpensesByYearResult({required this.ym, this.total});
}

typedef ExpensesByYear$lotFilter = Expression<bool> Function(
  $ExpensesTable expenses,
);

class ExpensesByDayResult {
  final String ym;
  final int? total;
  ExpensesByDayResult({required this.ym, this.total});
}

typedef ExpensesByDay$lotFilter = Expression<bool> Function(
  $ExpensesTable expenses,
);

class ExpensesByCategoryResult {
  final CostCategory category;
  final int? total;
  ExpensesByCategoryResult({required this.category, this.total});
}

typedef ExpensesByCategory$lotFilter = Expression<bool> Function(
  $ExpensesTable expenses,
);
