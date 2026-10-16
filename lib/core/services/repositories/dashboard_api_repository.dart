import '../../services/api_service.dart';

abstract class DashboardApiRepositoryBase {
  Future<Map<String, dynamic>> getStats();
}

class DashboardApiRepository implements DashboardApiRepositoryBase {
  final ApiService _api;
  DashboardApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<Map<String, dynamic>> getStats() async {
    final res = await _api.get<dynamic>('/reports/dashboard');
    return Map<String, dynamic>.from(res as Map? ?? {});
  }
}
