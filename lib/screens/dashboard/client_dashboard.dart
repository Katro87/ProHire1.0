import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/models/user_model.dart';
import 'package:mini_fiverr/providers/user_provider.dart';
import 'package:mini_fiverr/services/firestore_service.dart';
import 'package:mini_fiverr/screens/professionals/professional_detail_screen.dart';
import 'package:mini_fiverr/screens/profile/profile_screen.dart';
import 'package:mini_fiverr/screens/jobs/activity_screen.dart';
import 'package:mini_fiverr/screens/chat/chat_list_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _firestoreService.seedDemoProfessionals();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().userModel;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _currentIndex == 0 ? CustomAppBar(
        title: 'Find Talent',
        profilePicUrl: user.profilePicUrl,
        onProfileTap: () => setState(() => _currentIndex = 3),
        onNotificationsTap: () {},
        onWalletTap: () {},
        notificationCount: 2,
      ) : null,
      body: _buildBody(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
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
              child: const TextField(
                decoration: InputDecoration(hintText: 'Search professionals by skill...', border: InputBorder.none, icon: Icon(Icons.search, color: AppColors.primary)),
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
                  child: Chip(
                    label: Text(skill),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey[300]!),
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

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final pro = snapshot.data![index];
                    return ProfessionalCard(
                      professional: pro,
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
