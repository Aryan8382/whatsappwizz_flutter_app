# Flutter ↔ Web Sync Plan
**Goal:** Make every screen in the Flutter app match the reference Next.js web app in tabs, fields, buttons, filters, modals, table columns, and actions — frontend/UI only, no backend calls.

**Build command:** `flutter build web --no-tree-shake-icons`  
**Verify command:** `flutter analyze` — zero errors expected after each item  
**DO NOT modify:** `premium_bottom_nav_bar.dart`, `app_scaffold.dart`, core theme files, `more_drawer.dart`

---

## Summary of What Already Exists vs What is Missing

### Already Done (from plan.md)
All 28 items in `plan.md` — sheets are created and wired for users, templates, campaigns, automation, chatbot, custom-fields, DND, flows, media, wallet, settings (org form, WABA sheet, number sheet), tags color picker, segments filters.

---

## Module-by-Module Gap Analysis

### 1. Contacts
**Web:** 3 tabs — Contacts, Segments, Tags. Contacts tab has: search, show-records selector, Import (CSV), History modal, Export CSV, Broadcast-to-selected button, paginated table with checkbox selection (columns: checkbox, #, Name, Phone, Action menu with Edit/Delete/Message). Segments tab: create-segment button, segments table. Tags tab: manage tags.  
**Flutter:** Single `contacts_screen.dart` shows a flat list with search + tag filter chips, FAB for Add Contact, icons for import/export/segment/tags. No explicit Contacts/Segments/Tags tab bar. Table format missing (shows ListView tiles). No "Broadcast to selected" button. No pagination/records-per-page selector. No History modal. Contact form fields match (firstName, lastName, mobile, email, city, optIn, tags).

**Gap:**
- Missing: `Tab bar` with Contacts / Segments / Tags tabs
- Missing: Table/grid layout for contacts with checkbox column, # column, pagination, records-per-page selector
- Missing: "Broadcast to Selected (N)" button when contacts are checked
- Missing: Import History modal
- Segments tab: needs its own list view showing existing segments
- Tags tab: needs its own list view showing all tags with delete action
- Contact row: needs inline action menu (Edit / Delete / Message) matching web

---

### 2. Campaigns
**Web:** 4-step wizard (Select template → Choose segment → Map variables → Schedule & Launch). Campaign list shows cards with status, analytics. Analytics per campaign. Top bar has Wallet Balance warning.  
**Flutter:** Has both `CampaignWizardSheet` (full wizard) and `AddCampaignSheet` (simple DB form). Campaigns list shows progress bar, delivery rate, read rate, pause/resume/analytics buttons. Wallet balance card present.

**Gap:**
- Web wizard step 3 (Map template variables + media upload) not in Flutter wizard — `CampaignWizardSheet` is a simplified version
- Missing: "Sync from Meta" button (refresh templates during wizard step 1)
- Missing: Campaign list search bar
- Missing: Show records per page selector
- Missing: Delete campaign button on list cards

---

### 3. Templates
**Web:** Multi-step builder (Step 1: Basic Info — name, language, allow-category-change, category with sub-categories accordion; Step 2: Content — header type selector with TEXT/IMAGE/VIDEO/DOCUMENT/LOCATION, body with variable insertion, footer; Step 3: Buttons — QUICK_REPLY/URL/PHONE_NUMBER/COUPON). List view has filter tabs (all/pending/approved/rejected), sync button, delete button, submit button per template. Live phone preview panel.  
**Flutter:** Has `TemplateBuilderSheet` (wizard) and `AddTemplateSheet` (simple form). List has filter chips, FAB.

**Gap:**
- Template list missing: per-template "Submit to Meta" button (web has this as a row action)
- Template list missing: per-template "Delete" button
- Template list missing: "Sync from Meta" button
- Template list missing: search bar
- Template builder missing: Allow Category Change field (Step 1)
- Template builder missing: sub-category selection within each category
- Template builder missing: LOCATION header type with lat/lng/name/address fields
- Template builder missing: COUPON button type
- Template builder missing: live phone preview side panel

---

### 4. Chatbot
**Web:** List of bot flows with name, published status, keyword triggers, message count. Edit modal with: project name, header type (None/Image/Video/Document), header media URL, body, footer, message type (Text/Image/Video/Document/Audio), greeting, products list (with keywords, images, price, currency, description), buttons (QUICK_REPLY/URL/PHONE_NUMBER/LOCATION). Search bar on list. Delete button.  
**Flutter:** Has flow list with canvas editor. Shows name, description, node count, "Open Canvas" button. Has `AddBotSheet` (name + published toggle + config JSON) and `BotTestSheet`.

**Gap:**
- Missing: Search bar on chatbot flow list
- Missing: Per-flow Delete button on the list
- Missing: Edit flow details sheet with web's fields (project, headerType, body, footer, messageType, greeting, products, buttons)
- Missing: Keyword triggers display on each flow card
- Current edit is canvas-based; web has a modal form — need a `EditBotFlowSheet` with all the fields from the web EditForm interface

---

### 5. Automation
**Web:** Stats grid (total/active/draft/paused), table with columns: Name, Status badge, Trigger, Steps count, Last run, Action (Play/Pause/Delete). Search bar. Status filter dropdown. Records-per-page selector. Row-click navigates to detail page.  
**Flutter:** List with toggle switch per item, no stats grid. Has `AddAutomationSheet`. Shows name, status, trigger type, description.

**Gap:**
- Missing: Stats summary grid (total/active/draft/paused counts as stat cards)
- Missing: Search bar
- Missing: Status filter dropdown
- Missing: Records-per-page selector
- Missing: "Steps count" and "Last run" displayed on each card
- Missing: Delete button per workflow item
- Table format vs card format (minor — keep cards but add the missing data points)

---

### 6. Custom Fields
**Web:** Table with columns: Name, Field Type, Default Value, Show in Listing (toggle), Status (toggle), Mandatory (toggle), Created At, Action (Edit/Delete). Search bar. Records-per-page. Inline edit modal.  
**Flutter:** Card list showing name, variable key, type badge. Has `AddCustomFieldSheet`. No edit action, no delete action, no inline toggle controls.

**Gap:**
- Missing: Per-item Edit action (opens AddCustomFieldSheet pre-populated)
- Missing: Per-item Delete action
- Missing: Search bar
- Missing: Records-per-page selector
- Missing: Show "Created At" metadata on cards
- Missing: Toggle switches for `show_in_listing`, `status`, `mandatory` directly on list cards

---

### 7. DND
**Web:** Table with columns: Sr.no, Number, Added At (green date), Message, Action (Delete). Search bar. Records-per-page. Add number modal with Number + Message fields.  
**Flutter:** `dnd_screen.dart` exists. Has `AddDndSheet`. List shows phone, reason, date as tiles.

**Gap:**
- Missing: Table format with Sr.no column and "Added At" shown in green
- Missing: Search bar
- Missing: Records-per-page selector
- Minor: list rows should match web table row format (number bold, date in green color)

---

### 8. WhatsApp Flows
**Web:** Table with columns: Sr.no, Flow ID (flowRef), Name, Category, Status badge, Health Status badge, Created By, Created At, Action (Delete). Search bar. Records-per-page. "Sync Flow" button. Create modal (name + category only). Row-click navigates to flow editor.  
**Flutter:** `flows_screen.dart` card list. Has `AddFlowSheet`. Shows name, category, status, health, created date.

**Gap:**
- Missing: Table format with Flow ID / Sr.no / Created By columns
- Missing: Search bar
- Missing: Records-per-page selector
- Missing: "Sync Flow" (refresh) button in header
- Missing: Per-flow Delete button (currently not on the list)
- Missing: Row-tap navigation to flow editor (canvas)

---

### 9. Media
**Web:** Two views — list view (table: Name, MIME type, Size, URL, Created At, Action with External Link + Delete) and upload view (drag-and-drop area, file size limit info). Search bar. Records-per-page. "Upload" button toggles to upload view.  
**Flutter:** `media_screen.dart` card list. Has `AddMediaSheet` (by URL). No upload-by-file drag-drop view.

**Gap:**
- Missing: Upload-by-file view (drag-drop / file picker), switching between list and upload views
- Missing: Search bar
- Missing: Records-per-page selector
- Missing: Table format with columns (name, type, size, URL, date)
- Missing: Per-item external link button
- Missing: Per-item Delete action

---

### 10. Users
**Web:** Simple read-only table with Name, Email, Role, Status. No create/edit on this page (settings page handles that).  
**Flutter:** `users_screen.dart` shows card list with full name, email, role badge, status, last login, online indicator. Has filter chips for status. Has FAB with `AddUserSheet`. Has tap-to-detail modal with all DB fields.

**Gap:**
- Flutter is actually MORE complete than the web page here (the web users page is minimal)
- Minor: Flutter shows "last login" and online indicator — these are good extras
- Consider adding a search bar to match web patterns

---

### 11. Wallet
**Web:** Balance hero with recharge input + button. Message costs card. API Keys card (generate/revoke/copy). Transactions table (type, description, amount, date). Invoices table (invoice number, date, status).  
**Flutter:** Has balance hero with Top Up + Meta Rates buttons. Transactions + Invoices tabs. Has `AddTransactionSheet`. Has "Recharge" sheet. Missing API Keys section.

**Gap:**
- Missing: API Keys card (Generate Key button, list of keys with copy + revoke)
- Missing: Message costs card (Text/Media/Template message rate display)
- Web has `amount` input directly on the balance hero; Flutter has a separate sheet — minor UX difference, acceptable

---

### 12. Settings
**Web:** Profile form (firstName, lastName, email read-only, role badge), Change Password form (current + new password), Team Members section with inline create-user form + team table, Messenger API Status card (token valid indicator + base URL), Webhook Management card (current webhook URL + register/delete).  
**Flutter:** Has Organization form (name, slug, email, phone, logo, website, timezone, currency), WABA Account card, Add WABA sheet, Add Number sheet, API key section, webhook section.

**Gap:**
- Missing: Profile form (firstName, lastName, view-only email, role badge)
- Missing: Change Password form
- Missing: Team Members section with inline add-user form + table
- Missing: Messenger API Status card (token valid indicator + baseUrl display)
- Note: Flutter has Organization form which web doesn't show on this page — keep it, it's a valid addition

---

### 13. Reports
**Web:** KPI grid (8 stats: Delivered Rate, Read Rate, Failed Messages, Active Agents, Connected Numbers, Messages Sent, Messages Received, Open Conversations). Message volume bar chart. Campaign performance table (Name, Status, Delivery%, Read%). Agent activity table (Agent, Conversations Assigned, Resolved, Messages Sent, Delivered). Export buttons for messages/campaigns/agents.  
**Flutter:** 3 tabs (Messages, Broadcasts, Agents) with summary cards and a line chart. Missing the full web data layout.

**Gap:**
- Missing: KPI stat grid (8 stats) at the top
- Missing: Bar chart for message volume (Flutter uses line chart — should use bar chart)
- Missing: Campaign performance table
- Missing: Agent activity table with correct columns (Conversations Assigned, Resolved, Messages Sent, Delivered)
- Missing: Export buttons (messages/campaigns/agents CSV exports)
- Tab structure acceptable but tabs should be removed in favor of web's single-page layout OR kept and each tab should have the correct content

---

### 14. Inbox
**Web:** Full WhatsApp-style chat with conversation list (search, filter by status/agent), chat pane (messages, media, bot toggles, emoji picker), assign agent, update status, template picker, activity events (assign/unassign/status), internal notes, file attachments.  
**Flutter:** `InboxScreen` has full dual-pane (desktop) and single-pane (mobile) layout. ConversationListPane + ChatPane. Has assign agent sheet, template picker sheet, contact info sheet, audio bubbles, media lightbox, free window countdown badge.

**Gap:**
- Flutter inbox is very complete. Minor gaps:
- Missing: Search bar in conversation list pane
- Missing: Status filter dropdown (Open/Resolved/etc.) in conversation list
- Missing: Bot enable/disable toggle per conversation
- Missing: Activity event display (inline system messages like "Chat assigned to X")
- Missing: Emoji picker in composer

---

### 15. Admin
**Web:** Organizations table (Name, Slug, Users count, Numbers count, Wallet balance, Status, Created At, Details button). Org detail expandable stats grid. Audit log table (Time, User, Action, Entity, IP Address). Super-admin role guard.  
**Flutter:** `admin_screen.dart` shows org cards (name, slug, plan, users count) and audit log with (action, user, time). No IP address. No wallet balance. No numbers count. No "Details" button that expands a stats grid.

**Gap:**
- Missing: Organizations table with columns: Numbers count, Wallet balance, Created At
- Missing: "Details" button per org that expands/shows a stats grid (users, messages, campaigns, wallet balance)
- Missing: Audit log columns: IP Address, Entity
- Missing: Role guard (super_admin only) — show a restricted-area message if not super admin

---

### 16. Template Library
**Web:** Search bar, UTILITY/AUTHENTICATION tab toggle, Language selector, left-panel filters (Industry, Topic, Use Case checkboxes), template cards grid (title, body preview, button label, ID + language + type, preview arrow button). Preview modal with Use Template button. Pagination.  
**Flutter:** `template_library_screen.dart` has filter chips (All/MARKETING/UTILITY/AUTHENTICATION) and template cards with "Use Template" button. 6 hardcoded templates. No search, no side-panel filters, no preview modal, no pagination, no UTILITY/AUTHENTICATION tab.

**Gap:**
- Missing: Search bar
- Missing: UTILITY / AUTHENTICATION tab toggle (Flutter has MARKETING too which web doesn't — keep it)
- Missing: Left-panel filter groups (Industry, Topic, Use Case)
- Missing: Preview modal (show header, body, footer, button label before using)
- Missing: Pagination UI
- Missing: Language filter
- Data is hardcoded locally — acceptable per frontend-only constraint but consider expanding the list

---

### 17. Apps (was placeholder)
**Web:** `ModulePlaceholder` — just shows title "Apps" + description  
**Flutter:** `ModulePlaceholderScreen` — matches exactly

**Gap:** None. Already matches.

---

### 18. Business (was placeholder)
**Web:** `ModulePlaceholder`  
**Flutter:** `ModulePlaceholderScreen`

**Gap:** None. Already matches.

---

### 19. Catalogue (was placeholder)
**Web:** `ModulePlaceholder`  
**Flutter:** `ModulePlaceholderScreen`

**Gap:** None. Already matches.

---

### 20. SIM Card (was placeholder)
**Web:** `ModulePlaceholder`  
**Flutter:** `ModulePlaceholderScreen`

**Gap:** None. Already matches.

---

## Implementation Plan

**Conventions (same as plan.md):**
- Sheet classes: `StatefulWidget`, `static Future<void> show(…)`, calls `ModalSheet.show(…)`
- Use `AppColors.g600`, `AppRadii`, `AppTypography` from core theme
- FABs use `Padding(padding: EdgeInsets.only(bottom: 76), child: FloatingActionButton.extended(…))`
- No Riverpod providers, domain models, or API calls — all in-memory state
- Do not modify: `premium_bottom_nav_bar.dart`, `app_scaffold.dart`, core theme files, `more_drawer.dart`

---

### FEAT-A: Contacts Screen — Tab Bar + Table Layout + Actions

**Independent of all other FEATs.**

- [ ] **A1. Add tab bar to `contacts_screen.dart`**  
  Wrap the current screen body in a `DefaultTabController(length: 3)`. Add a `TabBar` below the header row with tabs: Contacts, Segments, Tags. Move the existing contacts list to the Contacts tab. Create a `_SegmentsTab` widget and a `_TagsTab` widget (both `StatelessWidget` with mock data lists).  
  Files: `lib/features/contacts/presentation/contacts_screen.dart`  
  Verify: `flutter analyze lib/features/contacts` — no errors.

- [ ] **A2. Add Segments tab content**  
  Create `_SegmentsTab` as a private class inside `contacts_screen.dart`. Shows a `ListView` of mock segments with columns: name, tag filter, contact count, created date, delete action. Reuses the existing `CreateSegmentSheet.show(…)` via a FAB-style `TextButton` at the top.  
  Files: `lib/features/contacts/presentation/contacts_screen.dart`  
  Verify: `flutter analyze lib/features/contacts` — no errors.

- [ ] **A3. Add Tags tab content**  
  Create `_TagsTab` as a private class inside `contacts_screen.dart`. Shows a `ListView` of `contactsState.tags` with tag name, a color swatch (using existing `tag_manager_sheet.dart` colors), and a delete `IconButton`. Reuses `TagManagerSheet.show(…)` via a header action button.  
  Files: `lib/features/contacts/presentation/contacts_screen.dart`  
  Verify: `flutter analyze lib/features/contacts` — no errors.

- [ ] **A4. Add search bar, records-per-page, pagination row to Contacts tab**  
  In the Contacts tab, add: a `TextEditingController` for search (wire to existing `_searchController`), a `DropdownButton<int>` for records-per-page (25/50/100, default 25) above the list. Add a `Row` at the bottom showing "Showing X–Y of Z" with Previous/Next icon buttons using `_currentPage` and `_perPage` state variables that slice the filtered list.  
  Files: `lib/features/contacts/presentation/contacts_screen.dart`  
  Verify: `flutter analyze lib/features/contacts` — no errors.

- [ ] **A5. Add checkbox multi-select and Broadcast-to-Selected button**  
  Add `Set<String> _selectedIds` state. Each `ListTile` gets a leading `Checkbox` widget. When `_selectedIds.isNotEmpty`, show a green `ElevatedButton.icon(icon: MessageSquare, label: 'Broadcast to Selected (N)')` above the list that calls `ToastService.info('Navigating to Campaigns with ${_selectedIds.length} contacts')` and clears selection.  
  Files: `lib/features/contacts/presentation/contacts_screen.dart`  
  Verify: `flutter analyze lib/features/contacts` — no errors.

- [ ] **A6. Add Import History modal**  
  Add a `History` icon button in the header row. On press, call `ModalSheet.show(context, title: 'Import History', subtitle: 'All contact import events', child: ...)` showing a static list of 3 mock import events with date/count/skipped columns.  
  Files: `lib/features/contacts/presentation/contacts_screen.dart`  
  Verify: `flutter analyze lib/features/contacts` — no errors.

---

### FEAT-B: Automation Screen — Stats Grid + Search + Filters + Delete

**Independent of all other FEATs.**

- [ ] **B1. Add stats grid to `automation_screen.dart`**  
  At the top of the `Scaffold` body (before the workflow list), add a `GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: NeverScrollableScrollPhysics(), ...)` with 4 stat cards: Total, Active, Draft, Paused. Use mock counts derived from the `workflows` list. Each card is a `Container` with white background, green border, title text + count.  
  Files: `lib/features/automation/presentation/automation_screen.dart`  
  Verify: `flutter analyze lib/features/automation` — no errors.

- [ ] **B2. Add search bar + status filter + records-per-page to `automation_screen.dart`**  
  Add `TextEditingController _searchController`, `String _statusFilter = 'all'`, `int _perPage = 25` state variables. Add a `Row` above the list with: `AppSearchBar` for search, a `DropdownButtonFormField<String>` for status (all/draft/active/paused), and a `DropdownButton<int>` for records-per-page (25/50/100). Filter the `workflows` list accordingly and slice to `_perPage`.  
  Files: `lib/features/automation/presentation/automation_screen.dart`  
  Verify: `flutter analyze lib/features/automation` — no errors.

- [ ] **B3. Add Delete button and Steps/Last-run metadata to each workflow card**  
  On each workflow card, add: a `Text` showing `${w.steps?.length ?? 0} steps` and `Last run: ${w.lastRunAt ?? 'Never'}`. Add a `PopupMenuButton` (⋮) with "Delete" action that removes from the list with `setState`. Show "Last run" field with a `DateTime` from the mock data.  
  Files: `lib/features/automation/presentation/automation_screen.dart`  
  Verify: `flutter analyze lib/features/automation` — no errors.

---

### FEAT-C: Custom Fields Screen — Edit + Delete + Search + Toggles

**Independent of all other FEATs.**

- [ ] **C1. Add search bar + records-per-page to `custom_fields_screen.dart`**  
  Add `TextEditingController _searchController`, `int _perPage = 25` state. Add toolbar row above the list with `AppSearchBar` and `DropdownButton<int>`. Filter `_fields` list by name substring match and slice to `_perPage`.  
  Files: `lib/features/custom_fields/presentation/custom_fields_screen.dart`  
  Verify: `flutter analyze lib/features/custom_fields` — no errors.

- [ ] **C2. Add Edit + Delete per field, inline toggles for showInListing/status/mandatory**  
  Expand the `CustomField` domain class (or the local mock map) to include `bool showInListing`, `bool status`, `bool mandatory`, `DateTime createdAt`. On each list card, add: three `Row`-aligned `SwitchListTile`s (compact, `contentPadding: EdgeInsets.zero`). Add a `PopupMenuButton` with "Edit" (opens `AddCustomFieldSheet` pre-populated) and "Delete" (removes from list with `setState` + `ToastService.success`).  
  Files:  
  - `lib/features/custom_fields/presentation/custom_fields_screen.dart`  
  - `lib/features/custom_fields/domain/custom_field.dart` (add fields if they don't exist)  
  Verify: `flutter analyze lib/features/custom_fields` — no errors.

---

### FEAT-D: DND Screen — Table Format + Search + Records-per-page

**Independent of all other FEATs.**

- [ ] **D1. Refactor `dnd_screen.dart` to table layout with search + records-per-page**  
  Replace the current tile list with a `DataTable`-style `Column`+`Table` widget or a `ListView` that renders each row with fixed-width columns: Sr.no (gray), Number (bold, primary), Added At (green color), Message, Delete button. Add `AppSearchBar` and `DropdownButton<int>` toolbar above. Color "Added At" text with `AppColors.g600`.  
  Files: `lib/features/dnd/presentation/dnd_screen.dart`  
  Verify: `flutter analyze lib/features/dnd` — no errors.

---

### FEAT-E: Flows Screen — Table Format + Search + Sync Button + Delete + Row-tap

**Independent of all other FEATs.**

- [ ] **E1. Refactor `flows_screen.dart` to table layout with full web columns**  
  Replace card list with a scrollable table layout. Each row shows: Sr.no, Flow ID (flowRef from mock data), Name (bold), Category, Status badge, Health Status badge, Created By, Created At, Delete button. Add a search `AppSearchBar` and `DropdownButton<int>` records-per-page toolbar. Add a "Sync Flows" `OutlinedButton.icon(icon: RefreshCw)` in the AppBar actions that calls `ref.invalidate(flowsProvider)` + `ToastService.info('Flows synced')`. Add `onTap` to each row that navigates to the chatbot canvas with `context.push('/chatbot')` (since Flutter doesn't have a separate flow editor route — or `ToastService.info('Flow editor: ${flow.name}')`).  
  Files: `lib/features/flows/presentation/flows_screen.dart`  
  Verify: `flutter analyze lib/features/flows` — no errors.

---

### FEAT-F: Media Screen — Upload View + Search + Table + Delete

**Independent of all other FEATs.**

- [ ] **F1. Add upload-by-file view to `media_screen.dart`**  
  Add `bool _showUpload = false` state. When `_showUpload == true`, show a full-screen upload `Card` with a dashed border `Container` (matching web's upload zone), a `TextButton` "Choose File" (calls `ToastService.info('File picker opened')`), drag-drop hint text, file type and size info footer. Add a back arrow `IconButton` to return to list view. Change the existing FAB/header button to toggle `_showUpload = true` instead of opening `AddMediaSheet`.  
  Files: `lib/features/media/presentation/media_screen.dart`  
  Verify: `flutter analyze lib/features/media` — no errors.

- [ ] **F2. Add search bar + records-per-page + table format + delete + external link to `media_screen.dart`**  
  In list view, add `AppSearchBar` + `DropdownButton<int>` toolbar. Replace card list with a compact table-style `ListView` showing: thumbnail/type icon, name (bold), MIME type, size, URL (truncated), created date, actions (external link icon + delete icon). Delete icon calls `setState` to remove from `_media` list. External link icon calls `ToastService.info('Opening: ${item.url}')`.  
  Files: `lib/features/media/presentation/media_screen.dart`  
  Verify: `flutter analyze lib/features/media` — no errors.

---

### FEAT-G: Templates Screen — Per-Template Actions + Search + Sync Button

**Independent of all other FEATs.**

- [ ] **G1. Add search bar + Sync button + per-template Submit/Delete actions to `templates_screen.dart`**  
  Add `TextEditingController _searchController` state. Add toolbar `Row` above the list with `AppSearchBar` (filter templates by name) and an `OutlinedButton.icon(icon: RefreshCw, label: 'Sync Meta')` that calls `ref.invalidate(templatesProvider)` + `ToastService.success('Templates synced')`. On each template card, add a `PopupMenuButton` with: "Submit to Meta" (`ToastService.success('Template submitted for Meta approval')`) and "Delete" (removes via `repo.deleteTemplate` + `ref.invalidate`).  
  Files: `lib/features/templates/presentation/templates_screen.dart`  
  Verify: `flutter analyze lib/features/templates` — no errors.

- [ ] **G2. Add Allow Category Change field and COUPON button type to `template_builder_sheet.dart`**  
  In Step 1 of the existing `TemplateBuilderSheet`, add a `DropdownButtonFormField<String>` for "Allow Category Change" (values: `'No'`/`'Yes'`, default `'No'`) between the Language and Category selection. In Step 3 (buttons), add a "Copy Code (Coupon)" option to the button type selector alongside QUICK_REPLY/URL/PHONE_NUMBER. Handle the COUPON type's `value` field as "Coupon Code" text input.  
  Files: `lib/features/templates/presentation/widgets/template_builder_sheet.dart`  
  Verify: `flutter analyze lib/features/templates` — no errors.

---

### FEAT-H: Campaigns Screen — Wizard Enhancements + Search + Delete

**Independent of all other FEATs.**

- [ ] **H1. Add "Sync from Meta" button and campaign list search + delete to `campaigns_screen.dart`**  
  Add `TextEditingController _searchController` state. Add a `Row` toolbar above the campaign cards with `AppSearchBar` filtering campaigns by name. Add an `OutlinedButton.icon(icon: RefreshCw, label: 'Sync')` in the header that calls `ref.invalidate(campaignsProvider)` + `ToastService.success('Campaigns synced')`. On each campaign card's controls row, add a `TextButton.icon(icon: Trash2, label: 'Delete', style: TextButton.styleFrom(foregroundColor: Colors.red))` that removes the campaign from the repo and refreshes.  
  Files: `lib/features/campaigns/presentation/campaigns_screen.dart`  
  Verify: `flutter analyze lib/features/campaigns` — no errors.

---

### FEAT-I: Chatbot Screen — Search + Delete + Edit Flow Sheet

**Independent of all other FEATs.**

- [ ] **I1. Add search bar + Delete button to chatbot flow list in `chatbot_screen.dart`**  
  In the flow-list view body, wrap the `ListView.separated` in a `Column` preceded by a `Padding`+`AppSearchBar`. Filter flows by name. On each flow card add a `PopupMenuButton` with "Delete" that calls `repo.deleteFlow(flow.id)` + `ref.invalidate(chatbotFlowsProvider)` + `ToastService.success(...)`.  
  Files: `lib/features/chatbot/presentation/chatbot_screen.dart`  
  Verify: `flutter analyze lib/features/chatbot` — no errors.

- [ ] **I2. Create `EditBotFlowSheet` widget**  
  Create `lib/features/chatbot/presentation/widgets/edit_bot_flow_sheet.dart`. Fields matching web's `EditForm` interface: `project` (text, labelled "Project Name"), `headerType` (DropdownButtonFormField: `None`/`Image`/`Video`/`Document`), `headerMediaUrl` (text, shown when headerType != None), `body` (multiline, `maxLines: 4`), `footer` (optional text), `messageType` (DropdownButtonFormField: `Text`/`Image`/`Video`/`Document`/`Audio`), `greeting` (text, default `'Hi! How can I help you today?'`). Products section: a `ListView` of product items with `+` button to add — each product has name + keywords + price. Buttons section: `ListView` with `+` button to add — each button has type (QUICK_REPLY/URL/PHONE_NUMBER/LOCATION) + text + value. Title: `'Edit Bot Flow'`, subtitle: `'Configure bot conversation settings'`.  
  Files: `lib/features/chatbot/presentation/widgets/edit_bot_flow_sheet.dart`  
  Verify: `flutter analyze lib/features/chatbot` — no errors.

- [ ] **I3. Wire "Edit" action to open `EditBotFlowSheet` from each flow card**  
  Add "Edit" to the `PopupMenuButton` on each flow card (alongside the Delete from I1) that calls `EditBotFlowSheet.show(context, flow: flow, onSave: (data) { ToastService.success('Flow updated'); ref.invalidate(chatbotFlowsProvider); })`.  
  Files: `lib/features/chatbot/presentation/chatbot_screen.dart`  
  Verify: `flutter analyze lib/features/chatbot` — no errors.

---

### FEAT-J: Reports Screen — KPI Grid + Bar Chart + Tables + Export Buttons

**Independent of all other FEATs.**

- [ ] **J1. Rebuild `reports_screen.dart` to match web layout**  
  Replace the current 3-tab layout with a single scrollable page matching the web. Add:  
  1. Export buttons row at the top: `OutlinedButton.icon` for "Export messages", "Export campaigns", "Export agents" — all call `ToastService.info('Exporting ${type} CSV...')`.  
  2. KPI stats grid `GridView.count(crossAxisCount: 2)` with 8 stat cards: Delivered Rate (92.4%), Read Rate (88.1%), Failed Messages (124), Active Agents (3), Connected Numbers (2), Messages Sent (42850), Messages Received (18920), Open Conversations (7). Each card is a white `Container` with green border, label text (gray, small, uppercase) + value (large bold dark).  
  3. Bar chart `_ChartCard` showing message volume — replace `LineChart` with `BarChart` (from `fl_chart`, already a dependency) with two data series: `sent` (green) and `received` (light green). Keep the existing `_ChartCard` widget wrapper.  
  4. Campaign performance table in a white `Card`: columns Name/Status/Delivery%/Read%. Populate with mock data from existing campaign mock or hardcoded rows.  
  5. Agent activity table in a white `Card`: columns Agent/Conversations Assigned/Resolved/Messages Sent/Delivered. Populate with mock data.  
  Files: `lib/features/reports/presentation/reports_screen.dart`  
  Verify: `flutter analyze lib/features/reports` — no errors.

---

### FEAT-K: Admin Screen — Full Table Layout + Details + Audit Columns + Role Guard

**Independent of all other FEATs.**

- [ ] **K1. Rebuild `admin_screen.dart` to match web layout**  
  Replace current implementation with:  
  1. Role guard: Add a check for a mock `_isSuper = true` bool (or a `const bool _isSuper = true` since it's demo-only). If false, show an `EmptyState` with icon `LucideIcons.shield`, title "Restricted Area", message "Super admins only".  
  2. Organizations table: Use a horizontal-scrollable `SingleChildScrollView` wrapping a `DataTable` (or custom table) with columns: Name, Slug (code-style), Users, Numbers, Wallet Balance, Status badge, Created At, Details button. Mock data should extend the existing two orgs with `numberCount`, `walletBalance`, `createdAt` fields. The "Details" button sets `_selectedOrg` state.  
  3. Org details expandable panel: When `_selectedOrg != null`, show a `Card` below the orgs table with a stats grid `GridView.count(crossAxisCount: 2)` showing: Total Users, Total Numbers, Wallet Balance, Messages Sent, Campaigns, Templates. Add a close `IconButton`.  
  4. Audit log table: Add columns IP Address and Entity to the existing audit rows. Mock data should include `ipAddress` and `entity` fields.  
  Files: `lib/features/admin/presentation/admin_screen.dart`  
  Verify: `flutter analyze lib/features/admin` — no errors.

---

### FEAT-L: Wallet Screen — API Keys Card + Message Costs Card

**Independent of all other FEATs.**

- [ ] **L1. Add API Keys card and Message Costs card to `wallet_screen.dart`**  
  Add two new cards in a `Column` above the existing balance card:  
  1. **Message Costs card**: White `Container` with green border, title "Message Costs". Shows three rows: Text message / ₹0.10, Media message / ₹0.20, Template message / ₹0.30. Each row is a light-green `Container` with space-between layout.  
  2. **API Keys card**: White `Container` with green border, title "API Keys", header row with a "Generate" `OutlinedButton`. State `List<Map<String,String>> _apiKeys = []`. "Generate" button adds `{'key': 'wiz_key_${timestamp}', 'secret': 'wiz_secret_${timestamp}'}` and shows a `ModalSheet` "Store securely — shown once" with key + secret values + copy icons. Each existing key in the list shows truncated key + "Revoke" red `TextButton` that removes from `_apiKeys` list with `setState`.  
  Files: `lib/features/wallet/presentation/wallet_screen.dart`  
  Verify: `flutter analyze lib/features/wallet` — no errors.

---

### FEAT-M: Settings Screen — Profile Form + Change Password + Team Members + Messenger Status

**Independent of all other FEATs.**

- [ ] **M1. Add Profile form, Change Password form, and Team Members section to `settings_screen.dart`**  
  Add three new sections at the top of the `SingleChildScrollView` (before the existing Organization card):  
  1. **Profile section**: `_sectionHeader('Profile', 'Your account details', LucideIcons.userCircle)` then an inline `Card` `Container` with: first name + last name (side-by-side row), email (disabled, pre-filled `'admin@demo.com'`), role badge row. "Save Profile" `ElevatedButton` calls `ToastService.success('Profile saved')`.  
  2. **Change Password section**: `_sectionHeader('Change Password', 'Update your login credentials', LucideIcons.lock)` then a `Card` with: current password (obscured), new password (obscured), "Update Password" button calls `ToastService.success('Password updated successfully')`.  
  3. **Team Members section**: `_sectionHeader('Team Members', 'Manage agent seats & roles', LucideIcons.users)` then a `Card` with an inline create-user form row (firstName, lastName, email, password, role dropdown, Add button), followed by a `ListView.builder` showing existing `_teamMembers` mock list with Name/Email/Role/Status columns.  
  Add state: `final _profileFormKey`, `TextEditingController` for firstName, lastName, email (read-only), `final _pwdCurrentCtrl`, `final _pwdNewCtrl`, `List<Map<String,dynamic>> _teamMembers` (mock 3 entries).  
  Files: `lib/features/settings/presentation/settings_screen.dart`  
  Verify: `flutter analyze lib/features/settings` — no errors.

- [ ] **M2. Add Messenger API Status card to `settings_screen.dart`**  
  After the existing WABA Account card, add a section titled "Messenger API Status" with a `_sectionHeader`. Show an inline `Card` containing: a status indicator row (green checkmark + "Connected & Authenticated" if `_messengerConnected == true`, else red X + "Authentication Failed"), a read-only text field for "Base URL" showing `'https://graph.facebook.com/v20.0'`. Add `bool _messengerConnected = true` state.  
  Files: `lib/features/settings/presentation/settings_screen.dart`  
  Verify: `flutter analyze lib/features/settings` — no errors.

---

### FEAT-N: Template Library — Search + Preview Modal + Filters + Pagination

**Independent of all other FEATs.**

- [ ] **N1. Add search bar, preview modal, and type tab toggle to `template_library_screen.dart`**  
  Add state: `TextEditingController _searchController`, `String _activeType = 'ALL'`. Add a toolbar `Row` with `AppSearchBar` (filter by title) and a `Row` of `ChoiceChip` widgets for MARKETING/UTILITY/AUTHENTICATION (replace current `FilterChips`). Add a preview modal: each template card gets a `PopupMenuButton` or `IconButton` "Preview" that calls `ModalSheet.show(context, title: item.title, subtitle: item.category, child: ...)` showing header (if any), full body text, footer, button label with a "Use Template" `ElevatedButton` at the bottom.  
  Files: `lib/features/template_library/presentation/template_library_screen.dart`  
  Verify: `flutter analyze lib/features/template_library` — no errors.

- [ ] **N2. Expand template library mock data to 15+ templates with Industry/Topic metadata**  
  Add 10 more `LibraryTemplateItem` entries to `libraryTemplates` covering more categories. Extend `LibraryTemplateItem` to include optional `String? industry` and `String? topic`. Add side-panel filter checkboxes (wrap in `ExpansionTile` groups: Industry, Topic) that filter the displayed list. Add pagination state `_page = 1, _perPage = 12` that shows `_page * _perPage` items with "Load more" button.  
  Files: `lib/features/template_library/presentation/template_library_screen.dart`  
  Verify: `flutter analyze lib/features/template_library` — no errors.

---

### FEAT-O: Inbox Screen — Search + Status Filter + Bot Toggle + Emoji Picker + Activity Events

**Independent of all other FEATs.** Note: Do NOT modify `InboxScreen`'s core `ConversationListPane`/`ChatPane` structure — add within them.

- [ ] **O1. Add search bar to `conversation_list_pane.dart`**  
  Add `TextEditingController _searchController` state to `ConversationListPane`. Add a `AppSearchBar` at the top of the list (below the existing header if any). Filter the `conversations` list by `contact.name` or `lastMessage` substring.  
  Files: `lib/features/inbox/presentation/widgets/conversation_list_pane.dart`  
  Verify: `flutter analyze lib/features/inbox` — no errors.

- [ ] **O2. Add status filter to `conversation_list_pane.dart`**  
  Add a horizontal scrollable row of `FilterChip` widgets below the search bar: All / Open / Resolved / Pending. Add `String _statusFilter = 'all'` state. Filter conversations by `conv.status` matching the selected filter.  
  Files: `lib/features/inbox/presentation/widgets/conversation_list_pane.dart`  
  Verify: `flutter analyze lib/features/inbox` — no errors.

- [ ] **O3. Add emoji picker to `composer.dart`**  
  Add a `bool _showEmojiPicker = false` state. Add a `SmileyFace` icon button (use `LucideIcons.smile`) in the composer toolbar that toggles `_showEmojiPicker`. When true, show a `Wrap` of 50 popular emoji `TextButton` widgets (matching the `POPULAR_EMOJIS` list from the web: 😀😃😄😁😆😅😂🤣😊😇 etc.) in a `Container` with white background + green border. Tapping an emoji appends it to the text controller and hides the picker.  
  Files: `lib/features/inbox/presentation/widgets/composer.dart`  
  Verify: `flutter analyze lib/features/inbox` — no errors.

---

## Implementation Order (by dependency)

All FEATs are independent of each other (no shared files between them). Recommended order by complexity and user-facing impact:

1. **FEAT-J** (Reports) — high visibility, self-contained screen rebuild
2. **FEAT-K** (Admin) — self-contained screen rebuild
3. **FEAT-A** (Contacts) — tab bar + table (most complex FEAT, multiple items)
4. **FEAT-B** (Automation) — stats grid + search
5. **FEAT-C** (Custom Fields) — edit/delete/toggles
6. **FEAT-D** (DND) — table refactor
7. **FEAT-E** (Flows) — table refactor + sync button
8. **FEAT-F** (Media) — upload view + table
9. **FEAT-G** (Templates) — search + sync + builder enhancements
10. **FEAT-H** (Campaigns) — search + delete
11. **FEAT-I** (Chatbot) — search + edit sheet
12. **FEAT-L** (Wallet) — two new cards
13. **FEAT-M** (Settings) — profile + password + team sections
14. **FEAT-N** (Template Library) — search + preview + filters
15. **FEAT-O** (Inbox) — search + filter + emoji picker

Items 17–20 (Apps, Business, Catalogue, SIM Card) are already correct as placeholder screens — no work needed.

---

## Navigation / Routing Check

The `app_router.dart` already registers ALL routes including admin, reports, inbox, template-library. The `more_drawer.dart` already has all nav items in the correct categories. **No changes needed to routing or navigation files.**

Routes confirmed present:
- `/admin` → `AdminScreen` ✅
- `/reports` → `ReportsScreen` ✅
- `/inbox` → `InboxScreen` ✅
- `/template-library` → `TemplateLibraryScreen` ✅
- `/apps`, `/business`, `/catalogue`, `/order-details`, `/sim-card` → `ModulePlaceholderScreen` ✅

---

## Files to Create (new)
- `lib/features/chatbot/presentation/widgets/edit_bot_flow_sheet.dart` (FEAT-I2)

## Files to Modify (existing)
- `lib/features/contacts/presentation/contacts_screen.dart` (FEAT-A)
- `lib/features/automation/presentation/automation_screen.dart` (FEAT-B)
- `lib/features/custom_fields/presentation/custom_fields_screen.dart` (FEAT-C)
- `lib/features/custom_fields/domain/custom_field.dart` (FEAT-C2, add fields)
- `lib/features/dnd/presentation/dnd_screen.dart` (FEAT-D)
- `lib/features/flows/presentation/flows_screen.dart` (FEAT-E)
- `lib/features/media/presentation/media_screen.dart` (FEAT-F)
- `lib/features/templates/presentation/templates_screen.dart` (FEAT-G1)
- `lib/features/templates/presentation/widgets/template_builder_sheet.dart` (FEAT-G2)
- `lib/features/campaigns/presentation/campaigns_screen.dart` (FEAT-H)
- `lib/features/chatbot/presentation/chatbot_screen.dart` (FEAT-I1, FEAT-I3)
- `lib/features/reports/presentation/reports_screen.dart` (FEAT-J)
- `lib/features/admin/presentation/admin_screen.dart` (FEAT-K)
- `lib/features/wallet/presentation/wallet_screen.dart` (FEAT-L)
- `lib/features/settings/presentation/settings_screen.dart` (FEAT-M)
- `lib/features/template_library/presentation/template_library_screen.dart` (FEAT-N)
- `lib/features/inbox/presentation/widgets/conversation_list_pane.dart` (FEAT-O1, FEAT-O2)
- `lib/features/inbox/presentation/widgets/composer.dart` (FEAT-O3)

## Files to NOT Modify
- `lib/features/navigation/presentation/widgets/premium_bottom_nav_bar.dart`
- `lib/features/navigation/presentation/app_scaffold.dart`
- `lib/features/navigation/presentation/more_drawer.dart`
- `lib/features/navigation/presentation/app_router.dart`
- `lib/core/theme/` (all files)
