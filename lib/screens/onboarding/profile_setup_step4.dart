import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/providers/auth_provider.dart';
import 'package:mini_fiverr/providers/user_provider.dart';
import 'package:mini_fiverr/screens/splash_screen.dart';
import 'package:mini_fiverr/utils/avatar_utils.dart';
import 'package:mini_fiverr/utils/error_handler.dart';
import 'package:mini_fiverr/utils/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileSetupStep4 extends StatelessWidget {
  const ProfileSetupStep4({super.key});

  void _handleComplete(BuildContext context) async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    try {
      await userProvider.updateUser(authProvider.user!.uid, {'profileCompleted': true});
      Fluttertoast.showToast(msg: "🎉 Profile setup complete!", backgroundColor: AppColors.success);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (route) => false,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: ErrorHandler.getHumanReadableError(e), backgroundColor: AppColors.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().userModel;
    if (user == null) return const Scaffold();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Review & Complete')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Step 4 of 4: Review', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Center(
              child: AvatarUtils.buildAvatar(name: user.name, imageUrl: user.profilePicUrl, radius: 60),
            ),
            const SizedBox(height: 24),
            _buildReviewCard(context, user),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => _handleComplete(context),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark),
              child: const Text('✅ Complete Setup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, user) {
    bool isPro = user.role == 'professional';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildRow('Name', user.name),
            _buildRow('Role', user.role.name.toUpperCase()),
            if (isPro) ...[
              _buildRow('Title', user.professionalTitle ?? ''),
              _buildRow('Rate', '\$${user.hourlyRate}/hr'),
              _buildRow('Experience', user.experience ?? ''),
              _buildRow('Skills', (user.skills as List).join(', ')),
            ] else ...[
              _buildRow('Company', user.companyName ?? 'N/A'),
              _buildRow('Industry', user.industry ?? ''),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
