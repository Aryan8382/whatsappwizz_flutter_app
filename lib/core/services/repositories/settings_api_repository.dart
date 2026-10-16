import '../api_service.dart';

class ApiKeyModel {
  final String id;
  final String organizationId;
  final String apiKey;
  final String secret;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String label;

  ApiKeyModel({
    required this.id,
    required this.organizationId,
    required this.apiKey,
    required this.secret,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    this.label = 'API Key',
  });

  factory ApiKeyModel.fromJson(Map<String, dynamic> json) {
    return ApiKeyModel(
      id: json['id']?.toString() ?? '',
      organizationId: json['organizationId']?.toString() ?? json['organization_id']?.toString() ?? '1',
      apiKey: json['apiKey']?.toString() ?? json['api_key']?.toString() ?? '',
      secret: json['secret']?.toString() ?? '',
      active: json['active'] == true || json['active'] == 1,
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.tryParse((json['createdAt'] ?? json['created_at']).toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? DateTime.tryParse((json['updatedAt'] ?? json['updated_at']).toString()) ?? DateTime.now()
          : DateTime.now(),
      label: json['label']?.toString() ?? 'Live API Key',
    );
  }
}

class WebhookModel {
  final String id;
  final String organizationId;
  final String url;
  final List<String> events;
  final String secret;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  WebhookModel({
    required this.id,
    required this.organizationId,
    required this.url,
    required this.events,
    required this.secret,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WebhookModel.fromJson(Map<String, dynamic> json) {
    var rawEvents = json['events'];
    List<String> eventList = [];
    if (rawEvents is List) {
      eventList = rawEvents.map((e) => e.toString()).toList();
    } else if (rawEvents is String) {
      eventList = [rawEvents];
    }

    return WebhookModel(
      id: json['id']?.toString() ?? '',
      organizationId: json['organizationId']?.toString() ?? json['organization_id']?.toString() ?? '1',
      url: json['url']?.toString() ?? '',
      events: eventList,
      secret: json['secret']?.toString() ?? '',
      active: json['active'] == true || json['active'] == 1,
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.tryParse((json['createdAt'] ?? json['created_at']).toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? DateTime.tryParse((json['updatedAt'] ?? json['updated_at']).toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class SettingsApiRepository {
  final ApiService _api;
  SettingsApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  Future<Map<String, dynamic>?> getOrgProfile() async {
    final user = await _api.getStoredUser();
    if (user != null && user['organization'] is Map) {
      return Map<String, dynamic>.from(user['organization'] as Map);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getWabaAccounts() async {
    try {
      final res = await _api.get<dynamic>('/waba/status');
      final list = res is List ? res : (res as Map?)?['items'] ?? [];
      return (list as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getNumbers() async {
    try {
      final res = await _api.get<dynamic>('/waba/numbers');
      final list = res is List ? res : (res as Map?)?['items'] ?? [];
      return (list as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<ApiKeyModel>> getApiKeys() async {
    try {
      final res = await _api.get<dynamic>('/apikeys');
      final list = res is List ? res : (res as Map?)?['items'] ?? [];
      return (list as List).map((j) => ApiKeyModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<ApiKeyModel> generateApiKey() async {
    final res = await _api.post<dynamic>('/apikeys', {});
    return ApiKeyModel.fromJson(res as Map<String, dynamic>);
  }

  Future<void> revokeApiKey(dynamic id) async {
    await _api.delete('/apikeys/$id');
  }

  Future<List<WebhookModel>> getWebhooks() async {
    try {
      final res = await _api.get<dynamic>('/webhooks');
      final list = res is List ? res : (res as Map?)?['items'] ?? [];
      return (list as List).map((j) => WebhookModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> testWebhook(dynamic id) async {
    await _api.post('/webhooks/$id/test', {});
  }

  Future<void> deleteWebhook(dynamic id) async {
    await _api.delete('/webhooks/$id');
  }
}
