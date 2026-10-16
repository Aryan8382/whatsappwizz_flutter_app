import 'dart:convert';

/// Matches `segments` table in `whatsapp_wiz (2).sql`
///
/// CREATE TABLE `segments` (
///   `id` bigint(20) NOT NULL,
///   `organization_id` bigint(20) NOT NULL,
///   `name` varchar(150) NOT NULL,
///   `filters` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`filters`)),
///   `contact_count` int(11) NOT NULL DEFAULT 0,
///   `created_by` bigint(20) DEFAULT NULL,
///   `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
///   `updated_at` datetime(3) NOT NULL
/// )
class Segment {
  final dynamic id;
  final dynamic organizationId;
  final String name;
  final dynamic filters;
  final int contactCount;
  final dynamic createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // UI helpers
  final String? description;
  final String tagFilter;
  final bool optInOnly;

  const Segment({
    required this.id,
    this.organizationId = '2',
    required this.name,
    this.filters,
    int? contactCount,
    int? estimatedCount,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.description,
    this.tagFilter = '',
    this.optInOnly = true,
  }) : contactCount = contactCount ?? estimatedCount ?? 0;

  int get estimatedCount => contactCount;

  factory Segment.fromJson(Map<String, dynamic> json) {
    dynamic parsedFilters = json['filters'];
    if (parsedFilters is String && parsedFilters.isNotEmpty) {
      try {
        parsedFilters = jsonDecode(parsedFilters);
      } catch (_) {}
    }

    return Segment(
      id: json['id'] ?? '',
      organizationId: json['organization_id'] ?? json['organizationId'] ?? '2',
      name: json['name'] ?? '',
      filters: parsedFilters,
      contactCount: json['contact_count'] ?? json['contactCount'] ?? json['estimated_count'] ?? 0,
      createdBy: json['created_by'] ?? json['createdBy'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
      description: json['description'],
      tagFilter: json['tag_filter'] ?? json['tagFilter'] ?? '',
      optInOnly: json['opt_in_only'] ?? json['optInOnly'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'name': name,
      'filters': filters is String ? filters : jsonEncode(filters),
      'contact_count': contactCount,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'description': description,
    };
  }
}
