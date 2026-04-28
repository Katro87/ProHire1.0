import 'package:flutter/material.dart';
import 'package:mini_fiverr/utils/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PaymentSimulator extends StatefulWidget {
  final double amount;
  final String professionalName;

  const PaymentSimulator({super.key, required this.amount, required this.professionalName});

  @override
  State<PaymentSimulator> createState() => _PaymentSimulatorState();
}

class _PaymentSimulatorState extends State<PaymentSimulator> {
  bool _isProcessing = false;

  void _handlePay() async {
    setState(() => _isProcessing = true);
    
    // Simulate payment delay
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle, size: 64, color: AppColors.success),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Payment Successful!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('✅ Payment of \$${widget.amount.toStringAsFixed(2)} to ${widget.professionalName} was successful.'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return from simulator
            },
            child: const Text('Great!'),
          ),
        ],
      ),
    );
    
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Secure Payment')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('💰 Payment Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildSummaryRow('Paying to:', widget.professionalName),
                  _buildSummaryRow('Service Amount:', '\$${widget.amount.toStringAsFixed(2)}'),
                  _buildSummaryRow('Fee (5%):', '\$${(widget.amount * 0.05).toStringAsFixed(2)}'),
                  const Divider(height: 32),
                  _buildSummaryRow('Total Amount:', '\$${(widget.amount * 1.05).toStringAsFixed(2)}', isTotal: true),
                ],
              ),
            ),
            const Spacer(),
            if (_isProcessing) 
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Processing payment...', style: TextStyle(fontStyle: FontStyle.italic)),
                ].animate(interval: 200.ms).fade(),
              )
            else
              ElevatedButton(
                onPressed: _handlePay,
                child: Text('Pay Now (\$${(widget.amount * 1.05).toStringAsFixed(2)})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: isTotal ? 20 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.bold, color: isTotal ? AppColors.primary : AppColors.textPrimary)),
        ],
      ),
    );
  }
}
