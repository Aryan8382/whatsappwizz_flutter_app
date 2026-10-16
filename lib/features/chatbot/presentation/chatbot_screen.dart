import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/repositories/chatbot_api_repository.dart';
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
import '../domain/bot_node.dart';
import '../domain/chatbot_repository.dart';
import 'widgets/add_bot_sheet.dart';
import 'widgets/bot_studio_editor.dart';
import 'widgets/bot_test_sheet.dart';
import 'widgets/flow_canvas.dart';
import 'widgets/node_config_sheet.dart';

final chatbotRepositoryProvider = Provider<ChatbotRepository>((ref) {
  return ChatbotApiRepository();
});

final chatbotFlowsProvider = FutureProvider.autoDispose<List<BotFlow>>((ref) async {
  final timer = Timer(const Duration(seconds: 12), () => ref.invalidateSelf());
  ref.onDispose(() => timer.cancel());
  final repo = ref.watch(chatbotRepositoryProvider);
  return repo.getFlows();
});

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  BotFlow? _activeFlow;

  @override
  Widget build(BuildContext context) {
    final flowsAsync = ref.watch(chatbotFlowsProvider);
    final repo = ref.watch(chatbotRepositoryProvider);

    if (_activeFlow != null) {
      return BotStudioEditor(
        initialFlow: _activeFlow!,
        repo: repo,
        onBack: () => setState(() => _activeFlow = null),
      );
    }

    // Flow List View
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Chatbot Flow Builder'),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 76),
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.g600,
          foregroundColor: Colors.white,
          icon: const Icon(LucideIcons.plus, size: 20),
          label: const Text('New Bot Flow', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            AddBotSheet.show(
              context,
              onSave: (data) {
                ToastService.success('Bot flow created');
                ref.invalidate(chatbotFlowsProvider);
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
              icon: AppIcons.chatbot,
              title: 'No bot flows',
              message: 'Create automated conversation workflows',
            );
          }

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: AppRadii.borderLg,
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_outlined, size: 18, color: Color(0xFF16A34A)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Only 1 bot is published at a time. Activating a bot automatically sets others to draft.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                  itemCount: flows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final flow = flows[index];
                    final isPub = flow.isPublished;
                    return FadeSlideIn.staggered(
                      index: index,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppRadii.border2xl,
                          border: Border.all(
                            color: isPub ? const Color(0xFF22C55E) : const Color(0x3322C55E),
                            width: isPub ? 1.8 : 1.0,
                          ),
                          boxShadow: isPub
                              ? const [
                                  BoxShadow(
                                    color: Color(0x1422C55E),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          flow.name,
                                          style: AppTypography.titleMedium.copyWith(fontSize: 15),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () async {
                                    final willPublish = !isPub;
                                    await repo.togglePublish(flow.id, willPublish);
                                    ref.invalidate(chatbotFlowsProvider);
                                    ToastService.success(
                                      willPublish
                                          ? '"${flow.name}" is now published (other bots set to draft)'
                                          : '"${flow.name}" set to draft',
                                    );
                                  },
                                  child: StatusBadge(
                                    status: isPub ? 'active' : 'draft',
                                    label: isPub ? 'Published' : 'Draft',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              flow.description,
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Text(
                                  '${flow.nodes.length} nodes · ${flow.connections.length} connections',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!isPub)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: OutlinedButton(
                                          onPressed: () async {
                                            await repo.togglePublish(flow.id, true);
                                            ref.invalidate(chatbotFlowsProvider);
                                            ToastService.success(
                                              '"${flow.name}" published (other bots set to draft)',
                                            );
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            side: const BorderSide(color: Color(0xFF22C55E)),
                                            foregroundColor: const Color(0xFF16A34A),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          child: const Text('Publish', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                        ),
                                      )
                                    else
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: OutlinedButton(
                                          onPressed: () async {
                                            await repo.togglePublish(flow.id, false);
                                            ref.invalidate(chatbotFlowsProvider);
                                            ToastService.info('"${flow.name}" set to draft');
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            side: BorderSide(color: Colors.grey.shade400),
                                            foregroundColor: Colors.grey.shade700,
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          child: const Text('Unpublish', style: TextStyle(fontSize: 12)),
                                        ),
                                      ),
                                    ElevatedButton.icon(
                                      onPressed: () => setState(() => _activeFlow = flow),
                                      icon: const Icon(AppIcons.flows, size: 14),
                                      label: const Text('Open Canvas', style: TextStyle(fontSize: 12)),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
