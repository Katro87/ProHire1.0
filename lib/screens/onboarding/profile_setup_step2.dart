import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/providers/auth_provider.dart';
import 'package:mini_fiverr/providers/user_provider.dart';
import 'package:mini_fiverr/screens/onboarding/profile_setup_step3.dart';
import 'package:mini_fiverr/utils/error_handler.dart';
import 'package:mini_fiverr/utils/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mini_fiverr/models/user_model.dart';

class ProfileSetupStep2 extends StatefulWidget {
  const ProfileSetupStep2({super.key});

  @override
  State<ProfileSetupStep2> createState() => _ProfileSetupStep2State();
}

class _ProfileSetupStep2State extends State<ProfileSetupStep2> {
  final _formKey = GlobalKey<FormState>();
  
  // Professional fields
  final _titleController = TextEditingController();
  final _bioController = TextEditingController();
  final _rateController = TextEditingController();
  String _experience = '1-3 years';
  final List<String> _skills = [];
  final _skillInputController = TextEditingController();
  bool _isAvailable = true;

  // Client fields
  final _companyController = TextEditingController();
  final _lookingForController = TextEditingController();
  String _industry = 'Tech';

  void _addSkill(String skill) {
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillInputController.clear();
      });
    }
  }

  void _handleNext() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final role = userProvider.userModel!.role;

      Map<String, dynamic> data = {};
      if (role == UserRole.professional) {
        if (_skills.isEmpty) {
          Fluttertoast.showToast(msg: "⚠️ Add at least one skill", backgroundColor: AppColors.error);
          return;
        }
        data = {
          'professionalTitle': _titleController.text.trim(),
          'bio': _bioController.text.trim(),
          'hourlyRate': double.tryParse(_rateController.text) ?? 0.0,
          'experience': _experience,
          'skills': _skills,
          'isAvailable': _isAvailable,
        };
      } else {
        data = {
          'companyName': _companyController.text.trim(),
          'lookingFor': _lookingForController.text.trim(),
          'industry': _industry,
        };
      }

      try {
        await userProvider.updateUser(authProvider.user!.uid, data);
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSetupStep3()));
      } catch (e) {
        Fluttertoast.showToast(msg: ErrorHandler.getHumanReadableError(e), backgroundColor: AppColors.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().userModel;
    if (user == null) return const Scaffold();

    bool isPro = user.role == UserRole.professional;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Setup Information')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Step 2 of 4: ${isPro ? "Professional Info" : "Client Info"}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              if (isPro) ..._buildProfessionalForm() else ..._buildClientForm(),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _handleNext,
                child: const Text('Next →', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildProfessionalForm() {
    return [
      TextFormField(
        controller: _titleController,
        decoration: const InputDecoration(
          labelText: 'Professional Title *',
          hintText: 'e.g. Senior Flutter Developer',
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        validator: (v) => (v == null || v.isEmpty) ? 'Title is required' : null,
      ),
      const SizedBox(height: 20),
      const Text('Skills *', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextFormField(
        controller: _skillInputController,
        decoration: InputDecoration(
          hintText: 'Type and press enter to add skill',
          suffixIcon: IconButton(icon: const Icon(Icons.add), onPressed: () => _addSkill(_skillInputController.text.trim())),
          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        onFieldSubmitted: _addSkill,
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        children: _skills.map((s) => Chip(
          label: Text(s),
          onDeleted: () => setState(() => _skills.remove(s)),
        )).toList(),
      ),
      const SizedBox(height: 20),
      const Text('Years of Experience *', style: TextStyle(fontWeight: FontWeight.bold)),
      DropdownButtonFormField<String>(
        value: _experience,
        items: ['0-1', '1-3', '3-5', '5-10', '10+'].map((e) => DropdownMenuItem(value: '$e years', child: Text('$e years'))).toList(),
        onChanged: (v) => setState(() => _experience = v!),
        decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
      ),
      const SizedBox(height: 20),
      TextFormField(
        controller: _rateController,
        decoration: const InputDecoration(
          labelText: 'Hourly Rate (USD) *',
          prefixText: '\$ ',
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        keyboardType: TextInputType.number,
        validator: (v) => (v == null || v.isEmpty) ? 'Rate is required' : null,
      ),
      const SizedBox(height: 20),
      TextFormField(
        controller: _bioController,
        decoration: const InputDecoration(
          labelText: 'Bio / About Me *',
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        maxLines: 5,
        maxLength: 500,
        validator: (v) => (v == null || v.isEmpty) ? 'Bio is required' : null,
      ),
      SwitchListTile(
        title: const Text('Available for hire'),
        value: _isAvailable,
        onChanged: (v) => setState(() => _isAvailable = v),
        activeThumbColor: AppColors.primary,
      ),
    ];
  }

  List<Widget> _buildClientForm() {
    return [
      TextFormField(
        controller: _companyController,
        decoration: const InputDecoration(
          labelText: 'Company/Organization Name *',
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        validator: (v) => (v == null || v.isEmpty) ? 'Company name is required' : null,
      ),
      const SizedBox(height: 20),
      TextFormField(
        controller: _lookingForController,
        decoration: const InputDecoration(
          labelText: 'What are you looking for? *',
          hintText: 'e.g. Need a logo designer for my startup',
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
        maxLines: 3,
        validator: (v) => (v == null || v.isEmpty) ? 'This field is required' : null,
      ),
      const SizedBox(height: 20),
      const Text('Industry *', style: TextStyle(fontWeight: FontWeight.bold)),
      DropdownButtonFormField<String>(
        value: _industry,
        items: ['Tech', 'Healthcare', 'Finance', 'Education', 'Other'].map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: (v) => setState(() => _industry = v!),
        decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
      ),
    ];
  }
}
