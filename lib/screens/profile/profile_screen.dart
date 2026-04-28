import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/providers/auth_provider.dart';
import 'package:mini_fiverr/providers/user_provider.dart';
import 'package:mini_fiverr/screens/splash_screen.dart';
import 'package:mini_fiverr/utils/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SplashScreen()), (route) => false);
              Fluttertoast.showToast(msg: "👋 Logged out successfully", backgroundColor: AppColors.secondary);
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().userModel;
    if (user == null) return const Scaffold();

    bool isPro = user.role == 'professional';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(radius: 60, backgroundImage: NetworkImage(user.profilePicUrl)),
                  const SizedBox(height: 16),
                  Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(isPro ? (user.professionalTitle ?? 'Digital Creator') : 'Business Account', style: const TextStyle(color: AppColors.textSecondary)),
                  if (isPro) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const Text(' 4.8 • ', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Text('💵 ', style: TextStyle(fontSize: 16)),
                        Text('\$${user.hourlyRate}/hr', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),
            if (isPro) ...[
              _buildSectionHeader('My Professional Cards', '3'),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildMiniCard('Web Dev'),
                    _buildMiniCard('Design'),
                    _buildMiniCard('SEO'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
            _buildSettingsGroup('Account Settings', [
              _buildSettingsTile(Icons.person_outline, 'Edit Profile', () {}),
              _buildSettingsTile(Icons.swap_horiz, 'Switch Role (${user.role == 'client' ? 'Pro' : 'Client'})', () {}),
              _buildSettingsTile(Icons.security_outlined, 'Security Questions', () {}),
              _buildSettingsTile(Icons.notifications_outlined, 'Notification Preferences', () {}),
            ]),
            const SizedBox(height: 24),
            _buildActionCard('Wallet Balance', '\$250.00', Icons.account_balance_wallet, AppColors.primary),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('🚪 LOGOUT', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Row(
          children: [
            Text(count, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniCard(String title) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      alignment: Alignment.center,
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.secondary, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }

  Widget _buildActionCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
        ],
      ),
    );
  }
}
