import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/widgets/modal_sheet.dart';
import '../../domain/template.dart';

class TemplateBuilderSheet extends StatefulWidget {
  final ValueChanged<Template> onSave;

  const TemplateBuilderSheet({super.key, required this.onSave});

  static Future<void> show(BuildContext context, {required ValueChanged<Template> onSave}) {
    return ModalSheet.show(
      context: context,
      title: 'Create Meta Template',
      subtitle: 'Compose WhatsApp message template with live preview',
      child: TemplateBuilderSheet(onSave: onSave),
    );
  }

  @override
  State<TemplateBuilderSheet> createState() => _TemplateBuilderSheetState();
}

class _TemplateBuilderSheetState extends State<TemplateBuilderSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _headerController = TextEditingController();
  final _bodyController = TextEditingController(text: 'Hi {{1}}, thank you for your order with {{2}}!');
  final _footerController = TextEditingController(text: 'Reply STOP to opt out');
  final _buttonController = TextEditingController();
  String _category = 'MARKETING';
  final List<String> _buttons = ['Track Order'];
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _headerController.dispose();
    _bodyController.dispose();
    _footerController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  List<String> get _detectedVariables {
    final exp = RegExp(r'\{\{\d+\}\}');
    final matches = exp.allMatches(_bodyController.text).map((m) => m.group(0)!).toSet().toList();
    matches.sort();
    return matches;
  }

  void _handleAddButton() {
    final text = _buttonController.text.trim();
    if (text.isEmpty) return;
    if (_buttons.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 buttons allowed per Meta template.')),
      );
      return;
    }
    setState(() {
      _buttons.add(text);
      _buttonController.clear();
    });
  }

  void _handleRemoveButton(int index) {
    setState(() {
      _buttons.removeAt(index);
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim().toLowerCase().replaceAll(' ', '_');

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 350));

    final template = Template(
      id: '',
      name: name,
      category: _category,
      headerType: _headerController.text.trim().isNotEmpty ? 'TEXT' : null,
      headerText: _headerController.text.trim().isNotEmpty ? _headerController.text.trim() : null,
      body: _bodyController.text.trim(),
      footer: _footerController.text.trim().isNotEmpty ? _footerController.text.trim() : null,
      buttons: _buttons,
      status: TemplateStatus.draft,
      updatedAt: DateTime.now(),
    );

    widget.onSave(template);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final variables = _detectedVariables;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Live Bubble Preview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live WhatsApp Preview',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.g100,
                  borderRadius: AppRadii.borderFull,
                ),
                child: Text(
                  _category,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.g800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEAE2),
              borderRadius: AppRadii.border2xl,
              border: Border.all(color: const Color(0xFFDDD6CE)),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadii.borderXl,
                boxShadow: const [
                  BoxShadow(color: Color(0x10000000), blurRadius: 4, offset: Offset(0, 1)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_headerController.text.trim().isNotEmpty) ...[
                    Text(
                      _headerController.text.trim(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    _bodyController.text.trim().isEmpty
                        ? 'Message body preview will appear here...'
                        : _bodyController.text.trim(),
                    style: const TextStyle(fontSize: 14, height: 1.35, color: AppColors.textPrimary),
                  ),
                  if (_footerController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _footerController.text.trim(),
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                    ),
                  ],
                  if (_buttons.isNotEmpty) ...[
                    const Divider(height: 16),
                    ..._buttons.map((b) => Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0x3322C55E)),
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.g50.withOpacity(0.5),
                          ),
                          child: Text(
                            b,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.g700,
                            ),
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Template Name Field
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Template Name *',
              hintText: 'e.g. order_delivery_update',
              helperText: _nameController.text.trim().isEmpty
                  ? 'Use lowercase and underscores only'
                  : 'Slug: ${_nameController.text.trim().toLowerCase().replaceAll(' ', '_')}',
              prefixIcon: const Icon(AppIcons.edit, size: 18),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a template name';
              }
              if (value.trim().length < 3) {
                return 'Template name must be at least 3 characters';
              }
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Category Selector
          const Text(
            'Template Category *',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['MARKETING', 'UTILITY', 'AUTHENTICATION'].map((cat) {
              final isSelected = _category == cat;
              return ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                selectedColor: AppColors.g100,
                labelStyle: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.g800 : AppColors.textSecondary,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.g600 : AppColors.glassBorderLight,
                  width: isSelected ? 1.4 : 1,
                ),
                onSelected: (_) => setState(() => _category = cat),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Header (Optional)
          TextFormField(
            controller: _headerController,
            decoration: const InputDecoration(
              labelText: 'Header Text (Optional)',
              hintText: 'e.g. Special Offer or Order Update',
              prefixIcon: Icon(AppIcons.templates, size: 18),
            ),
            maxLength: 60,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),

          // Body Text Field
          TextFormField(
            controller: _bodyController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Message Body *',
              hintText: 'Enter text. Use {{1}}, {{2}} for dynamic variables',
              alignLabelWithHint: true,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Message body cannot be empty';
              }
              if (value.trim().length < 10) {
                return 'Message body is too short (min 10 characters)';
              }
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),
          if (variables.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Detected variables: ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(width: 4),
                ...variables.map((v) => Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.g100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.g300),
                      ),
                      child: Text(
                        v,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.g800),
                      ),
                    )),
              ],
            ),
          ],
          const SizedBox(height: 16),

          // Footer Text Field
          TextFormField(
            controller: _footerController,
            decoration: const InputDecoration(
              labelText: 'Footer Text (Optional)',
              hintText: 'e.g. Reply STOP to opt out',
              prefixIcon: Icon(AppIcons.info, size: 18),
            ),
            maxLength: 60,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),

          // Action Buttons Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Quick Reply Buttons (Max 3)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppColors.textPrimary),
              ),
              Text(
                '${_buttons.length}/3',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _buttonController,
                  decoration: const InputDecoration(
                    hintText: 'Button label...',
                    isDense: true,
                  ),
                  onSubmitted: (_) => _handleAddButton(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _buttons.length < 3 ? _handleAddButton : null,
                icon: const Icon(AppIcons.add, size: 16),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ],
          ),
          if (_buttons.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: List.generate(_buttons.length, (index) {
                final btnText = _buttons[index];
                return Chip(
                  label: Text(btnText, style: const TextStyle(fontSize: 12)),
                  backgroundColor: AppColors.g50,
                  deleteIcon: const Icon(AppIcons.close, size: 15),
                  onDeleted: () => _handleRemoveButton(index),
                );
              }),
            ),
          ],
          const SizedBox(height: 28),

          // Submit Button with Loading State
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _handleSubmit,
              child: _isSaving
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                        ),
                        SizedBox(width: 12),
                        Text('Saving Template...'),
                      ],
                    )
                  : const Text('Save Template as Draft'),
            ),
          ),
        ],
      ),
    );
  }
}
