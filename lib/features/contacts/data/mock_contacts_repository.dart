import '../domain/contact.dart';
import '../domain/contacts_repository.dart';
import '../domain/segment.dart';

class MockContactsRepository implements ContactsRepository {
  final List<Contact> _contacts = [
    Contact(
      id: 'c1',
      firstName: 'Ravi',
      lastName: 'Kumar',
      mobile: '919111111111',
      email: 'ravi.kumar@example.com',
      optIn: true,
      tags: ['VIP', 'Customer'],
      source: 'seed',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    Contact(
      id: 'c2',
      firstName: 'Priya',
      lastName: 'Sharma',
      mobile: '919222222222',
      email: 'priya.sharma@example.com',
      optIn: true,
      tags: ['Lead'],
      source: 'seed',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Contact(
      id: 'c3',
      firstName: 'Amit',
      lastName: 'Patel',
      mobile: '919333333333',
      email: 'amit.patel@example.com',
      optIn: true,
      tags: ['Customer', 'Billing'],
      source: 'seed',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    Contact(
      id: 'c4',
      firstName: 'Sneha',
      lastName: 'Gupta',
      mobile: '919444444444',
      email: 'sneha.gupta@example.com',
      optIn: false,
      tags: ['Lead'],
      source: 'seed',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Contact(
      id: 'c5',
      firstName: 'Vikram',
      lastName: 'Singh',
      mobile: '919555555555',
      email: 'vikram.singh@example.com',
      optIn: true,
      tags: ['VIP'],
      source: 'seed',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  final List<String> _tags = ['VIP', 'Customer', 'Lead', 'Billing', 'Support'];

  final List<Segment> _segments = [
    const Segment(
      id: 'seg_1',
      name: 'VIP High Value',
      tagFilter: 'VIP',
      optInOnly: true,
      estimatedCount: 2,
    ),
    const Segment(
      id: 'seg_2',
      name: 'All Active Leads',
      tagFilter: 'Lead',
      optInOnly: true,
      estimatedCount: 1,
    ),
    const Segment(
      id: 'seg_3',
      name: 'Customers (All)',
      tagFilter: 'Customer',
      optInOnly: true,
      estimatedCount: 2,
    ),
  ];

  @override
  Future<List<Contact>> getContacts({String? query, String? tag}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var list = [..._contacts];

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((c) {
        return c.fullName.toLowerCase().contains(q) ||
            c.mobile.contains(q) ||
            (c.email?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    if (tag != null && tag.isNotEmpty) {
      list = list.where((c) => c.tags.contains(tag)).toList();
    }

    return list;
  }

  @override
  Future<Contact> createContact(Contact contact) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newContact = contact.copyWith(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
    _contacts.insert(0, newContact);
    return newContact;
  }

  @override
  Future<Contact> updateContact(Contact contact) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final idx = _contacts.indexWhere((c) => c.id == contact.id);
    if (idx != -1) {
      _contacts[idx] = contact;
    }
    return contact;
  }

  @override
  Future<void> deleteContact(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _contacts.removeWhere((c) => c.id == id);
  }

  @override
  Future<List<String>> getAllTags() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return [..._tags];
  }

  @override
  Future<void> createTag(String name) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!_tags.contains(name)) _tags.add(name);
  }

  @override
  Future<List<Segment>> getSegments() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [..._segments];
  }

  @override
  Future<Segment> createSegment({
    required String name,
    required String tagFilter,
    required bool optInOnly,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final count = _contacts.where((c) {
      if (optInOnly && !c.optIn) return false;
      if (tagFilter.isNotEmpty && !c.tags.contains(tagFilter)) return false;
      return true;
    }).length;

    final seg = Segment(
      id: 'seg_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      tagFilter: tagFilter,
      optInOnly: optInOnly,
      estimatedCount: count,
    );
    _segments.insert(0, seg);
    return seg;
  }
}
