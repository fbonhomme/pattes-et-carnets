import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pattes_et_carnets/features/home/home_screen.dart';
import 'package:pattes_et_carnets/features/journal/journal_screen.dart';
import 'package:pattes_et_carnets/features/calendar/calendar_screen.dart';
import 'package:pattes_et_carnets/features/cat_profile/cat_profile_screen.dart';
import 'package:pattes_et_carnets/features/emergency/emergency_screen.dart';
import 'package:pattes_et_carnets/features/splash/splash_screen.dart';
import 'package:pattes_et_carnets/shared/widgets/scaffold_with_nav.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/splash',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: SplashScreen(),
      ),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => ScaffoldWithNav(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/journal',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const JournalScreen(),
          ),
        ),
        GoRoute(
          path: '/calendar',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const CalendarScreen(),
          ),
        ),
      ],
    ),
    // Full-screen routes (outside the shell / bottom nav)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/journal/:catId',
      redirect: _requireCatId,
      builder: (context, state) => JournalScreen(catId: _catId(state)),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/cat/:catId',
      redirect: _requireCatId,
      builder: (context, state) => CatProfileScreen(catId: _catId(state)),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/emergency/:catId',
      redirect: _requireCatId,
      builder: (context, state) => EmergencyScreen(catId: _catId(state)),
    ),
  ],
);

// Parse the :catId path parameter once here so screens receive an int.
int? _tryCatId(GoRouterState state) =>
    int.tryParse(state.pathParameters['catId'] ?? '');

int _catId(GoRouterState state) => _tryCatId(state)!;

String? _requireCatId(BuildContext context, GoRouterState state) =>
    _tryCatId(state) == null ? '/' : null;
