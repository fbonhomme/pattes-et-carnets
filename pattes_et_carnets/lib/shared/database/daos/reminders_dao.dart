import 'package:drift/drift.dart';
import 'package:pattes_et_carnets/shared/database/app_database.dart';

part 'reminders_dao.g.dart';

@DriftAccessor(tables: [Reminders])
class RemindersDao extends DatabaseAccessor<AppDatabase>
    with _$RemindersDaoMixin {
  RemindersDao(super.db);

  Stream<List<Reminder>> watchRemindersForCat(int catId) =>
      (select(reminders)
            ..where((t) => t.catId.equals(catId))
            ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
          .watch();

  /// All pending reminders across all cats, sorted by due date — used by CalendarScreen.
  Stream<List<Reminder>> watchAllPendingReminders() =>
      (select(reminders)
            ..where((t) => t.isDone.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
          .watch();

  Future<Reminder?> getReminderById(int id) =>
      (select(reminders)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Reminder>> getPendingReminders() =>
      (select(reminders)..where((t) => t.isDone.equals(false))).get();

  Future<int> insertReminder(RemindersCompanion reminder) =>
      into(reminders).insert(reminder);

  Future<bool> updateReminder(RemindersCompanion reminder) =>
      update(reminders).replace(reminder);

  Future<void> markDone(int id) => (update(reminders)..where((t) => t.id.equals(id)))
      .write(const RemindersCompanion(isDone: Value(true)));

  Future<int> deleteReminder(int id) =>
      (delete(reminders)..where((t) => t.id.equals(id))).go();

  Future<int> deleteAllForCat(int catId) =>
      (delete(reminders)..where((t) => t.catId.equals(catId))).go();
}
