/// Matches `conversation_labels` table in `whatsapp_wiz (2).sql`
///
/// CREATE TABLE `conversation_labels` (
///   `id` bigint(20) NOT NULL,
///   `organization_id` bigint(20) NOT NULL,
///   `name` varchar(100) NOT NULL,
///   `color` varchar(20) NOT NULL DEFAULT '#25D366',
///   `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3)
/// )
class ConversationLabel {
  final dynamic id;
  final dynamic organizationId;
  final String name;
  final String color;
  final DateTime createdAt;

  const ConversationLabel({
    required this.id,
    this.organizationId = '2',
    required this.name,
    this.color = '#25D366',
    required this.createdAt,
  });

  factory ConversationLabel.fromJson(Map<String, dynamic> json) {
    return ConversationLabel(
      id: json['id'] ?? '',
      organizationId: json['organization_id'] ?? json['organizationId'] ?? '2',
      name: json['name'] ?? '',
      color: json['color'] ?? '#25D366',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'name': name,
      'color': color,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
