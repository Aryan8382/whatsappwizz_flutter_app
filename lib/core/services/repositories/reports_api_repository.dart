import '../../services/api_service.dart';

abstract class ReportsApiRepositoryBase {
  Future<Map<String, dynamic>> getDashboard();
  Future<Map<String, dynamic>> getMessageReports({String? from, String? to});
  Future<Map<String, dynamic>> getCampaignReports({String? from, String? to});
  Future<Map<String, dynamic>> getAgentReports({String? from, String? to});
  Future<String> exportReports({String? from, String? to, String? type});
}

class ReportsApiRepository implements ReportsApiRepositoryBase {
  final ApiService _api;
  ReportsApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<Map<String, dynamic>> getDashboard() async {
    final res = await _api.get<dynamic>('/reports/dashboard');
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  @override
  Future<Map<String, dynamic>> getMessageReports({String? from, String? to}) async {
    final q = <String, dynamic>{};
    if (from != null) q['from'] = from;
    if (to != null) q['to'] = to;
    final res = await _api.get<dynamic>('/reports/messages', query: q);
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  @override
  Future<Map<String, dynamic>> getCampaignReports({String? from, String? to}) async {
    final q = <String, dynamic>{};
    if (from != null) q['from'] = from;
    if (to != null) q['to'] = to;
    final res = await _api.get<dynamic>('/reports/campaigns', query: q);
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  @override
  Future<Map<String, dynamic>> getAgentReports({String? from, String? to}) async {
    final q = <String, dynamic>{};
    if (from != null) q['from'] = from;
    if (to != null) q['to'] = to;
    final res = await _api.get<dynamic>('/reports/agents', query: q);
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  @override
  Future<String> exportReports({String? from, String? to, String? type}) async {
    final q = <String, dynamic>{};
    if (from != null) q['from'] = from;
    if (to != null) q['to'] = to;
    if (type != null) q['type'] = type;
    return _api.getText('/reports/export');
  }
}
