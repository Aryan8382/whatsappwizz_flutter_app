import 'template.dart';

abstract class TemplatesRepository {
  Future<List<Template>> getTemplates();
  Future<Template> createTemplate(Template template);
  Future<void> submitForApproval(String templateId);
  Future<void> syncWithMeta();
}
