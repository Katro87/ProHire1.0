import 'package:flutter/material.dart';
import 'package:mini_fiverr/utils/avatar_utils.dart';
import 'package:mini_fiverr/utils/theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _items = [
    {'title': 'Job accepted', 'body': 'Alice accepted your request.', 'time': '2m ago', 'read': false, 'name': 'Alice Johnson'},
    {'title': 'New message', 'body': 'Marcus sent you an update.', 'time': '18m ago', 'read': false, 'name': 'Marcus Chen'},
    {'title': 'Payment received', 'body': 'Your wallet was credited.', 'time': '2h ago', 'read': true, 'name': 'Wallet'},
  ];

  void _markAllRead() {
    setState(() {
      for (final item in _items) {
        item['read'] = true;
      }
    });
  }

  void _markOneRead(int index) {
    setState(() {
      _items[index]['read'] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(onPressed: _markAllRead, child: const Text('Mark all as read', style: TextStyle(color: Colors.white))),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: item['read'] == true ? Colors.white : const Color(0xFFEFF6FF),
            child: ListTile(
              onTap: () => _markOneRead(index),
              leading: AvatarUtils.buildAvatar(name: item['name'] as String, imageUrl: '', radius: 18),
              title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['body'] as String),
              trailing: Text(item['time'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ),
          );
        },
      ),
    );
  }
}