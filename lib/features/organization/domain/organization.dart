/// Matches `organizations` table in `whatsapp_wiz (2).sql`
///
/// CREATE TABLE `organizations` (
///   `id` bigint(20) NOT NULL,
///   `name` varchar(150) NOT NULL,
///   `slug` varchar(100) NOT NULL,
///   `email` varchar(150) DEFAULT NULL,
///   `phone` varchar(30) DEFAULT NULL,
///   `logo` varchar(255) DEFAULT NULL,
///   `website` varchar(255) DEFAULT NULL,
///   `timezone` varchar(100) NOT NULL DEFAULT 'Asia/Kolkata',
///   `currency` varchar(10) NOT NULL DEFAULT 'INR',
///   `status` varchar(20) NOT NULL DEFAULT 'active',
///   `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
///   `updated_at` datetime(3) NOT NULL,
///   `deleted_at` datetime(3) DEFAULT NULL
/// )
class Organization {
  final dynamic id;
  final String name;
  final String slug;
  final String? email;
  final String? phone;
  final String? logo;
  final String? website;
  final String timezone;
  final String currency;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Organization({
    required this.id,
    required this.name,
    required this.slug,
    this.email,
    this.phone,
    this.logo,
    this.website,
    this.timezone = 'Asia/Kolkata',
    this.currency = 'INR',
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    final uAt = json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
        : DateTime.now();
    final cAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString()) ?? uAt
        : uAt;

    return Organization(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      email: json['email'],
      phone: json['phone'],
      logo: json['logo'],
      website: json['website'],
      timezone: json['timezone'] ?? 'Asia/Kolkata',
      currency: json['currency'] ?? 'INR',
      status: json['status'] ?? 'active',
      createdAt: cAt,
      updatedAt: uAt,
      deletedAt: json['deleted_at'] != null ? DateTime.tryParse(json['deleted_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'email': email,
      'phone': phone,
      'logo': logo,
      'website': website,
      'timezone': timezone,
      'currency': currency,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
