// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CatsTable extends Cats with TableInfo<$CatsTable, Cat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _breedMeta = const VerificationMeta('breed');
  @override
  late final GeneratedColumn<String> breed = GeneratedColumn<String>(
    'breed',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CatSex, String> sex =
      GeneratedColumn<String>(
        'sex',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('female'),
      ).withConverter<CatSex>($CatsTable.$convertersex);
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chipNumberMeta = const VerificationMeta(
    'chipNumber',
  );
  @override
  late final GeneratedColumn<String> chipNumber = GeneratedColumn<String>(
    'chip_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bloodTypeMeta = const VerificationMeta(
    'bloodType',
  );
  @override
  late final GeneratedColumn<String> bloodType = GeneratedColumn<String>(
    'blood_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> allergies =
      GeneratedColumn<String>(
        'allergies',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<String>>($CatsTable.$converterallergies);
  static const VerificationMeta _vetIdMeta = const VerificationMeta('vetId');
  @override
  late final GeneratedColumn<int> vetId = GeneratedColumn<int>(
    'vet_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    breed,
    sex,
    birthDate,
    weightKg,
    chipNumber,
    photoPath,
    bloodType,
    allergies,
    vetId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cats';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cat> instance, {
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
    if (data.containsKey('breed')) {
      context.handle(
        _breedMeta,
        breed.isAcceptableOrUnknown(data['breed']!, _breedMeta),
      );
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('chip_number')) {
      context.handle(
        _chipNumberMeta,
        chipNumber.isAcceptableOrUnknown(data['chip_number']!, _chipNumberMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('blood_type')) {
      context.handle(
        _bloodTypeMeta,
        bloodType.isAcceptableOrUnknown(data['blood_type']!, _bloodTypeMeta),
      );
    }
    if (data.containsKey('vet_id')) {
      context.handle(
        _vetIdMeta,
        vetId.isAcceptableOrUnknown(data['vet_id']!, _vetIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cat(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      breed: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}breed'],
      ),
      sex: $CatsTable.$convertersex.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sex'],
        )!,
      ),
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      chipNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chip_number'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      bloodType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blood_type'],
      ),
      allergies: $CatsTable.$converterallergies.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}allergies'],
        )!,
      ),
      vetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vet_id'],
      ),
    );
  }

  @override
  $CatsTable createAlias(String alias) {
    return $CatsTable(attachedDatabase, alias);
  }

  static TypeConverter<CatSex, String> $convertersex = const CatSexConverter();
  static TypeConverter<List<String>, String> $converterallergies =
      const StringListConverter();
}

class Cat extends DataClass implements Insertable<Cat> {
  final int id;
  final String name;
  final String? breed;
  final CatSex sex;
  final DateTime? birthDate;
  final double? weightKg;
  final String? chipNumber;
  final String? photoPath;
  final String? bloodType;
  final List<String> allergies;
  final int? vetId;
  const Cat({
    required this.id,
    required this.name,
    this.breed,
    required this.sex,
    this.birthDate,
    this.weightKg,
    this.chipNumber,
    this.photoPath,
    this.bloodType,
    required this.allergies,
    this.vetId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || breed != null) {
      map['breed'] = Variable<String>(breed);
    }
    {
      map['sex'] = Variable<String>($CatsTable.$convertersex.toSql(sex));
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || chipNumber != null) {
      map['chip_number'] = Variable<String>(chipNumber);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || bloodType != null) {
      map['blood_type'] = Variable<String>(bloodType);
    }
    {
      map['allergies'] = Variable<String>(
        $CatsTable.$converterallergies.toSql(allergies),
      );
    }
    if (!nullToAbsent || vetId != null) {
      map['vet_id'] = Variable<int>(vetId);
    }
    return map;
  }

  CatsCompanion toCompanion(bool nullToAbsent) {
    return CatsCompanion(
      id: Value(id),
      name: Value(name),
      breed: breed == null && nullToAbsent
          ? const Value.absent()
          : Value(breed),
      sex: Value(sex),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      chipNumber: chipNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(chipNumber),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      bloodType: bloodType == null && nullToAbsent
          ? const Value.absent()
          : Value(bloodType),
      allergies: Value(allergies),
      vetId: vetId == null && nullToAbsent
          ? const Value.absent()
          : Value(vetId),
    );
  }

  factory Cat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cat(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      breed: serializer.fromJson<String?>(json['breed']),
      sex: serializer.fromJson<CatSex>(json['sex']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      chipNumber: serializer.fromJson<String?>(json['chipNumber']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      bloodType: serializer.fromJson<String?>(json['bloodType']),
      allergies: serializer.fromJson<List<String>>(json['allergies']),
      vetId: serializer.fromJson<int?>(json['vetId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'breed': serializer.toJson<String?>(breed),
      'sex': serializer.toJson<CatSex>(sex),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'weightKg': serializer.toJson<double?>(weightKg),
      'chipNumber': serializer.toJson<String?>(chipNumber),
      'photoPath': serializer.toJson<String?>(photoPath),
      'bloodType': serializer.toJson<String?>(bloodType),
      'allergies': serializer.toJson<List<String>>(allergies),
      'vetId': serializer.toJson<int?>(vetId),
    };
  }

  Cat copyWith({
    int? id,
    String? name,
    Value<String?> breed = const Value.absent(),
    CatSex? sex,
    Value<DateTime?> birthDate = const Value.absent(),
    Value<double?> weightKg = const Value.absent(),
    Value<String?> chipNumber = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    Value<String?> bloodType = const Value.absent(),
    List<String>? allergies,
    Value<int?> vetId = const Value.absent(),
  }) => Cat(
    id: id ?? this.id,
    name: name ?? this.name,
    breed: breed.present ? breed.value : this.breed,
    sex: sex ?? this.sex,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    chipNumber: chipNumber.present ? chipNumber.value : this.chipNumber,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    bloodType: bloodType.present ? bloodType.value : this.bloodType,
    allergies: allergies ?? this.allergies,
    vetId: vetId.present ? vetId.value : this.vetId,
  );
  Cat copyWithCompanion(CatsCompanion data) {
    return Cat(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      breed: data.breed.present ? data.breed.value : this.breed,
      sex: data.sex.present ? data.sex.value : this.sex,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      chipNumber: data.chipNumber.present
          ? data.chipNumber.value
          : this.chipNumber,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      bloodType: data.bloodType.present ? data.bloodType.value : this.bloodType,
      allergies: data.allergies.present ? data.allergies.value : this.allergies,
      vetId: data.vetId.present ? data.vetId.value : this.vetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cat(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('breed: $breed, ')
          ..write('sex: $sex, ')
          ..write('birthDate: $birthDate, ')
          ..write('weightKg: $weightKg, ')
          ..write('chipNumber: $chipNumber, ')
          ..write('photoPath: $photoPath, ')
          ..write('bloodType: $bloodType, ')
          ..write('allergies: $allergies, ')
          ..write('vetId: $vetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    breed,
    sex,
    birthDate,
    weightKg,
    chipNumber,
    photoPath,
    bloodType,
    allergies,
    vetId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cat &&
          other.id == this.id &&
          other.name == this.name &&
          other.breed == this.breed &&
          other.sex == this.sex &&
          other.birthDate == this.birthDate &&
          other.weightKg == this.weightKg &&
          other.chipNumber == this.chipNumber &&
          other.photoPath == this.photoPath &&
          other.bloodType == this.bloodType &&
          other.allergies == this.allergies &&
          other.vetId == this.vetId);
}

class CatsCompanion extends UpdateCompanion<Cat> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> breed;
  final Value<CatSex> sex;
  final Value<DateTime?> birthDate;
  final Value<double?> weightKg;
  final Value<String?> chipNumber;
  final Value<String?> photoPath;
  final Value<String?> bloodType;
  final Value<List<String>> allergies;
  final Value<int?> vetId;
  const CatsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.breed = const Value.absent(),
    this.sex = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.chipNumber = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.bloodType = const Value.absent(),
    this.allergies = const Value.absent(),
    this.vetId = const Value.absent(),
  });
  CatsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.breed = const Value.absent(),
    this.sex = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.chipNumber = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.bloodType = const Value.absent(),
    this.allergies = const Value.absent(),
    this.vetId = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Cat> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? breed,
    Expression<String>? sex,
    Expression<DateTime>? birthDate,
    Expression<double>? weightKg,
    Expression<String>? chipNumber,
    Expression<String>? photoPath,
    Expression<String>? bloodType,
    Expression<String>? allergies,
    Expression<int>? vetId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (breed != null) 'breed': breed,
      if (sex != null) 'sex': sex,
      if (birthDate != null) 'birth_date': birthDate,
      if (weightKg != null) 'weight_kg': weightKg,
      if (chipNumber != null) 'chip_number': chipNumber,
      if (photoPath != null) 'photo_path': photoPath,
      if (bloodType != null) 'blood_type': bloodType,
      if (allergies != null) 'allergies': allergies,
      if (vetId != null) 'vet_id': vetId,
    });
  }

  CatsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? breed,
    Value<CatSex>? sex,
    Value<DateTime?>? birthDate,
    Value<double?>? weightKg,
    Value<String?>? chipNumber,
    Value<String?>? photoPath,
    Value<String?>? bloodType,
    Value<List<String>>? allergies,
    Value<int?>? vetId,
  }) {
    return CatsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      sex: sex ?? this.sex,
      birthDate: birthDate ?? this.birthDate,
      weightKg: weightKg ?? this.weightKg,
      chipNumber: chipNumber ?? this.chipNumber,
      photoPath: photoPath ?? this.photoPath,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      vetId: vetId ?? this.vetId,
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
    if (breed.present) {
      map['breed'] = Variable<String>(breed.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>($CatsTable.$convertersex.toSql(sex.value));
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (chipNumber.present) {
      map['chip_number'] = Variable<String>(chipNumber.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (bloodType.present) {
      map['blood_type'] = Variable<String>(bloodType.value);
    }
    if (allergies.present) {
      map['allergies'] = Variable<String>(
        $CatsTable.$converterallergies.toSql(allergies.value),
      );
    }
    if (vetId.present) {
      map['vet_id'] = Variable<int>(vetId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('breed: $breed, ')
          ..write('sex: $sex, ')
          ..write('birthDate: $birthDate, ')
          ..write('weightKg: $weightKg, ')
          ..write('chipNumber: $chipNumber, ')
          ..write('photoPath: $photoPath, ')
          ..write('bloodType: $bloodType, ')
          ..write('allergies: $allergies, ')
          ..write('vetId: $vetId')
          ..write(')'))
        .toString();
  }
}

class $VetsTable extends Vets with TableInfo<$VetsTable, Vet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VetsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clinicMeta = const VerificationMeta('clinic');
  @override
  late final GeneratedColumn<String> clinic = GeneratedColumn<String>(
    'clinic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, clinic, phone];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vet> instance, {
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
    if (data.containsKey('clinic')) {
      context.handle(
        _clinicMeta,
        clinic.isAcceptableOrUnknown(data['clinic']!, _clinicMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      clinic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clinic'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
    );
  }

  @override
  $VetsTable createAlias(String alias) {
    return $VetsTable(attachedDatabase, alias);
  }
}

class Vet extends DataClass implements Insertable<Vet> {
  final int id;
  final String name;
  final String? clinic;
  final String phone;
  const Vet({
    required this.id,
    required this.name,
    this.clinic,
    required this.phone,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || clinic != null) {
      map['clinic'] = Variable<String>(clinic);
    }
    map['phone'] = Variable<String>(phone);
    return map;
  }

  VetsCompanion toCompanion(bool nullToAbsent) {
    return VetsCompanion(
      id: Value(id),
      name: Value(name),
      clinic: clinic == null && nullToAbsent
          ? const Value.absent()
          : Value(clinic),
      phone: Value(phone),
    );
  }

  factory Vet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vet(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      clinic: serializer.fromJson<String?>(json['clinic']),
      phone: serializer.fromJson<String>(json['phone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'clinic': serializer.toJson<String?>(clinic),
      'phone': serializer.toJson<String>(phone),
    };
  }

  Vet copyWith({
    int? id,
    String? name,
    Value<String?> clinic = const Value.absent(),
    String? phone,
  }) => Vet(
    id: id ?? this.id,
    name: name ?? this.name,
    clinic: clinic.present ? clinic.value : this.clinic,
    phone: phone ?? this.phone,
  );
  Vet copyWithCompanion(VetsCompanion data) {
    return Vet(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      clinic: data.clinic.present ? data.clinic.value : this.clinic,
      phone: data.phone.present ? data.phone.value : this.phone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vet(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('clinic: $clinic, ')
          ..write('phone: $phone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, clinic, phone);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vet &&
          other.id == this.id &&
          other.name == this.name &&
          other.clinic == this.clinic &&
          other.phone == this.phone);
}

class VetsCompanion extends UpdateCompanion<Vet> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> clinic;
  final Value<String> phone;
  const VetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.clinic = const Value.absent(),
    this.phone = const Value.absent(),
  });
  VetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.clinic = const Value.absent(),
    required String phone,
  }) : name = Value(name),
       phone = Value(phone);
  static Insertable<Vet> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? clinic,
    Expression<String>? phone,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (clinic != null) 'clinic': clinic,
      if (phone != null) 'phone': phone,
    });
  }

  VetsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? clinic,
    Value<String>? phone,
  }) {
    return VetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      clinic: clinic ?? this.clinic,
      phone: phone ?? this.phone,
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
    if (clinic.present) {
      map['clinic'] = Variable<String>(clinic.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('clinic: $clinic, ')
          ..write('phone: $phone')
          ..write(')'))
        .toString();
  }
}

class $HealthEntriesTable extends HealthEntries
    with TableInfo<$HealthEntriesTable, HealthEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HealthEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _catIdMeta = const VerificationMeta('catId');
  @override
  late final GeneratedColumn<int> catId = GeneratedColumn<int>(
    'cat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<HealthEntryType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<HealthEntryType>($HealthEntriesTable.$convertertype);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    catId,
    type,
    date,
    title,
    note,
    photoPath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'health_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<HealthEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cat_id')) {
      context.handle(
        _catIdMeta,
        catId.isAcceptableOrUnknown(data['cat_id']!, _catIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
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
  HealthEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HealthEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      catId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cat_id'],
      )!,
      type: $HealthEntriesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HealthEntriesTable createAlias(String alias) {
    return $HealthEntriesTable(attachedDatabase, alias);
  }

  static TypeConverter<HealthEntryType, String> $convertertype =
      const HealthEntryTypeConverter();
}

class HealthEntry extends DataClass implements Insertable<HealthEntry> {
  final int id;
  final int catId;
  final HealthEntryType type;
  final DateTime date;
  final String title;
  final String? note;
  final String? photoPath;
  final DateTime createdAt;
  const HealthEntry({
    required this.id,
    required this.catId,
    required this.type,
    required this.date,
    required this.title,
    this.note,
    this.photoPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cat_id'] = Variable<int>(catId);
    {
      map['type'] = Variable<String>(
        $HealthEntriesTable.$convertertype.toSql(type),
      );
    }
    map['date'] = Variable<DateTime>(date);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  HealthEntriesCompanion toCompanion(bool nullToAbsent) {
    return HealthEntriesCompanion(
      id: Value(id),
      catId: Value(catId),
      type: Value(type),
      date: Value(date),
      title: Value(title),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      createdAt: Value(createdAt),
    );
  }

  factory HealthEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HealthEntry(
      id: serializer.fromJson<int>(json['id']),
      catId: serializer.fromJson<int>(json['catId']),
      type: serializer.fromJson<HealthEntryType>(json['type']),
      date: serializer.fromJson<DateTime>(json['date']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String?>(json['note']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'catId': serializer.toJson<int>(catId),
      'type': serializer.toJson<HealthEntryType>(type),
      'date': serializer.toJson<DateTime>(date),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String?>(note),
      'photoPath': serializer.toJson<String?>(photoPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  HealthEntry copyWith({
    int? id,
    int? catId,
    HealthEntryType? type,
    DateTime? date,
    String? title,
    Value<String?> note = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    DateTime? createdAt,
  }) => HealthEntry(
    id: id ?? this.id,
    catId: catId ?? this.catId,
    type: type ?? this.type,
    date: date ?? this.date,
    title: title ?? this.title,
    note: note.present ? note.value : this.note,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    createdAt: createdAt ?? this.createdAt,
  );
  HealthEntry copyWithCompanion(HealthEntriesCompanion data) {
    return HealthEntry(
      id: data.id.present ? data.id.value : this.id,
      catId: data.catId.present ? data.catId.value : this.catId,
      type: data.type.present ? data.type.value : this.type,
      date: data.date.present ? data.date.value : this.date,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HealthEntry(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, catId, type, date, title, note, photoPath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HealthEntry &&
          other.id == this.id &&
          other.catId == this.catId &&
          other.type == this.type &&
          other.date == this.date &&
          other.title == this.title &&
          other.note == this.note &&
          other.photoPath == this.photoPath &&
          other.createdAt == this.createdAt);
}

class HealthEntriesCompanion extends UpdateCompanion<HealthEntry> {
  final Value<int> id;
  final Value<int> catId;
  final Value<HealthEntryType> type;
  final Value<DateTime> date;
  final Value<String> title;
  final Value<String?> note;
  final Value<String?> photoPath;
  final Value<DateTime> createdAt;
  const HealthEntriesCompanion({
    this.id = const Value.absent(),
    this.catId = const Value.absent(),
    this.type = const Value.absent(),
    this.date = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HealthEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int catId,
    required HealthEntryType type,
    required DateTime date,
    required String title,
    this.note = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : catId = Value(catId),
       type = Value(type),
       date = Value(date),
       title = Value(title);
  static Insertable<HealthEntry> custom({
    Expression<int>? id,
    Expression<int>? catId,
    Expression<String>? type,
    Expression<DateTime>? date,
    Expression<String>? title,
    Expression<String>? note,
    Expression<String>? photoPath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catId != null) 'cat_id': catId,
      if (type != null) 'type': type,
      if (date != null) 'date': date,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (photoPath != null) 'photo_path': photoPath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HealthEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? catId,
    Value<HealthEntryType>? type,
    Value<DateTime>? date,
    Value<String>? title,
    Value<String?>? note,
    Value<String?>? photoPath,
    Value<DateTime>? createdAt,
  }) {
    return HealthEntriesCompanion(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      type: type ?? this.type,
      date: date ?? this.date,
      title: title ?? this.title,
      note: note ?? this.note,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (catId.present) {
      map['cat_id'] = Variable<int>(catId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $HealthEntriesTable.$convertertype.toSql(type.value),
      );
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HealthEntriesCompanion(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('type: $type, ')
          ..write('date: $date, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _catIdMeta = const VerificationMeta('catId');
  @override
  late final GeneratedColumn<int> catId = GeneratedColumn<int>(
    'cat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReminderType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReminderType>($RemindersTable.$convertertype);
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
    'is_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    catId,
    type,
    dueDate,
    title,
    description,
    isDone,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cat_id')) {
      context.handle(
        _catIdMeta,
        catId.isAcceptableOrUnknown(data['cat_id']!, _catIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catIdMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_done')) {
      context.handle(
        _isDoneMeta,
        isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      catId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cat_id'],
      )!,
      type: $RemindersTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_done'],
      )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }

  static TypeConverter<ReminderType, String> $convertertype =
      const ReminderTypeConverter();
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final int id;
  final int catId;
  final ReminderType type;
  final DateTime dueDate;
  final String title;
  final String? description;
  final bool isDone;
  const Reminder({
    required this.id,
    required this.catId,
    required this.type,
    required this.dueDate,
    required this.title,
    this.description,
    required this.isDone,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cat_id'] = Variable<int>(catId);
    {
      map['type'] = Variable<String>(
        $RemindersTable.$convertertype.toSql(type),
      );
    }
    map['due_date'] = Variable<DateTime>(dueDate);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_done'] = Variable<bool>(isDone);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      catId: Value(catId),
      type: Value(type),
      dueDate: Value(dueDate),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isDone: Value(isDone),
    );
  }

  factory Reminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<int>(json['id']),
      catId: serializer.fromJson<int>(json['catId']),
      type: serializer.fromJson<ReminderType>(json['type']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      isDone: serializer.fromJson<bool>(json['isDone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'catId': serializer.toJson<int>(catId),
      'type': serializer.toJson<ReminderType>(type),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'isDone': serializer.toJson<bool>(isDone),
    };
  }

  Reminder copyWith({
    int? id,
    int? catId,
    ReminderType? type,
    DateTime? dueDate,
    String? title,
    Value<String?> description = const Value.absent(),
    bool? isDone,
  }) => Reminder(
    id: id ?? this.id,
    catId: catId ?? this.catId,
    type: type ?? this.type,
    dueDate: dueDate ?? this.dueDate,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    isDone: isDone ?? this.isDone,
  );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      catId: data.catId.present ? data.catId.value : this.catId,
      type: data.type.present ? data.type.value : this.type,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('type: $type, ')
          ..write('dueDate: $dueDate, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isDone: $isDone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, catId, type, dueDate, title, description, isDone);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.catId == this.catId &&
          other.type == this.type &&
          other.dueDate == this.dueDate &&
          other.title == this.title &&
          other.description == this.description &&
          other.isDone == this.isDone);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<int> id;
  final Value<int> catId;
  final Value<ReminderType> type;
  final Value<DateTime> dueDate;
  final Value<String> title;
  final Value<String?> description;
  final Value<bool> isDone;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.catId = const Value.absent(),
    this.type = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.isDone = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    required int catId,
    required ReminderType type,
    required DateTime dueDate,
    required String title,
    this.description = const Value.absent(),
    this.isDone = const Value.absent(),
  }) : catId = Value(catId),
       type = Value(type),
       dueDate = Value(dueDate),
       title = Value(title);
  static Insertable<Reminder> custom({
    Expression<int>? id,
    Expression<int>? catId,
    Expression<String>? type,
    Expression<DateTime>? dueDate,
    Expression<String>? title,
    Expression<String>? description,
    Expression<bool>? isDone,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catId != null) 'cat_id': catId,
      if (type != null) 'type': type,
      if (dueDate != null) 'due_date': dueDate,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (isDone != null) 'is_done': isDone,
    });
  }

  RemindersCompanion copyWith({
    Value<int>? id,
    Value<int>? catId,
    Value<ReminderType>? type,
    Value<DateTime>? dueDate,
    Value<String>? title,
    Value<String?>? description,
    Value<bool>? isDone,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (catId.present) {
      map['cat_id'] = Variable<int>(catId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $RemindersTable.$convertertype.toSql(type.value),
      );
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('catId: $catId, ')
          ..write('type: $type, ')
          ..write('dueDate: $dueDate, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isDone: $isDone')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CatsTable cats = $CatsTable(this);
  late final $VetsTable vets = $VetsTable(this);
  late final $HealthEntriesTable healthEntries = $HealthEntriesTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final CatsDao catsDao = CatsDao(this as AppDatabase);
  late final VetsDao vetsDao = VetsDao(this as AppDatabase);
  late final HealthEntriesDao healthEntriesDao = HealthEntriesDao(
    this as AppDatabase,
  );
  late final RemindersDao remindersDao = RemindersDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cats,
    vets,
    healthEntries,
    reminders,
  ];
}

typedef $$CatsTableCreateCompanionBuilder =
    CatsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> breed,
      Value<CatSex> sex,
      Value<DateTime?> birthDate,
      Value<double?> weightKg,
      Value<String?> chipNumber,
      Value<String?> photoPath,
      Value<String?> bloodType,
      Value<List<String>> allergies,
      Value<int?> vetId,
    });
typedef $$CatsTableUpdateCompanionBuilder =
    CatsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> breed,
      Value<CatSex> sex,
      Value<DateTime?> birthDate,
      Value<double?> weightKg,
      Value<String?> chipNumber,
      Value<String?> photoPath,
      Value<String?> bloodType,
      Value<List<String>> allergies,
      Value<int?> vetId,
    });

class $$CatsTableFilterComposer extends Composer<_$AppDatabase, $CatsTable> {
  $$CatsTableFilterComposer({
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

  ColumnFilters<String> get breed => $composableBuilder(
    column: $table.breed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CatSex, CatSex, String> get sex =>
      $composableBuilder(
        column: $table.sex,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chipNumber => $composableBuilder(
    column: $table.chipNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bloodType => $composableBuilder(
    column: $table.bloodType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get allergies => $composableBuilder(
    column: $table.allergies,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get vetId => $composableBuilder(
    column: $table.vetId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatsTableOrderingComposer extends Composer<_$AppDatabase, $CatsTable> {
  $$CatsTableOrderingComposer({
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

  ColumnOrderings<String> get breed => $composableBuilder(
    column: $table.breed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chipNumber => $composableBuilder(
    column: $table.chipNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bloodType => $composableBuilder(
    column: $table.bloodType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allergies => $composableBuilder(
    column: $table.allergies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vetId => $composableBuilder(
    column: $table.vetId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatsTable> {
  $$CatsTableAnnotationComposer({
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

  GeneratedColumn<String> get breed =>
      $composableBuilder(column: $table.breed, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CatSex, String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get chipNumber => $composableBuilder(
    column: $table.chipNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get bloodType =>
      $composableBuilder(column: $table.bloodType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get allergies =>
      $composableBuilder(column: $table.allergies, builder: (column) => column);

  GeneratedColumn<int> get vetId =>
      $composableBuilder(column: $table.vetId, builder: (column) => column);
}

class $$CatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatsTable,
          Cat,
          $$CatsTableFilterComposer,
          $$CatsTableOrderingComposer,
          $$CatsTableAnnotationComposer,
          $$CatsTableCreateCompanionBuilder,
          $$CatsTableUpdateCompanionBuilder,
          (Cat, BaseReferences<_$AppDatabase, $CatsTable, Cat>),
          Cat,
          PrefetchHooks Function()
        > {
  $$CatsTableTableManager(_$AppDatabase db, $CatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> breed = const Value.absent(),
                Value<CatSex> sex = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<String?> chipNumber = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> bloodType = const Value.absent(),
                Value<List<String>> allergies = const Value.absent(),
                Value<int?> vetId = const Value.absent(),
              }) => CatsCompanion(
                id: id,
                name: name,
                breed: breed,
                sex: sex,
                birthDate: birthDate,
                weightKg: weightKg,
                chipNumber: chipNumber,
                photoPath: photoPath,
                bloodType: bloodType,
                allergies: allergies,
                vetId: vetId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> breed = const Value.absent(),
                Value<CatSex> sex = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<String?> chipNumber = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> bloodType = const Value.absent(),
                Value<List<String>> allergies = const Value.absent(),
                Value<int?> vetId = const Value.absent(),
              }) => CatsCompanion.insert(
                id: id,
                name: name,
                breed: breed,
                sex: sex,
                birthDate: birthDate,
                weightKg: weightKg,
                chipNumber: chipNumber,
                photoPath: photoPath,
                bloodType: bloodType,
                allergies: allergies,
                vetId: vetId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatsTable,
      Cat,
      $$CatsTableFilterComposer,
      $$CatsTableOrderingComposer,
      $$CatsTableAnnotationComposer,
      $$CatsTableCreateCompanionBuilder,
      $$CatsTableUpdateCompanionBuilder,
      (Cat, BaseReferences<_$AppDatabase, $CatsTable, Cat>),
      Cat,
      PrefetchHooks Function()
    >;
typedef $$VetsTableCreateCompanionBuilder =
    VetsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> clinic,
      required String phone,
    });
typedef $$VetsTableUpdateCompanionBuilder =
    VetsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> clinic,
      Value<String> phone,
    });

class $$VetsTableFilterComposer extends Composer<_$AppDatabase, $VetsTable> {
  $$VetsTableFilterComposer({
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

  ColumnFilters<String> get clinic => $composableBuilder(
    column: $table.clinic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VetsTableOrderingComposer extends Composer<_$AppDatabase, $VetsTable> {
  $$VetsTableOrderingComposer({
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

  ColumnOrderings<String> get clinic => $composableBuilder(
    column: $table.clinic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VetsTable> {
  $$VetsTableAnnotationComposer({
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

  GeneratedColumn<String> get clinic =>
      $composableBuilder(column: $table.clinic, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);
}

class $$VetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VetsTable,
          Vet,
          $$VetsTableFilterComposer,
          $$VetsTableOrderingComposer,
          $$VetsTableAnnotationComposer,
          $$VetsTableCreateCompanionBuilder,
          $$VetsTableUpdateCompanionBuilder,
          (Vet, BaseReferences<_$AppDatabase, $VetsTable, Vet>),
          Vet,
          PrefetchHooks Function()
        > {
  $$VetsTableTableManager(_$AppDatabase db, $VetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> clinic = const Value.absent(),
                Value<String> phone = const Value.absent(),
              }) => VetsCompanion(
                id: id,
                name: name,
                clinic: clinic,
                phone: phone,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> clinic = const Value.absent(),
                required String phone,
              }) => VetsCompanion.insert(
                id: id,
                name: name,
                clinic: clinic,
                phone: phone,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VetsTable,
      Vet,
      $$VetsTableFilterComposer,
      $$VetsTableOrderingComposer,
      $$VetsTableAnnotationComposer,
      $$VetsTableCreateCompanionBuilder,
      $$VetsTableUpdateCompanionBuilder,
      (Vet, BaseReferences<_$AppDatabase, $VetsTable, Vet>),
      Vet,
      PrefetchHooks Function()
    >;
typedef $$HealthEntriesTableCreateCompanionBuilder =
    HealthEntriesCompanion Function({
      Value<int> id,
      required int catId,
      required HealthEntryType type,
      required DateTime date,
      required String title,
      Value<String?> note,
      Value<String?> photoPath,
      Value<DateTime> createdAt,
    });
typedef $$HealthEntriesTableUpdateCompanionBuilder =
    HealthEntriesCompanion Function({
      Value<int> id,
      Value<int> catId,
      Value<HealthEntryType> type,
      Value<DateTime> date,
      Value<String> title,
      Value<String?> note,
      Value<String?> photoPath,
      Value<DateTime> createdAt,
    });

class $$HealthEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $HealthEntriesTable> {
  $$HealthEntriesTableFilterComposer({
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

  ColumnFilters<int> get catId => $composableBuilder(
    column: $table.catId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<HealthEntryType, HealthEntryType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HealthEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $HealthEntriesTable> {
  $$HealthEntriesTableOrderingComposer({
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

  ColumnOrderings<int> get catId => $composableBuilder(
    column: $table.catId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HealthEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HealthEntriesTable> {
  $$HealthEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get catId =>
      $composableBuilder(column: $table.catId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<HealthEntryType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HealthEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HealthEntriesTable,
          HealthEntry,
          $$HealthEntriesTableFilterComposer,
          $$HealthEntriesTableOrderingComposer,
          $$HealthEntriesTableAnnotationComposer,
          $$HealthEntriesTableCreateCompanionBuilder,
          $$HealthEntriesTableUpdateCompanionBuilder,
          (
            HealthEntry,
            BaseReferences<_$AppDatabase, $HealthEntriesTable, HealthEntry>,
          ),
          HealthEntry,
          PrefetchHooks Function()
        > {
  $$HealthEntriesTableTableManager(_$AppDatabase db, $HealthEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HealthEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HealthEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HealthEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> catId = const Value.absent(),
                Value<HealthEntryType> type = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HealthEntriesCompanion(
                id: id,
                catId: catId,
                type: type,
                date: date,
                title: title,
                note: note,
                photoPath: photoPath,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int catId,
                required HealthEntryType type,
                required DateTime date,
                required String title,
                Value<String?> note = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => HealthEntriesCompanion.insert(
                id: id,
                catId: catId,
                type: type,
                date: date,
                title: title,
                note: note,
                photoPath: photoPath,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HealthEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HealthEntriesTable,
      HealthEntry,
      $$HealthEntriesTableFilterComposer,
      $$HealthEntriesTableOrderingComposer,
      $$HealthEntriesTableAnnotationComposer,
      $$HealthEntriesTableCreateCompanionBuilder,
      $$HealthEntriesTableUpdateCompanionBuilder,
      (
        HealthEntry,
        BaseReferences<_$AppDatabase, $HealthEntriesTable, HealthEntry>,
      ),
      HealthEntry,
      PrefetchHooks Function()
    >;
typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      Value<int> id,
      required int catId,
      required ReminderType type,
      required DateTime dueDate,
      required String title,
      Value<String?> description,
      Value<bool> isDone,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<int> id,
      Value<int> catId,
      Value<ReminderType> type,
      Value<DateTime> dueDate,
      Value<String> title,
      Value<String?> description,
      Value<bool> isDone,
    });

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
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

  ColumnFilters<int> get catId => $composableBuilder(
    column: $table.catId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReminderType, ReminderType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
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

  ColumnOrderings<int> get catId => $composableBuilder(
    column: $table.catId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get catId =>
      $composableBuilder(column: $table.catId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReminderType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          Reminder,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
          Reminder,
          PrefetchHooks Function()
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> catId = const Value.absent(),
                Value<ReminderType> type = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                catId: catId,
                type: type,
                dueDate: dueDate,
                title: title,
                description: description,
                isDone: isDone,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int catId,
                required ReminderType type,
                required DateTime dueDate,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                catId: catId,
                type: type,
                dueDate: dueDate,
                title: title,
                description: description,
                isDone: isDone,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      Reminder,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
      Reminder,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CatsTableTableManager get cats => $$CatsTableTableManager(_db, _db.cats);
  $$VetsTableTableManager get vets => $$VetsTableTableManager(_db, _db.vets);
  $$HealthEntriesTableTableManager get healthEntries =>
      $$HealthEntriesTableTableManager(_db, _db.healthEntries);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
}
