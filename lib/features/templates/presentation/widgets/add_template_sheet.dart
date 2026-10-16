import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/modal_sheet.dart';

class AddTemplateSheet extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSave;
  final Map<String, dynamic>? initialValue;

  const AddTemplateSheet({
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
      title: initialValue != null ? 'Edit Template' : 'New Template',
      subtitle: 'Add WhatsApp message template fields',
      child: AddTemplateSheet(onSave: onSave, initialValue: initialValue),
    );
  }

  @override
  State<AddTemplateSheet> createState() => _AddTemplateSheetState();
}

class _AddTemplateSheetState extends State<AddTemplateSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _headerController;
  late final TextEditingController _bodyController;
  late final TextEditingController _footerController;
  late final TextEditingController _rejectionReasonController;
  String _category = 'UTILITY';
  String _language = 'en';
  String _status = 'draft';

  @override
  void initState() {
    super.initState();
    final v = widget.initialValue;
    _nameController = TextEditingController(text: v?['name'] ?? '');
    _headerController = TextEditingController(text: v?['header'] ?? '');
    _bodyController = TextEditingController(text: v?['body'] ?? '');
    _footerController = TextEditingController(text: v?['footer'] ?? '');
    _rejectionReasonController = TextEditingController(text: v?['rejection_reason'] ?? '');
    _category = v?['category'] ?? 'UTILITY';
    _language = v?['language'] ?? 'en';
    _status = v?['status'] ?? 'draft';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _headerController.dispose();
    _bodyController.dispose();
    _footerController.dispose();
    _rejectionReasonController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave({
      'name': _nameController.text.trim(),
      'category': _category,
      'language': _language,
      'status': _status,
      'header': _headerController.text.trim().isEmpty ? null : _headerController.text.trim(),
      'body': _bodyController.text.trim(),
      'footer': _footerController.text.trim().isEmpty ? null : _footerController.text.trim(),
      'rejection_reason': _rejectionReasonController.text.trim().isEmpty
          ? null
          : _rejectionReasonController.text.trim(),
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
            decoration: const InputDecoration(labelText: 'Template Name *'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Category *'),
            items: const [
              DropdownMenuItem(value: 'UTILITY', child: Text('UTILITY')),
              DropdownMenuItem(value: 'MARKETING', child: Text('MARKETING')),
              DropdownMenuItem(value: 'AUTHENTICATION', child: Text('AUTHENTICATION')),
            ],
            onChanged: (v) => setState(() => _category = v ?? 'UTILITY'),
            validator: (v) => v == null ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _language,
            decoration: const InputDecoration(labelText: 'Language *'),
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English (en)')),
              DropdownMenuItem(value: 'hi', child: Text('Hindi (hi)')),
              DropdownMenuItem(value: 'ar', child: Text('Arabic (ar)')),
              DropdownMenuItem(value: 'es', child: Text('Spanish (es)')),
              DropdownMenuItem(value: 'fr', child: Text('French (fr)')),
              DropdownMenuItem(value: 'pt_BR', child: Text('Portuguese BR (pt_BR)')),
            ],
            onChanged: (v) => setState(() => _language = v ?? 'en'),
            validator: (v) => v == null ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'draft', child: Text('Draft')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'approved', child: Text('Approved')),
              DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
            onChanged: (v) => setState(() => _status = v ?? 'draft'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _headerController,
            decoration: const InputDecoration(labelText: 'Header (optional)'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _bodyController,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Body *',
              alignLabelWithHint: true,
              hintText: 'Hello {{1}}, your order {{2}} is confirmed.',
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _footerController,
            decoration: const InputDecoration(labelText: 'Footer (optional)'),
          ),
          if (isEditing && _rejectionReasonController.text.isNotEmpty) ...[
            const SizedBox(height: 14),
            TextFormField(
              controller: _rejectionReasonController,
              readOnly: true,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Icon(Icons.info_outline_rounded, size: 18),
                ),
              ),
              style: const TextStyle(color: Color(0xFFB91C1C)),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.g600,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 46),
            ),
            child: Text(isEditing ? 'Update Template' : 'Create Template'),
          ),
        ],
      ),
    );
  }
}
