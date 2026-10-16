import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/widgets/modal_sheet.dart';
import '../../domain/campaign.dart';

class CampaignWizardSheet extends StatefulWidget {
  final ValueChanged<Campaign> onLaunch;

  const CampaignWizardSheet({super.key, required this.onLaunch});

  static Future<void> show(BuildContext context, {required ValueChanged<Campaign> onLaunch}) {
    return ModalSheet.show(
      context: context,
      title: 'New WhatsApp Broadcast',
      subtitle: 'Schedule or send mass campaign to your audience',
      child: CampaignWizardSheet(onLaunch: onLaunch),
    );
  }

  @override
  State<CampaignWizardSheet> createState() => _CampaignWizardSheetState();
}

class _CampaignWizardSheetState extends State<CampaignWizardSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  List<Map<String, dynamic>> _templates = [];
  List<Map<String, dynamic>> _segments = [];
  bool _isLoadingData = true;

  dynamic _selectedTemplateId;
  String _selectedTemplateName = '';
  dynamic _selectedSegmentId;
  String _selectedAudience = 'All Contacts';
  int _estimatedRecipients = 50;
  bool _isLaunching = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final tplRes = await ApiService.instance.get<dynamic>('/templates');
      final segRes = await ApiService.instance.get<dynamic>('/segments');
      final tplList = tplRes is List ? tplRes : (tplRes as Map?)?['items'] ?? [];
      final segList = segRes is List ? segRes : (segRes as Map?)?['items'] ?? [];
      if (mounted) {
        setState(() {
          _templates = (tplList as List).map((x) => Map<String, dynamic>.from(x as Map)).toList();
          _segments = (segList as List).map((x) => Map<String, dynamic>.from(x as Map)).toList();
          if (_templates.isNotEmpty) {
            _selectedTemplateId = _templates.first['id'];
            _selectedTemplateName = (_templates.first['name'] ?? '').toString();
            _nameController.text = 'Broadcast ${_templates.first['name']}';
          }
          if (_segments.isNotEmpty) {
            _selectedSegmentId = _segments.first['id'];
            _selectedAudience = 'Segment: ${_segments.first['name']}';
          }
          _isLoadingData = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleLaunch() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTemplateId == null && _templates.isNotEmpty) {
      _selectedTemplateId = _templates.first['id'];
      _selectedTemplateName = (_templates.first['name'] ?? '').toString();
    }
    final name = _nameController.text.trim();

    setState(() => _isLaunching = true);

    final campaign = Campaign(
      id: '',
      templateId: _selectedTemplateId,
      name: name,
      templateName: _selectedTemplateName,
      audience: _selectedSegmentId != null ? {'segmentIds': [_selectedSegmentId]} : null,
      audienceSource: _selectedAudience,
      status: CampaignStatus.running,
      totalRecipients: _estimatedRecipients,
      sentCount: 0,
      createdAt: DateTime.now(),
    );

    widget.onLaunch(campaign);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final estimatedCost = _estimatedRecipients * 0.78; // Marketing rate

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Budget & Wallet Estimate Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.g50,
              borderRadius: AppRadii.border2xl,
              border: Border.all(color: AppColors.g300),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(AppIcons.wallet, color: AppColors.g700, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated Meta Cost: ₹${estimatedCost.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: AppColors.g950),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$_estimatedRecipients contacts · ₹0.78/msg marketing tier',
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadii.borderMd,
                    border: Border.all(color: const Color(0x3322C55E)),
                  ),
                  child: const Row(
                    children: [
                      Icon(AppIcons.checkCircle, size: 15, color: AppColors.g600),
                      SizedBox(width: 6),
                      Text(
                        'Wallet Balance Sufficient: ₹5,000 available',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.g800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Campaign Name
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Campaign Name *',
              hintText: 'e.g. End of Season Sale',
              prefixIcon: Icon(AppIcons.broadcasts, size: 18),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a campaign name';
              }
              if (value.trim().length < 3) {
                return 'Campaign name must be at least 3 characters';
              }
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),

          // Template Selector
          const Text(
            'Approved Template *',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          _isLoadingData
              ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2)))
              : DropdownButtonFormField<dynamic>(
                  value: _selectedTemplateId,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    prefixIcon: Icon(AppIcons.templates, size: 18),
                  ),
                  items: _templates.map((tpl) {
                    final id = tpl['id'];
                    final name = tpl['name'] ?? '';
                    final cat = tpl['category'] ?? '';
                    return DropdownMenuItem<dynamic>(
                      value: id,
                      child: Text('$name ($cat)', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final found = _templates.firstWhere((t) => t['id'] == val, orElse: () => {});
                      setState(() {
                        _selectedTemplateId = val;
                        _selectedTemplateName = (found['name'] ?? '').toString();
                        if (_nameController.text.startsWith('Broadcast ') || _nameController.text.isEmpty) {
                          _nameController.text = 'Broadcast $_selectedTemplateName';
                        }
                      });
                    }
                  },
                ),
          const SizedBox(height: 18),

          // Audience Selector
          const Text(
            'Target Audience *',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<dynamic>(
            value: _selectedSegmentId,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              prefixIcon: Icon(AppIcons.contacts, size: 18),
            ),
            items: [
              const DropdownMenuItem<dynamic>(
                value: null,
                child: Text('All Contacts'),
              ),
              ..._segments.map((seg) {
                return DropdownMenuItem<dynamic>(
                  value: seg['id'],
                  child: Text('Segment: ${seg['name'] ?? 'Custom'}'),
                );
              }),
            ],
            onChanged: (val) {
              setState(() {
                _selectedSegmentId = val;
                if (val == null) {
                  _selectedAudience = 'All Contacts';
                  _estimatedRecipients = 50;
                } else {
                  final s = _segments.firstWhere((x) => x['id'] == val, orElse: () => {});
                  _selectedAudience = 'Segment: ${s['name'] ?? 'Custom'}';
                  _estimatedRecipients = int.tryParse(s['contactCount']?.toString() ?? '50') ?? 50;
                }
              });
            },
          ),
          const SizedBox(height: 28),

          // Submit Button with Loading Feedback
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isLaunching ? null : _handleLaunch,
              child: _isLaunching
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                        ),
                        SizedBox(width: 12),
                        Text('Launching Broadcast Campaign...'),
                      ],
                    )
                  : const Text('Launch Broadcast Campaign'),
            ),
          ),
        ],
      ),
    );
  }
}
