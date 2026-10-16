import 'dart:async';
import '../domain/conversation.dart';
import '../domain/inbox_repository.dart';
import '../domain/message.dart';

class MockInboxRepository implements InboxRepository {
  final List<Conversation> _conversations = [
    Conversation(
      id: 'conv_1',
      contactName: 'Ravi Kumar',
      contactPhone: '919111111111',
      lastMessage: 'Could you please confirm the delivery date for order #5021?',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
      status: ConversationStatus.open,
      assignedAgentName: 'Demo Agent',
      labels: ['VIP', 'Support'],
      unreadCount: 2,
      lastInboundTime: DateTime.now().subtract(const Duration(hours: 5, minutes: 20)), // 18h 40m left -> Green
    ),
    Conversation(
      id: 'conv_2',
      contactName: 'Priya Sharma',
      contactPhone: '919222222222',
      lastMessage: 'Is this available in green color too?',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
      status: ConversationStatus.open,
      assignedAgentName: 'Demo Supervisor',
      labels: ['Sales'],
      unreadCount: 1,
      lastInboundTime: DateTime.now().subtract(const Duration(hours: 21, minutes: 30)), // 2h 30m left -> Amber
    ),
    Conversation(
      id: 'conv_3',
      contactName: 'Amit Patel',
      contactPhone: '919333333333',
      lastMessage: 'Need urgent invoice for our tax filing.',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
      status: ConversationStatus.pending,
      assignedAgentName: 'Demo Agent',
      labels: ['Billing', 'Urgent'],
      unreadCount: 0,
      lastInboundTime: DateTime.now().subtract(const Duration(hours: 23, minutes: 15)), // 45m left -> Red
    ),
    Conversation(
      id: 'conv_4',
      contactName: 'Sneha Gupta',
      contactPhone: '919444444444',
      lastMessage: 'Thanks, talk to you next week.',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
      status: ConversationStatus.open,
      assignedAgentName: 'Demo Admin',
      labels: ['Follow-up'],
      unreadCount: 0,
      lastInboundTime: DateTime.now().subtract(const Duration(hours: 32)), // 0m left -> Expired
    ),
    Conversation(
      id: 'conv_5',
      contactName: 'Vikram Singh',
      contactPhone: '919555555555',
      lastMessage: 'Query has been resolved. Thank you!',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 6)),
      status: ConversationStatus.resolved,
      assignedAgentName: 'Demo Agent',
      labels: ['Feedback'],
      unreadCount: 0,
      lastInboundTime: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];

  final Map<String, List<Message>> _messagesMap = {};

  MockInboxRepository() {
    _initMessages();
  }

  void _initMessages() {
    final now = DateTime.now();

    _messagesMap['conv_1'] = [
      Message(
        id: 'm1_1',
        conversationId: 'conv_1',
        direction: MessageDirection.inbound,
        type: MessageType.text,
        body: 'Hi, I placed an order yesterday.',
        createdAt: now.subtract(const Duration(hours: 5, minutes: 30)),
      ),
      Message(
        id: 'm1_2',
        conversationId: 'conv_1',
        direction: MessageDirection.outbound,
        type: MessageType.text,
        body: 'Hello Ravi! Welcome to Demo Company. Let me check your order status.',
        status: MessageStatus.read,
        createdAt: now.subtract(const Duration(hours: 5, minutes: 25)),
      ),
      Message(
        id: 'm1_3',
        conversationId: 'conv_1',
        direction: MessageDirection.outbound,
        type: MessageType.internalNote,
        body: 'Customer ordered Item #881 via website. Payment verified.',
        isInternalNote: true,
        createdAt: now.subtract(const Duration(hours: 5, minutes: 22)),
      ),
      Message(
        id: 'm1_4',
        conversationId: 'conv_1',
        direction: MessageDirection.outbound,
        type: MessageType.document,
        body: 'Here is your order summary invoice.',
        mediaName: 'Invoice_5021.pdf',
        mediaSize: '240 KB',
        mediaUrl: 'https://example.com/invoice.pdf',
        status: MessageStatus.read,
        createdAt: now.subtract(const Duration(hours: 5, minutes: 20)),
      ),
      Message(
        id: 'm1_5',
        conversationId: 'conv_1',
        direction: MessageDirection.inbound,
        type: MessageType.text,
        body: 'Could you please confirm the delivery date for order #5021?',
        createdAt: now.subtract(const Duration(minutes: 15)),
      ),
    ];

    _messagesMap['conv_2'] = [
      Message(
        id: 'm2_1',
        conversationId: 'conv_2',
        direction: MessageDirection.inbound,
        type: MessageType.text,
        body: 'Hi, saw your new catalog on Instagram.',
        createdAt: now.subtract(const Duration(hours: 22)),
      ),
      Message(
        id: 'm2_2',
        conversationId: 'conv_2',
        direction: MessageDirection.outbound,
        type: MessageType.interactive,
        body: 'Welcome! Which category would you like to explore today?',
        interactiveButtons: ['Footwear', 'Apparel', 'Accessories'],
        status: MessageStatus.delivered,
        createdAt: now.subtract(const Duration(hours: 21, minutes: 50)),
      ),
      Message(
        id: 'm2_3',
        conversationId: 'conv_2',
        direction: MessageDirection.inbound,
        type: MessageType.text,
        body: 'Is this available in green color too?',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 10)),
      ),
    ];

    _messagesMap['conv_3'] = [
      Message(
        id: 'm3_1',
        conversationId: 'conv_3',
        direction: MessageDirection.inbound,
        type: MessageType.text,
        body: 'Need urgent invoice for our tax filing.',
        createdAt: now.subtract(const Duration(hours: 23, minutes: 15)),
      ),
    ];

    _messagesMap['conv_4'] = [
      Message(
        id: 'm4_1',
        conversationId: 'conv_4',
        direction: MessageDirection.outbound,
        type: MessageType.template,
        body: 'Hi Sneha, welcome to Demo Company! Enjoy your day.',
        templateName: 'welcome_message',
        status: MessageStatus.read,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Message(
        id: 'm4_2',
        conversationId: 'conv_4',
        direction: MessageDirection.inbound,
        type: MessageType.text,
        body: 'Thanks, talk to you next week.',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];

    _messagesMap['conv_5'] = [
      Message(
        id: 'm5_1',
        conversationId: 'conv_5',
        direction: MessageDirection.inbound,
        type: MessageType.text,
        body: 'Query has been resolved. Thank you!',
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
    ];
  }

  @override
  Future<List<Conversation>> getConversations({
    String? query,
    ConversationStatus? status,
    String? label,
    String? assignedAgent,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var list = [..._conversations];

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((c) {
        return c.contactName.toLowerCase().contains(q) ||
            c.contactPhone.contains(q) ||
            c.lastMessage.toLowerCase().contains(q);
      }).toList();
    }

    if (status != null) {
      list = list.where((c) => c.status == status).toList();
    }

    if (label != null && label.isNotEmpty) {
      list = list.where((c) => c.labels.contains(label)).toList();
    }

    if (assignedAgent != null && assignedAgent.isNotEmpty) {
      list = list.where((c) => c.assignedAgentName == assignedAgent).toList();
    }

    return list;
  }

  @override
  Future<Conversation?> getConversationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final match = _conversations.where((c) => c.id == id);
    return match.isNotEmpty ? match.first : null;
  }

  @override
  Future<List<Message>> getMessages(String conversationId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _messagesMap[conversationId] ?? [];
  }

  @override
  Future<Message> sendMessage({
    required String conversationId,
    required String body,
    MessageType type = MessageType.text,
    String? mediaUrl,
    String? mediaName,
    String? mediaSize,
    String? templateName,
    List<String> interactiveButtons = const [],
    bool isInternalNote = false,
    Conversation? conversation,
    List<String>? templateParameters,
    String? headerMediaUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final msg = Message(
      id: 'msg_${dateNowId()}',
      conversationId: conversationId,
      direction: MessageDirection.outbound,
      type: isInternalNote ? MessageType.internalNote : type,
      body: body,
      mediaUrl: mediaUrl,
      mediaName: mediaName,
      mediaSize: mediaSize,
      templateName: templateName,
      interactiveButtons: interactiveButtons,
      status: isInternalNote ? MessageStatus.delivered : MessageStatus.sent,
      createdAt: DateTime.now(),
      isInternalNote: isInternalNote,
    );

    if (!_messagesMap.containsKey(conversationId)) {
      _messagesMap[conversationId] = [];
    }
    _messagesMap[conversationId]!.add(msg);

    // Update conversation last message
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1 && !isInternalNote) {
      _conversations[idx] = _conversations[idx].copyWith(
        lastMessage: body,
        lastMessageTime: DateTime.now(),
      );
    }

    // Schedule live WhatsApp delivery and read transitions
    if (!isInternalNote) {
      // Sent -> Delivered after 700ms
      Timer(const Duration(milliseconds: 700), () {
        final list = _messagesMap[conversationId];
        if (list != null) {
          final mIdx = list.indexWhere((m) => m.id == msg.id);
          if (mIdx != -1) {
            list[mIdx] = list[mIdx].copyWith(status: MessageStatus.delivered);
          }
        }
      });

      // Delivered -> Read after 1600ms
      Timer(const Duration(milliseconds: 1600), () {
        final list = _messagesMap[conversationId];
        if (list != null) {
          final mIdx = list.indexWhere((m) => m.id == msg.id);
          if (mIdx != -1) {
            list[mIdx] = list[mIdx].copyWith(status: MessageStatus.read);
          }
        }
      });

      // Customer inbound reply after 2600ms to test live auto-refresh
      Timer(const Duration(milliseconds: 2600), () {
        final list = _messagesMap[conversationId];
        if (list != null) {
          final replyText = body.toLowerCase().contains('order')
              ? 'Thanks for the update, will track it!'
              : (body.toLowerCase().contains('price') || body.toLowerCase().contains('cost')
                  ? 'Sounds good! How do I complete payment?'
                  : 'Received, thank you! 👍');

          final inboundMsg = Message(
            id: 'msg_${dateNowId()}',
            conversationId: conversationId,
            direction: MessageDirection.inbound,
            type: MessageType.text,
            body: replyText,
            status: MessageStatus.delivered,
            createdAt: DateTime.now(),
          );
          list.add(inboundMsg);

          final cIdx = _conversations.indexWhere((c) => c.id == conversationId);
          if (cIdx != -1) {
            _conversations[cIdx] = _conversations[cIdx].copyWith(
              lastMessage: replyText,
              lastMessageTime: DateTime.now(),
              lastInboundTime: DateTime.now(),
              unreadCount: _conversations[cIdx].unreadCount + 1,
            );
          }
        }
      });
    }

    return msg;
  }

  @override
  Future<void> updateConversationStatus(
    String conversationId,
    ConversationStatus status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      _conversations[idx] = _conversations[idx].copyWith(status: status);
    }
  }

  @override
  Future<void> assignAgent(String conversationId, String agentName) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      _conversations[idx] = _conversations[idx].copyWith(assignedAgentName: agentName);
    }
  }

  @override
  Future<void> addLabel(String conversationId, String label) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      final current = [..._conversations[idx].labels];
      if (!current.contains(label)) current.add(label);
      _conversations[idx] = _conversations[idx].copyWith(labels: current);
    }
  }

  @override
  Future<void> removeLabel(String conversationId, String label) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      final current = [..._conversations[idx].labels]..remove(label);
      _conversations[idx] = _conversations[idx].copyWith(labels: current);
    }
  }

  static int _idCounter = 100;
  static String dateNowId() => '${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}';
}
