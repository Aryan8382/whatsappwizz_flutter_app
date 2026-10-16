import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../shared/widgets/modal_sheet.dart';

class AddUserSheet extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSave;
  final Map<String, dynamic>? initialValue;

  const AddUserSheet({
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
      title: initialValue != null ? 'Edit Team Member' : 'Add Team Member',
      subtitle: 'Creates a new users record',
      child: AddUserSheet(onSave: onSave, initialValue: initialValue),
    );
  }

  @override
  State<AddUserSheet> createState() => _AddUserSheetState();
}

class _AddUserSheetState extends State<AddUserSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _passwordController;
  late final TextEditingController _avatarController;
  String _status = 'active';
  int _roleId = 3;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final v = widget.initialValue;
    _firstNameController = TextEditingController(text: v?['first_name'] ?? '');
    _lastNameController = TextEditingController(text: v?['last_name'] ?? '');
    _emailController = TextEditingController(text: v?['email'] ?? '');
    _mobileController = TextEditingController(text: v?['mobile'] ?? '');
    _passwordController = TextEditingController();
    _avatarController = TextEditingController(text: v?['avatar'] ?? '');
    _status = v?['status'] ?? 'active';
    _roleId = v?['role_id'] ?? 3;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave({
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'mobile': _mobileController.text.trim(),
      'password_hash': _passwordController.text,
      'avatar': _avatarController.text.trim().isEmpty ? null : _avatarController.text.trim(),
      'status': _status,
      'role_id': _roleId,
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
          // First Name + Last Name row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name *'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email *',
              prefixIcon: Icon(LucideIcons.mail, size: 18),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Mobile',
              prefixIcon: Icon(LucideIcons.phone, size: 18),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: isEditing ? 'Password (leave blank to keep)' : 'Password *',
              prefixIcon: const Icon(LucideIcons.lock, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 18,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: isEditing
                ? null
                : (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _avatarController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Avatar URL (optional)',
              prefixIcon: Icon(LucideIcons.image, size: 18),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
              DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
            ],
            onChanged: (v) => setState(() => _status = v ?? 'active'),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<int>(
            value: _roleId,
            decoration: const InputDecoration(labelText: 'Role *'),
            items: const [
              DropdownMenuItem(value: 1, child: Text('1 — Admin')),
              DropdownMenuItem(value: 2, child: Text('2 — Manager')),
              DropdownMenuItem(value: 3, child: Text('3 — Agent')),
            ],
            onChanged: (v) => setState(() => _roleId = v ?? 3),
            validator: (v) => v == null ? 'Required' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.g600,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 46),
            ),
            child: Text(isEditing ? 'Update User' : 'Create User'),
          ),
        ],
      ),
    );
  }
}
