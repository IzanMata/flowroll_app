import 'package:dio/dio.dart';
import 'api_exception.dart';

/// Wraps a repository call and converts [DioException] → [ApiException].
/// Eliminates the repeated try/catch boilerplate in every repository method.
Future<T> guard<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    throw ApiException.fromDio(e);
  }
}
