import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme_notifier.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.isDark;
    Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F7FB);
    Color panelColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black87;
    Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    Color inputFillColor = isDark ? Colors.grey.shade900 : Colors.grey.shade100;

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: bgColor, 
      appBar: AppBar(
        title: const Text('Payment History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)], begin: Alignment.topLeft, end: Alignment.bottomRight))),
      ),
      body: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Search account number or type...',
                hintStyle: TextStyle(color: subTextColor, fontWeight: FontWeight.normal),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4F46E5)),
                filled: true,
                fillColor: inputFillColor, 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
              ),
            ).animate().fade().slideY(begin: -0.2),
          ),

         
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .collection('bills')
                  .orderBy('paidOn', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_toggle_off, size: 80, color: subTextColor.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text('No payment history found.', style: TextStyle(color: subTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ).animate().fade(),
                  );
                }

                var docs = snapshot.data!.docs;
                
               
                var filteredDocs = docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String type = (data['type'] ?? '').toString().toLowerCase();
                  String acct = (data['accountNumber'] ?? '').toString().toLowerCase();
                  return type.contains(_searchQuery) || acct.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var data = filteredDocs[index].data() as Map<String, dynamic>;
                    bool isElec = data['type'] == 'Electricity';
                    
                    
                    String dateStr = '';
                    if (data['paidOn'] != null) {
                      DateTime dt = (data['paidOn'] as Timestamp).toDate();
                      dateStr = "${dt.day}/${dt.month}/${dt.year}";
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: panelColor, 
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: isDark ? Colors.black45 : const Color(0xFF4F46E5).withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        // 🔔 3D Floating Icon
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: isElec ? const LinearGradient(colors: [Colors.orange, Colors.deepOrange]) : const LinearGradient(colors: [Colors.cyan, Colors.blue]),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: isElec ? Colors.orange.withOpacity(0.4) : Colors.cyan.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]
                          ),
                          child: Icon(isElec ? Icons.bolt : Icons.water_drop, color: Colors.white, size: 24),
                        ),
                        title: Text(data['type'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text('Acct: ${data['accountNumber']}', style: TextStyle(color: subTextColor, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('Paid: $dateStr', style: TextStyle(color: subTextColor, fontSize: 12)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('LKR ${data['amount']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5), fontSize: 16)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: const Text('Paid', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading Receipt...')));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.download_rounded, color: Color(0xFF4F46E5), size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fade(delay: (50 * index).ms).slideY(begin: 0.1);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
