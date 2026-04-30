import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/providers/auth_provider.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/models/user_model.dart';
import 'package:mini_fiverr/screens/auth/security_questions_screen.dart';
import 'package:mini_fiverr/screens/payment/wallet_screen.dart';
import 'package:mini_fiverr/screens/profile/create_professional_card.dart';
import 'package:mini_fiverr/screens/client/favorites_screen.dart';
import 'package:mini_fiverr/screens/professional/earnings_screen.dart';
import 'package:mini_fiverr/screens/shared/edit_profile_screen.dart';
import 'package:mini_fiverr/screens/shared/notifications_screen.dart';
import 'package:mini_fiverr/screens/splash_screen.dart';
import 'package:mini_fiverr/utils/avatar_utils.dart';
import 'package:mini_fiverr/utils/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DataProvider data = context.watch<DataProvider>();
    final user = data.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool isProfessional = user.role == UserRole.professional;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isProfessional ? AppColors.secondary.withValues(alpha: 0.22) : AppColors.primary.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(isProfessional ? 'Professional' : 'Client', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const NotificationsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const EditProfileScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: glassCardDecoration(accent: isProfessional ? AppColors.secondary : AppColors.primary),
            child: Column(
              children: <Widget>[
                AvatarUtils.buildAvatar(name: user.fullName, imageUrl: user.avatarPath, radius: 54),
                const SizedBox(height: 14),
                Text(user.fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  isProfessional ? (user.title.isEmpty ? 'Professional' : user.title) : (user.companyName.isEmpty ? 'Client' : user.companyName),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(child: _metricCard('Wallet', '\$${user.walletBalance.toStringAsFixed(0)}')),
                    const SizedBox(width: 12),
                    Expanded(child: _metricCard(isProfessional ? 'Earnings' : 'Saved', isProfessional ? '\$${user.earnings.toStringAsFixed(0)}' : '${user.favoriteProfessionalIds.length}')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (isProfessional) ...<Widget>[
            _sectionHeader('Professional Snapshot'),
            const SizedBox(height: 10),
            _infoPanel(
              children: <Widget>[
                _infoRow('Title', user.title.isEmpty ? 'Add a title' : user.title),
                _infoRow('Hourly Rate', '\$${user.hourlyRate.toStringAsFixed(0)}/hr'),
                _infoRow('Experience', user.experienceYears > 0 ? '${user.experienceYears} years' : 'Add your experience'),
                _infoRow('Skills', user.skills.isEmpty ? 'Add skills' : user.skills.join(', ')),
              ],
            ),
            const SizedBox(height: 20),
            _sectionHeader('Quick Actions'),
            const SizedBox(height: 10),
            _actionTile(
              context,
              Icons.add_business_rounded,
              'Add Job Card',
              'Create a new service card from your professional view.',
              () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const CreateProfessionalCardScreen())),
            ),
            _actionTile(
              context,
              Icons.trending_up_rounded,
              'Earnings Dashboard',
              'Track income and completed work in one place.',
              () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const EarningsScreen())),
            ),
          ] else ...<Widget>[
            _sectionHeader('Client Details'),
            const SizedBox(height: 10),
            _infoPanel(
              children: <Widget>[
                _infoRow('Company', user.companyName.isEmpty ? 'Add company name' : user.companyName),
                _infoRow('Looking For', user.lookingForTalent.isEmpty ? 'Describe your needs' : user.lookingForTalent),
                _infoRow('Favorites', '${user.favoriteProfessionalIds.length} professionals saved'),
              ],
            ),
          ],
          const SizedBox(height: 20),
          _sectionHeader('Account Settings'),
          const SizedBox(height: 10),
          _actionTile(context, Icons.lock_outline_rounded, 'Security Questions', 'Manage account recovery questions.', () {
            Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SecurityQuestionsScreen(isMandatory: false)));
          }),
          _actionTile(context, Icons.settings_backup_restore_rounded, 'Switch Role', 'Toggle between client and professional views.', () async {
            await context.read<DataProvider>().switchRole();
          }),
          _actionTile(context, Icons.favorite_border_rounded, 'Favorites', 'See saved professionals.', () {
            Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const FavoritesScreen()));
          }),
          _actionTile(context, Icons.account_balance_wallet_rounded, 'Wallet', 'Review balance and payments.', () {
            Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const WalletScreen()));
          }),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Logout'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white));
  }

  Widget _infoPanel({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(String label, String value) {
    return ListTile(
      dense: true,
      title: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      subtitle: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }

  Widget _actionTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await context.read<AppAuthProvider>().logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute<void>(builder: (_) => const SplashScreen()), (Route<dynamic> route) => false);
                Fluttertoast.showToast(msg: 'Logged out successfully', backgroundColor: AppColors.secondary);
              },
              child: const Text('Logout', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }
}
