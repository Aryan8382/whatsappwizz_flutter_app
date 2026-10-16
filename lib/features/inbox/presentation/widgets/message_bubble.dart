import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../shared/services/toast_service.dart';
import '../../domain/message.dart';
import 'audio_message_bubble.dart';
import 'media_lightbox_dialog.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final VoidCallback? onRetry;
  final ValueChanged<String>? onButtonClicked;

  const MessageBubble({
    super.key,
    required this.message,
    this.onRetry,
    this.onButtonClicked,
  });

  @override
  Widget build(BuildContext context) {
    if (message.senderType == 'system') {
      return _buildSystemEventPill(context);
    }

    if (message.isInternalNote) {
      return _buildInternalNote(context);
    }

    final isOutbound = message.direction == MessageDirection.outbound;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxBubbleWidth = constraints.maxWidth * 0.75;

        final timeRow = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateTimeFormatter.formatTime(message.createdAt),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: isOutbound ? const Color(0xFF667781) : const Color(0xFF8696A0),
              ),
            ),
            if (isOutbound) ...[
              const SizedBox(width: 3),
              _buildStatusIcon(message.status),
            ],
          ],
        );

        final isShortText = message.type == MessageType.text &&
            message.body.length <= 25 &&
            !message.body.contains('\n');

        Widget bubbleBody;
        if (isShortText) {
          bubbleBody = Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.body,
                style: const TextStyle(
                  fontSize: 14.5,
                  color: AppColors.textPrimary,
                  height: 1.35,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 1),
                child: timeRow,
              ),
            ],
          );
        } else {
          bubbleBody = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildContent(context),
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.bottomRight,
                child: timeRow,
              ),
            ],
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          child: Align(
            alignment: isOutbound ? Alignment.centerRight : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxBubbleWidth,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                decoration: BoxDecoration(
                  color: isOutbound ? AppColors.waLightGreen : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(AppRadii.r2xl),
                    topRight: const Radius.circular(AppRadii.r2xl),
                    bottomLeft: Radius.circular(isOutbound ? AppRadii.r2xl : 4),
                    bottomRight: Radius.circular(isOutbound ? 4 : AppRadii.r2xl),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: bubbleBody,
              ),
            ),
          ),
        );
      },
    );
}

  Widget _buildInternalNote(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9C3), // Yellow amber
        borderRadius: AppRadii.borderXl,
        border: Border.all(color: const Color(0xFFFDE047), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.lock, size: 14, color: Color(0xFF854D0E)),
              SizedBox(width: 6),
              Text(
                'Internal Note (Private to Agents)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF854D0E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            message.body,
            style: const TextStyle(fontSize: 13, color: Color(0xFF713F12)),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              DateTimeFormatter.formatTime(message.createdAt),
              style: const TextStyle(fontSize: 10, color: Color(0xFFA16207)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemEventPill(BuildContext context) {
    final timeStr = DateTimeFormatter.formatTime(message.createdAt);
    final isUnassign = message.body.toLowerCase().contains('unassign');

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isUnassign ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9), // Red-50 or Slate-100
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnassign ? const Color(0xFFFECACA) : const Color(0xFFCBD5E1),
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
              isUnassign ? Icons.person_off_outlined : Icons.person_pin_circle_outlined,
              size: 14,
              color: isUnassign ? const Color(0xFFDC2626) : const Color(0xFF475569),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                message.body,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isUnassign ? const Color(0xFFB91C1C) : const Color(0xFF334155),
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
                  color: isUnassign ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.body,
          style: const TextStyle(fontSize: 14.5, color: AppColors.textPrimary, height: 1.35),
        );

      case MessageType.image:
        final imgUrl = message.mediaUrl ?? 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600';
        return GestureDetector(
          onTap: () => MediaLightboxDialog.show(
            context,
            title: message.body.isNotEmpty ? message.body : 'Image Attachment',
            imageUrl: imgUrl,
            subtitle: DateTimeFormatter.formatFull(message.createdAt),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: AppRadii.borderLg,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (ctx, err, stack) => const Icon(
                          LucideIcons.image,
                          size: 48,
                          color: AppColors.g600,
                        ),
                      ),
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.zoomIn, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (message.body.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(message.body, style: const TextStyle(fontSize: 14.5)),
              ],
            ],
          ),
        );

      case MessageType.video:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: AppRadii.borderLg,
              child: Container(
                height: 160,
                color: Colors.black87,
                alignment: Alignment.center,
                child: const Icon(LucideIcons.playCircle, size: 48, color: Colors.white),
              ),
            ),
            if (message.body.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(message.body, style: const TextStyle(fontSize: 14.5)),
            ],
          ],
        );

      case MessageType.document:
        return InkWell(
          onTap: () => ToastService.success('Opening ${message.mediaName ?? "Invoice.pdf"}'),
          borderRadius: AppRadii.borderMd,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.04),
              borderRadius: AppRadii.borderMd,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.fileText, size: 30, color: AppColors.g700),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.mediaName ?? 'Document.pdf',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        message.mediaSize ?? 'PDF',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const Icon(LucideIcons.download, size: 20, color: AppColors.g600),
              ],
            ),
          ),
        );

      case MessageType.audio:
        return AudioMessageBubble(message: message);

      case MessageType.location:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: AppRadii.borderMd,
              ),
              alignment: Alignment.center,
              child: const Icon(LucideIcons.mapPin, size: 36, color: AppColors.g700),
            ),
            const SizedBox(height: 6),
            const Text('Shared Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        );

      case MessageType.template:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.g100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(AppIcons.checkCircle, size: 12, color: AppColors.g700),
                  const SizedBox(width: 4),
                  Text(
                    'Template: ${message.templateName ?? "General"}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.g800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(message.body, style: const TextStyle(fontSize: 14.5)),
          ],
        );

      case MessageType.interactive:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.body, style: const TextStyle(fontSize: 14.5)),
            if (message.interactiveButtons.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: message.interactiveButtons.map((btn) {
                  return ActionChip(
                    label: Text(btn, style: const TextStyle(fontSize: 12, color: AppColors.g800)),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.g400),
                    onPressed: () => onButtonClicked?.call(btn),
                  );
                }).toList(),
              ),
            ],
          ],
        );

      default:
        return Text(message.body, style: const TextStyle(fontSize: 14.5));
    }
  }

  Widget _buildStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sent:
        return const Icon(LucideIcons.check, size: 14, color: Colors.grey);
      case MessageStatus.delivered:
        return const Icon(LucideIcons.checkCheck, size: 14, color: Colors.grey);
      case MessageStatus.read:
        return const Icon(LucideIcons.checkCheck, size: 14, color: Color(0xFF53BDEB)); // WhatsApp Blue
      case MessageStatus.failed:
        return InkWell(
          onTap: onRetry,
          child: const Icon(LucideIcons.alertCircle, size: 14, color: AppColors.statusRedText),
        );
    }
  }
}
