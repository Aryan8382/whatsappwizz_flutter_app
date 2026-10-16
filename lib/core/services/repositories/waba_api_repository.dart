import '../api_service.dart';

class WabaAccountModel {
  final String id;
  final String wabaId;
  final String businessName;
  final String qualityRating;
  final String status;
  final List<WabaNumberModel> numbers;

  const WabaAccountModel({
    required this.id,
    required this.wabaId,
    required this.businessName,
    required this.qualityRating,
    required this.status,
    required this.numbers,
  });

  factory WabaAccountModel.fromJson(Map<String, dynamic> json) {
    final rawNumbers = json['numbers'] as List? ?? [];
    return WabaAccountModel(
      id: json['id']?.toString() ?? '',
      wabaId: json['wabaId']?.toString() ?? json['waba_id']?.toString() ?? '',
      businessName: json['businessId']?.toString() ?? json['business_name']?.toString() ?? 'WABA Account',
      qualityRating: json['qualityRating']?.toString() ?? json['quality_rating']?.toString() ?? 'GREEN',
      status: json['status']?.toString() ?? 'connected',
      numbers: rawNumbers.map((n) => WabaNumberModel.fromJson(n as Map<String, dynamic>)).toList(),
    );
  }
}

class WabaNumberModel {
  final String id;
  final String displayName;
  final String phone;
  final String phoneNumberId;
  final String qualityRating;
  final String status;

  const WabaNumberModel({
    required this.id,
    required this.displayName,
    required this.phone,
    required this.phoneNumberId,
    required this.qualityRating,
    required this.status,
  });

  factory WabaNumberModel.fromJson(Map<String, dynamic> json) {
    return WabaNumberModel(
      id: json['id']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? json['display_name']?.toString() ?? 'WhatsApp Number',
      phone: json['phoneNumber']?.toString() ?? json['phone']?.toString() ?? '',
      phoneNumberId: json['phoneNumberId']?.toString() ?? json['phone_number_id']?.toString() ?? '',
      qualityRating: json['qualityRating']?.toString() ?? json['quality_rating']?.toString() ?? 'GREEN',
      status: json['verificationStatus']?.toString() ?? json['status']?.toString() ?? 'connected',
    );
  }
}

class WabaApiRepository {
  final ApiService _api;
  WabaApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  Future<List<WabaAccountModel>> getAccounts() async {
    try {
      final res = await _api.get<dynamic>('/waba/status');
      final list = res is List ? res : (res as Map?)?['items'] ?? [];
      return (list as List).map((j) => WabaAccountModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<WabaNumberModel>> getNumbers() async {
    try {
      final res = await _api.get<dynamic>('/waba/numbers');
      final list = res is List ? res : (res as Map?)?['items'] ?? [];
      return (list as List).map((j) => WabaNumberModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
