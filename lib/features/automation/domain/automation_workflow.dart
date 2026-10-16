import 'dart:convert';

/// Matches `automation_workflows` table in `whatsapp_wiz (2).sql`
///
/// CREATE TABLE `automation_workflows` (
///   `id` bigint(20) NOT NULL,
///   `organization_id` bigint(20) NOT NULL,
///   `name` varchar(150) NOT NULL,
///   `status` varchar(20) NOT NULL DEFAULT 'draft',
///   `trigger_type` varchar(50) DEFAULT NULL,
///   `trigger_config` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`trigger_config`)),
///   `steps` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`steps`)),
///   `last_run_at` datetime(3) DEFAULT NULL,
///   `created_by` bigint(20) DEFAULT NULL,
///   `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
///   `updated_at` datetime(3) NOT NULL
/// )
class AutomationWorkflow {
  final dynamic id;
  final dynamic organizationId;
  final String name;
  final String status;
  final String? triggerType;
  final dynamic triggerConfig;
  final dynamic steps;
  final DateTime? lastRunAt;
  final dynamic createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // UI helper getters & fields
  final String triggerEvent;
  final String actionType;
  final int executionCount;

  const AutomationWorkflow({
    required this.id,
    this.organizationId = '2',
    required this.name,
    String? status,
    bool? isActive,
    this.triggerType,
    String? triggerEvent,
    this.triggerConfig,
    String? actionType,
    this.steps,
    this.lastRunAt,
    this.createdBy,
    DateTime? createdAt,
    required this.updatedAt,
    this.executionCount = 0,
  })  : status = status ?? (isActive == true ? 'active' : 'draft'),
        triggerEvent = triggerEvent ?? triggerType ?? 'message.inbound',
        actionType = actionType ?? 'send_template',
        createdAt = createdAt ?? updatedAt;

  bool get isActive => status == 'active';

  factory AutomationWorkflow.fromJson(Map<String, dynamic> json) {
    dynamic parsedTriggerConfig = json['trigger_config'];
    if (parsedTriggerConfig is String && parsedTriggerConfig.isNotEmpty) {
      try {
        parsedTriggerConfig = jsonDecode(parsedTriggerConfig);
      } catch (_) {}
    }

    dynamic parsedSteps = json['steps'];
    if (parsedSteps is String && parsedSteps.isNotEmpty) {
      try {
        parsedSteps = jsonDecode(parsedSteps);
      } catch (_) {}
    }

    final uAt = json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
        : DateTime.now();
    final cAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString()) ?? uAt
        : uAt;

    final stat = json['status'] ?? (json['isActive'] == true ? 'active' : 'draft');

    return AutomationWorkflow(
      id: json['id'] ?? '',
      organizationId: json['organization_id'] ?? json['organizationId'] ?? '2',
      name: json['name'] ?? '',
      status: stat,
      triggerType: json['trigger_type'] ?? json['triggerEvent'],
      triggerConfig: parsedTriggerConfig,
      steps: parsedSteps,
      lastRunAt: json['last_run_at'] != null ? DateTime.tryParse(json['last_run_at'].toString()) : null,
      createdBy: json['created_by'] ?? json['createdBy'],
      createdAt: cAt,
      updatedAt: uAt,
      triggerEvent: json['triggerEvent'] ?? json['trigger_type'] ?? 'message.inbound',
      actionType: json['actionType'] ?? 'send_template',
      executionCount: json['executionCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'name': name,
      'status': status,
      'trigger_type': triggerType,
      'trigger_config': triggerConfig is String ? triggerConfig : (triggerConfig != null ? jsonEncode(triggerConfig) : null),
      'steps': steps is String ? steps : (steps != null ? jsonEncode(steps) : null),
      'last_run_at': lastRunAt?.toIso8601String(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AutomationWorkflow copyWith({
    dynamic id,
    dynamic organizationId,
    String? name,
    String? status,
    bool? isActive,
    String? triggerType,
    String? triggerEvent,
    dynamic triggerConfig,
    String? actionType,
    dynamic steps,
    DateTime? lastRunAt,
    dynamic createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? executionCount,
  }) {
    return AutomationWorkflow(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      status: status ?? (isActive != null ? (isActive ? 'active' : 'draft') : this.status),
      triggerType: triggerType ?? this.triggerType,
      triggerEvent: triggerEvent ?? this.triggerEvent,
      triggerConfig: triggerConfig ?? this.triggerConfig,
      actionType: actionType ?? this.actionType,
      steps: steps ?? this.steps,
      lastRunAt: lastRunAt ?? this.lastRunAt,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      executionCount: executionCount ?? this.executionCount,
    );
  }
}
