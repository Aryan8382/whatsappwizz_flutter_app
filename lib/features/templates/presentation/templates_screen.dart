import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/repositories/templates_api_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/animated_entrance.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_list.dart';
import '../../../shared/widgets/status_badge.dart';
import '../domain/template.dart';
import '../domain/templates_repository.dart';
import 'widgets/add_template_sheet.dart';
import 'widgets/template_builder_sheet.dart';

final templatesRepositoryProvider = Provider<TemplatesRepository>((ref) {
  return TemplatesApiRepository();
});

final templatesProvider = FutureProvider.autoDispose<List<Template>>((ref) async {
  final timer = Timer(const Duration(seconds: 12), () => ref.invalidateSelf());
  ref.onDispose(() => timer.cancel());
  final repo = ref.watch(templatesRepositoryProvider);
  return repo.getTemplates();
});

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesProvider);
    final repo = ref.watch(templatesRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 480;
                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Templates', style: AppTypography.displayMedium),
                      const SizedBox(height: 2),
                      Text(
                        'Meta approved message templates',
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                ToastService.info('Syncing templates with Meta WABA...');
                                await repo.syncWithMeta();
                                ref.invalidate(templatesProvider);
                                ToastService.success('Templates synchronized with Meta');
                              },
                              icon: const Icon(AppIcons.sync, size: 15),
                              label: const Text('Sync Meta', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                TemplateBuilderSheet.show(
                                  context,
                                  onSave: (tpl) async {
                                    await repo.createTemplate(tpl);
                                    ref.invalidate(templatesProvider);
                                    ToastService.success('Template draft created');
                                  },
                                );
                              },
                              icon: const Icon(AppIcons.add, size: 16),
                              label: const Text('New Template', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.g600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Templates', style: AppTypography.displayMedium),
                          const SizedBox(height: 2),
                          Text(
                            'Meta approved message templates',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        ToastService.info('Syncing templates with Meta WABA...');
                        await repo.syncWithMeta();
                        ref.invalidate(templatesProvider);
                        ToastService.success('Templates synchronized with Meta');
                      },
                      icon: const Icon(AppIcons.sync, size: 15),
                      label: const Text('Sync Meta', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        TemplateBuilderSheet.show(
                          context,
                          onSave: (tpl) async {
                            await repo.createTemplate(tpl);
                            ref.invalidate(templatesProvider);
                            ToastService.success('Template draft created');
                          },
                        );
                      },
                      icon: const Icon(AppIcons.add, size: 16),
                      label: const Text('New Template', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.g600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          Expanded(
            child: templatesAsync.when(
              loading: () => const SingleChildScrollView(child: SkeletonList.cards(count: 4)),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (templates) {
          if (templates.isEmpty) {
            return EmptyState(
              icon: AppIcons.templates,
              title: 'No templates created',
              message: 'Create approved WhatsApp templates for broadcast campaigns and notifications',
              actionLabel: 'Create Template',
              onAction: () {
                TemplateBuilderSheet.show(
                  context,
                  onSave: (tpl) async {
                    await repo.createTemplate(tpl);
                    ref.invalidate(templatesProvider);
                    ToastService.success('Template draft created');
                  },
                );
              },
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            itemCount: templates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tpl = templates[index];
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
                            tpl.name,
                            style: AppTypography.titleMedium.copyWith(fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        StatusBadge(
                          status: tpl.status.value,
                          label: tpl.status.label,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.g50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tpl.category,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.g800),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Lang: ${tpl.language.toUpperCase()}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      tpl.body,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tpl.status == TemplateStatus.draft) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await repo.submitForApproval(tpl.id);
                            ref.invalidate(templatesProvider);
                            ToastService.success('Submitted to Meta for review');
                          },
                          icon: const Icon(AppIcons.send, size: 14),
                          label: const Text('Submit to Meta', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
          );
        },
        ),
      ),
    ],
  ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 76),
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.g600,
          foregroundColor: Colors.white,
          icon: const Icon(AppIcons.add),
          label: const Text('New Template', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            TemplateBuilderSheet.show(
              context,
              onSave: (tpl) async {
                await repo.createTemplate(tpl);
                ref.invalidate(templatesProvider);
                ToastService.success('Template draft created');
              },
            );
          },

        ),
      ),
    );
  }
}
