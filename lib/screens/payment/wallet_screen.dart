import 'package:flutter/material.dart';
import 'package:mini_fiverr/utils/theme.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Wallet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildBalanceSection(),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary), padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('Add Funds', style: TextStyle(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Tooltip(
                    message: "Coming Soon",
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.grey), padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Withdraw', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            _buildTransactionHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20)],
      ),
      child: Column(
        children: [
          const Text('💰 Your Balance', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('\$250.00', style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: AppColors.secondary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
            child: const Text('+ \$25.00 this month', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Transaction History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              _buildTransactionTile('Added Funds', 'Jan 15, 2026', '+\$100.00', AppColors.success),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _buildTransactionTile('Paid to Alice J.', 'Jan 18, 2026', '-\$55.00', AppColors.error),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _buildTransactionTile('Refund Received', 'Jan 20, 2026', '+\$25.00', AppColors.success),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTile(String title, String date, String amount, Color color) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(amount.contains('+') ? Icons.add : Icons.remove, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(date, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
    );
  }
}
