import 'package:flutter/material.dart';
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
  final List<TextEditingController> _answerControllers = List.generate(5, (_) => TextEditingController());
  
  // Mock data for demo
  final List<String> _mockQuestions = [
    "What was the name of your first pet?",
    "What city were you born in?",
    "What is your favorite food?",
    "What was your dream job as a child?",
    "What is your favorite book?"
  ];

  void _handleVerifyEmail() {
    if (Validators.validateEmail(_emailController.text) == null) {
      if (_emailController.text.contains("sufyan")) {
         setState(() => _step = 2);
      } else {
        Fluttertoast.showToast(msg: "No account found with this email.", backgroundColor: AppColors.error);
      }
    } else {
      Fluttertoast.showToast(msg: "Please enter a valid email", backgroundColor: AppColors.error);
    }
  }

  void _handleVerifyAnswers() {
    // Demo logic: just check if answers are not empty
    int correct = 0;
    for (var controller in _answerControllers) {
      if (controller.text.isNotEmpty) correct++;
    }

    if (correct >= 3) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('✅ Verification Successful'),
          content: const Text('For security, we\'ve sent a password reset link to your email. (Simulated)'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // go back to login
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      Fluttertoast.showToast(msg: "Incorrect answers. Please try again.", backgroundColor: AppColors.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Reset Password')),
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
          'Enter your email to verify your identity using security questions.',
          textAlign: TextAlign.center,
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
          onPressed: _handleVerifyEmail,
          child: const Text('Continue'),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        const Text(
          'Answer at least 3 security questions correctly to proceed.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        for (int i = 0; i < 5; i++) ...[
          _buildAnswerField(i),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _handleVerifyAnswers,
          child: const Text('Submit Answers'),
        ),
      ],
    );
  }

  Widget _buildAnswerField(int i) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Q: ${_mockQuestions[i]}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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
