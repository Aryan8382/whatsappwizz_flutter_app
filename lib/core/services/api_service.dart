import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Central HTTP client — mirrors the web frontend's lib/api.ts exactly.
///
/// • Flutter web  → http://localhost:4000/api/v1
/// • Android emu  → http://10.0.2.2:4000/api/v1
/// • Auto-attaches Bearer token from secure storage
/// • On 401 → clears local session
/// • Unwraps NestJS TransformInterceptor envelope { data: ... }
/// • Throws ApiException on HTTP errors
class ApiService {
  static ApiService? _instance;
  static ApiService get instance {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  late final Dio _dio;
  final FlutterSecureStorage _storage;
  final Map<String, String> _memoryCache = {};

  ApiService._internal()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          webOptions: WebOptions(dbName: 'ww_storage'),
        ) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      // Don't set Content-Type globally — Dio sets it per-request correctly
      // Setting it globally causes CORS preflight failures on web
      validateStatus: (s) => s != null && s < 600,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (opts, handler) async {
        // Attach auth token
        final token = await getToken();
        if (token != null && token.isNotEmpty) {
          opts.headers['Authorization'] = 'Bearer $token';
        }
        // Bypass ngrok free tier browser warning interstitial (native mobile or ngrok endpoints)
        if (!kIsWeb || opts.path.contains('ngrok') || opts.baseUrl.contains('ngrok')) {
          opts.headers['ngrok-skip-browser-warning'] = 'true';
        }
        // Set JSON content type only when sending a body (avoids CORS preflight on GET)
        if (opts.data != null && opts.data is! FormData) {
          opts.headers['Content-Type'] = 'application/json';
        }
        handler.next(opts);
      },
      onResponse: (res, handler) {
        if (res.statusCode == 401) clearSession();
        handler.next(res);
      },
    ));
  }

  // ─── Safe storage helpers ─────────────────────────────────────────────

  Future<void> _safeWrite(String key, String value) async {
    _memoryCache[key] = value;
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {}
  }

  Future<String?> _safeRead(String key) async {
    if (_memoryCache.containsKey(key)) return _memoryCache[key];
    try {
      final val = await _storage.read(key: key);
      if (val != null) _memoryCache[key] = val;
      return val;
    } catch (_) {
      return _memoryCache[key];
    }
  }

  Future<void> _safeDelete(String key) async {
    _memoryCache.remove(key);
    try {
      await _storage.delete(key: key);
    } catch (_) {}
  }

  // ─── Session helpers ──────────────────────────────────────────────────

  Future<String?> getToken() => _safeRead(AppConstants.tokenKey);

  Future<void> setSession({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> user,
  }) async {
    await _safeWrite(AppConstants.tokenKey, accessToken);
    await _safeWrite(AppConstants.refreshTokenKey, refreshToken);
    await _safeWrite(AppConstants.userKey, jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getStoredUser() async {
    final raw = await _safeRead(AppConstants.userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getRefreshToken() =>
      _safeRead(AppConstants.refreshTokenKey);

  Future<void> clearSession() async {
    await _safeDelete(AppConstants.tokenKey);
    await _safeDelete(AppConstants.refreshTokenKey);
    await _safeDelete(AppConstants.userKey);
  }

  String get currentHost => AppConstants.apiHost;

  /// Load any user-selected server host on app startup
  Future<void> initHost() async {
    final saved = await _safeRead('ww_server_host');
    if (saved != null && saved.isNotEmpty) {
      AppConstants.customHost = saved;
      _dio.options.baseUrl = AppConstants.apiBaseUrl;
    }
  }

  /// Switch the active backend host (e.g. Ngrok vs Local LAN)
  Future<void> setHost(String host) async {
    final clean = host.trim().replaceAll(RegExp(r'/+$'), '');
    AppConstants.customHost = clean;
    _dio.options.baseUrl = AppConstants.apiBaseUrl;
    await _safeWrite('ww_server_host', clean);
  }

  /// Fast connectivity probe against a host candidate
  Future<bool> pingHost(String host) async {
    final clean = host.trim().replaceAll(RegExp(r'/+$'), '');
    try {
      final probeDio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
        validateStatus: (s) => s != null && s < 600,
        headers: {'ngrok-skip-browser-warning': 'true'},
      ));
      final res = await probeDio.get('$clean/api/v1/auth/me');
      // If NestJS answers with 401 Unauthorized or 200, the server is live and reachable!
      return res.statusCode == 200 || res.statusCode == 401 || res.statusCode == 403;
    } catch (_) {
      return false;
    }
  }

  // ─── HTTP Methods with Transparent Auto-Failover ──────────────────────

  Future<T> get<T>(String path, {Map<String, dynamic>? query}) async {
    return _execWithFailover((d) => d.get(path, queryParameters: query));
  }

  Future<T> post<T>(String path, [dynamic data]) async {
    return _execWithFailover((d) => d.post(
          path,
          data: data,
          options: Options(contentType: 'application/json'),
        ));
  }

  Future<T> put<T>(String path, [dynamic data]) async {
    return _execWithFailover((d) => d.put(
          path,
          data: data,
          options: Options(contentType: 'application/json'),
        ));
  }

  Future<T> patch<T>(String path, [dynamic data]) async {
    return _execWithFailover((d) => d.patch(
          path,
          data: data,
          options: Options(contentType: 'application/json'),
        ));
  }

  Future<T> delete<T>(String path) async {
    return _execWithFailover((d) => d.delete(path));
  }

  Future<T> upload<T>(String path, FormData formData) async {
    return _execWithFailover((d) => d.post(path, data: formData));
  }

  Future<String> getText(String path) async {
    final res = await _dio.get<String>(
      path,
      options: Options(responseType: ResponseType.plain),
    );
    _checkError(res);
    return res.data ?? '';
  }

  /// Executes an API call. If the current host fails with 404 (e.g. tunnel down)
  /// or network connection error, automatically tries the alternate candidate once.
  Future<T> _execWithFailover<T>(Future<Response> Function(Dio client) request) async {
    try {
      final res = await request(_dio);
      return _handle<T>(res);
    } on ApiException catch (e) {
      if (e.statusCode == 404 && !kIsWeb) {
        // Try alternate host on mobile
        final switched = await _tryAutoFailover();
        if (switched) {
          final retryRes = await request(_dio);
          return _handle<T>(retryRes);
        }
      }
      rethrow;
    } on DioException catch (dioErr) {
      if (!kIsWeb) {
        final switched = await _tryAutoFailover();
        if (switched) {
          final retryRes = await request(_dio);
          return _handle<T>(retryRes);
        }
      }
      final statusCode = dioErr.response?.statusCode ?? 503;
      final msg = dioErr.type == DioExceptionType.connectionTimeout
          ? 'Connection timed out. Server unreachable.'
          : (dioErr.type == DioExceptionType.connectionError
              ? 'Cannot connect to backend server. Verify WiFi or Ngrok.'
              : dioErr.message ?? 'Network error ($statusCode)');
      throw ApiException(msg, statusCode);
    }
  }

  bool _isFailingOver = false;
  Future<bool> _tryAutoFailover() async {
    if (_isFailingOver) return false;
    _isFailingOver = true;
    try {
      final active = currentHost;
      final alternate = active == AppConstants.publicBackendUrl
          ? AppConstants.localLanUrl
          : AppConstants.publicBackendUrl;

      final isAltAlive = await pingHost(alternate);
      if (isAltAlive) {
        debugPrint('[ApiService] Auto-switched server from $active to $alternate');
        await setHost(alternate);
        return true;
      }
      return false;
    } finally {
      _isFailingOver = false;
    }
  }

  // ─── Internal ─────────────────────────────────────────────────────────

  T _handle<T>(Response res) {
    _checkError(res);
    return _unwrap<T>(res.data);
  }

  void _checkError(Response res) {
    final code = res.statusCode ?? 0;
    if (code == 401) {
      clearSession();
      throw const ApiException('Unauthorized', 401);
    }
    if (code >= 400) {
      final body = res.data;
      String message = 'Request failed ($code)';
      if (body is Map) {
        final m = body['message'];
        if (m is String) message = m;
        if (m is List) message = m.join(', ');
      } else if (code == 404) {
        message = 'Server unreachable (404). Backend offline or tunnel URL changed.';
      } else if (code >= 500) {
        message = 'Server internal error ($code). Please check backend logs.';
      }
      throw ApiException(message, code);
    }
  }

  /// Unwrap NestJS TransformInterceptor envelope: { data: T }
  T _unwrap<T>(dynamic body) {
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'] as T;
    }
    return body as T;
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  const ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
