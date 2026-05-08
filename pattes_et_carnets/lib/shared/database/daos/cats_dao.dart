import 'package:drift/drift.dart';
import 'package:pattes_et_carnets/shared/database/app_database.dart';

part 'cats_dao.g.dart';

@DriftAccessor(tables: [Cats])
class CatsDao extends DatabaseAccessor<AppDatabase> with _$CatsDaoMixin {
  CatsDao(super.db);

  Stream<List<Cat>> watchAllCats() => select(cats).watch();

  Future<Cat?> getCatById(int id) =>
      (select(cats)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<Cat?> watchCatById(int id) =>
      (select(cats)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<int> insertCat(CatsCompanion cat) => into(cats).insert(cat);

  Future<bool> updateCat(CatsCompanion cat) => update(cats).replace(cat);

  Future<int> deleteCat(int id) =>
      (delete(cats)..where((t) => t.id.equals(id))).go();
}
