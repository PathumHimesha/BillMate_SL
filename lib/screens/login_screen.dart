import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'translation_service.dart';
import 'dashboard_screen.dart';
import 'signup_screen.dart'; 
import '../theme_notifier.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    TranslationService.loadLanguage().then((_) {
      if (mounted) setState(() {}); 
    });
  }

  Future<void> _changeLanguage(String langCode) async {
    await TranslationService.setLanguage(langCode);
    setState(() {});
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text); 
    
    showDialog(
      context: context,
      builder: (context) {
        bool isDark = themeNotifier.isDark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Reset Password', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter your email address to receive a password reset link.', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontSize: 14)),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  filled: true,
                  fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                if (resetEmailController.text.isNotEmpty) {
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(email: resetEmailController.text.trim());
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent! Check your inbox.'), backgroundColor: Colors.green));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.redAccent));
                    }
                  }
                }
              },
              child: const Text('Send Link', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.isDark;
    Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F7FB);
    Color panelColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black; 
    Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // --- HEADER BACKGROUND (Curved Gradient) ---
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Language Switcher
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildLangButton('en', 'EN', isDark),
                        const SizedBox(width: 8),
                        _buildLangButton('si', 'සිං', isDark),
                        const SizedBox(width: 8),
                        _buildLangButton('ta', 'தமிழ்', isDark),
                      ],
                    ).animate().fade().slideY(begin: -0.2),
                    
                    const SizedBox(height: 30),
                    
                    // App Logo & Welcome
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                      ),
                      child: const Icon(Icons.account_balance, size: 60, color: Colors.white),
                    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                    
                    const SizedBox(height: 20),
                    
                    Text(
                      TranslationService.getText('welcome'), 
                      textAlign: TextAlign.center, 
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      TranslationService.getText('subtitle'), 
                      textAlign: TextAlign.center, 
                      style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
                    ).animate().fade(delay: 300.ms),
                    
                    const SizedBox(height: 40),

                    // --- LOGIN CARD ---
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
                          // Email Field
                          TextField(
                            controller: _emailController,
                            style: TextStyle(color: textColor), 
                            decoration: InputDecoration(
                              labelText: TranslationService.getText('email'),
                              labelStyle: TextStyle(color: subTextColor),
                              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF4F46E5)),
                              filled: true,
                              fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Password Field
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: TextStyle(color: textColor), 
                            decoration: InputDecoration(
                              labelText: TranslationService.getText('password'),
                              labelStyle: TextStyle(color: subTextColor),
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF4F46E5)),
                              filled: true,
                              fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showForgotPasswordDialog, 
                              child: Text(TranslationService.getText('forgot'), style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Login Button
                          SizedBox(
                            width: double.infinity, height: 60,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5), 
                                shadowColor: const Color(0xFF4F46E5).withOpacity(0.5),
                                elevation: 8,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                              ),
                              onPressed: _isLoading ? null : _login,
                              child: _isLoading 
                                ? const CircularProgressIndicator(color: Colors.white) 
                                : Text(TranslationService.getText('login_btn'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 400.ms).slideY(begin: 0.2),

                    const SizedBox(height: 32),

                    // --- SIGN UP OPTION ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?", style: TextStyle(color: subTextColor, fontSize: 15)),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                          },
                          child: const Text('Sign Up', style: TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildLangButton(String langCode, String label, bool isDark) {
    bool isSelected = TranslationService.currentLang == langCode;
    return GestureDetector(
      onTap: () => _changeLanguage(langCode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.white : Colors.transparent),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)] : [],
        ),
        child: Text(
          label, 
          style: TextStyle(color: isSelected ? const Color(0xFF4F46E5) : Colors.white, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }
}