import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dashboard_screen.dart';
import '../theme_notifier.dart'; 

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _registerUser() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match!"), backgroundColor: Colors.redAccent));
      return;
    }
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await userCredential.user?.updateDisplayName(_nameController.text.trim());
      if (mounted) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const DashboardScreen()), (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Registration failed"), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.isDark;
    Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F7FB);
    Color panelColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black; 
    Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    Color inputFillColor = isDark ? Colors.grey.shade900 : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // --- HEADER BACKGROUND (Curved Gradient) ---
          Container(
            height: MediaQuery.of(context).size.height * 0.40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
              boxShadow: [
                BoxShadow(color: const Color(0xFF4F46E5).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 5))
              ],
            ),
          ).animate().fadeIn(duration: 800.ms),

          // --- MAIN CONTENT ---
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back Button & Title
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ).animate().fade().slideX(begin: -0.2),
                    
                    const SizedBox(height: 10),
                    
                    // App Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                      ),
                      child: const Icon(Icons.person_add_alt_1, size: 50, color: Colors.white),
                    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                    
                    const SizedBox(height: 16),
                    
                    const Text(
                      'Create Account', 
                      textAlign: TextAlign.center, 
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
                    
                    const SizedBox(height: 6),
                    
                    Text(
                      'Join BillMate SL today!', 
                      textAlign: TextAlign.center, 
                      style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.8)),
                    ).animate().fade(delay: 300.ms),
                    
                    const SizedBox(height: 32),

                    // --- SIGN UP CARD ---
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: panelColor, 
                        borderRadius: BorderRadius.circular(32), 
                        boxShadow: [
                          BoxShadow(color: isDark ? Colors.black45 : Colors.blue.withOpacity(0.1), blurRadius: 25, offset: const Offset(0, 15))
                        ]
                      ),
                      child: Column(
                        children: [
                          // Name Field
                          TextField(
                            controller: _nameController,
                            style: TextStyle(color: textColor), 
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              labelStyle: TextStyle(color: subTextColor),
                              prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF4F46E5)),
                              filled: true,
                              fillColor: inputFillColor,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Email Field
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: textColor), 
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              labelStyle: TextStyle(color: subTextColor),
                              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF4F46E5)),
                              filled: true,
                              fillColor: inputFillColor,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Password Field
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: TextStyle(color: textColor), 
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: subTextColor),
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF4F46E5)),
                              filled: true,
                              fillColor: inputFillColor,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password Field
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            style: TextStyle(color: textColor), 
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              labelStyle: TextStyle(color: subTextColor),
                              prefixIcon: const Icon(Icons.lock_reset, color: Color(0xFF4F46E5)),
                              filled: true,
                              fillColor: inputFillColor,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Register Button
                          SizedBox(
                            width: double.infinity, height: 60,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5), 
                                shadowColor: const Color(0xFF4F46E5).withOpacity(0.5),
                                elevation: 8,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                              ),
                              onPressed: _isLoading ? null : _registerUser,
                              child: _isLoading 
                                ? const CircularProgressIndicator(color: Colors.white) 
                                : const Text('Register', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 400.ms).slideY(begin: 0.2),

                    const SizedBox(height: 24),

                    // --- LOGIN BACK OPTION ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account?", style: TextStyle(color: subTextColor, fontSize: 15)),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Login', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ],
                    ).animate().fade(delay: 600.ms),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
