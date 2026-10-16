import '../../services/api_service.dart';

abstract class ApiKeysApiRepositoryBase {
  Future<List<Map<String, dynamic>>> getApiKeys();
  Future<Map<String, dynamic>> createApiKey();
  Future<void> deleteApiKey(dynamic id);
}

class ApiKeysApiRepository implements ApiKeysApiRepositoryBase {
  final ApiService _api;
  ApiKeysApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<List<Map<String, dynamic>>> getApiKeys() async {
    final res = await _api.get<dynamic>('/apikeys');
    final list = res is List ? res : (res as Map?)?['items'] ?? [];
    return (list as List).map((j) => Map<String, dynamic>.from(j as Map)).toList();
  }

  @override
  Future<Map<String, dynamic>> createApiKey() async {
    final res = await _api.post<dynamic>('/apikeys');
    return Map<String, dynamic>.from(res as Map);
  }

  @override
  Future<void> deleteApiKey(dynamic id) async {
    await _api.delete('/apikeys/$id');
  }
}
