import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/models/chat_model.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/screens/shared/chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final List<ConversationModel> list = data.conversations
        .where((ConversationModel c) => c.otherUserName.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (String value) => setState(() => _query = value),
            decoration: const InputDecoration(hintText: 'Search conversations', prefixIcon: Icon(Icons.search)),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () async => data.markAllConversationsAsRead(),
            child: const Text('Mark All Read'),
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('No messages yet. Find talent and start a conversation!'))
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, int i) {
                    final c = list[i];
                    return ListTile(
                      leading: CircleAvatar(child: Text(c.otherUserName.substring(0, 1).toUpperCase())),
                      title: Text(c.otherUserName, style: TextStyle(fontWeight: c.hasUnread ? FontWeight.bold : FontWeight.w500)),
                      subtitle: Text(c.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(DateFormat.jm().format(c.lastMessageTime), style: const TextStyle(fontSize: 10)),
                          if (c.hasUnread) const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: CircleAvatar(radius: 4, backgroundColor: Color(0xFF6C5CE7)),
                          ),
                          TextButton(
                            onPressed: c.hasUnread ? () async => data.markConversationAsRead(c.id) : null,
                            child: const Text('Mark as Read'),
                          ),
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(builder: (_) => ChatScreen(conversationId: c.id)),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
