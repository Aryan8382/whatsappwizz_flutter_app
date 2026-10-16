import 'contact.dart';
import 'segment.dart';

abstract class ContactsRepository {
  Future<List<Contact>> getContacts({String? query, String? tag});
  Future<Contact> createContact(Contact contact);
  Future<Contact> updateContact(Contact contact);
  Future<void> deleteContact(String id);
  Future<List<String>> getAllTags();
  Future<void> createTag(String name);
  Future<List<Segment>> getSegments();
  Future<Segment> createSegment({
    required String name,
    required String tagFilter,
    required bool optInOnly,
  });
}
