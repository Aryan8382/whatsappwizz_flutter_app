import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/repositories/campaigns_api_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/animated_entrance.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_list.dart';
import '../../../shared/widgets/status_badge.dart';
import '../domain/campaign.dart';
import '../domain/campaigns_repository.dart';
import 'widgets/add_campaign_sheet.dart';
import 'widgets/campaign_analytics_sheet.dart';
import 'widgets/campaign_wizard_sheet.dart';

final campaignsRepositoryProvider = Provider<CampaignsRepository>((ref) {
  return CampaignsApiRepository();
});

final campaignsProvider = FutureProvider.autoDispose<List<Campaign>>((ref) async {
  final repo = ref.watch(campaignsRepositoryProvider);
  // Auto-refresh running broadcast campaigns every 8 seconds
  final timer = Timer(const Duration(seconds: 8), () {
    ref.invalidateSelf();
  });
  ref.onDispose(() => timer.cancel());
  return repo.getCampaigns();
});

class CampaignsScreen extends ConsumerWidget {
  const CampaignsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(campaignsProvider);
    final repo = ref.watch(campaignsRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: RefreshIndicator(
        color: AppColors.g600,
        onRefresh: () async => ref.invalidate(campaignsProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 116),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Broadcasts', style: AppTypography.displayMedium),
                        Text('Mass WhatsApp campaigns', style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      CampaignWizardSheet.show(
                        context,
                        onLaunch: (camp) async {
                          await repo.createCampaign(camp);
                          ref.invalidate(campaignsProvider);
                          ToastService.success('Broadcast campaign launched');
                        },
                      );
                    },
                    icon: const Icon(AppIcons.add, size: 18),
                    label: const Text('New Campaign'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Wallet Balance Alert Card (per spec: wallet-low warnings)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.g50,
                  borderRadius: AppRadii.borderXl,
                  border: Border.all(color: AppColors.g200),
                ),
                child: Row(
                  children: [
                    const Icon(AppIcons.wallet, size: 20, color: AppColors.g700),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WABA Wallet Balance: ₹5,000.00',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.g950),
                          ),
                          Text(
                            'Sufficient credits for ~6,410 marketing messages',
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/wallet'),
                      child: const Text('Top Up', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Campaign Cards
              campaignsAsync.when(
                loading: () => const SkeletonList.cards(count: 3),
                error: (err, _) => Center(child: Text('Error loading campaigns: $err')),
                data: (campaigns) {
                  if (campaigns.isEmpty) {
                    return EmptyState(
                      icon: AppIcons.broadcasts,
                      title: 'No broadcast campaigns',
                      message: 'Schedule your first broadcast to reach customers in bulk',
                      actionLabel: 'Create Broadcast',
                      onAction: () {
                        CampaignWizardSheet.show(
                          context,
                          onLaunch: (camp) async {
                            await repo.createCampaign(camp);
                            ref.invalidate(campaignsProvider);
                          },
                        );
                      },
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: campaigns.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final c = campaigns[index];
                      final progress = c.totalRecipients > 0 ? (c.sentCount / c.totalRecipients) : 0.0;

                      return FadeSlideIn.staggered(
                        index: index,
                        child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppRadii.border2xl,
                          border: Border.all(color: const Color(0x3322C55E)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    c.name,
                                    style: AppTypography.titleMedium.copyWith(fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                StatusBadge(status: c.status.value, label: c.status.label),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${c.audienceSource} • Template: ${c.templateName}',
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 12),

                            // Progress Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: AppColors.g100,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.g600),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${c.sentCount} / ${c.totalRecipients} sent (${(progress * 100).toStringAsFixed(0)}%)',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.g950),
                                ),
                                Text(
                                  'Delivery: ${c.deliveryRate.toStringAsFixed(0)}% · Read: ${c.openRate.toStringAsFixed(0)}%',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Controls Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (c.status == CampaignStatus.running)
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      await repo.pauseCampaign(c.id);
                                      ref.invalidate(campaignsProvider);
                                      ToastService.info('Campaign paused');
                                    },
                                    icon: const Icon(LucideIcons.pause, size: 14),
                                    label: const Text('Pause', style: TextStyle(fontSize: 11)),
                                  )
                                else if (c.status == CampaignStatus.paused)
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      await repo.resumeCampaign(c.id);
                                      ref.invalidate(campaignsProvider);
                                      ToastService.success('Campaign resumed');
                                    },
                                    icon: const Icon(LucideIcons.play, size: 14),
                                    label: const Text('Resume', style: TextStyle(fontSize: 11)),
                                  ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => CampaignAnalyticsSheet.show(context, c),
                                  icon: const Icon(LucideIcons.barChart2, size: 14),
                                  label: const Text('Analytics', style: TextStyle(fontSize: 11)),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 76),
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.g600,
          foregroundColor: Colors.white,
          icon: const Icon(LucideIcons.plus, size: 20),
          label: const Text('New Campaign', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            AddCampaignSheet.show(
              context,
              onSave: (data) {
                ToastService.success('Campaign created');
                ref.invalidate(campaignsProvider);
              },
            );
          },
        ),
      ),
    );
  }
}
