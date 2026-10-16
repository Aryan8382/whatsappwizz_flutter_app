import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/modal_sheet.dart';

class AddAutomationSheet extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSave;
  final Map<String, dynamic>? initialValue;

  const AddAutomationSheet({
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
      title: initialValue != null ? 'Edit Automation' : 'New Automation',
      subtitle: 'Create event-driven workflow rule',
      child: AddAutomationSheet(onSave: onSave, initialValue: initialValue),
    );
  }

  @override
  State<AddAutomationSheet> createState() => _AddAutomationSheetState();
}

class _AddAutomationSheetState extends State<AddAutomationSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _triggerConfigController;
  late final TextEditingController _stepsController;
  String _status = 'draft';
  String _triggerType = 'new_contact';

  @override
  void initState() {
    super.initState();
    final v = widget.initialValue;
    _nameController = TextEditingController(text: v?['name'] ?? '');
    _triggerConfigController = TextEditingController(text: v?['trigger_config'] ?? '');
    _stepsController = TextEditingController(text: v?['steps'] ?? '');
    _status = v?['status'] ?? 'draft';
    _triggerType = v?['trigger_type'] ?? 'new_contact';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _triggerConfigController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave({
      'name': _nameController.text.trim(),
      'status': _status,
      'trigger_type': _triggerType,
      'trigger_config': _triggerConfigController.text.trim().isEmpty
          ? null
          : _triggerConfigController.text.trim(),
      'steps': _stepsController.text.trim().isEmpty ? null : _stepsController.text.trim(),
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
            decoration: const InputDecoration(labelText: 'Automation Name *'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'draft', child: Text('Draft')),
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'paused', child: Text('Paused')),
              DropdownMenuItem(value: 'archived', child: Text('Archived')),
            ],
            onChanged: (v) => setState(() => _status = v ?? 'draft'),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _triggerType,
            decoration: const InputDecoration(labelText: 'Trigger Type *'),
            items: const [
              DropdownMenuItem(value: 'new_contact', child: Text('New Contact')),
              DropdownMenuItem(value: 'keyword', child: Text('Keyword')),
              DropdownMenuItem(value: 'opt_in', child: Text('Opt-In')),
              DropdownMenuItem(value: 'inbound_message', child: Text('Inbound Message')),
              DropdownMenuItem(value: 'scheduled', child: Text('Scheduled')),
            ],
            onChanged: (v) => setState(() => _triggerType = v ?? 'new_contact'),
            validator: (v) => v == null ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _triggerConfigController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Trigger Config (JSON, optional)',
              alignLabelWithHint: true,
              hintText: '{"key": "value"}',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _stepsController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Steps (JSON, optional)',
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
            child: Text(isEditing ? 'Update Automation' : 'Create Automation'),
          ),
        ],
      ),
    );
  }
}
