import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/services/toast_service.dart';
import '../../auth/presentation/auth_controller.dart';
import 'inbox_controller.dart';
import 'widgets/chat_pane.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inboxControllerProvider.notifier).selectConversation(widget.conversationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final inboxState = ref.watch(inboxControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final notifier = ref.read(inboxControllerProvider.notifier);
    final myName = authState.user?.fullName ?? 'Demo Admin';

    if (inboxState.conversations.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final conv = inboxState.conversations.firstWhere(
      (c) => c.id.toString() == widget.conversationId.toString(),
      orElse: () => inboxState.activeConversation ?? inboxState.conversations.first,
    );

    return Scaffold(
      body: ChatPane(
        conversation: conv,
        messages: inboxState.activeMessages,
        currentUserName: myName,
        onBack: () => context.pop(),
        onSendText: (text) => notifier.sendText(text),
        onSendInternalNote: (note) => notifier.sendInternalNote(note),
        onSendTemplate: (tpl) => notifier.sendTemplate(tpl.name, tpl.body),
        onPickAttachment: () => ToastService.info('Attachment picker opened'),
        onUpdateStatus: (status) => notifier.updateStatus(status),
        onAssignAgent: (agent) => notifier.assignAgent(agent, currentUserName: myName),
      ),
    );
  }
}
