import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/providers/chat_provider.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/widgets/auto_reply_chips.dart';
import 'package:mini_fiverr/widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _input = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().markConversationAsRead(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final chat = context.watch<ChatProvider>();
    final convo = data.conversations.firstWhere((c) => c.id == widget.conversationId);

    return Scaffold(
      appBar: AppBar(title: Text(convo.otherUserName)),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12),
              itemCount: convo.messages.length + (chat.isTyping ? 1 : 0),
              itemBuilder: (_, int i) {
                if (chat.isTyping && i == convo.messages.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 45,
                        child: LinearProgressIndicator(minHeight: 4),
                      ),
                    ),
                  );
                }
                return MessageBubble(message: convo.messages[i]);
              },
            ),
          ),
          AutoReplyChips(onTap: (String text) => _send(text)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _input,
                    onSubmitted: (String value) => _send(value),
                    decoration: const InputDecoration(hintText: 'Write a message...'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _input.text.trim().isEmpty ? null : () => _send(_input.text),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send(String text) async {
    final String value = text.trim();
    if (value.isEmpty) {
      return;
    }
    _input.clear();
    setState(() {});
    await context.read<ChatProvider>().sendAndSimulate(
          data: context.read<DataProvider>(),
          conversationId: widget.conversationId,
          message: value,
        );
    if (mounted) {
      context.read<DataProvider>().markConversationAsRead(widget.conversationId);
    }
  }
}
