enum UserRole {
  superAdmin('super_admin', 'Super Admin'),
  orgAdmin('org_admin', 'Org Admin'),
  supervisor('supervisor', 'Supervisor'),
  agent('agent', 'Agent'),
  reseller('reseller', 'Reseller');

  final String value;
  final String displayName;
  const UserRole(this.value, this.displayName);

  static UserRole fromString(String val) {
    switch (val.toLowerCase()) {
      case 'super_admin':
        return UserRole.superAdmin;
      case 'org_admin':
        return UserRole.orgAdmin;
      case 'supervisor':
        return UserRole.supervisor;
      case 'agent':
        return UserRole.agent;
      case 'reseller':
        return UserRole.reseller;
      default:
        return UserRole.agent;
    }
  }

  static UserRole fromRoleId(dynamic roleId) {
    final id = int.tryParse(roleId.toString()) ?? 4;
    switch (id) {
      case 1:
      case 6:
        return UserRole.superAdmin;
      case 2:
      case 7:
        return UserRole.orgAdmin;
      case 3:
      case 8:
        return UserRole.supervisor;
      case 4:
      case 9:
        return UserRole.agent;
      case 5:
      case 10:
        return UserRole.reseller;
      default:
        return UserRole.agent;
    }
  }
}

/// Matches `users` table in `whatsapp_wiz (2).sql`
///
/// CREATE TABLE `users` (
///   `id` bigint(20) NOT NULL,
///   `organization_id` bigint(20) NOT NULL,
///   `role_id` bigint(20) NOT NULL,
///   `first_name` varchar(100) NOT NULL,
///   `last_name` varchar(100) NOT NULL,
///   `email` varchar(150) NOT NULL,
///   `mobile` varchar(30) DEFAULT NULL,
///   `password_hash` varchar(255) NOT NULL,
///   `avatar` varchar(255) DEFAULT NULL,
///   `status` varchar(20) NOT NULL DEFAULT 'active',
///   `last_login` datetime(3) DEFAULT NULL,
///   `created_at` datetime(3) NOT NULL DEFAULT current_timestamp(3),
///   `updated_at` datetime(3) NOT NULL
/// )
class User {
  final dynamic id;
  final dynamic organizationId;
  final dynamic roleId;
  final String firstName;
  final String lastName;
  final String email;
  final String? mobile;
  final String? passwordHash;
  final String? avatar;
  final String status;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined / UI helper properties
  final UserRole role;
  final String? orgName;

  const User({
    dynamic sub,
    dynamic id,
    dynamic organizationId = '1',
    dynamic roleId = 4,
    required this.email,
    required this.role,
    this.firstName = '',
    this.lastName = '',
    this.mobile,
    this.passwordHash,
    this.avatar,
    this.status = 'active',
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
    this.orgName,
  })  : id = id ?? sub ?? '1',
        organizationId = organizationId ?? '1',
        roleId = roleId ?? 4;

  /// Compatibility alias for authentication sub token
  String get sub => id.toString();

  String get fullName => '$firstName $lastName'.trim();

  factory User.fromJson(Map<String, dynamic> json) {
    final rId = json['role_id'] ?? json['roleId'] ?? (json['role'] is Map ? json['role']['id'] : null);
    final roleVal = rId != null
        ? UserRole.fromRoleId(rId)
        : (json['role'] != null && json['role'] is! Map
            ? UserRole.fromString(json['role'].toString())
            : UserRole.agent);

    final rawLastLogin = json['last_login'] ?? json['lastLogin'];
    final rawCreatedAt = json['created_at'] ?? json['createdAt'];
    final rawUpdatedAt = json['updated_at'] ?? json['updatedAt'];

    return User(
      id: json['id'] ?? json['sub'],
      organizationId: json['organization_id'] ?? json['organizationId'],
      roleId: rId,
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'],
      passwordHash: json['password_hash'] ?? json['passwordHash'],
      avatar: json['avatar'],
      status: json['status'] ?? 'active',
      lastLogin: rawLastLogin != null ? DateTime.tryParse(rawLastLogin.toString()) : null,
      createdAt: rawCreatedAt != null ? DateTime.tryParse(rawCreatedAt.toString()) : null,
      updatedAt: rawUpdatedAt != null ? DateTime.tryParse(rawUpdatedAt.toString()) : null,
      role: roleVal,
      orgName: json['org_name'] ?? json['orgName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'role_id': roleId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'mobile': mobile,
      'password_hash': passwordHash,
      'avatar': avatar,
      'status': status,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'role': role.value,
      'org_name': orgName,
    };
  }

  User copyWith({
    dynamic id,
    dynamic sub,
    dynamic organizationId,
    dynamic roleId,
    String? email,
    UserRole? role,
    String? firstName,
    String? lastName,
    String? mobile,
    String? passwordHash,
    String? avatar,
    String? status,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? orgName,
  }) {
    return User(
      id: id ?? sub ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      roleId: roleId ?? this.roleId,
      email: email ?? this.email,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      mobile: mobile ?? this.mobile,
      passwordHash: passwordHash ?? this.passwordHash,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      orgName: orgName ?? this.orgName,
    );
  }
}
