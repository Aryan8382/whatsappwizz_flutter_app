import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/animated_entrance.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/skeleton_list.dart';
import '../../../shared/widgets/status_badge.dart';
import '../data/api_dashboard_repository.dart';
import '../domain/dashboard_repository.dart';
import '../domain/dashboard_stats.dart';
import 'widgets/analytics_chart.dart';
import 'widgets/savings_tracker_card.dart';
import 'widgets/stat_card.dart';

/// Dashboard repository — uses real backend API from working-project2
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return ApiDashboardRepository();
});

final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  // Auto-refresh dashboard metrics every 15 seconds
  final timer = Timer(const Duration(seconds: 15), () {
    ref.invalidateSelf();
  });
  ref.onDispose(() => timer.cancel());
  return repo.getDashboardStats();
});

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _showAllMetrics = false;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: RefreshIndicator(
        color: AppColors.g600,
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          await ref.read(dashboardStatsProvider.future);
        },
        child: statsAsync.when(
          loading: () => const SingleChildScrollView(
            child: SkeletonList.stats(),
          ),
          error: (err, stack) => ErrorState(
            message: err.toString(),
            onRetry: () => ref.refresh(dashboardStatsProvider),
          ),
          data: (stats) => FadeSlideIn(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 116),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome / Overview Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dashboard', style: AppTypography.displayMedium),
                          const SizedBox(height: 2),
                          Text(
                            'Live WhatsApp Business overview',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/wallet'),
                        icon: const Icon(AppIcons.wallet, size: 16),
                        label: Text('₹${stats.walletBalance.toStringAsFixed(0)}'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 24H Savings Tracker Card
                  SavingsTrackerCard(
                    costSavedInr: stats.costSavedInr,
                    freeMessages: stats.freeWindowMessages,
                    resolutionRate: stats.windowResolutionRate,
                    metaFeesCharged: stats.metaFeesCharged,
                  ),
                  const SizedBox(height: 18),

                  // Core Performance Metrics (Primary High-Priority KPIs)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Core Performance',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        _showAllMetrics ? '8 of 8 metrics' : '4 key highlights',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Row 1: Conversations & Messages Sent
                  FadeSlideIn.staggered(
                    index: 0,
                    child: Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Conversations',
                            value: stats.totalConversations.toString(),
                            icon: AppIcons.inbox,
                            iconColor: AppColors.g600,
                            subtitle: 'All channels',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Messages Sent',
                            value: stats.messagesSent.toString(),
                            icon: AppIcons.send,
                            iconColor: AppColors.waTeal,
                            subtitle: 'Last 30 days',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Row 2: Delivery Rate & Read Rate
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Delivery Rate',
                          value: '${stats.deliveredRate.toStringAsFixed(1)}%',
                          icon: LucideIcons.checkCheck,
                          iconColor: AppColors.g700,
                          subtitle: '${stats.messagesDelivered} delivered',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          title: 'Read Rate',
                          value: '${stats.readRate.toStringAsFixed(1)}%',
                          icon: LucideIcons.eye,
                          iconColor: AppColors.g600,
                          subtitle: '${stats.messagesRead} opened',
                        ),
                      ),
                    ],
                  ),

                  // Expandable Secondary Metrics
                  AnimatedCrossFade(
                    firstChild: const SizedBox(height: 0),
                    secondChild: Column(
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: 'Open Chats',
                                value: stats.activeConversations.toString(),
                                icon: AppIcons.messageCircle,
                                iconColor: AppColors.g700,
                                subtitle: 'Active now',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                title: 'Inbound Received',
                                value: stats.messagesReceived.toString(),
                                icon: AppIcons.arrowDownLeft,
                                iconColor: AppColors.g600,
                                subtitle: 'Inbound traffic',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: 'Active Campaigns',
                                value: stats.activeCampaigns.toString(),
                                icon: AppIcons.broadcasts,
                                iconColor: AppColors.g800,
                                subtitle: 'Running live',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                title: 'Wallet Balance',
                                value: '₹${stats.walletBalance.toStringAsFixed(0)}',
                                icon: AppIcons.wallet,
                                iconColor: AppColors.waTeal,
                                subtitle: 'Available INR',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    crossFadeState: _showAllMetrics ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                  ),

                  const SizedBox(height: 10),

                  // Toggle Button for Density Control
                  Center(
                    child: TextButton.icon(
                      onPressed: () => setState(() => _showAllMetrics = !_showAllMetrics),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.g700,
                        backgroundColor: AppColors.g50.withOpacity(0.7),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.borderFull,
                          side: const BorderSide(color: Color(0x3322C55E)),
                        ),
                      ),
                      icon: Icon(
                        _showAllMetrics ? AppIcons.chevronDown : AppIcons.chevronRight,
                        size: 16,
                      ),
                      label: Text(
                        _showAllMetrics
                            ? 'Collapse secondary metrics'
                            : 'Show 4 more metrics (Chats, Inbound, etc.)',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                // Activity Chart (14 days)
                AnalyticsChart(metrics: stats.hourlyMetrics),
                const SizedBox(height: 16),

                // Active Campaigns Card (Web Parity)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadii.border2Xl,
                    border: Border.all(color: const Color(0x1F22C55E), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Active Campaigns',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/campaigns'),
                            child: const Text(
                              'View all',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.g600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...stats.recentCampaigns.map((camp) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.g50.withOpacity(0.5),
                              borderRadius: AppRadii.borderLg,
                              border: Border.all(color: AppColors.g200, width: 0.8),
                            ),
                            child: Row(
                              children: [
                                const Icon(AppIcons.broadcasts, size: 18, color: AppColors.g700),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        camp.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${camp.sentCount} sent',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge(status: camp.status),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Recent Conversations Card (Web Parity)
                Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.border2Xl,
                    side: const BorderSide(color: Color(0x1F22C55E), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Conversations',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/inbox'),
                              child: const Text(
                                'Open Inbox',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.g600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...stats.recentConversations.map((c) => Material(
                              color: Colors.transparent,
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                onTap: () => context.push('/inbox/${c.id}'),
                                leading: AppAvatar(name: c.contactName, radius: 18),
                                title: Text(
                                  c.contactName,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  c.lastMessage,
                                  style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Text(
                                  c.timeAgo,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textFaint),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Action Bar
                Text('Quick Actions', style: AppTypography.titleMedium),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
                        icon: AppIcons.messageCircle,
                        label: 'New Chat',
                        onTap: () => context.go('/inbox'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickActionButton(
                        icon: AppIcons.broadcasts,
                        label: 'Broadcast',
                        onTap: () => context.go('/campaigns'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickActionButton(
                        icon: AppIcons.templates,
                        label: 'Templates',
                        onTap: () => context.push('/templates'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.borderXl,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadii.borderXl,
          border: Border.all(color: const Color(0x3322C55E), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: AppColors.g700),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
