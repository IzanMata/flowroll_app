import 'package:dio/dio.dart';

sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  factory ApiException.fromDio(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const NetworkException('Connection timed out'),
      DioExceptionType.connectionError =>
        const NetworkException('No internet connection'),
      DioExceptionType.badResponse => switch (e.response?.statusCode) {
          400 => BadRequestException(_extractMessage(e.response)),
          401 => const UnauthorizedException(),
          403 => const ForbiddenException(),
          404 => const NotFoundException(),
          422 => ValidationException(_extractErrors(e.response)),
          429 => const RateLimitException(),
          500 => const ServerException(),
          _ => ServerException(_extractMessage(e.response)),
        },
      _ => ServerException(e.message ?? 'Unexpected error'),
    };
  }

  static String _extractMessage(Response? response) {
    if (response?.data is Map) {
      final data = response!.data as Map<String, dynamic>;
      return data['detail']?.toString() ??
          data['message']?.toString() ??
          'Request failed (${response.statusCode})';
    }
    return 'Request failed (${response?.statusCode})';
  }

  static Map<String, List<String>> _extractErrors(Response? response) {
    if (response?.data is Map) {
      final data = response!.data as Map<String, dynamic>;
      return data.map((k, v) => MapEntry(
            k,
            v is List ? v.map((e) => e.toString()).toList() : [v.toString()],
          ));
    }
    return {};
  }
}

class NetworkException extends ApiException {
  const NetworkException([super.message = 'No internet connection']);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException() : super('Session expired. Please log in again.');
}

class ForbiddenException extends ApiException {
  const ForbiddenException() : super('You do not have permission.');
}

class NotFoundException extends ApiException {
  const NotFoundException() : super('Resource not found.');
}

class BadRequestException extends ApiException {
  const BadRequestException([super.message = 'Invalid request.']);
}

class ValidationException extends ApiException {
  const ValidationException(this.errors) : super('Validation failed.');
  final Map<String, List<String>> errors;
}

class RateLimitException extends ApiException {
  const RateLimitException() : super('Too many requests. Please wait.');
}

class ServerException extends ApiException {
  const ServerException([super.message = 'Server error. Please try again.']);
}
