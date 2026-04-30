import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/utils/avatar_utils.dart';
import 'package:mini_fiverr/utils/theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // No local state; the provider owns read status.

  @override
  Widget build(BuildContext context) {
    final DataProvider data = context.watch<DataProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(onPressed: () async => data.markAllNotificationsAsRead(), child: const Text('Mark all as read', style: TextStyle(color: Colors.white))),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: data.notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (BuildContext context, int index) {
          final n = data.notifications[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: n.isRead ? Colors.white : const Color(0xFFEFF6FF),
            child: ListTile(
              onTap: () async => data.markNotificationAsRead(n.id),
              leading: AvatarUtils.buildAvatar(name: n.title, imageUrl: '', radius: 18),
              title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(n.body),
              trailing: TextButton(
                onPressed: n.isRead ? null : () async => data.markNotificationAsRead(n.id),
                child: Text(n.isRead ? 'Read' : 'Mark as Read'),
              ),
            ),
          );
        },
      ),
    );
  }
}