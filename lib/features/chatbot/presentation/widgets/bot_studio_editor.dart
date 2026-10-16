import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/bot_node.dart';
import '../../domain/chatbot_repository.dart';
import '../chatbot_screen.dart';

enum StudioTab { message, buttons, products, links, setup }

class BotStudioEditor extends ConsumerStatefulWidget {
  final BotFlow initialFlow;
  final ChatbotRepository repo;
  final VoidCallback onBack;

  const BotStudioEditor({
    super.key,
    required this.initialFlow,
    required this.repo,
    required this.onBack,
  });

  @override
  ConsumerState<BotStudioEditor> createState() => _BotStudioEditorState();
}

class _BotStudioEditorState extends ConsumerState<BotStudioEditor> {
  late BotFlow _flow;
  late BotEditForm _editForm;
  bool _loading = false;
  bool _saving = false;
  StudioTab _currentTab = StudioTab.message;
  int _mobileViewIndex = 0; // 0: Studio Edit, 1: WhatsApp Preview, 2: Flow Canvas

  // Add node form state
  String _newNodeType = 'message';
  final TextEditingController _newNodeTextCtrl = TextEditingController();

  // Connect nodes form state
  int _connSource = 0;
  int _connTarget = 0;

  @override
  void initState() {
    super.initState();
    _flow = widget.initialFlow;
    _editForm = BotEditForm.fromFlow(_flow);
    _loadFlowDetails();
  }

  @override
  void dispose() {
    _newNodeTextCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFlowDetails() async {
    setState(() => _loading = true);
    try {
      final detailed = await widget.repo.getFlowById(_flow.id.toString());
      if (detailed != null && mounted) {
        setState(() {
          _flow = detailed;
          _editForm = BotEditForm.fromFlow(detailed);
        });
      }
    } catch (_) {
      // Keep initial flow if fetch fails
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveChanges({bool publishAfter = false}) async {
    setState(() => _saving = true);
    try {
      final configMap = _editForm.toBotConfig();
      await widget.repo.updateBot(
        _flow.id.toString(),
        name: _editForm.project.trim().isNotEmpty ? _editForm.project.trim() : _flow.name,
        config: configMap,
      );

      // If published after
      if (publishAfter) {
        await widget.repo.togglePublish(_flow.id.toString(), true);
      }

      // Reload
      final refreshed = await widget.repo.getFlowById(_flow.id.toString());
      if (refreshed != null && mounted) {
        setState(() {
          _flow = refreshed;
          _editForm = BotEditForm.fromFlow(refreshed);
        });
      }
      ref.invalidate(chatbotFlowsProvider);

      if (publishAfter) {
        ToastService.success('"${_editForm.project}" published live! (Other bots set to draft)');
      } else {
        ToastService.success('Bot flow saved successfully');
      }
    } catch (e) {
      ToastService.error('Failed to save: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addNode() async {
    final text = _newNodeTextCtrl.text.trim();
    if (text.isEmpty) {
      ToastService.info('Please enter node message text');
      return;
    }
    try {
      await widget.repo.addNode(_flow.id.toString(), nodeType: _newNodeType, text: text);
      _newNodeTextCtrl.clear();
      await _loadFlowDetails();
      ToastService.success('Node added');
    } catch (e) {
      ToastService.error('Failed to add node: $e');
    }
  }

  Future<void> _deleteNode(String nodeId) async {
    try {
      await widget.repo.deleteNode(_flow.id.toString(), nodeId);
      await _loadFlowDetails();
      ToastService.info('Node removed');
    } catch (e) {
      ToastService.error('Failed to remove node: $e');
    }
  }

  Future<void> _addConnection() async {
    if (_connSource == 0 || _connTarget == 0) {
      ToastService.info('Select both source and target nodes');
      return;
    }
    if (_connSource == _connTarget) {
      ToastService.info('Source and target must be different nodes');
      return;
    }
    try {
      await widget.repo.addConnection(
        _flow.id.toString(),
        sourceNode: _connSource,
        targetNode: _connTarget,
      );
      _connSource = 0;
      _connTarget = 0;
      await _loadFlowDetails();
      ToastService.success('Nodes connected');
    } catch (e) {
      ToastService.error('Failed to connect: $e');
    }
  }

  Future<void> _deleteConnection(int source, int target) async {
    try {
      await widget.repo.deleteConnection(_flow.id.toString(), sourceNode: source, targetNode: target);
      await _loadFlowDetails();
      ToastService.info('Connection removed');
    } catch (e) {
      ToastService.error('Failed to disconnect: $e');
    }
  }

  void _showPreviewDialog() async {
    try {
      final res = await widget.repo.getPreview(_flow.id.toString());
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(LucideIcons.eye, size: 18, color: Color(0xFF16A34A)),
              const SizedBox(width: 8),
              Expanded(child: Text('Flow Preview: ${_flow.name}', style: const TextStyle(fontSize: 15))),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: res != null && res['preview'] is List
                ? ListView.separated(
                    shrinkWrap: true,
                    itemCount: (res['preview'] as List).length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final p = res['preview'][i];
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['nodeType']?.toString().toUpperCase() ?? 'NODE',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                            ),
                            const SizedBox(height: 4),
                            Text(p['text']?.toString() ?? '', style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      );
                    },
                  )
                : const Text('No message previews available. Ensure nodes have message text.', style: TextStyle(fontSize: 13)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ToastService.error('Preview error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: widget.onBack,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                _editForm.project.isNotEmpty ? _editForm.project : _flow.name,
                style: AppTypography.titleMedium.copyWith(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(
              status: _flow.isPublished ? 'active' : 'draft',
              label: _flow.isPublished ? 'Live' : 'Draft',
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Preview Flow',
            icon: const Icon(LucideIcons.eye, size: 20, color: AppColors.textSecondary),
            onPressed: _showPreviewDialog,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: OutlinedButton.icon(
              onPressed: _saving ? null : () => _saveChanges(),
              icon: _saving
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(LucideIcons.save, size: 15),
              label: Text(_saving ? 'Saving...' : 'Save', style: const TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF16A34A),
                side: const BorderSide(color: Color(0xFF22C55E)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8, right: 12),
            child: ElevatedButton.icon(
              onPressed: _saving ? null : () => _saveChanges(publishAfter: true),
              icon: const Icon(LucideIcons.play, size: 14),
              label: const Text('Publish', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : isDesktop
              ? _buildDesktopStudio()
              : _buildMobileStudio(),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Desktop Layout (3-Column Studio matching website code)
  // ══════════════════════════════════════════════════════════════════
  Widget _buildDesktopStudio() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Column 1: Visual Flow Nodes Canvas (flex 5)
        Expanded(
          flex: 5,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
              color: Colors.white,
            ),
            child: Column(
              children: [
                _buildAddNodeToolbar(),
                Expanded(child: _buildFlowNodesList()),
              ],
            ),
          ),
        ),

        // Column 2: WhatsApp Live Phone Simulator (320px)
        SizedBox(
          width: 320,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
              color: Color(0xFFF1F5F9),
            ),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: SingleChildScrollView(
                child: _buildWhatsAppPhoneSimulator(),
              ),
            ),
          ),
        ),

        // Column 3: Inspector Panel (flex 5)
        Expanded(
          flex: 5,
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildInspectorTabBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildInspectorContent(),
                  ),
                ),
                _buildSaveFooter(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Mobile Layout (Tabbed Studio with persistent switcher)
  // ══════════════════════════════════════════════════════════════════
  Widget _buildMobileStudio() {
    return Column(
      children: [
        // Segmented Mode Switcher
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.white,
          child: Row(
            children: [
              _mobileSegmentButton(0, 'Edit Bot', LucideIcons.sliders),
              const SizedBox(width: 6),
              _mobileSegmentButton(1, 'Preview', LucideIcons.smartphone),
              const SizedBox(width: 6),
              _mobileSegmentButton(2, 'Flow Canvas', LucideIcons.gitFork),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        Expanded(
          child: IndexedStack(
            index: _mobileViewIndex,
            children: [
              // 0: Studio Edit (Inspector Tabs + Form)
              Column(
                children: [
                  _buildInspectorTabBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildInspectorContent(),
                    ),
                  ),
                  _buildSaveFooter(),
                ],
              ),

              // 1: Live Phone Simulator Preview
              Container(
                color: const Color(0xFFE2E8F0),
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: SingleChildScrollView(
                    child: _buildWhatsAppPhoneSimulator(),
                  ),
                ),
              ),

              // 2: Flow Canvas with Add Node bar
              Column(
                children: [
                  _buildAddNodeToolbar(),
                  Expanded(child: _buildFlowNodesList()),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mobileSegmentButton(int index, String label, IconData icon) {
    final active = _mobileViewIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _mobileViewIndex = index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? const Color(0xFF22C55E) : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: active ? const Color(0xFF15803D) : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.bold : FontWeight.w500,
                  color: active ? const Color(0xFF15803D) : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Toolbar: Add Node (Message / Question)
  // ══════════════════════════════════════════════════════════════════
  Widget _buildAddNodeToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF0FDF4),
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          // Node type toggle
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0x3322C55E)),
            ),
            child: Row(
              children: [
                _nodeTypeChip('message', 'Message', LucideIcons.messageSquare),
                _nodeTypeChip('question', 'Question', LucideIcons.helpCircle),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _newNodeTextCtrl,
              decoration: InputDecoration(
                hintText: 'Node message text…',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
              ),
              style: const TextStyle(fontSize: 12),
              onSubmitted: (_) => _addNode(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _addNode,
            icon: const Icon(LucideIcons.plus, size: 14),
            label: const Text('Add Node', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nodeTypeChip(String type, String label, IconData icon) {
    final active = _newNodeType == type;
    return InkWell(
      onTap: () => setState(() => _newNodeType = type),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFDCFCE7) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: active ? const Color(0xFF15803D) : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: active ? const Color(0xFF15803D) : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Visual Connected Nodes List
  // ══════════════════════════════════════════════════════════════════
  Widget _buildFlowNodesList() {
    final nodes = _flow.nodes;
    if (nodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.gitFork, size: 36, color: Color(0xFF94A3B8)),
            const SizedBox(height: 10),
            const Text('No nodes configured yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
            const SizedBox(height: 4),
            const Text('Add your first message node above to automate conversations.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: nodes.length,
      itemBuilder: (context, i) {
        final node = nodes[i];
        final isLast = i == nodes.length - 1;
        final outConnections = _flow.connections.where((c) => c.sourceNode.toString() == node.id.toString()).length;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vertical Timeline Spine
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: node.type.color, width: 2),
                        boxShadow: [
                          BoxShadow(color: node.type.color.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Icon(node.type.icon, size: 13, color: node.type.color),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Node Card
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: node.type.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              node.type.label.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: node.type.color,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '#${node.id}',
                                style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.textMuted),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(LucideIcons.trash2, size: 13, color: Color(0xFF94A3B8)),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                onPressed: () => _deleteNode(node.id.toString()),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        node.content.isNotEmpty ? node.content : (node.name ?? 'Node #${node.id}'),
                        style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$outConnections outbound connection${outConnections == 1 ? '' : 's'}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Live WhatsApp Phone Simulator (matching website code)
  // ══════════════════════════════════════════════════════════════════
  Widget _buildWhatsAppPhoneSimulator() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEAE2),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
        boxShadow: const [
          BoxShadow(color: Color(0x1F0A1F14), blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // WhatsApp Top App Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: const Color(0xFF008069),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.white24,
                  child: Text(
                    (_editForm.project.isNotEmpty ? _editForm.project[0] : 'B').toUpperCase(),
                    style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _editForm.project.isNotEmpty ? _editForm.project : 'Chatbot',
                        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text('online', style: TextStyle(fontSize: 9.5, color: Color(0xFFD1FAE5))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Chat Bubble Area
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Outgoing Bot Message Bubble
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(2),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 3, offset: const Offset(0, 1)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Media (if image)
                      if (_editForm.headerType != 'None' && _editForm.headerMediaUrl.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade200,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            _editForm.headerMediaUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text('${_editForm.headerType} preview', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ),
                          ),
                        ),

                      // Message Body
                      Text(
                        _editForm.body.isNotEmpty ? _editForm.body : 'Hi! How can I help you today?',
                        style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF111B21)),
                      ),

                      // Footer
                      if (_editForm.footer.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          _editForm.footer,
                          style: TextStyle(fontSize: 9.5, color: Colors.grey.shade600),
                        ),
                      ],

                      // Time + Double Check
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('12:45 PM', style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
                          const SizedBox(width: 4),
                          const Icon(LucideIcons.checkCheck, size: 12, color: Color(0xFF53BDEB)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Interactive Buttons
                const SizedBox(height: 8),
                ..._editForm.buttons.take(3).map(
                  (btn) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0x33008069)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 2, offset: const Offset(0, 1)),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      btn.text.isNotEmpty ? btn.text : 'Interactive Button',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF008069),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Phone Dummy Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: const Color(0xFFF0F2F5),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Text('Type a message…', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 6),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF008069),
                  child: const Icon(LucideIcons.send, size: 12, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Inspector Tabs Navigation
  // ══════════════════════════════════════════════════════════════════
  Widget _buildInspectorTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _inspectorTabItem(StudioTab.message, 'Message', LucideIcons.messageSquare),
          _inspectorTabItem(StudioTab.buttons, 'Buttons', LucideIcons.mousePointerClick),
          _inspectorTabItem(StudioTab.products, 'Products', LucideIcons.tag),
          _inspectorTabItem(StudioTab.links, 'Links', LucideIcons.gitFork),
          _inspectorTabItem(StudioTab.setup, 'Setup', LucideIcons.settings),
        ],
      ),
    );
  }

  Widget _inspectorTabItem(StudioTab tab, String label, IconData icon) {
    final active = _currentTab == tab;
    return InkWell(
      onTap: () => setState(() => _currentTab = tab),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFDCFCE7) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: active ? const Color(0xFF15803D) : AppColors.textSecondary),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: active ? const Color(0xFF15803D) : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Inspector Tab Content
  // ══════════════════════════════════════════════════════════════════
  Widget _buildInspectorContent() {
    switch (_currentTab) {
      case StudioTab.message:
        return _buildMessageTab();
      case StudioTab.buttons:
        return _buildButtonsTab();
      case StudioTab.products:
        return _buildProductsTab();
      case StudioTab.links:
        return _buildLinksTab();
      case StudioTab.setup:
        return _buildSetupTab();
    }
  }

  // ── Tab 1: Message ──
  Widget _buildMessageTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Message Body *'),
        TextFormField(
          initialValue: _editForm.body,
          maxLines: 4,
          decoration: _inputDecoration('Enter the primary message your bot sends…'),
          style: const TextStyle(fontSize: 13),
          onChanged: (val) => setState(() => _editForm.body = val),
        ),
        const SizedBox(height: 16),

        _fieldLabel('Header Type'),
        Row(
          children: ['None', 'Image', 'Video', 'Document'].map((t) {
            final active = _editForm.headerType == t;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: ChoiceChip(
                  label: Text(t, style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
                  selected: active,
                  selectedColor: const Color(0xFFDCFCE7),
                  onSelected: (_) => setState(() => _editForm.headerType = t),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        if (_editForm.headerType != 'None') ...[
          _fieldLabel('${_editForm.headerType} Media URL *'),
          TextFormField(
            initialValue: _editForm.headerMediaUrl,
            decoration: _inputDecoration('https://example.com/media.jpg'),
            style: const TextStyle(fontSize: 12),
            onChanged: (val) => setState(() => _editForm.headerMediaUrl = val),
          ),
          const SizedBox(height: 16),
        ],

        _fieldLabel('Footer Text'),
        TextFormField(
          initialValue: _editForm.footer,
          decoration: _inputDecoration('e.g. Reply STOP to opt out'),
          style: const TextStyle(fontSize: 12),
          onChanged: (val) => setState(() => _editForm.footer = val),
        ),
      ],
    );
  }

  // ── Tab 2: Buttons ──
  Widget _buildButtonsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Up to 3 quick action buttons', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            OutlinedButton.icon(
              onPressed: _editForm.buttons.length >= 3
                  ? null
                  : () {
                      setState(() {
                        _editForm.buttons.add(
                          BotButtonForm(id: 'btn_${DateTime.now().millisecondsSinceEpoch}', type: 'QUICK_REPLY', text: ''),
                        );
                      });
                    },
              icon: const Icon(LucideIcons.plus, size: 13),
              label: const Text('Add Button', style: TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_editForm.buttons.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text('No buttons added yet. Click "+ Add Button" above.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ),

        ..._editForm.buttons.asMap().entries.map((entry) {
          final index = entry.key;
          final btn = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('BUTTON ${index + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.red),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => setState(() => _editForm.buttons.removeAt(index)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: btn.type,
                  isDense: true,
                  decoration: _inputDecoration('Type'),
                  items: const [
                    DropdownMenuItem(value: 'QUICK_REPLY', child: Text('Quick reply', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'URL', child: Text('Website URL', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'PHONE_NUMBER', child: Text('Call Phone', style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'LOCATION', child: Text('Location', style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => btn.type = val);
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: btn.text,
                  decoration: _inputDecoration('Button Label (e.g. View Catalog)'),
                  style: const TextStyle(fontSize: 12),
                  onChanged: (val) => btn.text = val,
                ),
                if (btn.type != 'QUICK_REPLY') ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: btn.value,
                    decoration: _inputDecoration(
                      btn.type == 'URL'
                          ? 'https://example.com'
                          : btn.type == 'PHONE_NUMBER'
                              ? '+919999999999'
                              : 'https://maps.google.com/?q=lat,lng',
                    ),
                    style: const TextStyle(fontSize: 12),
                    onChanged: (val) => btn.value = val,
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── Tab 3: Products ──
  Widget _buildProductsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Keywords trigger product cards', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _editForm.products.add(
                    BotProductForm(
                      id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
                      name: 'New Product',
                      keywords: 'item, buy',
                      images: ['https://images.pexels.com/photos/265906/pexels-photo-265906.jpeg?w=400&h=400&fit=crop'],
                      price: 999,
                    ),
                  );
                });
              },
              icon: const Icon(LucideIcons.plus, size: 13),
              label: const Text('Add Product', style: TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_editForm.products.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text('No products configured. Click "+ Add Product" to add automated catalog items.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ),

        ..._editForm.products.asMap().entries.map((entry) {
          final index = entry.key;
          final prod = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('PRODUCT ${index + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.red),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => setState(() => _editForm.products.removeAt(index)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextFormField(
                  initialValue: prod.name,
                  decoration: _inputDecoration('Product Name'),
                  style: const TextStyle(fontSize: 12),
                  onChanged: (val) => prod.name = val,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: prod.keywords,
                  decoration: _inputDecoration('Trigger keywords (e.g. shoes, sneaker)'),
                  style: const TextStyle(fontSize: 12),
                  onChanged: (val) => prod.keywords = val,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: prod.price?.toString() ?? '',
                  decoration: _inputDecoration('Price (e.g. 999)'),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 12),
                  onChanged: (val) => prod.price = double.tryParse(val),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('${prod.images.length} image(s)', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          prod.images.add('https://images.pexels.com/photos/265906/pexels-photo-265906.jpeg?w=400&h=400&fit=crop');
                        });
                      },
                      icon: const Icon(LucideIcons.image, size: 13),
                      label: const Text('+ Image URL', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
                ...prod.images.asMap().entries.map((imgEntry) {
                  final imgIdx = imgEntry.key;
                  final imgUrl = imgEntry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            imgUrl,
                            width: 28,
                            height: 28,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(width: 28, height: 28, color: Colors.grey.shade300),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: imgUrl,
                            decoration: _inputDecoration('Image URL'),
                            style: const TextStyle(fontSize: 11),
                            onChanged: (val) => prod.images[imgIdx] = val,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.x, size: 14),
                          onPressed: () => setState(() => prod.images.removeAt(imgIdx)),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── Tab 4: Links ──
  Widget _buildLinksTab() {
    final conns = _flow.connections;
    final nodes = _flow.nodes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Active Node Connections (${conns.length})'),
        if (conns.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text('No connections yet. Connect nodes below.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ),

        ...conns.map((c) {
          final sId = int.tryParse(c.sourceNode.toString()) ?? 0;
          final tId = int.tryParse(c.targetNode.toString()) ?? 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0x2622C55E), borderRadius: BorderRadius.circular(8)),
                  child: Text('Node #${c.sourceNode}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(LucideIcons.arrowRight, size: 14, color: AppColors.textMuted),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0x2622C55E), borderRadius: BorderRadius.circular(8)),
                  child: Text('Node #${c.targetNode}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.red),
                  onPressed: () => _deleteConnection(sId, tId),
                ),
              ],
            ),
          );
        }),

        const Divider(height: 28),
        _fieldLabel('Connect Nodes'),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _connSource == 0 ? null : _connSource,
                hint: const Text('Source Node', style: TextStyle(fontSize: 11)),
                decoration: _inputDecoration('From'),
                items: nodes.map((n) {
                  final idNum = int.tryParse(n.id.toString()) ?? 0;
                  return DropdownMenuItem<int>(
                    value: idNum,
                    child: Text('#${n.id} (${n.type.label})', style: const TextStyle(fontSize: 11)),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _connSource = val ?? 0),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _connTarget == 0 ? null : _connTarget,
                hint: const Text('Target Node', style: TextStyle(fontSize: 11)),
                decoration: _inputDecoration('To'),
                items: nodes.map((n) {
                  final idNum = int.tryParse(n.id.toString()) ?? 0;
                  return DropdownMenuItem<int>(
                    value: idNum,
                    child: Text('#${n.id} (${n.type.label})', style: const TextStyle(fontSize: 11)),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _connTarget = val ?? 0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addConnection,
            icon: const Icon(LucideIcons.link, size: 14),
            label: const Text('Connect Nodes', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              foregroundColor: const Color(0xFF16A34A),
              side: const BorderSide(color: Color(0xFF22C55E)),
            ),
          ),
        ),
      ],
    );
  }

  // ── Tab 5: Setup ──
  Widget _buildSetupTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Flow Name *'),
        TextFormField(
          initialValue: _editForm.project,
          decoration: _inputDecoration('Flow Name'),
          style: const TextStyle(fontSize: 13),
          onChanged: (val) => setState(() => _editForm.project = val),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _flow.isPublished ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _flow.isPublished ? const Color(0xFF86EFAC) : const Color(0xFFCBD5E1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusBadge(
                status: _flow.isPublished ? 'active' : 'draft',
                label: _flow.isPublished ? 'Live in WhatsApp (Active Bot)' : 'Draft — not active',
              ),
              const SizedBox(height: 8),
              Text(
                _flow.isPublished
                    ? 'This bot is actively handling incoming messages for your organization.'
                    : 'Publishing this flow will make it the single active bot, automatically putting any other active bot into draft.',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        _fieldLabel('How It Works'),
        _ruleBullet('hi / hello → Triggers welcome greeting message and interactive buttons.'),
        _ruleBullet('Keywords match → Automated product cards with images, prices, and links.'),
        _ruleBullet('Single Published Bot → Only 1 bot handles customer conversations at a time.'),
        _ruleBullet('Draft Bots → Safely edit and configure without affecting live conversations.'),
      ],
    );
  }

  Widget _ruleBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4))),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // Footer Save Action
  // ══════════════════════════════════════════════════════════════════
  Widget _buildSaveFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _saving ? null : () => _saveChanges(),
              icon: const Icon(LucideIcons.save, size: 14),
              label: Text(_saving ? 'Saving...' : 'Save changes', style: const TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                foregroundColor: const Color(0xFF16A34A),
                side: const BorderSide(color: Color(0xFF22C55E)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _saving ? null : () => _saveChanges(publishAfter: true),
              icon: const Icon(LucideIcons.play, size: 14),
              label: const Text('Publish Live', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF22C55E), width: 1.5),
      ),
    );
  }
}
