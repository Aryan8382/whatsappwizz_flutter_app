import 'package:flutter/material.dart';
import '../../../core/services/repositories/dnd_api_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/animated_entrance.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_list.dart';
import 'widgets/add_dnd_sheet.dart';


class DndScreen extends StatefulWidget {
  const DndScreen({super.key});

  @override
  State<DndScreen> createState() => _DndScreenState();
}

class _DndScreenState extends State<DndScreen> {
  final _repo = DndApiRepository();
  bool _isLoading = false;
  final List<Map<String, String>> _dndList = [];

  @override
  void initState() {
    super.initState();
    _loadDnd();
  }

  Future<void> _loadDnd() async {
    setState(() => _isLoading = true);
    try {
      final list = await _repo.getEntries();
      if (list.isNotEmpty) {
        _dndList.clear();
        for (final item in list) {
          final dt = DateTime.tryParse(item['createdAt']?.toString() ?? '') ?? DateTime.now();
          final diff = DateTime.now().difference(dt);
          final dateStr = diff.inDays > 0 ? '${diff.inDays}d ago' : '${diff.inHours}h ago';

          _dndList.add({
            'id': item['id']?.toString() ?? '',
            'phone': item['number']?.toString() ?? '',
            'reason': item['message']?.toString() ?? 'Opt-out',
            'date': dateStr,
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Do Not Disturb (DND)'),
      ),
      body: _isLoading
          ? Center(child: SkeletonList(count: 4, itemHeight: 70))
          : _dndList.isEmpty
              ? EmptyState(
                  icon: AppIcons.dnd,
                  title: 'No blocked contacts',
                  message: 'Numbers in DND will be suppressed from receiving mass campaigns and automated messages',
                )

              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  itemCount: _dndList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = _dndList[index];
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
                              decoration: const BoxDecoration(
                                color: AppColors.statusRedBg,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.ban, size: 20, color: AppColors.statusRedText),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('+${item['phone']}', style: AppTypography.titleMedium.copyWith(fontSize: 14.5)),
                                  Text(item['reason']!, style: AppTypography.bodySmall),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.trash2, color: AppColors.statusRedText, size: 18),
                              onPressed: () async {
                                final ok = await ConfirmDialog.show(
                                  context: context,
                                  title: 'Remove from DND',
                                  message: 'Allow WhatsApp messaging to +${item['phone']} again?',
                                  confirmLabel: 'Remove',
                                );
                                if (ok == true) {
                                  try {
                                    await _repo.removeEntry(item['id']);
                                    ToastService.success('Removed from DND list');
                                    _loadDnd();
                                  } catch (e) {
                                    ToastService.error('Failed to remove: $e');
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
          icon: const Icon(LucideIcons.phoneOff, size: 20),
          label: const Text('Add to DND', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            AddDndSheet.show(
              context,
              onSave: (data) async {
                try {
                  await _repo.addEntry(data['number'], data['message']);
                  ToastService.success('Added to DND list');
                  _loadDnd();
                } catch (e) {
                  ToastService.error('Failed to add to DND: $e');
                }
              },
            );
          },
        ),
      ),
    );
  }
}

