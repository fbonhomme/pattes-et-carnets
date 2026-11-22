import 'package:drift/drift.dart' show Value;
import 'package:image_picker/image_picker.dart';
import 'package:pattes_et_carnets/shared/database/app_database.dart';
import 'package:pattes_et_carnets/shared/services/notification_service.dart';
import 'package:pattes_et_carnets/shared/services/photo_storage.dart';

// Writes that must keep the database, scheduled notifications and photo files
// in sync. Screens call these instead of chaining DAOs and services themselves.

/// Inserts [data] (no id) or replaces the reminder (id present), then
/// (re)schedules its notification.
Future<void> saveReminder(AppDatabase db, RemindersCompanion data) async {
  final int id;
  if (data.id.present) {
    id = data.id.value;
    await db.remindersDao.updateReminder(data);
    await NotificationService.cancelReminder(id);
  } else {
    id = await db.remindersDao.insertReminder(data);
  }
  final reminder = await db.remindersDao.getReminderById(id);
  if (reminder == null) return;
  final cat = await db.catsDao.getCatById(reminder.catId);
  await NotificationService.scheduleReminder(reminder, cat?.name ?? '');
}

Future<void> markReminderDone(AppDatabase db, int id) async {
  await db.remindersDao.markDone(id);
  await NotificationService.cancelReminder(id);
}

Future<void> deleteReminder(AppDatabase db, int id) async {
  await db.remindersDao.deleteReminder(id);
  await NotificationService.cancelReminder(id);
}

/// Deletes the cat; foreign keys cascade to its journal and reminders in the
/// same statement. Notifications and photo files are cleaned up afterwards.
Future<void> deleteCat(AppDatabase db, Cat cat) async {
  final reminders = await db.remindersDao.getPendingRemindersForCat(cat.id);
  final entries = await db.healthEntriesDao.getEntriesForCat(cat.id);
  await db.catsDao.deleteCat(cat.id);
  for (final r in reminders) {
    await NotificationService.cancelReminder(r.id);
  }
  await deletePhoto(cat.photoPath);
  for (final e in entries) {
    await deletePhoto(e.photoPath);
  }
}

/// Stores [image] as the cat's profile photo and removes the previous file.
/// Reads the current path from the database so a stale widget copy of the cat
/// can't make us delete the wrong file.
Future<void> setCatPhoto(AppDatabase db, int catId, XFile image) async {
  final previous = (await db.catsDao.getCatById(catId))?.photoPath;
  final dest = await savePhoto(image, prefix: 'cat_$catId');
  await db.catsDao.updateCat(
    CatsCompanion(id: Value(catId), photoPath: Value(dest)),
  );
  await deletePhoto(previous);
}

Future<void> deleteEntry(AppDatabase db, HealthEntry entry) async {
  await db.healthEntriesDao.deleteEntry(entry.id);
  await deletePhoto(entry.photoPath);
}
