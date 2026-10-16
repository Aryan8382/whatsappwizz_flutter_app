import '../domain/template.dart';
import '../domain/templates_repository.dart';

class MockTemplatesRepository implements TemplatesRepository {
  final List<Template> _templates = [
    Template(
      id: 'tpl_1',
      name: 'welcome_message',
      language: 'en',
      category: 'MARKETING',
      headerType: 'TEXT',
      headerText: 'Welcome to Our Community!',
      body: 'Hi {{1}}, welcome to our community! Enjoy your day and check out our new catalog.',
      footer: 'Reply STOP to unsubscribe',
      buttons: ['View Catalog', 'Talk to Agent'],
      status: TemplateStatus.approved,
      updatedAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    Template(
      id: 'tpl_2',
      name: 'order_confirmation',
      language: 'en',
      category: 'UTILITY',
      headerType: 'TEXT',
      headerText: 'Order Confirmed',
      body: 'Hi {{1}}, your order #{{2}} has been confirmed. Delivery is scheduled for {{3}}.',
      footer: 'Need help? Contact support',
      buttons: ['Track Order'],
      status: TemplateStatus.approved,
      updatedAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    Template(
      id: 'tpl_3',
      name: 'festive_discount_sale',
      language: 'en',
      category: 'MARKETING',
      headerType: 'IMAGE',
      body: 'Celebrate this festive season with flat {{1}}% discount across all products! Use coupon code {{2}} at checkout.',
      footer: 'Valid until Sunday midnight',
      buttons: ['Shop Now'],
      status: TemplateStatus.pending,
      updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    Template(
      id: 'tpl_4',
      name: 'abandoned_cart_reminder',
      language: 'en',
      category: 'MARKETING',
      body: 'Hey {{1}}, you left items in your cart. Complete your purchase now with free shipping.',
      buttons: ['Checkout Now'],
      status: TemplateStatus.draft,
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Template(
      id: 'tpl_5',
      name: 'payment_failed_alert',
      language: 'en',
      category: 'UTILITY',
      body: 'Your payment for transaction #{{1}} could not be processed. Please retry with a valid payment method.',
      buttons: ['Retry Payment'],
      status: TemplateStatus.rejected,
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  @override
  Future<List<Template>> getTemplates() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [..._templates];
  }

  @override
  Future<Template> createTemplate(Template template) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final created = template.copyWith(
      id: 'tpl_${DateTime.now().millisecondsSinceEpoch}',
      status: TemplateStatus.draft,
      updatedAt: DateTime.now(),
    );
    _templates.insert(0, created);
    return created;
  }

  @override
  Future<void> submitForApproval(String templateId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _templates.indexWhere((t) => t.id == templateId);
    if (idx != -1) {
      _templates[idx] = _templates[idx].copyWith(status: TemplateStatus.pending);
    }
  }

  @override
  Future<void> syncWithMeta() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simulated sync with Meta WABA
  }
}
