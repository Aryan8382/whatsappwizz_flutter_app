enum TemplateStatus {
  approved('approved', 'Approved'),
  pending('pending', 'Pending Approval'),
  rejected('rejected', 'Rejected'),
  draft('draft', 'Draft');

  final String value;
  final String label;
  const TemplateStatus(this.value, this.label);

  static TemplateStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'approved':
        return TemplateStatus.approved;
      case 'pending':
        return TemplateStatus.pending;
      case 'rejected':
        return TemplateStatus.rejected;
      case 'draft':
      default:
        return TemplateStatus.draft;
    }
  }
}

/// Matches `templates` table in `whatsapp_wiz (2).sql`
///
/// CREATE TABLE `templates` (
///   `id` bigint(20) NOT NULL,
///   `organization_id` bigint(20) NOT NULL,
///   `meta_template_id` varchar(150) DEFAULT NULL,
///   `name` varchar(150) NOT NULL,
///   `category` varchar(50) NOT NULL DEFAULT 'UTILITY',
///   `language` varchar(20) NOT NULL DEFAULT 'en',
///   `status` varchar(50) NOT NULL DEFAULT 'draft',
///   `header` text DEFAULT NULL,
///   `body` longtext NOT NULL,
///   `footer` text DEFAULT NULL,
///   `rejection_reason` text DEFAULT NULL,
///   `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
///   `updated_at` datetime(3) NOT NULL
/// )
class Template {
  final dynamic id;
  final dynamic organizationId;
  final String? metaTemplateId;
  final String name;
  final String category;
  final String language;
  final TemplateStatus status;
  final String? header;
  final String body;
  final String? footer;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  // UI helper fields
  final String? headerType;
  final List<String> buttons;

  const Template({
    required this.id,
    this.organizationId = '2',
    this.metaTemplateId,
    required this.name,
    this.language = 'en',
    required this.category,
    this.header,
    String? headerText,
    this.headerType,
    required this.body,
    this.footer,
    this.rejectionReason,
    this.buttons = const [],
    required this.status,
    DateTime? createdAt,
    required this.updatedAt,
  })  : createdAt = createdAt ?? updatedAt;

  String? get headerText => header;

  factory Template.fromJson(Map<String, dynamic> json) {
    final statusVal = json['status'] != null
        ? TemplateStatus.fromString(json['status'].toString())
        : TemplateStatus.draft;

    final uAt = json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
        : DateTime.now();
    final cAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString()) ?? uAt
        : uAt;

    return Template(
      id: json['id'] ?? '',
      organizationId: json['organization_id'] ?? json['organizationId'] ?? '2',
      metaTemplateId: json['meta_template_id'] ?? json['metaTemplateId'],
      name: json['name'] ?? '',
      category: json['category'] ?? 'UTILITY',
      language: json['language'] ?? 'en',
      status: statusVal,
      header: json['header'] ?? json['headerText'],
      body: json['body'] ?? '',
      footer: json['footer'],
      rejectionReason: json['rejection_reason'] ?? json['rejectionReason'],
      headerType: json['header_type'] ?? json['headerType'],
      buttons: () {
        final raw = json['buttons'];
        if (raw == null) return const <String>[];
        if (raw is List) {
          return raw.map((b) {
            if (b is Map) {
              return (b['text'] ?? b['title'] ?? b['value'] ?? b.toString()).toString();
            }
            return b.toString();
          }).toList();
        }
        return const <String>[];
      }(),
      createdAt: cAt,
      updatedAt: uAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'meta_template_id': metaTemplateId,
      'name': name,
      'category': category,
      'language': language,
      'status': status.value,
      'header': header,
      'body': body,
      'footer': footer,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'buttons': buttons,
    };
  }

  Template copyWith({
    dynamic id,
    dynamic organizationId,
    String? metaTemplateId,
    String? name,
    String? language,
    String? category,
    String? header,
    String? headerType,
    String? headerText,
    String? body,
    String? footer,
    String? rejectionReason,
    List<String>? buttons,
    TemplateStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Template(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      metaTemplateId: metaTemplateId ?? this.metaTemplateId,
      name: name ?? this.name,
      language: language ?? this.language,
      category: category ?? this.category,
      header: header ?? headerText ?? this.header,
      headerType: headerType ?? this.headerType,
      body: body ?? this.body,
      footer: footer ?? this.footer,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      buttons: buttons ?? this.buttons,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
