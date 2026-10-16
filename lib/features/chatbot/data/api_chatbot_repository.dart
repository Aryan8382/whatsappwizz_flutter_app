import '../../../core/services/api_service.dart';
import '../domain/bot_node.dart';
import '../domain/chatbot_repository.dart';

class ApiChatbotRepository implements ChatbotRepository {
  final ApiService _api;
  ApiChatbotRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<List<BotFlow>> getFlows() async {
    final res = await _api.get<dynamic>('/bots');
    final list = res is List ? res : (res as Map?)?['items'] ?? (res as Map?)?['flows'] ?? [];
    return (list as List)
        .map((j) => BotFlow.fromJson(j as Map<String, dynamic>))
        .toList();
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

  @override
  Future<BotFlow> saveFlow(BotFlow flow) async {
    final payload = {
      'name': flow.name,
      'config': flow.config,
    };
    dynamic res;
    if (flow.id != null && flow.id.toString().isNotEmpty && flow.id.toString() != 'new') {
      res = await _api.put<dynamic>('/bots/${flow.id}', payload);
    } else {
      res = await _api.post<dynamic>('/bots', payload);
    }
    return BotFlow.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<void> togglePublish(String id, bool publish) async {
    final endpoint = publish ? '/bots/$id/publish' : '/bots/$id/unpublish';
    await _api.post(endpoint, {});
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
    await _api.delete<dynamic>('/bots/$flowId/nodes/$nodeId');
  }

  @override
  Future<void> addConnection(String flowId, {required int sourceNode, required int targetNode}) async {
    await _api.post<dynamic>('/bots/$flowId/connections', {
      'sourceNode': sourceNode,
      'targetNode': targetNode,
    });
  }

  @override
  Future<void> deleteConnection(String flowId, {required int sourceNode, required int targetNode}) async {
    await _api.delete<dynamic>('/bots/$flowId/connections/$sourceNode/$targetNode');
  }

  @override
  Future<dynamic> getPreview(String flowId) async {
    return _api.get<dynamic>('/bots/$flowId/preview');
  }
}
