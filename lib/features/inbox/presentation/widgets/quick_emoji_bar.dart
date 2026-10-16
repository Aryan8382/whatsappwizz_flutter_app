import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radii.dart';

/// Quick emoji reaction bar matching `POPULAR_EMOJIS` in web inbox.
class QuickEmojiBar extends StatelessWidget {
  final ValueChanged<String> onSelectEmoji;
  final VoidCallback onClose;

  static const List<String> popularEmojis = [
    '😀', '😃', '😄', '😁', '😂', '🤣', '😊', '😍', '🥰', '😘',
    '😎', '🤩', '👍', '👎', '👏', '🙌', '🤝', '🙏', '❤️', '🔥',
    '✨', '🎉', '⭐', '💯', '💎', '💍', '🛍️', '📦', '💬', '✅',
  ];

  const QuickEmojiBar({
    super.key,
    required this.onSelectEmoji,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0x1F22C55E), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: popularEmojis.length,
              itemBuilder: (context, index) {
                final emoji = popularEmojis[index];
                return InkWell(
                  onTap: () => onSelectEmoji(emoji),
                  borderRadius: AppRadii.borderMd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(AppIcons.close, size: 18, color: AppColors.textMuted),
            onPressed: onClose,
            tooltip: 'Close Emojis',
          ),
        ],
      ),
    );
  }
}
