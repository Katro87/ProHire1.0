import 'package:flutter/material.dart';
import 'package:mini_fiverr/utils/theme.dart';

class BrowseProfessionalsScreen extends StatelessWidget {
  const BrowseProfessionalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Browse Talent')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          // This would use ProfessionalCard widget in real app
          return Container(height: 100, margin: const EdgeInsets.only(bottom: 12), color: Colors.white);
        },
      ),
    );
  }
}
