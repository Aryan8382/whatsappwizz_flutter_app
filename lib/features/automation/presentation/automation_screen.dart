import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/repositories/automation_api_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/animated_entrance.dart';
import '../../../shared/widgets/app_switch.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_list.dart';

import '../domain/automation_repository.dart';
import '../domain/automation_workflow.dart';
import 'widgets/add_automation_sheet.dart';

final automationRepositoryProvider = Provider<AutomationRepository>((ref) {
  return AutomationApiRepository();
});

final automationWorkflowsProvider =
    FutureProvider.autoDispose<List<AutomationWorkflow>>((ref) async {
  final timer = Timer(const Duration(seconds: 10), () => ref.invalidateSelf());
  ref.onDispose(() => timer.cancel());
  return ref.watch(automationRepositoryProvider).getWorkflows();
});

class AutomationScreen extends ConsumerWidget {
  const AutomationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workflowsAsync = ref.watch(automationWorkflowsProvider);
    final repo = ref.watch(automationRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Event Automation Rules'),
      ),
      body: workflowsAsync.when(
        loading: () => const Center(child: SkeletonList(count: 3, itemHeight: 90)),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (workflows) {
          if (workflows.isEmpty) {
            return const EmptyState(
              icon: AppIcons.automation,
              title: 'No automation workflows',
              message: 'Trigger auto-replies, assignments and tags on events',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            itemCount: workflows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final w = workflows[index];
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
                            w.name,
                            style: AppTypography.titleMedium.copyWith(fontSize: 15),
                          ),
                        ),
                        AppSwitch(
                          value: w.isActive,
                          onChanged: (newVal) async {
                            await repo.toggleActive(w.id, newVal);
                            ref.invalidate(automationWorkflowsProvider);
                            ToastService.success(
                              newVal ? 'Automation rule enabled' : 'Automation rule paused',
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(LucideIcons.zap, size: 14, color: AppColors.g700),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'When: ${w.triggerEvent}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.arrowRight, size: 14, color: AppColors.waTeal),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Then: ${w.actionType}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Executed ${w.executionCount} times',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.statusRedText),
                          tooltip: 'Delete Workflow',
                          onPressed: () async {
                            final ok = await ConfirmDialog.show(
                              context: context,
                              title: 'Delete Automation',
                              message: 'Are you sure you want to delete "${w.name}"?',
                              confirmLabel: 'Delete',
                            );
                            if (ok == true) {
                              try {
                                await repo.deleteWorkflow(w.id);
                                ref.invalidate(automationWorkflowsProvider);
                                ToastService.success('Workflow deleted');
                              } catch (e) {
                                ToastService.error('Failed to delete: $e');
                              }
                            }
                          },
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 76),
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.g600,
          foregroundColor: Colors.white,
          icon: const Icon(LucideIcons.plus, size: 20),
          label: const Text('New Automation', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            AddAutomationSheet.show(
              context,
              onSave: (data) async {
                try {
                  await repo.createWorkflow(data);
                  ToastService.success('Automation rule created');
                  ref.invalidate(automationWorkflowsProvider);
                } catch (e) {
                  ToastService.error('Failed to create workflow: $e');
                }
              },
            );
          },
        ),
      ),
    );
  }
}

