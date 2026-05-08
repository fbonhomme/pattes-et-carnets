import 'package:drift/drift.dart';
import 'package:pattes_et_carnets/shared/database/app_database.dart';

part 'health_entries_dao.g.dart';

@DriftAccessor(tables: [HealthEntries])
class HealthEntriesDao extends DatabaseAccessor<AppDatabase>
    with _$HealthEntriesDaoMixin {
  HealthEntriesDao(super.db);

  /// Entries for one cat, most recent first.
  Stream<List<HealthEntry>> watchEntriesForCat(int catId) =>
      (select(healthEntries)
            ..where((t) => t.catId.equals(catId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Future<int> insertEntry(HealthEntriesCompanion entry) =>
      into(healthEntries).insert(entry);

  Future<bool> updateEntry(HealthEntriesCompanion entry) =>
      update(healthEntries).replace(entry);

  Future<int> deleteEntry(int id) =>
      (delete(healthEntries)..where((t) => t.id.equals(id))).go();

  /// Delete all entries for a cat (used when deleting the cat).
  Future<int> deleteAllForCat(int catId) =>
      (delete(healthEntries)..where((t) => t.catId.equals(catId))).go();
}
