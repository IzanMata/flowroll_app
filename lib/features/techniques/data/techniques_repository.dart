import 'package:dio/dio.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/api/api_exception.dart';
import '../../../shared/models/technique.dart';
import '../../../shared/models/paginated_response.dart';

class TechniquesRepository {
  TechniquesRepository({required this.dio});

  final Dio dio;

  Future<PaginatedResponse<Belt>> listBelts({int page = 1}) async {
    try {
      final response = await dio.get(
        ApiConstants.beltsPath,
        queryParameters: {ApiConstants.pageParam: page},
      );
      return PaginatedResponse.fromJson(response.data as Map<String, dynamic>, Belt.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<PaginatedResponse<TechniqueCategory>> listCategories({
    int page = 1,
    String? search,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.techniqueCategoriesPath,
        queryParameters: {
          ApiConstants.pageParam: page,
          if (search != null && search.isNotEmpty) ApiConstants.searchParam: search,
        },
      );
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        TechniqueCategory.fromJson,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<PaginatedResponse<Technique>> listTechniques({
    int page = 1,
    String? search,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.techniquesPath,
        queryParameters: {
          ApiConstants.pageParam: page,
          if (search != null && search.isNotEmpty) ApiConstants.searchParam: search,
        },
      );
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        Technique.fromJson,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Technique> getTechnique(int id) async {
    try {
      final response = await dio.get('${ApiConstants.techniquesPath}$id/');
      return Technique.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Technique> createTechnique({
    required String name,
    String? description,
    int? difficulty,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.techniquesPath,
        data: {
          'name': name,
          if (description != null) 'description': description,
          if (difficulty != null) 'difficulty': difficulty,
        },
      );
      return Technique.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Technique> updateTechnique(
    int id, {
    String? name,
    String? description,
    int? difficulty,
  }) async {
    try {
      final response = await dio.patch(
        '${ApiConstants.techniquesPath}$id/',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (difficulty != null) 'difficulty': difficulty,
        },
      );
      return Technique.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> deleteTechnique(int id) async {
    try {
      await dio.delete('${ApiConstants.techniquesPath}$id/');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<TechniqueVariation> createVariation({
    required String name,
    String? description,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.variationsPath,
        data: {
          'name': name,
          if (description != null) 'description': description,
        },
      );
      return TechniqueVariation.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
