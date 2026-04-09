import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme_notifier.dart';

class AdminBillsScreen extends StatefulWidget {
  const AdminBillsScreen({super.key});

  @override
  State<AdminBillsScreen> createState() => _AdminBillsScreenState();
}

class _AdminBillsScreenState extends State<AdminBillsScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.isDark;
    Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F7FB);
    Color panelColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black87;
    Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    Color inputFillColor = isDark ? Colors.grey.shade900 : Colors.grey.shade100;

    String adminType = FirebaseAuth.instance.currentUser?.email == 'admin@ceb.lk' 
        ? 'Electricity' 
        : 'Water';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('$adminType Management', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)], begin: Alignment.topLeft, end: Alignment.bottomRight))),
      ),
      body: Column(
        children: [
          // --- 3D SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Search Account Number...',
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
              stream: FirebaseFirestore.instance.collection('official_bills')
                  .where('type', isEqualTo: adminType)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
                
                // --- EMPTY STATE ---
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_off_outlined, size: 80, color: subTextColor.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text('No $adminType bills found.', style: TextStyle(color: subTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ).animate().fade(),
                  );
                }

                var docs = snapshot.data!.docs;

                // Search Filter
                final bills = docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return data.containsKey('accountNumber') && data['accountNumber'].toString().contains(_searchQuery);
                }).toList();

                // Sort Newest First
                bills.sort((a, b) {
                  var aData = a.data() as Map<String, dynamic>;
                  var bData = b.data() as Map<String, dynamic>;
                  Timestamp? aTime = aData['createdAt'] as Timestamp?;
                  Timestamp? bTime = bData['createdAt'] as Timestamp?;
                  if (aTime == null || bTime == null) return 0;
                  return bTime.compareTo(aTime); 
                });

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: bills.length,
                  itemBuilder: (context, index) {
                    var bill = bills[index].data() as Map<String, dynamic>;
                    bool isPaid = bill['status'] == 'Paid';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: panelColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: isDark ? Colors.black45 : const Color(0xFF4F46E5).withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        // 🔔 3D Status Icon
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: isPaid ? const LinearGradient(colors: [Colors.green, Colors.teal]) : const LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: isPaid ? Colors.green.withOpacity(0.4) : Colors.orange.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]
                          ),
                          child: Icon(isPaid ? Icons.check : Icons.pending_actions, color: Colors.white, size: 24),
                        ),
                        title: Text('Account: ${bill['accountNumber']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text('LKR ${bill['amount']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5), fontSize: 15)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: Text(bill['status'], style: TextStyle(color: isPaid ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                          ],
                        ),
                        // 🔔 Premium Delete Button
                        trailing: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                          ),
                          onPressed: () {
                            FirebaseFirestore.instance.collection('official_bills').doc(bills[index].id).delete();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bill deleted successfully!'), backgroundColor: Colors.redAccent));
                          },
                        ),
                      ),
                    ).animate().fade(delay: (50 * index).ms).slideX();
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