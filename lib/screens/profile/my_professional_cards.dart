import 'package:flutter/material.dart';
import 'package:mini_fiverr/utils/theme.dart';

class MyProfessionalCardsScreen extends StatelessWidget {
  const MyProfessionalCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Professional Cards')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 3,
        itemBuilder: (context, index) {
          return _buildCard(context, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCard(BuildContext context, int index) {
    final titles = ['Senior Flutter Dev', 'UI Designer', 'Firebase Expert'];
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.work_outline, size: 40, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(titles[index], style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('\$45/hr', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            const Spacer(),
            Switch(value: true, onChanged: (v) {}, activeThumbColor: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
