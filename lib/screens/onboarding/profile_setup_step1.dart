import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/providers/auth_provider.dart';
import 'package:mini_fiverr/providers/user_provider.dart';
import 'package:mini_fiverr/screens/onboarding/profile_setup_step2.dart';
import 'package:mini_fiverr/utils/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mini_fiverr/widgets/loading_overlay.dart';

class ProfileSetupStep1 extends StatefulWidget {
  const ProfileSetupStep1({super.key});

  @override
  State<ProfileSetupStep1> createState() => _ProfileSetupStep1State();
}

class _ProfileSetupStep1State extends State<ProfileSetupStep1> {
  XFile? _imageFile;
  bool _isUploading = false;

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imageFile = image);
    }
  }

  void _handleNext() async {
    if (_imageFile == null) {
      Fluttertoast.showToast(msg: "⚠️ Please upload a profile photo", backgroundColor: AppColors.error);
      return;
    }

    setState(() => _isUploading = true);
    
    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final uid = Provider.of<AuthProvider>(context, listen: false).user!.uid;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    try {
      await userProvider.updateUser(uid, {
        'profilePicUrl': 'https://i.pravatar.cc/300?u=$uid', // Simulator URL
      });
      Fluttertoast.showToast(msg: "✅ Profile photo updated!", backgroundColor: AppColors.success);
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSetupStep2()));
    } catch (e) {
      Fluttertoast.showToast(msg: "❌ Failed: ${e.toString()}", backgroundColor: AppColors.error);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isUploading,
      message: "Uploading photo...",
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Setup Profile')),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text('Step 1 of 4: Profile Picture', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.white,
                      backgroundImage: _imageFile != null ? FileImage(File(_imageFile!.path)) : null,
                      child: _imageFile == null ? const Icon(Icons.person, size: 80, color: Colors.grey) : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: FloatingActionButton.small(
                        backgroundColor: AppColors.primary,
                        onPressed: _pickImage,
                        child: const Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'A professional photo helps building trust with your clients or professionals.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const Spacer(),
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
}
