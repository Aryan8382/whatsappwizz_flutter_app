import '../../../core/services/api_service.dart';
import '../domain/conversation.dart';
import '../domain/inbox_repository.dart';
import '../domain/message.dart';

/// Real inbox repository.
/// Matches backend DTOs exactly:
///   SendTextDto     → { whatsappNumberId, to, text }
///   SendTemplateDto → { whatsappNumberId, to, templateName, language?, parameters?, headerMediaUrl? }
///   SendMediaDto    → { whatsappNumberId, to, type?, mediaUrl?, caption? }
///
/// The backend /messages/send, /messages/template, /messages/media endpoints
/// require whatsappNumberId + to (contact phone), NOT conversationId.
/// We resolve both from the active Conversation object passed through the repo.
class ApiInboxRepository implements InboxRepository {
  final ApiService _api;
  ApiInboxRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  // ─── Conversations ────────────────────────────────────────────────────

  @override
  Future<List<Conversation>> getConversations({
    String? query,
    ConversationStatus? status,
    String? label,
    String? assignedAgent,
  }) async {
    final q = <String, dynamic>{};
    if (query != null && query.isNotEmpty) q['search'] = query;
    if (status != null) q['status'] = status.value;
    if (label != null) q['label'] = label;
    if (assignedAgent != null) q['assignedAgent'] = assignedAgent;
    final res = await _api.get<dynamic>('/conversations', query: q);
    final list = res is List
        ? res
        : (res is Map
            ? (res['conversations'] ?? res['items'] ?? res['data'] ?? [])
            : []);
    return (list as List)
        .map((j) => Conversation.fromJson(Map<String, dynamic>.from(j as Map)))
        .toList();
  }

  @override
  Future<Conversation?> getConversationById(String id) async {
    try {
      final res = await _api.get<dynamic>('/conversations/$id');
      return Conversation.fromJson(Map<String, dynamic>.from(res as Map));
    } catch (_) {
      return null;
    }
  }

  // ─── Messages ─────────────────────────────────────────────────────────

  @override
  Future<List<Message>> getMessages(String conversationId) async {
    final res = await _api.get<dynamic>('/messages/conversation/$conversationId');
    final list = res is List
        ? res
        : (res is Map
            ? (res['messages'] ?? res['items'] ?? res['data'] ?? [])
            : []);
    final result = <Message>[];
    for (final j in (list as List)) {
      try {
        result.add(Message.fromJson(Map<String, dynamic>.from(j as Map)));
      } catch (err) {
        // Keep resilient against any unexpected message format
      }
    }
    return result;
  }

  /// Send a message — routes to the correct backend endpoint based on type.
  ///
  /// IMPORTANT: The backend requires whatsappNumberId + to (phone number).
  /// The [conversation] param provides both from the active conversation.
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
    // Extra params needed by the backend (resolved from conversation)
    Conversation? conversation,
    List<String>? templateParameters,
    String? headerMediaUrl,
  }) async {
    // If no conversation provided, fall back to legacy route (won't reach Meta)
    if (conversation == null) {
      return _sendLegacy(
        conversationId: conversationId,
        body: body,
        type: type,
        mediaUrl: mediaUrl,
        templateName: templateName,
        isInternalNote: isInternalNote,
      );
    }

    final whatsappNumberId = conversation.whatsappNumberId;
    final to = conversation.contactPhone;

    if (whatsappNumberId == null || to.isEmpty) {
      throw Exception(
        'Cannot send message: conversation missing whatsappNumberId or contact phone. '
        'whatsappNumberId=$whatsappNumberId, contactPhone=$to',
      );
    }

    dynamic res;

    switch (type) {
      // ── Text message ──────────────────────────────────────────────────
      case MessageType.text:
        // POST /messages/send → SendTextDto { whatsappNumberId, to, text }
        res = await _api.post<dynamic>('/messages/send', {
          'whatsappNumberId': int.tryParse(whatsappNumberId.toString()) ?? whatsappNumberId,
          'to': to,
          'text': body,
        });
        break;

      // ── Template message ──────────────────────────────────────────────
      case MessageType.template:
        if (templateName == null || templateName.isEmpty) {
          throw Exception('templateName is required for template messages');
        }
        // POST /messages/template → SendTemplateDto
        res = await _api.post<dynamic>('/messages/template', {
          'whatsappNumberId': int.tryParse(whatsappNumberId.toString()) ?? whatsappNumberId,
          'to': to,
          'templateName': templateName,
          if (templateParameters != null && templateParameters.isNotEmpty)
            'parameters': templateParameters,
          if (headerMediaUrl != null) 'headerMediaUrl': headerMediaUrl,
        });
        break;

      // ── Image message ─────────────────────────────────────────────────
      case MessageType.image:
        res = await _api.post<dynamic>('/messages/media', {
          'whatsappNumberId': int.tryParse(whatsappNumberId.toString()) ?? whatsappNumberId,
          'to': to,
          'type': 'image',
          if (mediaUrl != null) 'mediaUrl': mediaUrl,
          if (body.isNotEmpty) 'caption': body,
        });
        break;

      // ── Video message ─────────────────────────────────────────────────
      case MessageType.video:
        res = await _api.post<dynamic>('/messages/media', {
          'whatsappNumberId': int.tryParse(whatsappNumberId.toString()) ?? whatsappNumberId,
          'to': to,
          'type': 'video',
          if (mediaUrl != null) 'mediaUrl': mediaUrl,
          if (body.isNotEmpty) 'caption': body,
        });
        break;

      // ── Document message ──────────────────────────────────────────────
      case MessageType.document:
        res = await _api.post<dynamic>('/messages/media', {
          'whatsappNumberId': int.tryParse(whatsappNumberId.toString()) ?? whatsappNumberId,
          'to': to,
          'type': 'document',
          if (mediaUrl != null) 'mediaUrl': mediaUrl,
          if (mediaName != null) 'filename': mediaName,
          if (body.isNotEmpty) 'caption': body,
        });
        break;

      // ── Audio message ─────────────────────────────────────────────────
      case MessageType.audio:
        res = await _api.post<dynamic>('/messages/media', {
          'whatsappNumberId': int.tryParse(whatsappNumberId.toString()) ?? whatsappNumberId,
          'to': to,
          'type': 'audio',
          if (mediaUrl != null) 'mediaUrl': mediaUrl,
        });
        break;

      // ── Internal note (not sent via WhatsApp) ─────────────────────────
      case MessageType.internalNote:
        res = await _api.post<dynamic>('/conversations/$conversationId/notes', {
          'content': body,
        });
        break;

      // ── Fallback ──────────────────────────────────────────────────────
      default:
        res = await _api.post<dynamic>('/messages/send', {
          'whatsappNumberId': int.tryParse(whatsappNumberId.toString()) ?? whatsappNumberId,
          'to': to,
          'text': body,
        });
    }

    return Message.fromJson(res as Map<String, dynamic>);
  }

  // ─── Legacy send (no conversation context) ────────────────────────────

  Future<Message> _sendLegacy({
    required String conversationId,
    required String body,
    required MessageType type,
    String? mediaUrl,
    String? templateName,
    bool isInternalNote = false,
  }) async {
    final endpoint = isInternalNote
        ? '/conversations/$conversationId/notes'
        : '/messages/send';

    final payload = isInternalNote
        ? {'content': body}
        : {
            'conversationId': conversationId,
            'body': body,
            'type': type.name,
            if (mediaUrl != null) 'mediaUrl': mediaUrl,
            if (templateName != null) 'templateName': templateName,
          };

    final res = await _api.post<dynamic>(endpoint, payload);
    return Message.fromJson(res as Map<String, dynamic>);
  }

  // ─── Conversation actions ─────────────────────────────────────────────

  @override
  Future<void> updateConversationStatus(
    String conversationId,
    ConversationStatus status,
  ) async {
    await _api.post('/conversations/$conversationId/status', {
      'status': status.value,
    });
  }

  @override
  Future<void> assignAgent(String conversationId, String agentName) async {
    int? agentId;
    final lower = agentName.toLowerCase();
    if (lower.contains('admin')) {
      agentId = 1;
    } else if (lower.contains('supervisor')) {
      agentId = 2;
    } else if (lower.contains('agent')) {
      agentId = 3;
    } else if (lower.contains('reseller')) {
      agentId = 4;
    }

    await _api.post('/conversations/$conversationId/assign', {
      if (agentId != null) 'agentId': agentId,
      'agentName': agentName,
    });
  }

  @override
  Future<void> addLabel(String conversationId, String label) async {
    await _api.post('/conversations/$conversationId/labels', {
      'label': label,
    });
  }

  @override
  Future<void> removeLabel(String conversationId, String label) async {
    await _api.delete('/conversations/$conversationId/labels/$label');
  }
}
