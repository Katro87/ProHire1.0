import 'package:flutter/foundation.dart';
import 'package:mini_fiverr/providers/data_provider.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider(this.dataProvider);

  final DataProvider dataProvider;

  int get unreadCount => dataProvider.unreadNotificationCount;

  void markAllRead() {
    dataProvider.markAllNotificationsAsRead();
    notifyListeners();
  }
}
