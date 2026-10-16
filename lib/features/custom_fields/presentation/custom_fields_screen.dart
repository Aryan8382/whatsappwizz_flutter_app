import 'package:flutter/material.dart';
import '../../../core/services/repositories/custom_fields_api_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/animated_entrance.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_list.dart';
import '../domain/custom_field.dart';
import 'widgets/add_custom_field_sheet.dart';

class CustomFieldsScreen extends StatefulWidget {
  const CustomFieldsScreen({super.key});

  @override
  State<CustomFieldsScreen> createState() => _CustomFieldsScreenState();
}

class _CustomFieldsScreenState extends State<CustomFieldsScreen> {
  final _repo = CustomFieldsApiRepository();
  bool _isLoading = false;
  final List<CustomField> _fields = [];

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  Future<void> _loadFields() async {
    setState(() => _isLoading = true);
    try {
      final list = await _repo.getFields();
      _fields.clear();
      _fields.addAll(list);
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Custom Fields'),
      ),
      body: _isLoading
          ? Center(child: SkeletonList(count: 4, itemHeight: 70))
          : _fields.isEmpty
              ? EmptyState(
                  icon: AppIcons.customFields,
                  title: 'No custom fields',

                  message: 'Create variables to personalize templates, chatbots, and contact records',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  itemCount: _fields.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final f = _fields[index];
                    return FadeSlideIn.staggered(
                      index: index,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppRadii.border2xl,
                          border: Border.all(color: const Color(0x3322C55E)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.g50,
                                borderRadius: AppRadii.borderMd,
                              ),
                              child: const Icon(AppIcons.customFields, size: 20, color: AppColors.g700),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(f.name, style: AppTypography.titleMedium.copyWith(fontSize: 14.5)),
                                  const SizedBox(height: 2),
                                  Text('Variable: {{${f.key}}} · Type: ${f.type}', style: AppTypography.bodySmall),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.g100,
                                borderRadius: AppRadii.borderSm,
                              ),
                              child: Text(
                                f.type,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.g800),
                              ),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.statusRedText),
                              tooltip: 'Delete Field',
                              onPressed: () async {
                                final ok = await ConfirmDialog.show(
                                  context: context,
                                  title: 'Delete Custom Field',
                                  message: 'Are you sure you want to delete "${f.name}"?',
                                  confirmLabel: 'Delete',
                                );
                                if (ok == true) {
                                  try {
                                    await _repo.deleteField(f.id);
                                    ToastService.success('Custom field deleted');
                                    _loadFields();
                                  } catch (e) {
                                    ToastService.error('Failed to delete: $e');
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 76),
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.g600,
          foregroundColor: Colors.white,
          icon: const Icon(AppIcons.add, size: 20),
          label: const Text('Add Field', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            AddCustomFieldSheet.show(
              context,
              onSave: (data) async {
                try {
                  await _repo.createField({
                    'name': data['name'],
                    'fieldType': data['field_type'] ?? 'TEXT',
                  });
                  ToastService.success('Custom field created successfully');
                  _loadFields();
                } catch (e) {
                  ToastService.error('Failed to create field: $e');
                }
              },
            );
          },
        ),
      ),
    );
  }
}

