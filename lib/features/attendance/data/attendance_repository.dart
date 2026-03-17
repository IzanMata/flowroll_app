import 'package:dio/dio.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/api/api_exception.dart';
import '../../../shared/models/attendance.dart';
import '../../../shared/models/paginated_response.dart';

class AttendanceRepository {
  AttendanceRepository({required this.dio});

  final Dio dio;

  Future<PaginatedResponse<TrainingClass>> listClasses({
    required int academyId,
    int page = 1,
    String? search,
    ClassTypeEnum? classType,
    DateTime? scheduledAfter,
    DateTime? scheduledBefore,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.classesPath,
        queryParameters: {
          ApiConstants.academyParam: academyId,
          ApiConstants.pageParam: page,
          if (search != null && search.isNotEmpty) ApiConstants.searchParam: search,
          if (classType != null) 'class_type': classType.value,
          if (scheduledAfter != null) 'scheduled_after': scheduledAfter.toIso8601String(),
          if (scheduledBefore != null) 'scheduled_before': scheduledBefore.toIso8601String(),
        },
      );
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        TrainingClass.fromJson,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<TrainingClass> getClass(int id) async {
    try {
      final response = await dio.get('${ApiConstants.classesPath}$id/');
      return TrainingClass.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<TrainingClass> createClass({
    required int academyId,
    required String title,
    required DateTime scheduledAt,
    ClassTypeEnum? classType,
    int? professorId,
    int? durationMinutes,
    int? maxCapacity,
    String? notes,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.classesPath,
        data: {
          'academy': academyId,
          'title': title,
          'scheduled_at': scheduledAt.toIso8601String(),
          if (classType != null) 'class_type': classType.value,
          if (professorId != null) 'professor': professorId,
          if (durationMinutes != null) 'duration_minutes': durationMinutes,
          if (maxCapacity != null) 'max_capacity': maxCapacity,
          if (notes != null) 'notes': notes,
        },
      );
      return TrainingClass.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<QRCode> generateQr(int classId) async {
    try {
      final response = await dio.post('${ApiConstants.classesPath}$classId/generate_qr/');
      return QRCode.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<CheckIn> manualCheckIn({required int athleteId, required int trainingClassId}) async {
    try {
      final response = await dio.post(
        ApiConstants.manualCheckinPath,
        data: {'athlete_id': athleteId, 'training_class_id': trainingClassId},
      );
      return CheckIn.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<CheckIn> qrCheckIn({required String token}) async {
    try {
      final response = await dio.post(
        ApiConstants.qrCheckinPath,
        data: {'token': token},
      );
      return CheckIn.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<PaginatedResponse<DropInVisitor>> listDropIns({
    required int academyId,
    int page = 1,
    String? search,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.dropInsPath,
        queryParameters: {
          ApiConstants.academyParam: academyId,
          ApiConstants.pageParam: page,
          if (search != null && search.isNotEmpty) ApiConstants.searchParam: search,
        },
      );
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        DropInVisitor.fromJson,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<DropInVisitor> createDropIn({
    required int academyId,
    required String firstName,
    required String lastName,
    required String email,
    required DateTime expiresAt,
    String? phone,
    int? trainingClassId,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.dropInsPath,
        data: {
          'academy': academyId,
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'expires_at': expiresAt.toIso8601String(),
          if (phone != null) 'phone': phone,
          if (trainingClassId != null) 'training_class': trainingClassId,
        },
      );
      return DropInVisitor.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
