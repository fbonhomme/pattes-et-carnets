import 'package:drift/drift.dart';
import 'package:pattes_et_carnets/shared/database/app_database.dart';

part 'vets_dao.g.dart';

@DriftAccessor(tables: [Vets])
class VetsDao extends DatabaseAccessor<AppDatabase> with _$VetsDaoMixin {
  VetsDao(super.db);

  Stream<List<Vet>> watchAllVets() => select(vets).watch();

  Future<Vet?> getVetById(int id) =>
      (select(vets)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<Vet?> watchVetById(int id) =>
      (select(vets)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<int> insertVet(VetsCompanion vet) => into(vets).insert(vet);

  Future<bool> updateVet(VetsCompanion vet) => update(vets).replace(vet);

  Future<int> deleteVet(int id) =>
      (delete(vets)..where((t) => t.id.equals(id))).go();
}
