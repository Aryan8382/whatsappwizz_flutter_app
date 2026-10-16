import 'dart:convert';

enum CampaignStatus {
  running('running', 'Running'),
  paused('paused', 'Paused'),
  completed('completed', 'Completed'),
  scheduled('scheduled', 'Scheduled'),
  draft('draft', 'Draft');

  final String value;
  final String label;
  const CampaignStatus(this.value, this.label);

  static CampaignStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'running':
        return CampaignStatus.running;
      case 'paused':
        return CampaignStatus.paused;
      case 'completed':
        return CampaignStatus.completed;
      case 'scheduled':
        return CampaignStatus.scheduled;
      case 'draft':
      default:
        return CampaignStatus.draft;
    }
  }
}

/// Matches `campaigns` table in `whatsapp_wiz (2).sql`
///
/// CREATE TABLE `campaigns` (
///   `id` bigint(20) NOT NULL,
///   `organization_id` bigint(20) NOT NULL,
///   `template_id` bigint(20) DEFAULT NULL,
///   `name` varchar(150) NOT NULL,
///   `status` varchar(30) NOT NULL DEFAULT 'draft',
///   `audience` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`audience`)),
///   `scheduled_at` datetime(3) DEFAULT NULL,
///   `started_at` datetime(3) DEFAULT NULL,
///   `completed_at` datetime(3) DEFAULT NULL,
///   `total_contacts` int(11) NOT NULL DEFAULT 0,
///   `sent_count` int(11) NOT NULL DEFAULT 0,
///   `delivered_count` int(11) NOT NULL DEFAULT 0,
///   `read_count` int(11) NOT NULL DEFAULT 0,
///   `failed_count` int(11) NOT NULL DEFAULT 0,
///   `rate_per_minute` int(11) NOT NULL DEFAULT 60,
///   `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
///   `updated_at` datetime(3) NOT NULL,
///   `error_count` int(11) NOT NULL DEFAULT 0,
///   `retry_attempt` int(11) NOT NULL DEFAULT 0
/// )
class Campaign {
  final dynamic id;
  final dynamic organizationId;
  final dynamic templateId;
  final String name;
  final CampaignStatus status;
  final dynamic audience;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int totalContacts;
  final int sentCount;
  final int deliveredCount;
  final int readCount;
  final int failedCount;
  final int ratePerMinute;
  final int errorCount;
  final int retryAttempt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // UI helper fields
  final String templateName;
  final String audienceSource;

  const Campaign({
    required this.id,
    this.organizationId = '2',
    this.templateId,
    required this.name,
    required this.status,
    this.audience,
    this.scheduledAt,
    this.startedAt,
    this.completedAt,
    int? totalContacts,
    int? totalRecipients,
    this.sentCount = 0,
    this.deliveredCount = 0,
    this.readCount = 0,
    this.failedCount = 0,
    this.ratePerMinute = 60,
    this.errorCount = 0,
    this.retryAttempt = 0,
    required this.createdAt,
    DateTime? updatedAt,
    this.templateName = '',
    this.audienceSource = 'segment',
  })  : totalContacts = totalContacts ?? totalRecipients ?? 0,
        updatedAt = updatedAt ?? createdAt;

  int get totalRecipients => totalContacts;
  double get deliveryRate => totalRecipients > 0 ? (deliveredCount / totalRecipients) * 100 : 0.0;
  double get openRate => deliveredCount > 0 ? (readCount / deliveredCount) * 100 : 0.0;

  factory Campaign.fromJson(Map<String, dynamic> json) {
    dynamic parsedAudience = json['audience'];
    if (parsedAudience is String && parsedAudience.isNotEmpty) {
      try {
        parsedAudience = jsonDecode(parsedAudience);
      } catch (_) {}
    }

    final cStatus = json['status'] != null
        ? CampaignStatus.fromString(json['status'].toString())
        : CampaignStatus.draft;

    final rawCreatedAt = json['created_at'] ?? json['createdAt'];
    final rawUpdatedAt = json['updated_at'] ?? json['updatedAt'];
    final rawScheduledAt = json['scheduled_at'] ?? json['scheduledAt'];
    final rawStartedAt = json['started_at'] ?? json['startedAt'];
    final rawCompletedAt = json['completed_at'] ?? json['completedAt'];

    final cAt = rawCreatedAt != null
        ? DateTime.tryParse(rawCreatedAt.toString()) ?? DateTime.now()
        : DateTime.now();

    int parseNum(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    return Campaign(
      id: json['id'] ?? '',
      organizationId: json['organization_id'] ?? json['organizationId'] ?? '2',
      templateId: json['template_id'] ?? json['templateId'],
      name: json['name'] ?? '',
      status: cStatus,
      audience: parsedAudience,
      scheduledAt: rawScheduledAt != null ? DateTime.tryParse(rawScheduledAt.toString()) : null,
      startedAt: rawStartedAt != null ? DateTime.tryParse(rawStartedAt.toString()) : null,
      completedAt: rawCompletedAt != null ? DateTime.tryParse(rawCompletedAt.toString()) : null,
      totalContacts: parseNum(json['totalContacts'] ?? json['total_contacts'] ?? json['totalRecipients']),
      sentCount: parseNum(json['sentCount'] ?? json['sent_count']),
      deliveredCount: parseNum(json['deliveredCount'] ?? json['delivered_count']),
      readCount: parseNum(json['readCount'] ?? json['read_count']),
      failedCount: parseNum(json['failedCount'] ?? json['failed_count']),
      ratePerMinute: parseNum(json['ratePerMinute'] ?? json['rate_per_minute'] ?? 60),
      errorCount: parseNum(json['errorCount'] ?? json['error_count']),
      retryAttempt: parseNum(json['retryAttempt'] ?? json['retry_attempt']),
      createdAt: cAt,
      updatedAt: rawUpdatedAt != null ? DateTime.tryParse(rawUpdatedAt.toString()) : null,
      templateName: json['template_name'] ??
          json['templateName'] ??
          (json['template'] is Map ? json['template']['name'] : null) ??
          '',
      audienceSource: json['audience_source'] ?? json['audienceSource'] ?? 'segment',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'template_id': templateId,
      'name': name,
      'status': status.value,
      'audience': audience is String ? audience : jsonEncode(audience),
      'scheduled_at': scheduledAt?.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'total_contacts': totalContacts,
      'sent_count': sentCount,
      'delivered_count': deliveredCount,
      'read_count': readCount,
      'failed_count': failedCount,
      'rate_per_minute': ratePerMinute,
      'error_count': errorCount,
      'retry_attempt': retryAttempt,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'template_name': templateName,
      'audience_source': audienceSource,
    };
  }

  Campaign copyWith({
    dynamic id,
    dynamic organizationId,
    dynamic templateId,
    String? name,
    String? templateName,
    String? audienceSource,
    CampaignStatus? status,
    dynamic audience,
    DateTime? scheduledAt,
    DateTime? startedAt,
    DateTime? completedAt,
    int? totalContacts,
    int? totalRecipients,
    int? sentCount,
    int? deliveredCount,
    int? readCount,
    int? failedCount,
    int? ratePerMinute,
    int? errorCount,
    int? retryAttempt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Campaign(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      templateName: templateName ?? this.templateName,
      audienceSource: audienceSource ?? this.audienceSource,
      status: status ?? this.status,
      audience: audience ?? this.audience,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      totalContacts: totalContacts ?? totalRecipients ?? this.totalContacts,
      sentCount: sentCount ?? this.sentCount,
      deliveredCount: deliveredCount ?? this.deliveredCount,
      readCount: readCount ?? this.readCount,
      failedCount: failedCount ?? this.failedCount,
      ratePerMinute: ratePerMinute ?? this.ratePerMinute,
      errorCount: errorCount ?? this.errorCount,
      retryAttempt: retryAttempt ?? this.retryAttempt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
