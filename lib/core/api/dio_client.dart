import 'package:dio/dio.dart';
import 'api_constants.dart';
import 'jwt_interceptor.dart';
import '../auth/token_storage.dart';

class DioClient {
  DioClient({required TokenStorage tokenStorage}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      JwtInterceptor(tokenStorage: tokenStorage, dio: _dio),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print(obj.toString()),
      ),
    ]);
  }

  late final Dio _dio;
  Dio get dio => _dio;
}
