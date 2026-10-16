import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/widgets/modal_sheet.dart';

class AssignAgentSheet extends StatelessWidget {
  final String? currentAgent;
  final String? currentUserName;
  final ValueChanged<String> onSelected;

  const AssignAgentSheet({
    super.key,
    this.currentAgent,
    this.currentUserName,
    required this.onSelected,
  });

  static const List<String> agents = [
    'Demo Admin',
    'Demo Supervisor',
    'Demo Agent',
    'Demo Reseller',
  ];

  static Future<String?> show(BuildContext context, String? currentAgent, {String? currentUserName}) {
    return ModalSheet.show<String>(
      context: context,
      title: 'Assign Conversation',
      subtitle: 'Select team member to assign this chat',
      child: Builder(
        builder: (sheetCtx) => AssignAgentSheet(
          currentAgent: currentAgent,
          currentUserName: currentUserName,
          onSelected: (agent) {
            Navigator.of(sheetCtx, rootNavigator: true).pop(agent);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myName = currentUserName ?? 'Demo Admin';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...agents.map((agent) {
          final isMe = agent.toLowerCase() == myName.toLowerCase();
          final isSelected = agent == currentAgent;
          return Material(
            color: Colors.transparent,
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
              leading: CircleAvatar(
                backgroundColor: isSelected ? AppColors.g600 : AppColors.g100,
                child: Text(
                  agent[0],
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.g800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Row(
                children: [
                  Text(agent, style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (isMe) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.g100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'You',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.g800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              trailing: isSelected
                  ? const Icon(AppIcons.checkCircle, color: AppColors.g600, size: 20)
                  : null,
              onTap: () => onSelected(agent),
            ),
          );
        }),
        if (currentAgent != null && currentAgent!.isNotEmpty) ...[
          const Divider(height: 16),
          Material(
            color: Colors.transparent,
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFEE2E2),
                child: Icon(Icons.person_off_outlined, color: Color(0xFFDC2626), size: 18),
              ),
              title: const Text(
                'Unassign Chat',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFDC2626),
                ),
              ),
              onTap: () => onSelected(''),
            ),
          ),
        ],
      ],
    );
  }
}
