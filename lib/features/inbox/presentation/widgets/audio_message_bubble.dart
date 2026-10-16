import 'package:flutter/material.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/message.dart';

/// Audio player message bubble with waveform visualization and play/pause controls.
class AudioMessageBubble extends StatefulWidget {
  final Message message;

  const AudioMessageBubble({super.key, required this.message});

  @override
  State<AudioMessageBubble> createState() => _AudioMessageBubbleState();
}

class _AudioMessageBubbleState extends State<AudioMessageBubble> {
  bool _isPlaying = false;
  final double _progress = 0.35;

  @override
  Widget build(BuildContext context) {
    final isOutbound = widget.message.direction == MessageDirection.outbound;
    final bubbleColor = isOutbound ? const Color(0xFFD9FDD3) : Colors.white;

    return Align(
      alignment: isOutbound ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        constraints: const BoxConstraints(maxWidth: 290),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppRadii.r20),
            topRight: const Radius.circular(AppRadii.r20),
            bottomLeft: isOutbound ? const Radius.circular(AppRadii.r20) : const Radius.circular(4),
            bottomRight: isOutbound ? const Radius.circular(4) : const Radius.circular(AppRadii.r20),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Play / Pause Circle Button
                InkWell(
                  onTap: () {
                    setState(() {
                      _isPlaying = !_isPlaying;
                    });
                  },
                  borderRadius: AppRadii.borderFull,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isOutbound ? AppColors.g600 : AppColors.waTeal,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying ? LucideIcons.pause : LucideIcons.play,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Audio Waveform Visualizer Bars
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(24, (i) {
                          final barHeight = (8.0 + ((i * 7) % 18)).clamp(6.0, 22.0);
                          final isPassed = (i / 24.0) <= _progress;
                          return Container(
                            width: 3,
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: isPassed
                                  ? AppColors.g700
                                  : const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '0:18',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '0:45',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),

            // Timestamp + Delivery ticks
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _formatTime(widget.message.timestamp),
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 10.5,
                    color: AppColors.textMuted,
                  ),
                ),
                if (isOutbound) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    LucideIcons.checkCheck,
                    size: 14,
                    color: AppColors.waBlue,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }
}
