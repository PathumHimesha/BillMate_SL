import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dashboard_screen.dart';
import 'signup_screen.dart';
import '../theme_notifier.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  
  String _currentLang = 'si';

  
  final Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'welcome': 'Welcome Back',
      'subtitle': 'Official Utility Billing Portal',
      'email': 'Email Address',
      'password': 'Password',
      'forgot': 'Forgot Password?',
      'login': 'Login',
      'no_account': 'Don\'t have an account?',
      'signup': 'Sign Up',
    },
    'si': {
      'welcome': 'ආපසු සාදරයෙන් පිළිගනිමු',
      'subtitle': 'නිල උපයෝගිතා බිල්පත් ද්වාරය',
      'email': 'විද්‍යුත් තැපෑල',
      'password': 'මුරපදය',
      'forgot': 'මුරපදය අමතකද?',
      'login': 'පිවිසෙන්න',
      'no_account': 'ගිණුමක් නැද්ද?',
      'signup': 'ලියාපදිංචි වන්න',
    },
    'ta': {
      'welcome': 'மீண்டும் வருக',
      'subtitle': 'அதிகாரப்பூர்வ பயன்பாட்டு பில்லிங் போர்டல்',
      'email': 'மின்னஞ்சல்',
      'password': 'கடவுச்சொல்',
      'forgot': 'கடவுச்சொல் மறந்துவிட்டதா?',
      'login': 'உள்நுழைக',
      'no_account': 'கணக்கு இல்லையா?',
      'signup': 'பதிவு செய்க',
    }
  };

  
  String translate(String key) {
    return _localizedStrings[_currentLang]?[key] ?? '';
  }

  Future<void> _loginUser() async {
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Login failed"), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.isDark;
    Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F7FB);
    Color panelColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black87;
    Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    Color inputFillColor = isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- LANGUAGE TOGGLE BUTTONS ---
                  Padding(
                    padding: const EdgeInsets.only(top: 10, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildLangButton('EN', 'en'),
                        const SizedBox(width: 8),
                        _buildLangButton('සිං', 'si'),
                        const SizedBox(width: 8),
                        _buildLangButton('தமிழ்', 'ta'),
                      ],
                    ),
                  ).animate().fade().slideY(begin: -0.2),
                  
                  const SizedBox(height: 20),
                  
                  // --- BANK ICON ---
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                      ),
                      child: const Icon(Icons.account_balance, size: 50, color: Colors.white),
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 16),
                  
                  // --- TITLE & SUBTITLE ---
                  Text(
                    translate('welcome'), 
                    textAlign: TextAlign.center, 
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    translate('subtitle'), 
                    textAlign: TextAlign.center, 
                    style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
                  ).animate().fade(delay: 300.ms),
                  
                  const SizedBox(height: 40),

                  // --- LOGIN FORM CARD ---
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: panelColor, 
                      borderRadius: BorderRadius.circular(32), 
                      boxShadow: [
                        BoxShadow(color: isDark ? Colors.black45 : Colors.blue.withOpacity(0.1), blurRadius: 25, offset: const Offset(0, 15))
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Email Field
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: textColor), 
                          decoration: InputDecoration(
                            hintText: translate('email'),
                            hintStyle: TextStyle(color: subTextColor),
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
                            hintText: translate('password'),
                            hintStyle: TextStyle(color: subTextColor),
                            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF4F46E5)),
                            filled: true,
                            fillColor: inputFillColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Forgot Password
                        TextButton(
                          onPressed: () {
                            // Forgot password logic here
                          },
                          child: Text(translate('forgot'), style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 16),
                        
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
                            onPressed: _isLoading ? null : _loginUser,
                            child: _isLoading 
                              ? const CircularProgressIndicator(color: Colors.white) 
                              : Text(translate('login'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 400.ms).slideY(begin: 0.2),

                  const SizedBox(height: 24),

                  // --- SIGN UP OPTION ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(translate('no_account'), style: TextStyle(color: subTextColor, fontSize: 15)),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
                        child: Text(translate('signup'), style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ).animate().fade(delay: 600.ms),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildLangButton(String text, String langCode) {
    bool isActive = _currentLang == langCode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentLang = langCode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? const Color(0xFF4F46E5) : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
