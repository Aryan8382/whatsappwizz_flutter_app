import '../../services/api_service.dart';
import '../../../features/automation/domain/automation_workflow.dart';
import '../../../features/automation/domain/automation_repository.dart';

class AutomationApiRepository implements AutomationRepository {
  final ApiService _api;
  AutomationApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<List<AutomationWorkflow>> getWorkflows() async {
    final res = await _api.get<dynamic>('/automation');
    final list = res is List ? res : (res as Map?)?['items'] ?? [];
    return (list as List).map((j) => AutomationWorkflow.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> getStats() async {
    final res = await _api.get<dynamic>('/automation/stats');
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  Future<AutomationWorkflow> getWorkflow(dynamic id) async {
    final res = await _api.get<dynamic>('/automation/$id');
    return AutomationWorkflow.fromJson(res as Map<String, dynamic>);
  }

  Future<AutomationWorkflow> createWorkflow(Map<String, dynamic> data) async {
    final res = await _api.post<dynamic>('/automation', data);
    return AutomationWorkflow.fromJson(res as Map<String, dynamic>);
  }

  Future<AutomationWorkflow> updateWorkflow(dynamic id, Map<String, dynamic> data) async {
    final res = await _api.put<dynamic>('/automation/$id', data);
    return AutomationWorkflow.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<void> toggleActive(String id, bool active) async {
    await _api.post('/automation/$id/${active ? 'activate' : 'pause'}');
  }

  Future<void> deleteWorkflow(dynamic id) async {
    await _api.delete('/automation/$id');
  }
}
