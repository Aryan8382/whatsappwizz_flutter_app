import 'package:flutter/foundation.dart';

class AppConstants {
  static const String appName = 'Whatsapp Wiz';
  static const String appVersion = '1.0.0';

  // ─── Backend URLs ──────────────────────────────────────────────────────
  // Permanent public HTTPS backend domain (works worldwide for APK testing):
  static const String publicBackendUrl = 'https://whatsappwiz.onrender.com';

  // Local fallback:
  static const String lanIp         = '192.168.29.134'; // Your PC WiFi IP
  static const String localLanUrl   = 'http://192.168.29.134:4000';
  static const String emulatorHost  = '10.0.2.2';       // Android Emulator host loopback

  // Optional compile-time override: flutter run --dart-define=API_URL=http://localhost:4000
  static const String _envApiUrl    = String.fromEnvironment('API_URL');
  static String? _customHost;

  static String? get customHost => _customHost;
  static set customHost(String? val) {
    if (val != null) {
      _customHost = val.trim().replaceAll(RegExp(r'/+$'), '');
    } else {
      _customHost = null;
    }
  }

  static String get defaultHost {
    if (_envApiUrl.isNotEmpty) return _envApiUrl;
    // Always default to live Render backend for all platforms (Web, Android, Desktop):
    return publicBackendUrl;
  }

  static String get apiHost => _customHost ?? defaultHost;
  static String get apiBaseUrl => '$apiHost/api/v1';
  static String get socketUrl  => apiHost;

  // ─── Meta Webhook config (matches backend .env) ───────────────────────
  static const String webhookVerifyToken = 'waba_verify_8f3k2x';
  static const String webhookPath        = '/api/v1/webhooks/meta';

  // ─── Demo credentials ────────────────────────────────────────────────
  static const String demoAdminEmail         = 'admin@demo.com';
  static const String demoAdminPassword      = 'Admin@123';
  static const String demoSupervisorEmail    = 'supervisor@demo.com';
  static const String demoSupervisorPassword = 'Supervisor@123';
  static const String demoAgentEmail         = 'agent@demo.com';
  static const String demoAgentPassword      = 'Agent@123';
  static const String demoResellerEmail      = 'reseller@demo.com';
  static const String demoResellerPassword   = 'Reseller@123';
  static const String demoSuperAdminEmail    = 'admin@whatsappwiz.io';
  static const String demoSuperAdminPassword = 'Admin@123';

  // ─── Storage keys ────────────────────────────────────────────────────
  static const String tokenKey        = 'ww_access_token';
  static const String refreshTokenKey = 'ww_refresh_token';
  static const String userKey         = 'ww_user';

  // ─── Business ────────────────────────────────────────────────────────
  static const double averageTemplateCostInr = 0.75;
}
