import 'package:dio/dio.dart';

import '../auth/token_storage.dart';
import 'api_constants.dart';

class JwtInterceptor extends Interceptor {
  JwtInterceptor({required this.tokenStorage, required this.dio});

  final TokenStorage tokenStorage;
  final Dio dio;

  bool _isRefreshing = false;
  final List<(RequestOptions, ErrorInterceptorHandler)> _pendingQueue = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth endpoints
    if (_isAuthEndpoint(options.path)) {
      return handler.next(options);
    }

    final token = await tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401 || _isAuthEndpoint(err.requestOptions.path)) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      _pendingQueue.add((err.requestOptions, handler));
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        await _handleAuthFailure(err, handler);
        return;
      }

      final response = await dio.post<Map<String, dynamic>>(
        ApiConstants.tokenRefreshPath,
        data: {'refresh': refreshToken},
        options: Options(
          headers: {'Authorization': null},
          extra: {'skipInterceptor': true},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final data = response.data!;
      final newAccess = data['access'] as String;
      final newRefresh = data['refresh'] as String?;

      await tokenStorage.saveAccessToken(newAccess);
      if (newRefresh != null) {
        await tokenStorage.saveTokens(access: newAccess, refresh: newRefresh);
      }

      // Retry original request
      final retried = await _retry(err.requestOptions, newAccess);
      handler.resolve(retried);

      // Flush queue
      for (final (opts, pendingHandler) in _pendingQueue) {
        try {
          final r = await _retry(opts, newAccess);
          pendingHandler.resolve(r);
        } catch (e) {
          pendingHandler.next(err);
        }
      }
    } catch (_) {
      await _handleAuthFailure(err, handler);
      for (final (_, pendingHandler) in _pendingQueue) {
        pendingHandler.next(err);
      }
    } finally {
      _pendingQueue.clear();
      _isRefreshing = false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions opts, String token) {
    return dio.request<dynamic>(
      opts.path,
      data: opts.data,
      queryParameters: opts.queryParameters,
      options: Options(
        method: opts.method,
        headers: {...opts.headers, 'Authorization': 'Bearer $token'},
      ),
    );
  }

  Future<void> _handleAuthFailure(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    await tokenStorage.clearAll();
    handler.next(err);
  }

  bool _isAuthEndpoint(String path) =>
      path == ApiConstants.tokenPath ||
      path == ApiConstants.tokenRefreshPath;
}
