/// Matches `wallet_transactions` table in `whatsapp_wiz (2).sql`
///
/// CREATE TABLE `wallet_transactions` (
///   `id` bigint(20) NOT NULL,
///   `wallet_id` bigint(20) NOT NULL,
///   `type` varchar(30) NOT NULL,
///   `amount` decimal(15,2) NOT NULL,
///   `balance_after` decimal(15,2) NOT NULL,
///   `reference` varchar(255) DEFAULT NULL,
///   `description` varchar(255) DEFAULT NULL,
///   `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3)
/// )
class WalletTransaction {
  final dynamic id;
  final dynamic walletId;
  final String type; // credit, debit
  final double amount;
  final double balanceAfter;
  final String? reference;
  final String? description;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.reference,
    this.description,
    required this.createdAt,
  });

  bool get isCredit => type.toLowerCase() == 'credit';

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    final amt = json['amount'] is num
        ? (json['amount'] as num).toDouble()
        : (double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0);

    final balAfter = json['balance_after'] is num
        ? (json['balance_after'] as num).toDouble()
        : (double.tryParse(json['balance_after']?.toString() ?? '0') ?? 0.0);

    final cAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
        : DateTime.now();

    return WalletTransaction(
      id: json['id'] ?? '',
      walletId: json['wallet_id'] ?? json['walletId'] ?? '',
      type: json['type'] ?? 'credit',
      amount: amt,
      balanceAfter: balAfter,
      reference: json['reference'],
      description: json['description'],
      createdAt: cAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      'type': type,
      'amount': amount,
      'balance_after': balanceAfter,
      'reference': reference,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
