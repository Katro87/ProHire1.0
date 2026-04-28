import 'package:flutter/material.dart';
import 'package:mini_fiverr/utils/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String profilePicUrl;
  final VoidCallback onProfileTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onWalletTap;
  final int notificationCount;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.profilePicUrl,
    required this.onProfileTap,
    this.onNotificationsTap,
    this.onWalletTap,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: GestureDetector(
          onTap: onProfileTap,
          child: CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(profilePicUrl),
          ),
        ),
      ),
      title: Text(title),
      actions: [
        if (onNotificationsTap != null)
          Tooltip(
            message: 'Notifications',
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: onNotificationsTap,
                ),
                if (notificationCount > 0)
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(6)),
                      constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                      child: Text('$notificationCount', style: const TextStyle(color: Colors.white, fontSize: 8), textAlign: TextAlign.center),
                    ),
                  ),
              ],
            ),
          ),
        if (onWalletTap != null)
          Tooltip(
            message: 'Wallet Balance',
            child: IconButton(
              icon: const Icon(Icons.wallet),
              onPressed: onWalletTap,
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
