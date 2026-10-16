import '../domain/automation_workflow.dart';

abstract class AutomationRepository {
  Future<List<AutomationWorkflow>> getWorkflows();
  Future<void> toggleActive(String id, bool active);
}

class MockAutomationRepository implements AutomationRepository {
  final List<AutomationWorkflow> _workflows = [
    AutomationWorkflow(
      id: 'auto_1',
      name: 'Auto Welcome on New Lead',
      triggerEvent: 'Contact Created with tag #Lead',
      actionType: 'Send Template: welcome_message',
      isActive: true,
      executionCount: 840,
      updatedAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    AutomationWorkflow(
      id: 'auto_2',
      name: 'VIP Query Escalation',
      triggerEvent: 'Inbound message from VIP contact',
      actionType: 'Assign to Supervisor Queue',
      isActive: true,
      executionCount: 142,
      updatedAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    AutomationWorkflow(
      id: 'auto_3',
      name: 'Order Confirmation Ping',
      triggerEvent: 'Webhook: order.created',
      actionType: 'Send Template: order_confirmation',
      isActive: false,
      executionCount: 420,
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<List<AutomationWorkflow>> getWorkflows() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [..._workflows];
  }

  @override
  Future<void> toggleActive(String id, bool active) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _workflows.indexWhere((w) => w.id == id);
    if (idx != -1) {
      _workflows[idx] = _workflows[idx].copyWith(isActive: active);
    }
  }
}
