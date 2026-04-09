import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OtpResetScreen extends StatefulWidget {
  final String email;
  const OtpResetScreen({super.key, required this.email});

  @override
  State<OtpResetScreen> createState() => _OtpResetScreenState();
}

class _OtpResetScreenState extends State<OtpResetScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  
  // The secret code for your presentation!
  final String _correctOtp = "1234"; 

  @override
  void initState() {
    super.initState();
    // Simulate receiving an SMS after 1.5 seconds (gives the screen time to load)
    Future.delayed(const Duration(milliseconds: 1500), () {
      _showOtpPopup();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) { controller.dispose(); }
    for (var node in _focusNodes) { node.dispose(); }
    super.dispose();
  }

  // --- NEW: We moved the pop-up into its own function so we can reuse it! ---
  void _showOtpPopup() {
    if (mounted) {
      // Clear any existing snackbars first so they don't overlap
      ScaffoldMessenger.of(context).clearSnackBars(); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Message from BillMate: Your verification code is $_correctOtp'),
          backgroundColor: const Color(0xFF1E3A8A),
          duration: const Duration(seconds: 6), // Stays on screen a bit longer
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _verifyOtp() {
    String enteredOtp = _controllers.map((c) => c.text).join();
    
    if (enteredOtp == _correctOtp) {
      _showNewPasswordDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP Code. Please try again.'), backgroundColor: Colors.redAccent)
      );
    }
  }

  void _showNewPasswordDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Create New Password", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
        content: const TextField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: "Enter new password",
            prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF4F46E5)),
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 45),
            ),
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pop(context); 
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password reset successful! Please log in.'), backgroundColor: Colors.green)
              );
            },
            child: const Text("Save & Login", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF4F46E5).withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.mark_email_read_outlined, size: 40, color: Color(0xFF4F46E5)),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            const Text('Enter Verification Code', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))).animate().fade(delay: 100.ms),
            const SizedBox(height: 8),
            Text('We have sent a 4-digit code to ${widget.email}', style: const TextStyle(color: Colors.grey, fontSize: 14)).animate().fade(delay: 200.ms),
            const SizedBox(height: 40),
            
            // --- 4 BOX OTP INPUT ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 60,
                  height: 65,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: const Color(0xFFF4F7FB),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 3) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                      if (value.isNotEmpty && index == 3) {
                        _focusNodes[index].unfocus();
                        _verifyOtp(); 
                      }
                    },
                  ),
                ).animate().fade(delay: (300 + (index * 100)).ms).slideY(begin: 0.2);
              }),
            ),
            
            const Spacer(),
            
            // --- NEW: RESEND CODE BUTTON ---
            Center(
              child: TextButton(
                onPressed: _showOtpPopup,
                child: const Text("Didn't receive the code? Resend", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
              ),
            ).animate().fade(delay: 600.ms),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _verifyOtp,
                child: const Text('Verify', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ).animate().fade(delay: 700.ms).slideY(begin: 0.5),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}