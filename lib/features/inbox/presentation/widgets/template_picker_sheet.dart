import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/widgets/modal_sheet.dart';

class TemplateOption {
  final String id;
  final String name;
  final String category;
  final String body;
  final String? header;
  final String? footer;
  final String status;

  const TemplateOption({
    required this.id,
    required this.name,
    required this.category,
    required this.body,
    this.header,
    this.footer,
    this.status = 'approved',
  });
}

class TemplatePickerSheet extends StatefulWidget {
  final ValueChanged<TemplateOption> onSelect;

  const TemplatePickerSheet({super.key, required this.onSelect});

  static Future<TemplateOption?> show(BuildContext context) {
    return ModalSheet.show<TemplateOption>(
      context: context,
      title: 'Select Meta Template',
      subtitle: 'Required to reopen messaging window after 24 hours',
      child: TemplatePickerSheet(
        onSelect: (tpl) => Navigator.of(context).pop(tpl),
      ),
    );
  }

  @override
  State<TemplatePickerSheet> createState() => _TemplatePickerSheetState();
}

class _TemplatePickerSheetState extends State<TemplatePickerSheet> {
  List<TemplateOption> _allTemplates = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'ALL';

  @override
  void initState() {
    super.initState();
    _fetchRealTemplates();
  }

  Future<void> _fetchRealTemplates() async {
    try {
      final res = await ApiService.instance.get<dynamic>('/templates');
      final list = res is List ? res : (res as Map?)?['items'] ?? [];
      final parsed = (list as List).map((j) {
        final map = Map<String, dynamic>.from(j as Map);
        return TemplateOption(
          id: (map['id'] ?? '').toString(),
          name: (map['name'] ?? '').toString(),
          category: (map['category'] ?? 'UTILITY').toString().toUpperCase(),
          body: (map['body'] ?? '').toString(),
          header: map['header']?.toString(),
          footer: map['footer']?.toString(),
          status: (map['status'] ?? 'approved').toString(),
        );
      }).toList();

      if (mounted) {
        setState(() {
          _allTemplates = parsed;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<TemplateOption> get _filteredTemplates {
    return _allTemplates.where((tpl) {
      final matchesCat = _selectedCategory == 'ALL' || tpl.category == _selectedCategory;
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          tpl.name.toLowerCase().contains(q) ||
          tpl.body.toLowerCase().contains(q);
      return matchesCat && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.g600),
              SizedBox(height: 12),
              Text(
                'Loading live Meta templates...',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    final templates = _filteredTemplates;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search Bar
        TextField(
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: 'Search templates by name or text...',
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            prefixIcon: const Icon(AppIcons.search, size: 18, color: AppColors.textMuted),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: AppRadii.borderLg,
              borderSide: const BorderSide(color: Color(0x3322C55E)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadii.borderLg,
              borderSide: const BorderSide(color: Color(0x22000000)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadii.borderLg,
              borderSide: const BorderSide(color: AppColors.g600, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['ALL', 'MARKETING', 'UTILITY', 'AUTHENTICATION'].map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(
                    cat == 'ALL' ? 'All (${_allTemplates.length})' : cat,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.g600,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),

        // Templates List
        if (templates.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: const Text(
              'No matching approved templates found.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          )
        else
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.55,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: templates.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final tpl = templates[index];
                final isUtility = tpl.category == 'UTILITY';

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadii.borderXl,
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
                              tpl.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isUtility ? AppColors.statusBlueBg : AppColors.statusGreenBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tpl.category,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isUtility ? AppColors.statusBlueText : AppColors.statusGreenText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (tpl.header != null && tpl.header!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          tpl.header!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        tpl.body,
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.3),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () => widget.onSelect(tpl),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.g600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
                          ),
                          child: const Text('Send Template', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
