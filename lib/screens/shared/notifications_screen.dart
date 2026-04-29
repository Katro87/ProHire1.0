import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/providers/data_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: <Widget>[
          TextButton(onPressed: data.markAllNotificationsAsRead, child: const Text('Mark All Read')),
        ],
      ),
      body: ListView.builder(
        itemCount: data.notifications.length,
        itemBuilder: (_, int i) {
          final n = data.notifications[i];
          return ListTile(
            leading: n.isRead ? const Icon(Icons.notifications_none) : const Icon(Icons.notifications_active, color: Color(0xFF6C5CE7)),
            title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.w500 : FontWeight.bold)),
            subtitle: Text('${n.body}\n${DateFormat.yMMMd().add_jm().format(n.timestamp)}'),
            isThreeLine: true,
            onTap: () => data.markNotificationAsRead(n.id),
          );
        },
      ),
    );
  }
}
