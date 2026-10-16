/// Matches `contacts` table in `whatsapp_wiz (2).sql`
///
/// CREATE TABLE `contacts` (
///   `id` bigint(20) NOT NULL,
///   `organization_id` bigint(20) NOT NULL,
///   `first_name` varchar(100) NOT NULL,
///   `last_name` varchar(100) DEFAULT NULL,
///   `mobile` varchar(30) NOT NULL,
///   `email` varchar(150) DEFAULT NULL,
///   `city` varchar(100) DEFAULT NULL,
///   `state` varchar(100) DEFAULT NULL,
///   `country` varchar(100) DEFAULT NULL,
///   `opt_in` tinyint(1) NOT NULL DEFAULT 1,
///   `source` varchar(100) DEFAULT NULL,
///   `last_interaction` datetime(3) DEFAULT NULL,
///   `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
///   `updated_at` datetime(3) NOT NULL
/// )
class Contact {
  final dynamic id;
  final dynamic organizationId;
  final String firstName;
  final String? lastName;
  final String mobile;
  final String? email;
  final String? city;
  final String? state;
  final String? country;
  final bool optIn;
  final String source;
  final DateTime? lastInteraction;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Joined relations / App fields
  final List<String> tags;
  final Map<String, dynamic> customFields;

  const Contact({
    required this.id,
    this.organizationId = '2',
    required this.firstName,
    this.lastName,
    required this.mobile,
    this.email,
    this.city,
    this.state,
    this.country,
    this.optIn = true,
    this.source = 'manual',
    this.lastInteraction,
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
    this.customFields = const {},
  });

  String get fullName => ('$firstName ${lastName ?? ''}').trim();

  factory Contact.fromJson(Map<String, dynamic> json) {
    final rawLastInteraction = json['last_interaction'] ?? json['lastInteraction'];
    final rawUpdatedAt = json['updated_at'] ?? json['updatedAt'];
    final rawCreatedAt = json['created_at'] ?? json['createdAt'];

    return Contact(
      id: json['id'] ?? '',
      organizationId: json['organization_id'] ?? json['organizationId'] ?? '2',
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'],
      mobile: json['mobile'] ?? '',
      email: json['email'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      optIn: json['opt_in'] == 1 || json['opt_in'] == true || json['optIn'] == true,
      source: json['source'] ?? 'manual',
      lastInteraction: rawLastInteraction != null
          ? DateTime.tryParse(rawLastInteraction.toString())
          : null,
      createdAt: rawCreatedAt != null
          ? DateTime.tryParse(rawCreatedAt.toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: rawUpdatedAt != null
          ? DateTime.tryParse(rawUpdatedAt.toString())
          : null,
      tags: json['tags'] != null
          ? (json['tags'] as Iterable).map((t) {
              if (t is Map) {
                return (t['name'] ?? t['title'] ?? t.toString()).toString();
              }
              return t.toString();
            }).where((s) => s.isNotEmpty).toList()
          : const [],
      customFields: json['custom_fields'] != null && json['custom_fields'] is Map
          ? Map<String, dynamic>.from(json['custom_fields'] as Map)
          : (json['customFields'] != null && json['customFields'] is Map
              ? Map<String, dynamic>.from(json['customFields'] as Map)
              : const {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'first_name': firstName,
      'last_name': lastName,
      'mobile': mobile,
      'email': email,
      'city': city,
      'state': state,
      'country': country,
      'opt_in': optIn ? 1 : 0,
      'source': source,
      'last_interaction': lastInteraction?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': (updatedAt ?? createdAt).toIso8601String(),
      'tags': tags,
      'custom_fields': customFields,
    };
  }

  Contact copyWith({
    dynamic id,
    dynamic organizationId,
    String? firstName,
    String? lastName,
    String? mobile,
    String? email,
    String? city,
    String? state,
    String? country,
    bool? optIn,
    String? source,
    DateTime? lastInteraction,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    Map<String, dynamic>? customFields,
  }) {
    return Contact(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      optIn: optIn ?? this.optIn,
      source: source ?? this.source,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      customFields: customFields ?? this.customFields,
    );
  }
}
