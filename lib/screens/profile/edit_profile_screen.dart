import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/providers/auth_provider.dart' as app_auth;
import 'package:mini_fiverr/providers/user_provider.dart';
import 'package:mini_fiverr/utils/avatar_utils.dart';
import 'package:mini_fiverr/utils/error_handler.dart';
import 'package:mini_fiverr/utils/security_questions.dart';
import 'package:mini_fiverr/utils/theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _companyController = TextEditingController();
  final _lookingForController = TextEditingController();
  final _titleController = TextEditingController();
  final _experienceController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _skillInputController = TextEditingController();
  final _answerControllers = List.generate(2, (_) => TextEditingController());

  final List<String> _skills = [];
  final List<String> _selectedQuestions = List.generate(2, (_) => SecurityQuestions.defaults.first);
  bool _isLoading = false;
  bool _isUploadingPhoto = false;
  bool _hasUnsavedChanges = false;
  String? _profilePicUrl;
  bool _isProfessional = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().userModel;
    if (user != null) {
      _nameController.text = user.name;
      _bioController.text = user.bio ?? '';
      _companyController.text = user.companyName ?? '';
      _lookingForController.text = user.lookingFor ?? '';
      _titleController.text = user.professionalTitle ?? '';
      _experienceController.text = user.experience ?? '';
      _hourlyRateController.text = user.hourlyRate != null && user.hourlyRate! > 0 ? user.hourlyRate!.toStringAsFixed(0) : '';
      _profilePicUrl = user.profilePicUrl;
      _isProfessional = user.role == 'professional';
      _skills.addAll(user.skills ?? const []);

      final securityQuestions = user.securityQuestions ?? [];
      for (int i = 0; i < securityQuestions.length && i < 2; i++) {
        _selectedQuestions[i] = securityQuestions[i]['question'] ?? SecurityQuestions.defaults.first;
        _answerControllers[i].text = securityQuestions[i]['answer'] ?? '';
      }
    }

    for (final controller in [
      _nameController,
      _bioController,
      _companyController,
      _lookingForController,
      _titleController,
      _experienceController,
      _hourlyRateController,
      _skillInputController,
      ..._answerControllers,
    ]) {
      controller.addListener(() {
        if (!_hasUnsavedChanges) {
          setState(() => _hasUnsavedChanges = true);
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _companyController.dispose();
    _lookingForController.dispose();
    _titleController.dispose();
    _experienceController.dispose();
    _hourlyRateController.dispose();
    _skillInputController.dispose();
    for (final controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 85);
    if (pickedFile == null) {
      return;
    }

    setState(() => _isUploadingPhoto = true);
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Please sign in again to update your profile photo.');
      }

      final storageRef = FirebaseStorage.instance.ref().child('profile_pictures').child(currentUser.uid).child('avatar.jpg');
      await storageRef.putData(await pickedFile.readAsBytes());
      final url = await storageRef.getDownloadURL();

      setState(() {
        _profilePicUrl = url;
        _hasUnsavedChanges = true;
      });
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(msg: ErrorHandler.getHumanReadableError(e), backgroundColor: AppColors.error);
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  void _showPhotoSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_skills.isEmpty && _isProfessional) {
      Fluttertoast.showToast(msg: 'Please add at least one skill.', backgroundColor: AppColors.error);
      return;
    }

    if (_selectedQuestions.toSet().length < 2) {
      Fluttertoast.showToast(msg: 'Please choose two different security questions.', backgroundColor: AppColors.error);
      return;
    }

    final authProvider = context.read<app_auth.AppAuthProvider>();
    final userProvider = context.read<UserProvider>();
    final currentUser = authProvider.user;
    if (currentUser == null) {
      Fluttertoast.showToast(msg: 'Please sign in again.', backgroundColor: AppColors.error);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final updates = <String, dynamic>{
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'profilePicUrl': _profilePicUrl ?? '',
        'securityQuestions': List.generate(2, (index) => {
              'question': _selectedQuestions[index],
              'answer': _answerControllers[index].text.trim().toLowerCase(),
            }),
        'hasSecurityQuestions': true,
      };

      if (_isProfessional) {
        updates.addAll({
          'professionalTitle': _titleController.text.trim(),
          'skills': _skills,
          'experience': _experienceController.text.trim(),
          'hourlyRate': double.tryParse(_hourlyRateController.text.trim()) ?? 0.0,
          'lookingFor': _lookingForController.text.trim(),
          'profileCompleted': true,
        });
      } else {
        updates.addAll({
          'companyName': _companyController.text.trim(),
          'lookingFor': _lookingForController.text.trim(),
          'profileCompleted': true,
        });
      }

      await userProvider.updateUser(currentUser.uid, updates);
      await currentUser.updateDisplayName(_nameController.text.trim());
      if (_profilePicUrl != null && _profilePicUrl!.isNotEmpty) {
        await currentUser.updatePhotoURL(_profilePicUrl);
      }

      Fluttertoast.showToast(msg: 'Profile updated successfully.', backgroundColor: AppColors.success);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ErrorHandler.getHumanReadableError(e))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addSkill() {
    final value = _skillInputController.text.trim();
    if (value.isEmpty) {
      return;
    }

    final pieces = value.split(',').map((skill) => skill.trim()).where((skill) => skill.isNotEmpty);
    setState(() {
      for (final skill in pieces) {
        if (!_skills.contains(skill)) {
          _skills.add(skill);
        }
      }
      _skillInputController.clear();
      _hasUnsavedChanges = true;
    });
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasUnsavedChanges) {
      return true;
    }

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved changes'),
        content: const Text('You have unsaved changes. Discard them?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep Editing')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Discard')),
        ],
      ),
    );

    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().userModel;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WillPopScope(
      onWillPop: _confirmDiscard,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Edit Profile'),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2))
                  : const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      AvatarUtils.buildAvatar(name: _nameController.text.isEmpty ? user.name : _nameController.text, imageUrl: _profilePicUrl, radius: 56),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: FloatingActionButton.small(
                          heroTag: 'change_photo',
                          onPressed: _isUploadingPhoto ? null : _showPhotoSourcePicker,
                          child: _isUploadingPhoto
                              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.photo_camera_outlined),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isUploadingPhoto) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(),
                ],
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Full name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  maxLength: 500,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Bio', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                ),
                const SizedBox(height: 16),
                if (_isProfessional) ...[
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Professional Title', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _skillInputController,
                    decoration: InputDecoration(
                      labelText: 'Skills',
                      helperText: 'Add a skill and press enter or type comma-separated values.',
                      suffixIcon: IconButton(onPressed: _addSkill, icon: const Icon(Icons.add)),
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    onFieldSubmitted: (_) => _addSkill(),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skills.map((skill) {
                      return InputChip(
                        label: Text(skill),
                        onDeleted: () {
                          setState(() {
                            _skills.remove(skill);
                            _hasUnsavedChanges = true;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _experienceController,
                    decoration: const InputDecoration(labelText: 'Years of Experience', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _hourlyRateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(prefixText: '\$ ', labelText: 'Hourly Rate', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                    validator: (value) {
                      final rate = double.tryParse(value ?? '');
                      if (rate == null || rate < 5) {
                        return 'Hourly rate must be at least \$5';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lookingForController,
                    decoration: const InputDecoration(labelText: 'Looking For', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                  ),
                ] else ...[
                  TextFormField(
                    controller: _companyController,
                    decoration: const InputDecoration(labelText: 'Company Name', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lookingForController,
                    decoration: const InputDecoration(labelText: 'What talent are you looking for?', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                  ),
                ],
                const SizedBox(height: 24),
                _buildSecurityQuestionsSection(),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityQuestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Security Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('These questions will be used to verify your identity if you forget your password.', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        for (int i = 0; i < 2; i++) ...[
          DropdownButtonFormField<String>(
            value: _selectedQuestions[i],
            items: SecurityQuestions.defaults.map((question) {
              return DropdownMenuItem(value: question, child: Text(question));
            }).toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedQuestions[i] = value;
                _hasUnsavedChanges = true;
              });
            },
            decoration: InputDecoration(
              labelText: 'Question ${i + 1}',
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _answerControllers[i],
            decoration: InputDecoration(
              labelText: 'Answer ${i + 1}',
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
