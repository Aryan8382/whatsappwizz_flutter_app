import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/widgets/modal_sheet.dart';
import '../../domain/bot_node.dart';

class BotTestSheet extends StatefulWidget {
  final BotFlow flow;

  const BotTestSheet({super.key, required this.flow});

  static void show(BuildContext context, BotFlow flow) {
    ModalSheet.show(
      context: context,
      title: 'Test Bot Simulator',
      subtitle: flow.name,
      child: BotTestSheet(flow: flow),
    );
  }

  @override
  State<BotTestSheet> createState() => _BotTestSheetState();
}

class _BotTestSheetState extends State<BotTestSheet> {
  final List<Map<String, String>> _messages = [
    {'sender': 'bot', 'text': 'Hi! Welcome to our store. How can we help you today?'},
    {'sender': 'bot', 'text': 'Select an option: 1. Catalog, 2. Speak with Agent, 3. FAQs'},
  ];
  final _inputController = TextEditingController();

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _inputController.clear();
    });

    // Simulate bot response
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        if (text.toLowerCase().contains('catalog') || text == '1') {
          _messages.add({
            'sender': 'bot',
            'text': 'Browse our latest product collection and catalog.'
          });
        } else if (text.toLowerCase().contains('agent') || text == '2') {
          _messages.add({
            'sender': 'bot',
            'text': 'Connecting you to the next available agent queue...'
          });
        } else {
          _messages.add({
            'sender': 'bot',
            'text': 'Thanks for your reply! Our team will contact you shortly.'
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isUser = m['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.waLightGreen : const Color(0xFFF1F5F9),
                      borderRadius: AppRadii.borderXl,
                    ),
                    child: Text(
                      m['text']!,
                      style: const TextStyle(fontSize: 13.5),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      hintText: 'Type test reply...',
                      isDense: true,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(AppIcons.send, size: 18),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
