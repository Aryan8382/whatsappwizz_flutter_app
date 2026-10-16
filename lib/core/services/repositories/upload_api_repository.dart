import 'package:dio/dio.dart';
import '../../services/api_service.dart';

abstract class UploadApiRepositoryBase {
  Future<Map<String, dynamic>> uploadFile(String filePath, String fileName);
  Future<Map<String, dynamic>> uploadBytes(List<int> bytes, String fileName, String mimeType);
}

class UploadApiRepository implements UploadApiRepositoryBase {
  final ApiService _api;
  UploadApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<Map<String, dynamic>> uploadFile(String filePath, String fileName) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final res = await _api.upload<dynamic>('/upload', formData);
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  @override
  Future<Map<String, dynamic>> uploadBytes(List<int> bytes, String fileName, String mimeType) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName, contentType: DioMediaType.parse(mimeType)),
    });
    final res = await _api.upload<dynamic>('/upload', formData);
    return Map<String, dynamic>.from(res as Map? ?? {});
  }
}
