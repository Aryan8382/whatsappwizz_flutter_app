import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../shared/widgets/modal_sheet.dart';

class AddNumberSheet extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSave;
  final Map<String, dynamic>? initialValue;

  const AddNumberSheet({
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
      title: initialValue != null ? 'Edit WhatsApp Number' : 'Add WhatsApp Number',
      subtitle: 'Register a WhatsApp Business phone number',
      child: AddNumberSheet(onSave: onSave, initialValue: initialValue),
    );
  }

  @override
  State<AddNumberSheet> createState() => _AddNumberSheetState();
}

class _AddNumberSheetState extends State<AddNumberSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _phoneNumberIdController;
  late final TextEditingController _displayNameController;
  late final TextEditingController _wabaAccountIdController;
  String _verificationStatus = 'pending';
  String _qualityRating = 'GREEN';

  @override
  void initState() {
    super.initState();
    final v = widget.initialValue;
    _phoneNumberController = TextEditingController(text: v?['phone_number'] ?? '');
    _phoneNumberIdController = TextEditingController(text: v?['phone_number_id'] ?? '');
    _displayNameController = TextEditingController(text: v?['display_name'] ?? '');
    _wabaAccountIdController = TextEditingController(text: v?['waba_account_id']?.toString() ?? '');
    _verificationStatus = v?['verification_status'] ?? 'pending';
    _qualityRating = v?['quality_rating'] ?? 'GREEN';
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _phoneNumberIdController.dispose();
    _displayNameController.dispose();
    _wabaAccountIdController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave({
      'phone_number': _phoneNumberController.text.trim(),
      'phone_number_id': _phoneNumberIdController.text.trim(),
      'display_name': _displayNameController.text.trim(),
      'waba_account_id': int.tryParse(_wabaAccountIdController.text.trim()),
      'verification_status': _verificationStatus,
      'quality_rating': _qualityRating,
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
            controller: _phoneNumberController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number *',
              hintText: '+91 90000 00001',
              prefixIcon: Icon(LucideIcons.phone, size: 18),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _phoneNumberIdController,
            decoration: const InputDecoration(labelText: 'Phone Number ID *'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _displayNameController,
            decoration: const InputDecoration(labelText: 'Display Name *'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _wabaAccountIdController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'WABA Account ID *'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _verificationStatus,
            decoration: const InputDecoration(labelText: 'Verification Status'),
            items: const [
              DropdownMenuItem(value: 'verified', child: Text('Verified')),
              DropdownMenuItem(value: 'unverified', child: Text('Unverified')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
            ],
            onChanged: (v) => setState(() => _verificationStatus = v ?? 'pending'),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _qualityRating,
            decoration: const InputDecoration(labelText: 'Quality Rating'),
            items: const [
              DropdownMenuItem(value: 'GREEN', child: Text('Green')),
              DropdownMenuItem(value: 'YELLOW', child: Text('Yellow')),
              DropdownMenuItem(value: 'RED', child: Text('Red')),
            ],
            onChanged: (v) => setState(() => _qualityRating = v ?? 'GREEN'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.g600,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 46),
            ),
            child: Text(isEditing ? 'Update Number' : 'Add WhatsApp Number'),
          ),
        ],
      ),
    );
  }
}
