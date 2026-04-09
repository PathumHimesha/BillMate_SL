import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart'; 
import '../theme_notifier.dart';
import 'manage_cards_screen.dart';
import 'help_support_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.isDark;
    Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F7FB);
    Color panelColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black87;

    bool isAdmin = user?.email == 'admin@ceb.lk' || user?.email == 'admin@waterboard.lk';
    
    String displayName = user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
    String initials = displayName.length >= 2 ? displayName.substring(0, 2).toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
              boxShadow: [
                BoxShadow(color: const Color(0xFF4F46E5).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
          ).animate().fadeIn(duration: 800.ms),

       
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text('My Profile', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ).animate().fade().slideY(begin: -0.2),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(4), 
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade800 : Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8))],
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: const Color(0xFF4F46E5).withOpacity(0.8),
                              child: Text(initials, style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                        ),
                        const SizedBox(height: 16),
                        Text(displayName, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)).animate().fade(delay: 200.ms),
                        Text(user?.email ?? '', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)).animate().fade(delay: 300.ms),
                        
                        const SizedBox(height: 40),

                       
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: panelColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: isDark ? Colors.black45 : Colors.blue.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
                          ),
                          child: Column(
                            children: [
                             
                              ListTile(
                                leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF4F46E5).withOpacity(0.1), shape: BoxShape.circle), child: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: const Color(0xFF4F46E5))),
                                title: Text('Dark Mode', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                trailing: Switch(
                                  value: isDark,
                                  activeColor: const Color(0xFF4F46E5),
                                  onChanged: (value) {
                                    themeNotifier.toggleTheme();
                                    setState(() {}); 
                                  },
                                ),
                              ),
                              Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
                              
                            
                              if (!isAdmin) ...[
                                ListTile(
                                  leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.credit_card, color: Colors.green)),
                                  title: Text('Payment Methods', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageCardsScreen())),
                                ),
                                Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
                              ],
                              
                             
                              ListTile(
                                leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.cyan.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.help_outline, color: Colors.cyan)),
                                title: Text('Help & Support', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen())),
                              ),
                              Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)),

                              
                              ListTile(
                                leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.info_outline, color: Colors.redAccent)),
                                title: Text('About BillMate SL', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: panelColor,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                      title: const Text('BillMate SL', style: TextStyle(fontWeight: FontWeight.bold)),
                                      content: const Text('Version 1.0.0\nOfficial Utility Billing App for Sri Lanka.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
                                      ],
                                    )
                                  );
                                },
                              ),
                            ],
                          ),
                        ).animate().fade(delay: 400.ms).slideY(begin: 0.2),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
