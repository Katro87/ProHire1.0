import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/providers/auth_provider.dart';
import 'package:mini_fiverr/providers/user_provider.dart';
import 'package:mini_fiverr/screens/onboarding/profile_setup_step1.dart';
import 'package:mini_fiverr/utils/security_questions.dart';
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
  final List<TextEditingController> _answerControllers = List.generate(2, (_) => TextEditingController());
  final List<String> _selectedQuestions = List.generate(2, (_) => SecurityQuestions.defaults.first);

  void _handleSave() async {
    for (int i = 0; i < 2; i++) {
      if (_selectedQuestions[i].trim().isEmpty || _answerControllers[i].text.trim().isEmpty) {
        Fluttertoast.showToast(msg: 'Please fill both security questions and answers.', backgroundColor: AppColors.error);
        return;
      }
    }

    final questions = _selectedQuestions.map((question) => question.trim().toLowerCase()).toList();
    final uniqueQuestions = questions.toSet();
    if (uniqueQuestions.length < 2) {
      Fluttertoast.showToast(msg: 'Please choose two different questions.', backgroundColor: AppColors.error);
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    List<Map<String, String>> securityData = [];
    for (int i = 0; i < 2; i++) {
      securityData.add({
        'question': _selectedQuestions[i].trim(),
        'answer': _answerControllers[i].text.trim().toLowerCase(),
      });
    }

    try {
      await userProvider.updateUser(authProvider.user!.uid, {
        'securityQuestions': securityData,
        'hasSecurityQuestions': true,
      });
      Fluttertoast.showToast(msg: 'Security questions saved successfully.', backgroundColor: AppColors.success);
      if (!mounted) return;
      if (widget.isMandatory) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileSetupStep1()));
      } else {
        Navigator.pop(context);
      }
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
        appBar: widget.isMandatory ? null : AppBar(title: const Text('Security Questions')),
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
                          'Save two security questions to protect account recovery.',
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
                'These questions will be used to verify your identity if you forget your password.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              for (int i = 0; i < 2; i++) ...[
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
          value: _selectedQuestions[index],
          items: SecurityQuestions.defaults.map((question) {
            return DropdownMenuItem(value: question, child: Text(question));
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedQuestions[index] = value);
          },
          decoration: InputDecoration(
            labelText: 'Select question',
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            fillColor: AppColors.surfaceLight,
            filled: true,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _answerControllers[index],
          decoration: InputDecoration(
            hintText: 'Write your answer...',
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            fillColor: AppColors.surfaceLight,
            filled: true,
          ),
        ),
      ],
    );
  }
}
