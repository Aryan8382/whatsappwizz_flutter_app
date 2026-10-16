import '../../services/api_service.dart';

/// Messenger API repository — wraps all /api/v1/messenger/* endpoints.
/// These endpoints proxy directly to Meta WhatsApp Cloud API
/// (graph.facebook.com/v25.0) via the NestJS MessengerService.
///
/// Used for:
/// - Sending messages (text, image, video, document, audio, location)
/// - Sending template messages
/// - Interactive messages (buttons, CTA URL, list, address, flow)
/// - Media retrieval
/// - Template listing from Meta
/// - Webhook management
abstract class MessengerApiRepositoryBase {
  // Status
  Future<Map<String, dynamic>> getStatus();

  // Templates (from Meta directly)
  Future<List<Map<String, dynamic>>> getMetaTemplates({int limit});

  // Send APIs
  Future<Map<String, dynamic>> sendText({required String to, required String text});
  Future<Map<String, dynamic>> sendImage({required String to, required String imageUrl, String? caption});
  Future<Map<String, dynamic>> sendVideo({required String to, required String videoUrl, String? caption});
  Future<Map<String, dynamic>> sendDocument({required String to, required String documentUrl, String? filename, String? caption});
  Future<Map<String, dynamic>> sendAudio({required String to, required String audioUrl});
  Future<Map<String, dynamic>> sendLocation({required String to, required double longitude, required double latitude, String? name, String? address});
  Future<Map<String, dynamic>> sendTemplate({required String to, required String templateName, String languageCode, List<dynamic> components});

  // Interactive
  Future<Map<String, dynamic>> sendInteractiveButtons({required String to, required String text, required List<Map<String, String>> buttons});
  Future<Map<String, dynamic>> sendInteractiveCta({required String to, required String bodyText, required String displayText, required String url, String? headerText, String? footerText});
  Future<Map<String, dynamic>> sendInteractiveList({required String to, required String bodyText, required String buttonText, required List<Map<String, dynamic>> sections, String? headerText, String? footerText});
  Future<Map<String, dynamic>> sendInteractiveFlow({required String to, required String flowId, required String flowCta, required String body, String? flowToken, String? screen, String? header, String? footer});

  // Media
  Future<Map<String, dynamic>> getMedia(String mediaId);

  // Webhooks
  Future<Map<String, dynamic>> getWebhookInfo();
  Future<Map<String, dynamic>> registerWebhook(String url);
  Future<void> deleteWebhook();
}

class MessengerApiRepository implements MessengerApiRepositoryBase {
  final ApiService _api;
  MessengerApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  // ─── Status ───────────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> getStatus() async {
    final res = await _api.get<dynamic>('/messenger/status');
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  // ─── Templates from Meta ──────────────────────────────────────────────

  @override
  Future<List<Map<String, dynamic>>> getMetaTemplates({int limit = 1000}) async {
    final res = await _api.get<dynamic>('/messenger/templates', query: {'limit': limit});
    final list = (res is Map ? res['data'] : res) ?? [];
    return (list as List).map((j) => Map<String, dynamic>.from(j as Map)).toList();
  }

  // ─── Send Text ────────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> sendText({required String to, required String text}) async {
    final res = await _api.post<dynamic>('/messenger/send/text', {'to': to, 'text': text});
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  // ─── Send Image ───────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> sendImage({required String to, required String imageUrl, String? caption}) async {
    final res = await _api.post<dynamic>('/messenger/send/image', {
      'to': to,
      'imageUrl': imageUrl,
      if (caption != null) 'caption': caption,
    });
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  // ─── Send Video ───────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> sendVideo({required String to, required String videoUrl, String? caption}) async {
    final res = await _api.post<dynamic>('/messenger/send/video', {
      'to': to,
      'videoUrl': videoUrl,
      if (caption != null) 'caption': caption,
    });
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  // ─── Send Document ────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> sendDocument({required String to, required String documentUrl, String? filename, String? caption}) async {
    final res = await _api.post<dynamic>('/messenger/send/document', {
      'to': to,
      'documentUrl': documentUrl,
      if (filename != null) 'filename': filename,
      if (caption != null) 'caption': caption,
    });
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  // ─── Send Audio ───────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> sendAudio({required String to, required String audioUrl}) async {
    final res = await _api.post<dynamic>('/messenger/send/audio', {'to': to, 'audioUrl': audioUrl});
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  // ─── Send Location ────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> sendLocation({required String to, required double longitude, required double latitude, String? name, String? address}) async {
    final res = await _api.post<dynamic>('/messenger/send/location', {
      'to': to,
      'location': {
        'longitude': longitude,
        'latitude': latitude,
        if (name != null) 'name': name,
        if (address != null) 'address': address,
      },
    });
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  // ─── Send Template ────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> sendTemplate({
    required String to,
    required String templateName,
    String languageCode = 'en',
    List<dynamic> components = const [],
  }) async {
    final res = await _api.post<dynamic>('/messenger/send/template', {
      'to': to,
      'templateName': templateName,
      'languageCode': languageCode,
      if (components.isNotEmpty) 'components': components,
    });
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  // ─── Interactive Buttons ──────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> sendInteractiveButtons({
    required String to,
    required String text,
    required List<Map<String, String>> buttons,
  }) async {
    final res = await _api.post<dynamic>('/messenger/send/interactive-buttons', {
      'to': to,
      'text': text,
      'buttons': buttons,
    });
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  // ─── Interactive CTA URL ──────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> sendInteractiveCta({
    required String to,
    required String bodyText,
    required String displayText,
    required String url,
    String? headerText,
    String? footerText,
  }) async {
    final res = await _api.post<dynamic>('/messenger/send/interactive-cta', {
      'to': to,
      'bodyText': bodyText,
      'displayText': displayText,
      'url': url,
      if (headerText != null) 'headerText': headerText,
      if (footerText != null) 'footerText': footerText,
    });
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  // ─── Interactive List ─────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> sendInteractiveList({
    required String to,
    required String bodyText,
    required String buttonText,
    required List<Map<String, dynamic>> sections,
    String? headerText,
    String? footerText,
  }) async {
    final res = await _api.post<dynamic>('/messenger/send/interactive-list', {
      'to': to,
      'bodyText': bodyText,
      'buttonText': buttonText,
      'sections': sections,
      if (headerText != null) 'headerText': headerText,
      if (footerText != null) 'footerText': footerText,
    });
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  // ─── Interactive Flow ─────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> sendInteractiveFlow({
    required String to,
    required String flowId,
    required String flowCta,
    required String body,
    String? flowToken,
    String? screen,
    String? header,
    String? footer,
  }) async {
    final res = await _api.post<dynamic>('/messenger/send/interactive-flow', {
      'to': to,
      'flowId': flowId,
      'flowCta': flowCta,
      'body': body,
      if (flowToken != null) 'flowToken': flowToken,
      if (screen != null) 'screen': screen,
      if (header != null) 'header': header,
      if (footer != null) 'footer': footer,
    });
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  // ─── Media ────────────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> getMedia(String mediaId) async {
    final res = await _api.get<dynamic>('/messenger/media/$mediaId');
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  // ─── Webhooks ─────────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> getWebhookInfo() async {
    final res = await _api.get<dynamic>('/messenger/webhook');
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  @override
  Future<Map<String, dynamic>> registerWebhook(String url) async {
    final res = await _api.post<dynamic>('/messenger/webhook', {'url': url});
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  @override
  Future<void> deleteWebhook() async {
    await _api.delete('/messenger/webhook');
  }
}
