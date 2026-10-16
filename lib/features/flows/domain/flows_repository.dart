import 'whatsapp_flow.dart';

abstract class FlowsRepository {
  Future<List<WhatsappFlow>> getFlows();
  Future<WhatsappFlow> createFlow(Map<String, dynamic> data);
  Future<WhatsappFlow> updateFlow(dynamic id, Map<String, dynamic> data);
  Future<void> publishFlow(dynamic id);
  Future<void> deleteFlow(dynamic id);
}

