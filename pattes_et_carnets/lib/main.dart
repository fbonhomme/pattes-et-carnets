import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pattes_et_carnets/app/router.dart';
import 'package:pattes_et_carnets/app/theme.dart';
import 'package:pattes_et_carnets/shared/providers/database_provider.dart';
import 'package:pattes_et_carnets/shared/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr', null);
  await NotificationService.init();

  // One container so startup work and the UI share the same database.
  final container = ProviderContainer();
  try {
    final db = container.read(databaseProvider);
    // Reschedule pending reminders so notifications survive app restarts.
    final pendingReminders = await db.remindersDao.getPendingReminders();
    final cats = await db.catsDao.getAllCats();
    final catNames = {for (final c in cats) c.id: c.name};
    await NotificationService.rescheduleAll(pendingReminders, catNames);
  } catch (e) {
    // Never block startup because of notification/DB errors.
    debugPrint('Startup reschedule failed: $e');
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PattesEtCarnetsApp(),
    ),
  );
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
