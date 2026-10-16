import 'package:dio/dio.dart';
import '../../services/api_service.dart';

abstract class MediaApiRepositoryBase {
  Future<List<Map<String, dynamic>>> getMedia();
  Future<Map<String, dynamic>> addMedia(Map<String, dynamic> data);
  Future<Map<String, dynamic>> uploadFile(String filePath, String fileName, String mimeType);
  Future<void> deleteMedia(dynamic id);
}

class MediaApiRepository implements MediaApiRepositoryBase {
  final ApiService _api;
  MediaApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<List<Map<String, dynamic>>> getMedia() async {
    final res = await _api.get<dynamic>('/media');
    final list = res is List ? res : (res as Map?)?['items'] ?? [];
    return list.map((j) => Map<String, dynamic>.from(j as Map)).toList();
  }

  @override
  Future<Map<String, dynamic>> addMedia(Map<String, dynamic> data) async {
    final res = await _api.post<dynamic>('/media', data);
    return Map<String, dynamic>.from(res as Map);
  }

  @override
  Future<Map<String, dynamic>> uploadFile(String filePath, String fileName, String mimeType) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final res = await _api.upload<dynamic>('/upload', formData);
    return Map<String, dynamic>.from(res as Map);
  }

  @override
  Future<void> deleteMedia(dynamic id) async {
    await _api.delete('/media/$id');
  }
}
