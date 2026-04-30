import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/models/security_question_model.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/screens/onboarding/profile_setup_step1.dart';
import 'package:mini_fiverr/utils/constants.dart';
import 'package:mini_fiverr/utils/theme.dart';

class SecurityQuestionsScreen extends StatefulWidget {
  const SecurityQuestionsScreen({super.key, this.isMandatory = false});

  final bool isMandatory;

  @override
  State<SecurityQuestionsScreen> createState() => _SecurityQuestionsScreenState();
}

class _SecurityQuestionsScreenState extends State<SecurityQuestionsScreen> {
  late final List<TextEditingController> _answerControllers;
  late final List<String> _selectedQuestions;

  @override
  void initState() {
    super.initState();
    final List<SecurityQuestionModel> saved = context.read<DataProvider>().securityQuestionsFor(context.read<DataProvider>().currentUser?.id ?? '');
    _answerControllers = List<TextEditingController>.generate(2, (int index) => TextEditingController(text: index < saved.length ? saved[index].answer : ''));
    _selectedQuestions = List<String>.generate(2, (int index) => index < saved.length ? saved[index].question : AppConstants.securityQuestions[index]);
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final Set<String> unique = _selectedQuestions.map((String q) => q.trim().toLowerCase()).toSet();
    if (unique.length < 2 || _answerControllers.any((TextEditingController controller) => controller.text.trim().isEmpty)) {
      Fluttertoast.showToast(msg: 'Please choose two different questions and fill both answers.', backgroundColor: AppColors.error);
      return;
    }

    final DataProvider data = context.read<DataProvider>();
    final user = data.currentUser;
    if (user == null) {
      return;
    }

    await data.updateProfile(
      fullName: user.fullName,
      bio: user.bio,
      avatarPath: user.avatarPath,
      companyName: user.companyName,
      lookingForTalent: user.lookingForTalent,
      title: user.title,
      skills: user.skills,
      experienceYears: user.experienceYears,
      previousCompany: user.previousCompany,
      workPreferences: user.workPreferences,
      hourlyRate: user.hourlyRate,
      security: List<SecurityQuestionModel>.generate(
        2,
        (int index) => SecurityQuestionModel(
          question: _selectedQuestions[index],
          answer: _answerControllers[index].text.trim(),
        ),
      ),
    );

    Fluttertoast.showToast(msg: 'Security questions saved.', backgroundColor: AppColors.success);
    if (!mounted) return;
    if (widget.isMandatory) {
      Navigator.pushReplacement(context, MaterialPageRoute<void>(builder: (_) => const ProfileSetupStep1()));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !widget.isMandatory,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Security Questions')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            const Text('Use two questions for password recovery and account verification.', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            _questionBlock(0),
            const SizedBox(height: 16),
            _questionBlock(1),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _save, child: const Text('Save Questions')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _questionBlock(int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Question ${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedQuestions[index],
            items: AppConstants.securityQuestions.map((String question) => DropdownMenuItem<String>(value: question, child: Text(question))).toList(),
            onChanged: (String? value) {
              if (value == null) return;
              setState(() => _selectedQuestions[index] = value);
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _answerControllers[index],
            decoration: const InputDecoration(hintText: 'Answer', labelText: 'Answer'),
          ),
        ],
      ),
    );
  }
}
