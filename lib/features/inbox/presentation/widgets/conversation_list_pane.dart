import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../shared/widgets/animated_entrance.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/filter_chips.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/conversation.dart';

class ConversationListPane extends StatefulWidget {
  final List<Conversation> conversations;
  final String? selectedConversationId;
  final ValueChanged<Conversation> onSelect;
  final Future<void> Function() onRefresh;
  final VoidCallback? onSimulateIncoming;

  const ConversationListPane({
    super.key,
    required this.conversations,
    this.selectedConversationId,
    required this.onSelect,
    required this.onRefresh,
    this.onSimulateIncoming,
  });

  @override
  State<ConversationListPane> createState() => _ConversationListPaneState();
}

class _ConversationListPaneState extends State<ConversationListPane> {
  final TextEditingController _searchController = TextEditingController();
  ConversationStatus? _selectedStatus;

  List<Conversation> get _filteredConversations {
    var list = widget.conversations;
    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((c) {
        return c.contactName.toLowerCase().contains(q) ||
            c.contactPhone.contains(q) ||
            c.lastMessage.toLowerCase().contains(q);
      }).toList();
    }
    if (_selectedStatus != null) {
      list = list.where((c) => c.status == _selectedStatus).toList();
    }
    final sorted = List<Conversation>.from(list);
    sorted.sort((a, b) => b.latestActivityTime.toUtc().compareTo(a.latestActivityTime.toUtc()));
    return sorted;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredConversations;

    return Column(
      children: [
        // Search and Filters Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: AppSearchBar(
                  controller: _searchController,
                  hintText: 'Search chats by name, phone, message...',
                  onChanged: (_) => setState(() {}),
                ),
              ),
              if (widget.onSimulateIncoming != null) ...[
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Simulate Incoming Message (Tests 1->2->3 & chat jumps to top)',
                  child: InkWell(
                    onTap: widget.onSimulateIncoming,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.g50,
                        border: Border.all(color: AppColors.waGreen.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.mark_chat_unread_rounded,
                        size: 20,
                        color: AppColors.waGreen,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Status Filter Chips
        FilterChips<ConversationStatus?>(
          items: const [null, ConversationStatus.open, ConversationStatus.pending, ConversationStatus.resolved],
          selectedItem: _selectedStatus,
          onSelected: (val) => setState(() => _selectedStatus = val),
          labelBuilder: (status) => status == null ? 'All Chats' : status.label,
        ),

        const Divider(height: 1, color: Color(0x1F22C55E)),

        // Conversations List
        Expanded(
          child: RefreshIndicator(
            color: AppColors.g600,
            onRefresh: widget.onRefresh,
            child: list.isEmpty
                ? const EmptyState(
                    icon: AppIcons.inbox,
                    title: 'No conversations found',
                    message: 'Try adjusting your search query or filters',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 110),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      indent: 72,
                      color: Color(0x0F22C55E),
                    ),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      final isSelected = item.id == widget.selectedConversationId;

                      return FadeSlideIn.staggered(
                        index: index,
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            selected: isSelected,
                            selectedTileColor: AppColors.g50,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            onTap: () => widget.onSelect(item),
                        leading: Stack(
                          children: [
                            AppAvatar(name: item.contactName, radius: 22),
                            // Urgency badge dot (Green / Amber / Red / Expired)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _urgencyDotColor(item.urgency),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.contactName,
                                style: AppTypography.titleMedium.copyWith(
                                  fontSize: 15,
                                  fontWeight: item.unreadCount > 0 ? FontWeight.w700 : FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              DateTimeFormatter.formatExactTimeOrDate(item.lastMessageTime),
                              style: TextStyle(
                                fontSize: 11,
                                color: item.unreadCount > 0 ? AppColors.waGreen : AppColors.textMuted,
                                fontWeight: item.unreadCount > 0 ? FontWeight.w700 : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.lastMessage,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: item.unreadCount > 0
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary,
                                      fontWeight: item.unreadCount > 0
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                                if (item.unreadCount > 0) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: item.unreadCount > 9 ? 6 : 0,
                                      vertical: 2,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.waGreen,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      item.unreadCount > 99 ? '99+' : '${item.unreadCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        height: 1.1,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                StatusBadge(status: item.status.value, label: item.status.label, fontSize: 9.5),
                                const SizedBox(width: 6),
                                if (item.labels.isNotEmpty)
                                  ...item.labels.take(2).map((lbl) => Container(
                                        margin: const EdgeInsets.only(right: 4),
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          lbl,
                                          style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                                        ),
                                      )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                  ),
          ),
        ),
      ],
    );
  }

  Color _urgencyDotColor(WindowUrgency urgency) {
    switch (urgency) {
      case WindowUrgency.green:
        return AppColors.windowActiveGreen;
      case WindowUrgency.amber:
        return AppColors.windowExpiringAmber;
      case WindowUrgency.red:
        return AppColors.windowUrgentRed;
      case WindowUrgency.expired:
        return AppColors.windowExpired;
    }
  }
}
