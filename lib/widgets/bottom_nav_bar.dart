import 'package:flutter/material.dart';
import 'package:mini_fiverr/utils/theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      items: [
        BottomNavigationBarItem(
          icon: const Tooltip(message: 'Browse Professionals', child: Icon(Icons.explore)),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: const Tooltip(message: 'Your Jobs & Requests', child: Icon(Icons.work_history)),
          label: 'Activity',
        ),
        BottomNavigationBarItem(
          icon: const Tooltip(message: 'Chat with Users', child: Icon(Icons.chat_bubble_outline)),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: const Tooltip(message: 'Your Profile', child: Icon(Icons.account_circle)),
          label: 'Profile',
        ),
      ],
    );
  }
}
