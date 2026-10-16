/// Matches `wallets` table in `whatsapp_wiz (2).sql`
///
/// CREATE TABLE `wallets` (
///   `id` bigint(20) NOT NULL,
///   `organization_id` bigint(20) NOT NULL,
///   `balance` decimal(15,2) NOT NULL DEFAULT 0.00,
///   `currency` varchar(10) NOT NULL DEFAULT 'INR',
///   `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
///   `updated_at` datetime(3) NOT NULL
/// )
class Wallet {
  final dynamic id;
  final dynamic organizationId;
  final double balance;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Wallet({
    required this.id,
    this.organizationId = '2',
    required this.balance,
    this.currency = 'INR',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    final bal = json['balance'] is num
        ? (json['balance'] as num).toDouble()
        : (double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0);

    final uAt = json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
        : DateTime.now();
    final cAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString()) ?? uAt
        : uAt;

    return Wallet(
      id: json['id'] ?? '',
      organizationId: json['organization_id'] ?? json['organizationId'] ?? '2',
      balance: bal,
      currency: json['currency'] ?? 'INR',
      createdAt: cAt,
      updatedAt: uAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'balance': balance,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
