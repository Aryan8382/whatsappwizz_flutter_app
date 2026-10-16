import '../../../core/services/api_service.dart';
import '../domain/dashboard_repository.dart';
import '../domain/dashboard_stats.dart';

class ApiDashboardRepository implements DashboardRepository {
  final ApiService _api;
  ApiDashboardRepository({ApiService? api}) : _api = api ?? ApiService.instance;

  static double _toDouble(dynamic val, [double fallback = 0.0]) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? fallback;
    return fallback;
  }

  static int _toInt(dynamic val, [int fallback = 0]) {
    if (val == null) return fallback;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? fallback;
    return fallback;
  }

  static String _timeAgo(dynamic dateRaw) {
    if (dateRaw == null) return 'recently';
    final dt = DateTime.tryParse(dateRaw.toString());
    if (dt == null) return 'recently';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}';
  }

  @override
  Future<DashboardStats> getDashboardStats() async {
    try {
      final res = await _api.get<dynamic>('/reports/dashboard');
      final data = res is Map<String, dynamic> ? res : Map<String, dynamic>.from(res as Map);

      final kpis = data['kpis'] is Map ? data['kpis'] as Map : {};
      final messageTrend = (data['messageTrend'] as List?) ?? [];
      final recentConvs = (data['recentConversations'] as List?) ?? [];
      final campaigns = (data['campaigns'] as List?) ?? [];

      final hourly = <HourlyMessageMetric>[];
      for (int i = 0; i < messageTrend.length; i++) {
        final item = messageTrend[i] as Map?;
        if (item != null) {
          hourly.add(HourlyMessageMetric(
            hour: i,
            sent: _toInt(item['sent']),
            received: _toInt(item['received']),
          ));
        }
      }

      final recentSummaries = recentConvs.map((c) {
        final map = c as Map;
        final contact = map['contact'] as Map?;
        String contactName = '';
        if (contact != null) {
          final fn = contact['firstName'] as String? ?? contact['first_name'] as String? ?? '';
          final ln = contact['lastName'] as String? ?? contact['last_name'] as String? ?? '';
          contactName = '$fn $ln'.trim();
          if (contactName.isEmpty) {
            contactName = contact['mobile']?.toString() ??
                contact['phone']?.toString() ??
                contact['name']?.toString() ??
                'Contact';
          }
        }
        if (contactName.isEmpty) contactName = 'Contact';

        final messages = map['messages'] as List?;
        String lastMsg = '';
        if (messages != null && messages.isNotEmpty) {
          final first = messages.first;
          if (first is Map) {
            lastMsg = first['messageText'] as String? ??
                first['message_text'] as String? ??
                first['body'] as String? ??
                '';
          }
        }

        return RecentConversationSummary(
          id: map['id']?.toString() ?? '',
          contactName: contactName,
          lastMessage: lastMsg.isNotEmpty ? lastMsg : 'New conversation',
          timeAgo: _timeAgo(map['updatedAt'] ?? map['updated_at'] ?? map['createdAt']),
          unreadCount: _toInt(map['unreadCount'] ?? map['unread_count']),
        );
      }).toList();

      final recentCampSummaries = campaigns.map((camp) {
        final map = camp as Map;
        return RecentCampaignSummary(
          id: map['id']?.toString() ?? '',
          name: map['name'] as String? ?? 'Campaign',
          status: (map['status'] as String? ?? 'COMPLETED').toUpperCase(),
          sentCount: _toInt(map['sentCount'] ?? map['sent_count']),
        );
      }).toList();

      final sent = _toInt(kpis['messagesSent'] ?? kpis['messages_sent']);
      final freeWindowMsgs = _toInt(kpis['freeWindowMessages']);
      final savedInr = _toDouble(kpis['costSavedInr'], freeWindowMsgs * 0.75);
      final metaFees = _toDouble(kpis['metaFeesCharged']);
      final deliveredRate = _toDouble(kpis['deliveredRate'] ?? kpis['delivered_rate']);
      final readRate = _toDouble(kpis['readRate'] ?? kpis['read_rate']);
      final deliveredCount = _toInt(kpis['deliveredCount'], (sent * (deliveredRate / 100)).round());
      final readCount = _toInt(kpis['readCount'], (sent * (readRate / 100)).round());
      final resolutionRate = _toDouble(kpis['resolutionRate']);

      return DashboardStats(
        totalConversations: _toInt(kpis['totalConversations'] ?? kpis['total_conversations']),
        activeConversations: _toInt(kpis['openConversations'] ?? kpis['open_conversations']),
        messagesSent: sent,
        messagesReceived: _toInt(kpis['messagesReceived'] ?? kpis['messages_received']),
        messagesDelivered: deliveredCount,
        messagesRead: readCount,
        deliveredRate: deliveredRate,
        readRate: readRate,
        activeCampaigns: _toInt(kpis['activeCampaigns'] ?? kpis['active_campaigns']),
        freeWindowMessages: freeWindowMsgs,
        costSavedInr: savedInr,
        metaFeesCharged: metaFees,
        windowResolutionRate: resolutionRate,
        walletBalance: _toDouble(kpis['walletBalance'] ?? kpis['wallet_balance']),
        hourlyMetrics: hourly.isNotEmpty
            ? hourly
            : const [
                HourlyMessageMetric(hour: 0, sent: 0, received: 0),
                HourlyMessageMetric(hour: 12, sent: 0, received: 0),
              ],
        recentConversations: recentSummaries,
        recentCampaigns: recentCampSummaries,
      );
    } catch (e) {
      // Return safe empty stats with fallback
      return const DashboardStats(
        totalConversations: 0,
        activeConversations: 0,
        messagesSent: 0,
        messagesReceived: 0,
        messagesDelivered: 0,
        messagesRead: 0,
        activeCampaigns: 0,
        freeWindowMessages: 0,
        costSavedInr: 0,
        windowResolutionRate: 0,
        walletBalance: 0,
        hourlyMetrics: [],
        recentConversations: [],
        recentCampaigns: [],
      );
    }
  }
}
