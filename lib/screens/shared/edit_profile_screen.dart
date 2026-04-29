import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/models/security_question_model.dart';
import 'package:mini_fiverr/models/user_model.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/utils/constants.dart';
import 'package:mini_fiverr/widgets/toast_notification.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _bio = TextEditingController();
  final TextEditingController _company = TextEditingController();
  final TextEditingController _looking = TextEditingController();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _skills = TextEditingController();
  final TextEditingController _experience = TextEditingController();
  final TextEditingController _previous = TextEditingController();
  final TextEditingController _rate = TextEditingController();
  final TextEditingController _a1 = TextEditingController();
  final TextEditingController _a2 = TextEditingController();

  String? _q1;
  String? _q2;
  final List<String> _chips = <String>[];
  final Set<String> _prefs = <String>{};

  @override
  void initState() {
    super.initState();
    final data = context.read<DataProvider>();
    final user = data.currentUser!;
    _name.text = user.fullName;
    _bio.text = user.bio;
    _company.text = user.companyName;
    _looking.text = user.lookingForTalent;
    _title.text = user.title;
    _chips.addAll(user.skills);
    _experience.text = user.experienceYears.toString();
    _previous.text = user.previousCompany;
    _rate.text = user.hourlyRate.toStringAsFixed(0);
    _prefs.addAll(user.workPreferences);
    final qs = data.securityQuestionsFor(user.id);
    _q1 = qs.isNotEmpty ? qs[0].question : AppConstants.securityQuestions.first;
    _q2 = qs.length > 1 ? qs[1].question : AppConstants.securityQuestions[1];
    if (_q1 == _q2) {
      _q2 = AppConstants.securityQuestions.firstWhere((String q) => q != _q1);
    }
    _a1.text = qs.isNotEmpty ? qs[0].answer : '';
    _a2.text = qs.length > 1 ? qs[1].answer : '';
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _company.dispose();
    _looking.dispose();
    _title.dispose();
    _skills.dispose();
    _experience.dispose();
    _previous.dispose();
    _rate.dispose();
    _a1.dispose();
    _a2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final UserModel user = data.currentUser!;

    if (_q1 == null || !AppConstants.securityQuestions.contains(_q1)) {
      _q1 = AppConstants.securityQuestions.first;
    }
    if (_q2 == null || !AppConstants.securityQuestions.contains(_q2) || _q2 == _q1) {
      _q2 = AppConstants.securityQuestions.firstWhere((String q) => q != _q1);
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(radius: 34, child: Text(_name.text.isEmpty ? 'U' : _name.text.substring(0, 1).toUpperCase())),
            const SizedBox(height: 10),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 10),
            TextField(controller: _bio, minLines: 3, maxLines: 5, decoration: const InputDecoration(labelText: 'Bio')),
            const SizedBox(height: 10),
            if (user.role == UserRole.client) ...<Widget>[
              TextField(controller: _company, decoration: const InputDecoration(labelText: 'Company Name')),
              const SizedBox(height: 10),
              TextField(controller: _looking, decoration: const InputDecoration(labelText: 'What talent are you looking for?')),
            ] else ...<Widget>[
              TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title / Headline')),
              const SizedBox(height: 10),
              TextField(
                controller: _skills,
                decoration: InputDecoration(
                  labelText: 'Skills',
                  suffixIcon: IconButton(
                    onPressed: () {
                      final String skill = _skills.text.trim();
                      if (skill.isNotEmpty) {
                        setState(() {
                          _chips.add(skill);
                          _skills.clear();
                        });
                      }
                    },
                    icon: const Icon(Icons.add),
                  ),
                ),
              ),
              Wrap(
                spacing: 6,
                children: _chips
                    .map((String e) => Chip(label: Text(e), onDeleted: () => setState(() => _chips.remove(e))))
                    .toList(),
              ),
              const SizedBox(height: 10),
              TextField(controller: _experience, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Years of Experience')),
              const SizedBox(height: 10),
              TextField(controller: _previous, decoration: const InputDecoration(labelText: 'Previous Company')),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: <String>['Part-Time', 'Full-Time', 'Remote', 'On-Site']
                    .map((String p) => FilterChip(
                          selected: _prefs.contains(p),
                          label: Text(p),
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _prefs.add(p);
                              } else {
                                _prefs.remove(p);
                              }
                            });
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 10),
              TextField(controller: _rate, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hourly Rate', prefixText: '\$ ')),
            ],
            const SizedBox(height: 16),
            const Text('Security Questions', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _q1,
              items: AppConstants.securityQuestions.map((String q) => DropdownMenuItem<String>(value: q, child: Text(q))).toList(),
              onChanged: (String? v) => setState(() => _q1 = v),
            ),
            const SizedBox(height: 8),
            TextField(controller: _a1, decoration: const InputDecoration(labelText: 'Answer 1')),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _q2,
              items: AppConstants.securityQuestions.where((String q) => q != _q1).map((String q) => DropdownMenuItem<String>(value: q, child: Text(q))).toList(),
              onChanged: (String? v) => setState(() => _q2 = v),
            ),
            const SizedBox(height: 8),
            TextField(controller: _a2, decoration: const InputDecoration(labelText: 'Answer 2')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_q1 == _q2) {
                    ToastService.showError('Security questions must be different');
                    return;
                  }
                  final double rate = (double.tryParse(_rate.text.trim()) ?? 5).clamp(5, 9999);
                  context.read<DataProvider>().updateProfile(
                        fullName: _name.text.trim(),
                        bio: _bio.text.trim(),
                        avatarPath: '',
                        companyName: _company.text.trim(),
                        lookingForTalent: _looking.text.trim(),
                        title: _title.text.trim(),
                        skills: _chips,
                        experienceYears: int.tryParse(_experience.text.trim()) ?? 0,
                        previousCompany: _previous.text.trim(),
                        workPreferences: _prefs.toList(),
                        hourlyRate: rate,
                        security: <SecurityQuestionModel>[
                          SecurityQuestionModel(question: _q1!, answer: _a1.text.trim()),
                          SecurityQuestionModel(question: _q2!, answer: _a2.text.trim()),
                        ],
                      );
                  ToastService.showSuccess('Profile updated');
                },
                child: const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => context.read<DataProvider>().switchRole(),
              child: Text(user.role == UserRole.client ? 'Switch to Professional View' : 'Switch to Client View'),
            ),
          ],
        ),
      ),
    );
  }
}
