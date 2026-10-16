import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_wiz/features/inbox/domain/message.dart';
import 'package:whatsapp_wiz/features/inbox/presentation/widgets/message_bubble.dart';

void main() {
  group('MessageBubble Variant Tests', () {
    testWidgets('renders outbound text message bubble with tick', (tester) async {
      final msg = Message(
        id: 'm1',
        conversationId: 'c1',
        direction: MessageDirection.outbound,
        type: MessageType.text,
        body: 'Hello there!',
        status: MessageStatus.read,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: msg),
          ),
        ),
      );

      expect(find.text('Hello there!'), findsOneWidget);
      expect(find.byIcon(Icons.done_all_rounded), findsOneWidget);
    });

    testWidgets('renders document message bubble with filename and size', (tester) async {
      final msg = Message(
        id: 'm2',
        conversationId: 'c1',
        direction: MessageDirection.inbound,
        type: MessageType.document,
        body: 'Please check the file',
        mediaName: 'Annual_Report.pdf',
        mediaSize: '1.2 MB',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: msg),
          ),
        ),
      );

      expect(find.text('Annual_Report.pdf'), findsOneWidget);
      expect(find.text('1.2 MB'), findsOneWidget);
    });

    testWidgets('renders internal note with lock indicator and yellow background', (tester) async {
      final msg = Message(
        id: 'm3',
        conversationId: 'c1',
        direction: MessageDirection.outbound,
        type: MessageType.internalNote,
        body: 'VIP customer. Escalate to supervisor if unresolved.',
        isInternalNote: true,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: msg),
          ),
        ),
      );

      expect(find.textContaining('Internal Note'), findsOneWidget);
      expect(find.text('VIP customer. Escalate to supervisor if unresolved.'), findsOneWidget);
    });
  });
}
