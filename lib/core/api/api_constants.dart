abstract final class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  // Auth
  static const String tokenPath = '/api/auth/token/';
  static const String tokenRefreshPath = '/api/auth/token/refresh/';

  // Academies
  static const String academiesPath = '/api/academies/';

  // Athletes
  static const String athletesPath = '/api/athletes/';

  // Attendance
  static const String classesPath = '/api/attendance/classes/';
  static const String manualCheckinPath = '/api/attendance/classes/manual_checkin/';
  static const String qrCheckinPath = '/api/attendance/classes/qr_checkin/';
  static const String dropInsPath = '/api/attendance/drop-ins/';

  // Matches
  static const String matchesPath = '/api/matches/';

  // Tatami
  static const String matchupsPath = '/api/tatami/matchups/';
  static const String pairAthletesPath = '/api/tatami/matchups/pair_athletes/';
  static const String timerPresetsPath = '/api/tatami/timer-presets/';
  static const String timerSessionsPath = '/api/tatami/timer-sessions/';
  static const String weightClassesPath = '/api/tatami/weight-classes/';

  // Techniques
  static const String beltsPath = '/api/techniques/belts/';
  static const String techniqueCategoriesPath = '/api/techniques/categories/';
  static const String techniquesPath = '/api/techniques/techniques/';
  static const String variationsPath = '/api/techniques/variations/';

  // Query params
  static const String academyParam = 'academy';
  static const String pageParam = 'page';
  static const String searchParam = 'search';
  static const String orderingParam = 'ordering';
}
