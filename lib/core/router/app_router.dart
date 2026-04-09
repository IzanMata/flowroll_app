import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_provider.dart';
import '../../features/academies/presentation/screens/academy_selector_screen.dart';
import '../../features/athletes/presentation/screens/athlete_detail_screen.dart';
import '../../features/athletes/presentation/screens/athlete_form_screen.dart';
import '../../features/athletes/presentation/screens/athletes_list_screen.dart';
import '../../features/attendance/presentation/screens/class_detail_screen.dart';
import '../../features/attendance/presentation/screens/classes_list_screen.dart';
import '../../features/attendance/presentation/screens/drop_ins_screen.dart';
import '../../features/attendance/presentation/screens/qr_generator_screen.dart';
import '../../features/attendance/presentation/screens/qr_scanner_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/matches/presentation/screens/live_match_screen.dart';
import '../../features/matches/presentation/screens/match_detail_screen.dart';
import '../../features/matches/presentation/screens/matches_list_screen.dart';
import '../../features/tatami/presentation/screens/matchups_screen.dart';
import '../../features/tatami/presentation/screens/timer_presets_screen.dart';
import '../../features/tatami/presentation/screens/timer_session_screen.dart';
import '../../features/tatami/presentation/screens/weight_classes_screen.dart';
import '../../features/techniques/presentation/screens/technique_detail_screen.dart';
import '../../features/techniques/presentation/screens/techniques_curriculum_screen.dart';
import '../../shared/widgets/main_shell.dart';

// ─── Transition helpers ──────────────────────────────────────────────────────

Page<T> _slidePage<T>(Widget child, GoRouterState state) =>
    CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (_, animation, secondaryAnimation, c) {
        final slide = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

        final fadeOut = Tween<double>(begin: 1.0, end: 0.85).animate(
          CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInCubic),
        );

        return FadeTransition(
          opacity: fadeOut,
          child: SlideTransition(position: slide, child: c),
        );
      },
    );

Page<T> _bottomSlidePage<T>(Widget child, GoRouterState state) =>
    CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (_, animation, __, c) {
        final slide = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return SlideTransition(position: slide, child: c);
      },
    );

Page<T> _fadePage<T>(Widget child, GoRouterState state) =>
    CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (_, animation, __, c) =>
          FadeTransition(opacity: animation, child: c),
    );

// ─── Router ──────────────────────────────────────────────────────────────────

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(isAuthenticatedProvider);
  final academyId = ref.watch(selectedAcademyIdProvider);

  // Routes inside the ShellRoute that require an academy to be selected
  const shellPrefixes = ['/home', '/athletes', '/matches', '/tatami', '/techniques', '/drop-ins'];

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuth = authState.valueOrNull ?? false;
      final path = state.uri.path;
      final isOnAuth = path.startsWith('/login');

      if (!isAuth && !isOnAuth) return '/login';
      if (isAuth && path == '/login') return '/home';

      // Authenticated but no academy selected → force selection
      if (isAuth &&
          academyId == null &&
          path != '/select-academy' &&
          shellPrefixes.any((p) => path.startsWith(p))) {
        return '/select-academy';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (_, s) => _fadePage(const LoginScreen(), s),
      ),
      GoRoute(
        path: '/select-academy',
        pageBuilder: (_, s) => _bottomSlidePage(const AcademySelectorScreen(), s),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (_, s) => _fadePage(const ClassesListScreen(), s),
            routes: [
              GoRoute(
                path: 'class/:id',
                pageBuilder: (_, s) {
                  final id = int.tryParse(s.pathParameters['id'] ?? '');
                  if (id == null) return _fadePage(const ClassesListScreen(), s);
                  return _slidePage(ClassDetailScreen(classId: id), s);
                },
              ),
              GoRoute(
                path: 'class/:id/qr',
                pageBuilder: (_, s) {
                  final id = int.tryParse(s.pathParameters['id'] ?? '');
                  if (id == null) return _fadePage(const ClassesListScreen(), s);
                  return _slidePage(QrGeneratorScreen(classId: id), s);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/athletes',
            pageBuilder: (_, s) => _fadePage(const AthletesListScreen(), s),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (_, s) {
                  final id = int.tryParse(s.pathParameters['id'] ?? '');
                  if (id == null) return _fadePage(const AthletesListScreen(), s);
                  return _slidePage(AthleteDetailScreen(athleteId: id), s);
                },
              ),
              GoRoute(
                path: 'new',
                pageBuilder: (_, s) => _slidePage(const AthleteFormScreen(), s),
              ),
              GoRoute(
                path: ':id/edit',
                pageBuilder: (_, s) {
                  final id = int.tryParse(s.pathParameters['id'] ?? '');
                  if (id == null) return _fadePage(const AthletesListScreen(), s);
                  return _slidePage(AthleteFormScreen(athleteId: id), s);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/matches',
            pageBuilder: (_, s) => _fadePage(const MatchesListScreen(), s),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (_, s) {
                  final id = int.tryParse(s.pathParameters['id'] ?? '');
                  if (id == null) return _fadePage(const MatchesListScreen(), s);
                  return _slidePage(MatchDetailScreen(matchId: id), s);
                },
              ),
              GoRoute(
                path: ':id/live',
                pageBuilder: (_, s) {
                  final id = int.tryParse(s.pathParameters['id'] ?? '');
                  if (id == null) return _fadePage(const MatchesListScreen(), s);
                  return _bottomSlidePage(LiveMatchScreen(matchId: id), s);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/tatami',
            pageBuilder: (_, s) => _fadePage(const MatchupsScreen(), s),
            routes: [
              GoRoute(
                path: 'timers',
                pageBuilder: (_, s) => _slidePage(const TimerPresetsScreen(), s),
              ),
              GoRoute(
                path: 'timers/:id/session',
                pageBuilder: (_, s) {
                  final id = int.tryParse(s.pathParameters['id'] ?? '');
                  if (id == null) return _fadePage(const TimerPresetsScreen(), s);
                  return _bottomSlidePage(TimerSessionScreen(presetId: id), s);
                },
              ),
              GoRoute(
                path: 'weights',
                pageBuilder: (_, s) => _slidePage(const WeightClassesScreen(), s),
              ),
            ],
          ),
          GoRoute(
            path: '/techniques',
            pageBuilder: (_, s) => _fadePage(const TechniquesCurriculumScreen(), s),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (_, s) {
                  final id = int.tryParse(s.pathParameters['id'] ?? '');
                  if (id == null) return _fadePage(const TechniquesCurriculumScreen(), s);
                  return _slidePage(TechniqueDetailScreen(techniqueId: id), s);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/drop-ins',
            pageBuilder: (_, s) => _slidePage(const DropInsScreen(), s),
          ),
        ],
      ),
      GoRoute(
        path: '/qr-scan',
        pageBuilder: (_, s) => _bottomSlidePage(const QrScannerScreen(), s),
      ),
    ],
  );
});
