import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pattes_et_carnets/shared/database/app_database.dart';
import 'package:pattes_et_carnets/shared/providers/database_provider.dart';

final catsStreamProvider = StreamProvider.autoDispose<List<Cat>>((ref) {
  return ref.watch(catsDaoProvider).watchAllCats();
});

final catByIdProvider =
    StreamProvider.autoDispose.family<Cat?, int>((ref, id) {
  return ref.watch(catsDaoProvider).watchCatById(id);
});

final catHealthEntriesProvider =
    StreamProvider.autoDispose.family<List<HealthEntry>, int>((ref, catId) {
  return ref.watch(healthEntriesDaoProvider).watchEntriesForCat(catId);
});

final allHealthEntriesProvider =
    StreamProvider.autoDispose<List<HealthEntry>>((ref) {
  return ref.watch(healthEntriesDaoProvider).watchAllEntries();
});

final vetByIdProvider =
    StreamProvider.autoDispose.family<Vet?, int>((ref, vetId) {
  return ref.watch(vetsDaoProvider).watchVetById(vetId);
});

final allVetsProvider = StreamProvider.autoDispose<List<Vet>>((ref) {
  return ref.watch(vetsDaoProvider).watchAllVets();
});

final catRemindersProvider =
    StreamProvider.autoDispose.family<List<Reminder>, int>((ref, catId) {
  return ref.watch(remindersDaoProvider).watchRemindersForCat(catId);
});

/// All pending (not done) reminders across every cat — drives CalendarScreen.
final allPendingRemindersProvider =
    StreamProvider.autoDispose<List<Reminder>>((ref) {
  return ref.watch(remindersDaoProvider).watchAllPendingReminders();
});

/// Pending reminders due within the next 7 days — drives the stats tile.
final weeklyReminderCountProvider = StreamProvider.autoDispose<int>((ref) {
  return ref.watch(remindersDaoProvider).watchAllPendingReminders().map(
    (reminders) {
      final weekEnd = DateTime.now().add(const Duration(days: 7));
      return reminders
          .where((r) => r.dueDate.isBefore(weekEnd))
          .length;
    },
  );
});
