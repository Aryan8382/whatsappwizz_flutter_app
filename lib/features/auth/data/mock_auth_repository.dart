import '../domain/auth_repository.dart';
import '../domain/user.dart';

class MockAuthRepository implements AuthRepository {
  User? _currentUser;

  static final List<Map<String, dynamic>> _demoAccounts = [
    {
      'email': 'admin@demo.com',
      'password': 'Admin@123',
      'user': const User(
        sub: '101',
        email: 'admin@demo.com',
        organizationId: 'org_demo',
        role: UserRole.orgAdmin,
        firstName: 'Demo',
        lastName: 'Admin',
        orgName: 'Demo Company',
      ),
    },
    {
      'email': 'supervisor@demo.com',
      'password': 'Supervisor@123',
      'user': const User(
        sub: '102',
        email: 'supervisor@demo.com',
        organizationId: 'org_demo',
        role: UserRole.supervisor,
        firstName: 'Demo',
        lastName: 'Supervisor',
        orgName: 'Demo Company',
      ),
    },
    {
      'email': 'agent@demo.com',
      'password': 'Agent@123',
      'user': const User(
        sub: '103',
        email: 'agent@demo.com',
        organizationId: 'org_demo',
        role: UserRole.agent,
        firstName: 'Demo',
        lastName: 'Agent',
        orgName: 'Demo Company',
      ),
    },
    {
      'email': 'reseller@demo.com',
      'password': 'Reseller@123',
      'user': const User(
        sub: '104',
        email: 'reseller@demo.com',
        organizationId: 'org_demo',
        role: UserRole.reseller,
        firstName: 'Demo',
        lastName: 'Reseller',
        orgName: 'Demo Company',
      ),
    },
    {
      'email': 'admin@whatsappwiz.io',
      'password': 'Admin@123',
      'user': const User(
        sub: '1',
        email: 'admin@whatsappwiz.io',
        organizationId: 'org_super',
        role: UserRole.superAdmin,
        firstName: 'System',
        lastName: 'Admin',
        orgName: 'Whatsapp Wiz',
      ),
    },
  ];

  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final cleanEmail = email.trim().toLowerCase();
    final match = _demoAccounts.firstWhere(
      (acc) =>
          acc['email'] == cleanEmail &&
          acc['password'] == password,
      orElse: () => {},
    );

    if (match.isEmpty) {
      throw Exception('Invalid email or password. Check demo credentials.');
    }

    _currentUser = match['user'] as User;
    return _currentUser!;
  }

  @override
  Future<User?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_currentUser == null) throw Exception('Not authenticated');
  }
}
