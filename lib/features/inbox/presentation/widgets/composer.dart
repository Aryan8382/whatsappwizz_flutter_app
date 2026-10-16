import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/services/toast_service.dart';
import 'quick_emoji_bar.dart';

class Composer extends StatefulWidget {
  final bool isWindowExpired;
  final ValueChanged<String> onSendText;
  final ValueChanged<String> onSendInternalNote;
  final VoidCallback onPickTemplate;
  final VoidCallback onPickAttachment;

  const Composer({
    super.key,
    required this.isWindowExpired,
    required this.onSendText,
    required this.onSendInternalNote,
    required this.onPickTemplate,
    required this.onPickAttachment,
  });

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  final TextEditingController _textController = TextEditingController();
  bool _isInternalNote = false;
  bool _showEmojis = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    if (_isInternalNote) {
      widget.onSendInternalNote(text);
    } else {
      widget.onSendText(text);
    }

    _textController.clear();
    setState(() {});
  }

  void _showAttachmentMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, -2)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachOption(
                  icon: LucideIcons.fileText,
                  color: const Color(0xFF7F66FF),
                  label: 'Document',
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onPickAttachment();
                  },
                ),
                _buildAttachOption(
                  icon: LucideIcons.camera,
                  color: const Color(0xFFD3396D),
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(ctx);
                    ToastService.info('Camera opened');
                  },
                ),
                _buildAttachOption(
                  icon: LucideIcons.image,
                  color: const Color(0xFFAC44CF),
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onPickAttachment();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachOption(
                  icon: LucideIcons.headphones,
                  color: const Color(0xFFFF6A3D),
                  label: 'Audio',
                  onTap: () {
                    Navigator.pop(ctx);
                    ToastService.info('Audio picker opened');
                  },
                ),
                _buildAttachOption(
                  icon: LucideIcons.wand2,
                  color: const Color(0xFF00A884),
                  label: 'Template',
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onPickTemplate();
                  },
                ),
                _buildAttachOption(
                  icon: LucideIcons.user,
                  color: const Color(0xFF009DE2),
                  label: 'Contact',
                  onTap: () {
                    Navigator.pop(ctx);
                    ToastService.info('Contact sharing opened');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3B4A54)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isWindowExpired) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFFFEF2F2),
          border: Border(top: BorderSide(color: Color(0xFFFCA5A5))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Icon(LucideIcons.clock, color: AppColors.statusRedText, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '24-Hour Service Window Expired',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.statusRedText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Freeform replies are blocked by Meta. Send an approved template message to resume chatting.',
              style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: widget.onPickTemplate,
              icon: const Icon(AppIcons.templates, size: 18),
              label: const Text('Select Approved Template'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.g600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppRadii.borderXl),
              ),
            ),
          ],
        ),
      );
    }

    final hasText = _textController.text.trim().isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF0B141A) : const Color(0xFFEFEAE2),
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emojis bar if toggled
            if (_showEmojis) ...[
              QuickEmojiBar(
                onSelectEmoji: (emoji) {
                  final current = _textController.text;
                  final selection = _textController.selection;
                  if (selection.isValid && selection.start >= 0) {
                    final newText = current.replaceRange(selection.start, selection.end, emoji);
                    _textController.text = newText;
                    _textController.selection = TextSelection.collapsed(offset: selection.start + emoji.length);
                  } else {
                    _textController.text = current + emoji;
                  }
                  setState(() {});
                },
                onClose: () => setState(() => _showEmojis = false),
              ),
              const SizedBox(height: 6),
            ],

            // Internal Note Banner if active
            if (_isInternalNote) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF9C3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE047)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.lock, size: 14, color: Color(0xFF854D0E)),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Internal Note (Visible to team only)',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF854D0E),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _isInternalNote = false),
                      child: const Icon(AppIcons.close, size: 16, color: Color(0xFF854D0E)),
                    ),
                  ],
                ),
              ),
            ],

            // Authentic WhatsApp-Style Input Bar
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Seamless Input Pill
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isInternalNote
                          ? const Color(0xFFFEFCE8)
                          : (isDark ? const Color(0xFF1F2C34) : Colors.white),
                      borderRadius: BorderRadius.circular(25),
                      border: _isInternalNote
                          ? Border.all(color: const Color(0xFFFDE047), width: 1)
                          : null, // Zero harsh borders, exactly like official WhatsApp
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 1.5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // WhatsApp Smiley / Emoji Toggle
                        IconButton(
                          icon: Icon(
                            _showEmojis
                                ? Icons.keyboard_alt_outlined
                                : Icons.sentiment_satisfied_alt_rounded,
                            size: 23,
                            color: _showEmojis
                                ? const Color(0xFF00A884)
                                : const Color(0xFF8696A0),
                          ),
                          onPressed: () => setState(() => _showEmojis = !_showEmojis),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          constraints: const BoxConstraints(),
                          splashRadius: 20,
                          tooltip: 'Emoji & Stickers',
                        ),

                        // Seamless Message Field (Takes all remaining width with zero inner borders)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: TextField(
                              controller: _textController,
                              maxLines: 5,
                              minLines: 1,
                              textCapitalization: TextCapitalization.sentences,
                              cursorColor: const Color(0xFF00A884),
                              cursorWidth: 2.0,
                              cursorRadius: const Radius.circular(2),
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white : const Color(0xFF111B21),
                                height: 1.25,
                              ),
                              decoration: InputDecoration(
                                hintText: _isInternalNote ? 'Write internal note...' : 'Message',
                                hintStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF8696A0),
                                  fontWeight: FontWeight.w400,
                                ),
                                // Explicitly disable any inherited outline borders and fills from theme
                                filled: false,
                                fillColor: Colors.transparent,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ),

                        // Attachment Paperclip
                        IconButton(
                          icon: const Icon(
                            Icons.attach_file_rounded,
                            size: 22,
                            color: Color(0xFF8696A0),
                          ),
                          onPressed: () => _showAttachmentMenu(context),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                          constraints: const BoxConstraints(),
                          splashRadius: 20,
                          tooltip: 'Attach',
                        ),

                        // Quick Templates Wand
                        IconButton(
                          icon: const Icon(
                            LucideIcons.wand2,
                            size: 20,
                            color: Color(0xFF8696A0),
                          ),
                          onPressed: widget.onPickTemplate,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                          constraints: const BoxConstraints(),
                          splashRadius: 20,
                          tooltip: 'Templates',
                        ),

                        // Internal Note Toggle Lock
                        IconButton(
                          icon: Icon(
                            _isInternalNote ? Icons.lock_rounded : Icons.lock_outline_rounded,
                            size: 20,
                            color: _isInternalNote ? const Color(0xFFCA8A04) : const Color(0xFF8696A0),
                          ),
                          onPressed: () => setState(() => _isInternalNote = !_isInternalNote),
                          padding: const EdgeInsets.only(left: 4, right: 8, top: 8, bottom: 8),
                          constraints: const BoxConstraints(),
                          splashRadius: 20,
                          tooltip: 'Internal Note',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Circular WhatsApp Mic / Send Floating Action Button
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isInternalNote
                        ? const Color(0xFFCA8A04)
                        : const Color(0xFF00A884),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isInternalNote ? const Color(0xFFCA8A04) : const Color(0xFF00A884))
                            .withOpacity(0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: hasText
                          ? _handleSend
                          : () => ToastService.info('Voice message recording...'),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            hasText ? Icons.send_rounded : Icons.mic_rounded,
                            key: ValueKey<bool>(hasText),
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
