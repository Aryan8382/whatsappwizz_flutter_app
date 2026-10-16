import 'dart:ui';
import '../domain/bot_node.dart';
import '../domain/chatbot_repository.dart';

class MockChatbotRepository implements ChatbotRepository {
  final List<BotFlow> _flows = [
    BotFlow(
      id: 'flow_1',
      name: 'Customer Welcome & FAQ Bot',
      description: 'Greets inbound users and provides interactive options',
      isPublished: true,
      nodes: const [
        BotNode(
          id: 'n_start',
          type: BotNodeType.start,
          title: 'Start Trigger',
          content: 'When customer sends any message',
          position: Offset(40, 140),
        ),
        BotNode(
          id: 'n_msg1',
          type: BotNodeType.message,
          title: 'Greeting Message',
          content: 'Hi! Welcome to Demo Store. How can we help you today?',
          position: Offset(260, 140),
        ),
        BotNode(
          id: 'n_btn',
          type: BotNodeType.button,
          title: 'Main Menu',
          content: 'Options: Catalog, Speak with Agent, FAQs',
          position: Offset(500, 140),
        ),
        BotNode(
          id: 'n_handover',
          type: BotNodeType.handover,
          title: 'Transfer to Human',
          content: 'Assign to Support agent queue',
          position: Offset(760, 60),
        ),
        BotNode(
          id: 'n_catalog',
          type: BotNodeType.message,
          title: 'Catalog Link',
          content: 'Browse our latest collection at https://demo.store/catalog',
          position: Offset(760, 240),
        ),
      ],
      connections: const [
        BotConnection(fromNodeId: 'n_start', toNodeId: 'n_msg1'),
        BotConnection(fromNodeId: 'n_msg1', toNodeId: 'n_btn'),
        BotConnection(fromNodeId: 'n_btn', toNodeId: 'n_handover', label: 'Agent'),
        BotConnection(fromNodeId: 'n_btn', toNodeId: 'n_catalog', label: 'Catalog'),
      ],
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    BotFlow(
      id: 'flow_2',
      name: 'Order Status Inquiry Bot',
      description: 'Looks up order tracking details via API webhook',
      isPublished: false,
      nodes: const [
        BotNode(
          id: 'f2_start',
          type: BotNodeType.start,
          title: 'Keyword Match: #ORDER',
          content: 'Matches order query',
          position: Offset(40, 100),
        ),
        BotNode(
          id: 'f2_api',
          type: BotNodeType.api,
          title: 'Query ERP Webhook',
          content: 'GET /orders/:orderId',
          position: Offset(260, 100),
        ),
      ],
      connections: const [
        BotConnection(fromNodeId: 'f2_start', toNodeId: 'f2_api'),
      ],
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  @override
  Future<List<BotFlow>> getFlows() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [..._flows];
  }

  @override
  Future<BotFlow?> getFlowById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final match = _flows.where((f) => f.id == id);
    return match.isNotEmpty ? match.first : null;
  }

  @override
  Future<BotFlow> saveFlow(BotFlow flow) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _flows.indexWhere((f) => f.id == flow.id);
    if (idx != -1) {
      _flows[idx] = flow;
    } else {
      _flows.add(flow);
    }
    return flow;
  }

  @override
  Future<void> togglePublish(String id, bool publish) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _flows.indexWhere((f) => f.id == id);
    if (idx != -1) {
      _flows[idx] = _flows[idx].copyWith(isPublished: publish);
    }
  }

  @override
  Future<void> updateBot(String id, {required String name, required Map<String, dynamic> config}) async {
    final idx = _flows.indexWhere((f) => f.id == id);
    if (idx != -1) {
      _flows[idx] = _flows[idx].copyWith(name: name, config: config);
    }
  }

  @override
  Future<void> addNode(String flowId, {required String nodeType, required String text}) async {}

  @override
  Future<void> deleteNode(String flowId, String nodeId) async {}

  @override
  Future<void> addConnection(String flowId, {required int sourceNode, required int targetNode}) async {}

  @override
  Future<void> deleteConnection(String flowId, {required int sourceNode, required int targetNode}) async {}

  @override
  Future<dynamic> getPreview(String flowId) async => null;
}
