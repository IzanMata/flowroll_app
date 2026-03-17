import 'athlete.dart';

enum EventTypeEnum {
  points('POINTS'),
  advantage('ADVANTAGE'),
  penalty('PENALTY'),
  submission('SUBMISSION');

  const EventTypeEnum(this.value);
  final String value;

  static EventTypeEnum fromJson(String v) =>
      EventTypeEnum.values.firstWhere((e) => e.value == v, orElse: () => EventTypeEnum.points);
}

class MatchEvent {
  const MatchEvent({
    required this.id,
    required this.athlete,
    required this.athleteName,
    required this.timestamp,
    this.pointsAwarded,
    required this.actionDescription,
    required this.eventType,
  });

  final int id;
  final int athlete;
  final String athleteName;
  final int timestamp;
  final int? pointsAwarded;
  final String actionDescription;
  final EventTypeEnum eventType;

  factory MatchEvent.fromJson(Map<String, dynamic> json) => MatchEvent(
        id: json['id'] as int,
        athlete: json['athlete'] as int,
        athleteName: json['athlete_name'] as String,
        timestamp: json['timestamp'] as int,
        pointsAwarded: json['points_awarded'] as int?,
        actionDescription: json['action_description'] as String,
        eventType: EventTypeEnum.fromJson(json['event_type'] as String),
      );
}

class Match {
  const Match({
    required this.id,
    required this.athleteA,
    required this.athleteB,
    required this.athleteADetail,
    required this.athleteBDetail,
    required this.date,
    this.durationSeconds,
    required this.isFinished,
    required this.scoreA,
    required this.scoreB,
    this.winner,
    this.winnerDetail,
    required this.events,
  });

  final int id;
  final int athleteA;
  final int athleteB;
  final UserMinimal athleteADetail;
  final UserMinimal athleteBDetail;
  final DateTime date;
  final int? durationSeconds;
  final bool isFinished;
  final int scoreA;
  final int scoreB;
  final int? winner;
  final UserMinimal? winnerDetail;
  final List<MatchEvent> events;

  factory Match.fromJson(Map<String, dynamic> json) => Match(
        id: json['id'] as int,
        athleteA: json['athlete_a'] as int,
        athleteB: json['athlete_b'] as int,
        athleteADetail: UserMinimal.fromJson(json['athlete_a_detail'] as Map<String, dynamic>),
        athleteBDetail: UserMinimal.fromJson(json['athlete_b_detail'] as Map<String, dynamic>),
        date: DateTime.parse(json['date'] as String),
        durationSeconds: json['duration_seconds'] as int?,
        isFinished: json['is_finished'] as bool,
        scoreA: json['score_a'] as int,
        scoreB: json['score_b'] as int,
        winner: json['winner'] as int?,
        winnerDetail: json['winner_detail'] != null
            ? UserMinimal.fromJson(json['winner_detail'] as Map<String, dynamic>)
            : null,
        events: (json['events'] as List<dynamic>)
            .map((e) => MatchEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Match && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
