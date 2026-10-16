import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/repositories/flows_api_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/animated_entrance.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_list.dart';
import '../../../shared/widgets/status_badge.dart';
import '../domain/flows_repository.dart';
import '../domain/whatsapp_flow.dart';
import 'widgets/add_flow_sheet.dart';

final flowsRepositoryProvider = Provider<FlowsRepository>((ref) {
  return FlowsApiRepository();
});

final flowsProvider = FutureProvider.autoDispose<List<WhatsappFlow>>((ref) async {
  final timer = Timer(const Duration(seconds: 10), () => ref.invalidateSelf());
  ref.onDispose(() => timer.cancel());
  return ref.watch(flowsRepositoryProvider).getFlows();
});

class FlowsScreen extends ConsumerWidget {
  const FlowsScreen({super.key});

  void _showJsonViewer(BuildContext context, WhatsappFlow flow) {
    String prettyJson = '';
    try {
      if (flow.screens is String) {
        final decoded = jsonDecode(flow.screens);
        prettyJson = const JsonEncoder.withIndent('  ').convert(decoded);
      } else if (flow.screens != null) {
        prettyJson = const JsonEncoder.withIndent('  ').convert(flow.screens);
      } else {
        prettyJson = const JsonEncoder.withIndent('  ').convert({
          'version': '3.0',
          'screens': [
            {
              'id': 'WELCOME',
              'title': flow.name,
              'data': {},
              'layout': {'type': 'SingleColumnLayout', 'children': []}
            }
          ]
        });
      }
    } catch (_) {
      prettyJson = flow.screens?.toString() ?? '{}';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.border2xl),
        title: Row(
          children: [
            const Icon(LucideIcons.code, size: 20, color: AppColors.g700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${flow.name} (JSON)',
                style: AppTypography.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              tooltip: 'Copy JSON',
              icon: const Icon(LucideIcons.copy, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: prettyJson));
                ToastService.success('Flow JSON copied to clipboard');
              },
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          height: 380,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: AppRadii.borderLg,
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                prettyJson,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Color(0xFF38BDF8),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editFlow(BuildContext context, WidgetRef ref, WhatsappFlow flow, FlowsRepository repo) {
    AddFlowSheet.show(
      context,
      initialValue: {
        'name': flow.name,
        'category': flow.category,
        'status': flow.status,
        'health_status': flow.healthStatus,
        'screens': flow.screens is String
            ? flow.screens
            : (flow.screens != null ? jsonEncode(flow.screens) : ''),
      },
      onSave: (data) async {
        try {
          await repo.updateFlow(flow.id, data);
          ref.invalidate(flowsProvider);
          ToastService.success('Flow updated successfully');
        } catch (e) {
          ToastService.error('Failed to update flow: $e');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flowsAsync = ref.watch(flowsProvider);
    final repo = ref.watch(flowsRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('WhatsApp Native Flows'),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 76),
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.g600,
          foregroundColor: Colors.white,
          icon: const Icon(LucideIcons.plus, size: 20),
          label: const Text('New Flow', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            AddFlowSheet.show(
              context,
              onSave: (data) async {
                try {
                  await repo.createFlow(data);
                  ref.invalidate(flowsProvider);
                  ToastService.success('Flow created successfully');
                } catch (e) {
                  ToastService.error('Failed to create flow: $e');
                }
              },
            );
          },
        ),
      ),
      body: flowsAsync.when(
        loading: () => const Center(child: SkeletonList(count: 3, itemHeight: 90)),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (flows) {
          if (flows.isEmpty) {
            return const EmptyState(
              icon: AppIcons.flows,
              title: 'No WhatsApp Flows',
              message: 'Build interactive forms and multi-screen flows directly in WhatsApp',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            itemCount: flows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final flow = flows[index];
              final isPublished = flow.status.toLowerCase() == 'published';

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
                              flow.name,
                              style: AppTypography.titleMedium.copyWith(fontSize: 15),
                            ),
                          ),
                          StatusBadge(
                            status: flow.status.toLowerCase(),
                            label: flow.status,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${flow.screensCount} Interactive Screens · Category: ${flow.categories.join(", ")}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.statusRedText),
                            tooltip: 'Delete Flow',
                            onPressed: () async {
                              final ok = await ConfirmDialog.show(
                                context: context,
                                title: 'Delete Flow',
                                message: 'Are you sure you want to delete "${flow.name}"?',
                                confirmLabel: 'Delete',
                              );
                              if (ok == true) {
                                try {
                                  await repo.deleteFlow(flow.id);
                                  ref.invalidate(flowsProvider);
                                  ToastService.success('Flow deleted');
                                } catch (e) {
                                  ToastService.error('Failed to delete: $e');
                                }
                              }
                            },
                          ),
                          const Spacer(),
                          if (!isPublished) ...[
                            OutlinedButton.icon(
                              onPressed: () async {
                                try {
                                  await repo.publishFlow(flow.id);
                                  ref.invalidate(flowsProvider);
                                  ToastService.success('Flow published live to WhatsApp');
                                } catch (e) {
                                  ToastService.error('Failed to publish: $e');
                                }
                              },
                              icon: const Icon(LucideIcons.send, size: 13, color: AppColors.g700),
                              label: const Text('Publish', style: TextStyle(fontSize: 12, color: AppColors.g700)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.g500),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          OutlinedButton.icon(
                            onPressed: () => _showJsonViewer(context, flow),
                            icon: const Icon(LucideIcons.code, size: 14),
                            label: const Text('View JSON', style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _editFlow(context, ref, flow, repo),
                            icon: const Icon(LucideIcons.edit2, size: 14),
                            label: const Text('Edit Flow', style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.g600,
                              foregroundColor: Colors.white,
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
    );
  }
}

