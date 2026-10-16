import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../shared/services/toast_service.dart';
import '../../auth/domain/user.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../inbox/presentation/inbox_controller.dart';

class NavCategory {
  final String title;
  final List<NavItem> items;

  const NavCategory({
    required this.title,
    required this.items,
  });
}

class NavItem {
  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
  final Color accentColor;
  final List<UserRole>? allowedRoles;
  final bool isPlaceholder;
  final String? badgeText;
  final Color? badgeColor;

  const NavItem({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.accentColor,
    this.allowedRoles,
    this.isPlaceholder = false,
    this.badgeText,
    this.badgeColor,
  });
}

class MoreDrawer extends ConsumerStatefulWidget {
  final User? currentUser;
  final String? currentRoute;

  const MoreDrawer({
    super.key,
    this.currentUser,
    this.currentRoute,
  });

  @override
  ConsumerState<MoreDrawer> createState() => _MoreDrawerState();
}

class _MoreDrawerState extends ConsumerState<MoreDrawer> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const List<NavCategory> _categories = [
    NavCategory(
      title: 'CORE WORKSPACE',
      items: [
        NavItem(
          title: 'Dashboard',
          subtitle: 'Real-time KPIs & activity',
          route: '/',
          icon: AppIcons.dashboard,
          accentColor: Color(0xFF10B981),
        ),
        NavItem(
          title: 'Live Inbox',
          subtitle: 'Multi-agent chat console',
          route: '/inbox',
          icon: AppIcons.inbox,
          accentColor: Color(0xFF059669),
        ),
        NavItem(
          title: 'Campaigns',
          subtitle: 'Bulk WhatsApp broadcasts',
          route: '/campaigns',
          icon: AppIcons.broadcasts,
          accentColor: Color(0xFF0D9488),
        ),
      ],
    ),
    NavCategory(
      title: 'AUDIENCE & MESSAGING',
      items: [
        NavItem(
          title: 'Contacts & Audience',
          subtitle: 'Import, tags & segments',
          route: '/contacts',
          icon: AppIcons.contacts,
          accentColor: Color(0xFF0284C7),
        ),
        NavItem(
          title: 'Message Templates',
          subtitle: 'Meta-approved WABA templates',
          route: '/templates',
          icon: AppIcons.templates,
          accentColor: Color(0xFF2563EB),
          allowedRoles: [UserRole.superAdmin, UserRole.orgAdmin, UserRole.supervisor],
        ),
        NavItem(
          title: 'Template Library',
          subtitle: 'Ready-to-use industry presets',
          route: '/template-library',
          icon: LucideIcons.bookOpen,
          accentColor: Color(0xFF4F46E5),
          allowedRoles: [UserRole.superAdmin, UserRole.orgAdmin, UserRole.supervisor],
        ),
      ],
    ),
    NavCategory(
      title: 'AUTOMATION STUDIO',
      items: [
        NavItem(
          title: 'Chatbot Builder',
          subtitle: 'Visual conversational bots',
          route: '/chatbot',
          icon: AppIcons.chatbot,
          accentColor: Color(0xFF7C3AED),
          badgeText: 'AI BOT',
          badgeColor: Color(0xFF7C3AED),
          allowedRoles: [UserRole.superAdmin, UserRole.orgAdmin, UserRole.supervisor],
        ),
        NavItem(
          title: 'WhatsApp Flows',
          subtitle: 'Interactive forms & catalogs',
          route: '/flow',
          icon: AppIcons.flows,
          accentColor: Color(0xFF9333EA),
          badgeText: 'META',
          badgeColor: Color(0xFF9333EA),
          allowedRoles: [UserRole.superAdmin, UserRole.orgAdmin, UserRole.supervisor],
        ),
        NavItem(
          title: 'Automation Rules',
          subtitle: 'Triggers, keywords & auto-replies',
          route: '/automation',
          icon: AppIcons.automation,
          accentColor: Color(0xFFD97706),
          allowedRoles: [UserRole.superAdmin, UserRole.orgAdmin, UserRole.supervisor],
        ),
        NavItem(
          title: 'Custom Fields',
          subtitle: 'Dynamic contact attributes',
          route: '/custom-fields',
          icon: AppIcons.customFields,
          accentColor: Color(0xFFEA580C),
          allowedRoles: [UserRole.superAdmin, UserRole.orgAdmin],
        ),
      ],
    ),
    NavCategory(
      title: 'MEDIA & COMPLIANCE',
      items: [
        NavItem(
          title: 'Media Gallery',
          subtitle: 'Images, PDFs, audio assets',
          route: '/media',
          icon: AppIcons.media,
          accentColor: Color(0xFF0891B2),
        ),
        NavItem(
          title: 'DND Manager',
          subtitle: 'Opt-out list & opt-in records',
          route: '/dnd',
          icon: AppIcons.dnd,
          accentColor: Color(0xFFE11D48),
        ),
      ],
    ),
    NavCategory(
      title: 'ADMIN & FINANCE',
      items: [
        NavItem(
          title: 'Wallet & Billing',
          subtitle: 'Balance, rates & invoices',
          route: '/wallet',
          icon: AppIcons.wallet,
          accentColor: Color(0xFF16A34A),
          allowedRoles: [UserRole.superAdmin, UserRole.orgAdmin, UserRole.supervisor, UserRole.reseller],
        ),
        NavItem(
          title: 'Analytics & Reports',
          subtitle: 'Delivery rates, costs & CTR',
          route: '/reports',
          icon: AppIcons.reports,
          accentColor: Color(0xFF0284C7),
          allowedRoles: [UserRole.superAdmin, UserRole.orgAdmin, UserRole.supervisor, UserRole.reseller],
        ),
        NavItem(
          title: 'Team & Staff',
          subtitle: 'Manage agent seats & roles',
          route: '/users',
          icon: LucideIcons.userCheck,
          accentColor: Color(0xFF475569),
          allowedRoles: [UserRole.superAdmin, UserRole.orgAdmin, UserRole.supervisor],
        ),
        NavItem(
          title: 'Settings & WABA',
          subtitle: 'API keys, webhooks & numbers',
          route: '/settings',
          icon: AppIcons.settings,
          accentColor: Color(0xFF334155),
          allowedRoles: [UserRole.superAdmin, UserRole.orgAdmin],
        ),
        NavItem(
          title: 'System Admin',
          subtitle: 'Platform-level tenant controls',
          route: '/admin',
          icon: AppIcons.shield,
          accentColor: Color(0xFFDC2626),
          badgeText: 'SUPER',
          badgeColor: Color(0xFFDC2626),
          allowedRoles: [UserRole.superAdmin],
        ),
      ],
    ),
    NavCategory(
      title: 'ECOSYSTEM (EXPANDING)',
      items: [
        NavItem(
          title: 'Apps Directory',
          subtitle: 'Integrations & webhooks marketplace',
          route: '/apps',
          icon: LucideIcons.layoutGrid,
          accentColor: Color(0xFF64748B),
          isPlaceholder: true,
        ),
        NavItem(
          title: 'Business Profile',
          subtitle: 'Sync WhatsApp business profile',
          route: '/business',
          icon: LucideIcons.briefcase,
          accentColor: Color(0xFF64748B),
          isPlaceholder: true,
        ),
        NavItem(
          title: 'Product Catalogue',
          subtitle: 'Meta Commerce manager items',
          route: '/catalogue',
          icon: LucideIcons.package,
          accentColor: Color(0xFF64748B),
          isPlaceholder: true,
        ),
        NavItem(
          title: 'Order Details',
          subtitle: 'Catalog orders & cart updates',
          route: '/order-details',
          icon: LucideIcons.shoppingBag,
          accentColor: Color(0xFF64748B),
          isPlaceholder: true,
        ),
        NavItem(
          title: 'SIM Card Management',
          subtitle: 'Virtual numbers & cellular SIMs',
          route: '/sim-card',
          icon: LucideIcons.cpu,
          accentColor: Color(0xFF64748B),
          isPlaceholder: true,
        ),
      ],
    ),
  ];


  void _confirmLogout(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(AppIcons.logout, color: Color(0xFFDC2626), size: 22),
            SizedBox(width: 10),
            Text('Sign Out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Are you sure you want to end your current session? You will need your credentials to log back in.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop(); // Close dialog
              Navigator.of(context).pop(); // Close drawer
              final router = GoRouter.of(context);
              await ref.read(authControllerProvider.notifier).logout();
              router.go('/login');
              ToastService.info('Signed out successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.currentUser?.role ?? UserRole.agent;
    final inboxState = ref.watch(inboxControllerProvider);
    final totalUnread = inboxState.conversations.fold<int>(0, (sum, c) => sum + c.unreadCount);

    final filteredCategories = <NavCategory>[];

    for (final cat in _categories) {
      final visibleItems = cat.items.where((item) {
        if (item.allowedRoles != null && !item.allowedRoles!.contains(role)) {
          return false;
        }
        if (_searchQuery.trim().isNotEmpty) {
          final q = _searchQuery.toLowerCase().trim();
          final titleMatch = item.title.toLowerCase().contains(q);
          final subMatch = item.subtitle.toLowerCase().contains(q);
          return titleMatch || subMatch;
        }
        return true;
      }).toList();

      if (visibleItems.isNotEmpty) {
        filteredCategories.add(NavCategory(title: cat.title, items: visibleItems));
      }
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = (screenWidth * 0.85).clamp(290.0, 340.0);

    return Drawer(
      width: drawerWidth,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 16,
      child: Column(
        children: [
          // ─── Header: Obsidian Emerald Brand & User Card ───
          _buildHeroHeader(context, role),

          // ─── Search Bar ───
          _buildSearchBar(),

          // ─── Categorized Navigation List ───
          Expanded(
            child: filteredCategories.isEmpty
                ? _buildEmptySearchState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, catIndex) {
                      final category = filteredCategories[catIndex];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 14, 10, 6),
                            child: Row(
                              children: [
                                Text(
                                  category.title,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.9,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...category.items.map((item) {
                            return _buildNavTile(
                              context: context,
                              item: item,
                              unreadCount: item.route == '/inbox' ? totalUnread : 0,
                            );
                          }),
                        ],
                      );
                    },
                  ),
          ),

          // ─── Footer: Status & Sign Out ───
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, UserRole role) {
    final user = widget.currentUser;
    final displayName = user?.fullName.isNotEmpty == true ? user!.fullName : (user?.email ?? 'Agent');
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'W';
    final orgName = user?.orgName ?? 'WhatsApp Wiz Org';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF062E1E), // Deep Obsidian Emerald
            Color(0xFF0F472F),
            Color(0xFF047857), // Vivid Emerald accent
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Brand Line + Close Button
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2)),
                      ],
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Image.asset(
                      'assets/images/logo.png',
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.chat_rounded,
                        color: Color(0xFF059669),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WhatsApp Wiz',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Cloud API v20.0 • Meta Partner',
                          style: TextStyle(
                            color: Color(0xFF86EFAC),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                    ),
                    splashRadius: 20,
                    tooltip: 'Close Menu',
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // User Info Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFF047857),
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF062E1E), width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  role.displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  orgName,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.80),
                                    fontSize: 10.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 9),
          hintText: 'Search modules & tools...',
          hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF64748B)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
        ),
        onChanged: (val) {
          setState(() => _searchQuery = val);
        },
      ),
    );
  }

  Widget _buildNavTile({
    required BuildContext context,
    required NavItem item,
    int unreadCount = 0,
  }) {
    final currentRoute = widget.currentRoute ?? '';
    final isSelected = currentRoute == item.route ||
        (item.route != '/' && currentRoute.startsWith(item.route));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Material(
        color: isSelected ? const Color(0xFFECFDF5) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: item.accentColor.withOpacity(0.12),
          highlightColor: item.accentColor.withOpacity(0.06),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
            context.push(item.route);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFFA7F3D0) : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon squircle badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? item.accentColor
                        : item.accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: item.accentColor.withOpacity(0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    item.icon,
                    size: 19,
                    color: isSelected ? Colors.white : item.accentColor,
                  ),
                ),
                const SizedBox(width: 11),

                // Title + Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF065F46)
                              : const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? const Color(0xFF047857).withOpacity(0.85)
                              : const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Trailing Badges or Indicators
                if (unreadCount > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ] else if (item.badgeText != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (item.badgeColor ?? item.accentColor).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: (item.badgeColor ?? item.accentColor).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      item.badgeText!,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: item.badgeColor ?? item.accentColor,
                      ),
                    ),
                  ),
                ] else if (item.isPlaceholder) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: const Text(
                      'SOON',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ] else if (isSelected) ...[
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: Color(0xFF10B981),
                  ),
                ] else ...[
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Color(0xFFCBD5E1),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded, size: 32, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 12),
            const Text(
              'No modules found',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 4),
            Text(
              'No results for "$_searchQuery". Try another keyword.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Sign out button
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => _confirmLogout(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCA5A5).withOpacity(0.7)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(AppIcons.logout, size: 16, color: Color(0xFFDC2626)),
                    SizedBox(width: 8),
                    Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Health Status & Version
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Meta Graph API Online',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const Text(
                  'v2.4.2 (WABA)',
                  style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
