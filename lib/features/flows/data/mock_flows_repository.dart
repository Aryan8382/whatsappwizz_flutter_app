import '../domain/whatsapp_flow.dart';

abstract class FlowsRepository {
  Future<List<WhatsappFlow>> getFlows();
}

class MockFlowsRepository implements FlowsRepository {
  @override
  Future<List<WhatsappFlow>> getFlows() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return [
      WhatsappFlow(
        id: 'fl_1',
        name: 'Appointment Booking Flow',
        status: 'PUBLISHED',
        categories: ['APPOINTMENT_BOOKING'],
        screensCount: 3,
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      WhatsappFlow(
        id: 'fl_2',
        name: 'Customer Survey & Feedback Flow',
        status: 'PUBLISHED',
        categories: ['SURVEY'],
        screensCount: 4,
        updatedAt: DateTime.now().subtract(const Duration(days: 9)),
      ),
      WhatsappFlow(
        id: 'fl_3',
        name: 'Product Lead Inquiry Form',
        status: 'DRAFT',
        categories: ['LEAD_GENERATION'],
        screensCount: 2,
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
