import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pattes_et_carnets/shared/database/app_database.dart';
import 'package:pattes_et_carnets/shared/database/daos/cats_dao.dart';
import 'package:pattes_et_carnets/shared/database/daos/vets_dao.dart';
import 'package:pattes_et_carnets/shared/database/daos/health_entries_dao.dart';
import 'package:pattes_et_carnets/shared/database/daos/reminders_dao.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final catsDaoProvider = Provider<CatsDao>((ref) {
  return ref.watch(databaseProvider).catsDao;
});

final vetsDaoProvider = Provider<VetsDao>((ref) {
  return ref.watch(databaseProvider).vetsDao;
});

final healthEntriesDaoProvider = Provider<HealthEntriesDao>((ref) {
  return ref.watch(databaseProvider).healthEntriesDao;
});

final remindersDaoProvider = Provider<RemindersDao>((ref) {
  return ref.watch(databaseProvider).remindersDao;
});
