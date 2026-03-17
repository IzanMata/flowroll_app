enum MatchFormatEnum {
  tournament('TOURNAMENT'),
  survival('SURVIVAL');

  const MatchFormatEnum(this.value);
  final String value;

  static MatchFormatEnum? fromJson(String? v) =>
      v == null ? null : MatchFormatEnum.values.firstWhere((e) => e.value == v, orElse: () => MatchFormatEnum.tournament);
}

enum MatchupStatusEnum {
  pending('PENDING'),
  inProgress('IN_PROGRESS'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  const MatchupStatusEnum(this.value);
  final String value;

  static MatchupStatusEnum? fromJson(String? v) =>
      v == null ? null : MatchupStatusEnum.values.firstWhere((e) => e.value == v, orElse: () => MatchupStatusEnum.pending);
}

enum FormatEnum {
  ibjjf('IBJJF'),
  adcc('ADCC'),
  positional('POSITIONAL'),
  custom('CUSTOM');

  const FormatEnum(this.value);
  final String value;

  static FormatEnum? fromJson(String? v) =>
      v == null ? null : FormatEnum.values.firstWhere((e) => e.value == v, orElse: () => FormatEnum.custom);
}

enum TimerSessionStatusEnum {
  idle('IDLE'),
  running('RUNNING'),
  paused('PAUSED'),
  finished('FINISHED');

  const TimerSessionStatusEnum(this.value);
  final String value;

  static TimerSessionStatusEnum? fromJson(String? v) =>
      v == null ? null : TimerSessionStatusEnum.values.firstWhere((e) => e.value == v, orElse: () => TimerSessionStatusEnum.idle);
}

class Matchup {
  const Matchup({
    required this.id,
    required this.academy,
    required this.athleteA,
    required this.athleteAName,
    required this.athleteB,
    required this.athleteBName,
    this.weightClass,
    this.matchFormat,
    this.roundNumber,
    this.status,
    this.winner,
    this.winnerName,
    required this.createdAt,
  });

  final int id;
  final int academy;
  final int athleteA;
  final String athleteAName;
  final int athleteB;
  final String athleteBName;
  final int? weightClass;
  final MatchFormatEnum? matchFormat;
  final int? roundNumber;
  final MatchupStatusEnum? status;
  final int? winner;
  final String? winnerName;
  final DateTime createdAt;

  factory Matchup.fromJson(Map<String, dynamic> json) => Matchup(
        id: json['id'] as int,
        academy: json['academy'] as int,
        athleteA: json['athlete_a'] as int,
        athleteAName: json['athlete_a_name'] as String,
        athleteB: json['athlete_b'] as int,
        athleteBName: json['athlete_b_name'] as String,
        weightClass: json['weight_class'] as int?,
        matchFormat: MatchFormatEnum.fromJson(json['match_format'] as String?),
        roundNumber: json['round_number'] as int?,
        status: MatchupStatusEnum.fromJson(json['status'] as String?),
        winner: json['winner'] as int?,
        winnerName: json['winner_name'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Matchup && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class TimerPreset {
  const TimerPreset({
    required this.id,
    required this.academy,
    required this.name,
    this.format,
    this.roundDurationSeconds,
    this.restDurationSeconds,
    this.overtimeSeconds,
    this.rounds,
  });

  final int id;
  final int academy;
  final String name;
  final FormatEnum? format;
  final int? roundDurationSeconds;
  final int? restDurationSeconds;
  final int? overtimeSeconds;
  final int? rounds;

  factory TimerPreset.fromJson(Map<String, dynamic> json) => TimerPreset(
        id: json['id'] as int,
        academy: json['academy'] as int,
        name: json['name'] as String,
        format: FormatEnum.fromJson(json['format'] as String?),
        roundDurationSeconds: json['round_duration_seconds'] as int?,
        restDurationSeconds: json['rest_duration_seconds'] as int?,
        overtimeSeconds: json['overtime_seconds'] as int?,
        rounds: json['rounds'] as int?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TimerPreset && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class TimerSession {
  const TimerSession({
    required this.id,
    required this.preset,
    required this.presetName,
    this.status,
    this.currentRound,
    this.startedAt,
    this.pausedAt,
    required this.elapsedSeconds,
  });

  final int id;
  final int preset;
  final String presetName;
  final TimerSessionStatusEnum? status;
  final int? currentRound;
  final DateTime? startedAt;
  final DateTime? pausedAt;
  final int elapsedSeconds;

  factory TimerSession.fromJson(Map<String, dynamic> json) => TimerSession(
        id: json['id'] as int,
        preset: json['preset'] as int,
        presetName: json['preset_name'] as String,
        status: TimerSessionStatusEnum.fromJson(json['status'] as String?),
        currentRound: json['current_round'] as int?,
        startedAt: json['started_at'] != null ? DateTime.parse(json['started_at'] as String) : null,
        pausedAt: json['paused_at'] != null ? DateTime.parse(json['paused_at'] as String) : null,
        elapsedSeconds: json['elapsed_seconds'] as int,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TimerSession && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class WeightClass {
  const WeightClass({
    required this.id,
    required this.name,
    this.maxKg,
    this.gender,
    this.ageGroup,
  });

  final int id;
  final String name;
  final double? maxKg;
  final String? gender;
  final String? ageGroup;

  factory WeightClass.fromJson(Map<String, dynamic> json) => WeightClass(
        id: json['id'] as int,
        name: json['name'] as String,
        maxKg: (json['max_kg'] as num?)?.toDouble(),
        gender: json['gender'] as String?,
        ageGroup: json['age_group'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WeightClass && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
