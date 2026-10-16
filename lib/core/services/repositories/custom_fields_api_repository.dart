import '../../services/api_service.dart';
import '../../../features/custom_fields/domain/custom_field.dart';

abstract class CustomFieldsApiRepositoryBase {
  Future<List<CustomField>> getFields();
  Future<CustomField> createField(Map<String, dynamic> data);
  Future<CustomField> updateField(dynamic id, Map<String, dynamic> data);
  Future<void> deleteField(dynamic id);
}

class CustomFieldsApiRepository implements CustomFieldsApiRepositoryBase {
  final ApiService _api;
  CustomFieldsApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<List<CustomField>> getFields() async {
    final res = await _api.get<dynamic>('/custom-fields');
    final list = res is List ? res : (res as Map?)?['items'] ?? [];
    return (list as List).map((j) {
      final m = j as Map<String, dynamic>;
      return CustomField(
        id: m['id']?.toString() ?? '',
        name: m['name'] ?? '',
        key: (m['name'] ?? '').toString().toLowerCase().replaceAll(' ', '_'),
        type: (m['field_type'] ?? m['fieldType'] ?? 'TEXT').toString().toUpperCase(),
      );
    }).toList();
  }

  @override
  Future<CustomField> createField(Map<String, dynamic> data) async {
    final res = await _api.post<dynamic>('/custom-fields', data);
    final m = res as Map<String, dynamic>;
    return CustomField(
      id: m['id']?.toString() ?? '',
      name: m['name'] ?? '',
      key: (m['name'] ?? '').toString().toLowerCase().replaceAll(' ', '_'),
      type: (m['field_type'] ?? 'TEXT').toString().toUpperCase(),
    );
  }

  @override
  Future<CustomField> updateField(dynamic id, Map<String, dynamic> data) async {
    final res = await _api.put<dynamic>('/custom-fields/$id', data);
    final m = res as Map<String, dynamic>;
    return CustomField(
      id: m['id']?.toString() ?? '',
      name: m['name'] ?? '',
      key: (m['name'] ?? '').toString().toLowerCase().replaceAll(' ', '_'),
      type: (m['field_type'] ?? 'TEXT').toString().toUpperCase(),
    );
  }

  @override
  Future<void> deleteField(dynamic id) async {
    await _api.delete('/custom-fields/$id');
  }
}
