import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/modal_sheet.dart';
import '../../domain/contact.dart';

class ContactDetailSheet extends StatelessWidget {
  final Contact contact;
  final VoidCallback? onEdit;

  const ContactDetailSheet({
    super.key,
    required this.contact,
    this.onEdit,
  });

  static void show(BuildContext context, {required Contact contact, VoidCallback? onEdit}) {
    ModalSheet.show(
      context: context,
      title: 'Contact Details',
      subtitle: 'Database record for ${contact.fullName}',
      child: ContactDetailSheet(contact: contact, onEdit: onEdit),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Profile Header Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.g50,
            borderRadius: AppRadii.border2xl,
            border: Border.all(color: AppColors.g200),
          ),
          child: Row(
            children: [
              AppAvatar(name: contact.fullName, radius: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.fullName,
                      style: AppTypography.titleLarge.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'ID: #${contact.id} • Org: #${contact.organizationId}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: contact.optIn ? AppColors.statusGreenBg : const Color(0xFFFEF2F2),
                  borderRadius: AppRadii.borderFull,
                  border: Border.all(
                    color: contact.optIn ? const Color(0x3322C55E) : const Color(0xFFFCA5A5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      contact.optIn ? AppIcons.checkCircle : LucideIcons.slash,
                      size: 13,
                      color: contact.optIn ? AppColors.statusGreenText : AppColors.statusRedText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      contact.optIn ? 'Opted In' : 'No Opt-in',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: contact.optIn ? AppColors.statusGreenText : AppColors.statusRedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Database Fields Grid
        Text('Contact Information', style: AppTypography.titleMedium),
        const SizedBox(height: 10),
        _buildInfoTile(
          icon: LucideIcons.phone,
          label: 'Mobile (WhatsApp ID)',
          value: '+${contact.mobile}',
          copyable: true,
        ),
        const SizedBox(height: 8),
        _buildInfoTile(
          icon: LucideIcons.mail,
          label: 'Email Address',
          value: (contact.email?.isNotEmpty == true) ? contact.email! : 'Not specified',
          copyable: contact.email?.isNotEmpty == true,
        ),
        const SizedBox(height: 8),
        _buildInfoTile(
          icon: LucideIcons.mapPin,
          label: 'Location (City, State, Country)',
          value: _formatLocation(contact),
        ),
        const SizedBox(height: 8),
        _buildInfoTile(
          icon: LucideIcons.globe,
          label: 'Acquisition Source',
          value: contact.source.isNotEmpty ? contact.source.toUpperCase() : 'ORGANIC / INBOUND',
        ),

        const SizedBox(height: 18),
        // Timestamps Section
        Text('Activity Timestamps', style: AppTypography.titleMedium),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildTimestampTile(
                label: 'Last Interaction',
                value: contact.lastInteraction != null
                    ? _formatDate(contact.lastInteraction!)
                    : 'No interaction yet',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTimestampTile(
                label: 'Created Date',
                value: _formatDate(contact.createdAt),
              ),
            ),
          ],
        ),

        // Tags Section
        if (contact.tags.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text('Segment Tags (${contact.tags.length})', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: contact.tags.map((t) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.g100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.g300),
                ),
                child: Text('#$t', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g900)),
              );
            }).toList(),
          ),
        ],

        // Custom Fields Section
        if (contact.customFields.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text('Custom Fields', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadii.borderXl,
              border: Border.all(color: const Color(0x1F22C55E)),
            ),
            child: Column(
              children: contact.customFields.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                      Text('${entry.value}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],

        const SizedBox(height: 24),
        if (onEdit != null)
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onEdit!();
            },
            icon: const Icon(LucideIcons.edit2, size: 16),
            label: const Text('Edit Contact Record'),
          ),
      ],
    );
  }

  static Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool copyable = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: const Color(0x1F22C55E)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.g700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 1),
                Text(value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
          if (copyable)
            IconButton(
              icon: const Icon(LucideIcons.copy, size: 15, color: AppColors.textMuted),
              onPressed: () => ToastService.info('Copied $value'),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  static Widget _buildTimestampTile({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.borderLg,
        border: Border.all(color: const Color(0x1F22C55E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  static String _formatLocation(Contact contact) {
    final parts = [contact.city, contact.state, contact.country]
        .where((p) => p != null && p.isNotEmpty)
        .cast<String>()
        .toList();
    return parts.isNotEmpty ? parts.join(', ') : 'Not specified';
  }

  static String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
