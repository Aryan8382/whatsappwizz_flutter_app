import '../../services/api_service.dart';

abstract class WalletApiRepositoryBase {
  Future<Map<String, dynamic>> getWallet();
  Future<List<Map<String, dynamic>>> getTransactions();
  Future<void> recharge(double amount);
  Future<Map<String, dynamic>> addTransaction(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getInvoices();
  Future<Map<String, dynamic>> getInvoice(dynamic id);
}

class WalletApiRepository implements WalletApiRepositoryBase {
  final ApiService _api;
  WalletApiRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  @override
  Future<Map<String, dynamic>> getWallet() async {
    final res = await _api.get<dynamic>('/wallet');
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactions() async {
    final res = await _api.get<dynamic>('/wallet/transactions');
    final list = res is List ? res : (res as Map?)?['items'] ?? [];
    return (list as List).map((j) => Map<String, dynamic>.from(j as Map)).toList();
  }

  @override
  Future<void> recharge(double amount) async {
    await _api.post('/wallet/recharge', {'amount': amount});
  }

  @override
  Future<Map<String, dynamic>> addTransaction(Map<String, dynamic> data) async {
    final res = await _api.post<dynamic>('/wallet/recharge', data);
    return Map<String, dynamic>.from(res as Map? ?? {});
  }

  @override
  Future<List<Map<String, dynamic>>> getInvoices() async {
    final res = await _api.get<dynamic>('/wallet/invoices');
    final list = res is List ? res : (res as Map?)?['items'] ?? [];
    return (list as List).map((j) => Map<String, dynamic>.from(j as Map)).toList();
  }

  @override
  Future<Map<String, dynamic>> getInvoice(dynamic id) async {
    final res = await _api.get<dynamic>('/wallet/invoices/$id');
    return Map<String, dynamic>.from(res as Map? ?? {});
  }
}
