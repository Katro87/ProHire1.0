import 'package:flutter/material.dart';
import 'package:mini_fiverr/models/user_model.dart';
import 'package:mini_fiverr/screens/auth/create_new_password_screen.dart';
import 'package:mini_fiverr/services/firestore_service.dart';
import 'package:mini_fiverr/utils/theme.dart';
import 'package:mini_fiverr/utils/validators.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 1;
  final _emailController = TextEditingController();
  final _firestoreService = FirestoreService();
  final List<TextEditingController> _answerControllers = List.generate(2, (_) => TextEditingController());
  UserModel? _recoveryUser;
  bool _isLoading = false;
  int _attempts = 0;
  DateTime? _lockedUntil;

  Future<void> _handleVerifyEmail() async {
    if (Validators.validateEmail(_emailController.text) == null) {
      setState(() => _isLoading = true);
      try {
        final user = await _firestoreService.getUserByEmail(_emailController.text);
        if (user == null) {
          Fluttertoast.showToast(msg: 'No account found with this email.', backgroundColor: AppColors.error);
          return;
        }
        setState(() {
          _recoveryUser = user;
          _step = 2;
        });
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      Fluttertoast.showToast(msg: 'Please enter a valid email.', backgroundColor: AppColors.error);
    }
  }

  void _handleVerifyAnswers() {
    if (_lockedUntil != null && DateTime.now().isBefore(_lockedUntil!)) {
      final minutes = _lockedUntil!.difference(DateTime.now()).inMinutes + 1;
      Fluttertoast.showToast(msg: 'Too many attempts. Try again in $minutes minutes.', backgroundColor: AppColors.error);
      return;
    }

    final questions = _recoveryUser?.securityQuestions ?? [];
    int correct = 0;
    for (int i = 0; i < questions.length && i < 2; i++) {
      final expected = (questions[i]['answer'] ?? '').trim().toLowerCase();
      final provided = _answerControllers[i].text.trim().toLowerCase();
      if (expected.isNotEmpty && expected == provided) {
        correct++;
      }
    }

    if (correct == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateNewPasswordScreen(email: _emailController.text.trim()),
        ),
      );
      return;
    }

    _attempts += 1;
    if (_attempts >= 3) {
      _lockedUntil = DateTime.now().add(const Duration(minutes: 15));
    }

    Fluttertoast.showToast(msg: 'Answers do not match our records. Please try again.', backgroundColor: AppColors.error);
    setState(() {});
  }

  List<String> _currentQuestions() {
    final stored = _recoveryUser?.securityQuestions ?? [];
    if (stored.length >= 2) {
      return [stored[0]['question'] ?? 'Security question 1', stored[1]['question'] ?? 'Security question 2'];
    }
    return ['Security question 1', 'Security question 2'];
  }

  @override
  void dispose() {
    _emailController.dispose();
    for (final controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Reset Your Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (_step == 1) _buildStep1(),
            if (_step == 2) _buildStep2(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        const Icon(Icons.lock_reset, size: 80, color: AppColors.primary),
        const SizedBox(height: 24),
        const Text(
          'Answer your security questions to continue',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 32),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleVerifyEmail,
          child: _isLoading
              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : const Text('Continue'),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final questions = _currentQuestions();
    return Column(
      children: [
        const Text(
          'Answer both questions correctly to proceed.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        for (int i = 0; i < 2; i++) ...[
          _buildAnswerField(i),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _handleVerifyAnswers,
          child: const Text('Verify Answers'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to Login'),
        ),
      ],
    );
  }

  Widget _buildAnswerField(int i) {
    final questions = _currentQuestions();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Q: ${questions[i]}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        TextFormField(
          controller: _answerControllers[i],
          decoration: InputDecoration(
            hintText: 'Your answer...',
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        ),
      ],
    );
  }
}
