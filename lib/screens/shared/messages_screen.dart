import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/models/chat_model.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/screens/shared/chat_screen.dart';
import 'package:mini_fiverr/utils/theme.dart';

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
            decoration: const InputDecoration(
              hintText: 'Search conversations', 
              prefixIcon: Icon(Icons.search),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () async => data.markAllConversationsAsRead(),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Text('Mark All Read', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('No messages yet.'))
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, int i) {
                    final c = list[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: Text(c.otherUserName.substring(0, 1).toUpperCase(), 
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(c.otherUserName, 
                        style: TextStyle(fontWeight: c.hasUnread ? FontWeight.bold : FontWeight.w500)),
                      subtitle: Text(c.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min, // Fixes Bottom Overflow
                        children: <Widget>[
                          Text(DateFormat.jm().format(c.lastMessageTime), 
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          const SizedBox(height: 4),
                          if (c.hasUnread) 
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () async => data.markConversationAsRead(c.id),
                                  child: const Text('Mark as Read', 
                                    style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                ),
                              ],
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
