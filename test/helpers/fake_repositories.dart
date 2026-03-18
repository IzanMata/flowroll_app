import 'package:flowroll_app/features/academies/data/academies_repository.dart';
import 'package:flowroll_app/features/athletes/data/athletes_repository.dart';
import 'package:flowroll_app/features/attendance/data/attendance_repository.dart';
import 'package:flowroll_app/features/matches/data/matches_repository.dart';
import 'package:flowroll_app/features/tatami/data/tatami_repository.dart';
import 'package:flowroll_app/features/techniques/data/techniques_repository.dart';
import 'package:flowroll_app/shared/models/academy.dart';
import 'package:flowroll_app/shared/models/athlete.dart';
import 'package:flowroll_app/shared/models/attendance.dart';
import 'package:flowroll_app/shared/models/match.dart';
import 'package:flowroll_app/shared/models/paginated_response.dart';
import 'package:flowroll_app/shared/models/tatami.dart';
import 'package:flowroll_app/shared/models/technique.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks (for verify() calls) ─────────────────────────────────────────────

class MockAcademiesRepository extends Mock implements AcademiesRepository {}
class MockAthletesRepository extends Mock implements AthletesRepository {}
class MockAttendanceRepository extends Mock implements AttendanceRepository {}
class MockMatchesRepository extends Mock implements MatchesRepository {}
class MockTatamiRepository extends Mock implements TatamiRepository {}
class MockTechniquesRepository extends Mock implements TechniquesRepository {}

// ── Fallback registrations (required by mocktail) ─────────────────────────

void registerFallbacks() {
  registerFallbackValue(BeltEnum.white);
  registerFallbackValue(RoleEnum.student);
  registerFallbackValue(ClassTypeEnum.gi);
  registerFallbackValue(EventTypeEnum.points);
  registerFallbackValue(MatchFormatEnum.tournament);
}

// ── Stub helpers ───────────────────────────────────────────────────────────

extension AcademiesRepoStubs on MockAcademiesRepository {
  void stubListAcademies(PaginatedResponse<Academy> page) {
    when(() => listAcademies(page: any(named: 'page'), search: any(named: 'search')))
        .thenAnswer((_) async => page);
  }
}

extension AthletesRepoStubs on MockAthletesRepository {
  void stubListAthletes(PaginatedResponse<AthleteProfile> page) {
    when(() => listAthletes(
          academyId: any(named: 'academyId'),
          page: any(named: 'page'),
          search: any(named: 'search'),
          ordering: any(named: 'ordering'),
        )).thenAnswer((_) async => page);
  }

  void stubGetAthlete(AthleteProfile athlete) {
    when(() => getAthlete(any())).thenAnswer((_) async => athlete);
  }

  void stubCreateAthlete(AthleteProfile athlete) {
    when(() => createAthlete(
          userId: any(named: 'userId'),
          academyId: any(named: 'academyId'),
          belt: any(named: 'belt'),
          role: any(named: 'role'),
          stripes: any(named: 'stripes'),
        )).thenAnswer((_) async => athlete);
  }

  void stubUpdateAthlete(AthleteProfile athlete) {
    when(() => updateAthlete(
          any(),
          belt: any(named: 'belt'),
          role: any(named: 'role'),
          stripes: any(named: 'stripes'),
        )).thenAnswer((_) async => athlete);
  }

  void stubCreateAthleteFails(Exception error) {
    when(() => createAthlete(
          userId: any(named: 'userId'),
          academyId: any(named: 'academyId'),
          belt: any(named: 'belt'),
          role: any(named: 'role'),
          stripes: any(named: 'stripes'),
        )).thenThrow(error);
  }
}

extension AttendanceRepoStubs on MockAttendanceRepository {
  void stubListClasses(PaginatedResponse<TrainingClass> page) {
    when(() => listClasses(
          academyId: any(named: 'academyId'),
          page: any(named: 'page'),
          search: any(named: 'search'),
          classType: any(named: 'classType'),
          scheduledAfter: any(named: 'scheduledAfter'),
          scheduledBefore: any(named: 'scheduledBefore'),
        )).thenAnswer((_) async => page);
  }

  void stubGetClass(TrainingClass cls) {
    when(() => getClass(any())).thenAnswer((_) async => cls);
  }

  void stubManualCheckIn() {
    when(() => manualCheckIn(
          athleteId: any(named: 'athleteId'),
          trainingClassId: any(named: 'trainingClassId'),
        )).thenAnswer((_) async => CheckIn(
              id: 1,
              athlete: 1,
              athleteUsername: 'test_user',
              trainingClass: 1,
              checkedInAt: DateTime.now(),
            ));
  }

  void stubManualCheckInFails(Exception error) {
    when(() => manualCheckIn(
          athleteId: any(named: 'athleteId'),
          trainingClassId: any(named: 'trainingClassId'),
        )).thenThrow(error);
  }

  void stubListDropIns(PaginatedResponse<DropInVisitor> page) {
    when(() => listDropIns(academyId: any(named: 'academyId')))
        .thenAnswer((_) async => page);
  }

  void stubCreateDropIn(DropInVisitor visitor) {
    when(() => createDropIn(
          academyId: any(named: 'academyId'),
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          email: any(named: 'email'),
          phone: any(named: 'phone'),
          expiresAt: any(named: 'expiresAt'),
        )).thenAnswer((_) async => visitor);
  }

  void stubCreateDropInFails(Exception error) {
    when(() => createDropIn(
          academyId: any(named: 'academyId'),
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          email: any(named: 'email'),
          phone: any(named: 'phone'),
          expiresAt: any(named: 'expiresAt'),
        )).thenThrow(error);
  }
}

extension MatchesRepoStubs on MockMatchesRepository {
  void stubListMatches(PaginatedResponse<Match> page) {
    when(() => listMatches(
          academyId: any(named: 'academyId'),
          page: any(named: 'page'),
          search: any(named: 'search'),
        )).thenAnswer((_) async => page);
  }

  void stubGetMatch(Match match) {
    when(() => getMatch(any(), academyId: any(named: 'academyId')))
        .thenAnswer((_) async => match);
  }

  void stubCreateMatch(Match match) {
    when(() => createMatch(
          athleteA: any(named: 'athleteA'),
          athleteB: any(named: 'athleteB'),
          academyId: any(named: 'academyId'),
        )).thenAnswer((_) async => match);
  }

  void stubCreateMatchFails(Exception error) {
    when(() => createMatch(
          athleteA: any(named: 'athleteA'),
          athleteB: any(named: 'athleteB'),
          academyId: any(named: 'academyId'),
        )).thenThrow(error);
  }

  void stubAddEvent(Match match) {
    when(() => addEvent(
          matchId: any(named: 'matchId'),
          athleteId: any(named: 'athleteId'),
          timestamp: any(named: 'timestamp'),
          actionDescription: any(named: 'actionDescription'),
          eventType: any(named: 'eventType'),
          pointsAwarded: any(named: 'pointsAwarded'),
          academyId: any(named: 'academyId'),
        )).thenAnswer((_) async => match);
  }

  void stubFinishMatch(Match match) {
    when(() => finishMatch(
          matchId: any(named: 'matchId'),
          athleteA: any(named: 'athleteA'),
          athleteB: any(named: 'athleteB'),
          winnerId: any(named: 'winnerId'),
          academyId: any(named: 'academyId'),
        )).thenAnswer((_) async => match);
  }
}

extension TatamiRepoStubs on MockTatamiRepository {
  void stubListPresets(PaginatedResponse<TimerPreset> page) {
    when(() => listTimerPresets(academyId: any(named: 'academyId')))
        .thenAnswer((_) async => page);
  }
}

extension TechniquesRepoStubs on MockTechniquesRepository {
  void stubListTechniques(PaginatedResponse<Technique> page) {
    when(() => listTechniques(
          page: any(named: 'page'),
          search: any(named: 'search'),
        )).thenAnswer((_) async => page);
  }
}
