import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/models/user_model.dart';
import 'package:mini_fiverr/providers/auth_provider.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/screens/client/client_home_screen.dart';
import 'package:mini_fiverr/screens/client/favorites_screen.dart';
import 'package:mini_fiverr/screens/client/find_talent_screen.dart';
import 'package:mini_fiverr/screens/professional/job_requests_screen.dart';
import 'package:mini_fiverr/screens/professional/professional_home_screen.dart';
import 'package:mini_fiverr/screens/profile/profile_screen.dart';
import 'package:mini_fiverr/screens/profile/create_professional_card.dart';
import 'package:mini_fiverr/screens/shared/messages_screen.dart';
import 'package:mini_fiverr/screens/shared/notifications_screen.dart';
import 'package:mini_fiverr/utils/theme.dart';
import 'package:mini_fiverr/widgets/custom_bottom_nav.dart';

class RoleSwitcher extends StatefulWidget {
  const RoleSwitcher({super.key, this.initialIndex});

  final int? initialIndex;

  @override
  State<RoleSwitcher> createState() => _RoleSwitcherState();
}

class _RoleSwitcherState extends State<RoleSwitcher> {
  int? _index;
  UserRole? _lastRole;

  @override
  Widget build(BuildContext context) {
    final DataProvider data = context.watch<DataProvider>();
    final bool isClient = data.currentRole == UserRole.client;

    // Default tab logic: Client -> Find Talent (index 1), Pro -> My Jobs (index 0)
    if (_index == null || _lastRole != data.currentRole) {
      if (widget.initialIndex != null && _lastRole == null) {
        _index = widget.initialIndex;
      } else {
        _index = isClient ? 1 : 0;
      }
      _lastRole = data.currentRole;
    }

    final List<Widget> pages = isClient
        ? const <Widget>[
            ClientHomeScreen(),
            FindTalentScreen(),
            MessagesScreen(),
            FavoritesScreen(isTab: true),
            ProfileScreen(isTab: true),
          ]
        : const <Widget>[
            ProfessionalHomeScreen(),
            JobRequestsScreen(),
            CreateProfessionalCardScreen(isTab: true),
            MessagesScreen(),
            ProfileScreen(isTab: true),
          ];

    final List<NavItemData> items = isClient
        ? const <NavItemData>[
            NavItemData(icon: Icons.home_rounded, label: 'My Hires'),
            NavItemData(icon: Icons.search_rounded, label: 'Find Talent'),
            NavItemData(icon: Icons.chat_bubble_outline_rounded, label: 'Messages'),
            NavItemData(icon: Icons.favorite_border_rounded, label: 'Saved'),
            NavItemData(icon: Icons.person_outline_rounded, label: 'Profile'),
          ]
        : const <NavItemData>[
            NavItemData(icon: Icons.home_rounded, label: 'My Jobs'),
            NavItemData(icon: Icons.assignment_outlined, label: 'Requests'),
            NavItemData(icon: Icons.add_circle_outline_rounded, label: 'Add Job'),
            NavItemData(icon: Icons.chat_bubble_outline_rounded, label: 'Messages'),
            NavItemData(icon: Icons.person_outline_rounded, label: 'Profile'),
          ];

    if (_index! >= pages.length) {
      _index = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_title(items[_index!].label)),
        actions: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isClient ? AppColors.primary.withValues(alpha: 0.2) : AppColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: (isClient ? AppColors.primary : AppColors.secondary).withValues(alpha: 0.4)),
            ),
            child: Text(isClient ? 'Client Role' : 'Pro Role', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
            ),
            icon: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                const Icon(Icons.notifications_none_rounded),
                if (data.unreadNotificationCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Text(
                        '${data.unreadNotificationCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: CustomBottomNav(
        items: items,
        currentIndex: _index!,
        onTap: (int i) => setState(() => _index = i),
        badgeIndex: isClient ? 2 : 3,
        badgeCount: data.totalUnreadMessages,
      ),
    );
  }

  String _title(String item) {
    if (item == 'Profile') return 'My Profile';
    if (item == 'Add Job') return 'Add New Service';
    return item;
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out of ProHire?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (result == true) {
      if (!context.mounted) return;
      await context.read<AppAuthProvider>().logout();
    }
  }
}
