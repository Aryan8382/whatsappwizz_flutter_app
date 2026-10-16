import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_wiz/features/inbox/domain/conversation.dart';
import 'package:whatsapp_wiz/features/inbox/presentation/widgets/free_window_countdown_badge.dart';

void main() {
  group('24H Free Service Window Urgency Tests', () {
    testWidgets('renders active window (>4h) with green urgency', (tester) async {
      final conv = Conversation(
        id: 'c1',
        contactName: 'Ravi',
        contactPhone: '919111111111',
        lastMessage: 'Hello',
        lastMessageTime: DateTime.now(),
        status: ConversationStatus.open,
        lastInboundTime: DateTime.now().subtract(const Duration(hours: 5)), // 19h left
      );

      expect(conv.urgency, WindowUrgency.green);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FreeWindowCountdownBadge(conversation: conv),
          ),
        ),
      );

      expect(find.textContaining('Free Window'), findsOneWidget);
    });

    testWidgets('renders expiring soon (1h-4h) with amber urgency', (tester) async {
      final conv = Conversation(
        id: 'c2',
        contactName: 'Priya',
        contactPhone: '919222222222',
        lastMessage: 'Hello',
        lastMessageTime: DateTime.now(),
        status: ConversationStatus.open,
        lastInboundTime: DateTime.now().subtract(const Duration(hours: 22)), // 2h left
      );

      expect(conv.urgency, WindowUrgency.amber);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FreeWindowCountdownBadge(conversation: conv),
          ),
        ),
      );

      expect(find.textContaining('Expiring Soon'), findsOneWidget);
    });

    testWidgets('renders final window (<1h) with urgent red urgency', (tester) async {
      final conv = Conversation(
        id: 'c3',
        contactName: 'Amit',
        contactPhone: '919333333333',
        lastMessage: 'Hello',
        lastMessageTime: DateTime.now(),
        status: ConversationStatus.open,
        lastInboundTime: DateTime.now().subtract(const Duration(hours: 23, minutes: 30)), // 30m left
      );

      expect(conv.urgency, WindowUrgency.red);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FreeWindowCountdownBadge(conversation: conv),
          ),
        ),
      );

      expect(find.textContaining('Final Window'), findsOneWidget);
    });

    testWidgets('renders expired session when window past 24h', (tester) async {
      final conv = Conversation(
        id: 'c4',
        contactName: 'Sneha',
        contactPhone: '919444444444',
        lastMessage: 'Hello',
        lastMessageTime: DateTime.now(),
        status: ConversationStatus.open,
        lastInboundTime: DateTime.now().subtract(const Duration(hours: 25)), // 0 left
      );

      expect(conv.urgency, WindowUrgency.expired);
      expect(conv.isWindowExpired, isTrue);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FreeWindowCountdownBadge(conversation: conv),
          ),
        ),
      );

      expect(find.text('Session Expired'), findsOneWidget);
    });
  });
}
