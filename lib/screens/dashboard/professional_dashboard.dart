import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/providers/user_provider.dart';
import 'package:mini_fiverr/screens/profile/profile_screen.dart';
import 'package:mini_fiverr/widgets/custom_app_bar.dart';
import 'package:mini_fiverr/widgets/bottom_nav_bar.dart';
import 'package:mini_fiverr/utils/theme.dart';
import 'package:mini_fiverr/screens/jobs/activity_screen.dart';
import 'package:mini_fiverr/screens/chat/chat_list_screen.dart';
import 'package:mini_fiverr/screens/notifications/notifications_screen.dart';
import 'package:mini_fiverr/screens/payment/wallet_screen.dart';

class ProfessionalDashboard extends StatefulWidget {
  const ProfessionalDashboard({super.key});

  @override
  State<ProfessionalDashboard> createState() => _ProfessionalDashboardState();
}

class _ProfessionalDashboardState extends State<ProfessionalDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().userModel;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _currentIndex == 0 ? CustomAppBar(
        title: 'My Dashboard',
        profilePicUrl: user.profilePicUrl,
        onProfileTap: () => setState(() => _currentIndex = 3),
        onNotificationsTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
        onWalletTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())),
        notificationCount: 5,
      ) : null,
      body: _buildBody(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        isProfessional: true,
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildStatsTab();
      case 1: return const ActivityScreen();
      case 2: return const ChatListScreen();
      case 3: return const ProfileScreen();
      default: return const SizedBox();
    }
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBalanceCard(),
          const SizedBox(height: 24),
          const Text('My Active Job Cards', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildJobCard('Senior Flutter Dev', '\$45/hr', Colors.green),
                _buildJobCard('UI/UX Designer', '\$55/hr', Colors.blue),
                _buildJobCard('Create New Card', '+', Colors.grey),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Incoming Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          _buildRequestTile('John Doe', 'Need a crypto dashboard UI', '\$500'),
          _buildRequestTile('Sarah Smith', 'Fix bugs in React Native app', '\$200'),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Earnings', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const Icon(Icons.trending_up, color: AppColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          const Text('\$2,450.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildMiniStat('Active Jobs', '3')),
              Expanded(child: _buildMiniStat('Rating', '4.9 ⭐')),
              Expanded(child: _buildMiniStat('Response', '1hr')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildJobCard(String title, String subtitle, Color color) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(Icons.work, color: color, size: 20)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(subtitle, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRequestTile(String name, String desc, String budget) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(child: Text(name[0])),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(budget, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            const Text('Pending', style: TextStyle(fontSize: 10, color: AppColors.accent)),
          ],
        ),
      ),
    );
  }
}
