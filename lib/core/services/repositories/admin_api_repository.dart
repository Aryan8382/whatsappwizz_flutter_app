import '../api_service.dart';

class OrgModel {
  final String id;
  final String name;
  final String slug;
  final String plan;
  final int usersCount;

  const OrgModel({
    required this.id,
    required this.name,
    required this.slug,
    this.plan = 'STANDARD',
    this.usersCount = 1,
  });

  factory OrgModel.fromJson(Map<String, dynamic> json) {
    return OrgModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Organization',
      slug: json['slug']?.toString() ?? '',
      plan: json['plan']?.toString() ?? 'Active',
      usersCount: (json['_count'] is Map ? (json['_count']['users'] as num?)?.toInt() : null) ??
          (json['usersCount'] as num?)?.toInt() ??
          1,
    );
  }
}

class AuditLogModel {
  final String id;
  final String action;
  final String user;
  final DateTime createdAt;

  const AuditLogModel({
    required this.id,
    required this.action,
    required this.user,
    required this.createdAt,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    final userObj = json['user'] is Map ? json['user'] : null;
    final userEmail = userObj != null ? userObj['email']?.toString() : null;

    return AuditLogModel(
      id: json['id']?.toString() ?? '',
      action: json['action']?.toString() ?? 'SYSTEM_EVENT',
      user: userEmail ?? json['userEmail']?.toString() ?? 'system',
      createdAt: json['created_at'] != null || json['createdAt'] != null
          ? DateTime.tryParse((json['created_at'] ?? json['createdAt']).toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class AdminApiRepository {
  final ApiService _api;
  AdminApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  Future<List<OrgModel>> getOrganizations() async {
    try {
      final res = await _api.get<dynamic>('/organizations');
      final items = res is Map ? (res['items'] ?? []) : (res is List ? res : []);
      return (items as List).map((j) => OrgModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {
      // If user is not super_admin/reseller, return current org
      final currentUser = await _api.getStoredUser();
      final orgName = currentUser?['organization']?['name']?.toString() ?? 'My Organization';
      return [
        OrgModel(
          id: currentUser?['organizationId']?.toString() ?? '1',
          name: orgName,
          slug: orgName.toLowerCase().replaceAll(' ', '-'),
          plan: 'Standard',
          usersCount: 1,
        )
      ];
    }
  }

  Future<List<AuditLogModel>> getAuditLogs() async {
    try {
      final res = await _api.get<dynamic>('/audit');
      final items = res is Map ? (res['items'] ?? []) : (res is List ? res : []);
      return (items as List).map((j) => AuditLogModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
