import 'bot_node.dart';

abstract class ChatbotRepository {
  Future<List<BotFlow>> getFlows();
  Future<BotFlow?> getFlowById(String id);
  Future<BotFlow> saveFlow(BotFlow flow);
  Future<void> togglePublish(String id, bool publish);
  Future<void> updateBot(String id, {required String name, required Map<String, dynamic> config});
  Future<void> addNode(String flowId, {required String nodeType, required String text});
  Future<void> deleteNode(String flowId, String nodeId);
  Future<void> addConnection(String flowId, {required int sourceNode, required int targetNode});
  Future<void> deleteConnection(String flowId, {required int sourceNode, required int targetNode});
  Future<dynamic> getPreview(String flowId);
}
