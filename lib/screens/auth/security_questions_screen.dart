import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/providers/auth_provider.dart';
import 'package:mini_fiverr/providers/user_provider.dart';
import 'package:mini_fiverr/screens/onboarding/profile_setup_step1.dart';
import 'package:mini_fiverr/utils/error_handler.dart';
import 'package:mini_fiverr/utils/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SecurityQuestionsScreen extends StatefulWidget {
  final bool isMandatory;

  const SecurityQuestionsScreen({super.key, this.isMandatory = false});

  @override
  State<SecurityQuestionsScreen> createState() => _SecurityQuestionsScreenState();
}

class _SecurityQuestionsScreenState extends State<SecurityQuestionsScreen> {
  final List<String> _questions = [
    "What is your mother's maiden name?",
    "What was the name of your first pet?",
    "What was the name of your elementary school?",
    "What is your favorite movie?",
    "What is your favorite book?",
    "What city were you born in?",
    "What is your middle name?",
    "What was your childhood nickname?",
    "What was the make of your first car?",
    "What is your favorite food?",
    "What was your dream job as a child?",
    "What is your father's middle name?",
    "What was your high school mascot?",
    "What street did you grow up on?",
    "What was your grades in intermediate/inter?",
  ];

  final List<String?> _selectedQuestions = List.filled(5, null);
  final List<TextEditingController> _answerControllers = List.generate(5, (_) => TextEditingController());

  void _handleSave() async {
    // Basic validation
    for (int i = 0; i < 5; i++) {
      if (_selectedQuestions[i] == null || _answerControllers[i].text.trim().isEmpty) {
        Fluttertoast.showToast(msg: "⚠️ Please fill all questions and answers", backgroundColor: AppColors.error);
        return;
      }
    }

    // Check for duplicates
    final uniqueQuestions = _selectedQuestions.toSet();
    if (uniqueQuestions.length < 5) {
      Fluttertoast.showToast(msg: "⚠️ Please select unique questions", backgroundColor: AppColors.error);
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    List<Map<String, String>> securityData = [];
    for (int i = 0; i < 5; i++) {
      securityData.add({
        'question': _selectedQuestions[i]!,
        'answer': _answerControllers[i].text.trim().toLowerCase(),
      });
    }

    try {
      await userProvider.updateUser(authProvider.user!.uid, {
        'securityQuestions': securityData,
        'hasSecurityQuestions': true,
      });
      Fluttertoast.showToast(msg: "✅ Security questions saved!", backgroundColor: AppColors.success);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileSetupStep1()));
    } catch (e) {
      final errorMsg = ErrorHandler.getHumanReadableError(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.isMandatory) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('⚠️ You must complete security questions to continue'),
              backgroundColor: Colors.orange.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: widget.isMandatory ? null : AppBar(title: const Text('🔒 Secure Your Account')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (widget.isMandatory)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '🔒 Security setup required! Complete all 5 questions before using the app.',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const Text(
                "You must set up 5 security questions. If you forget your password, you'll need to answer at least 3 correctly to reset it.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            const SizedBox(height: 32),
              for (int i = 0; i < 5; i++) ...[
                _buildQuestionSection(i),
                const SizedBox(height: 24),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSave,
                child: const Text('Save & Continue', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionSection(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Question ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedQuestions[index],
          items: _questions.map((q) => DropdownMenuItem(value: q, child: Text(q, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: (v) => setState(() => _selectedQuestions[index] = v),
          decoration: const InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
          isExpanded: true,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _answerControllers[index],
          decoration: InputDecoration(
            hintText: 'Answer ${index + 1}',
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        ),
      ],
    );
  }
}
