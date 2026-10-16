import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/animated_entrance.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_search_bar.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/filter_chips.dart';
import '../../../shared/widgets/skeleton_list.dart';
import '../../../core/services/repositories/contacts_api_repository.dart';
import '../domain/contact.dart';
import '../domain/contacts_repository.dart';
import 'widgets/add_contact_sheet.dart';
import 'widgets/contact_detail_sheet.dart';
import 'widgets/create_segment_sheet.dart';
import 'widgets/tag_manager_sheet.dart';

final contactsRepositoryProvider = Provider<ContactsRepository>((ref) {
  return ContactsApiRepository();
});

class ContactsState {
  final List<Contact> contacts;
  final List<String> tags;
  final bool isLoading;
  final String? error;

  const ContactsState({
    this.contacts = const [],
    this.tags = const [],
    this.isLoading = false,
    this.error,
  });

  ContactsState copyWith({
    List<Contact>? contacts,
    List<String>? tags,
    bool? isLoading,
    String? error,
  }) {
    return ContactsState(
      contacts: contacts ?? this.contacts,
      tags: tags ?? this.tags,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ContactsNotifier extends StateNotifier<ContactsState> {
  final ContactsRepository _repo;

  ContactsNotifier(this._repo) : super(const ContactsState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final contacts = await _repo.getContacts();
      final tags = await _repo.getAllTags();
      state = state.copyWith(contacts: contacts, tags: tags, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addContact(Contact contact) async {
    final created = await _repo.createContact(contact);
    state = state.copyWith(contacts: [created, ...state.contacts]);
  }

  Future<void> deleteContact(String id) async {
    await _repo.deleteContact(id);
    state = state.copyWith(contacts: state.contacts.where((c) => c.id != id).toList());
  }

  Future<void> addTag(String tag) async {
    await _repo.createTag(tag);
    state = state.copyWith(tags: [...state.tags, tag]);
  }

  Future<void> createSegment(String name, String tagFilter, bool optInOnly) async {
    await _repo.createSegment(name: name, tagFilter: tagFilter, optInOnly: optInOnly);
  }
}

final contactsControllerProvider =
    StateNotifierProvider<ContactsNotifier, ContactsState>((ref) {
  final repo = ref.watch(contactsRepositoryProvider);
  return ContactsNotifier(repo);
});

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedTag;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactsState = ref.watch(contactsControllerProvider);
    final notifier = ref.read(contactsControllerProvider.notifier);

    var filtered = contactsState.contacts;
    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      filtered = filtered.where((c) {
        return c.fullName.toLowerCase().contains(q) ||
            c.mobile.contains(q) ||
            (c.email?.toLowerCase().contains(q) ?? false);
      }).toList();
    }
    if (_selectedTag != null && _selectedTag!.isNotEmpty) {
      filtered = filtered.where((c) => c.tags.contains(_selectedTag)).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Header with Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contacts', style: AppTypography.displayMedium),
                      Text(
                        '${contactsState.contacts.length} total subscribers',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                // CSV Import button
                IconButton(
                  icon: const Icon(LucideIcons.upload, size: 20),
                  tooltip: 'Import CSV',
                  onPressed: () {
                    ToastService.success('CSV import wizard opened');
                  },
                ),
                // CSV Export button
                IconButton(
                  icon: const Icon(LucideIcons.download, size: 20),
                  tooltip: 'Export CSV',
                  onPressed: () {
                    ToastService.info('Exporting contacts to CSV file...');
                  },
                ),
                // Build Segment button
                IconButton(
                  icon: const Icon(LucideIcons.pieChart, size: 20),
                  tooltip: 'Build Segment',
                  onPressed: () {
                    CreateSegmentSheet.show(
                      context,
                      allContacts: contactsState.contacts,
                      availableTags: contactsState.tags,
                      onSave: (name, tag, optIn, filters) {
                        notifier.createSegment(name, tag, optIn);
                        ToastService.success('Audience segment "$name" created');
                      },
                    );
                  },
                ),
                // Tag Manager button
                IconButton(
                  icon: const Icon(LucideIcons.tag, size: 20),
                  tooltip: 'Tag Manager',
                  onPressed: () {
                    TagManagerSheet.show(
                      context,
                      tags: contactsState.tags,
                      onAddTag: (t, c) {
                        notifier.addTag(t);
                        ToastService.success('Tag #$t created');
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Search contacts by name, mobile, email...',
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Tag Filters
          FilterChips<String?>(
            items: [null, ...contactsState.tags],
            selectedItem: _selectedTag,
            onSelected: (t) => setState(() => _selectedTag = t),
            labelBuilder: (t) => t == null ? 'All Tags' : '#$t',
          ),

          const Divider(height: 1, color: Color(0x1F22C55E)),

          // Contacts List
          Expanded(
            child: contactsState.isLoading && contactsState.contacts.isEmpty
                ? const SkeletonList(count: 6, itemHeight: 74)
                : RefreshIndicator(
                    color: AppColors.g600,
                    onRefresh: () => notifier.load(),
                    child: filtered.isEmpty
                        ? const EmptyState(
                            icon: LucideIcons.users,
                            title: 'No contacts found',
                            message: 'Add a new contact or try different search filters',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const Divider(
                              height: 1,
                              indent: 72,
                              color: Color(0x0F22C55E),
                            ),
                            itemBuilder: (context, index) {
                              final contact = filtered[index];
                              return FadeSlideIn.staggered(
                                index: index,
                                child: ListTile(
                                onTap: () {
                                  ContactDetailSheet.show(
                                    context,
                                    contact: contact,
                                    onEdit: () {
                                      AddContactSheet.show(
                                        context,
                                        availableTags: contactsState.tags,
                                        initialContact: contact,
                                        onSave: (updated) {
                                          notifier.addContact(updated);
                                          ToastService.success('Contact updated');
                                        },
                                      );
                                    },
                                  );
                                },
                                leading: AppAvatar(name: contact.fullName, radius: 20),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        contact.fullName,
                                        style: AppTypography.titleMedium.copyWith(fontSize: 14.5),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (contact.optIn)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.statusGreenBg,
                                          borderRadius: AppRadii.borderFull,
                                        ),
                                        child: const Text(
                                          'Opted In',
                                          style: TextStyle(
                                            color: AppColors.statusGreenText,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2),
                                    Text('+${contact.mobile}', style: AppTypography.bodySmall),
                                    if (contact.tags.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 4,
                                        children: contact.tags.map((t) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                            decoration: BoxDecoration(
                                              color: AppColors.g50,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: AppColors.g200),
                                            ),
                                            child: Text(
                                              t,
                                              style: const TextStyle(fontSize: 9.5, color: AppColors.g800),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  shape: RoundedRectangleBorder(borderRadius: AppRadii.borderXl),
                                  icon: const Icon(AppIcons.moreVertical, size: 18, color: AppColors.textMuted),
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(LucideIcons.edit2, size: 16),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(LucideIcons.trash2, size: 16, color: AppColors.statusRedText),
                                          SizedBox(width: 8),
                                          Text('Delete', style: TextStyle(color: AppColors.statusRedText)),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (val) async {
                                    if (val == 'edit') {
                                      AddContactSheet.show(
                                        context,
                                        availableTags: contactsState.tags,
                                        initialContact: contact,
                                        onSave: (updated) {
                                          notifier.addContact(updated);
                                          ToastService.success('Contact updated');
                                        },
                                      );
                                    } else if (val == 'delete') {
                                      final ok = await ConfirmDialog.show(
                                        context: context,
                                        title: 'Delete Contact',
                                        message: 'Are you sure you want to delete ${contact.fullName}?',
                                        confirmLabel: 'Delete',
                                        isDestructive: true,
                                      );
                                      if (ok == true) {
                                        notifier.deleteContact(contact.id);
                                        ToastService.success('Contact deleted');
                                      }
                                    }
                                  },
                                ),
                              ), // end ListTile
                              ); // end FadeSlideIn.staggered
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 76),
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.g600,
          foregroundColor: Colors.white,
          icon: const Icon(LucideIcons.userPlus, size: 20),
          label: const Text('Add Contact', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            AddContactSheet.show(
              context,
              availableTags: contactsState.tags,
              onSave: (contact) {
                notifier.addContact(contact);
                ToastService.success('Contact created');
              },
            );
          },
        ),
      ),
    );
  }
}
