import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/modal_sheet.dart';
import '../../domain/conversation.dart';
import '../inbox_controller.dart';
import 'assign_agent_sheet.dart';

class ContactInfoSheet extends ConsumerStatefulWidget {
  final Conversation conversation;

  const ContactInfoSheet({super.key, required this.conversation});

  static void show(BuildContext context, Conversation conversation) {
    ModalSheet.show(
      context: context,
      title: 'Contact Details',
      child: ContactInfoSheet(conversation: conversation),
    );
  }

  @override
  ConsumerState<ContactInfoSheet> createState() => _ContactInfoSheetState();
}

class _ContactInfoSheetState extends ConsumerState<ContactInfoSheet> {
  // Common quick-add label tags
  static const List<String> _suggestedLabels = [
    'VIP',
    'Lead',
    'Support',
    'Billing',
    'Urgent',
    'High Priority',
    'New Customer',
  ];

  void _showEditContactDialog(Conversation conv) {
    final nameCtrl = TextEditingController(text: conv.contactName);
    final phoneCtrl = TextEditingController(text: conv.contactPhone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderXl),
        title: const Row(
          children: [
            Icon(LucideIcons.user, size: 20, color: AppColors.g600),
            SizedBox(width: 8),
            Text('Edit Contact Info', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Contact Name',
                hintText: 'Enter contact name',
                prefixIcon: Icon(LucideIcons.userCheck, size: 18),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'e.g. 919876543210',
                prefixIcon: Icon(LucideIcons.phone, size: 18),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameCtrl.text.trim();
              final newPhone = phoneCtrl.text.trim();
              if (newName.isNotEmpty) {
                ref.read(inboxControllerProvider.notifier).updateContactInfo(
                  name: newName,
                  phone: newPhone.isNotEmpty ? newPhone : null,
                );
                ToastService.success('Contact info updated');
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.g600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAssignAgentSheet(Conversation conv) async {
    final agent = await showModalBottomSheet<String?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Assign Conversation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFF1F5F9),
                child: Icon(Icons.person_off_rounded, size: 18, color: Colors.grey),
              ),
              title: const Text('Unassign', style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: conv.assignedAgentName == null || conv.assignedAgentName!.isEmpty
                  ? const Icon(AppIcons.checkCircle, color: AppColors.g600, size: 20)
                  : null,
              onTap: () => Navigator.of(ctx).pop(''),
            ),
            ...AssignAgentSheet.agents.map((ag) {
              final isSelected = ag == conv.assignedAgentName;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isSelected ? AppColors.g600 : AppColors.g100,
                  child: Text(
                    ag[0],
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.g800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(ag, style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: isSelected
                    ? const Icon(AppIcons.checkCircle, color: AppColors.g600, size: 20)
                    : null,
                onTap: () => Navigator.of(ctx).pop(ag),
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (agent != null) {
      ref.read(inboxControllerProvider.notifier).assignAgent(agent);
      ToastService.success(agent.isEmpty ? 'Conversation unassigned' : 'Assigned to $agent');
    }
  }

  void _showAddLabelDialog(Conversation conv) {
    final labelCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderXl),
        title: const Row(
          children: [
            Icon(LucideIcons.tag, size: 20, color: AppColors.g600),
            SizedBox(width: 8),
            Text('Manage Labels', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(
                  labelText: 'New Label',
                  hintText: 'Enter custom tag name',
                  prefixIcon: Icon(LucideIcons.plus, size: 18),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Popular Suggestions:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _suggestedLabels.map((lbl) {
                  final isAlreadyAdded = conv.labels.contains(lbl);
                  return ActionChip(
                    avatar: Icon(
                      isAlreadyAdded ? Icons.check : Icons.add,
                      size: 14,
                      color: isAlreadyAdded ? AppColors.g700 : AppColors.textMuted,
                    ),
                    label: Text(
                      lbl,
                      style: TextStyle(
                        fontSize: 12,
                        color: isAlreadyAdded ? AppColors.g700 : AppColors.textPrimary,
                        fontWeight: isAlreadyAdded ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    backgroundColor: isAlreadyAdded ? AppColors.g50 : Colors.white,
                    side: BorderSide(
                      color: isAlreadyAdded ? AppColors.g500 : const Color(0xFFE2E8F0),
                    ),
                    onPressed: () {
                      if (!isAlreadyAdded) {
                        ref.read(inboxControllerProvider.notifier).addLabel(lbl);
                        ToastService.success('Added "$lbl"');
                        Navigator.of(ctx).pop();
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final newLabel = labelCtrl.text.trim();
              if (newLabel.isNotEmpty) {
                ref.read(inboxControllerProvider.notifier).addLabel(newLabel);
                ToastService.success('Added "$newLabel"');
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.g600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Tag'),
          ),
        ],
      ),
    );
  }

  void _showStatusPickerSheet(Conversation conv) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Change Conversation Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            _statusOption(
              ctx,
              status: ConversationStatus.open,
              label: 'Open',
              subtitle: 'Active chat receiving responses',
              icon: LucideIcons.messageSquare,
              color: AppColors.g600,
              current: conv.status,
            ),
            _statusOption(
              ctx,
              status: ConversationStatus.pending,
              label: 'Pending',
              subtitle: 'Awaiting customer reply or action',
              icon: LucideIcons.clock,
              color: const Color(0xFFD97706),
              current: conv.status,
            ),
            _statusOption(
              ctx,
              status: ConversationStatus.resolved,
              label: 'Resolved',
              subtitle: 'Issue addressed, chat input closed',
              icon: Icons.check_circle_outline,
              color: const Color(0xFF16A34A),
              current: conv.status,
            ),
            _statusOption(
              ctx,
              status: ConversationStatus.closed,
              label: 'Closed',
              subtitle: 'Archived permanently',
              icon: Icons.cancel_outlined,
              color: Colors.grey,
              current: conv.status,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _statusOption(
    BuildContext ctx, {
    required ConversationStatus status,
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required ConversationStatus current,
  }) {
    final isSelected = current == status;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      trailing: isSelected
          ? Icon(AppIcons.checkCircle, color: color, size: 20)
          : null,
      onTap: () {
        Navigator.of(ctx).pop();
        ref.read(inboxControllerProvider.notifier).updateStatus(status);
        ToastService.success('Status updated to $label');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final inboxState = ref.watch(inboxControllerProvider);
    // Grab the latest reactive conversation from state
    final conv = inboxState.conversations.firstWhere(
      (c) => c.id == widget.conversation.id,
      orElse: () => widget.conversation,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Avatar, Name, Phone + Edit Contact Button
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    AppAvatar(name: conv.contactName, radius: 36),
                    InkWell(
                      onTap: () => _showEditContactDialog(conv),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.g600,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(AppIcons.edit, size: 13, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        conv.contactName,
                        style: AppTypography.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _showEditContactDialog(conv),
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(AppIcons.edit, size: 15, color: AppColors.g700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '+${conv.contactPhone}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 1. Assigned Agent (Editable)
          _EditableTile(
            icon: LucideIcons.user,
            title: 'Assigned Agent',
            value: conv.assignedAgentName != null && conv.assignedAgentName!.isNotEmpty
                ? conv.assignedAgentName!
                : 'Unassigned',
            valueColor: conv.assignedAgentName != null && conv.assignedAgentName!.isNotEmpty
                ? AppColors.textPrimary
                : AppColors.textMuted,
            badgeColor: conv.assignedAgentName != null && conv.assignedAgentName!.isNotEmpty
                ? AppColors.g100
                : null,
            badgeTextColor: conv.assignedAgentName != null && conv.assignedAgentName!.isNotEmpty
                ? AppColors.g800
                : null,
            onTap: () => _showAssignAgentSheet(conv),
          ),

          // 2. Labels / Tags (Interactive Chips & Add Button)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.g50,
              borderRadius: AppRadii.borderLg,
              border: Border.all(color: const Color(0x1F22C55E)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.tag, size: 18, color: AppColors.g700),
                    const SizedBox(width: 10),
                    const Text('Labels', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const Spacer(),
                    InkWell(
                      onTap: () => _showAddLabelDialog(conv),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.g600,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 13, color: Colors.white),
                            SizedBox(width: 3),
                            Text('Add', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (conv.labels.isEmpty)
                  const Text('No labels assigned. Tap "+ Add" to add tags.', style: TextStyle(fontSize: 12, color: AppColors.textMuted))
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: conv.labels.map((lbl) {
                      return Chip(
                        label: Text(lbl, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                        backgroundColor: Colors.white,
                        deleteIcon: const Icon(Icons.close, size: 13, color: Colors.grey),
                        onDeleted: () {
                          ref.read(inboxControllerProvider.notifier).removeLabel(lbl);
                          ToastService.info('Removed "$lbl"');
                        },
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),

          // 3. Status (Editable)
          _EditableTile(
            icon: AppIcons.info,
            title: 'Status',
            value: conv.status.label,
            valueColor: _getStatusColor(conv.status),
            badgeColor: _getStatusColor(conv.status).withOpacity(0.12),
            badgeTextColor: _getStatusColor(conv.status),
            onTap: () => _showStatusPickerSheet(conv),
          ),

          // 4. 24H Service Window
          _EditableTile(
            icon: LucideIcons.hourglass,
            title: '24H Service Window',
            value: conv.isWindowExpired
                ? 'Expired'
                : '${conv.remainingWindow.inHours}h ${conv.remainingWindow.inMinutes % 60}m remaining',
            valueColor: conv.isWindowExpired ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
            badgeColor: (conv.isWindowExpired ? const Color(0xFFDC2626) : const Color(0xFF16A34A)).withOpacity(0.12),
            badgeTextColor: conv.isWindowExpired ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
            showChevron: false,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Color _getStatusColor(ConversationStatus status) {
    switch (status) {
      case ConversationStatus.open:
        return AppColors.g600;
      case ConversationStatus.pending:
        return const Color(0xFFD97706);
      case ConversationStatus.resolved:
        return const Color(0xFF16A34A);
      case ConversationStatus.closed:
        return Colors.grey;
    }
  }
}

class _EditableTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final bool showChevron;
  final VoidCallback? onTap;

  const _EditableTile({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
    this.badgeColor,
    this.badgeTextColor,
    this.showChevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.g50,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: const Color(0x1F22C55E)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.borderLg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.g700),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const Spacer(),
                if (badgeColor != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        color: badgeTextColor ?? AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Text(
                    value,
                    style: TextStyle(
                      color: valueColor ?? AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (showChevron) ...[
                  const SizedBox(width: 6),
                  const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
