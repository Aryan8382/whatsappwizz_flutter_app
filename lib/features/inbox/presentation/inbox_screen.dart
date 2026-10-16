import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/skeleton_list.dart';
import '../../auth/presentation/auth_controller.dart';
import 'inbox_controller.dart';
import 'widgets/chat_pane.dart';
import 'widgets/conversation_list_pane.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxState = ref.watch(inboxControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final notifier = ref.read(inboxControllerProvider.notifier);
    final myName = authState.user?.fullName ?? 'Demo Admin';

    if (inboxState.isLoading && inboxState.conversations.isEmpty) {
      return const Scaffold(
        body: Center(child: SkeletonList(count: 6, itemHeight: 80)),
      );
    }

    if (inboxState.error != null && inboxState.conversations.isEmpty) {
      return Scaffold(
        body: ErrorState(
          message: inboxState.error!,
          onRetry: () => notifier.loadConversations(),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDualPane = constraints.maxWidth >= 900;

        if (isDualPane) {
          // Dual Pane for Tablet / Desktop (>= 900dp)
          final activeConv = inboxState.activeConversation ??
              (inboxState.conversations.isNotEmpty ? inboxState.conversations.first : null);

          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.only(bottom: 84),
              child: Row(
                children: [
                  SizedBox(
                    width: 360,
                    child: ConversationListPane(
                      conversations: inboxState.conversations,
                      selectedConversationId: inboxState.activeConversationId,
                      onSelect: (conv) => notifier.selectConversation(conv.id.toString()),
                      onRefresh: () => notifier.loadConversations(),
                      onSimulateIncoming: () => notifier.simulateIncomingMessage(),
                    ),
                  ),
                  const VerticalDivider(width: 1, thickness: 1, color: Color(0x1F22C55E)),
                  Expanded(
                    child: activeConv == null
                        ? const Center(
                            child: Text(
                              'Select a conversation to start messaging',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          )
                        : ChatPane(
                            key: ValueKey(activeConv.id.toString()),
                            conversation: activeConv,
                            messages: inboxState.activeMessages,
                            currentUserName: myName,
                            onSendText: (text) => notifier.sendText(text),
                            onSendInternalNote: (note) => notifier.sendInternalNote(note),
                            onSendTemplate: (tpl) => notifier.sendTemplate(tpl.name, tpl.body),
                            onPickAttachment: () => ToastService.info('File Picker opened'),
                            onUpdateStatus: (status) => notifier.updateStatus(status),
                            onAssignAgent: (agent) => notifier.assignAgent(agent, currentUserName: myName),
                          ),
                  ),
                ],
              ),
            ),
          );
        }

        // Single Pane for Phones (< 900dp)
        return Scaffold(
          body: ConversationListPane(
            conversations: inboxState.conversations,
            selectedConversationId: inboxState.activeConversationId,
            onSelect: (conv) {
              notifier.selectConversation(conv.id.toString());
              context.push('/inbox/${conv.id}');
            },
            onRefresh: () => notifier.loadConversations(),
            onSimulateIncoming: () => notifier.simulateIncomingMessage(),
          ),
        );
      },
    );
  }
}
