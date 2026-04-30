import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/providers/auth_provider.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/models/user_model.dart';
import 'package:mini_fiverr/screens/auth/security_questions_screen.dart';
import 'package:mini_fiverr/screens/payment/wallet_screen.dart';
import 'package:mini_fiverr/screens/client/favorites_screen.dart';
import 'package:mini_fiverr/screens/professional/earnings_screen.dart';
import 'package:mini_fiverr/screens/shared/edit_profile_screen.dart';
import 'package:mini_fiverr/screens/shared/notifications_screen.dart';
import 'package:mini_fiverr/utils/avatar_utils.dart';
import 'package:mini_fiverr/utils/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.isTab = false});

  final bool isTab;

  @override
  Widget build(BuildContext context) {
    final DataProvider data = context.watch<DataProvider>();
    final user = data.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool isProfessional = user.role == UserRole.professional;

    final Widget body = ListView(
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
        _sectionHeader('Profile Information'),
        const SizedBox(height: 10),
        _infoPanel(
          children: <Widget>[
            _infoRow('Email', user.email),
            if (isProfessional) ...[
              _infoRow('Hourly Rate', '\$${user.hourlyRate.toStringAsFixed(0)}/hr'),
              _infoRow('Experience', user.experienceYears > 0 ? '${user.experienceYears} years' : 'Add your experience'),
            ] else ...[
              _infoRow('Company', user.companyName.isEmpty ? 'Individual' : user.companyName),
              _infoRow('Looking For', user.lookingForTalent.isEmpty ? 'General Services' : user.lookingForTalent),
            ],
          ],
        ),
        const SizedBox(height: 20),
        _sectionHeader('Account Actions'),
        const SizedBox(height: 10),
        _actionTile(context, Icons.edit_note_rounded, 'Edit Profile', 'Update your personal details.', () {
          Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const EditProfileScreen()));
        }),
        _actionTile(context, Icons.security_rounded, 'Security Settings', 'Manage recovery questions.', () {
          Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SecurityQuestionsScreen(isMandatory: false)));
        }),
        _actionTile(context, Icons.swap_horiz_rounded, 'Switch to ${isProfessional ? 'Client' : 'Professional'}', 'Change your current app view.', () => _confirmRoleSwitch(context, data)),

        if (!isProfessional)
          _actionTile(context, Icons.favorite_rounded, 'My Favorites', 'See professionals you saved.', () {
            Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const FavoritesScreen()));
          }),

        _actionTile(context, Icons.account_balance_wallet_rounded, 'Wallet & Payments', 'Manage your funds.', () {
          Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const WalletScreen()));
        }),

        if (isProfessional)
          _actionTile(context, Icons.bar_chart_rounded, 'Earnings Analytics', 'Track your income growth.', () {
            Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const EarningsScreen()));
          }),

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () => _logout(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error.withValues(alpha: 0.1), foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error, width: 0.5)),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout from ProHire', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );

    if (isTab) return body;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const NotificationsScreen())),
          ),
        ],
      ),
      body: body,
    );
  }

  void _confirmRoleSwitch(BuildContext context, DataProvider data) async {
    final bool isPro = data.currentRole == UserRole.professional;
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Switch to ${isPro ? 'Client' : 'Professional'}?'),
        content: Text('This will change your dashboard to ${isPro ? 'Client' : 'Professional'} view. Do you want to continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Switch Role', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
    if (result == true) {
      await data.switchRole();
    }
  }

  Widget _metricCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
    return Material( // Added Material to prevent "No Material widget found" error
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(children: children),
      ),
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
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out of ProHire?'),
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
