import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _accessKey = 'fr_access_token';
  static const _refreshKey = 'fr_refresh_token';

  // Used on Android / iOS only
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Web: in-memory only — avoids storing JWT in localStorage (XSS risk).
  // Tokens are lost on page refresh; the app redirects to /login as expected.
  final Map<String, String> _webMemory = {};

  Future<String?> getAccessToken() => _read(_accessKey);
  Future<String?> getRefreshToken() => _read(_refreshKey);

  Future<void> saveTokens({required String access, required String refresh}) async {
    await Future.wait([
      _write(_accessKey, access),
      _write(_refreshKey, refresh),
    ]);
  }

  Future<void> saveAccessToken(String access) => _write(_accessKey, access);

  Future<void> clearAll() async {
    await Future.wait([
      _delete(_accessKey),
      _delete(_refreshKey),
    ]);
  }

  Future<bool> hasTokens() async {
    final access = await getAccessToken();
    return access != null && access.isNotEmpty;
  }

  // ── Platform-aware helpers ──────────────────────────────────────────────

  Future<String?> _read(String key) async {
    if (kIsWeb) return _webMemory[key];
    return _secureStorage.read(key: key);
  }

  Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      _webMemory[key] = value;
      return;
    }
    await _secureStorage.write(key: key, value: value);
  }

  Future<void> _delete(String key) async {
    if (kIsWeb) {
      _webMemory.remove(key);
      return;
    }
    await _secureStorage.delete(key: key);
  }
}
