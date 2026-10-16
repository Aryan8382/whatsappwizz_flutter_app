import '../../services/api_service.dart';

abstract class OrganizationApiRepositoryBase {
  Future<List<Map<String, dynamic>>> getOrganizations();
  Future<Map<String, dynamic>> getOrganization(dynamic id);
  Future<Map<String, dynamic>> createOrganization(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateOrganization(dynamic id, Map<String, dynamic> data);
  Future<void> deleteOrganization(dynamic id);
}

class OrganizationApiRepository implements OrganizationApiRepositoryBase {
  final ApiService _api;
  OrganizationApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<List<Map<String, dynamic>>> getOrganizations() async {
    final res = await _api.get<dynamic>('/organizations');
    final list = res is List ? res : (res as Map?)?['items'] ?? [];
    return (list as List).map((j) => Map<String, dynamic>.from(j as Map)).toList();
  }

  @override
  Future<Map<String, dynamic>> getOrganization(dynamic id) async {
    final res = await _api.get<dynamic>('/organizations/$id');
    return Map<String, dynamic>.from(res as Map);
  }

  @override
  Future<Map<String, dynamic>> createOrganization(Map<String, dynamic> data) async {
    final res = await _api.post<dynamic>('/organizations', data);
    return Map<String, dynamic>.from(res as Map);
  }

  @override
  Future<Map<String, dynamic>> updateOrganization(dynamic id, Map<String, dynamic> data) async {
    final res = await _api.put<dynamic>('/organizations/$id', data);
    return Map<String, dynamic>.from(res as Map);
  }

  @override
  Future<void> deleteOrganization(dynamic id) async {
    await _api.delete('/organizations/$id');
  }
}
