import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/widgets/modal_sheet.dart';
import '../../domain/contact.dart';

class CreateSegmentSheet extends StatefulWidget {
  final List<Contact> allContacts;
  final List<String> availableTags;
  final void Function(String name, String tagFilter, bool optInOnly, String filters) onSave;

  const CreateSegmentSheet({
    super.key,
    required this.allContacts,
    required this.availableTags,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required List<Contact> allContacts,
    required List<String> availableTags,
    required void Function(String name, String tagFilter, bool optInOnly, String filters) onSave,
  }) {
    return ModalSheet.show(
      context: context,
      title: 'Build Audience Segment',
      subtitle: 'Create targeted audience group with live preview',
      child: CreateSegmentSheet(
        allContacts: allContacts,
        availableTags: availableTags,
        onSave: onSave,
      ),
    );
  }

  @override
  State<CreateSegmentSheet> createState() => _CreateSegmentSheetState();
}

class _CreateSegmentSheetState extends State<CreateSegmentSheet> {
  final _nameController = TextEditingController();
  final _filtersController = TextEditingController();
  String _selectedTag = '';
  bool _optInOnly = true;

  int get _matchingCount {
    return widget.allContacts.where((c) {
      if (_optInOnly && !c.optIn) return false;
      if (_selectedTag.isNotEmpty && !c.tags.contains(_selectedTag)) return false;
      return true;
    }).length;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _filtersController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    widget.onSave(name, _selectedTag, _optInOnly, _filtersController.text.trim());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final count = _matchingCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Live audience count preview box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.g50,
            borderRadius: AppRadii.border2xl,
            border: Border.all(color: AppColors.g200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(AppIcons.contacts, color: AppColors.g700, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count Matching Contacts',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.g950,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ready to receive targeted WhatsApp broadcasts',
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Segment Name
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Segment Name *',
            hintText: 'e.g. VIP Customers Q4',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),

        // Filters JSON
        TextFormField(
          controller: _filtersController,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Filters (JSON, optional)',
            alignLabelWithHint: true,
            hintText: '{"tag":"VIP","opt_in":true}',
          ),
        ),
        const SizedBox(height: 16),

        // Filter by Tag
        const Text('Filter by Tag', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All Tags'),
              selected: _selectedTag.isEmpty,
              onSelected: (_) => setState(() => _selectedTag = ''),
            ),
            ...widget.availableTags.map((t) {
              return ChoiceChip(
                label: Text(t),
                selected: _selectedTag == t,
                onSelected: (_) => setState(() => _selectedTag = t),
              );
            }),
          ],
        ),
        const SizedBox(height: 16),

        // Opt-In only checkbox
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Only include opted-in contacts', style: TextStyle(fontSize: 13.5)),
          subtitle: const Text('Ensures zero WhatsApp policy spam flags', style: TextStyle(fontSize: 11)),
          value: _optInOnly,
          activeColor: AppColors.g600,
          onChanged: (val) => setState(() => _optInOnly = val ?? true),
        ),
        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: _nameController.text.trim().isNotEmpty ? _handleSubmit : null,
          child: const Text('Save Segment'),
        ),
      ],
    );
  }
}
