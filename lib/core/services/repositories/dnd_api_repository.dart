import '../../services/api_service.dart';

abstract class DndApiRepositoryBase {
  Future<List<Map<String, dynamic>>> getEntries();
  Future<void> addEntry(String number, String? message);
  Future<void> removeEntry(dynamic id);
}

class DndApiRepository implements DndApiRepositoryBase {
  final ApiService _api;
  DndApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<List<Map<String, dynamic>>> getEntries() async {
    final res = await _api.get<dynamic>('/dnd');
    final list = res is List ? res : (res as Map?)?['items'] ?? [];
    return list.map((j) => Map<String, dynamic>.from(j as Map)).toList();
  }

  @override
  Future<void> addEntry(String number, String? message) async {
    await _api.post('/dnd', {
      'number': number,
      if (message != null && message.isNotEmpty) 'message': message,
    });
  }

  @override
  Future<void> removeEntry(dynamic id) async {
    await _api.delete('/dnd/$id');
  }
}
