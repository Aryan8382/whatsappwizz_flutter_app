import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/domain/user.dart';
import '../../auth/presentation/auth_controller.dart';
import 'more_drawer.dart';
import 'navigation_progress.dart';
import 'widgets/notifications_sheet.dart';
import 'widgets/premium_bottom_nav_bar.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../campaigns/presentation/campaigns_screen.dart';
import '../../templates/presentation/templates_screen.dart';
import '../../chatbot/presentation/chatbot_screen.dart';
import '../../inbox/presentation/inbox_controller.dart';
import '../../../core/services/notification_service.dart';

class AppScaffold extends ConsumerStatefulWidget {
  final Widget child;
  final String location;

  const AppScaffold({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _lastValidIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshCurrentPage(widget.location);
    }
  }

  @override
  void didUpdateWidget(covariant AppScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location != oldWidget.location) {
      _refreshCurrentPage(widget.location);
    }
  }

  void _refreshCurrentPage(String loc) {
    if (loc == '/' || loc.isEmpty) {
      ref.invalidate(dashboardStatsProvider);
    } else if (loc.startsWith('/inbox')) {
      ref.read(inboxControllerProvider.notifier).loadConversations(silent: true);
    } else if (loc.startsWith('/campaigns')) {
      ref.invalidate(campaignsProvider);
    } else if (loc.startsWith('/templates')) {
      ref.invalidate(templatesProvider);
    } else if (loc.startsWith('/chatbot')) {
      ref.invalidate(chatbotFlowsProvider);
    }
  }

  int _calculateSelectedIndex(String loc) {
    if (loc == '/' || loc.isEmpty) return 0;
    if (loc.startsWith('/chatbot')) return 1;
    if (loc.startsWith('/inbox')) return 2;
    if (loc.startsWith('/templates') || loc.startsWith('/template-library')) return 3;
    if (loc.startsWith('/campaigns') || loc.startsWith('/broadcast')) return 4;
    return -1; // secondary route in drawer
  }

  void _onItemTapped(int index) {
    _lastValidIndex = index;
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/chatbot');
        break;
      case 2:
        context.go('/inbox');
        break;
      case 3:
        context.go('/templates');
        break;
      case 4:
        context.go('/campaigns');
        break;
    }
  }

  void _showRoleSwitchDialog(User user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.border3xl),
        title: const Text('Switch Role (Demo Testing)', style: AppTypography.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values.map((role) {
            final isSelected = user.role == role;
            return ListTile(
              leading: Icon(
                isSelected ? AppIcons.checkCircle : AppIcons.shield,
                color: isSelected ? AppColors.g600 : AppColors.textMuted,
                size: 20,
              ),
              title: Text(role.displayName),
              subtitle: Text(role.value, style: const TextStyle(fontSize: 11)),
              onTap: () {
                ref.read(authControllerProvider.notifier).switchRoleForDemo(role);
                Navigator.of(ctx).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final inboxState = ref.watch(inboxControllerProvider);
    final notifState = ref.watch(notificationProvider);
    final totalUnread = inboxState.conversations.fold<int>(0, (sum, c) => sum + c.unreadCount);
    final selectedIndex = _calculateSelectedIndex(widget.location);
    if (selectedIndex != -1) {
      _lastValidIndex = selectedIndex;
    }
    final isInboxChat = widget.location.startsWith('/inbox/') && widget.location != '/inbox';

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      drawer: MoreDrawer(
        currentUser: user,
        currentRoute: widget.location,
      ),
      appBar: isInboxChat
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(64), // 62px header + 2px navigation progress
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // Liquid Glass Header (Apple liquid glass styling matching bottom navigation bar)
                      Expanded(
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                // Apple Clear Liquid Glass outer container matching bottom navbar
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withOpacity(0.88),
                                    Colors.white.withOpacity(0.70),
                                    Colors.white.withOpacity(0.58),
                                  ],
                                  stops: const [0.0, 0.40, 1.0],
                                ),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.white.withOpacity(0.85),
                                    width: 0.85,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F172A).withOpacity(0.04),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.60),
                                    blurRadius: 1.2,
                                    offset: const Offset(0, 1),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Menu Button: Apple Liquid Glass Pod
                                  _GlassIconPod(
                                    tooltip: 'Open Menu',
                                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                                    icon: const Icon(
                                      Icons.menu_rounded,
                                      color: Color(0xFF16A34A),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Logo: original asset and aspect ratio preserved
                                  Image.asset(
                                    'assets/images/logo.png',
                                    height: 28,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Text(
                                      'WhatsApp Wiz',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.g700,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),

                                  const Spacer(),

                                  if (user != null) ...[
                                    // Notifications: Apple Liquid Glass Pod with real-time unread badge
                                    _GlassIconPod(
                                      tooltip: 'Notifications',
                                      onTap: () => NotificationsSheet.show(context),
                                      icon: Icon(
                                        notifState.unreadCount > 0
                                            ? Icons.notifications_active_rounded
                                            : Icons.notifications_none_rounded,
                                        color: const Color(0xFF16A34A),
                                        size: 22,
                                      ),
                                      badge: notifState.unreadCount > 0
                                          ? Positioned(
                                              top: 2,
                                              right: 2,
                                              child: Container(
                                                padding: const EdgeInsets.all(2.5),
                                                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF22C55E),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(0xFF22C55E).withOpacity(0.55),
                                                      blurRadius: 3,
                                                      offset: const Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    notifState.unreadCount > 9 ? '9+' : '${notifState.unreadCount}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8.5,
                                                      fontWeight: FontWeight.bold,
                                                      height: 1,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 10),

                                    // User Avatar: 36px glossy jewel sphere with emerald gradient & profile menu
                                    PopupMenuButton<String>(
                                      offset: const Offset(0, 48),
                                      shape: RoundedRectangleBorder(borderRadius: AppRadii.border2xl),
                                      tooltip: 'Account Menu',
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF4ADE80), // radiant light green specular highlight
                                              Color(0xFF22C55E), // primary brand emerald
                                              Color(0xFF15803D), // deep jewel green
                                            ],
                                            stops: [0.0, 0.45, 1.0],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF15803D).withOpacity(0.35),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                            BoxShadow(
                                              color: Colors.white.withOpacity(0.70),
                                              blurRadius: 1.5,
                                              offset: const Offset(0, -1),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.85),
                                            width: 1.2,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.2,
                                            shadows: [
                                              Shadow(
                                                color: Color(0x33000000),
                                                offset: Offset(0, 1),
                                                blurRadius: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  itemBuilder: (ctx) => [
                                    PopupMenuItem(
                                      enabled: false,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(user.fullName, style: AppTypography.labelLarge),
                                          Text(user.email, style: AppTypography.bodySmall),
                                          if (user.orgName != null) ...[
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.g100,
                                                borderRadius: AppRadii.borderSm,
                                                border: Border.all(color: AppColors.g300, width: 1),
                                              ),
                                              child: Text(
                                                user.orgName!,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.g800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const PopupMenuDivider(),
                                    PopupMenuItem(
                                      value: 'role',
                                      child: Row(
                                        children: [
                                          const Icon(AppIcons.shield, size: 18, color: AppColors.g700),
                                          const SizedBox(width: 10),
                                          Text('Role: ${user.role.displayName}'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'settings',
                                      child: Row(
                                        children: [
                                          Icon(AppIcons.settings, size: 18),
                                          SizedBox(width: 10),
                                          Text('Settings'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'logout',
                                      child: Row(
                                        children: [
                                          Icon(AppIcons.logout, size: 18, color: AppColors.statusRedText),
                                          SizedBox(width: 10),
                                          Text('Sign Out', style: TextStyle(color: AppColors.statusRedText)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (val) {
                                    if (val == 'role') {
                                      _showRoleSwitchDialog(user);
                                    } else if (val == 'settings') {
                                      context.push('/settings');
                                    } else if (val == 'logout') {
                                      ref.read(authControllerProvider.notifier).logout();
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const NavigationProgress(),
                ],
              ),
            ),
          ),
        ),
      body: AnimatedSwitcher(
        duration: AppAnimations.standard,
        switchInCurve: AppAnimations.enter,
        switchOutCurve: AppAnimations.exit,
        transitionBuilder: (child, animation) {
          final offsetAnim = Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: AppAnimations.enter));
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offsetAnim, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(widget.location),
          child: widget.child,
        ),
      ),
      bottomNavigationBar: isInboxChat
          ? null
          : PremiumBottomNavBar(
              selectedIndex: selectedIndex == -1 ? _lastValidIndex : selectedIndex,
              onItemSelected: _onItemTapped,
              items: [
                const NavDestinationItem(
                  icon: AppIcons.dashboard,
                  activeIcon: AppIcons.dashboard,
                  label: 'Dashboard',
                ),
                const NavDestinationItem(
                  icon: AppIcons.chatbot,
                  activeIcon: AppIcons.chatbot,
                  label: 'Chatbot',
                ),
                NavDestinationItem(
                  icon: AppIcons.inbox,
                  activeIcon: AppIcons.inbox,
                  label: 'Inbox',
                  badgeCount: totalUnread > 0 ? totalUnread : null,
                ),
                const NavDestinationItem(
                  icon: AppIcons.templates,
                  activeIcon: AppIcons.templates,
                  label: 'Template',
                ),
                const NavDestinationItem(
                  icon: AppIcons.broadcasts,
                  activeIcon: AppIcons.broadcasts,
                  label: 'Broadcast',
                ),
              ],
            ),
    );
  }
}

/// Apple Clear Liquid Glass pod for header action buttons (Menu, Notifications).
/// Uses identical multi-tone refraction gradient, specular highlight borders,
/// and ambient lift as the floating bottom navigation bar.
class _GlassIconPod extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;
  final Widget? badge;
  final String? tooltip;
  final double size = 42; // fixed default, not a constructor parameter

  const _GlassIconPod({
    required this.icon,
    required this.onTap,
    this.badge,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget pod = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          // Ambient soft depth
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
          // Top specular rim reflection
          BoxShadow(
            color: Colors.white.withOpacity(0.90),
            blurRadius: 2,
            offset: const Offset(0, -0.8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              // Multi-tone liquid glass refraction body matching bottom navbar
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.92),
                  Colors.white.withOpacity(0.55),
                  Colors.white.withOpacity(0.78),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.95),
                width: 1.2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: onTap,
                splashColor: const Color(0xFFDCFCE7).withOpacity(0.6),
                highlightColor: Colors.white.withOpacity(0.4),
                child: Center(child: icon),
              ),
            ),
          ),
        ),
      ),
    );

    if (badge != null) {
      pod = Stack(
        clipBehavior: Clip.none,
        children: [
          pod,
          badge!,
        ],
      );
    }

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: pod,
      );
    }

    return pod;
  }
}

