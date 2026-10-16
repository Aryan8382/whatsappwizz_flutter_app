import '../../services/api_service.dart';
import '../../../features/campaigns/domain/campaign.dart';
import '../../../features/campaigns/domain/campaigns_repository.dart';

class CampaignsApiRepository implements CampaignsRepository {
  final ApiService _api;
  CampaignsApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<List<Campaign>> getCampaigns() async {
    final res = await _api.get<dynamic>('/campaigns');
    final list = res is List ? res : (res as Map?)?['items'] ?? [];
    return (list as List)
        .map((j) => Campaign.fromJson(Map<String, dynamic>.from(j as Map)))
        .toList();
  }

  @override
  Future<Campaign> createCampaign(Campaign campaign) async {
    final payload = <String, dynamic>{
      'name': campaign.name,
      'templateId': int.tryParse(campaign.templateId.toString()) ?? campaign.templateId,
      if (campaign.audience is Map && (campaign.audience as Map)['tagIds'] != null)
        'tagIds': (campaign.audience['tagIds'] as List).map((x) => int.parse(x.toString())).toList(),
      if (campaign.audience is Map && (campaign.audience as Map)['segmentIds'] != null)
        'segmentIds': (campaign.audience['segmentIds'] as List).map((x) => int.parse(x.toString())).toList(),
      if (campaign.scheduledAt != null)
        'scheduledAt': campaign.scheduledAt!.toIso8601String(),
      'ratePerMinute': campaign.ratePerMinute > 0 ? campaign.ratePerMinute : 60,
    };
    final res = await _api.post<dynamic>('/campaigns', payload);
    final created = Campaign.fromJson(Map<String, dynamic>.from(res as Map));
    if (campaign.scheduledAt == null && created.id != null) {
      try {
        await startCampaign(created.id.toString());
      } catch (_) {}
    }
    return created;
  }

  @override
  Future<void> startCampaign(String id) async {
    await _api.post('/campaigns/$id/start', {});
  }

  @override
  Future<void> pauseCampaign(String id) async {
    await _api.post('/campaigns/$id/pause', {});
  }

  @override
  Future<void> resumeCampaign(String id) async {
    await _api.post('/campaigns/$id/resume', {});
  }
}
