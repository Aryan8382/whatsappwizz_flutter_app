import '../../services/api_service.dart';
import '../../../features/flows/domain/whatsapp_flow.dart';
import '../../../features/flows/domain/flows_repository.dart';

class FlowsApiRepository implements FlowsRepository {
  final ApiService _api;
  FlowsApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<List<WhatsappFlow>> getFlows() async {
    final res = await _api.get<dynamic>('/flows');
    final list = res is List ? res : (res as Map?)?['items'] ?? [];
    return (list as List).map((j) => WhatsappFlow.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<WhatsappFlow> createFlow(Map<String, dynamic> data) async {
    final res = await _api.post<dynamic>('/flows', data);
    return WhatsappFlow.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<WhatsappFlow> updateFlow(dynamic id, Map<String, dynamic> data) async {
    final res = await _api.put<dynamic>('/flows/$id', data);
    return WhatsappFlow.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<void> publishFlow(dynamic id) async {
    await _api.post<dynamic>('/flows/$id/publish', {});
  }

  @override
  Future<void> deleteFlow(dynamic id) async {
    await _api.delete<dynamic>('/flows/$id');
  }
}

