import 'package:drift/drift.dart';
import 'package:pattes_et_carnets/shared/database/app_database.dart';
import 'package:pattes_et_carnets/shared/models/enums.dart';

/// Inserts sample data (Luna + Milo) if the database is empty.
/// Called once at app startup.
class DatabaseSeeder {
  const DatabaseSeeder(this._db);

  final AppDatabase _db;

  Future<void> seedIfEmpty() async {
    final cats = await _db.catsDao.watchAllCats().first;
    if (cats.isNotEmpty) return;

    // Vet
    final vetId = await _db.vetsDao.insertVet(
      const VetsCompanion(
        name: Value('Dr. Martin'),
        clinic: Value('Clinique du Parc'),
        phone: Value('01 23 45 67 89'),
      ),
    );

    // Luna — Maine Coon, 3 ans
    final lunaId = await _db.catsDao.insertCat(
      CatsCompanion(
        name: const Value('Luna'),
        breed: const Value('Maine Coon'),
        sex: const Value(CatSex.female),
        birthDate: Value(DateTime.now().subtract(const Duration(days: 365 * 3 + 45))),
        weightKg: const Value(4.3),
        chipNumber: const Value('250268731456789'),
        bloodType: const Value('A'),
        allergies: const Value(['Saumon']),
        vetId: Value(vetId),
      ),
    );

    // Milo — chaton, 8 mois
    final miloId = await _db.catsDao.insertCat(
      CatsCompanion(
        name: const Value('Milo'),
        breed: const Value('Européen roux'),
        sex: const Value(CatSex.male),
        birthDate: Value(DateTime.now().subtract(const Duration(days: 240))),
        weightKg: const Value(2.1),
        vetId: Value(vetId),
      ),
    );

    final now = DateTime.now();

    // Luna reminders
    await _db.remindersDao.insertReminder(
      RemindersCompanion(
        catId: Value(lunaId),
        type: const Value(ReminderType.vaccin),
        dueDate: Value(now.add(const Duration(days: 12))),
        title: const Value('Vaccin Typhus'),
        description: const Value('Rappel annuel obligatoire'),
      ),
    );
    await _db.remindersDao.insertReminder(
      RemindersCompanion(
        catId: Value(lunaId),
        type: const Value(ReminderType.rdvVeterinaire),
        dueDate: Value(DateTime(now.year, now.month + 1, 15)),
        title: const Value('Check-up annuel'),
        description: const Value('Bilan de santé complet'),
      ),
    );

    // Milo reminders
    await _db.remindersDao.insertReminder(
      RemindersCompanion(
        catId: Value(miloId),
        type: const Value(ReminderType.vermifuge),
        dueDate: Value(now.add(const Duration(days: 1))),
        title: const Value('Vermifuge'),
        description: const Value('Soin d\'hygiène périodique'),
      ),
    );
    await _db.remindersDao.insertReminder(
      RemindersCompanion(
        catId: Value(miloId),
        type: const Value(ReminderType.vaccin),
        dueDate: Value(now.add(const Duration(days: 30))),
        title: const Value('Primo-vaccination'),
        description: const Value('Première série vaccinale'),
      ),
    );

    // Luna health journal entries
    await _db.healthEntriesDao.insertEntry(
      HealthEntriesCompanion(
        catId: Value(lunaId),
        type: const Value(HealthEntryType.visite),
        date: Value(now.subtract(const Duration(days: 36))),
        title: const Value('Visite vétérinaire'),
        note: const Value(
          'Vaccin annuel effectué. Luna se porte à merveille, son poids est stable à 4.3 kg.',
        ),
      ),
    );
    await _db.healthEntriesDao.insertEntry(
      HealthEntriesCompanion(
        catId: Value(lunaId),
        type: const Value(HealthEntryType.alimentation),
        date: Value(now.subtract(const Duration(days: 51))),
        title: const Value('Changement d\'alimentation'),
        note: const Value(
          'Passage aux croquettes sans céréales. Transition douce sur 7 jours.',
        ),
      ),
    );
    await _db.healthEntriesDao.insertEntry(
      HealthEntriesCompanion(
        catId: Value(lunaId),
        type: const Value(HealthEntryType.antiparasitaire),
        date: Value(now.subtract(const Duration(days: 68))),
        title: const Value('Traitement antiparasitaire'),
        note: const Value('Pipette mensuelle appliquée.'),
      ),
    );
  }
}
