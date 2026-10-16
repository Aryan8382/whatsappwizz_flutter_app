import 'package:dio/dio.dart';
import '../../services/api_service.dart';
import '../../../features/contacts/domain/contact.dart';
import '../../../features/contacts/domain/contacts_repository.dart';
import '../../../features/contacts/domain/segment.dart';

class ContactsApiRepository implements ContactsRepository {
  final ApiService _api;
  ContactsApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<List<Contact>> getContacts({String? query, String? tag}) async {
    final q = <String, dynamic>{};
    if (query != null && query.isNotEmpty) q['search'] = query;
    if (tag != null && tag.isNotEmpty) q['tag'] = tag;
    final res = await _api.get<dynamic>('/contacts', query: q);
    final list = _list(res);
    return list.map((j) => Contact.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Contact> createContact(Contact contact) async {
    final res = await _api.post<dynamic>('/contacts', contact.toJson());
    return Contact.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<Contact> updateContact(Contact contact) async {
    final res = await _api.put<dynamic>('/contacts/${contact.id}', contact.toJson());
    return Contact.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<void> deleteContact(String id) async {
    await _api.delete('/contacts/$id');
  }

  // ── Tags ──────────────────────────────────────────────────────────────

  @override
  Future<List<String>> getAllTags() async {
    final res = await _api.get<dynamic>('/contacts/tags');
    final list = _list(res);
    return list.map((t) {
      if (t is Map) return t['name']?.toString() ?? '';
      return t.toString();
    }).where((s) => s.isNotEmpty).toList();
  }

  Future<List<Map<String, dynamic>>> getAllTagsWithMeta() async {
    final res = await _api.get<dynamic>('/contacts/tags');
    final list = _list(res);
    return list.map((j) => Map<String, dynamic>.from(j as Map)).toList();
  }

  @override
  Future<void> createTag(String name) async {
    await _api.post('/contacts/tags', {'name': name, 'color': '#25D366'});
  }

  Future<void> deleteTag(dynamic tagId) async {
    await _api.delete('/contacts/tags/$tagId');
  }

  Future<List<Contact>> getContactsByTag(dynamic tagId) async {
    final res = await _api.get<dynamic>('/contacts/tags/$tagId/contacts');
    final list = _list(res);
    return list.map((j) => Contact.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<void> removeTagFromContact(dynamic tagId, dynamic contactId) async {
    await _api.delete('/contacts/tags/$tagId/contacts/$contactId');
  }

  // ── Import / Export ───────────────────────────────────────────────────

  Future<Map<String, dynamic>> importCsv(String filePath, String fileName) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final res = await _api.upload<dynamic>('/contacts/import', formData);
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  Future<String> exportCsv() async {
    return _api.getText('/contacts/export');
  }

  // ── Segments ──────────────────────────────────────────────────────────

  @override
  Future<List<Segment>> getSegments() async {
    final res = await _api.get<dynamic>('/segments');
    final list = _list(res);
    return list.map((j) => Segment.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Segment> createSegment({
    required String name,
    required String tagFilter,
    required bool optInOnly,
  }) async {
    final res = await _api.post<dynamic>('/segments', {
      'name': name,
      'filters': {
        if (tagFilter.isNotEmpty) 'tag': tagFilter,
        'optIn': optInOnly,
      },
    });
    return Segment.fromJson(res as Map<String, dynamic>);
  }

  // ── helpers ───────────────────────────────────────────────────────────

  List _list(dynamic res) {
    if (res is List) return res;
    if (res is Map) {
      if (res['contacts'] is List) return res['contacts'] as List;
      if (res['items'] is List) return res['items'] as List;
      if (res['data'] is List) return res['data'] as List;
    }
    return [];
  }
}
