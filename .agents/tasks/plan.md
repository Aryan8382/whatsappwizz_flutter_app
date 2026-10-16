# Implementation Plan — DB-Backed Forms for All Screens

**Project:** `whatsapp_wiz` (Flutter 3.x / Dart SDK ^3.12.2)  
**Build command:** `flutter build web` (or `flutter run -d chrome` for dev)  
**Verify command:** `flutter analyze` — zero errors expected after each item  

---

## Gold-standard patterns (READ THESE, never modify them)

| File | What it teaches |
|---|---|
| `lib/features/contacts/presentation/contacts_screen.dart` | FAB wiring pattern, notifier structure |
| `lib/features/contacts/presentation/widgets/add_contact_sheet.dart` | Sheet class skeleton: `StatefulWidget`, `static Future<void> show(…)`, `ModalSheet.show(…)`, `Form` + `GlobalKey<FormState>`, `_handleSubmit()` pops after saving |
| `lib/shared/widgets/modal_sheet.dart` | `ModalSheet.show()` signature — always pass `context`, `title`, `subtitle`, `child` |
| `lib/features/campaigns/presentation/widgets/campaign_wizard_sheet.dart` | Dropdown pattern, `StatefulBuilder` inside modal, loading state |
| `lib/features/templates/presentation/widgets/template_builder_sheet.dart` | Multi-field form with conditional sections, `ChoiceChip` row for enum fields |

---

## Conventions to follow in every new sheet

1. **File location:** `lib/features/<feature>/presentation/widgets/<name>_sheet.dart`  
2. **Class skeleton:** mirrors `AddContactSheet` exactly — `StatefulWidget`, named constructor, `static Future<void> show(BuildContext context, {required …})` that calls `ModalSheet.show(…)`.  
3. **Imports:** `package:flutter/material.dart`, `../../../../core/theme/app_colors.dart`, `../../../../core/theme/app_icons.dart` (for `LucideIcons`), `../../../../shared/widgets/modal_sheet.dart`. Adjust `../` depth for settings widgets (one extra level).  
4. **Dropdowns:** Use `DropdownButtonFormField<String>` with `InputDecoration` matching the existing sheets.  
5. **Switches:** Use `SwitchListTile(contentPadding: EdgeInsets.zero, activeColor: AppColors.g600, …)`.  
6. **JSON textareas:** `TextFormField(maxLines: 5, decoration: InputDecoration(labelText: '…', alignLabelWithHint: true, hintText: '{"key": "value"}'))`.  
7. **Submit button:** `ElevatedButton` at bottom, calls `widget.onSave(…)` then `Navigator.of(context).pop()`.  
8. **FAB in screen:** `Padding(padding: const EdgeInsets.only(bottom: 76), child: FloatingActionButton.extended(backgroundColor: AppColors.g600, foregroundColor: Colors.white, …))` — matching contacts_screen exactly.  
9. **Do not** add Riverpod providers, domain models, or repository calls — all screens currently hold in-memory state; the sheets just collect data and return it via a callback, same as `AddContactSheet`.

---

## Items

- [ ] 1. **USERS — Create `AddUserSheet`**  
  Create a new sheet widget that covers all `users` table fields: `first_name` + `last_name` (side-by-side row, matching contacts pattern), `email` (email keyboard), `mobile` (phone keyboard), `password_hash` (obscured `TextFormField` with eye-toggle, labelled "Password"), `avatar` (url text, optional), `status` (DropdownButtonFormField with values `active` / `inactive` / `suspended`), `role_id` (DropdownButtonFormField showing "1 — Admin / 2 — Manager / 3 — Agent" — store int value).  
  The `static show()` call title is `'Add Team Member'`, subtitle `'Creates a new users record'`.  
  `onSave` callback signature: `ValueChanged<Map<String, dynamic>>`.  
  Files:  
  - **Create** `lib/features/users/presentation/widgets/add_user_sheet.dart`  
  Verify: `flutter analyze lib/features/users` — no errors.

- [ ] 2. **USERS — Wire FAB in `users_screen.dart`**  
  The screen currently has a FAB that calls `_showInviteSheet()` (an inline `ModalSheet.show` with only email + role). Replace the FAB's `onPressed` to call `AddUserSheet.show(context, onSave: (data) { ToastService.success('User created'); })`. Add the import for `add_user_sheet.dart`. Remove the now-unused `_showInviteSheet()` method.  
  Files:  
  - **Modify** `lib/features/users/presentation/users_screen.dart`  
  Verify: `flutter analyze lib/features/users` — no errors.

- [ ] 3. **TEMPLATES — Create `AddTemplateSheet`**  
  The existing `template_builder_sheet.dart` is a rich live-preview form. The task requires a simpler DB-field form (`add_template_sheet.dart`) as an alternative entry point. Create it with: `name` (text, required), `category` (DropdownButtonFormField: `UTILITY` / `MARKETING` / `AUTHENTICATION`), `language` (DropdownButtonFormField: `en` / `hi` / `ar` / `es` / `fr` / `pt_BR`), `status` (DropdownButtonFormField: `draft` / `pending` / `approved` / `rejected`), `header` (optional text), `body` (required multiline, `maxLines: 4`), `footer` (optional text), `rejection_reason` (read-only `TextFormField` with `enabled: false`, shown only when status == `'rejected'` — wrap in `if (_status == 'rejected') …` block using `setState`).  
  Title: `'New Template'`, subtitle: `'Add WhatsApp message template fields'`.  
  Files:  
  - **Create** `lib/features/templates/presentation/widgets/add_template_sheet.dart`  
  Verify: `flutter analyze lib/features/templates` — no errors.

- [ ] 4. **TEMPLATES — Wire FAB in `templates_screen.dart`**  
  The screen already has a FAB calling `TemplateBuilderSheet.show(…)`. Replace that FAB call with `AddTemplateSheet.show(context, onSave: (data) { ToastService.success('Template draft created'); ref.invalidate(templatesProvider); })`. Add the import for `add_template_sheet.dart`. Keep the existing `TemplateBuilderSheet` import and usage in the empty-state action and list — only the FAB changes.  
  Files:  
  - **Modify** `lib/features/templates/presentation/templates_screen.dart`  
  Verify: `flutter analyze lib/features/templates` — no errors.

- [ ] 5. **CAMPAIGNS — Create `AddCampaignSheet`**  
  The existing `campaign_wizard_sheet.dart` is a full wizard. Create a simpler `add_campaign_sheet.dart` with exact DB fields: `name` (text, required), `template_id` (text field, labelled "Template ID"), `status` (DropdownButtonFormField: `draft` / `running` / `paused` / `completed` / `failed`), `scheduled_at` (use `TextFormField` with `readOnly: true` and `onTap` calling `showDatePicker` + `showTimePicker`, display formatted result in controller, labelled "Scheduled At"), `rate_per_minute` (number keyboard, default `'60'`), `audience` (JSON textarea, `maxLines: 5`).  
  Title: `'New Campaign'`, subtitle: `'Configure broadcast campaign settings'`.  
  `onSave` callback: `ValueChanged<Map<String, dynamic>>`.  
  Files:  
  - **Create** `lib/features/campaigns/presentation/widgets/add_campaign_sheet.dart`  
  Verify: `flutter analyze lib/features/campaigns` — no errors.

- [ ] 6. **CAMPAIGNS — Wire FAB in `campaigns_screen.dart`**  
  The screen header has an `ElevatedButton.icon('New Campaign')` but no FAB. Add a `floatingActionButton` to the `Scaffold` that calls `AddCampaignSheet.show(context, onSave: (data) { ToastService.success('Campaign created'); ref.refresh(campaignsProvider); })`. Keep the existing header button calling `CampaignWizardSheet` unchanged.  
  Files:  
  - **Modify** `lib/features/campaigns/presentation/campaigns_screen.dart`  
  Verify: `flutter analyze lib/features/campaigns` — no errors.

- [ ] 7. **AUTOMATION — Create `AddAutomationSheet`**  
  Create `add_automation_sheet.dart` with: `name` (text, required), `status` (DropdownButtonFormField: `draft` / `active` / `paused` / `archived`), `trigger_type` (DropdownButtonFormField: `new_contact` / `keyword` / `opt_in` / `inbound_message` / `scheduled`), `trigger_config` (JSON textarea, optional), `steps` (JSON textarea, optional).  
  Title: `'New Automation'`, subtitle: `'Create event-driven workflow rule'`.  
  Files:  
  - **Create** `lib/features/automation/presentation/widgets/add_automation_sheet.dart`  
  Verify: `flutter analyze lib/features/automation` — no errors.

- [ ] 8. **AUTOMATION — Wire FAB in `automation_screen.dart`**  
  The screen uses `ConsumerWidget` with no FAB. Add a `floatingActionButton` to the `Scaffold` that calls `AddAutomationSheet.show(context, onSave: (data) { ToastService.success('Automation rule created'); ref.invalidate(automationWorkflowsProvider); })`. Import `add_automation_sheet.dart`.  
  Files:  
  - **Modify** `lib/features/automation/presentation/automation_screen.dart`  
  Verify: `flutter analyze lib/features/automation` — no errors.

- [ ] 9. **CHATBOT — Create `AddBotSheet`**  
  Create `add_bot_sheet.dart` in `lib/features/chatbot/presentation/widgets/`. Fields: `name` (text, required), `published` (`SwitchListTile`, default false), `config` (JSON textarea, optional).  
  Title: `'New Bot Flow'`, subtitle: `'Create a new chatbot flow configuration'`.  
  Files:  
  - **Create** `lib/features/chatbot/presentation/widgets/add_bot_sheet.dart`  
  Verify: `flutter analyze lib/features/chatbot` — no errors.

- [ ] 10. **CHATBOT — Wire FAB in `chatbot_screen.dart`**  
  The flow-list view (`_activeFlow == null` branch) has no FAB. Add a `floatingActionButton` to the list-view `Scaffold` (inside the `if (_activeFlow == null)` branch's `Scaffold`) calling `AddBotSheet.show(context, onSave: (data) { ToastService.success('Bot flow created'); ref.invalidate(chatbotFlowsProvider); })`. Do not add a FAB to the canvas `Scaffold`. Import `add_bot_sheet.dart`.  
  Files:  
  - **Modify** `lib/features/chatbot/presentation/chatbot_screen.dart`  
  Verify: `flutter analyze lib/features/chatbot` — no errors.

- [ ] 11. **CUSTOM FIELDS — Create `AddCustomFieldSheet`**  
  Create `add_custom_field_sheet.dart` in `lib/features/custom_fields/presentation/widgets/`. Fields: `name` (text, required), `field_type` (DropdownButtonFormField: `text` / `number` / `date` / `boolean` / `select`), `default_value` (optional text), `options` (JSON textarea, shown only when `_fieldType == 'select'` — wrap in `AnimatedSwitcher` or plain `if` block), `show_in_listing` (`SwitchListTile`, default true), `status` (`SwitchListTile` labelled "Active", default true), `mandatory` (`SwitchListTile`, default false).  
  Title: `'Add Custom Field'`, subtitle: `'Define contact attribute schema'`.  
  Files:  
  - **Create** `lib/features/custom_fields/presentation/widgets/add_custom_field_sheet.dart`  
  Verify: `flutter analyze lib/features/custom_fields` — no errors.

- [ ] 12. **CUSTOM FIELDS — Wire FAB in `custom_fields_screen.dart`**  
  The FAB already exists but calls `ToastService.info(…)`. Replace `onPressed` to call `AddCustomFieldSheet.show(context, onSave: (data) { setState(() { /* append to _fields */ }); ToastService.success('Custom field created'); })`. Import `add_custom_field_sheet.dart`.  
  Files:  
  - **Modify** `lib/features/custom_fields/presentation/custom_fields_screen.dart`  
  Verify: `flutter analyze lib/features/custom_fields` — no errors.

- [ ] 13. **DND — Create `AddDndSheet`**  
  Create `add_dnd_sheet.dart` in `lib/features/dnd/presentation/widgets/`. Fields: `number` (phone keyboard, required, labelled "Phone Number *", hint "e.g. 919876543210"), `message` (optional text, labelled "Reason / Note").  
  Title: `'Add to DND List'`, subtitle: `'Block this number from receiving messages'`.  
  Files:  
  - **Create** `lib/features/dnd/presentation/widgets/add_dnd_sheet.dart`  
  Verify: `flutter analyze lib/features/dnd` — no errors.

- [ ] 14. **DND — Wire FAB in `dnd_screen.dart`**  
  The FAB exists but calls `ToastService.info(…)`. Replace `onPressed` to call `AddDndSheet.show(context, onSave: (data) { setState(() { _dndList.insert(0, {'phone': data['number'], 'reason': data['message'] ?? '', 'date': 'just now'}); }); ToastService.success('Added to DND list'); })`. Import `add_dnd_sheet.dart`.  
  Files:  
  - **Modify** `lib/features/dnd/presentation/dnd_screen.dart`  
  Verify: `flutter analyze lib/features/dnd` — no errors.

- [ ] 15. **WHATSAPP FLOWS — Create `AddFlowSheet`**  
  Create `lib/features/flows/presentation/widgets/add_flow_sheet.dart`. Fields: `name` (text, required), `category` (DropdownButtonFormField: `SIGN_UP` / `SIGN_IN` / `APPOINTMENT_BOOKING` / `LEAD_GENERATION` / `CONTACT_US` / `CUSTOMER_SUPPORT` / `SURVEY` / `OTHER`), `status` (DropdownButtonFormField: `draft` / `published` / `deprecated` / `blocked`), `health_status` (DropdownButtonFormField: `healthy` / `needs_update` / `blocked`), `screens` (JSON textarea, optional).  
  Title: `'New WhatsApp Flow'`, subtitle: `'Create interactive multi-screen native flow'`.  
  Files:  
  - **Create** `lib/features/flows/presentation/widgets/add_flow_sheet.dart`  
  Verify: `flutter analyze lib/features/flows` — no errors.

- [ ] 16. **WHATSAPP FLOWS — Wire FAB in `flows_screen.dart`**  
  The screen is a `ConsumerWidget` with no FAB. Add `floatingActionButton` to the `Scaffold` calling `AddFlowSheet.show(context, onSave: (data) { ToastService.success('Flow created'); ref.invalidate(flowsProvider); })`. Import `add_flow_sheet.dart`.  
  Files:  
  - **Modify** `lib/features/flows/presentation/flows_screen.dart`  
  Verify: `flutter analyze lib/features/flows` — no errors.

- [ ] 17. **MEDIA — Create `AddMediaSheet`**  
  Create `lib/features/media/presentation/widgets/add_media_sheet.dart`. Fields: `name` (text, required), `mime_type` (DropdownButtonFormField: `image/jpeg` / `image/png` / `video/mp4` / `audio/mpeg` / `application/pdf`), `url` (text, required, URL keyboard), `size` (number keyboard, labelled "Size (bytes)").  
  Title: `'Add Media Asset'`, subtitle: `'Register a media file by URL'`.  
  Files:  
  - **Create** `lib/features/media/presentation/widgets/add_media_sheet.dart`  
  Verify: `flutter analyze lib/features/media` — no errors.

- [ ] 18. **MEDIA — Wire FAB in `media_screen.dart`**  
  The FAB exists but calls `ToastService.info(…)`. Replace `onPressed` to call `AddMediaSheet.show(context, onSave: (data) { setState(() { _media.insert(0, MediaFile(id: 'm${_media.length + 1}', name: data['name'], type: data['mime_type'].toString().split('/').first, size: '${data['size']} bytes', uploadedAt: DateTime.now())); }); ToastService.success('Media asset added'); })`. Import `add_media_sheet.dart`.  
  Files:  
  - **Modify** `lib/features/media/presentation/media_screen.dart`  
  Verify: `flutter analyze lib/features/media` — no errors.

- [ ] 19. **TAGS — Add color picker to `tag_manager_sheet.dart`**  
  Modify the existing sheet to add a `String _selectedColor` state variable defaulting to `'#25D366'`. Below the tag name TextField row, add a labeled row "Tag Color" followed by a `Wrap` of 8 `GestureDetector`-wrapped circular `Container` chips (diameter 28px) for the preset colors: `#25D366`, `#16A34A`, `#EF4444`, `#3B82F6`, `#F59E0B`, `#8B5CF6`, `#EC4899`, `#64748B`. The selected chip gets a `BoxDecoration` border `Border.all(color: Colors.black, width: 2)` and a checkmark icon inside. Pass `_selectedColor` alongside the tag name in `onAddTag` — change the callback signature to `void Function(String tag, String color)` and update the call-site in `contacts_screen.dart` to `onAddTag: (t, c) { notifier.addTag(t); ToastService.success('Tag #$t created'); }`.  
  Files:  
  - **Modify** `lib/features/contacts/presentation/widgets/tag_manager_sheet.dart`  
  - **Modify** `lib/features/contacts/presentation/contacts_screen.dart` (only the `onAddTag` lambda — do not touch any other part of the file)  
  Verify: `flutter analyze lib/features/contacts` — no errors.

- [ ] 20. **SEGMENTS — Add `filters` JSON field to `create_segment_sheet.dart`**  
  Add a `TextEditingController _filtersController` initialized to `''`. Below the "Opt-In only" checkbox, add a `TextFormField(controller: _filtersController, maxLines: 5, decoration: InputDecoration(labelText: 'Advanced Filters (JSON, optional)', alignLabelWithHint: true, hintText: '{"custom_field": "value"}'))`. Pass `_filtersController.text.trim()` in `_handleSubmit` — widen the `onSave` signature to `void Function(String name, String tagFilter, bool optInOnly, String filters)` and update the call-site in `contacts_screen.dart` to `onSave: (name, tag, optIn, filters) { notifier.createSegment(name, tag, optIn); ToastService.success('Segment "$name" created'); }`. Also dispose `_filtersController` in `dispose()`.  
  Files:  
  - **Modify** `lib/features/contacts/presentation/widgets/create_segment_sheet.dart`  
  - **Modify** `lib/features/contacts/presentation/contacts_screen.dart` (only the `onSave` lambda)  
  Verify: `flutter analyze lib/features/contacts` — no errors.

- [ ] 21. **WALLET — Create `AddTransactionSheet`**  
  Create `lib/features/wallet/presentation/widgets/add_transaction_sheet.dart`. Fields: `type` (DropdownButtonFormField: `credit` / `debit` / `refund`), `amount` (decimal keyboard, required, `hintText: '0.00'`), `reference` (optional text), `description` (optional multiline, `maxLines: 3`).  
  Title: `'Add Transaction'`, subtitle: `'Manually record a wallet transaction'`.  
  Files:  
  - **Create** `lib/features/wallet/presentation/widgets/add_transaction_sheet.dart`  
  Verify: `flutter analyze lib/features/wallet` — no errors.

- [ ] 22. **WALLET — Wire FAB in `wallet_screen.dart`**  
  The screen has no FAB. Add a `floatingActionButton` to the `Scaffold` calling `AddTransactionSheet.show(context, onSave: (data) { setState(() { final amt = double.tryParse(data['amount'].toString()) ?? 0.0; final isCredit = data['type'] == 'credit'; if (isCredit) _balance += amt; else _balance -= amt; _transactions.insert(0, {'id': _transactions.length + 101, 'wallet_id': 1, 'title': data['description'] ?? data['type'], 'description': data['reference'] ?? '', 'amount': isCredit ? amt : -amt, 'type': data['type'], 'reference_id': data['reference'] ?? 'manual', 'created_at': DateTime.now()}); }); ToastService.success('Transaction recorded'); })`. Import `add_transaction_sheet.dart`.  
  Files:  
  - **Modify** `lib/features/wallet/presentation/wallet_screen.dart`  
  Verify: `flutter analyze lib/features/wallet` — no errors.

- [ ] 23. **SETTINGS — Inline Organization form card**  
  The `settings_screen.dart` currently shows WABA account info, webhooks, and API keys. Add an "Organization" section at the very top of the `SingleChildScrollView` column (before the WABA Account card). The section uses the existing `_sectionHeader('Organization', 'Table: organizations', LucideIcons.building2)` pattern. Below the header, add an inline `Card`-style `Container` (white, `AppRadii.border2xl`, green border) containing a `Form` with: `name` (text, required), `slug` (text, required), `email` (email keyboard), `phone` (phone keyboard), `logo` (url text, optional), `website` (url text, optional), `timezone` (DropdownButtonFormField with values: `Asia/Kolkata`, `UTC`, `America/New_York`, `America/Los_Angeles`, `Europe/London`, `Europe/Paris`, `Asia/Dubai`, `Asia/Singapore`, `Australia/Sydney`), `currency` (DropdownButtonFormField: `INR` / `USD` / `EUR` / `GBP` / `AED`). Pre-populate controllers with sensible demo values (name: `'WhatsApp Wiz Demo Org'`, slug: `'demo-org'`, etc.). Add a "Save Organization" `ElevatedButton` at the bottom of the card that calls `ToastService.success('Organization settings saved')`.  
  No new file needed — everything is inline in the existing screen. Add a `final _orgFormKey = GlobalKey<FormState>()` and the 8 `TextEditingController` fields to `_SettingsScreenState`, initialised in `initState`, disposed in `dispose`.  
  Files:  
  - **Modify** `lib/features/settings/presentation/settings_screen.dart`  
  Verify: `flutter analyze lib/features/settings` — no errors.

- [ ] 24. **SETTINGS — Create `AddWabaSheet`**  
  Create `lib/features/settings/presentation/widgets/add_waba_sheet.dart`. Note: imports use `../../../core/…` (three levels up from `widgets/`). Fields: `business_id` (text, required), `waba_id` (text, required), `access_token` (obscured with eye-toggle, required), `token_expiry` (date picker via `TextFormField` with `readOnly: true` + `onTap`, labelled "Token Expiry Date"), `quality_rating` (DropdownButtonFormField: `UNKNOWN` / `GREEN` / `YELLOW` / `RED`), `status` (DropdownButtonFormField: `connected` / `disconnected` / `banned`).  
  Title: `'Add WABA Account'`, subtitle: `'Connect a WhatsApp Business Account'`.  
  Files:  
  - **Create** `lib/features/settings/presentation/widgets/add_waba_sheet.dart`  
  Verify: `flutter analyze lib/features/settings` — no errors.

- [ ] 25. **SETTINGS — Add "Add WABA" button to `settings_screen.dart`**  
  After the WABA Account card, add a `TextButton.icon(icon: Icon(AppIcons.add), label: Text('Add WABA Account'))` that calls `AddWabaSheet.show(context, onSave: (data) { ToastService.success('WABA account added'); })`. Import `add_waba_sheet.dart`.  
  Files:  
  - **Modify** `lib/features/settings/presentation/settings_screen.dart`  
  Verify: `flutter analyze lib/features/settings` — no errors.

- [ ] 26. **SETTINGS — Create `AddNumberSheet`**  
  Create `lib/features/settings/presentation/widgets/add_number_sheet.dart`. Fields: `phone_number` (phone keyboard, required), `phone_number_id` (text, required), `display_name` (text, required), `waba_account_id` (number keyboard, labelled "WABA Account ID"), `verification_status` (DropdownButtonFormField: `verified` / `unverified` / `pending`), `quality_rating` (DropdownButtonFormField: `GREEN` / `YELLOW` / `RED`).  
  Title: `'Add WhatsApp Number'`, subtitle: `'Register a WhatsApp Business phone number'`.  
  Files:  
  - **Create** `lib/features/settings/presentation/widgets/add_number_sheet.dart`  
  Verify: `flutter analyze lib/features/settings` — no errors.

- [ ] 27. **SETTINGS — Add "Add Number" button to `settings_screen.dart`**  
  Inside the WABA Account card, after the `..._numbers.map(…)` list, add a `TextButton.icon(icon: Icon(AppIcons.add), label: Text('Add WhatsApp Number'))` that calls `AddNumberSheet.show(context, onSave: (data) { ToastService.success('Number registered'); })`. Import `add_number_sheet.dart`.  
  Files:  
  - **Modify** `lib/features/settings/presentation/settings_screen.dart`  
  Verify: `flutter analyze lib/features/settings` — no errors.

- [ ] 28. **Final build verification**  
  Run a full analyze and web build to confirm all 15 new/modified files compile cleanly together.  
  Verify: `flutter analyze` (zero errors) then `flutter build web --no-tree-shake-icons` (build succeeds, no compilation errors).

---

## Dependency order

Items 1-2 (Users), 3-4 (Templates), 5-6 (Campaigns), 7-8 (Automation), 9-10 (Chatbot), 11-12 (Custom Fields), 13-14 (DND), 15-16 (Flows), 17-18 (Media), 21-22 (Wallet) are fully independent of each other — they can be done in any order.

Items 19-20 (Tags/Segments) both touch `contacts_screen.dart` so do them consecutively to avoid merge conflicts — do item 19 first, then 20.

Items 23, 25, 27 all modify `settings_screen.dart`. Do them in order: 23 → 24 → 25 → 26 → 27 so each change builds on the previous.

Item 28 must be last.
