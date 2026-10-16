import '../../../core/services/api_service.dart';
import '../domain/campaign.dart';
import '../domain/campaigns_repository.dart';

class ApiCampaignsRepository implements CampaignsRepository {
  final ApiService _api;
  ApiCampaignsRepository({ApiService? api}) : _api = api ?? ApiService.instance;

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
    final payload = {
      'name': campaign.name,
      'templateId': campaign.templateId,
      'audience': campaign.audience,
      'scheduledAt': campaign.scheduledAt?.toIso8601String(),
    };
    final res = await _api.post<dynamic>('/campaigns', payload);
    return Campaign.fromJson(Map<String, dynamic>.from(res as Map));
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
