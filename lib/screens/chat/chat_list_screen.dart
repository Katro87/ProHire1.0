import 'package:flutter/material.dart';
import 'package:mini_fiverr/utils/theme.dart';
import 'package:mini_fiverr/screens/chat/chat_room_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Messages')),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 4,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 80),
        itemBuilder: (context, index) {
          return _buildChatTile(context, index);
        },
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, int index) {
    final names = ['Alice Johnson', 'Marcus Chen', 'Sarah Williams', 'John Smith'];
    final msgs = [
      'Job accepted! Let\'s discuss details.',
      'Can you provide the Figma files?',
      'The deadline works for me.',
      'Just sent the payment check.'
    ];

    return ListTile(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoomScreen(userName: names[index], userPic: 'https://i.pravatar.cc/100?u=$index'))),
      leading: CircleAvatar(radius: 28, backgroundImage: NetworkImage('https://i.pravatar.cc/100?u=$index')),
      title: Text(names[index], style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(msgs[index], maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('2m ago', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          if (index == 0) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
        ],
      ),
    );
  }
}
