import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/modal_sheet.dart';

class TagManagerSheet extends StatefulWidget {
  final List<String> tags;
  final void Function(String tag, String color) onAddTag;

  const TagManagerSheet({
    super.key,
    required this.tags,
    required this.onAddTag,
  });

  static Future<void> show(
    BuildContext context, {
    required List<String> tags,
    required void Function(String tag, String color) onAddTag,
  }) {
    return ModalSheet.show(
      context: context,
      title: 'Tag Manager',
      subtitle: 'Manage labels applied to WhatsApp contacts',
      child: TagManagerSheet(tags: tags, onAddTag: onAddTag),
    );
  }

  @override
  State<TagManagerSheet> createState() => _TagManagerSheetState();
}

class _TagManagerSheetState extends State<TagManagerSheet> {
  final _tagController = TextEditingController();
  String _selectedColor = '#25D366';

  static const List<String> _presetColors = [
    '#25D366',
    '#16A34A',
    '#EF4444',
    '#3B82F6',
    '#F59E0B',
    '#8B5CF6',
    '#EC4899',
    '#64748B',
  ];

  Color _fromHex(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  void _handleAdd() {
    final text = _tagController.text.trim();
    if (text.isEmpty) return;
    widget.onAddTag(text, _selectedColor);
    _tagController.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  hintText: 'Enter new tag name...',
                  isDense: true,
                ),
                onSubmitted: (_) => _handleAdd(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _handleAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.g600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Tag Color', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _presetColors.map((hex) {
            final isSelected = _selectedColor == hex;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = hex),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _fromHex(hex),
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.black, width: 2)
                      : Border.all(color: Colors.transparent, width: 2),
                ),
                alignment: Alignment.center,
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        const Text('Existing Tags', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.tags.map((t) {
            return Chip(
              label: Text(t, style: const TextStyle(fontSize: 12)),
              backgroundColor: AppColors.g50,
              side: const BorderSide(color: AppColors.g200),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
