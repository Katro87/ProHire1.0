import 'package:flutter/material.dart';
import 'package:mini_fiverr/utils/theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isProfessional;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isProfessional = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isProfessional ? const Color(0xFF023047) : Colors.white;
    final selectedColor = isProfessional ? const Color(0xFFFFB703) : const Color(0xFF1DBF73);
    final unselectedColor = isProfessional ? Colors.white54 : AppColors.textSecondary;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      items: isProfessional
          ? const [
              BottomNavigationBarItem(
                icon: Tooltip(message: 'Your Dashboard', child: Icon(Icons.dashboard_outlined)),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Tooltip(message: 'Incoming Job Requests', child: Icon(Icons.assignment_outlined)),
                activeIcon: Icon(Icons.assignment),
                label: 'Requests',
              ),
              BottomNavigationBarItem(
                icon: Tooltip(message: 'Client Messages', child: Icon(Icons.message_outlined)),
                activeIcon: Icon(Icons.message),
                label: 'Inbox',
              ),
              BottomNavigationBarItem(
                icon: Tooltip(message: 'Professional Profile', child: Icon(Icons.badge_outlined)),
                activeIcon: Icon(Icons.badge),
                label: 'My Card',
              ),
            ]
          : const [
              BottomNavigationBarItem(
                icon: Tooltip(message: 'Browse Professionals', child: Icon(Icons.search)),
                activeIcon: Icon(Icons.search, size: 30),
                label: 'Find Talent',
              ),
              BottomNavigationBarItem(
                icon: Tooltip(message: 'Your Active Jobs', child: Icon(Icons.work_outline)),
                activeIcon: Icon(Icons.work, size: 30),
                label: 'My Jobs',
              ),
              BottomNavigationBarItem(
                icon: Tooltip(message: 'Chat with Professionals', child: Icon(Icons.chat_bubble_outline)),
                activeIcon: Icon(Icons.chat_bubble, size: 30),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: Tooltip(message: 'Your Profile', child: Icon(Icons.person_outline)),
                activeIcon: Icon(Icons.person, size: 30),
                label: 'Profile',
              ),
            ],
    );
  }
}
