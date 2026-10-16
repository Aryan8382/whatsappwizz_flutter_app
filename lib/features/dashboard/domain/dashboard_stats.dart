class DashboardStats {
  final int totalConversations;
  final int activeConversations;
  final int messagesSent;
  final int messagesReceived;
  final int messagesDelivered;
  final int messagesRead;
  final double deliveredRate;
  final double readRate;
  final int activeCampaigns;
  final int freeWindowMessages;
  final double costSavedInr;
  final double metaFeesCharged;
  final double windowResolutionRate;
  final double walletBalance;
  final List<HourlyMessageMetric> hourlyMetrics;
  final List<RecentConversationSummary> recentConversations;
  final List<RecentCampaignSummary> recentCampaigns;

  const DashboardStats({
    required this.totalConversations,
    required this.activeConversations,
    required this.messagesSent,
    required this.messagesReceived,
    required this.messagesDelivered,
    required this.messagesRead,
    this.deliveredRate = 0.0,
    this.readRate = 0.0,
    required this.activeCampaigns,
    required this.freeWindowMessages,
    required this.costSavedInr,
    this.metaFeesCharged = 0.0,
    required this.windowResolutionRate,
    required this.walletBalance,
    required this.hourlyMetrics,
    required this.recentConversations,
    required this.recentCampaigns,
  });
}

class HourlyMessageMetric {
  final int hour;
  final int sent;
  final int received;

  const HourlyMessageMetric({
    required this.hour,
    required this.sent,
    required this.received,
  });
}

class RecentConversationSummary {
  final String id;
  final String contactName;
  final String lastMessage;
  final String timeAgo;
  final int unreadCount;

  const RecentConversationSummary({
    required this.id,
    required this.contactName,
    required this.lastMessage,
    required this.timeAgo,
    this.unreadCount = 0,
  });
}

class RecentCampaignSummary {
  final String id;
  final String name;
  final String status;
  final int sentCount;

  const RecentCampaignSummary({
    required this.id,
    required this.name,
    required this.status,
    required this.sentCount,
  });
}
