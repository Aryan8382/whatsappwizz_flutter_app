import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/modal_sheet.dart';

class AddBotSheet extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSave;
  final Map<String, dynamic>? initialValue;

  const AddBotSheet({
    super.key,
    required this.onSave,
    this.initialValue,
  });

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<Map<String, dynamic>> onSave,
    Map<String, dynamic>? initialValue,
  }) {
    return ModalSheet.show(
      context: context,
      title: initialValue != null ? 'Edit Bot Flow' : 'New Bot Flow',
      subtitle: 'Create a new chatbot flow configuration',
      child: AddBotSheet(onSave: onSave, initialValue: initialValue),
    );
  }

  @override
  State<AddBotSheet> createState() => _AddBotSheetState();
}

class _AddBotSheetState extends State<AddBotSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _configController;
  bool _published = false;

  @override
  void initState() {
    super.initState();
    final v = widget.initialValue;
    _nameController = TextEditingController(text: v?['name'] ?? '');
    _configController = TextEditingController(text: v?['config'] ?? '');
    _published = v?['published'] ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _configController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave({
      'name': _nameController.text.trim(),
      'published': _published,
      'config': _configController.text.trim().isEmpty ? null : _configController.text.trim(),
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialValue != null;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Bot Flow Name *'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Published', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
            subtitle: const Text('Make this bot flow live immediately', style: TextStyle(fontSize: 11)),
            value: _published,
            activeColor: AppColors.g600,
            onChanged: (val) => setState(() => _published = val),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _configController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Config (JSON, optional)',
              alignLabelWithHint: true,
              hintText: '{"key": "value"}',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.g600,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 46),
            ),
            child: Text(isEditing ? 'Update Bot Flow' : 'Create Bot Flow'),
          ),
        ],
      ),
    );
  }
}
