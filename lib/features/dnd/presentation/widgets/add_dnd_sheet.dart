import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../shared/widgets/modal_sheet.dart';

class AddDndSheet extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSave;

  const AddDndSheet({
    super.key,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<Map<String, dynamic>> onSave,
  }) {
    return ModalSheet.show(
      context: context,
      title: 'Add to DND List',
      subtitle: 'Block this number from receiving messages',
      child: AddDndSheet(onSave: onSave),
    );
  }

  @override
  State<AddDndSheet> createState() => _AddDndSheetState();
}

class _AddDndSheetState extends State<AddDndSheet> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _numberController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave({
      'number': _numberController.text.trim(),
      'message': _messageController.text.trim().isEmpty ? null : _messageController.text.trim(),
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _numberController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number *',
              hintText: 'e.g. 919876543210',
              prefixIcon: Icon(LucideIcons.phoneOff, size: 18),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _messageController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason / Note (optional)',
              alignLabelWithHint: true,
              hintText: 'e.g. Customer requested opt-out',
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
            child: const Text('Add to DND'),
          ),
        ],
      ),
    );
  }
}
