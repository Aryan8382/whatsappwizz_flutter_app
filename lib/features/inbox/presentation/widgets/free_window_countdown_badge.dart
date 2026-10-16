import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radii.dart';
import '../../domain/conversation.dart';

class FreeWindowCountdownBadge extends StatefulWidget {
  final Conversation conversation;
  final VoidCallback? onExpiredTap;

  const FreeWindowCountdownBadge({
    super.key,
    required this.conversation,
    this.onExpiredTap,
  });

  @override
  State<FreeWindowCountdownBadge> createState() => _FreeWindowCountdownBadgeState();
}

class _FreeWindowCountdownBadgeState extends State<FreeWindowCountdownBadge> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showSavingsExplanation(BuildContext context) {
    final urgency = widget.conversation.urgency;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.border3xl),
        title: Row(
          children: [
            const Icon(LucideIcons.piggyBank, color: AppColors.g600, size: 22),
            const SizedBox(width: 8),
            const Text('24H Free Service Window', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              urgency == WindowUrgency.expired
                  ? 'The 24-hour customer service window has expired. Freeform replies are locked by Meta. You must send an approved template message to re-engage.'
                  : 'Customer replied inside the 24-hour service window. All text, images, and bot messages sent now cost ₹0.00 Meta template charges!',
              style: const TextStyle(fontSize: 13.5, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.g50,
                borderRadius: AppRadii.borderLg,
                border: Border.all(color: AppColors.g200),
              ),
              child: const Row(
                children: [
                  Icon(AppIcons.checkCircle, color: AppColors.g700, size: 16),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Saving approx ₹0.75 per message vs template charges',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.g800),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final urgency = widget.conversation.urgency;
    final rem = widget.conversation.remainingWindow;

    Color bg;
    Color border;
    Color textColor;
    IconData icon;
    String text;

    switch (urgency) {
      case WindowUrgency.green:
        bg = const Color(0xFFF0FDF4); // Soft Emerald-50
        border = const Color(0xFFBBF7D0); // Emerald-200
        textColor = const Color(0xFF15803D); // Emerald-700
        icon = LucideIcons.clock;
        final h = rem.inHours;
        final m = rem.inMinutes % 60;
        text = '${h}h ${m}m';
        break;
      case WindowUrgency.amber:
        bg = const Color(0xFFFFFBEB); // Soft Amber-50
        border = const Color(0xFFFDE68A); // Amber-200
        textColor = const Color(0xFFB45309); // Amber-700
        icon = LucideIcons.clock;
        final h = rem.inHours;
        final m = rem.inMinutes % 60;
        text = '${h}h ${m}m';
        break;
      case WindowUrgency.red:
        bg = const Color(0xFFFFF1F2); // Soft Rose-50
        border = const Color(0xFFFECDD3); // Rose-200
        textColor = const Color(0xFFBE123C); // Rose-700
        icon = LucideIcons.clock;
        final m = rem.inMinutes;
        text = '${m}m';
        break;
      case WindowUrgency.expired:
        bg = const Color(0xFFF8FAFC); // Slate-50
        border = const Color(0xFFE2E8F0); // Slate-200
        textColor = const Color(0xFF64748B); // Slate-500
        icon = LucideIcons.lock;
        text = 'Expired';
        break;
    }

    return InkWell(
      onTap: urgency == WindowUrgency.expired && widget.onExpiredTap != null
          ? widget.onExpiredTap
          : () => _showSavingsExplanation(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11.5, color: textColor),
            const SizedBox(width: 3.5),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
