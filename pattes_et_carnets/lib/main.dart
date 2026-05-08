import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pattes_et_carnets/app/router.dart';
import 'package:pattes_et_carnets/app/theme.dart';
import 'package:pattes_et_carnets/shared/database/app_database.dart';
import 'package:pattes_et_carnets/shared/database/database_seeder.dart';
import 'package:pattes_et_carnets/shared/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr', null);
  await NotificationService.init();

  final db = AppDatabase();
  await DatabaseSeeder(db).seedIfEmpty();

  // Reschedule all pending reminders so notifications survive app restarts.
  final pendingReminders = await db.remindersDao.getPendingReminders();
  final cats = await db.catsDao.getAllCats();
  final catNames = {for (final c in cats) c.id: c.name};
  await NotificationService.rescheduleAll(pendingReminders, catNames);

  await db.close();
  runApp(const ProviderScope(child: PattesEtCarnetsApp()));
}

class PattesEtCarnetsApp extends StatelessWidget {
  const PattesEtCarnetsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pattes & Carnets',
      theme: AppTheme.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
