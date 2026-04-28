import 'package:flutter/material.dart';
import 'package:mini_fiverr/utils/theme.dart';
import 'package:mini_fiverr/widgets/nav_item.dart';

class ProfessionalNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ProfessionalNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavItem(
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
                tooltip: 'Your Dashboard',
              ),
              NavItem(
                icon: Icons.assignment_rounded,
                label: 'Requests',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
                tooltip: 'Job Requests',
                badge: 3,
              ),
              const SizedBox(width: 20), // space for FAB
              NavItem(
                icon: Icons.message_rounded,
                label: 'Inbox',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
                tooltip: 'Client Messages',
              ),
              NavItem(
                icon: Icons.badge_rounded,
                label: 'My Card',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
                tooltip: 'Your Professional Card',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
