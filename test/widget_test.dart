import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_wiz/features/auth/domain/auth_repository.dart';
import 'package:whatsapp_wiz/features/auth/domain/user.dart';
import 'package:whatsapp_wiz/features/auth/presentation/auth_controller.dart';
import 'package:whatsapp_wiz/features/auth/presentation/login_screen.dart';

class TestAuthRepository implements AuthRepository {
  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<User> login(String email, String password) async {
    return const User(
      sub: '1',
      email: 'test@demo.com',
      organizationId: 'org1',
      role: UserRole.orgAdmin,
    );
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {}
}

void main() {
  group('Login Form Widget Tests', () {
    testWidgets('renders login form with email, password fields and sign in button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(TestAuthRepository()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header and fields exist
      expect(find.text('Sign in to your workspace'), findsOneWidget);
      expect(find.text('Work Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('1-Tap Demo Credentials'), findsOneWidget);
    });

    testWidgets('tapping quick demo chip updates credentials', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(TestAuthRepository()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Supervisor' chip
      await tester.tap(find.text('Supervisor'));
      await tester.pumpAndSettle();

      expect(find.text('supervisor@demo.com'), findsOneWidget);
    });
  });
}
