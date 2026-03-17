import 'package:dio/dio.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/api/api_exception.dart';
import '../../../shared/models/tatami.dart';
import '../../../shared/models/paginated_response.dart';

class TatamiRepository {
  TatamiRepository({required this.dio});

  final Dio dio;

  // Matchups
  Future<PaginatedResponse<Matchup>> listMatchups({
    required int academyId,
    int page = 1,
    MatchupStatusEnum? status,
    MatchFormatEnum? matchFormat,
    int? weightClass,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.matchupsPath,
        queryParameters: {
          ApiConstants.academyParam: academyId,
          ApiConstants.pageParam: page,
          if (status != null) 'status': status.value,
          if (matchFormat != null) 'match_format': matchFormat.value,
          if (weightClass != null) 'weight_class': weightClass,
        },
      );
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        Matchup.fromJson,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<PaginatedResponse<Matchup>> pairAthletes({
    required List<int> athleteIds,
    required MatchFormatEnum matchFormat,
    required int academyId,
    int? weightClassId,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.pairAthletesPath,
        queryParameters: {ApiConstants.academyParam: academyId},
        data: {
          'athlete_ids': athleteIds,
          'match_format': matchFormat.value,
          'academy_id': academyId,
          if (weightClassId != null) 'weight_class_id': weightClassId,
        },
      );
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        Matchup.fromJson,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // Timer presets
  Future<PaginatedResponse<TimerPreset>> listTimerPresets({
    required int academyId,
    int page = 1,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.timerPresetsPath,
        queryParameters: {
          ApiConstants.academyParam: academyId,
          ApiConstants.pageParam: page,
        },
      );
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        TimerPreset.fromJson,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<TimerSession> startSession({required int presetId, required int academyId}) async {
    try {
      final response = await dio.post(
        '${ApiConstants.timerPresetsPath}$presetId/start_session/',
        queryParameters: {ApiConstants.academyParam: academyId},
        data: {'preset': presetId},
      );
      return TimerSession.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // Timer sessions
  Future<TimerSession> pauseSession({required int sessionId, required int academyId}) async {
    try {
      final response = await dio.post(
        '${ApiConstants.timerSessionsPath}$sessionId/pause/',
        queryParameters: {ApiConstants.academyParam: academyId},
        data: {'preset': 0},
      );
      return TimerSession.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<TimerSession> finishSession({required int sessionId, required int academyId}) async {
    try {
      final response = await dio.post(
        '${ApiConstants.timerSessionsPath}$sessionId/finish/',
        queryParameters: {ApiConstants.academyParam: academyId},
        data: {'preset': 0},
      );
      return TimerSession.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // Weight classes
  Future<PaginatedResponse<WeightClass>> listWeightClasses({int page = 1}) async {
    try {
      final response = await dio.get(
        ApiConstants.weightClassesPath,
        queryParameters: {ApiConstants.pageParam: page},
      );
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        WeightClass.fromJson,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
