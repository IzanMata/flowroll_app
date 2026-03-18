// ignore_for_file: prefer_const_constructors
import 'package:flowroll_app/shared/models/academy.dart';
import 'package:flowroll_app/shared/models/athlete.dart';
import 'package:flowroll_app/shared/models/attendance.dart';
import 'package:flowroll_app/shared/models/match.dart';
import 'package:flowroll_app/shared/models/paginated_response.dart';
import 'package:flowroll_app/shared/models/tatami.dart';
import 'package:flowroll_app/shared/models/technique.dart';

// ── Academy ────────────────────────────────────────────────────────────────

Academy fakeAcademy({int id = 1, String name = 'Test Academy', String? city = 'Bogotá'}) =>
    Academy(id: id, name: name, city: city, createdAt: DateTime(2024, 1, 1));

PaginatedResponse<Academy> fakeAcademiesPage([List<Academy>? items]) =>
    PaginatedResponse(count: items?.length ?? 1, results: items ?? [fakeAcademy()]);

// ── Athlete ────────────────────────────────────────────────────────────────

AthleteProfile fakeAthlete({
  int id = 1,
  String username = 'john_doe',
  String email = 'john@example.com',
  BeltEnum? belt = BeltEnum.blue,
  RoleEnum? role = RoleEnum.student,
  int stripes = 2,
}) =>
    AthleteProfile(
      id: id,
      user: id,
      username: username,
      email: email,
      academy: 1,
      academyDetail: fakeAcademy(),
      role: role,
      belt: belt,
      stripes: stripes,
    );

PaginatedResponse<AthleteProfile> fakeAthletesPage([List<AthleteProfile>? items]) =>
    PaginatedResponse(count: items?.length ?? 1, results: items ?? [fakeAthlete()]);

// ── TrainingClass ──────────────────────────────────────────────────────────

TrainingClass fakeClass({
  int id = 1,
  String title = 'Morning Gi',
  ClassTypeEnum? classType = ClassTypeEnum.gi,
  int attendanceCount = 5,
  int? maxCapacity = 20,
  String? notes,
}) =>
    TrainingClass(
      id: id,
      academy: 1,
      title: title,
      classType: classType,
      professorUsername: 'prof_jones',
      scheduledAt: DateTime.now(),
      durationMinutes: 60,
      maxCapacity: maxCapacity,
      notes: notes,
      attendanceCount: attendanceCount,
      createdAt: DateTime(2024, 1, 1),
    );

// ── DropInVisitor ──────────────────────────────────────────────────────────

DropInVisitor fakeDropIn({
  int id = 1,
  String firstName = 'Jane',
  String lastName = 'Visitor',
  String email = 'jane@example.com',
  DropInVisitorStatusEnum status = DropInVisitorStatusEnum.active,
}) =>
    DropInVisitor(
      id: id,
      academy: 1,
      firstName: firstName,
      lastName: lastName,
      email: email,
      accessToken: 'tok_$id',
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      status: status,
      createdAt: DateTime.now(),
    );

PaginatedResponse<DropInVisitor> fakeDropInsPage([List<DropInVisitor>? items]) =>
    PaginatedResponse(count: items?.length ?? 1, results: items ?? [fakeDropIn()]);

// ── Match ──────────────────────────────────────────────────────────────────

UserMinimal fakeUserMinimal({int id = 1, String username = 'athlete_a'}) =>
    UserMinimal(id: id, username: username);

Match fakeMatch({
  int id = 1,
  bool isFinished = false,
  int scoreA = 0,
  int scoreB = 0,
  int? winner,
  List<MatchEvent> events = const [],
}) =>
    Match(
      id: id,
      athleteA: 1,
      athleteB: 2,
      athleteADetail: fakeUserMinimal(id: 1, username: 'athlete_a'),
      athleteBDetail: fakeUserMinimal(id: 2, username: 'athlete_b'),
      date: DateTime.now(),
      isFinished: isFinished,
      scoreA: scoreA,
      scoreB: scoreB,
      winner: winner,
      winnerDetail: winner != null
          ? fakeUserMinimal(id: winner, username: winner == 1 ? 'athlete_a' : 'athlete_b')
          : null,
      events: events,
    );

PaginatedResponse<Match> fakeMatchesPage([List<Match>? items]) =>
    PaginatedResponse(count: items?.length ?? 1, results: items ?? [fakeMatch()]);

// ── TimerPreset ────────────────────────────────────────────────────────────

TimerPreset fakeTimerPreset({
  int id = 1,
  String name = '5 Minute Rounds',
  int roundDurationSeconds = 300,
  int rounds = 3,
}) =>
    TimerPreset(
      id: id,
      academy: 1,
      name: name,
      roundDurationSeconds: roundDurationSeconds,
      rounds: rounds,
    );

PaginatedResponse<TimerPreset> fakePresetsPage([List<TimerPreset>? items]) =>
    PaginatedResponse(count: items?.length ?? 1, results: items ?? [fakeTimerPreset()]);

// ── Technique ──────────────────────────────────────────────────────────────

Technique fakeTechnique({
  int id = 1,
  String name = 'Armbar',
  String minBelt = 'white',
  int? difficulty = 2,
  List<TechniqueCategory> categories = const [],
  List<TechniqueVariation> variations = const [],
}) =>
    Technique(
      id: id,
      name: name,
      minBelt: minBelt,
      difficulty: difficulty,
      categories: categories,
      variations: variations,
      leadsTo: const [],
    );

PaginatedResponse<Technique> fakeTechniquesPage([List<Technique>? items]) =>
    PaginatedResponse(count: items?.length ?? 1, results: items ?? [fakeTechnique()]);

// ── Convenience empty pages ────────────────────────────────────────────────

PaginatedResponse<T> emptyPage<T>() => PaginatedResponse<T>(count: 0, results: []);
