import 'package:flutter/material.dart';

enum CatSex { male, female }

enum HealthEntryType {
  vaccination,
  antiparasitaire,
  vermifuge,
  alimentation,
  visite,
  note,
}

enum ReminderType {
  vaccin,
  vermifuge,
  rdvVeterinaire,
  antiparasitaire,
  hygiene,
  traitement,
}

/// Computed at runtime from a Reminder's dueDate — never stored in DB.
enum HealthStatus { upToDate, upcoming, late }

// ---------------------------------------------------------------------------
// Extensions — labels, icons, colors
// ---------------------------------------------------------------------------

extension CatSexExt on CatSex {
  String get label => switch (this) {
        CatSex.male => 'Mâle',
        CatSex.female => 'Femelle',
      };

  IconData get icon => switch (this) {
        CatSex.male => Icons.male,
        CatSex.female => Icons.female,
      };
}

extension HealthEntryTypeExt on HealthEntryType {
  String get label => switch (this) {
        HealthEntryType.vaccination => 'Vaccination',
        HealthEntryType.antiparasitaire => 'Antiparasitaire',
        HealthEntryType.vermifuge => 'Vermifuge',
        HealthEntryType.alimentation => 'Alimentation',
        HealthEntryType.visite => 'Visite vétérinaire',
        HealthEntryType.note => 'Note',
      };

  IconData get icon => switch (this) {
        HealthEntryType.vaccination => Icons.vaccines,
        HealthEntryType.antiparasitaire => Icons.bug_report,
        HealthEntryType.vermifuge => Icons.medication,
        HealthEntryType.alimentation => Icons.restaurant,
        HealthEntryType.visite => Icons.local_hospital,
        HealthEntryType.note => Icons.edit_note,
      };
}

extension ReminderTypeExt on ReminderType {
  String get label => switch (this) {
        ReminderType.vaccin => 'Vaccin',
        ReminderType.vermifuge => 'Vermifuge',
        ReminderType.rdvVeterinaire => 'RDV vétérinaire',
        ReminderType.antiparasitaire => 'Antiparasitaire',
        ReminderType.hygiene => 'Hygiène',
        ReminderType.traitement => 'Traitement',
      };

  IconData get icon => switch (this) {
        ReminderType.vaccin => Icons.vaccines,
        ReminderType.vermifuge => Icons.medication,
        ReminderType.rdvVeterinaire => Icons.medical_services,
        ReminderType.antiparasitaire => Icons.bug_report,
        ReminderType.hygiene => Icons.soap,
        ReminderType.traitement => Icons.medical_services,
      };
}

extension HealthStatusExt on HealthStatus {
  String get label => switch (this) {
        HealthStatus.upToDate => 'À jour',
        HealthStatus.upcoming => 'À venir',
        HealthStatus.late => 'En retard',
      };

  /// Returns the design-system color token name — resolved against ColorScheme in UI.
  Color statusColor(ColorScheme scheme) => switch (this) {
        HealthStatus.upToDate => scheme.primary,
        HealthStatus.upcoming => scheme.secondary,
        HealthStatus.late => scheme.error,
      };

  Color statusContainerColor(ColorScheme scheme) => switch (this) {
        HealthStatus.upToDate => scheme.primaryContainer,
        HealthStatus.upcoming => scheme.secondaryContainer,
        HealthStatus.late => scheme.errorContainer,
      };
}
