/// Matches `whatsapp_numbers` table in `whatsapp_wiz (2).sql`
///
/// CREATE TABLE `whatsapp_numbers` (
///   `id` bigint(20) NOT NULL,
///   `organization_id` bigint(20) NOT NULL,
///   `waba_account_id` bigint(20) NOT NULL,
///   `phone_number` varchar(30) NOT NULL,
///   `phone_number_id` varchar(100) NOT NULL,
///   `display_name` varchar(150) NOT NULL,
///   `verification_status` varchar(50) NOT NULL DEFAULT 'verified',
///   `quality_rating` varchar(30) NOT NULL DEFAULT 'GREEN',
///   `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
///   `updated_at` datetime(3) NOT NULL
/// )
class WhatsappNumber {
  final dynamic id;
  final dynamic organizationId;
  final dynamic wabaAccountId;
  final String phoneNumber;
  final String phoneNumberId;
  final String displayName;
  final String verificationStatus;
  final String qualityRating;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WhatsappNumber({
    required this.id,
    this.organizationId = '2',
    required this.wabaAccountId,
    required this.phoneNumber,
    required this.phoneNumberId,
    required this.displayName,
    this.verificationStatus = 'verified',
    this.qualityRating = 'GREEN',
    required this.createdAt,
    required this.updatedAt,
  });

  factory WhatsappNumber.fromJson(Map<String, dynamic> json) {
    final uAt = json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
        : DateTime.now();
    final cAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString()) ?? uAt
        : uAt;

    return WhatsappNumber(
      id: json['id'] ?? '',
      organizationId: json['organization_id'] ?? json['organizationId'] ?? '2',
      wabaAccountId: json['waba_account_id'] ?? json['wabaAccountId'] ?? '1',
      phoneNumber: json['phone_number'] ?? json['phoneNumber'] ?? '',
      phoneNumberId: json['phone_number_id'] ?? json['phoneNumberId'] ?? '',
      displayName: json['display_name'] ?? json['displayName'] ?? '',
      verificationStatus: json['verification_status'] ?? json['verificationStatus'] ?? 'verified',
      qualityRating: json['quality_rating'] ?? json['qualityRating'] ?? 'GREEN',
      createdAt: cAt,
      updatedAt: uAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'waba_account_id': wabaAccountId,
      'phone_number': phoneNumber,
      'phone_number_id': phoneNumberId,
      'display_name': displayName,
      'verification_status': verificationStatus,
      'quality_rating': qualityRating,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
