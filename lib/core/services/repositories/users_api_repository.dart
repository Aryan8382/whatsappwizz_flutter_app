import '../../services/api_service.dart';
import '../../../features/auth/domain/user.dart';

abstract class UsersApiRepositoryBase {
  Future<List<User>> getUsers();
  Future<List<Map<String, dynamic>>> getRoles();
  Future<User> createUser(Map<String, dynamic> data);
  Future<User> updateUser(dynamic id, Map<String, dynamic> data);
  Future<void> deleteUser(dynamic id);
}

class UsersApiRepository implements UsersApiRepositoryBase {
  final ApiService _api;
  UsersApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<List<User>> getUsers() async {
    final res = await _api.get<dynamic>('/users');
    final list = res is List ? res : (res as Map?)?['items'] ?? [];
    return list.map((j) => User.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getRoles() async {
    final res = await _api.get<dynamic>('/users/roles');
    final list = res is List ? res : [];
    return list.map((j) => Map<String, dynamic>.from(j as Map)).toList();
  }

  @override
  Future<User> createUser(Map<String, dynamic> data) async {
    final res = await _api.post<dynamic>('/users', data);
    return User.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<User> updateUser(dynamic id, Map<String, dynamic> data) async {
    final res = await _api.put<dynamic>('/users/$id', data);
    return User.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<void> deleteUser(dynamic id) async {
    await _api.delete('/users/$id');
  }
}
