import 'package:intl/intl.dart';
import 'package:pattes_et_carnets/shared/database/app_database.dart';
import 'package:pattes_et_carnets/shared/models/enums.dart';

extension ReminderStatusExt on Reminder {
  /// Calendar days until [dueDate] (negative when late). Compared in UTC so a
  /// DST change never turns "tomorrow" into "today".
  int get daysLeft {
    final now = DateTime.now();
    return DateTime.utc(dueDate.year, dueDate.month, dueDate.day)
        .difference(DateTime.utc(now.year, now.month, now.day))
        .inDays;
  }

  /// Computes HealthStatus from dueDate — uses relational pattern matching.
  HealthStatus get healthStatus {
    if (isDone) return HealthStatus.upToDate;
    return switch (daysLeft) {
      < 0 => HealthStatus.late,
      <= 7 => HealthStatus.upcoming,
      _ => HealthStatus.upToDate,
    };
  }

  /// Human due-date label shared by every reminder card.
  String get dueLabel => switch (daysLeft) {
        < 0 => 'En retard de ${-daysLeft} j',
        0 => "Aujourd'hui",
        1 => 'Demain',
        <= 30 => 'Dans $daysLeft jours',
        _ => DateFormat('d MMM', 'fr').format(dueDate),
      };
}

extension CatAgeExt on Cat {
  /// Returns formatted age string in French.
  String get ageLabel {
    final birth = birthDate;
    if (birth == null) return 'Âge inconnu';

    final now = DateTime.now();
    final years = now.year - birth.year -
        ((now.month < birth.month ||
                (now.month == birth.month && now.day < birth.day))
            ? 1
            : 0);
    final months = (now.month - birth.month + 12) % 12;

    return switch ((years, months)) {
      (0, 0) => 'Moins d\'un mois',
      (0, final m) => '$m mois',
      (final y, 0) => '$y an${y > 1 ? 's' : ''}',
      (final y, final m) => '$y an${y > 1 ? 's' : ''}, $m mois',
    };
  }
}
