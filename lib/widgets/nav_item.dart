import 'package:flutter/material.dart';
import 'package:mini_fiverr/utils/theme.dart';

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final String? tooltip;
  final int? badge;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.tooltip,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 26,
                    color: isActive ? AppColors.primary : AppColors.textSecondary,
                  ),
                  if (badge != null && badge! > 0)
                    Positioned(
                      right: -10,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          boxShadow: [AppShadows.softShadow],
                        ),
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                  fontFamily: 'Poppins',
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
