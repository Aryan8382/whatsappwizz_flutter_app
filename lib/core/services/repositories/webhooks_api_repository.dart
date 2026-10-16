import '../../services/api_service.dart';

abstract class WebhooksApiRepositoryBase {
  Future<List<Map<String, dynamic>>> getWebhooks();
  Future<Map<String, dynamic>> createWebhook(Map<String, dynamic> data);
  Future<Map<String, dynamic>> updateWebhook(dynamic id, Map<String, dynamic> data);
  Future<void> deleteWebhook(dynamic id);
  Future<void> testWebhook(dynamic id);
  Future<List<Map<String, dynamic>>> getWebhookLogs(dynamic id);
}

class WebhooksApiRepository implements WebhooksApiRepositoryBase {
  final ApiService _api;
  WebhooksApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<List<Map<String, dynamic>>> getWebhooks() async {
    final res = await _api.get<dynamic>('/webhooks');
    final list = res is List ? res : (res as Map?)?['items'] ?? [];
    return list.map((j) => Map<String, dynamic>.from(j as Map)).toList();
  }

  @override
  Future<Map<String, dynamic>> createWebhook(Map<String, dynamic> data) async {
    final res = await _api.post<dynamic>('/webhooks', data);
    return Map<String, dynamic>.from(res as Map);
  }

  @override
  Future<Map<String, dynamic>> updateWebhook(dynamic id, Map<String, dynamic> data) async {
    final res = await _api.put<dynamic>('/webhooks/$id', data);
    return Map<String, dynamic>.from(res as Map);
  }

  @override
  Future<void> deleteWebhook(dynamic id) async {
    await _api.delete('/webhooks/$id');
  }

  @override
  Future<void> testWebhook(dynamic id) async {
    await _api.post('/webhooks/$id/test');
  }

  @override
  Future<List<Map<String, dynamic>>> getWebhookLogs(dynamic id) async {
    final res = await _api.get<dynamic>('/webhooks/$id/logs');
    final list = res is List ? res : [];
    return list.map((j) => Map<String, dynamic>.from(j as Map)).toList();
  }
}
