import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mini_fiverr/models/job_model.dart';
import 'package:mini_fiverr/providers/data_provider.dart';
import 'package:mini_fiverr/utils/theme.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DataProvider data = context.watch<DataProvider>();
    final user = data.currentUser;
    final List<HireRequestModel> completed = data.professionalRequests.where((HireRequestModel request) => request.status == HireRequestStatus.completed).toList();

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Earnings Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: glassCardDecoration(accent: AppColors.secondary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Total Earnings', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text('\$${user.earnings.toStringAsFixed(0)}', style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(child: _statCard('Completed Jobs', '${completed.length}')),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard('Hourly Rate', '\$${user.hourlyRate.toStringAsFixed(0)}/hr')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Recent Completed Jobs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 10),
          if (completed.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No completed jobs yet.', style: TextStyle(color: AppColors.textSecondary)),
            )
          else
            ...completed.map(
              (HireRequestModel request) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
                child: ListTile(
                  title: Text(request.projectTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  subtitle: Text(request.clientName, style: const TextStyle(color: AppColors.textSecondary)),
                  trailing: Text('\$${request.budget.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}