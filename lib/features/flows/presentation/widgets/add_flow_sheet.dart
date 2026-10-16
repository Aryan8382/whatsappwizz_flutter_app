import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/modal_sheet.dart';

class AddFlowSheet extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSave;
  final Map<String, dynamic>? initialValue;

  const AddFlowSheet({
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
      title: initialValue != null ? 'Edit WhatsApp Flow' : 'New WhatsApp Flow',
      subtitle: 'Create interactive multi-screen native flow',
      child: AddFlowSheet(onSave: onSave, initialValue: initialValue),
    );
  }

  @override
  State<AddFlowSheet> createState() => _AddFlowSheetState();
}

class _AddFlowSheetState extends State<AddFlowSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _screensController;
  String _category = 'OTHER';
  String _status = 'draft';
  String _healthStatus = 'healthy';

  @override
  void initState() {
    super.initState();
    final v = widget.initialValue;
    _nameController = TextEditingController(text: v?['name'] ?? '');
    _screensController = TextEditingController(text: v?['screens'] ?? '');
    _category = v?['category'] ?? 'OTHER';
    _status = v?['status'] ?? 'draft';
    _healthStatus = v?['health_status'] ?? 'healthy';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _screensController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave({
      'name': _nameController.text.trim(),
      'category': _category,
      'status': _status,
      'health_status': _healthStatus,
      'screens': _screensController.text.trim().isEmpty ? null : _screensController.text.trim(),
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
            decoration: const InputDecoration(labelText: 'Flow Name *'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Category *'),
            items: const [
              DropdownMenuItem(value: 'SIGN_UP', child: Text('Sign Up')),
              DropdownMenuItem(value: 'SIGN_IN', child: Text('Sign In')),
              DropdownMenuItem(value: 'APPOINTMENT_BOOKING', child: Text('Appointment Booking')),
              DropdownMenuItem(value: 'LEAD_GENERATION', child: Text('Lead Generation')),
              DropdownMenuItem(value: 'CONTACT_US', child: Text('Contact Us')),
              DropdownMenuItem(value: 'CUSTOMER_SUPPORT', child: Text('Customer Support')),
              DropdownMenuItem(value: 'SURVEY', child: Text('Survey')),
              DropdownMenuItem(value: 'OTHER', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => _category = v ?? 'OTHER'),
            validator: (v) => v == null ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'draft', child: Text('Draft')),
              DropdownMenuItem(value: 'published', child: Text('Published')),
              DropdownMenuItem(value: 'deprecated', child: Text('Deprecated')),
              DropdownMenuItem(value: 'blocked', child: Text('Blocked')),
            ],
            onChanged: (v) => setState(() => _status = v ?? 'draft'),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _healthStatus,
            decoration: const InputDecoration(labelText: 'Health Status'),
            items: const [
              DropdownMenuItem(value: 'healthy', child: Text('Healthy')),
              DropdownMenuItem(value: 'needs_update', child: Text('Needs Update')),
              DropdownMenuItem(value: 'blocked', child: Text('Blocked')),
            ],
            onChanged: (v) => setState(() => _healthStatus = v ?? 'healthy'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _screensController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Screens (JSON, optional)',
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
            child: Text(isEditing ? 'Update Flow' : 'Create Flow'),
          ),
        ],
      ),
    );
  }
}
