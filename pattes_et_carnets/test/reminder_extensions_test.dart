import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pattes_et_carnets/shared/database/app_database.dart';
import 'package:pattes_et_carnets/shared/models/enums.dart';
import 'package:pattes_et_carnets/shared/models/reminder_extensions.dart';

Reminder _dueIn(int days, {bool isDone = false, int hour = 12}) {
  final now = DateTime.now();
  return Reminder(
    id: 1,
    catId: 1,
    type: ReminderType.vaccin,
    dueDate: DateTime(now.year, now.month, now.day + days, hour),
    title: 'Vaccin',
    isDone: isDone,
  );
}

void main() {
  setUpAll(() => initializeDateFormatting('fr'));

  test('daysLeft counts calendar days, ignoring time of day', () {
    // Due tomorrow early morning is still "1 day", not 0.
    expect(_dueIn(1, hour: 0).daysLeft, 1);
    expect(_dueIn(0, hour: 23).daysLeft, 0);
    expect(_dueIn(-3).daysLeft, -3);
  });

  test('dueLabel', () {
    expect(_dueIn(-2).dueLabel, 'En retard de 2 j');
    expect(_dueIn(0).dueLabel, "Aujourd'hui");
    expect(_dueIn(1).dueLabel, 'Demain');
    expect(_dueIn(30).dueLabel, 'Dans 30 jours');
    expect(_dueIn(31).dueLabel, isNot(startsWith('Dans')));
  });

  test('healthStatus', () {
    expect(_dueIn(-1).healthStatus, HealthStatus.late);
    expect(_dueIn(7).healthStatus, HealthStatus.upcoming);
    expect(_dueIn(8).healthStatus, HealthStatus.upToDate);
    expect(_dueIn(-1, isDone: true).healthStatus, HealthStatus.upToDate);
  });
}
