import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme_notifier.dart'; // 🔔 Dark Mode එකට අදාළ import එක මෙතනට දැම්මා

// --- 1. SECURITY & PASSWORD SCREEN ---
class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    // 🔔 Dark Mode එකට අදාළ පාට ටික
    bool isDark = themeNotifier.isDark;
    Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F7FB);
    Color panelColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : const Color(0xFF1E3A8A);
    Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;
    Color appBarColor = isDark ? const Color(0xFF1F1F1F) : Colors.transparent;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Security', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: appBarColor,
        flexibleSpace: isDark ? null : Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)]))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account Security', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)).animate().fade(),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: panelColor, 
                borderRadius: BorderRadius.circular(16), 
                boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]
              ),
              child: ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), shape: BoxShape.circle), child: const Icon(Icons.password, color: Colors.orange)),
                title: Text('Change Password', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black)),
                subtitle: Text('Update your password directly', style: TextStyle(color: subTextColor)),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: subTextColor),
                onTap: () {
                  final TextEditingController newPasswordController = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: panelColor, // 🔔 Pop-up එකේ පාට
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: Text("Create New Password", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                      content: TextField(
                        controller: newPasswordController,
                        obscureText: true,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: "Enter new password",
                          hintStyle: TextStyle(color: subTextColor),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF4F46E5)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: subTextColor.withOpacity(0.3)), borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: TextStyle(color: subTextColor))),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: () async {
                            if (newPasswordController.text.length >= 6) {
                              try {
                                await user?.updatePassword(newPasswordController.text.trim());
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated successfully!'), backgroundColor: Colors.green));
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Please log out and log back in to do this.'), backgroundColor: Colors.redAccent));
                                }
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters long.'), backgroundColor: Colors.redAccent));
                            }
                          },
                          child: const Text("Save", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ).animate().fade(delay: 100.ms).slideY(),
          ],
        ),
      ),
    );
  }
}

// --- 2. HELP & SUPPORT SCREEN ---
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.isDark;
    Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F7FB);
    Color panelColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : const Color(0xFF1E3A8A);
    Color subTextColor = isDark ? Colors.grey.shade400 : Colors.black87;
    Color appBarColor = isDark ? const Color(0xFF1F1F1F) : Colors.transparent;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: appBarColor,
        flexibleSpace: isDark ? null : Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)]))),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text('Frequently Asked Questions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)).animate().fade(),
          const SizedBox(height: 16),
          _buildFaqTile('How do I add a new bill?', 'Go to the Dashboard and click the big purple "Add Utility Account" button at the bottom.', isDark, panelColor, textColor, subTextColor).animate().fade(delay: 100.ms).slideX(),
          _buildFaqTile('Can I delete a payment?', 'Yes! Go to your Payment History and swipe left on any paid bill to delete it forever.', isDark, panelColor, textColor, subTextColor).animate().fade(delay: 200.ms).slideX(),
          _buildFaqTile('Is my data safe?', 'Yes, all your data is securely stored on Google Firebase servers.', isDark, panelColor, textColor, subTextColor).animate().fade(delay: 300.ms).slideX(),
        ],
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer, bool isDark, Color panelColor, Color textColor, Color subTextColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: panelColor, 
        borderRadius: BorderRadius.circular(16), 
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: ExpansionTile(
        title: Text(question, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        iconColor: const Color(0xFF4F46E5),
        collapsedIconColor: subTextColor,
        children: [Padding(padding: const EdgeInsets.all(16.0), child: Text(answer, style: TextStyle(color: subTextColor)))],
      ),
    );
  }
}

// --- 3. ABOUT SCREEN ---
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.isDark;
    Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F7FB);
    Color textColor = isDark ? Colors.white : const Color(0xFF1E3A8A);
    Color subTextColor = isDark ? Colors.grey.shade400 : Colors.black54;
    Color appBarColor = isDark ? const Color(0xFF1F1F1F) : Colors.transparent;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('About BillMate SL', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: appBarColor,
        flexibleSpace: isDark ? null : Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)]))),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF4F46E5).withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.account_balance_wallet, size: 80, color: Color(0xFF4F46E5)),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text('BillMate SL', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor)).animate().fade(delay: 200.ms),
            Text('Version 1.0.0', style: TextStyle(color: subTextColor)).animate().fade(delay: 300.ms),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Developed as a premium FinTech solution to help users track and manage their utility bills with ease.',
                textAlign: TextAlign.center,
                style: TextStyle(color: subTextColor, height: 1.5),
              ),
            ).animate().fade(delay: 400.ms).slideY(),
          ],
        ),
      ),
    );
  }
}