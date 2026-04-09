import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PaymentConfirmationScreen extends StatelessWidget {
  final double amountPaid;  

  const PaymentConfirmationScreen({super.key, required this.amountPaid});

  
  String _formatDate(DateTime date) {
    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    String todayDate = _formatDate(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.green, size: 80),
              ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 32),
              const Text('Payment Successful!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))).animate().fade(delay: 200.ms),
              const SizedBox(height: 16),
              
              
              Text('Amount Paid: LKR ${amountPaid.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, color: Colors.black87)).animate().fade(delay: 300.ms),
              const SizedBox(height: 8),
              Text('Payment Date: $todayDate', style: const TextStyle(fontSize: 16, color: Colors.grey)).animate().fade(delay: 400.ms),
              
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Back to Dashboard', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ).animate().fade(delay: 500.ms).slideY(begin: 0.5),
            ],
          ),
        ),
      ),
    );
  }
}