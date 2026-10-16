import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/modal_sheet.dart';

class AddCustomFieldSheet extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSave;
  final Map<String, dynamic>? initialValue;

  const AddCustomFieldSheet({
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
      title: initialValue != null ? 'Edit Custom Field' : 'Add Custom Field',
      subtitle: 'Define contact attribute schema',
      child: AddCustomFieldSheet(onSave: onSave, initialValue: initialValue),
    );
  }

  @override
  State<AddCustomFieldSheet> createState() => _AddCustomFieldSheetState();
}

class _AddCustomFieldSheetState extends State<AddCustomFieldSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _defaultValueController;
  late final TextEditingController _optionsController;
  String _fieldType = 'text';
  bool _showInListing = false;
  bool _active = true;
  bool _mandatory = false;

  @override
  void initState() {
    super.initState();
    final v = widget.initialValue;
    _nameController = TextEditingController(text: v?['name'] ?? '');
    _defaultValueController = TextEditingController(text: v?['default_value'] ?? '');
    _optionsController = TextEditingController(text: v?['options'] ?? '');
    _fieldType = v?['field_type'] ?? 'text';
    _showInListing = v?['show_in_listing'] ?? false;
    _active = v?['status'] ?? v?['active'] ?? true;
    _mandatory = v?['mandatory'] ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _defaultValueController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave({
      'name': _nameController.text.trim(),
      'field_type': _fieldType,
      'default_value': _defaultValueController.text.trim().isEmpty
          ? null
          : _defaultValueController.text.trim(),
      'options': _fieldType == 'select' && _optionsController.text.trim().isNotEmpty
          ? _optionsController.text.trim()
          : null,
      'show_in_listing': _showInListing,
      'active': _active,
      'mandatory': _mandatory,
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
            decoration: const InputDecoration(labelText: 'Field Name *'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _fieldType,
            decoration: const InputDecoration(labelText: 'Field Type *'),
            items: const [
              DropdownMenuItem(value: 'text', child: Text('Text')),
              DropdownMenuItem(value: 'number', child: Text('Number')),
              DropdownMenuItem(value: 'date', child: Text('Date')),
              DropdownMenuItem(value: 'boolean', child: Text('Boolean')),
              DropdownMenuItem(value: 'select', child: Text('Select')),
            ],
            onChanged: (v) => setState(() => _fieldType = v ?? 'text'),
            validator: (v) => v == null ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _defaultValueController,
            decoration: const InputDecoration(labelText: 'Default Value (optional)'),
          ),
          if (_fieldType == 'select') ...[
            const SizedBox(height: 14),
            TextFormField(
              controller: _optionsController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Options (JSON)',
                alignLabelWithHint: true,
                hintText: '["Option A", "Option B", "Option C"]',
              ),
            ),
          ],
          const SizedBox(height: 14),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show in Listing', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
            subtitle: const Text('Display this field in contact list view', style: TextStyle(fontSize: 11)),
            value: _showInListing,
            activeColor: AppColors.g600,
            onChanged: (val) => setState(() => _showInListing = val),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Active', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
            subtitle: const Text('Enable this field for data collection', style: TextStyle(fontSize: 11)),
            value: _active,
            activeColor: AppColors.g600,
            onChanged: (val) => setState(() => _active = val),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Mandatory', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
            subtitle: const Text('Require this field when creating contacts', style: TextStyle(fontSize: 11)),
            value: _mandatory,
            activeColor: AppColors.g600,
            onChanged: (val) => setState(() => _mandatory = val),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.g600,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 46),
            ),
            child: Text(isEditing ? 'Update Field' : 'Create Field'),
          ),
        ],
      ),
    );
  }
}
