import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🔔 Admin ද කියලා බලන්න මේක ඕනේ
import 'package:flutter_animate/flutter_animate.dart';
import '../theme_notifier.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.isDark;
    Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F7FB);
    Color panelColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black87;

    // --- 🔔 CHECK IF CURRENT USER IS ADMIN ---
    final user = FirebaseAuth.instance.currentUser;
    bool isAdmin = user?.email == 'admin@ceb.lk' || user?.email == 'admin@waterboard.lk';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Notification Center', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)]))),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Get notices from Firebase ordered by newest first
        stream: FirebaseFirestore.instance.collection('system_notices').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No new notices right now.', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          final notices = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              var noticeDoc = notices[index]; // 🔔 Document එක ගන්නවා (මකන්න ID එක ඕන නිසා)
              var notice = noticeDoc.data() as Map<String, dynamic>;
              
              // Simple Date Formatter
              Timestamp? t = notice['createdAt'] as Timestamp?;
              String dateStr = '';
              if (t != null) {
                DateTime d = t.toDate();
                dateStr = "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} at ${d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour)}:${d.minute.toString().padLeft(2, '0')} ${d.hour >= 12 ? 'PM' : 'AM'}";
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: panelColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), shape: BoxShape.circle),
                      child: const Icon(Icons.campaign, color: Colors.orange, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notice['title'] ?? 'System Notice', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(notice['message'] ?? '', style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade800, fontSize: 14, height: 1.4)),
                          const SizedBox(height: 12),
                          Text(dateStr, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    // --- 🔔 NEW: DELETE BUTTON (ADMIN ONLY) ---
                    if (isAdmin)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        tooltip: 'Delete Notice',
                        onPressed: () {
                          // පොඩි Confirmation එකක් දෙමු එකපාර මැකෙන්නේ නැති වෙන්න
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: panelColor,
                              title: Text('Delete Notice?', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                              content: Text('Are you sure you want to delete this broadcast?', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700)),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance.collection('system_notices').doc(noticeDoc.id).delete();
                                    if (ctx.mounted) Navigator.pop(ctx);
                                  },
                                  child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ).animate().fade(delay: (100 * index).ms).slideY(begin: 0.2); 
            },
          );
        },
      ),
    );
  }
}