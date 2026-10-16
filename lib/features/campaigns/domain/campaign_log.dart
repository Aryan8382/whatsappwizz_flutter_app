/// Matches `campaign_logs` table in `whatsapp_wiz (2).sql`
///
/// CREATE TABLE `campaign_logs` (
///   `id` bigint(20) NOT NULL,
///   `campaign_id` bigint(20) NOT NULL,
///   `contact_id` bigint(20) NOT NULL,
///   `meta_message_id` varchar(150) DEFAULT NULL,
///   `status` varchar(30) NOT NULL DEFAULT 'pending',
///   `error_message` text DEFAULT NULL,
///   `sent_at` datetime(3) DEFAULT NULL,
///   `delivered_at` datetime(3) DEFAULT NULL,
///   `read_at` datetime(3) DEFAULT NULL
/// )
class CampaignLog {
  final dynamic id;
  final dynamic campaignId;
  final dynamic contactId;
  final String? metaMessageId;
  final String status;
  final String? errorMessage;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;

  const CampaignLog({
    required this.id,
    required this.campaignId,
    required this.contactId,
    this.metaMessageId,
    this.status = 'pending',
    this.errorMessage,
    this.sentAt,
    this.deliveredAt,
    this.readAt,
  });

  factory CampaignLog.fromJson(Map<String, dynamic> json) {
    return CampaignLog(
      id: json['id'] ?? '',
      campaignId: json['campaign_id'] ?? json['campaignId'] ?? '',
      contactId: json['contact_id'] ?? json['contactId'] ?? '',
      metaMessageId: json['meta_message_id'] ?? json['metaMessageId'],
      status: json['status'] ?? 'pending',
      errorMessage: json['error_message'] ?? json['errorMessage'],
      sentAt: json['sent_at'] != null ? DateTime.tryParse(json['sent_at'].toString()) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.tryParse(json['delivered_at'].toString()) : null,
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaign_id': campaignId,
      'contact_id': contactId,
      'meta_message_id': metaMessageId,
      'status': status,
      'error_message': errorMessage,
      'sent_at': sentAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }
}
