import 'automation_workflow.dart';

abstract class AutomationRepository {
  Future<List<AutomationWorkflow>> getWorkflows();
  Future<void> toggleActive(String id, bool active);
  Future<AutomationWorkflow> createWorkflow(Map<String, dynamic> data);
  Future<void> deleteWorkflow(dynamic id);
}

