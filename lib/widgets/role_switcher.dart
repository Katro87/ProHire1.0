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
import 'package:mini_fiverr/screens/professional/professional_profile_view_screen.dart';
import 'package:mini_fiverr/screens/shared/edit_profile_screen.dart';
import 'package:mini_fiverr/screens/shared/messages_screen.dart';
import 'package:mini_fiverr/screens/shared/notifications_screen.dart';
import 'package:mini_fiverr/utils/theme.dart';
import 'package:mini_fiverr/widgets/custom_bottom_nav.dart';

class RoleSwitcher extends StatefulWidget {
  const RoleSwitcher({super.key});

  @override
  State<RoleSwitcher> createState() => _RoleSwitcherState();
}

class _RoleSwitcherState extends State<RoleSwitcher> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final DataProvider data = context.watch<DataProvider>();
    final bool isClient = data.currentRole == UserRole.client;

    final List<Widget> pages = isClient
        ? const <Widget>[
            ClientHomeScreen(),
            FindTalentScreen(),
            MessagesScreen(),
            FavoritesScreen(),
            EditProfileScreen(),
          ]
        : const <Widget>[
            ProfessionalHomeScreen(),
            JobRequestsScreen(),
            MessagesScreen(),
            ProfessionalProfileViewScreen(),
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
            NavItemData(icon: Icons.chat_bubble_outline_rounded, label: 'Messages'),
            NavItemData(icon: Icons.person_outline_rounded, label: 'Profile'),
          ];

    if (_index >= pages.length) {
      _index = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_title(items[_index].label)),
        actions: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isClient ? AppColors.primary.withValues(alpha: 0.2) : AppColors.secondary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(isClient ? 'Client' : 'Professional', style: const TextStyle(fontSize: 11, color: Colors.white)),
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
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: const BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Text(
                        data.unreadNotificationCount > 99 ? '99+' : '${data.unreadNotificationCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              await context.read<AppAuthProvider>().logout();
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: CustomBottomNav(
        items: items,
        currentIndex: _index,
        onTap: (int i) => setState(() => _index = i),
        badgeIndex: 2,
        badgeCount: data.totalUnreadMessages,
      ),
    );
  }

  String _title(String item) {
    if (item == 'Profile') {
      return 'My Profile';
    }
    return item;
  }
}
