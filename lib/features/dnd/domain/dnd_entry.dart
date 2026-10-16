/// Matches `dnd_entries` table in `whatsapp_wiz (2).sql`
///
/// CREATE TABLE `dnd_entries` (
///   `id` bigint(20) NOT NULL,
///   `organization_id` bigint(20) NOT NULL,
///   `number` varchar(30) NOT NULL,
///   `message` varchar(255) DEFAULT NULL,
///   `added_at` datetime(3) NOT NULL DEFAULT current_timestamp(3)
/// )
class DndEntry {
  final dynamic id;
  final dynamic organizationId;
  final String number;
  final String? message;
  final DateTime addedAt;

  const DndEntry({
    required this.id,
    this.organizationId = '2',
    required this.number,
    this.message,
    required this.addedAt,
  });

  factory DndEntry.fromJson(Map<String, dynamic> json) {
    return DndEntry(
      id: json['id'] ?? '',
      organizationId: json['organization_id'] ?? json['organizationId'] ?? '2',
      number: json['number'] ?? json['phone'] ?? '',
      message: json['message'] ?? json['reason'],
      addedAt: json['added_at'] != null
          ? DateTime.tryParse(json['added_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'number': number,
      'message': message,
      'added_at': addedAt.toIso8601String(),
    };
  }
}
