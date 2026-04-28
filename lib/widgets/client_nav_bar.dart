import 'package:flutter/material.dart';
import 'package:mini_fiverr/utils/theme.dart';
import 'package:mini_fiverr/widgets/nav_item.dart';

class ClientNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ClientNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x4D6C63FF),
            blurRadius: 30,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavItem(
                icon: Icons.explore_rounded,
                label: 'Explore',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
                tooltip: 'Find Professionals',
              ),
              NavItem(
                icon: Icons.work_history_rounded,
                label: 'My Jobs',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
                tooltip: 'Your Active Jobs',
              ),
              NavItem(
                icon: Icons.chat_bubble_rounded,
                label: 'Messages',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
                tooltip: 'Chat with Professionals',
              ),
              NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
                tooltip: 'Your Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
