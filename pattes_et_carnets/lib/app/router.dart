import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pattes_et_carnets/features/home/home_screen.dart';
import 'package:pattes_et_carnets/features/journal/journal_screen.dart';
import 'package:pattes_et_carnets/features/calendar/calendar_screen.dart';
import 'package:pattes_et_carnets/features/cat_profile/cat_profile_screen.dart';
import 'package:pattes_et_carnets/features/emergency/emergency_screen.dart';
import 'package:pattes_et_carnets/shared/widgets/scaffold_with_nav.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => ScaffoldWithNav(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/journal/:catId',
          pageBuilder: (context, state) => NoTransitionPage(
            child: JournalScreen(catId: state.pathParameters['catId']!),
          ),
        ),
        GoRoute(
          path: '/calendar',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CalendarScreen(),
          ),
        ),
      ],
    ),
    // Full-screen routes (outside the shell / bottom nav)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/cat/:catId',
      builder: (context, state) =>
          CatProfileScreen(catId: state.pathParameters['catId']!),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/emergency/:catId',
      builder: (context, state) =>
          EmergencyScreen(catId: state.pathParameters['catId']!),
    ),
  ],
);
