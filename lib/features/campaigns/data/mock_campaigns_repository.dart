import '../domain/campaign.dart';
import '../domain/campaigns_repository.dart';

class MockCampaignsRepository implements CampaignsRepository {
  final List<Campaign> _campaigns = [
    Campaign(
      id: 'cmp_1',
      name: 'Diwali Mega Offer 2026',
      templateName: 'welcome_message',
      audienceSource: 'Segment: VIP High Value',
      status: CampaignStatus.completed,
      totalRecipients: 1200,
      sentCount: 1200,
      deliveredCount: 1150,
      readCount: 920,
      failedCount: 12,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Campaign(
      id: 'cmp_2',
      name: 'Weekend Flash Sale VIP',
      templateName: 'welcome_message',
      audienceSource: 'Tag: VIP',
      status: CampaignStatus.running,
      totalRecipients: 500,
      sentCount: 320,
      deliveredCount: 310,
      readCount: 240,
      failedCount: 4,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Campaign(
      id: 'cmp_3',
      name: 'New Arrivals Notification',
      templateName: 'welcome_message',
      audienceSource: 'Segment: All Active Leads',
      status: CampaignStatus.paused,
      totalRecipients: 850,
      sentCount: 200,
      deliveredCount: 195,
      readCount: 140,
      failedCount: 5,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Future<List<Campaign>> getCampaigns() async {
    await Future.delayed(const Duration(milliseconds: 150));
    // Simulate live delivery progress on running campaigns for real-time auto-refresh
    for (int i = 0; i < _campaigns.length; i++) {
      final c = _campaigns[i];
      if (c.status == CampaignStatus.running && c.sentCount < c.totalRecipients) {
        final newSent = (c.sentCount + 12).clamp(0, c.totalRecipients);
        final newDelivered = (c.deliveredCount + 11).clamp(0, newSent);
        final newRead = (c.readCount + 9).clamp(0, newDelivered);
        _campaigns[i] = c.copyWith(
          sentCount: newSent,
          deliveredCount: newDelivered,
          readCount: newRead,
          status: newSent >= c.totalRecipients ? CampaignStatus.completed : CampaignStatus.running,
        );
      }
    }
    return [..._campaigns];
  }

  @override
  Future<Campaign> createCampaign(Campaign campaign) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final created = campaign.copyWith(
      id: 'cmp_${DateTime.now().millisecondsSinceEpoch}',
      status: CampaignStatus.running,
      createdAt: DateTime.now(),
    );
    _campaigns.insert(0, created);
    return created;
  }

  @override
  Future<void> startCampaign(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _campaigns.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _campaigns[idx] = _campaigns[idx].copyWith(status: CampaignStatus.running);
    }
  }

  @override
  Future<void> pauseCampaign(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _campaigns.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _campaigns[idx] = _campaigns[idx].copyWith(status: CampaignStatus.paused);
    }
  }

  @override
  Future<void> resumeCampaign(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _campaigns.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _campaigns[idx] = _campaigns[idx].copyWith(status: CampaignStatus.running);
    }
  }
}
