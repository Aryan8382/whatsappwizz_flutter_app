import 'campaign.dart';

abstract class CampaignsRepository {
  Future<List<Campaign>> getCampaigns();
  Future<Campaign> createCampaign(Campaign campaign);
  Future<void> startCampaign(String id);
  Future<void> pauseCampaign(String id);
  Future<void> resumeCampaign(String id);
}
