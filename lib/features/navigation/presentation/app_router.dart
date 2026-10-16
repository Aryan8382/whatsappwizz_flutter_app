import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_icons.dart';
import '../../admin/presentation/admin_screen.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/login_screen.dart';
import '../../automation/presentation/automation_screen.dart';
import '../../campaigns/presentation/campaigns_screen.dart';
import '../../chatbot/presentation/chatbot_screen.dart';
import '../../contacts/presentation/contacts_screen.dart';
import '../../custom_fields/presentation/custom_fields_screen.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../dnd/presentation/dnd_screen.dart';
import '../../flows/presentation/flows_screen.dart';
import '../../inbox/presentation/chat_screen.dart';
import '../../inbox/presentation/inbox_screen.dart';
import '../../media/presentation/media_screen.dart';
import '../../placeholder/presentation/module_placeholder_screen.dart';
import '../../reports/presentation/reports_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../template_library/presentation/template_library_screen.dart';
import '../../templates/presentation/templates_screen.dart';
import '../../users/presentation/users_screen.dart';
import '../../wallet/presentation/wallet_screen.dart';
import 'app_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      if (!isAuth && !isLoggingIn) return '/login';
      if (isAuth && isLoggingIn) return '/';
      return null;
    },
    routes: [
      // ─── Login (scale-fade from center) ─────────────────────────────────
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionDuration: AppAnimations.deliberate,
          reverseTransitionDuration: AppAnimations.comfortable,
          transitionsBuilder: AppAnimations.scaleFadeTransition,
        ),
      ),

      // ─── Full-screen Chat (slide in from right) ──────────────────────────
      GoRoute(
        path: '/inbox/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: ChatScreen(conversationId: id),
            transitionDuration: AppAnimations.comfortable,
            reverseTransitionDuration: AppAnimations.standard,
            transitionsBuilder: AppAnimations.slideRightTransition,
          );
        },
      ),

      // ─── App Shell (fade-up for every tab switch) ────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppScaffold(
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          _fadeRoute('/', const DashboardScreen()),
          _fadeRoute('/inbox', const InboxScreen()),
          _fadeRoute('/contacts', const ContactsScreen()),
          _fadeRoute('/campaigns', const CampaignsScreen()),
          _fadeRoute('/templates', const TemplatesScreen()),
          _fadeRoute('/template-library', const TemplateLibraryScreen()),
          _fadeRoute('/chatbot', const ChatbotScreen()),
          _fadeRoute('/flow', const FlowsScreen()),
          _fadeRoute('/automation', const AutomationScreen()),
          _fadeRoute('/custom-fields', const CustomFieldsScreen()),
          _fadeRoute('/media', const MediaScreen()),
          _fadeRoute('/dnd', const DndScreen()),
          _fadeRoute('/reports', const ReportsScreen()),
          _fadeRoute('/wallet', const WalletScreen()),
          _fadeRoute('/users', const UsersScreen()),
          _fadeRoute('/admin', const AdminScreen()),
          _fadeRoute('/settings', const SettingsScreen()),

          // Placeholder Routes
          _fadeRoute('/apps', const ModulePlaceholderScreen(
            title: 'Apps Directory',
            icon: LucideIcons.layoutGrid,
          )),
          _fadeRoute('/business', const ModulePlaceholderScreen(
            title: 'Business Profile',
            icon: LucideIcons.briefcase,
          )),
          _fadeRoute('/catalogue', const ModulePlaceholderScreen(
            title: 'Product Catalogue',
            icon: LucideIcons.package,
          )),
          _fadeRoute('/order-details', const ModulePlaceholderScreen(
            title: 'Order Details',
            icon: LucideIcons.shoppingBag,
          )),
          _fadeRoute('/sim-card', const ModulePlaceholderScreen(
            title: 'SIM Card Management',
            icon: LucideIcons.cpu,
          )),
        ],
      ),
    ],
  );
});

/// Helper: builds a shell GoRoute with the fade-up transition.
GoRoute _fadeRoute(String path, Widget screen) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) => CustomTransitionPage(
      key: state.pageKey,
      child: screen,
      transitionDuration: AppAnimations.standard,
      reverseTransitionDuration: AppAnimations.fast,
      transitionsBuilder: AppAnimations.fadeUpTransition,
    ),
  );
}
