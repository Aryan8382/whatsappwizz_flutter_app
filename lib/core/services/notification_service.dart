import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import 'realtime_service.dart';

enum NotificationType {
  message,
  campaign,
  template,
  system,
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final Map<String, dynamic>? data;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.data,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}

class NotificationState {
  final List<AppNotification> notifications;
  final bool isLoading;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final ApiService _api;
  final RealtimeService _realtime;
  Function? _cancelMessageListener;
  Function? _cancelCampaignListener;
  Function? _cancelTemplateListener;

  NotificationNotifier({
    ApiService? api,
    RealtimeService? realtime,
  })  : _api = api ?? ApiService.instance,
        _realtime = realtime ?? RealtimeService.instance,
        super(const NotificationState()) {
    _init();
  }

  Future<void> _init() async {
    await loadInitialNotifications();
    _listenToRealtimeEvents();
  }

  void _listenToRealtimeEvents() {
    // 1. Live incoming messages
    _cancelMessageListener = _realtime.on('message:new', (data) {
      if (data is Map) {
        final text = data['text'] ?? data['messageText'] ?? 'New message received';
        final senderType = data['senderType']?.toString().toUpperCase() ?? 'CONTACT';
        final contactObj = data['contact'] is Map ? data['contact'] : null;
        final contactName = contactObj?['name'] ?? contactObj?['firstName'] ?? data['senderName'] ?? 'Customer';

        // Notify if it's an incoming customer message
        if (senderType != 'USER' && senderType != 'AGENT') {
          addNotification(
            title: 'New WhatsApp Message',
            body: '$contactName: $text',
            type: NotificationType.message,
            data: {
              'conversationId': data['conversationId']?.toString(),
              'phone': contactObj?['phone']?.toString(),
            },
          );
        }
      }
    });

    // 2. Live campaign updates
    _cancelCampaignListener = _realtime.on('campaign:updated', (data) {
      if (data is Map) {
        final name = data['name'] ?? 'Broadcast';
        final status = data['status']?.toString().toUpperCase() ?? 'COMPLETED';
        addNotification(
          title: 'Campaign Update',
          body: "Broadcast '$name' is now $status",
          type: NotificationType.campaign,
          data: {'campaignId': data['id']?.toString()},
        );
      }
    });

    // 3. Live template approvals / rejections
    _cancelTemplateListener = _realtime.on('template:status', (data) {
      if (data is Map) {
        final name = data['name'] ?? 'Template';
        final status = data['status']?.toString().toUpperCase() ?? 'APPROVED';
        addNotification(
          title: 'Template Status Changed',
          body: "Template '$name' has been $status by Meta",
          type: NotificationType.template,
          data: {'templateId': data['id']?.toString()},
        );
      }
    });
  }

  Future<void> loadInitialNotifications() async {
    state = state.copyWith(isLoading: true);
    final List<AppNotification> items = [];

    try {
      // 1. Fetch recent live conversations with incoming messages
      final convRes = await _api.get<dynamic>('/conversations', query: {'limit': 5});
      final convList = convRes is List
          ? convRes
          : (convRes is Map ? (convRes['conversations'] ?? convRes['items'] ?? []) : []);

      for (var c in convList) {
        if (c is Map) {
          final cId = c['id']?.toString() ?? '';
          final contact = c['contact'] is Map ? c['contact'] : {};
          final name = contact['name'] ?? contact['firstName'] ?? contact['mobile'] ?? 'Customer';
          final lastMsg = c['lastMessage'] is Map
              ? (c['lastMessage']['text'] ?? c['lastMessage']['content'])
              : (c['lastMessageText'] ?? 'Recent chat');
          final updatedAt = c['updatedAt'] != null || c['updated_at'] != null
              ? DateTime.tryParse((c['updatedAt'] ?? c['updated_at']).toString()) ?? DateTime.now()
              : DateTime.now();
          final unreadCount = (c['unreadCount'] as num?)?.toInt() ?? 0;

          items.add(AppNotification(
            id: 'conv_$cId',
            title: unreadCount > 0 ? '$unreadCount New message${unreadCount > 1 ? 's' : ''}' : 'WhatsApp Chat',
            body: '$name: $lastMsg',
            timestamp: updatedAt,
            type: NotificationType.message,
            isRead: unreadCount == 0,
            data: {'conversationId': cId},
          ));
        }
      }
    } catch (_) {}

    try {
      // 2. Fetch live campaigns
      final campRes = await _api.get<dynamic>('/campaigns', query: {'limit': 3});
      final campList = campRes is List
          ? campRes
          : (campRes is Map ? (campRes['campaigns'] ?? campRes['items'] ?? []) : []);

      for (var camp in campList) {
        if (camp is Map) {
          final id = camp['id']?.toString() ?? '';
          final name = camp['name'] ?? 'Campaign';
          final status = camp['status']?.toString().toUpperCase() ?? 'COMPLETED';
          final updatedAt = camp['updatedAt'] != null
              ? DateTime.tryParse(camp['updatedAt'].toString()) ?? DateTime.now()
              : DateTime.now();

          items.add(AppNotification(
            id: 'camp_$id',
            title: 'Campaign Status',
            body: "Broadcast '$name' is $status",
            timestamp: updatedAt,
            type: NotificationType.campaign,
            isRead: true,
            data: {'campaignId': id},
          ));
        }
      }
    } catch (_) {}

    try {
      // 3. Fetch live templates
      final tempRes = await _api.get<dynamic>('/templates', query: {'limit': 3});
      final tempList = tempRes is List
          ? tempRes
          : (tempRes is Map ? (tempRes['templates'] ?? tempRes['items'] ?? []) : []);

      for (var t in tempList) {
        if (t is Map) {
          final id = t['id']?.toString() ?? '';
          final name = t['name'] ?? 'Template';
          final status = t['status']?.toString().toUpperCase() ?? 'APPROVED';
          final updatedAt = t['updatedAt'] != null
              ? DateTime.tryParse(t['updatedAt'].toString()) ?? DateTime.now()
              : DateTime.now();

          if (status == 'APPROVED' || status == 'REJECTED') {
            items.add(AppNotification(
              id: 'temp_$id',
              title: 'Template $status',
              body: "Template '$name' is $status for sending",
              timestamp: updatedAt,
              type: NotificationType.template,
              isRead: true,
              data: {'templateId': id},
            ));
          }
        }
      }
    } catch (_) {}

    // Sort by timestamp descending
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    state = state.copyWith(
      notifications: items,
      isLoading: false,
    );
  }

  void addNotification({
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? data,
  }) {
    final newItem = AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
      isRead: false,
      data: data,
    );

    state = state.copyWith(
      notifications: [newItem, ...state.notifications],
    );
  }

  void markAllAsRead() {
    final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updated);
  }

  void clearAll() {
    state = state.copyWith(notifications: const []);
  }

  void markAsRead(String id) {
    final updated = state.notifications.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  void removeNotification(String id) {
    final updated = state.notifications.where((n) => n.id != id).toList();
    state = state.copyWith(notifications: updated);
  }

  @override
  void dispose() {
    _cancelMessageListener?.call();
    _cancelCampaignListener?.call();
    _cancelTemplateListener?.call();
    super.dispose();
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});
