import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/api_inbox_repository.dart';
import '../domain/conversation.dart';
import '../domain/inbox_repository.dart';
import '../domain/message.dart';
import '../../../core/services/realtime_service.dart';

final inboxRepositoryProvider = Provider<InboxRepository>((ref) {
  return ApiInboxRepository();
});

class InboxState {
  final List<Conversation> conversations;
  final String? activeConversationId;
  final List<Message> activeMessages;
  final bool isLoading;
  final String? error;

  const InboxState({
    this.conversations = const [],
    this.activeConversationId,
    this.activeMessages = const [],
    this.isLoading = false,
    this.error,
  });

  Conversation? get activeConversation {
    if (activeConversationId == null) return null;
    final match = conversations.where((c) => c.id.toString() == activeConversationId.toString());
    return match.isNotEmpty ? match.first : null;
  }

  InboxState copyWith({
    List<Conversation>? conversations,
    String? activeConversationId,
    List<Message>? activeMessages,
    bool? isLoading,
    String? error,
  }) {
    return InboxState(
      conversations: conversations ?? this.conversations,
      activeConversationId: activeConversationId ?? this.activeConversationId,
      activeMessages: activeMessages ?? this.activeMessages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class InboxNotifier extends StateNotifier<InboxState> {
  final InboxRepository _repo;
  Timer? _liveRefreshTimer;
  final List<Function> _socketCancellers = [];
  final Map<String, String?> _assignedAgents = {};
  final Map<String, List<Message>> _systemMessages = {};

  InboxNotifier(this._repo) : super(const InboxState()) {
    loadConversations();
    _startLiveAutoRefresh();
    _subscribeToRealtime();
  }

  /// Socket.IO subscriptions — instant push instead of relying on poll only
  void _subscribeToRealtime() {
    final rt = RealtimeService.instance;

    // New message received from Meta webhook
    final cancel1 = rt.on('message:new', (data) {
      if (data is Map) {
        final convId = (data['conversationId'] ?? data['conversation_id'] ?? data['conversation']?['id'])?.toString();
        final body = (data['messageText'] ?? data['message_text'] ?? data['body'] ?? '').toString();
        final senderType = (data['senderType'] ?? data['sender_type'] ?? '').toString().toLowerCase();

        if (convId != null && convId.isNotEmpty) {
          handleIncomingMessage(
            conversationId: convId,
            messageData: Map<String, dynamic>.from(data),
            body: body,
            senderType: senderType,
          );
          return;
        }
      }
      loadConversations(silent: true);
      final activeId = state.activeConversationId;
      if (activeId != null) loadMessages(activeId, silent: true);
    });

    // Message status updated (sent → delivered → read)
    final cancel2 = rt.on('message:status', (data) {
      final activeId = state.activeConversationId;
      if (activeId != null) loadMessages(activeId, silent: true);
    });

    // New conversation opened
    final cancel3 = rt.on('conversation:new', (data) {
      loadConversations(silent: true);
    });

    _socketCancellers.addAll([cancel1, cancel2, cancel3]);
  }

  void handleIncomingMessage({
    required String conversationId,
    required Map<String, dynamic> messageData,
    required String body,
    required String senderType,
  }) {
    final now = DateTime.now().toUtc();
    final isActiveChat = state.activeConversationId?.toString() == conversationId.toString();
    final isCustomerMessage = senderType == 'customer' || senderType == 'contact';

    final existingIndex = state.conversations.indexWhere(
      (c) => c.id.toString() == conversationId.toString(),
    );

    Conversation updatedConv;
    if (existingIndex != -1) {
      final existing = state.conversations[existingIndex];
      // If customer sent message:
      // If active/open chat -> unreadCount stays 0 (seen chat doesn't show numbers)
      // If other chat -> increment unread count: 1, 2, 3...
      final newUnread = isActiveChat
          ? 0
          : (isCustomerMessage ? existing.unreadCount + 1 : existing.unreadCount);

      updatedConv = existing.copyWith(
        lastMessage: body.isNotEmpty ? body : existing.lastMessage,
        lastMessageTime: now,
        updatedAt: now,
        unreadCount: newUnread,
        lastInboundTime: isCustomerMessage ? now : existing.lastInboundTime,
      );
    } else {
      updatedConv = Conversation(
        id: conversationId,
        contactName: messageData['senderName'] ?? messageData['contactName'] ?? 'Contact',
        contactPhone: messageData['from'] ?? messageData['phone'] ?? '',
        lastMessage: body,
        lastMessageTime: now,
        updatedAt: now,
        unreadCount: isActiveChat ? 0 : 1,
        status: ConversationStatus.open,
      );
    }

    // THIS CHAT ALWAYS JUMPS TO FIRST (INDEX 0)
    final otherConvs = state.conversations
        .where((c) => c.id.toString() != conversationId.toString())
        .toList();
    final newConversationsList = [updatedConv, ...otherConvs];

    List<Message> newMessages = state.activeMessages;
    if (isActiveChat) {
      final newMsg = Message.fromJson(messageData);
      if (!newMessages.any((m) => m.id.toString() == newMsg.id.toString())) {
        newMessages = [...newMessages, newMsg];
      }
    }

    state = state.copyWith(
      conversations: newConversationsList,
      activeMessages: newMessages,
    );
  }

  void simulateIncomingMessage({String? conversationId, String? text}) {
    final activeId = state.activeConversationId?.toString();
    
    // Pick target:
    // 1. Specified conversationId if provided
    // 2. Or conversation that already has unread count (to demonstrate 1 -> 2 -> 3 count incrementing like WhatsApp)
    // 3. Or an inactive conversation (not currently opened)
    // 4. Or first conversation
    Conversation? targetConv;
    if (conversationId != null) {
      final matches = state.conversations.where((c) => c.id.toString() == conversationId.toString());
      if (matches.isNotEmpty) targetConv = matches.first;
    } else {
      final unreadMatches = state.conversations.where((c) => c.unreadCount > 0 && c.id.toString() != activeId);
      if (unreadMatches.isNotEmpty) {
        targetConv = unreadMatches.first;
      } else {
        final inactiveMatches = state.conversations.where((c) => c.id.toString() != activeId);
        if (inactiveMatches.isNotEmpty) {
          targetConv = inactiveMatches.first;
        } else if (state.conversations.isNotEmpty) {
          targetConv = state.conversations.first;
        }
      }
    }

    if (targetConv == null) return;
    final convId = targetConv.id.toString();
    final newCount = targetConv.unreadCount + 1;
    final msgText = text ?? 'New message #$newCount from customer!';
    final now = DateTime.now().toUtc();

    final data = {
      'id': 'sim_${now.millisecondsSinceEpoch}',
      'conversationId': convId,
      'senderType': 'customer',
      'messageType': 'text',
      'messageText': msgText,
      'body': msgText,
      'createdAt': now.toIso8601String(),
      'status': 'delivered',
    };

    handleIncomingMessage(
      conversationId: convId,
      messageData: data,
      body: msgText,
      senderType: 'customer',
    );
  }

  void _startLiveAutoRefresh() {
    _liveRefreshTimer?.cancel();
    // Fallback poll every 5s (Socket.IO handles instant updates)
    _liveRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      loadConversations(silent: true);
    });
  }

  @override
  void dispose() {
    _liveRefreshTimer?.cancel();
    for (final cancel in _socketCancellers) {
      cancel();
    }
    super.dispose();
  }

  Future<void> loadConversations({bool silent = false}) async {
    if (!silent && state.conversations.isEmpty) {
      state = state.copyWith(isLoading: true, error: null);
    }
    try {
      final list = await _repo.getConversations();
      final activeId = state.activeConversationId;

      // Merge with local unread, assigned agents, and recent timestamps
      final mergedList = list.map((serverConv) {
        final convIdStr = serverConv.id.toString();
        if (_assignedAgents.containsKey(convIdStr)) {
          serverConv = serverConv.copyWith(assignedAgentName: _assignedAgents[convIdStr]);
        }
        // If this is currently active chat, keep unreadCount = 0
        if (activeId != null && serverConv.id.toString() == activeId.toString()) {
          final local = state.activeConversation;
          if (local != null && local.latestActivityTime.isAfter(serverConv.latestActivityTime)) {
            return serverConv.copyWith(
              unreadCount: 0,
              lastMessage: local.lastMessage,
              lastMessageTime: local.lastMessageTime,
              updatedAt: local.updatedAt,
            );
          }
          return serverConv.copyWith(unreadCount: 0);
        }

        // If local conversation has higher unreadCount from real-time events that haven't reached REST yet:
        final localMatches = state.conversations.where((c) => c.id.toString() == serverConv.id.toString());
        if (localMatches.isNotEmpty) {
          final local = localMatches.first;
          if (local.unreadCount > serverConv.unreadCount) {
            return serverConv.copyWith(
              unreadCount: local.unreadCount,
              lastMessage: local.latestActivityTime.isAfter(serverConv.latestActivityTime) ? local.lastMessage : serverConv.lastMessage,
              lastMessageTime: local.latestActivityTime.isAfter(serverConv.latestActivityTime) ? local.lastMessageTime : serverConv.lastMessageTime,
              updatedAt: local.latestActivityTime.isAfter(serverConv.latestActivityTime) ? local.updatedAt : serverConv.updatedAt,
            );
          }
        }
        return serverConv;
      }).toList();

      mergedList.sort((a, b) => b.latestActivityTime.toUtc().compareTo(a.latestActivityTime.toUtc()));

      state = state.copyWith(
        conversations: mergedList,
        isLoading: false,
      );

      if (activeId != null) {
        await loadMessages(activeId, silent: silent);
      } else if (mergedList.isNotEmpty) {
        final firstId = mergedList.first.id.toString();
        await selectConversation(firstId);
      }
    } catch (e, stack) {
      debugPrint('[InboxNotifier] loadConversations error: $e\n$stack');
      if (!silent) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  Future<void> selectConversation(String id) async {
    // 1. Immediately mark conversation as seen / read in local state
    // Seen chats don't show numbers (same as WhatsApp)
    final updatedList = state.conversations.map((c) {
      if (c.id.toString() == id.toString()) {
        return c.copyWith(unreadCount: 0);
      }
      return c;
    }).toList();

    state = state.copyWith(
      activeConversationId: id,
      conversations: updatedList,
    );

    // 2. Fetch messages from backend (which also marks messages as read in the DB)
    await loadMessages(id);
  }

  Future<void> loadMessages(String id, {bool silent = false}) async {
    try {
      final msgs = await _repo.getMessages(id);
      final sysMsgs = _systemMessages[id.toString()] ?? [];
      final allMsgs = [...msgs, ...sysMsgs];
      allMsgs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      state = state.copyWith(activeMessages: allMsgs);
    } catch (e, stack) {
      debugPrint('[InboxNotifier] loadMessages error: $e\n$stack');
      if (!silent) {
        state = state.copyWith(error: e.toString());
      }
    }
  }

  bool _areMessageListsEqual(List<Message> a, List<Message> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].status != b[i].status || a[i].body != b[i].body) {
        return false;
      }
    }
    return true;
  }

  Future<void> sendText(String text) async {
    final activeId = state.activeConversationId;
    if (activeId == null) return;
    final conversation = state.activeConversation;
    try {
      final now = DateTime.now().toUtc();
      final currentConv = conversation ??
          state.conversations.firstWhere(
            (c) => c.id.toString() == activeId.toString(),
            orElse: () => state.conversations.first,
          );
      final updatedConv = currentConv.copyWith(
        lastMessage: text,
        lastMessageTime: now,
        updatedAt: now,
        unreadCount: 0,
      );

      // Move this chat ALWAYS to index 0 (FIRST):
      final otherConversations = state.conversations
          .where((c) => c.id.toString() != activeId.toString())
          .toList();
      final updatedConversations = [updatedConv, ...otherConversations];

      final optimisticMsg = Message(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        conversationId: activeId,
        senderType: 'agent',
        type: MessageType.text,
        body: text,
        status: MessageStatus.sent,
        createdAt: now,
      );

      state = state.copyWith(
        conversations: updatedConversations,
        activeMessages: [...state.activeMessages, optimisticMsg],
      );

      final msg = await _repo.sendMessage(
        conversationId: activeId,
        body: text,
        type: MessageType.text,
        conversation: conversation,
      );

      final msgs = state.activeMessages.map((m) {
        return m.id == optimisticMsg.id ? msg : m;
      }).toList();

      state = state.copyWith(activeMessages: msgs);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }


  Future<void> sendInternalNote(String note) async {
    final activeId = state.activeConversationId;
    if (activeId == null) return;
    final conversation = state.activeConversation;
    try {
      final msg = await _repo.sendMessage(
        conversationId: activeId,
        body: note,
        isInternalNote: true,
        type: MessageType.internalNote,
        conversation: conversation,
      );
      state = state.copyWith(
        activeMessages: [...state.activeMessages, msg],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> sendTemplate(
    String templateName,
    String body, {
    List<String>? parameters,
    String? headerMediaUrl,
  }) async {
    final activeId = state.activeConversationId;
    if (activeId == null) return;
    final conversation = state.activeConversation;
    try {
      final msg = await _repo.sendMessage(
        conversationId: activeId,
        body: body,
        type: MessageType.template,
        templateName: templateName,
        templateParameters: parameters,
        headerMediaUrl: headerMediaUrl,
        conversation: conversation,
      );

      final now = DateTime.now().toUtc();
      // Immediately activate the chat for this number & reset 24-hr window
      final currentConv = conversation ??
          state.conversations.firstWhere(
            (c) => c.id.toString() == activeId.toString(),
            orElse: () => state.conversations.first,
          );
      final activatedConv = currentConv.copyWith(
        status: ConversationStatus.open,
        lastInboundTime: now,
        lastMessage: body.isNotEmpty ? body : templateName,
        lastMessageTime: now,
        updatedAt: now,
        unreadCount: 0,
      );

      final otherConversations = state.conversations
          .where((c) => c.id.toString() != activeId.toString())
          .toList();
      final updatedConversations = [activatedConv, ...otherConversations];

      state = state.copyWith(
        conversations: updatedConversations,
        activeMessages: [...state.activeMessages, msg],
      );
      await loadConversations(silent: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> sendMedia(
    String mediaUrl,
    MessageType type, {
    String? caption,
    String? fileName,
  }) async {
    final activeId = state.activeConversationId;
    if (activeId == null) return;
    final conversation = state.activeConversation;
    try {
      final msg = await _repo.sendMessage(
        conversationId: activeId,
        body: caption ?? '',
        type: type,
        mediaUrl: mediaUrl,
        mediaName: fileName,
        conversation: conversation,
      );
      final now = DateTime.now().toUtc();
      final currentConv = conversation ??
          state.conversations.firstWhere(
            (c) => c.id.toString() == activeId.toString(),
            orElse: () => state.conversations.first,
          );
      final updatedConv = currentConv.copyWith(
        lastMessage: caption?.isNotEmpty == true ? caption! : '[${type.name}]',
        lastMessageTime: now,
        updatedAt: now,
        unreadCount: 0,
      );
      final otherConversations = state.conversations
          .where((c) => c.id.toString() != activeId.toString())
          .toList();
      final updatedConversations = [updatedConv, ...otherConversations];

      state = state.copyWith(
        conversations: updatedConversations,
        activeMessages: [...state.activeMessages, msg],
      );
      await loadConversations(silent: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateStatus(ConversationStatus status) async {
    final activeId = state.activeConversationId;
    if (activeId == null) return;

    // Optimistically update conversation status in local state
    final updatedList = state.conversations.map((c) {
      return c.id.toString() == activeId.toString() ? c.copyWith(status: status) : c;
    }).toList();
    state = state.copyWith(conversations: updatedList);

    try {
      await _repo.updateConversationStatus(activeId, status);
      await loadConversations(silent: true);
    } catch (e) {
      debugPrint('[InboxNotifier] updateStatus error: $e');
    }
  }

  Future<void> assignAgent(String agentName, {String? currentUserName}) async {
    final activeId = state.activeConversationId;
    if (activeId == null) return;

    final isUnassign = agentName.isEmpty;
    final isMe = !isUnassign &&
        (agentName.toLowerCase() == 'you' ||
            (currentUserName != null &&
                agentName.toLowerCase() == currentUserName.toLowerCase()));
    final systemText = isUnassign
        ? 'Chat unassigned'
        : (isMe ? 'Chat assigned to you' : 'Chat assigned to $agentName');

    final now = DateTime.now().toUtc();
    final systemMsg = Message(
      id: 'assign_${now.millisecondsSinceEpoch}',
      conversationId: activeId,
      senderType: 'system',
      type: MessageType.text,
      body: systemText,
      status: MessageStatus.sent,
      createdAt: now,
    );

    // Save in persistent maps so background polls don't overwrite them
    _assignedAgents[activeId.toString()] = isUnassign ? null : agentName;
    _systemMessages.putIfAbsent(activeId.toString(), () => []).add(systemMsg);

    // Optimistically update assigned agent name and chat timeline
    final updatedList = state.conversations.map((c) {
      return c.id.toString() == activeId.toString()
          ? c.copyWith(assignedAgentName: isUnassign ? null : agentName)
          : c;
    }).toList();

    state = state.copyWith(
      conversations: updatedList,
      activeMessages: [...state.activeMessages, systemMsg],
    );

    try {
      await _repo.assignAgent(activeId, agentName);
      await loadConversations(silent: true);
    } catch (e) {
      debugPrint('[InboxNotifier] assignAgent error: $e');
    }
  }

  Future<void> addLabel(String label) async {
    final activeId = state.activeConversationId;
    if (activeId == null || label.trim().isEmpty) return;
    final trimmed = label.trim();

    // Optimistically update labels
    final updatedList = state.conversations.map((c) {
      if (c.id.toString() == activeId.toString()) {
        final currentLabels = List<String>.from(c.labels);
        if (!currentLabels.contains(trimmed)) {
          currentLabels.add(trimmed);
        }
        return c.copyWith(labels: currentLabels);
      }
      return c;
    }).toList();
    state = state.copyWith(conversations: updatedList);

    try {
      await _repo.addLabel(activeId, trimmed);
      await loadConversations(silent: true);
    } catch (e) {
      debugPrint('[InboxNotifier] addLabel error: $e');
    }
  }

  Future<void> removeLabel(String label) async {
    final activeId = state.activeConversationId;
    if (activeId == null) return;

    // Optimistically remove label
    final updatedList = state.conversations.map((c) {
      if (c.id == activeId) {
        final currentLabels = List<String>.from(c.labels)..remove(label);
        return c.copyWith(labels: currentLabels);
      }
      return c;
    }).toList();
    state = state.copyWith(conversations: updatedList);

    try {
      await _repo.removeLabel(activeId, label);
      await loadConversations(silent: true);
    } catch (e) {
      debugPrint('[InboxNotifier] removeLabel error: $e');
    }
  }

  Future<void> updateContactInfo({required String name, String? phone}) async {
    final activeId = state.activeConversationId;
    if (activeId == null) return;

    final trimmedName = name.trim();
    final trimmedPhone = phone?.trim();

    // Optimistically update contact details
    final updatedList = state.conversations.map((c) {
      if (c.id == activeId) {
        return c.copyWith(
          contactName: trimmedName.isNotEmpty ? trimmedName : c.contactName,
          contactPhone: trimmedPhone != null && trimmedPhone.isNotEmpty ? trimmedPhone : c.contactPhone,
        );
      }
      return c;
    }).toList();
    state = state.copyWith(conversations: updatedList);

    await loadConversations(silent: true);
  }
}

final inboxControllerProvider =
    StateNotifierProvider<InboxNotifier, InboxState>((ref) {
  final repo = ref.watch(inboxRepositoryProvider);
  return InboxNotifier(repo);
});
