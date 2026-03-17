import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/auth_repository.dart';
import '../api/providers.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.watch(dioProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  return ref.watch(authRepositoryProvider).isAuthenticated();
});

// Selected academy — persisted in shared_preferences
final selectedAcademyIdProvider = StateNotifierProvider<SelectedAcademyNotifier, int?>((ref) {
  return SelectedAcademyNotifier();
});

class SelectedAcademyNotifier extends StateNotifier<int?> {
  SelectedAcademyNotifier() : super(null) {
    _load();
  }

  static const _key = 'selected_academy_id';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_key);
    state = id;
  }

  Future<void> select(int academyId) async {
    state = academyId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, academyId);
  }

  Future<void> clear() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
