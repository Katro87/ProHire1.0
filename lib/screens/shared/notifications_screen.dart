import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/utils/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: <Widget>[
          TextButton(
            onPressed: () async => data.markAllNotificationsAsRead(),
            child: const Text('Mark All Read', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: data.notifications.isEmpty
          ? const Center(child: Text('No notifications yet', style: TextStyle(color: AppColors.textSecondary)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: data.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, int i) {
                final n = data.notifications[i];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: n.isRead ? Colors.transparent : AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: n.isRead ? AppColors.textMuted.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                      child: Icon(
                        n.isRead ? Icons.notifications_none : Icons.notifications_active,
                        color: n.isRead ? AppColors.textMuted : AppColors.primary,
                      ),
                    ),
                    title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.w500 : FontWeight.bold, color: Colors.white)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${n.body}\n${DateFormat.yMMMd().add_jm().format(n.timestamp)}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                    isThreeLine: true,
                    trailing: n.isRead
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.check_circle_outline, color: AppColors.primary),
                            onPressed: () async => data.markNotificationAsRead(n.id),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
