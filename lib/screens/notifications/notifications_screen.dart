import 'package:flutter/material.dart';
import 'package:mini_fiverr/utils/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Job accepted', 'Alice accepted your request.', '2m ago'),
      ('New message', 'Marcus sent you an update.', '18m ago'),
      ('Payment received', 'Your wallet was credited.', '2h ago'),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.notifications)),
              title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item.$2),
              trailing: Text(item.$3, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ),
          );
        },
      ),
    );
  }
}