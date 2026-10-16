import 'dart:convert';

/// Matches `whatsapp_flows` table in `whatsapp_wiz (2).sql`
///
/// CREATE TABLE `whatsapp_flows` (
///   `id` bigint(20) NOT NULL,
///   `organization_id` bigint(20) NOT NULL,
///   `flow_ref` varchar(60) NOT NULL,
///   `name` varchar(150) NOT NULL,
///   `category` varchar(50) NOT NULL DEFAULT 'OTHER',
///   `status` varchar(20) NOT NULL DEFAULT 'draft',
///   `health_status` varchar(20) NOT NULL DEFAULT 'healthy',
///   `screens` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`screens`)),
///   `created_by` bigint(20) DEFAULT NULL,
///   `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
///   `updated_at` datetime(3) NOT NULL
/// )
class WhatsappFlow {
  final dynamic id;
  final dynamic organizationId;
  final String flowRef;
  final String name;
  final String category;
  final String status;
  final String healthStatus;
  final dynamic screens;
  final dynamic createdBy;
  final DateTime? createdAt;
  final DateTime updatedAt;

  // UI helper fields
  final int screensCount;
  final List<String> categories;

  const WhatsappFlow({
    required this.id,
    this.organizationId = '2',
    this.flowRef = '',
    required this.name,
    this.category = 'OTHER',
    required this.status,
    this.healthStatus = 'healthy',
    this.screens,
    this.createdBy,
    this.createdAt,
    required this.updatedAt,
    this.screensCount = 1,
    this.categories = const ['OTHER'],
  });

  factory WhatsappFlow.fromJson(Map<String, dynamic> json) {
    dynamic parsedScreens = json['screens'];
    if (parsedScreens is String && parsedScreens.isNotEmpty) {
      try {
        parsedScreens = jsonDecode(parsedScreens);
      } catch (_) {}
    }

    final uAt = json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
        : DateTime.now();
    final cAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null;

    final cat = json['category']?.toString() ?? 'OTHER';

    return WhatsappFlow(
      id: json['id'] ?? '',
      organizationId: json['organization_id'] ?? json['organizationId'] ?? '2',
      flowRef: json['flow_ref'] ?? json['flowRef'] ?? 'FLOW-${json['id']}',
      name: json['name'] ?? '',
      category: cat,
      status: json['status'] ?? 'DRAFT',
      healthStatus: json['health_status'] ?? json['healthStatus'] ?? 'healthy',
      screens: parsedScreens,
      createdBy: json['created_by'] ?? json['createdBy'],
      createdAt: cAt,
      updatedAt: uAt,
      screensCount: json['screensCount'] ?? (parsedScreens is List ? parsedScreens.length : 1),
      categories: [cat],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'flow_ref': flowRef,
      'name': name,
      'category': category,
      'status': status,
      'health_status': healthStatus,
      'screens': screens is String ? screens : (screens != null ? jsonEncode(screens) : null),
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
