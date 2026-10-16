import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api_auth_repository.dart';
import '../domain/auth_repository.dart';
import '../domain/user.dart';
import '../../../core/services/realtime_service.dart';
import '../../../core/services/api_service.dart';

// Switch here to MockAuthRepository for offline demo mode
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository();
});class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AuthState()) {
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final current = await _repo.getCurrentUser();
      if (current != null) {
        state = state.copyWith(user: current, isLoading: false);
        // Reconnect Socket.IO on app restart if already logged in
        final token = await ApiService.instance.getToken();
        if (token != null) {
          RealtimeService.instance.connect(
            token: token,
            organizationId: current.organizationId.toString(),
          );
        }
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repo.login(email, password);
      state = state.copyWith(user: user, isLoading: false);
      // Connect Socket.IO for real-time inbox updates
      final token = await ApiService.instance.getToken();
      if (token != null) {
        RealtimeService.instance.connect(
          token: token,
          organizationId: user.organizationId.toString(),
        );
      }
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
        clearUser: true,
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    RealtimeService.instance.disconnect(); // Clean up socket
    await _repo.logout();
    state = const AuthState(user: null);
  }

  void switchRoleForDemo(UserRole role) {
    if (state.user == null) return;
    state = state.copyWith(user: state.user!.copyWith(role: role));
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
