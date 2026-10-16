import 'dart:convert';

/// Matches `custom_fields` table in `whatsapp_wiz (2).sql`
///
/// CREATE TABLE `custom_fields` (
///   `id` bigint(20) NOT NULL,
///   `organization_id` bigint(20) NOT NULL,
///   `name` varchar(150) NOT NULL,
///   `field_type` varchar(30) NOT NULL,
///   `default_value` varchar(255) DEFAULT NULL,
///   `options` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`options`)),
///   `show_in_listing` tinyint(1) NOT NULL DEFAULT 1,
///   `status` tinyint(1) NOT NULL DEFAULT 1,
///   `mandatory` tinyint(1) NOT NULL DEFAULT 0,
///   `created_by` bigint(20) DEFAULT NULL,
///   `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
///   `updated_at` datetime(3) NOT NULL
/// )
class CustomField {
  final dynamic id;
  final dynamic organizationId;
  final String name;
  final String fieldType;
  final String? defaultValue;
  final dynamic options;
  final bool showInListing;
  final bool status;
  final bool mandatory;
  final dynamic createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CustomField({
    required this.id,
    this.organizationId = '2',
    required this.name,
    this.fieldType = 'text',
    String? type,
    String? key,
    this.defaultValue,
    this.options,
    this.showInListing = true,
    this.status = true,
    this.mandatory = false,
    bool? isRequired,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  // Backward compatibility UI getters
  String get key => name.toLowerCase().replaceAll(' ', '_');
  String get type => fieldType.toUpperCase();
  bool get isRequired => mandatory;

  factory CustomField.fromJson(Map<String, dynamic> json) {
    dynamic parsedOptions = json['options'];
    if (parsedOptions is String && parsedOptions.isNotEmpty) {
      try {
        parsedOptions = jsonDecode(parsedOptions);
      } catch (_) {}
    }

    return CustomField(
      id: json['id'] ?? '',
      organizationId: json['organization_id'] ?? json['organizationId'] ?? '2',
      name: json['name'] ?? '',
      fieldType: json['field_type'] ?? json['type'] ?? 'text',
      defaultValue: json['default_value'] ?? json['defaultValue'],
      options: parsedOptions,
      showInListing: json['show_in_listing'] == 1 || json['show_in_listing'] == true,
      status: json['status'] == 1 || json['status'] == true,
      mandatory: json['mandatory'] == 1 || json['mandatory'] == true || json['isRequired'] == true,
      createdBy: json['created_by'] ?? json['createdBy'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'name': name,
      'field_type': fieldType,
      'default_value': defaultValue,
      'options': options is String ? options : (options != null ? jsonEncode(options) : null),
      'show_in_listing': showInListing ? 1 : 0,
      'status': status ? 1 : 0,
      'mandatory': mandatory ? 1 : 0,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
