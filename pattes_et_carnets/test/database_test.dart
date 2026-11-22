import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pattes_et_carnets/shared/database/app_database.dart';
import 'package:pattes_et_carnets/shared/models/enums.dart';

void main() {
  group('v2 schema', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('fresh test database is not seeded with demo cats', () async {
      expect(await db.catsDao.getAllCats(), isEmpty);
    });

    test('deleting a cat cascades to its journal and reminders only', () async {
      final luna = await db.catsDao.insertCat(const CatsCompanion(name: Value('Luna')));
      final milo = await db.catsDao.insertCat(const CatsCompanion(name: Value('Milo')));
      for (final catId in [luna, milo]) {
        await db.remindersDao.insertReminder(RemindersCompanion(
          catId: Value(catId),
          type: const Value(ReminderType.vaccin),
          dueDate: Value(DateTime(2030)),
          title: const Value('Vaccin'),
        ));
        await db.healthEntriesDao.insertEntry(HealthEntriesCompanion(
          catId: Value(catId),
          type: const Value(HealthEntryType.note),
          date: Value(DateTime(2025)),
          title: const Value('Note'),
        ));
      }

      await db.catsDao.deleteCat(luna);

      expect(await db.remindersDao.getPendingRemindersForCat(luna), isEmpty);
      expect(await db.healthEntriesDao.getEntriesForCat(luna), isEmpty);
      expect(await db.remindersDao.getPendingRemindersForCat(milo), hasLength(1));
      expect(await db.healthEntriesDao.getEntriesForCat(milo), hasLength(1));
    });

    test('deleting a vet clears it from cats instead of failing', () async {
      final vet = await db.vetsDao.insertVet(
        const VetsCompanion(name: Value('Dr. Martin'), phone: Value('01')),
      );
      final cat = await db.catsDao.insertCat(
        CatsCompanion(name: const Value('Luna'), vetId: Value(vet)),
      );

      await db.vetsDao.deleteVet(vet);

      expect((await db.catsDao.getCatById(cat))!.vetId, isNull);
    });

    test('enums round-trip through textEnum columns', () async {
      final id = await db.catsDao.insertCat(
        const CatsCompanion(name: Value('Milo'), sex: Value(CatSex.male)),
      );
      expect((await db.catsDao.getCatById(id))!.sex, CatSex.male);
    });
  });

  test('v1 -> v2 migration keeps data, drops orphans, enforces foreign keys',
      () async {
    final migrated = AppDatabase.forTesting(NativeDatabase.memory(
      setup: (raw) {
        // Schema as shipped in v1: no foreign keys.
        raw.execute("""
          CREATE TABLE vets (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL, clinic TEXT NULL, phone TEXT NOT NULL);
          CREATE TABLE cats (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL, breed TEXT NULL,
            sex TEXT NOT NULL DEFAULT 'female', birth_date INTEGER NULL,
            weight_kg REAL NULL, chip_number TEXT NULL, photo_path TEXT NULL,
            blood_type TEXT NULL, allergies TEXT NOT NULL DEFAULT '[]',
            vet_id INTEGER NULL);
          CREATE TABLE health_entries (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            cat_id INTEGER NOT NULL, type TEXT NOT NULL, date INTEGER NOT NULL,
            title TEXT NOT NULL, note TEXT NULL, photo_path TEXT NULL,
            created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)));
          CREATE TABLE reminders (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            cat_id INTEGER NOT NULL, type TEXT NOT NULL, due_date INTEGER NOT NULL,
            title TEXT NOT NULL, description TEXT NULL,
            is_done INTEGER NOT NULL DEFAULT 0 CHECK (is_done IN (0, 1)));
          INSERT INTO cats (id, name, sex, allergies, vet_id) VALUES (1, 'Luna', 'male', '["Saumon"]', 99);
          INSERT INTO reminders (cat_id, type, due_date, title) VALUES (1, 'vaccin', 1900000000, 'Vaccin');
          INSERT INTO reminders (cat_id, type, due_date, title) VALUES (42, 'vaccin', 1900000000, 'Orphan');
          INSERT INTO health_entries (cat_id, type, date, title) VALUES (42, 'note', 1700000000, 'Orphan');
          PRAGMA user_version = 1;
        """);
      },
    ));
    addTearDown(migrated.close);

    final luna = (await migrated.catsDao.getCatById(1))!;
    expect(luna.sex, CatSex.male);
    expect(luna.allergies, ['Saumon']);
    expect(luna.vetId, isNull, reason: 'dangling vet id cleared');
    expect(await migrated.remindersDao.getPendingReminders(), hasLength(1));
    expect(await migrated.healthEntriesDao.getEntriesForCat(42), isEmpty);

    await migrated.catsDao.deleteCat(1);
    expect(await migrated.remindersDao.getPendingReminders(), isEmpty);
  });
}
