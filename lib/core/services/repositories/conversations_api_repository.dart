import '../../services/api_service.dart';

abstract class ConversationsApiRepositoryBase {
  Future<List<Map<String, dynamic>>> getConversations({String? status, String? assignedTo, int page, int limit});
  Future<Map<String, dynamic>> getConversation(dynamic id);
  Future<void> assignConversation(dynamic id, dynamic agentId);
  Future<void> transferConversation(dynamic id, dynamic agentId);
  Future<void> updateStatus(dynamic id, String status);
  Future<Map<String, dynamic>> addNote(dynamic id, String content);
  Future<List<Map<String, dynamic>>> getNotes(dynamic id);
  Future<List<Map<String, dynamic>>> getLabels();
  Future<Map<String, dynamic>> createLabel(Map<String, dynamic> data);
  Future<void> addLabel(dynamic conversationId, dynamic labelId);
  Future<void> removeLabel(dynamic conversationId, dynamic labelId);
}

class ConversationsApiRepository implements ConversationsApiRepositoryBase {
  final ApiService _api;
  ConversationsApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<List<Map<String, dynamic>>> getConversations({
    String? status,
    String? assignedTo,
    int page = 1,
    int limit = 25,
  }) async {
    final q = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null) q['status'] = status;
    if (assignedTo != null) q['assignedTo'] = assignedTo;
    final res = await _api.get<dynamic>('/conversations', query: q);
    final list = res is List
        ? res
        : (res is Map
            ? (res['conversations'] ?? res['items'] ?? res['data'] ?? [])
            : []);
    return (list as List).map((j) => Map<String, dynamic>.from(j as Map)).toList();
  }

  @override
  Future<Map<String, dynamic>> getConversation(dynamic id) async {
    final res = await _api.get<dynamic>('/conversations/$id');
    return Map<String, dynamic>.from(res as Map);
  }

  @override
  Future<void> assignConversation(dynamic id, dynamic agentId) async {
    await _api.post('/conversations/$id/assign', {'agentId': agentId});
  }

  @override
  Future<void> transferConversation(dynamic id, dynamic agentId) async {
    await _api.post('/conversations/$id/transfer', {'agentId': agentId});
  }

  @override
  Future<void> updateStatus(dynamic id, String status) async {
    await _api.post('/conversations/$id/status', {'status': status});
  }

  @override
  Future<Map<String, dynamic>> addNote(dynamic id, String content) async {
    final res = await _api.post<dynamic>('/conversations/$id/notes', {'content': content});
    return Map<String, dynamic>.from(res as Map);
  }

  @override
  Future<List<Map<String, dynamic>>> getNotes(dynamic id) async {
    final res = await _api.get<dynamic>('/conversations/$id/notes');
    final list = res is List ? res : [];
    return list.map((j) => Map<String, dynamic>.from(j as Map)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getLabels() async {
    final res = await _api.get<dynamic>('/conversations/labels');
    final list = res is List ? res : [];
    return list.map((j) => Map<String, dynamic>.from(j as Map)).toList();
  }

  @override
  Future<Map<String, dynamic>> createLabel(Map<String, dynamic> data) async {
    final res = await _api.post<dynamic>('/conversations/labels', data);
    return Map<String, dynamic>.from(res as Map);
  }

  @override
  Future<void> addLabel(dynamic conversationId, dynamic labelId) async {
    await _api.post('/conversations/$conversationId/labels', {'labelId': labelId});
  }

  @override
  Future<void> removeLabel(dynamic conversationId, dynamic labelId) async {
    await _api.delete('/conversations/$conversationId/labels/$labelId');
  }
}
