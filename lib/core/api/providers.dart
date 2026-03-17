import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/token_storage.dart';
import 'dio_client.dart';

final tokenStorageProvider = Provider<TokenStorage>((_) => TokenStorage());

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(tokenStorage: ref.watch(tokenStorageProvider));
});

final dioProvider = Provider<Dio>((ref) {
  return ref.watch(dioClientProvider).dio;
});
