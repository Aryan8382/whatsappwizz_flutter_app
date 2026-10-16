import '../../services/api_service.dart';

/// Matches backend DTOs exactly from messages.controller.ts + dto/send-message.dto.ts
///
/// SendTextDto     → POST /messages/send     { whatsappNumberId, to, text }
/// SendTemplateDto → POST /messages/template { whatsappNumberId, to, templateName, language?, parameters?, headerMediaUrl? }
/// SendMediaDto    → POST /messages/media    { whatsappNumberId, to, type?, mediaUrl?, caption? }
class MessagesApiRepository {
  final ApiService _api;
  MessagesApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  // POST /messages/send — SendTextDto
  Future<Map<String, dynamic>> sendText({
    required int whatsappNumberId,
    required String to,
    required String text,
  }) async {
    final res = await _api.post<dynamic>('/messages/send', {
      'whatsappNumberId': whatsappNumberId,
      'to': to,
      'text': text,
    });
    return Map<String, dynamic>.from(res as Map);
  }

  // POST /messages/template — SendTemplateDto
  Future<Map<String, dynamic>> sendTemplate({
    required int whatsappNumberId,
    required String to,
    required String templateName,
    String language = 'en',
    List<String> parameters = const [],
    String? headerMediaUrl,
  }) async {
    final res = await _api.post<dynamic>('/messages/template', {
      'whatsappNumberId': whatsappNumberId,
      'to': to,
      'templateName': templateName,
      'language': language,
      if (parameters.isNotEmpty) 'parameters': parameters,
      if (headerMediaUrl != null) 'headerMediaUrl': headerMediaUrl,
    });
    return Map<String, dynamic>.from(res as Map);
  }

  // POST /messages/media — SendMediaDto
  Future<Map<String, dynamic>> sendMedia({
    required int whatsappNumberId,
    required String to,
    String type = 'image',
    String? mediaUrl,
    String? caption,
  }) async {
    final res = await _api.post<dynamic>('/messages/media', {
      'whatsappNumberId': whatsappNumberId,
      'to': to,
      'type': type,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      if (caption != null) 'caption': caption,
    });
    return Map<String, dynamic>.from(res as Map);
  }

  // GET /messages/conversation/:id
  Future<List<Map<String, dynamic>>> getConversationMessages(dynamic conversationId) async {
    final res = await _api.get<dynamic>('/messages/conversation/$conversationId');
    final list = res is List ? res : (res as Map?)?['items'] ?? [];
    return list.map((j) => Map<String, dynamic>.from(j as Map)).toList();
  }

  // GET /messages/:id
  Future<Map<String, dynamic>> getMessage(dynamic id) async {
    final res = await _api.get<dynamic>('/messages/$id');
    return Map<String, dynamic>.from(res as Map);
  }

  // POST /messages/:id/retry
  Future<Map<String, dynamic>> retryMessage(dynamic id) async {
    final res = await _api.post<dynamic>('/messages/$id/retry');
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  // GET /messages/messenger/status
  Future<Map<String, dynamic>> getMessengerStatus() async {
    final res = await _api.get<dynamic>('/messages/messenger/status');
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  // POST /messages/conversation/:id/bot-reply
  Future<Map<String, dynamic>> runBotReply({
    required dynamic conversationId,
    required String text,
    int? botId,
  }) async {
    final res = await _api.post<dynamic>('/messages/conversation/$conversationId/bot-reply', {
      'text': text,
      if (botId != null) 'botId': botId,
    });
    return Map<String, dynamic>.from(res as Map? ?? {});
  }
}
