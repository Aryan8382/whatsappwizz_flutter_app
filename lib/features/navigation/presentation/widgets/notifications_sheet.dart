import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/skeleton_list.dart';

class NotificationsSheet extends ConsumerWidget {
  const NotificationsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const NotificationsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifState = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);
    final notifications = notifState.notifications;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.72,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.r28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(AppIcons.notifications, color: AppColors.g600, size: 22),
                    const SizedBox(width: 8),
                    Text('Notifications', style: AppTypography.displayMedium.copyWith(fontSize: 18)),
                    if (notifState.unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.g600,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${notifState.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (notifications.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      notifier.markAllAsRead();
                      notifier.clearAll();
                      ToastService.success('All notifications marked as read');
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(LucideIcons.checkCheck, size: 16, color: AppColors.g700),
                    label: const Text(
                      'Mark all read',
                      style: TextStyle(
                        color: AppColors.g700,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Notifications List or Empty State
          Expanded(
            child: notifState.isLoading && notifications.isEmpty
                ? const Center(child: SkeletonList(count: 4, itemHeight: 70))
                : notifications.isEmpty
                    ? const Center(
                        child: EmptyState(
                          icon: AppIcons.notifications,
                          title: 'No new notifications',
                          message: "You're all caught up! Live WhatsApp events will appear here.",
                        ),
                      )
                    : RefreshIndicator(
                        color: AppColors.g600,
                        onRefresh: () => notifier.loadInitialNotifications(),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: notifications.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
                          itemBuilder: (context, index) {
                            final item = notifications[index];
                            final isUnread = !item.isRead;

                            return Dismissible(
                              key: Key(item.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                color: AppColors.statusRedBg,
                                child: const Icon(LucideIcons.trash2, color: AppColors.statusRedText, size: 20),
                              ),
                              onDismissed: (_) {
                                notifier.removeNotification(item.id);
                              },
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isUnread ? AppColors.g100 : const Color(0xFFF1F5F9),
                                  child: Icon(
                                    _getNotificationIcon(item.type),
                                    color: isUnread ? AppColors.g700 : AppColors.textMuted,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2),
                                    Text(
                                      item.body,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isUnread ? AppColors.textSecondary : AppColors.textMuted,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _timeAgo(item.timestamp),
                                      style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                                trailing: isUnread
                                    ? Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.g600,
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    : null,
                                onTap: () {
                                  notifier.markAsRead(item.id);
                                  Navigator.of(context).pop();

                                  // Deep navigate based on notification type
                                  if (item.type == NotificationType.message) {
                                    context.go('/inbox');
                                  } else if (item.type == NotificationType.campaign) {
                                    context.go('/campaigns');
                                  } else if (item.type == NotificationType.template) {
                                    context.go('/templates');
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  static IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.message:
        return LucideIcons.messageSquare;
      case NotificationType.campaign:
        return LucideIcons.megaphone;
      case NotificationType.template:
        return LucideIcons.fileText;
      case NotificationType.system:
      default:
        return LucideIcons.bell;
    }
  }

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 45) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
