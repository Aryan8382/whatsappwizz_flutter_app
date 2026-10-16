import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';

enum BadgeVariant { green, amber, red, blue, gray }

class StatusBadge extends StatelessWidget {
  final String status;
  final String? label;
  final BadgeVariant? variant;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.label,
    this.variant,
    this.fontSize = 11.5,
  });

  BadgeVariant _getVariant() {
    if (variant != null) return variant!;
    final s = status.toLowerCase();
    switch (s) {
      case 'approved':
      case 'active':
      case 'connected':
      case 'completed':
      case 'delivered':
      case 'read':
      case 'open':
      case 'resolved':
      case 'running':
      case 'sent':
        return BadgeVariant.green;
      case 'pending':
      case 'paused':
      case 'scheduled':
      case 'pending_conv':
        return BadgeVariant.amber;
      case 'rejected':
      case 'failed':
      case 'disconnected':
        return BadgeVariant.red;
      case 'draft':
      case 'received':
      case 'closed':
      case 'inactive':
      default:
        return BadgeVariant.gray;
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = _getVariant();
    Color bg;
    Color text;

    switch (v) {
      case BadgeVariant.green:
        bg = AppColors.statusGreenBg;
        text = AppColors.statusGreenText;
        break;
      case BadgeVariant.amber:
        bg = AppColors.statusAmberBg;
        text = AppColors.statusAmberText;
        break;
      case BadgeVariant.red:
        bg = AppColors.statusRedBg;
        text = AppColors.statusRedText;
        break;
      case BadgeVariant.blue:
        bg = AppColors.statusBlueBg;
        text = AppColors.statusBlueText;
        break;
      case BadgeVariant.gray:
        bg = AppColors.statusGrayBg;
        text = AppColors.statusGrayText;
        break;
    }

    final displayText = label ?? status.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.borderFull,
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: text,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
