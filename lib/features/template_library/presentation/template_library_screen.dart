import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/repositories/template_library_api_repository.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/animated_entrance.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/filter_chips.dart';
import '../../../shared/widgets/skeleton_list.dart';
import '../../templates/domain/template.dart';
import '../../templates/presentation/templates_screen.dart';

final templateLibraryRepoProvider = Provider<TemplateLibraryApiRepository>((ref) {
  return TemplateLibraryApiRepository();
});

final templateLibraryProvider =
    FutureProvider.family.autoDispose<List<LibraryTemplateModel>, String?>((ref, category) async {
  final repo = ref.watch(templateLibraryRepoProvider);
  return repo.getTemplates(type: category);
});

class TemplateLibraryScreen extends ConsumerStatefulWidget {
  const TemplateLibraryScreen({super.key});

  @override
  ConsumerState<TemplateLibraryScreen> createState() => _TemplateLibraryScreenState();
}

class _TemplateLibraryScreenState extends ConsumerState<TemplateLibraryScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(templateLibraryProvider(_selectedCategory));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Template Library'),
      ),
      body: Column(
        children: [
          // Filter Chips
          FilterChips<String?>(
            items: const [null, 'UTILITY', 'AUTHENTICATION'],
            selectedItem: _selectedCategory,
            onSelected: (cat) => setState(() => _selectedCategory = cat),
            labelBuilder: (cat) => cat ?? 'All Templates',
          ),
          const Divider(height: 1, color: Color(0x1F22C55E)),

          // Template Cards from live API
          Expanded(
            child: templatesAsync.when(
              loading: () => const Center(child: SkeletonList(count: 4, itemHeight: 120)),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.alertCircle, color: AppColors.statusRedText, size: 36),
                      const SizedBox(height: 12),
                      Text('Error loading library: $err', textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(templateLibraryProvider(_selectedCategory)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (templates) {
                if (templates.isEmpty) {
                  return const EmptyState(
                    icon: AppIcons.templates,
                    title: 'No templates found',
                    message: 'Try changing your category filter',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  itemCount: templates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = templates[index];
                    return FadeSlideIn.staggered(
                      index: index,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppRadii.border2xl,
                          border: Border.all(color: const Color(0x3322C55E)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: AppTypography.titleMedium.copyWith(fontSize: 14.5),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.g100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.type,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.g800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (item.header != null && item.header!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                item.header!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              item.body,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                            if (item.footer != null && item.footer!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                item.footer!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.buttonLabel != null && item.buttonLabel!.isNotEmpty
                                      ? 'Button: ${item.buttonLabel}'
                                      : 'Language: ${item.language}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final repo = ref.read(templatesRepositoryProvider);
                                    await repo.createTemplate(
                                      Template(
                                        id: '',
                                        name: item.name
                                            .toLowerCase()
                                            .replaceAll(RegExp(r'[^a-z0-9_]'), '_'),
                                        category: item.type,
                                        body: item.body,
                                        buttons: item.buttonLabel != null && item.buttonLabel!.isNotEmpty
                                            ? [item.buttonLabel!]
                                            : const [],
                                        status: TemplateStatus.draft,
                                        updatedAt: DateTime.now(),
                                      ),
                                    );
                                    ref.invalidate(templatesProvider);
                                    ToastService.success('Copied to your templates as draft');
                                  },
                                  icon: const Icon(LucideIcons.copy, size: 14),
                                  label: const Text('Use Template', style: TextStyle(fontSize: 12)),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
