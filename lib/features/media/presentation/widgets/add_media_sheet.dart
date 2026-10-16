import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../shared/widgets/modal_sheet.dart';

class AddMediaSheet extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSave;
  final Map<String, dynamic>? initialValue;

  const AddMediaSheet({
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
      title: initialValue != null ? 'Edit Media Asset' : 'Add Media Asset',
      subtitle: 'Register a media file by URL',
      child: AddMediaSheet(onSave: onSave, initialValue: initialValue),
    );
  }

  @override
  State<AddMediaSheet> createState() => _AddMediaSheetState();
}

class _AddMediaSheetState extends State<AddMediaSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _urlController;
  late final TextEditingController _sizeController;
  String _mimeType = 'image/jpeg';

  @override
  void initState() {
    super.initState();
    final v = widget.initialValue;
    _nameController = TextEditingController(text: v?['name'] ?? '');
    _urlController = TextEditingController(text: v?['url'] ?? '');
    _sizeController = TextEditingController(text: v?['size']?.toString() ?? '');
    _mimeType = v?['mime_type'] ?? 'image/jpeg';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave({
      'name': _nameController.text.trim(),
      'mime_type': _mimeType,
      'url': _urlController.text.trim(),
      'size': _sizeController.text.trim().isEmpty
          ? null
          : int.tryParse(_sizeController.text.trim()),
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
            decoration: const InputDecoration(labelText: 'Asset Name *'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _mimeType,
            decoration: const InputDecoration(labelText: 'MIME Type *'),
            items: const [
              DropdownMenuItem(value: 'image/jpeg', child: Text('image/jpeg')),
              DropdownMenuItem(value: 'image/png', child: Text('image/png')),
              DropdownMenuItem(value: 'video/mp4', child: Text('video/mp4')),
              DropdownMenuItem(value: 'audio/mpeg', child: Text('audio/mpeg')),
              DropdownMenuItem(value: 'application/pdf', child: Text('application/pdf')),
            ],
            onChanged: (v) => setState(() => _mimeType = v ?? 'image/jpeg'),
            validator: (v) => v == null ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'URL *',
              hintText: 'https://example.com/file.jpg',
              prefixIcon: Icon(LucideIcons.link, size: 18),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _sizeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Size (bytes)',
              hintText: 'Size in bytes',
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
            child: Text(isEditing ? 'Update Asset' : 'Add Media Asset'),
          ),
        ],
      ),
    );
  }
}
