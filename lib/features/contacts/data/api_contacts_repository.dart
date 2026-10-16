import '../../../core/services/api_service.dart';
import '../domain/contact.dart';
import '../domain/contacts_repository.dart';
import '../domain/segment.dart';

class ApiContactsRepository implements ContactsRepository {
  final ApiService _api;
  ApiContactsRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<List<Contact>> getContacts({String? query, String? tag}) async {
    final q = <String, dynamic>{'limit': 100};
    if (query != null && query.isNotEmpty) q['search'] = query;
    if (tag != null && tag.isNotEmpty && tag != 'All') q['tag'] = tag;

    final res = await _api.get<dynamic>('/contacts', query: q);
    final list = res is List ? res : (res as Map?)?['items'] ?? [];
    return (list as List)
        .map((j) => Contact.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Contact> createContact(Contact contact) async {
    final payload = {
      'firstName': contact.firstName,
      'lastName': contact.lastName,
      'mobile': contact.mobile,
      'email': contact.email,
      'city': contact.city,
      'state': contact.state,
      'country': contact.country,
      'optIn': contact.optIn,
      'tags': contact.tags,
      'customFields': contact.customFields,
    };
    final res = await _api.post<dynamic>('/contacts', payload);
    return Contact.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<Contact> updateContact(Contact contact) async {
    final payload = {
      'firstName': contact.firstName,
      'lastName': contact.lastName,
      'mobile': contact.mobile,
      'email': contact.email,
      'city': contact.city,
      'state': contact.state,
      'country': contact.country,
      'optIn': contact.optIn,
      'tags': contact.tags,
      'customFields': contact.customFields,
    };
    final res = await _api.put<dynamic>('/contacts/${contact.id}', payload);
    return Contact.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<void> deleteContact(String id) async {
    await _api.delete('/contacts/$id');
  }

  @override
  Future<List<String>> getAllTags() async {
    try {
      final res = await _api.get<dynamic>('/contacts/tags');
      if (res is List) {
        return res.map((t) => t is Map ? (t['name'] as String? ?? '') : t.toString()).toList();
      }
      return [];
    } catch (_) {
      return ['VIP', 'Lead', 'Customer', 'Wholesale', 'Support'];
    }
  }

  @override
  Future<void> createTag(String name) async {
    await _api.post('/contacts/tags', {'name': name});
  }

  @override
  Future<List<Segment>> getSegments() async {
    try {
      final res = await _api.get<dynamic>('/segments');
      final list = res is List ? res : (res as Map?)?['items'] ?? [];
      return (list as List)
          .map((j) => Segment.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Segment> createSegment({
    required String name,
    required String tagFilter,
    required bool optInOnly,
  }) async {
    final payload = {
      'name': name,
      'filters': {
        'tags': tagFilter.isNotEmpty ? [tagFilter] : [],
        'optIn': optInOnly,
      },
    };
    final res = await _api.post<dynamic>('/segments', payload);
    return Segment.fromJson(res as Map<String, dynamic>);
  }
}
