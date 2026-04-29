import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/models/user_model.dart';
import 'package:mini_fiverr/providers/user_provider.dart';
import 'package:mini_fiverr/services/firestore_service.dart';
import 'package:mini_fiverr/screens/professionals/professional_detail_screen.dart';
import 'package:mini_fiverr/screens/profile/profile_screen.dart';
import 'package:mini_fiverr/screens/profile/my_favorites_screen.dart';
import 'package:mini_fiverr/screens/jobs/activity_screen.dart';
import 'package:mini_fiverr/screens/chat/chat_list_screen.dart';
import 'package:mini_fiverr/screens/notifications/notifications_screen.dart';
import 'package:mini_fiverr/screens/payment/wallet_screen.dart';
import 'package:mini_fiverr/widgets/custom_app_bar.dart';
import 'package:mini_fiverr/widgets/bottom_nav_bar.dart';
import 'package:mini_fiverr/widgets/professional_card.dart';
import 'package:mini_fiverr/utils/theme.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  int _currentIndex = 0;
  final FirestoreService _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  String? _selectedSkill;

  @override
  void initState() {
    super.initState();
    _firestoreService.seedDemoProfessionals();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().userModel;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _currentIndex == 0 ? CustomAppBar(
        title: 'Find Talent',
        displayName: user.name,
        profilePicUrl: user.profilePicUrl,
        onProfileTap: () => setState(() => _currentIndex = 3),
        onNotificationsTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
        onWalletTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())),
        notificationCount: 2,
      ) : null,
      body: _buildBody(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        isProfessional: false,
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildExploreTab();
      case 1: return const ActivityScreen();
      case 2: return const ChatListScreen();
      case 3: return const ProfileScreen();
      default: return const SizedBox();
    }
  }

  Widget _buildExploreTab() {
    final currentUser = context.watch<UserProvider>().userModel;
    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 300), () {
                    if (!mounted) return;
                    setState(() => _searchQuery = value.trim().toLowerCase());
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search professionals by skill...',
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, color: AppColors.primary),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _selectedSkill = null;
                            });
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Popular Skills
            const Text('Popular Skills', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Flutter', 'React', 'Design', 'SEO', 'Writing'].map((skill) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    selected: _selectedSkill == skill,
                    label: Text(skill),
                    backgroundColor: Colors.white,
                    selectedColor: AppColors.primary.withValues(alpha: 0.12),
                    labelStyle: TextStyle(color: _selectedSkill == skill ? AppColors.primary : AppColors.textPrimary),
                    onSelected: (_) {
                      setState(() {
                        _selectedSkill = _selectedSkill == skill ? null : skill;
                        _searchController.text = _selectedSkill ?? _searchController.text;
                        _searchQuery = (_selectedSkill ?? _searchController.text).trim().toLowerCase();
                      });
                    },
                    side: BorderSide(color: _selectedSkill == skill ? AppColors.primary : Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Featured Professionals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            StreamBuilder<List<UserModel>>(
              stream: _firestoreService.getProfessionals(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Column(
                    children: [
                      const SizedBox(height: 40),
                      const Icon(Icons.people_outline, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No professionals available yet. Check back later!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  );
                }

                final professionals = snapshot.data!.where((pro) {
                  final query = _searchQuery;
                  if (query.isEmpty) {
                    return true;
                  }

                  final searchable = [
                    pro.name,
                    pro.professionalTitle ?? '',
                    pro.bio ?? '',
                    ...(pro.skills ?? const []),
                  ].join(' ').toLowerCase();

                  return searchable.contains(query);
                }).toList();

                final visibleProfessionals = _selectedSkill == null
                    ? professionals
                    : professionals.where((pro) => (pro.skills ?? const []).any((skill) => skill.toLowerCase() == _selectedSkill!.toLowerCase())).toList();

                if (visibleProfessionals.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        const Icon(Icons.search_off, size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          "No professionals found for '${_searchQuery.isEmpty ? _selectedSkill ?? '' : _searchQuery}'. Try a different search term.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visibleProfessionals.length,
                  itemBuilder: (context, index) {
                    final pro = visibleProfessionals[index];
                    final favoriteIds = currentUser.favoriteProfessionalIds ?? const [];
                    return ProfessionalCard(
                      professional: pro,
                      isFavorite: favoriteIds.contains(pro.uid),
                      onFavoriteTap: () async {
                        final updated = [...favoriteIds];
                        if (updated.contains(pro.uid)) {
                          updated.remove(pro.uid);
                        } else {
                          updated.add(pro.uid);
                        }
                        await context.read<UserProvider>().updateUser(currentUser.uid, {'favoriteProfessionalIds': updated});
                      },
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfessionalDetailScreen(professional: pro))),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
