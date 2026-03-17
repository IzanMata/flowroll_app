import 'package:dio/dio.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/api/api_exception.dart';
import '../../../shared/models/athlete.dart';
import '../../../shared/models/paginated_response.dart';

class AthletesRepository {
  AthletesRepository({required this.dio});

  final Dio dio;

  Future<PaginatedResponse<AthleteProfile>> listAthletes({
    required int academyId,
    int page = 1,
    String? search,
    String? ordering,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.athletesPath,
        queryParameters: {
          'academy_id': academyId,
          ApiConstants.pageParam: page,
          if (search != null && search.isNotEmpty) ApiConstants.searchParam: search,
          if (ordering != null) ApiConstants.orderingParam: ordering,
        },
      );
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        AthleteProfile.fromJson,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<AthleteProfile> getAthlete(int id) async {
    try {
      final response = await dio.get('${ApiConstants.athletesPath}$id/');
      return AthleteProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<AthleteProfile> createAthlete({
    required int userId,
    int? academyId,
    RoleEnum? role,
    BeltEnum? belt,
    int? stripes,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.athletesPath,
        data: {
          'user': userId,
          if (academyId != null) 'academy': academyId,
          if (role != null) 'role': role.value,
          if (belt != null) 'belt': belt.value,
          if (stripes != null) 'stripes': stripes,
        },
      );
      return AthleteProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<AthleteProfile> updateAthlete(
    int id, {
    int? academyId,
    RoleEnum? role,
    BeltEnum? belt,
    int? stripes,
  }) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.athletesPath}$id/',
        data: {
          if (academyId != null) 'academy': academyId,
          if (role != null) 'role': role.value,
          if (belt != null) 'belt': belt.value,
          if (stripes != null) 'stripes': stripes,
        },
      );
      return AthleteProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> deleteAthlete(int id) async {
    try {
      await dio.delete('${ApiConstants.athletesPath}$id/');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
