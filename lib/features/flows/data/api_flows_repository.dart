import '../../../core/services/api_service.dart';
import '../domain/flows_repository.dart';
import '../domain/whatsapp_flow.dart';

class ApiFlowsRepository implements FlowsRepository {
  final ApiService _api;
  ApiFlowsRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<List<WhatsappFlow>> getFlows() async {
    final res = await _api.get<dynamic>('/flows');
    final list = res is List ? res : (res as Map?)?['items'] ?? [];
    return (list as List)
        .map((j) => WhatsappFlow.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<WhatsappFlow> createFlow(Map<String, dynamic> data) async {
    final res = await _api.post<dynamic>('/flows', data);
    return WhatsappFlow.fromJson(Map<String, dynamic>.from(res as Map));
  }

  @override
  Future<WhatsappFlow> updateFlow(dynamic id, Map<String, dynamic> data) async {
    final res = await _api.put<dynamic>('/flows/$id', data);
    return WhatsappFlow.fromJson(Map<String, dynamic>.from(res as Map));
  }

  @override
  Future<void> publishFlow(dynamic id) async {
    await _api.post('/flows/$id/publish', {});
  }

  @override
  Future<void> deleteFlow(dynamic id) async {
    await _api.delete('/flows/$id');
  }
}
