import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:pattes_et_carnets/shared/models/enums.dart';
import 'package:pattes_et_carnets/shared/database/daos/cats_dao.dart';
import 'package:pattes_et_carnets/shared/database/daos/vets_dao.dart';
import 'package:pattes_et_carnets/shared/database/daos/health_entries_dao.dart';
import 'package:pattes_et_carnets/shared/database/daos/reminders_dao.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Type Converters — switch expressions per dart-use-pattern-matching skill
// ---------------------------------------------------------------------------

class CatSexConverter extends TypeConverter<CatSex, String> {
  const CatSexConverter();

  @override
  CatSex fromSql(String fromDb) => switch (fromDb) {
        'male' => CatSex.male,
        _ => CatSex.female,
      };

  @override
  String toSql(CatSex value) => value.name;
}

class HealthEntryTypeConverter extends TypeConverter<HealthEntryType, String> {
  const HealthEntryTypeConverter();

  @override
  HealthEntryType fromSql(String fromDb) => switch (fromDb) {
        'vaccination' => HealthEntryType.vaccination,
        'antiparasitaire' => HealthEntryType.antiparasitaire,
        'vermifuge' => HealthEntryType.vermifuge,
        'alimentation' => HealthEntryType.alimentation,
        'visite' => HealthEntryType.visite,
        _ => HealthEntryType.note,
      };

  @override
  String toSql(HealthEntryType value) => value.name;
}

class ReminderTypeConverter extends TypeConverter<ReminderType, String> {
  const ReminderTypeConverter();

  @override
  ReminderType fromSql(String fromDb) => switch (fromDb) {
        'vaccin' => ReminderType.vaccin,
        'vermifuge' => ReminderType.vermifuge,
        'rdvVeterinaire' => ReminderType.rdvVeterinaire,
        'antiparasitaire' => ReminderType.antiparasitaire,
        'hygiene' => ReminderType.hygiene,
        _ => ReminderType.traitement,
      };

  @override
  String toSql(ReminderType value) => value.name;
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty || fromDb == '[]') return [];
    return List<String>.from(jsonDecode(fromDb) as List);
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

// ---------------------------------------------------------------------------
// Tables
// ---------------------------------------------------------------------------

@DataClassName('Vet')
class Vets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get clinic => text().nullable()();
  TextColumn get phone => text()();
}

@DataClassName('Cat')
class Cats extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get breed => text().nullable()();
  TextColumn get sex => text()
      .map(const CatSexConverter())
      .withDefault(const Constant('female'))();
  DateTimeColumn get birthDate => dateTime().nullable()();
  RealColumn get weightKg => real().nullable()();
  TextColumn get chipNumber => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  TextColumn get bloodType => text().nullable()();
  TextColumn get allergies => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  IntColumn get vetId => integer().nullable()();
}

@DataClassName('HealthEntry')
class HealthEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get catId => integer()();
  TextColumn get type => text().map(const HealthEntryTypeConverter())();
  DateTimeColumn get date => dateTime()();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Reminder')
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get catId => integer()();
  TextColumn get type => text().map(const ReminderTypeConverter())();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [Cats, Vets, HealthEntries, Reminders],
  daos: [CatsDao, VetsDao, HealthEntriesDao, RemindersDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'pattes_et_carnets.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
