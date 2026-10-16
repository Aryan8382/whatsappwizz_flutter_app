/// Matches `conversation_notes` table in `whatsapp_wiz (2).sql`
///
/// CREATE TABLE `conversation_notes` (
///   `id` bigint(20) NOT NULL,
///   `conversation_id` bigint(20) NOT NULL,
///   `user_id` bigint(20) NOT NULL,
///   `note` text NOT NULL,
///   `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3)
/// )
class ConversationNote {
  final dynamic id;
  final dynamic conversationId;
  final dynamic userId;
  final String note;
  final DateTime createdAt;

  const ConversationNote({
    required this.id,
    required this.conversationId,
    required this.userId,
    required this.note,
    required this.createdAt,
  });

  factory ConversationNote.fromJson(Map<String, dynamic> json) {
    return ConversationNote(
      id: json['id'] ?? '',
      conversationId: json['conversation_id'] ?? json['conversationId'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      note: json['note'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'user_id': userId,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
