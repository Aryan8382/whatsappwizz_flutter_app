import '../../../core/services/api_service.dart';
import '../domain/auth_repository.dart';
import '../domain/user.dart';

/// Real auth repository — calls NestJS /api/v1/auth/* endpoints.
/// Mirrors web frontend login() + setSession() from lib/api.ts exactly.
class ApiAuthRepository implements AuthRepository {
  final ApiService _api;

  ApiAuthRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<User> login(String email, String password) async {
    try {
      // POST /api/v1/auth/login
      final res = await _api.post<dynamic>('/auth/login', {
        'email': email.trim().toLowerCase(),
        'password': password,
      });

      // Backend returns: { accessToken, refreshToken, user: { sub, email, organizationId, role, ... } }
      final Map<String, dynamic> body = res is Map<String, dynamic>
          ? res
          : Map<String, dynamic>.from(res as Map);

      final accessToken = body['accessToken'] as String? ?? '';
      final refreshToken = body['refreshToken'] as String? ?? '';
      final userJson = body['user'] as Map<String, dynamic>? ?? {};

      // Save tokens + user to secure storage
      await _api.setSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: userJson,
      );

      return User.fromJson(userJson);
    } on ApiException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    // First try stored user from secure storage (fast path — offline friendly)
    final storedUser = await _api.getStoredUser();
    if (storedUser != null && storedUser.isNotEmpty) {
      // Also verify with server if we have a token
      try {
        final res = await _api.get<dynamic>('/auth/me');
        final body = res is Map<String, dynamic>
            ? res
            : Map<String, dynamic>.from(res as Map);
        return User.fromJson(body);
      } on ApiException catch (e) {
        if (e.statusCode == 401) {
          await _api.clearSession();
          return null;
        }
        return User.fromJson(storedUser);
      } catch (_) {
        return User.fromJson(storedUser);
      }
    }
    return null;
  }

  @override
  Future<void> logout() async {
    try {
      final refreshToken = await _api.getRefreshToken();
      if (refreshToken != null) {
        await _api.post('/auth/logout', {'refreshToken': refreshToken});
      }
    } catch (_) {
      // Always clear local session even if server call fails
    } finally {
      await _api.clearSession();
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _api.post('/auth/change-password', {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } on ApiException catch (e) {
      throw Exception(e.message);
    }
  }
}
