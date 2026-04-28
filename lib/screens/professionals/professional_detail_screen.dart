import 'package:flutter/material.dart';
import 'package:mini_fiverr/models/user_model.dart';
import 'package:mini_fiverr/utils/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfessionalDetailScreen extends StatelessWidget {
  final UserModel professional;

  const ProfessionalDetailScreen({super.key, required this.professional});

  void _handleHire(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _HireBottomSheet(professional: professional),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(professional.profilePicUrl, fit: BoxFit.cover),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(professional.name, style: Theme.of(context).textTheme.headlineMedium),
                          Text(professional.professionalTitle ?? '', style: const TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                        ],
                      ),
                      const Icon(Icons.favorite_border, color: AppColors.primary, size: 28),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                        child: Text('\$${professional.hourlyRate}/hr', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      const Text('4.9', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(' (237 reviews)', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('About', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(professional.bio ?? 'No bio provided.', style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.textSecondary)),
                  const SizedBox(height: 32),
                  const Text('Skills', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (professional.skills ?? []).map((s) => Chip(
                      label: Text(s),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.primary, width: 0.5),
                    )).toList(),
                  ),
                  const SizedBox(height: 32),
                  const Text('Experience', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(professional.experience ?? 'N/A', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: () => _handleHire(context),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 54)),
          child: const Text('🚀 Hire Me', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _HireBottomSheet extends StatefulWidget {
  final UserModel professional;
  const _HireBottomSheet({required this.professional});

  @override
  State<_HireBottomSheet> createState() => _HireBottomSheetState();
}

class _HireBottomSheetState extends State<_HireBottomSheet> {
  final _descController = TextEditingController();
  final _budgetController = TextEditingController();

  void _sendRequest() async {
    if (_descController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "⚠️ Please describe your project", backgroundColor: AppColors.error);
      return;
    }
    
    // Logic to create job request in Firestore would go here
    Fluttertoast.showToast(msg: "✅ Request sent to ${widget.professional.name}!", backgroundColor: AppColors.success);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 20, backgroundImage: NetworkImage(widget.professional.profilePicUrl)),
              const SizedBox(width: 12),
              Text('Hire ${widget.professional.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Describe your project', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'I need a... by next week...',
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Budget (USD)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _budgetController,
                      decoration: const InputDecoration(prefixText: '\$ ', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Deadline', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Select Date'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _sendRequest,
            child: const Text('📩 Send Request', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
