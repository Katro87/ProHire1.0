import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/models/user_model.dart';
import 'package:mini_fiverr/providers/auth_provider.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/widgets/role_switcher.dart';
import 'package:mini_fiverr/utils/theme.dart';
import 'package:mini_fiverr/widgets/toast_notification.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  UserRole? _role;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppAuthProvider auth = context.watch<AppAuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(controller: _name, decoration: const InputDecoration(labelText: 'Full Name')),
                const SizedBox(height: 12),
                TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Choose your role', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(child: _roleCard(UserRole.client, Icons.work_outline, 'I want to hire', 'Find talented professionals for your projects')),
                    const SizedBox(width: 10),
                    Expanded(child: _roleCard(UserRole.professional, Icons.laptop_chromebook_rounded, 'I want to work', 'Offer your skills and get hired')),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: auth.isLoading || _role == null
                        ? null
                        : () async {
                            try {
                              final cred = await context.read<AppAuthProvider>().signUp(_email.text.trim(), _password.text);
                              await context.read<DataProvider>().completeSignupProfile(
                                    uid: cred.user!.uid,
                                    email: _email.text.trim(),
                                    fullName: _name.text.trim(),
                                    role: _role!,
                                  );
                              ToastService.showSuccess('Welcome to ProHire');
                              if (mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (_) => RoleSwitcher(initialIndex: _role == UserRole.client ? 4 : 3),
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                              }
                            } catch (_) {
                              ToastService.showError('Could not create account', subtitle: auth.error ?? 'Try again');
                            }
                          },
                    child: auth.isLoading
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Sign Up'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleCard(UserRole role, IconData icon, String title, String subtitle) {
    final bool selected = _role == role;
    final Color glow = role == UserRole.client ? AppColors.primary : AppColors.secondary;

    return GestureDetector(
      onTap: () => setState(() => _role = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: glassCardDecoration(accent: selected ? glow : AppColors.border),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: selected ? glow : AppColors.textSecondary),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
