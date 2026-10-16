import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../constants/app_constants.dart';

/// Socket.IO realtime service — mirrors the web frontend's lib/socket.ts
///
/// Connects to NestJS RealtimeGateway at the backend URL.
/// Joins the org room automatically on connect.
/// Provides stream-based listeners for:
///   - message:new      → new inbound/outbound message
///   - message:status   → delivery/read status update
///   - conversation:new → new conversation opened
///   - template:status  → Meta template approval status change
class RealtimeService {
  static RealtimeService? _instance;
  static RealtimeService get instance {
    _instance ??= RealtimeService._internal();
    return _instance!;
  }

  io.Socket? _socket;
  String? _currentOrgId;
  bool _connected = false;

  RealtimeService._internal();

  bool get isConnected => _connected;

  /// Connect and join org room. Call after login.
  void connect({required String token, required String organizationId, bool force = false}) {
    if (!force && _socket != null && _connected && _currentOrgId == organizationId) return;

    _currentOrgId = organizationId;
    disconnect(); // clean up any old socket

    _socket = io.io(
      AppConstants.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': token, 'organizationId': organizationId})
          .setQuery({'organizationId': organizationId})
          .setExtraHeaders({'ngrok-skip-browser-warning': 'true'})
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.onConnect((_) {
      _connected = true;
      debugPrint('✅ Socket.IO connected to ${AppConstants.socketUrl}');
      // Join org room explicitly
      _socket!.emit('join', {'organizationId': organizationId});
    });

    _socket!.onDisconnect((_) {
      _connected = false;
      debugPrint('🔌 Socket.IO disconnected');
    });

    _socket!.onConnectError((err) {
      debugPrint('❌ Socket.IO connect error: $err');
    });

    _socket!.connect();
  }

  /// Listen to a specific event. Returns a cancel function.
  Function on(String event, Function(dynamic data) handler) {
    _socket?.on(event, handler);
    return () => _socket?.off(event, handler);
  }

  /// One-time listener
  void once(String event, Function(dynamic data) handler) {
    _socket?.once(event, handler);
  }

  /// Emit an event to the server
  void emit(String event, [dynamic data]) {
    _socket?.emit(event, data);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connected = false;
  }
}
