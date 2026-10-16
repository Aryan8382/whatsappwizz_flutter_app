import '../../../core/services/api_service.dart';
import '../domain/template.dart';
import '../domain/templates_repository.dart';

class ApiTemplatesRepository implements TemplatesRepository {
  final ApiService _api;
  ApiTemplatesRepository({ApiService? api}) : _api = api ?? ApiService.instance;

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
    final payload = {
      'name': template.name,
      'category': template.category,
      'language': template.language,
      'body': template.body,
      if (template.header != null) 'header': template.header,
      if (template.footer != null) 'footer': template.footer,
      if (template.buttons.isNotEmpty) 'buttons': template.buttons,
    };
    final res = await _api.post<dynamic>('/templates', payload);
    return Template.fromJson(Map<String, dynamic>.from(res as Map));
  }

  @override
  Future<void> submitForApproval(String templateId) async {
    await _api.post('/templates/$templateId/submit', {});
  }

  @override
  Future<void> syncWithMeta() async {
    await _api.post('/templates/sync', {});
  }
}
