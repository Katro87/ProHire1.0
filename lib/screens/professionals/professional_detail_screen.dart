import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mini_fiverr/models/user_model.dart';
import 'package:mini_fiverr/utils/avatar_utils.dart';
import 'package:mini_fiverr/models/job_model.dart';
import 'package:mini_fiverr/providers/user_provider.dart';
import 'package:mini_fiverr/utils/theme.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

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

  Future<void> _toggleFavorite(BuildContext context) async {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.userModel;
    if (currentUser == null) return;

    final favoriteIds = [...(currentUser.favoriteProfessionalIds ?? const [])];
    if (favoriteIds.contains(professional.uid)) {
      favoriteIds.remove(professional.uid);
    } else {
      favoriteIds.add(professional.uid);
    }

    await userProvider.updateUser(currentUser.uid, {'favoriteProfessionalIds': favoriteIds});
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
              background: Container(
                color: AppColors.surfaceLight,
                child: Center(
                  child: AvatarUtils.buildAvatar(name: professional.name, imageUrl: professional.profilePicUrl, radius: 72),
                ),
              ),
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
                      Consumer<UserProvider>(
                        builder: (context, userProvider, _) {
                          final favoriteIds = userProvider.userModel?.favoriteProfessionalIds ?? const [];
                          final isFavorite = favoriteIds.contains(professional.uid);
                          return IconButton(
                            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.redAccent : AppColors.primary, size: 28),
                            onPressed: () => _toggleFavorite(context),
                          );
                        },
                      ),
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
          child: const Text('Hire Me', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
  DateTime? _selectedDeadline;
  bool _isSubmitting = false;

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _selectedDeadline = picked);
    }
  }

  Future<void> _sendRequest() async {
    if (_descController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "⚠️ Please describe your project", backgroundColor: AppColors.error);
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Fluttertoast.showToast(msg: 'Please sign in to send a request.', backgroundColor: AppColors.error);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final userName = currentUser.displayName ?? currentUser.email ?? 'Client';
      final jobRef = FirebaseFirestore.instance.collection('jobs').doc();
      final job = JobModel(
        id: jobRef.id,
        clientId: currentUser.uid,
        clientName: userName,
        professionalId: widget.professional.uid,
        professionalName: widget.professional.name,
        description: _descController.text.trim(),
        budget: double.tryParse(_budgetController.text.trim()) ?? 0.0,
        deadline: _selectedDeadline,
        status: JobStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await jobRef.set(job.toMap());
      Fluttertoast.showToast(msg: 'Request sent to ${widget.professional.name}!', backgroundColor: AppColors.success);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(msg: 'Failed to send request.', backgroundColor: AppColors.error);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
              AvatarUtils.buildAvatar(name: widget.professional.name, imageUrl: widget.professional.profilePicUrl, radius: 20),
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
                      onPressed: _pickDeadline,
                      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text(
                        _selectedDeadline == null ? 'Select Date' : DateFormat('MMM d, yyyy').format(_selectedDeadline!),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _sendRequest,
            child: _isSubmitting
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : const Text('Send Request', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
