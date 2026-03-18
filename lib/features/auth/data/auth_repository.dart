import 'package:dio/dio.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/auth/token_storage.dart';
import '../../../shared/models/auth.dart';

class AuthRepository {
  AuthRepository({required this.dio, required this.tokenStorage});

  final Dio dio;
  final TokenStorage tokenStorage;

  Future<TokenPair> login({required String username, required String password}) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        ApiConstants.tokenPath,
        data: {'username': username, 'password': password},
      );
      final pair = TokenPair.fromJson(response.data as Map<String, dynamic>);
      await tokenStorage.saveTokens(access: pair.access, refresh: pair.refresh);
      return pair;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> logout() async {
    await tokenStorage.clearAll();
  }

  Future<bool> isAuthenticated() => tokenStorage.hasTokens();
}
