import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/providers/auth_provider.dart';
import 'package:mini_fiverr/providers/user_provider.dart';
import 'package:mini_fiverr/screens/onboarding/profile_setup_step4.dart';
import 'package:mini_fiverr/utils/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileSetupStep3 extends StatefulWidget {
  const ProfileSetupStep3({super.key});

  @override
  State<ProfileSetupStep3> createState() => _ProfileSetupStep3State();
}

class _ProfileSetupStep3State extends State<ProfileSetupStep3> {
  void _handleSwitchRole(String newRole) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch Role?'),
        content: Text('Switching to $newRole will change your dashboard view. Your existing data will be saved. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              await userProvider.updateUser(authProvider.user!.uid, {'role': newRole});
              if (!mounted) return;
              Navigator.pop(context);
              Fluttertoast.showToast(msg: "✅ Role switched to $newRole!", backgroundColor: AppColors.success);
            },
            child: const Text('Switch', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().userModel;
    if (user == null) return const Scaffold();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Account Role')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Step 3 of 4: Verify Role', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Row(
                children: [
                  Icon(user.role == 'client' ? Icons.business : Icons.person, size: 48, color: AppColors.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your current role:', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        Text(user.role.toUpperCase(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => _handleSwitchRole(user.role == 'client' ? 'professional' : 'client'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: AppColors.primary),
              ),
              child: Text(user.role == 'client' ? 'Switch to Professional' : 'Switch to Client', style: const TextStyle(color: AppColors.primary)),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSetupStep4())),
              child: const Text('Next →', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
