import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/providers/auth_provider.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/models/security_question_model.dart';
import 'package:mini_fiverr/screens/auth/create_new_password_screen.dart';
import 'package:mini_fiverr/utils/theme.dart';
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
  List<SecurityQuestionModel> _questions = [];
  bool _showQuestions = false;
  bool _isSearching = false;

  @override
  void dispose() {
    _email.dispose();
    _a1.dispose();
    _a2.dispose();
    super.dispose();
  }

  Future<void> _fetchQuestions() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      ToastService.showWarning('Please enter your email first');
      return;
    }

    setState(() => _isSearching = true);

    final data = context.read<DataProvider>();
    final questions = data.securityQuestionsForEmail(email);

    setState(() => _isSearching = false);

    if (questions.length < 2) {
      ToastService.showError('No security questions found', subtitle: 'Please ensure your email is correct.');
      return;
    }

    setState(() {
      _questions = questions;
      _showQuestions = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Reset Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text('Recover your account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                const Text('Enter your email to verify your identity.', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 32),
                TextField(
                  controller: _email,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    suffixIcon: _isSearching ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)) : null,
                  ),
                  onSubmitted: (_) => _fetchQuestions(),
                ),
                const SizedBox(height: 24),

                if (!_showQuestions) ...[
                  ElevatedButton(
                    onPressed: _isSearching ? null : _fetchQuestions,
                    child: const Text('Next -->'),
                  ),
                ],

                if (_showQuestions) ...[
                  const Divider(height: 48),
                  const Text('Security Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 16),

                  _questionField(_questions[0].question, _a1),
                  const SizedBox(height: 16),
                  _questionField(_questions[1].question, _a2),

                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      final bool ok = context.read<DataProvider>().verifySecurityAnswers(
                            _email.text.trim(),
                            _a1.text.trim(),
                            _a2.text.trim(),
                          );
                      if (ok) {
                        ToastService.showSuccess('Identity verified!');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateNewPasswordScreen(email: _email.text.trim()),
                          ),
                        );
                      } else {
                        ToastService.showError('Verification failed', subtitle: 'The answers do not match our records.');
                      }
                    },
                    child: const Text('Verify and Reset'),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _showQuestions = false),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _questionField(String question, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Your answer'),
        ),
      ],
    );
  }
}
