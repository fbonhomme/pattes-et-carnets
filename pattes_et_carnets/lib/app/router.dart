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
      builder: (context, state) =>
          JournalScreen(catId: state.pathParameters['catId']!),
    ),
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
