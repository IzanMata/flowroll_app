import 'package:dio/dio.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/api/api_exception.dart';
import '../../../shared/models/academy.dart';
import '../../../shared/models/paginated_response.dart';

class AcademiesRepository {
  AcademiesRepository({required this.dio});

  final Dio dio;

  Future<PaginatedResponse<Academy>> listAcademies({int page = 1, String? search}) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        ApiConstants.academiesPath,
        queryParameters: {
          ApiConstants.pageParam: page,
          if (search != null && search.isNotEmpty) ApiConstants.searchParam: search,
        },
      );
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        Academy.fromJson,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Academy> getAcademy(int id) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('${ApiConstants.academiesPath}$id/');
      return Academy.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Academy> createAcademy({required String name, String? city}) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        ApiConstants.academiesPath,
        data: {'name': name, if (city != null) 'city': city},
      );
      return Academy.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Academy> updateAcademy(int id, {required String name, String? city}) async {
    try {
      final response = await dio.patch<Map<String, dynamic>>(
        '${ApiConstants.academiesPath}$id/',
        data: {'name': name, if (city != null) 'city': city},
      );
      return Academy.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> deleteAcademy(int id) async {
    try {
      await dio.delete<void>('${ApiConstants.academiesPath}$id/');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
