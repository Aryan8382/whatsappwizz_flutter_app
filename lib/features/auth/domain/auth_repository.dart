import 'user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User?> getCurrentUser();
  Future<void> logout();
  Future<void> changePassword(String currentPassword, String newPassword);
}
