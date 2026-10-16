import '../domain/dashboard_repository.dart';
import '../domain/dashboard_stats.dart';

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardStats> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return const DashboardStats(
      totalConversations: 3420,
      activeConversations: 48,
      messagesSent: 18290,
      messagesReceived: 12450,
      messagesDelivered: 17850,
      messagesRead: 15420,
      deliveredRate: 97.6,
      readRate: 84.3,
      activeCampaigns: 4,
      freeWindowMessages: 14750,
      costSavedInr: 11062.5,
      metaFeesCharged: 2655.0,
      windowResolutionRate: 94.2,
      walletBalance: 0.0,
      hourlyMetrics: [
        HourlyMessageMetric(hour: 0, sent: 120, received: 95),
        HourlyMessageMetric(hour: 3, sent: 40, received: 30),
        HourlyMessageMetric(hour: 6, sent: 210, received: 180),
        HourlyMessageMetric(hour: 9, sent: 890, received: 720),
        HourlyMessageMetric(hour: 12, sent: 1450, received: 1180),
        HourlyMessageMetric(hour: 15, sent: 1620, received: 1390),
        HourlyMessageMetric(hour: 18, sent: 1120, received: 940),
        HourlyMessageMetric(hour: 21, sent: 480, received: 360),
      ],
      recentConversations: [
        RecentConversationSummary(
          id: '1',
          contactName: 'Ravi Kumar',
          lastMessage: 'Could you please confirm the delivery date for order #5021?',
          timeAgo: '2m ago',
          unreadCount: 2,
        ),
        RecentConversationSummary(
          id: '2',
          contactName: 'Priya Sharma',
          lastMessage: 'Is this available in green color too?',
          timeAgo: '55m ago',
          unreadCount: 1,
        ),
        RecentConversationSummary(
          id: '3',
          contactName: 'Amit Patel',
          lastMessage: 'Need urgent invoice for our tax filing.',
          timeAgo: '3h ago',
          unreadCount: 0,
        ),
        RecentConversationSummary(
          id: '4',
          contactName: 'Sneha Gupta',
          lastMessage: 'Thanks, talk to you next week.',
          timeAgo: '2d ago',
          unreadCount: 0,
        ),
      ],
      recentCampaigns: [
        RecentCampaignSummary(
          id: 'c1',
          name: 'Diwali Mega Sale 2026',
          status: 'running',
          sentCount: 15200,
        ),
        RecentCampaignSummary(
          id: 'c2',
          name: 'Abandoned Cart Recovery',
          status: 'running',
          sentCount: 2450,
        ),
        RecentCampaignSummary(
          id: 'c3',
          name: 'VIP Customer Exclusive',
          status: 'completed',
          sentCount: 850,
        ),
      ],
    );
  }
}
