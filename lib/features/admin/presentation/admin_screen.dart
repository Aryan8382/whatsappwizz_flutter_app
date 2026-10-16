import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/repositories/admin_api_repository.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/skeleton_list.dart';
import '../../../shared/widgets/status_badge.dart';

final adminRepoProvider = Provider<AdminApiRepository>((ref) {
  return AdminApiRepository();
});

final organizationsProvider = FutureProvider.autoDispose<List<OrgModel>>((ref) async {
  return ref.watch(adminRepoProvider).getOrganizations();
});

final auditLogsProvider = FutureProvider.autoDispose<List<AuditLogModel>>((ref) async {
  return ref.watch(adminRepoProvider).getAuditLogs();
});

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgsAsync = ref.watch(organizationsProvider);
    final logsAsync = ref.watch(auditLogsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('System Administration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Organizations Section
            Text('Organizations', style: AppTypography.titleMedium),
            const SizedBox(height: 10),
            orgsAsync.when(
              loading: () => const SkeletonList(count: 2, itemHeight: 70),
              error: (err, _) => Center(child: Text('Error loading organizations: $err')),
              data: (orgs) {
                if (orgs.isEmpty) {
                  return const Text('No organizations found', style: TextStyle(color: AppColors.textMuted));
                }
                return Column(
                  children: orgs.map((o) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _OrgCard(name: o.name, slug: o.slug, plan: o.plan, users: o.usersCount),
                  )).toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            // Audit Logs
            Text('Live Audit Trail Logs', style: AppTypography.titleMedium),
            const SizedBox(height: 10),
            logsAsync.when(
              loading: () => const SkeletonList(count: 3, itemHeight: 45),
              error: (err, _) => Center(child: Text('Error loading audit logs: $err')),
              data: (logs) {
                if (logs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadii.border2xl,
                      border: Border.all(color: const Color(0x3322C55E)),
                    ),
                    child: const Center(
                      child: Text('No audit logs recorded yet', style: TextStyle(color: AppColors.textMuted)),
                    ),
                  );
                }

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadii.border2xl,
                    border: Border.all(color: const Color(0x3322C55E)),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < logs.length; i++) ...[
                        if (i > 0) const Divider(height: 16),
                        _LogItem(
                          action: logs[i].action,
                          user: logs[i].user,
                          time: _timeAgo(logs[i].createdAt),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _OrgCard extends StatelessWidget {
  final String name;
  final String slug;
  final String plan;
  final int users;

  const _OrgCard({
    required this.name,
    required this.slug,
    required this.plan,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.border2xl,
        border: Border.all(color: const Color(0x3322C55E)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.g50,
              borderRadius: AppRadii.borderMd,
            ),
            child: const Icon(LucideIcons.building, color: AppColors.g700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.titleMedium.copyWith(fontSize: 14.5)),
                Text(slug.isNotEmpty ? 'Slug: $slug • $users active members' : '$users active member',
                    style: AppTypography.bodySmall),
              ],
            ),
          ),
          StatusBadge(status: 'active', label: plan),
        ],
      ),
    );
  }
}

class _LogItem extends StatelessWidget {
  final String action;
  final String user;
  final String time;

  const _LogItem({required this.action, required this.user, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(action, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(user, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
        ),
        Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }
}
