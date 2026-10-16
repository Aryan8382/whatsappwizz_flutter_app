import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../domain/conversation.dart';
import '../../domain/message.dart';
import 'assign_agent_sheet.dart';
import 'composer.dart';
import 'contact_info_sheet.dart';
import 'doodle_background.dart';
import 'free_window_countdown_badge.dart';
import 'message_bubble.dart';
import 'template_picker_sheet.dart';

class ChatPane extends StatefulWidget {
  final Conversation conversation;
  final List<Message> messages;
  final String? currentUserName;
  final ValueChanged<String> onSendText;
  final ValueChanged<String> onSendInternalNote;
  final void Function(TemplateOption) onSendTemplate;
  final VoidCallback onPickAttachment;
  final ValueChanged<ConversationStatus> onUpdateStatus;
  final ValueChanged<String> onAssignAgent;
  final VoidCallback? onBack;

  const ChatPane({
    super.key,
    required this.conversation,
    required this.messages,
    this.currentUserName,
    required this.onSendText,
    required this.onSendInternalNote,
    required this.onSendTemplate,
    required this.onPickAttachment,
    required this.onUpdateStatus,
    required this.onAssignAgent,
    this.onBack,
  });

  @override
  State<ChatPane> createState() => _ChatPaneState();
}

class _ChatPaneState extends State<ChatPane> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    // In reverse: true, offset 0.0 is the bottom (latest message)
    final show = _scrollController.offset > 250;
    if (show != _showScrollToBottom) {
      setState(() => _showScrollToBottom = show);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChatPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When switching conversation: jump instantly to latest message (offset 0.0)
    if (widget.conversation.id != oldWidget.conversation.id) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0.0);
      }
    } else if (widget.messages.length != oldWidget.messages.length) {
      // New message arrived: smoothly glide to latest message if close to bottom
      if (_scrollController.hasClients && _scrollController.offset < 400) {
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    final localA = a.toLocal();
    final localB = b.toLocal();
    return localA.year == localB.year && localA.month == localB.month && localA.day == localB.day;
  }

  Widget _buildDateChip(DateTime dt) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0x1F000000), width: 0.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          DateTimeFormatter.formatChatDate(dt),
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF54656F),
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentStatusPill(String agentName, bool assignedToMe, [DateTime? time]) {
    final timeStr = time != null ? DateTimeFormatter.formatTime(time) : '';
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: assignedToMe ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: assignedToMe ? const Color(0xFF86EFAD) : const Color(0xFFCBD5E1),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              assignedToMe ? Icons.check_circle_outline_rounded : Icons.lock_person_outlined,
              size: 14,
              color: assignedToMe ? const Color(0xFF15803D) : const Color(0xFF475569),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                assignedToMe ? 'Chat assigned to you' : 'Chat assigned to $agentName',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: assignedToMe ? const Color(0xFF15803D) : const Color(0xFF334155),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (timeStr.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: assignedToMe ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handlePickTemplate() async {
    final tpl = await TemplatePickerSheet.show(context);
    if (tpl != null) {
      widget.onSendTemplate(tpl);
    }
  }

  void _handleAssignAgent() async {
    final agent = await AssignAgentSheet.show(
      context,
      widget.conversation.assignedAgentName,
      currentUserName: widget.currentUserName,
    );
    if (!mounted) return;
    if (agent != null) {
      widget.onAssignAgent(agent);
      final myName = widget.currentUserName ?? 'Admin';
      final isMe = agent.toLowerCase() == myName.toLowerCase() || agent.toLowerCase() == 'you';
      if (agent.isEmpty) {
        ToastService.info('Chat unassigned');
      } else if (isMe) {
        ToastService.success('Chat assigned to you');
      } else {
        ToastService.success('Chat assigned to $agent');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final conv = widget.conversation;
    final myName = widget.currentUserName ?? 'Admin';
    final assignedAgent = conv.assignedAgentName;
    final cleanAgent = assignedAgent?.trim() ?? '';
    final isAssigned = cleanAgent.isNotEmpty &&
        !['unassigned', 'unassign', 'none'].contains(cleanAgent.toLowerCase());
    final isAssignedToMe = isAssigned &&
        (cleanAgent.toLowerCase() == myName.toLowerCase().trim() ||
            cleanAgent.toLowerCase() == 'you' ||
            (myName.toLowerCase().contains('admin') && cleanAgent.toLowerCase().contains('admin')) ||
            (myName.toLowerCase().contains('supervisor') && cleanAgent.toLowerCase().contains('supervisor')) ||
            (myName.toLowerCase().contains('agent') && cleanAgent.toLowerCase().contains('agent')) ||
            (myName.toLowerCase().contains('reseller') && cleanAgent.toLowerCase().contains('reseller')));
    final isAssignedToOther = isAssigned && !isAssignedToMe;
    final showTopStatusPill = isAssigned &&
        !widget.messages.any((m) =>
            m.senderType == 'system' &&
            m.body.toLowerCase().contains('assigned'));

    return Container(
      color: const Color(0xFFEFEAE2), // WhatsApp wallpaper tint
      child: Column(
        children: [
          // Chat Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0x1F22C55E), width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.arrowLeft, size: 22, color: AppColors.textPrimary),
                    onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    constraints: const BoxConstraints(),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 2),
                  GestureDetector(
                    onTap: () => ContactInfoSheet.show(context, conv),
                    child: AppAvatar(name: conv.contactName, radius: 19),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => ContactInfoSheet.show(context, conv),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  conv.contactName,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              if (isAssigned) ...[
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: _handleAssignAgent,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: isAssignedToMe ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isAssignedToMe ? const Color(0xFF86EFAD) : const Color(0xFFCBD5E1),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isAssignedToMe ? Icons.person_rounded : Icons.lock_person_outlined,
                                          size: 10,
                                          color: isAssignedToMe ? const Color(0xFF15803D) : const Color(0xFF475569),
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          isAssignedToMe ? 'You' : cleanAgent,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: isAssignedToMe ? const Color(0xFF15803D) : const Color(0xFF334155),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 1.5),
                          Text(
                            conv.contactPhone.startsWith('+') ? conv.contactPhone : '+${conv.contactPhone}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF667781),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // 24H Window Countdown Live Badge or Resolved Status Badge
                  if (conv.status == ConversationStatus.resolved)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA5D6A7)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 12, color: Color(0xFF2E7D32)),
                          SizedBox(width: 3),
                          Text(
                            'Resolved',
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    FreeWindowCountdownBadge(
                      conversation: conv,
                      onExpiredTap: _handlePickTemplate,
                    ),
                  IconButton(
                    icon: const Icon(LucideIcons.phone, size: 18, color: Color(0xFF54656F)),
                    onPressed: () => ToastService.info('Calling ${conv.contactName}...'),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                    tooltip: 'Call',
                  ),

                  // Actions Popup Menu
                  PopupMenuButton<String>(
                    offset: const Offset(0, 40),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.borderXl),
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                    icon: const Icon(AppIcons.moreVertical, size: 19, color: Color(0xFF54656F)),
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'info',
                        child: Row(
                          children: [
                            Icon(AppIcons.info, size: 18),
                            SizedBox(width: 8),
                            Text('Contact Info'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'assign',
                        child: Row(
                          children: [
                            Icon(LucideIcons.userPlus, size: 18),
                            SizedBox(width: 8),
                            Text('Assign Agent'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: conv.status == ConversationStatus.resolved ? 'open' : 'resolve',
                        child: Row(
                          children: [
                            Icon(
                              conv.status == ConversationStatus.resolved
                                   ? LucideIcons.rotateCcw
                                   : AppIcons.checkCircle,
                              size: 18,
                              color: AppColors.g600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              conv.status == ConversationStatus.resolved
                                  ? 'Reopen Conversation'
                                  : 'Mark as Resolved',
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (val) {
                      if (val == 'info') {
                        ContactInfoSheet.show(context, conv);
                      } else if (val == 'assign') {
                        _handleAssignAgent();
                      } else if (val == 'resolve') {
                        widget.onUpdateStatus(ConversationStatus.resolved);
                        ToastService.success('Conversation marked as resolved');
                        // Close chat view and return to conversations list
                        if (widget.onBack != null) {
                          widget.onBack!();
                        }
                      } else if (val == 'open') {
                        widget.onUpdateStatus(ConversationStatus.open);
                        ToastService.success('Conversation reopened');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Message Bubbles List with Authentic WhatsApp Doodle Wallpaper
          Expanded(
            child: Stack(
              children: [
                WhatsAppDoodleBackground(
                  child: widget.messages.isEmpty
                      ? const Center(
                          child: Text(
                            'No messages in this chat yet.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          reverse: true, // Offset 0.0 directly shows the last/most recent message!
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: widget.messages.length + (showTopStatusPill ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (showTopStatusPill && index == widget.messages.length) {
                              return _buildAssignmentStatusPill(
                                assignedAgent!,
                                isAssignedToMe,
                                conv.updatedAt ?? conv.lastMessageTime ?? conv.createdAt,
                              );
                            }
                            // index 0 is at the bottom (newest message)
                            final msgIndex = widget.messages.length - 1 - index;
                            final msg = widget.messages[msgIndex];

                            final showDateHeader = msgIndex == 0 ||
                                !_isSameDay(
                                  widget.messages[msgIndex - 1].createdAt,
                                  msg.createdAt,
                                );

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (showDateHeader) _buildDateChip(msg.createdAt),
                                MessageBubble(
                                  message: msg,
                                  onButtonClicked: (action) {
                                    widget.onSendText(action);
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                ),
                if (_showScrollToBottom)
                  Positioned(
                    right: 16,
                    bottom: 12,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _scrollToBottom,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0x1F22C55E), width: 1),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1F000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 22,
                            color: AppColors.g700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 1. If chat is assigned to another agent: DISABLE messaging from the user!
          if (isAssignedToOther)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0x1F22C55E), width: 1),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.lock_person_outlined, color: Color(0xFF475569), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Chat assigned to $assignedAgent',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Text(
                            'Messaging disabled. Assigned to another agent.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        widget.onAssignAgent(myName);
                        ToastService.success('Chat assigned to you');
                      },
                      icon: const Icon(Icons.person_add_alt_1, size: 14),
                      label: const Text('Assign to Me', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.g600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          // 2. If chat is resolved:
          else if (conv.status == ConversationStatus.resolved)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0x1F22C55E), width: 1),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32), size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Conversation is Resolved',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Chat input is closed. Reopen to reply.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        widget.onUpdateStatus(ConversationStatus.open);
                        ToastService.success('Conversation reopened');
                      },
                      icon: const Icon(LucideIcons.rotateCcw, size: 14),
                      label: const Text('Reopen', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.g600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          // 3. Normal Active Composer (assigned to you or unassigned):
          else
            Composer(
              isWindowExpired: conv.isWindowExpired,
              onSendText: widget.onSendText,
              onSendInternalNote: widget.onSendInternalNote,
              onPickTemplate: _handlePickTemplate,
              onPickAttachment: widget.onPickAttachment,
            ),
        ],
      ),
    );
  }
}
