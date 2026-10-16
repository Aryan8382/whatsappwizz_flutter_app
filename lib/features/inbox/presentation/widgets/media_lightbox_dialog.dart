import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/services/toast_service.dart';

/// Fullscreen lightbox modal for viewing images and media attachments.
class MediaLightboxDialog extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String? subtitle;

  const MediaLightboxDialog({
    super.key,
    required this.title,
    required this.imageUrl,
    this.subtitle,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String imageUrl,
    String? subtitle,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => MediaLightboxDialog(
        title: title,
        imageUrl: imageUrl,
        subtitle: subtitle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: AppRadii.border2Xl,
          border: Border.all(color: Colors.white24, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lightbox Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null) ...[
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.download, color: AppColors.g400, size: 20),
                    tooltip: 'Download',
                    onPressed: () {
                      ToastService.success('Downloaded: $title');
                    },
                  ),
                  IconButton(
                    icon: const Icon(AppIcons.close, color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),

            // Image Preview Area with InteractiveViewer
            Flexible(
              child: Container(
                color: Colors.black54,
                width: double.infinity,
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.8,
                  maxScale: 3.5,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.imageOff, size: 48, color: Colors.white38),
                          SizedBox(height: 8),
                          Text('Media unavailable', style: TextStyle(color: Colors.white60)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
