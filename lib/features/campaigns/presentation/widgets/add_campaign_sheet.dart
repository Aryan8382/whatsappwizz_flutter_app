import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../shared/widgets/modal_sheet.dart';

class AddCampaignSheet extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSave;
  final Map<String, dynamic>? initialValue;

  const AddCampaignSheet({
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
      title: initialValue != null ? 'Edit Campaign' : 'New Campaign',
      subtitle: 'Configure broadcast campaign settings',
      child: AddCampaignSheet(onSave: onSave, initialValue: initialValue),
    );
  }

  @override
  State<AddCampaignSheet> createState() => _AddCampaignSheetState();
}

class _AddCampaignSheetState extends State<AddCampaignSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _templateIdController;
  late final TextEditingController _scheduledAtController;
  late final TextEditingController _rateController;
  late final TextEditingController _audienceController;
  String _status = 'draft';

  @override
  void initState() {
    super.initState();
    final v = widget.initialValue;
    _nameController = TextEditingController(text: v?['name'] ?? '');
    _templateIdController = TextEditingController(text: v?['template_id']?.toString() ?? '');
    _scheduledAtController = TextEditingController(text: v?['scheduled_at'] ?? '');
    _rateController = TextEditingController(text: v?['rate_per_minute']?.toString() ?? '60');
    _audienceController = TextEditingController(text: v?['audience'] ?? '');
    _status = v?['status'] ?? 'draft';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _templateIdController.dispose();
    _scheduledAtController.dispose();
    _rateController.dispose();
    _audienceController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final formatted =
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    setState(() => _scheduledAtController.text = formatted);
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave({
      'name': _nameController.text.trim(),
      'template_id': _templateIdController.text.trim(),
      'status': _status,
      'scheduled_at': _scheduledAtController.text.trim().isEmpty
          ? null
          : _scheduledAtController.text.trim(),
      'rate_per_minute': int.tryParse(_rateController.text.trim()) ?? 60,
      'audience': _audienceController.text.trim().isEmpty
          ? null
          : _audienceController.text.trim(),
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
            decoration: const InputDecoration(labelText: 'Campaign Name *'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _templateIdController,
            decoration: const InputDecoration(
              labelText: 'Template ID *',
              hintText: 'e.g. 12345',
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'draft', child: Text('Draft')),
              DropdownMenuItem(value: 'running', child: Text('Running')),
              DropdownMenuItem(value: 'paused', child: Text('Paused')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
              DropdownMenuItem(value: 'failed', child: Text('Failed')),
            ],
            onChanged: (v) => setState(() => _status = v ?? 'draft'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _scheduledAtController,
            readOnly: true,
            onTap: _pickDateTime,
            decoration: InputDecoration(
              labelText: 'Scheduled At',
              hintText: 'Tap to select date & time',
              suffixIcon: IconButton(
                icon: const Icon(LucideIcons.clock, size: 18),
                onPressed: _pickDateTime,
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _rateController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Rate per Minute',
              hintText: '60',
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _audienceController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Audience (JSON, optional)',
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
            child: Text(isEditing ? 'Update Campaign' : 'Create Campaign'),
          ),
        ],
      ),
    );
  }
}
