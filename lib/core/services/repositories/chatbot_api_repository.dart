import '../../services/api_service.dart';
import '../../../features/chatbot/domain/bot_node.dart';
import '../../../features/chatbot/domain/chatbot_repository.dart';

class ChatbotApiRepository implements ChatbotRepository {
  final ApiService _api;
  ChatbotApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<List<BotFlow>> getFlows() async {
    final res = await _api.get<dynamic>('/bots');
    final list = res is List ? res : (res as Map?)?['items'] ?? [];
    return (list as List).map((j) => BotFlow.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<BotFlow?> getFlowById(String id) async {
    try {
      final res = await _api.get<dynamic>('/bots/$id');
      return BotFlow.fromJson(res as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getFlowPreview(dynamic id) async {
    final res = await _api.get<dynamic>('/bots/$id/preview');
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  @override
  Future<BotFlow> saveFlow(BotFlow flow) async {
    if (flow.id == '' || flow.id == null) {
      final res = await _api.post<dynamic>('/bots', flow.toJson());
      return BotFlow.fromJson(res as Map<String, dynamic>);
    } else {
      final res = await _api.put<dynamic>('/bots/${flow.id}', flow.toJson());
      return BotFlow.fromJson(res as Map<String, dynamic>);
    }
  }

  @override
  Future<void> togglePublish(String id, bool publish) async {
    await _api.post('/bots/$id/${publish ? 'publish' : 'unpublish'}');
  }

  @override
  Future<void> updateBot(String id, {required String name, required Map<String, dynamic> config}) async {
    await _api.put<dynamic>('/bots/$id', {
      'name': name,
      'config': config,
    });
  }

  @override
  Future<void> addNode(String flowId, {required String nodeType, required String text}) async {
    final cfg = <String, dynamic>{'text': text.trim()};
    if (nodeType == 'question') {
      cfg['answers'] = [{'text': text.trim(), 'targetNodeId': null}];
    }
    await _api.post<dynamic>('/bots/$flowId/nodes', {
      'nodeType': nodeType,
      'config': cfg,
      'positionX': 200,
      'positionY': 100,
    });
  }

  @override
  Future<void> deleteNode(String flowId, String nodeId) async {
    await _api.delete('/bots/$flowId/nodes/$nodeId');
  }

  @override
  Future<void> addConnection(String flowId, {required int sourceNode, required int targetNode}) async {
    await _api.post('/bots/$flowId/connections', {
      'sourceNode': sourceNode,
      'targetNode': targetNode,
    });
  }

  @override
  Future<void> deleteConnection(String flowId, {required int sourceNode, required int targetNode}) async {
    await _api.delete('/bots/$flowId/connections/$sourceNode/$targetNode');
  }

  @override
  Future<dynamic> getPreview(String flowId) async {
    return _api.get<dynamic>('/bots/$flowId/preview');
  }

  Future<void> deleteFlow(dynamic id) async {
    await _api.delete('/bots/$id');
  }
}
