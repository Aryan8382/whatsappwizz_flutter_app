import '../../../core/services/api_service.dart';
import '../domain/automation_repository.dart';
import '../domain/automation_workflow.dart';

class ApiAutomationRepository implements AutomationRepository {
  final ApiService _api;
  ApiAutomationRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<List<AutomationWorkflow>> getWorkflows() async {
    final res = await _api.get<dynamic>('/automation');
    final list = res is List ? res : (res as Map?)?['items'] ?? [];
    return (list as List)
        .map((j) => AutomationWorkflow.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> toggleActive(String id, bool active) async {
    final endpoint = active ? '/automation/$id/activate' : '/automation/$id/pause';
    await _api.post(endpoint, {});
  }

  @override
  Future<AutomationWorkflow> createWorkflow(Map<String, dynamic> data) async {
    final res = await _api.post<dynamic>('/automation', data);
    return AutomationWorkflow.fromJson(Map<String, dynamic>.from(res as Map));
  }

  @override
  Future<void> deleteWorkflow(dynamic id) async {
    await _api.delete('/automation/$id');
  }
}
