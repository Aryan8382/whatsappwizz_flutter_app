/// Matches `waba_accounts` table in `whatsapp_wiz (2).sql`
///
/// CREATE TABLE `waba_accounts` (
///   `id` bigint(20) NOT NULL,
///   `organization_id` bigint(20) NOT NULL,
///   `business_id` varchar(100) NOT NULL,
///   `waba_id` varchar(100) NOT NULL,
///   `access_token` text NOT NULL,
///   `token_expiry` datetime(3) DEFAULT NULL,
///   `quality_rating` varchar(30) NOT NULL DEFAULT 'UNKNOWN',
///   `status` varchar(30) NOT NULL DEFAULT 'connected',
///   `webhook_secret` text DEFAULT NULL,
///   `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
///   `updated_at` datetime(3) NOT NULL
/// )
class WabaAccount {
  final dynamic id;
  final dynamic organizationId;
  final String businessId;
  final String wabaId;
  final String accessToken;
  final DateTime? tokenExpiry;
  final String qualityRating;
  final String status;
  final String? webhookSecret;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WabaAccount({
    required this.id,
    this.organizationId = '2',
    required this.businessId,
    required this.wabaId,
    required this.accessToken,
    this.tokenExpiry,
    this.qualityRating = 'GREEN',
    this.status = 'connected',
    this.webhookSecret,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WabaAccount.fromJson(Map<String, dynamic> json) {
    final uAt = json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
        : DateTime.now();
    final cAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString()) ?? uAt
        : uAt;

    return WabaAccount(
      id: json['id'] ?? '',
      organizationId: json['organization_id'] ?? json['organizationId'] ?? '2',
      businessId: json['business_id'] ?? json['businessId'] ?? '',
      wabaId: json['waba_id'] ?? json['wabaId'] ?? '',
      accessToken: json['access_token'] ?? json['accessToken'] ?? '',
      tokenExpiry: json['token_expiry'] != null
          ? DateTime.tryParse(json['token_expiry'].toString())
          : null,
      qualityRating: json['quality_rating'] ?? json['qualityRating'] ?? 'GREEN',
      status: json['status'] ?? 'connected',
      webhookSecret: json['webhook_secret'] ?? json['webhookSecret'],
      createdAt: cAt,
      updatedAt: uAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'business_id': businessId,
      'waba_id': wabaId,
      'access_token': accessToken,
      'token_expiry': tokenExpiry?.toIso8601String(),
      'quality_rating': qualityRating,
      'status': status,
      'webhook_secret': webhookSecret,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
