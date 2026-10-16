import '../../services/api_service.dart';
import '../../../features/contacts/domain/segment.dart';

abstract class SegmentsApiRepositoryBase {
  Future<List<Segment>> getSegments();
  Future<Map<String, dynamic>> previewSegment(Map<String, dynamic> filters);
  Future<Segment> getSegment(dynamic id);
  Future<Segment> createSegment(Map<String, dynamic> data);
  Future<Segment> updateSegment(dynamic id, Map<String, dynamic> data);
  Future<void> deleteSegment(dynamic id);
}

class SegmentsApiRepository implements SegmentsApiRepositoryBase {
  final ApiService _api;
  SegmentsApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<List<Segment>> getSegments() async {
    final res = await _api.get<dynamic>('/segments');
    final list = res is List ? res : (res as Map?)?['items'] ?? [];
    return list.map((j) => Segment.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<Map<String, dynamic>> previewSegment(Map<String, dynamic> filters) async {
    final res = await _api.post<dynamic>('/segments/preview', filters);
    return Map<String, dynamic>.from(res as Map);
  }

  @override
  Future<Segment> getSegment(dynamic id) async {
    final res = await _api.get<dynamic>('/segments/$id');
    return Segment.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<Segment> createSegment(Map<String, dynamic> data) async {
    final res = await _api.post<dynamic>('/segments', data);
    return Segment.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<Segment> updateSegment(dynamic id, Map<String, dynamic> data) async {
    final res = await _api.put<dynamic>('/segments/$id', data);
    return Segment.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<void> deleteSegment(dynamic id) async {
    await _api.delete('/segments/$id');
  }
}
