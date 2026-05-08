# Pattes & Carnets

Application mobile Flutter de suivi santé pour chats. Gérez les profils de vos chats, suivez leurs soins, planifiez des rappels et réagissez rapidement en cas d'urgence.

## Fonctionnalités

- **Profils chats** — nom, race, sexe, date de naissance, poids, groupe sanguin, numéro de puce, allergies, vétérinaire attitré, photo de profil (caméra ou galerie)
- **Journal de santé** — notes de soins : vaccinations, antiparasitaires, vermifuges, visites vétérinaires, alimentation
- **Rappels & calendrier** — planification des soins à venir avec notifications push, vue calendrier mensuelle
- **Mode urgence** — fiche d'urgence rapide par chat (coordonnées vétérinaire, informations médicales clés)
- **Écran de démarrage** — splash screen animé au lancement

## Stack technique

| Couche | Technologie |
|---|---|
| UI | Flutter 3, Material 3 |
| État | Riverpod 2 (StreamProvider, ConsumerWidget) |
| Navigation | GoRouter 14 |
| Base de données | Drift (SQLite) avec DAOs et code généré |
| Notifications | flutter_local_notifications |
| Typographie | Quicksand, Nunito Sans (google_fonts) |
| Photo | image_picker |

## Architecture

```
lib/
├── app/
│   ├── router.dart       # GoRouter — toutes les routes
│   └── theme.dart        # Design system (couleurs, typographie)
├── features/
│   ├── splash/           # Écran de démarrage
│   ├── home/             # Liste des chats + stats
│   ├── cat_profile/      # Profil détaillé d'un chat
│   ├── journal/          # Journal de santé
│   ├── calendar/         # Vue calendrier des rappels
│   └── emergency/        # Fiche d'urgence
└── shared/
    ├── database/
    │   ├── app_database.dart   # Schéma Drift
    │   └── daos/               # CatsDao, VetsDao, RemindersDao, HealthEntriesDao
    ├── models/                 # Enums (CatSex, ReminderType, HealthEntryType…)
    ├── providers/              # Providers Riverpod partagés
    ├── services/               # NotificationService
    └── widgets/                # Composants réutilisables
```

## Lancer le projet

```bash
# Dépendances
flutter pub get

# Génération du code Drift + Riverpod
dart run build_runner build --delete-conflicting-outputs

# Lancer en debug
flutter run
```

## Build Android (APK)

```bash
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 flutter build apk --release
# APK : build/app/outputs/flutter-apk/app-release.apk
```

> Prérequis : Android SDK dans `~/android-sdk/`, NDK 27, Java 17.

## Permissions Android

| Permission | Usage |
|---|---|
| `CAMERA` | Photo de profil via appareil photo |
| `READ_MEDIA_IMAGES` | Accès galerie (Android 13+) |
| `READ_EXTERNAL_STORAGE` | Accès galerie (Android ≤ 12) |
| `POST_NOTIFICATIONS` | Notifications de rappels |
| `SCHEDULE_EXACT_ALARM` | Rappels à heure exacte |
| `RECEIVE_BOOT_COMPLETED` | Replanification au démarrage |
