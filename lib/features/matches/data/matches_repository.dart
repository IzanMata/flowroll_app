import 'package:dio/dio.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/api/api_exception.dart';
import '../../../shared/models/match.dart';
import '../../../shared/models/paginated_response.dart';

class MatchesRepository {
  MatchesRepository({required this.dio});

  final Dio dio;

  Future<PaginatedResponse<Match>> listMatches({
    required int academyId,
    int page = 1,
    String? search,
  }) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        ApiConstants.matchesPath,
        queryParameters: {
          ApiConstants.academyParam: academyId,
          ApiConstants.pageParam: page,
          if (search != null && search.isNotEmpty) ApiConstants.searchParam: search,
        },
      );
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        Match.fromJson,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Match> getMatch(int id, {required int academyId}) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '${ApiConstants.matchesPath}$id/',
        queryParameters: {ApiConstants.academyParam: academyId},
      );
      return Match.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Match> createMatch({
    required int athleteA,
    required int athleteB,
    required int academyId,
    int? durationSeconds,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        ApiConstants.matchesPath,
        queryParameters: {ApiConstants.academyParam: academyId},
        data: {
          'athlete_a': athleteA,
          'athlete_b': athleteB,
          if (durationSeconds != null) 'duration_seconds': durationSeconds,
        },
      );
      return Match.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Match> addEvent({
    required int matchId,
    required int athleteId,
    required int timestamp,
    required String actionDescription,
    required EventTypeEnum eventType,
    int? pointsAwarded,
    required int academyId,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '${ApiConstants.matchesPath}$matchId/add_event/',
        queryParameters: {ApiConstants.academyParam: academyId},
        data: {
          'athlete': athleteId,
          'timestamp': timestamp,
          'action_description': actionDescription,
          'event_type': eventType.value,
          if (pointsAwarded != null) 'points_awarded': pointsAwarded,
        },
      );
      return Match.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Match> finishMatch({
    required int matchId,
    required int athleteA,
    required int athleteB,
    int? winnerId,
    int? durationSeconds,
    required int academyId,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '${ApiConstants.matchesPath}$matchId/finish_match/',
        queryParameters: {ApiConstants.academyParam: academyId},
        data: {
          'athlete_a': athleteA,
          'athlete_b': athleteB,
          if (winnerId != null) 'winner_id': winnerId,
          if (durationSeconds != null) 'duration_seconds': durationSeconds,
        },
      );
      return Match.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> deleteMatch(int id, {required int academyId}) async {
    try {
      await dio.delete<void>(
        '${ApiConstants.matchesPath}$id/',
        queryParameters: {ApiConstants.academyParam: academyId},
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
