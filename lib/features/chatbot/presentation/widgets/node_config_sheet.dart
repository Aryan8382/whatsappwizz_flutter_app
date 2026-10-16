import 'package:flutter/material.dart';
import '../../../../shared/widgets/modal_sheet.dart';
import '../../domain/bot_node.dart';

class NodeConfigSheet extends StatefulWidget {
  final BotNode node;
  final ValueChanged<BotNode> onSave;

  const NodeConfigSheet({
    super.key,
    required this.node,
    required this.onSave,
  });

  static void show(
    BuildContext context, {
    required BotNode node,
    required ValueChanged<BotNode> onSave,
  }) {
    ModalSheet.show(
      context: context,
      title: 'Configure Node',
      subtitle: '${node.type.label} settings',
      child: NodeConfigSheet(node: node, onSave: onSave),
    );
  }

  @override
  State<NodeConfigSheet> createState() => _NodeConfigSheetState();
}

class _NodeConfigSheetState extends State<NodeConfigSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late BotNodeType _type;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.node.title);
    _contentController = TextEditingController(text: widget.node.content);
    _type = widget.node.type;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final updated = widget.node.copyWith(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      type: _type,
    );
    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<BotNodeType>(
          value: _type,
          decoration: const InputDecoration(labelText: 'Node Type'),
          items: BotNodeType.values.map((t) {
            return DropdownMenuItem(
              value: t,
              child: Row(
                children: [
                  Icon(t.icon, size: 16, color: t.color),
                  const SizedBox(width: 8),
                  Text(t.label),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _type = val);
          },
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Node Title'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _contentController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Message Body / Instructions'),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: const Text('Save Node Changes'),
        ),
      ],
    );
  }
}
