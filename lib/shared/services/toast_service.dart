import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';

enum ToastType { success, error, warning, info }

class ToastService {
  ToastService._();
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void show(
    String message, {
    String? title,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = messengerKey.currentState;
    if (messenger == null) return;

    Color bg;
    Color iconColor;
    IconData iconData;

    switch (type) {
      case ToastType.success:
        bg = const Color(0xFFF0FDF4);
        iconColor = AppColors.g600;
        iconData = AppIcons.checkCircle;
        break;
      case ToastType.error:
        bg = const Color(0xFFFEF2F2);
        iconColor = AppColors.statusRedText;
        iconData = AppIcons.alertCircle;
        break;
      case ToastType.warning:
        bg = const Color(0xFFFFFBEB);
        iconColor = AppColors.statusAmberText;
        iconData = AppIcons.warning;
        break;
      case ToastType.info:
        bg = const Color(0xFFEFF6FF);
        iconColor = AppColors.statusBlueText;
        iconData = AppIcons.info;
        break;
    }

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadii.border2xl,
            border: Border.all(color: iconColor.withOpacity(0.3), width: 1),
            boxShadow: AppShadows.glassMd,
          ),
          child: Row(
            children: [
              Icon(iconData, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null && title.isNotEmpty) ...[
                      Text(
                        title,
                        style: TextStyle(
                          color: iconColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      message,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void success(String message, {String? title = 'Success'}) {
    show(message, title: title, type: ToastType.success);
  }

  static void error(String message, {String? title = 'Error'}) {
    show(message, title: title, type: ToastType.error);
  }

  static void warning(String message, {String? title = 'Warning'}) {
    show(message, title: title, type: ToastType.warning);
  }

  static void info(String message, {String? title = 'Notice'}) {
    show(message, title: title, type: ToastType.info);
  }
}
