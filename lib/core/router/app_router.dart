import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_provider.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/academies/presentation/screens/academy_selector_screen.dart';
import '../../features/athletes/presentation/screens/athletes_list_screen.dart';
import '../../features/athletes/presentation/screens/athlete_detail_screen.dart';
import '../../features/athletes/presentation/screens/athlete_form_screen.dart';
import '../../features/attendance/presentation/screens/classes_list_screen.dart';
import '../../features/attendance/presentation/screens/class_detail_screen.dart';
import '../../features/attendance/presentation/screens/qr_generator_screen.dart';
import '../../features/attendance/presentation/screens/qr_scanner_screen.dart';
import '../../features/attendance/presentation/screens/drop_ins_screen.dart';
import '../../features/matches/presentation/screens/matches_list_screen.dart';
import '../../features/matches/presentation/screens/live_match_screen.dart';
import '../../features/matches/presentation/screens/match_detail_screen.dart';
import '../../features/tatami/presentation/screens/matchups_screen.dart';
import '../../features/tatami/presentation/screens/timer_presets_screen.dart';
import '../../features/tatami/presentation/screens/timer_session_screen.dart';
import '../../features/tatami/presentation/screens/weight_classes_screen.dart';
import '../../features/techniques/presentation/screens/techniques_curriculum_screen.dart';
import '../../features/techniques/presentation/screens/technique_detail_screen.dart';
import '../../shared/widgets/main_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuth = authState.valueOrNull ?? false;
      final isOnAuth = state.uri.path.startsWith('/login') || state.uri.path == '/splash';

      if (!isAuth && !isOnAuth) return '/login';
      if (isAuth && state.uri.path == '/login') return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/select-academy', builder: (_, __) => const AcademySelectorScreen()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const ClassesListScreen(),
            routes: [
              GoRoute(
                path: 'class/:id',
                builder: (_, state) =>
                    ClassDetailScreen(classId: int.parse(state.pathParameters['id']!)),
              ),
              GoRoute(
                path: 'class/:id/qr',
                builder: (_, state) =>
                    QrGeneratorScreen(classId: int.parse(state.pathParameters['id']!)),
              ),
            ],
          ),
          GoRoute(
            path: '/athletes',
            builder: (_, __) => const AthletesListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) =>
                    AthleteDetailScreen(athleteId: int.parse(state.pathParameters['id']!)),
              ),
              GoRoute(path: 'new', builder: (_, __) => const AthleteFormScreen()),
              GoRoute(
                path: ':id/edit',
                builder: (_, state) =>
                    AthleteFormScreen(athleteId: int.parse(state.pathParameters['id']!)),
              ),
            ],
          ),
          GoRoute(
            path: '/matches',
            builder: (_, __) => const MatchesListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) =>
                    MatchDetailScreen(matchId: int.parse(state.pathParameters['id']!)),
              ),
              GoRoute(
                path: ':id/live',
                builder: (_, state) =>
                    LiveMatchScreen(matchId: int.parse(state.pathParameters['id']!)),
              ),
            ],
          ),
          GoRoute(
            path: '/tatami',
            builder: (_, __) => const MatchupsScreen(),
            routes: [
              GoRoute(path: 'timers', builder: (_, __) => const TimerPresetsScreen()),
              GoRoute(
                path: 'timers/:id/session',
                builder: (_, state) =>
                    TimerSessionScreen(presetId: int.parse(state.pathParameters['id']!)),
              ),
              GoRoute(path: 'weights', builder: (_, __) => const WeightClassesScreen()),
            ],
          ),
          GoRoute(
            path: '/techniques',
            builder: (_, __) => const TechniquesCurriculumScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) =>
                    TechniqueDetailScreen(techniqueId: int.parse(state.pathParameters['id']!)),
              ),
            ],
          ),
          GoRoute(
            path: '/drop-ins',
            builder: (_, __) => const DropInsScreen(),
          ),
        ],
      ),
      GoRoute(path: '/qr-scan', builder: (_, __) => const QrScannerScreen()),
    ],
  );
});
