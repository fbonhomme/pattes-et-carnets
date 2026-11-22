import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:pattes_et_carnets/shared/models/enums.dart';
import 'package:pattes_et_carnets/shared/database/daos/cats_dao.dart';
import 'package:pattes_et_carnets/shared/database/daos/vets_dao.dart';
import 'package:pattes_et_carnets/shared/database/daos/health_entries_dao.dart';
import 'package:pattes_et_carnets/shared/database/daos/reminders_dao.dart';
import 'package:pattes_et_carnets/shared/database/database_seeder.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Type Converters
// ---------------------------------------------------------------------------

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
  TextColumn get sex =>
      textEnum<CatSex>().withDefault(const Constant('female'))();
  DateTimeColumn get birthDate => dateTime().nullable()();
  RealColumn get weightKg => real().nullable()();
  TextColumn get chipNumber => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  TextColumn get bloodType => text().nullable()();
  TextColumn get allergies => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();
  IntColumn get vetId => integer()
      .nullable()
      .references(Vets, #id, onDelete: KeyAction.setNull)();
}

@DataClassName('HealthEntry')
class HealthEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get catId =>
      integer().references(Cats, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => textEnum<HealthEntryType>()();
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
  IntColumn get catId =>
      integer().references(Cats, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => textEnum<ReminderType>()();
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
  AppDatabase() : _seedDemo = kDebugMode, super(_openConnection());
  AppDatabase.forTesting(super.e) : _seedDemo = false;

  final bool _seedDemo;

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Demo data only on a fresh debug install — never re-seeded after
          // the user deletes every cat.
          if (_seedDemo) await DatabaseSeeder(this).seed();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // v2 adds foreign keys: drop orphans left by the old non-atomic
            // delete, then rebuild the tables with their constraints.
            await customStatement(
              'DELETE FROM health_entries WHERE cat_id NOT IN (SELECT id FROM cats)',
            );
            await customStatement(
              'DELETE FROM reminders WHERE cat_id NOT IN (SELECT id FROM cats)',
            );
            await customStatement(
              'UPDATE cats SET vet_id = NULL WHERE vet_id NOT IN (SELECT id FROM vets)',
            );
            await m.alterTable(TableMigration(cats));
            await m.alterTable(TableMigration(healthEntries));
            await m.alterTable(TableMigration(reminders));
          }
        },
        beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'pattes_et_carnets.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
