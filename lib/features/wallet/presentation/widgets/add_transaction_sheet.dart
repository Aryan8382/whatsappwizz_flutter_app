import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/modal_sheet.dart';

class AddTransactionSheet extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSave;

  const AddTransactionSheet({
    super.key,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<Map<String, dynamic>> onSave,
  }) {
    return ModalSheet.show(
      context: context,
      title: 'Add Transaction',
      subtitle: 'Manually record a wallet transaction',
      child: AddTransactionSheet(onSave: onSave),
    );
  }

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _type = 'credit';

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave({
      'type': _type,
      'amount': _amountController.text.trim(),
      'reference': _referenceController.text.trim().isEmpty
          ? null
          : _referenceController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
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
          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Transaction Type *'),
            items: const [
              DropdownMenuItem(value: 'credit', child: Text('Credit')),
              DropdownMenuItem(value: 'debit', child: Text('Debit')),
              DropdownMenuItem(value: 'refund', child: Text('Refund')),
            ],
            onChanged: (v) => setState(() => _type = v ?? 'credit'),
            validator: (v) => v == null ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount *',
              hintText: '0.00',
              prefixText: '₹ ',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              if (double.tryParse(v.trim()) == null) return 'Enter a valid amount';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _referenceController,
            decoration: const InputDecoration(
              labelText: 'Reference (optional)',
              hintText: 'e.g. pay_Oz7K19xP2la98q',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              alignLabelWithHint: true,
              hintText: 'Brief note about this transaction',
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
            child: const Text('Record Transaction'),
          ),
        ],
      ),
    );
  }
}
