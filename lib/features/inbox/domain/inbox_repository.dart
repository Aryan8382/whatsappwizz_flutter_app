import 'conversation.dart';
import 'message.dart';

abstract class InboxRepository {
  Future<List<Conversation>> getConversations({
    String? query,
    ConversationStatus? status,
    String? label,
    String? assignedAgent,
  });

  Future<Conversation?> getConversationById(String id);

  Future<List<Message>> getMessages(String conversationId);

  /// Send a message. Pass [conversation] so the repo can resolve
  /// whatsappNumberId and contact phone — required by the backend DTOs.
  Future<Message> sendMessage({
    required String conversationId,
    required String body,
    MessageType type,
    String? mediaUrl,
    String? mediaName,
    String? mediaSize,
    String? templateName,
    List<String> interactiveButtons,
    bool isInternalNote,
    Conversation? conversation,
    List<String>? templateParameters,
    String? headerMediaUrl,
  });

  Future<void> updateConversationStatus(
    String conversationId,
    ConversationStatus status,
  );

  Future<void> assignAgent(String conversationId, String agentName);
  Future<void> addLabel(String conversationId, String label);
  Future<void> removeLabel(String conversationId, String label);
}
