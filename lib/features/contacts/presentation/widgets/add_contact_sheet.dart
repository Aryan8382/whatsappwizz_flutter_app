import 'package:flutter/material.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/modal_sheet.dart';
import '../../domain/contact.dart';

class AddContactSheet extends StatefulWidget {
  final ValueChanged<Contact> onSave;
  final List<String> availableTags;
  final Contact? initialContact;

  const AddContactSheet({
    super.key,
    required this.onSave,
    required this.availableTags,
    this.initialContact,
  });

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<Contact> onSave,
    required List<String> availableTags,
    Contact? initialContact,
  }) {
    return ModalSheet.show(
      context: context,
      title: initialContact != null ? 'Edit Contact' : 'New Contact',
      subtitle: 'Add customer details to WhatsApp directory',
      child: AddContactSheet(
        onSave: onSave,
        availableTags: availableTags,
        initialContact: initialContact,
      ),
    );
  }

  @override
  State<AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<AddContactSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstController;
  late final TextEditingController _lastController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _countryController;
  late final TextEditingController _sourceController;
  late bool _optIn;
  final List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    final c = widget.initialContact;
    _firstController = TextEditingController(text: c?.firstName ?? '');
    _lastController = TextEditingController(text: c?.lastName ?? '');
    _mobileController = TextEditingController(text: c?.mobile ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _cityController = TextEditingController(text: c?.city ?? '');
    _stateController = TextEditingController(text: c?.state ?? '');
    _countryController = TextEditingController(text: c?.country ?? '');
    _sourceController = TextEditingController(text: c?.source ?? '');
    _optIn = c?.optIn ?? true;
    if (c != null) {
      _selectedTags.addAll(c.tags);
    }
  }

  @override
  void dispose() {
    _firstController.dispose();
    _lastController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final contact = Contact(
      id: widget.initialContact?.id ?? '',
      firstName: _firstController.text.trim(),
      lastName: _lastController.text.trim(),
      mobile: _mobileController.text.trim(),
      email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
      state: _stateController.text.trim().isNotEmpty ? _stateController.text.trim() : null,
      country: _countryController.text.trim().isNotEmpty ? _countryController.text.trim() : null,
      source: _sourceController.text.trim().isNotEmpty ? _sourceController.text.trim() : 'manual',
      optIn: _optIn,
      tags: _selectedTags,
      createdAt: widget.initialContact?.createdAt ?? DateTime.now(),
    );

    widget.onSave(contact);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstController,
                  decoration: const InputDecoration(labelText: 'First Name *'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _lastController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Mobile Number *',
              hintText: 'e.g. 919876543210',
              prefixIcon: Icon(LucideIcons.phone, size: 18),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Phone number required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address (Optional)',
              prefixIcon: Icon(LucideIcons.mail, size: 18),
            ),
          ),
          const SizedBox(height: 14),

          // City + State row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(labelText: 'State'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _countryController,
            decoration: const InputDecoration(
              labelText: 'Country',
              prefixIcon: Icon(LucideIcons.globe, size: 18),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _sourceController.text.isEmpty ? null : _sourceController.text,
            decoration: const InputDecoration(labelText: 'Source (Optional)'),
            items: const [
              DropdownMenuItem(value: null, child: Text('— None —')),
              DropdownMenuItem(value: 'manual', child: Text('Manual')),
              DropdownMenuItem(value: 'import', child: Text('CSV Import')),
              DropdownMenuItem(value: 'api', child: Text('API')),
              DropdownMenuItem(value: 'webhook', child: Text('Webhook')),
              DropdownMenuItem(value: 'chatbot', child: Text('Chatbot')),
              DropdownMenuItem(value: 'flow', child: Text('WhatsApp Flow')),
            ],
            onChanged: (v) => setState(() => _sourceController.text = v ?? ''),
          ),
          const SizedBox(height: 14),

          // WhatsApp Opt-In Switch
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('WhatsApp Opt-In Verified', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
            subtitle: const Text('Customer has given explicit consent to receive messages', style: TextStyle(fontSize: 11)),
            value: _optIn,
            activeColor: AppColors.g600,
            onChanged: (val) => setState(() => _optIn = val),
          ),
          const SizedBox(height: 14),

          // Tags Selection
          const Text('Tags', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.availableTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                selectedColor: AppColors.g100,
                checkmarkColor: AppColors.g800,
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: isSelected ? AppColors.g800 : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _handleSubmit,
            child: Text(widget.initialContact != null ? 'Update Contact' : 'Create Contact'),
          ),
        ],
      ),
    );
  }
}
