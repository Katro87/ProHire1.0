import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/providers/auth_provider.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/widgets/toast_notification.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _a1 = TextEditingController();
  final TextEditingController _a2 = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _a1.dispose();
    _a2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Column(
              children: <Widget>[
                TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await context.read<AppAuthProvider>().resetPassword(_email.text.trim());
                        ToastService.showSuccess('Reset link sent to your email');
                      } catch (_) {
                        ToastService.showWarning('Could not send reset link');
                      }
                    },
                    child: const Text('Send Reset Link'),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 14),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Or answer your security questions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 10),
                TextField(controller: _a1, decoration: const InputDecoration(labelText: 'Answer 1')),
                const SizedBox(height: 10),
                TextField(controller: _a2, decoration: const InputDecoration(labelText: 'Answer 2')),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      final bool ok = context.read<DataProvider>().verifySecurityAnswers(
                            _email.text.trim(),
                            _a1.text.trim(),
                            _a2.text.trim(),
                          );
                      if (ok) {
                        ToastService.showSuccess('Identity verified. Set your new password from email link.');
                      } else {
                        ToastService.showError('Answers did not match');
                      }
                    },
                    child: const Text('Verify Answers'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
