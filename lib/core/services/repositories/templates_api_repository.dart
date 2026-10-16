import '../../services/api_service.dart';
import '../../../features/templates/domain/template.dart';
import '../../../features/templates/domain/templates_repository.dart';

class TemplatesApiRepository implements TemplatesRepository {
  final ApiService _api;
  TemplatesApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<List<Template>> getTemplates() async {
    final res = await _api.get<dynamic>('/templates');
    final list = res is List ? res : (res as Map?)?['items'] ?? [];
    return (list as List)
        .map((j) => Template.fromJson(Map<String, dynamic>.from(j as Map)))
        .toList();
  }

  @override
  Future<Template> createTemplate(Template template) async {
    final res = await _api.post<dynamic>('/templates', template.toJson());
    return Template.fromJson(Map<String, dynamic>.from(res as Map));
  }

  @override
  Future<void> submitForApproval(String templateId) async {
    await _api.post('/templates/$templateId/submit');
  }

  @override
  Future<void> syncWithMeta() async {
    await _api.post('/templates/sync');
  }
}
