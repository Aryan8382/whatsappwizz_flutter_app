import '../api_service.dart';

class LibraryTemplateModel {
  final String id;
  final String name;
  final String type;
  final String language;
  final List<String> industry;
  final List<String> topic;
  final List<String> useCase;
  final String? header;
  final String body;
  final String? footer;
  final String? buttonLabel;

  const LibraryTemplateModel({
    required this.id,
    required this.name,
    required this.type,
    this.language = 'en_US',
    this.industry = const [],
    this.topic = const [],
    this.useCase = const [],
    this.header,
    required this.body,
    this.footer,
    this.buttonLabel,
  });

  factory LibraryTemplateModel.fromJson(Map<String, dynamic> json) {
    return LibraryTemplateModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Template',
      type: json['type']?.toString() ?? 'UTILITY',
      language: json['language']?.toString() ?? 'en_US',
      industry: (json['industry'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      topic: (json['topic'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      useCase: (json['useCase'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      header: json['header']?.toString(),
      body: json['body']?.toString() ?? '',
      footer: json['footer']?.toString(),
      buttonLabel: json['buttonLabel']?.toString(),
    );
  }
}

class TemplateLibraryApiRepository {
  final ApiService _api;
  TemplateLibraryApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  Future<List<LibraryTemplateModel>> getTemplates({String? type, String? search}) async {
    final query = <String, dynamic>{
      'limit': 50,
    };
    if (type != null && type.isNotEmpty && type != 'ALL') {
      query['type'] = type;
    }
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }

    final res = await _api.get<dynamic>('/template-library', query: query);
    final items = res is Map ? (res['items'] ?? []) : (res is List ? res : []);
    return (items as List)
        .map((j) => LibraryTemplateModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}
