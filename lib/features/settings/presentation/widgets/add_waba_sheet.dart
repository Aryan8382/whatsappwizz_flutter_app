import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../shared/widgets/modal_sheet.dart';

class AddWabaSheet extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSave;
  final Map<String, dynamic>? initialValue;

  const AddWabaSheet({
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
      title: initialValue != null ? 'Edit WABA Account' : 'Add WABA Account',
      subtitle: 'Connect a WhatsApp Business Account',
      child: AddWabaSheet(onSave: onSave, initialValue: initialValue),
    );
  }

  @override
  State<AddWabaSheet> createState() => _AddWabaSheetState();
}

class _AddWabaSheetState extends State<AddWabaSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _businessIdController;
  late final TextEditingController _wabaIdController;
  late final TextEditingController _accessTokenController;
  late final TextEditingController _tokenExpiryController;
  String _qualityRating = 'UNKNOWN';
  String _status = 'connected';
  bool _obscureToken = true;

  @override
  void initState() {
    super.initState();
    final v = widget.initialValue;
    _businessIdController = TextEditingController(text: v?['business_id'] ?? '');
    _wabaIdController = TextEditingController(text: v?['waba_id'] ?? '');
    _accessTokenController = TextEditingController(text: v?['access_token'] ?? '');
    _tokenExpiryController = TextEditingController(text: v?['token_expiry'] ?? '');
    _qualityRating = v?['quality_rating'] ?? 'UNKNOWN';
    _status = v?['status'] ?? 'connected';
  }

  @override
  void dispose() {
    _businessIdController.dispose();
    _wabaIdController.dispose();
    _accessTokenController.dispose();
    _tokenExpiryController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 60)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null) return;
    final formatted =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    setState(() => _tokenExpiryController.text = formatted);
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave({
      'business_id': _businessIdController.text.trim(),
      'waba_id': _wabaIdController.text.trim(),
      'access_token': _accessTokenController.text,
      'token_expiry': _tokenExpiryController.text.trim().isEmpty
          ? null
          : _tokenExpiryController.text.trim(),
      'quality_rating': _qualityRating,
      'status': _status,
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
            controller: _businessIdController,
            decoration: const InputDecoration(labelText: 'Business ID *'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _wabaIdController,
            decoration: const InputDecoration(labelText: 'WABA ID *'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _accessTokenController,
            obscureText: _obscureToken,
            decoration: InputDecoration(
              labelText: 'Access Token *',
              prefixIcon: const Icon(LucideIcons.key, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureToken ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 18,
                ),
                onPressed: () => setState(() => _obscureToken = !_obscureToken),
              ),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _tokenExpiryController,
            readOnly: true,
            onTap: _pickDate,
            decoration: InputDecoration(
              labelText: 'Token Expiry Date',
              hintText: 'Tap to select date',
              suffixIcon: IconButton(
                icon: const Icon(LucideIcons.clock, size: 18),
                onPressed: _pickDate,
              ),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _qualityRating,
            decoration: const InputDecoration(labelText: 'Quality Rating'),
            items: const [
              DropdownMenuItem(value: 'UNKNOWN', child: Text('Unknown')),
              DropdownMenuItem(value: 'GREEN', child: Text('Green')),
              DropdownMenuItem(value: 'YELLOW', child: Text('Yellow')),
              DropdownMenuItem(value: 'RED', child: Text('Red')),
            ],
            onChanged: (v) => setState(() => _qualityRating = v ?? 'UNKNOWN'),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'connected', child: Text('Connected')),
              DropdownMenuItem(value: 'disconnected', child: Text('Disconnected')),
              DropdownMenuItem(value: 'banned', child: Text('Banned')),
            ],
            onChanged: (v) => setState(() => _status = v ?? 'connected'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.g600,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 46),
            ),
            child: Text(isEditing ? 'Update WABA Account' : 'Add WABA Account'),
          ),
        ],
      ),
    );
  }
}
