import 'package:flutter/material.dart';
import 'package:mini_fiverr/utils/theme.dart';

class CreateProfessionalCardScreen extends StatefulWidget {
  const CreateProfessionalCardScreen({super.key, this.isTab = false});

  final bool isTab;

  @override
  State<CreateProfessionalCardScreen> createState() => _CreateProfessionalCardScreenState();
}

class _CreateProfessionalCardScreenState extends State<CreateProfessionalCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _rateController = TextEditingController();
  final _skillsController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _rateController.dispose();
    _skillsController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveCard() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Professional card saved')),
    );
    if (!widget.isTab) {
      Navigator.pop(context);
    } else {
      _titleController.clear();
      _rateController.clear();
      _skillsController.clear();
      _bioController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Add a premium card to showcase your service.',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            _buildField(_titleController, 'Card Title', 'e.g. Senior Flutter Developer'),
            const SizedBox(height: 16),
            _buildField(_rateController, 'Hourly Rate', 'e.g. 45', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildField(_skillsController, 'Skills', 'Flutter, Firebase, UI/UX'),
            const SizedBox(height: 16),
            _buildField(_bioController, 'Description', 'Tell clients what you do...', maxLines: 4),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _saveCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Card', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.isTab) return body;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Professional Card'),
      ),
      body: body,
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.elevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
    );
  }
}
