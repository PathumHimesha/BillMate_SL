import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

// --- PDF PACKAGES ---
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'add_utility_screen.dart';
import 'bill_details_screen.dart';
import 'payment_history_screen.dart';
import 'notifications_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart'; 
import 'translation_service.dart';
import 'help_support_screen.dart'; 
import '../theme_notifier.dart';
import 'admin_bills_screen.dart';
import 'manage_cards_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final user = FirebaseAuth.instance.currentUser;
  Uint8List? _imageBytes;
  double _monthlyBudget = 15000.0; 
  bool _isPayingAll = false;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    final base64String = prefs.getString('profile_image_${user?.uid}');
    final savedBudget = prefs.getDouble('monthly_budget_${user?.uid}'); 
    
    setState(() {
      if (base64String != null) _imageBytes = base64Decode(base64String);
      if (savedBudget != null) _monthlyBudget = savedBudget;
    });
  }

  void _showNoticeDialog() {
    final titleController = TextEditingController();
    final msgController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        bool isDark = themeNotifier.isDark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.campaign, color: Colors.orange)),
              const SizedBox(width: 10),
              Text('Send Notice', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, style: TextStyle(color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(labelText: 'Title', filled: true, fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
              const SizedBox(height: 10),
              TextField(controller: msgController, maxLines: 3, style: TextStyle(color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(labelText: 'Message...', filled: true, fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                if (titleController.text.isNotEmpty && msgController.text.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('system_notices').add({
                    'title': titleController.text, 'message': msgController.text, 'createdAt': FieldValue.serverTimestamp(),
                  });
                  if (context.mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notice Broadcasted Successfully!'), backgroundColor: Colors.green)); }
                }
              },
              child: const Text('Broadcast', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        );
      }
    );
  }

  Future<void> _generateAdminReport() async {
    // Report generating code (Kept unchanged)
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('official_bills').get();
      final bills = querySnapshot.docs.map((doc) => doc.data()).toList();

      double totalPaid = 0; double totalUnpaid = 0;
      for (var b in bills) {
        if (b['status'] == 'Paid') totalPaid += (b['amount'] ?? 0);
        else totalUnpaid += (b['amount'] ?? 0);
      }

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('BillMate SL', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                pw.Text('Official System Revenue Report', style: const pw.TextStyle(fontSize: 16, color: PdfColors.grey700)),
                pw.SizedBox(height: 30),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Container(padding: const pw.EdgeInsets.all(15), decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.green), borderRadius: pw.BorderRadius.circular(10)), child: pw.Column(children: [pw.Text('Total Collected', style: const pw.TextStyle(color: PdfColors.green)), pw.Text('LKR ${totalPaid.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))])),
                    pw.Container(padding: const pw.EdgeInsets.all(15), decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.orange), borderRadius: pw.BorderRadius.circular(10)), child: pw.Column(children: [pw.Text('Total Pending', style: const pw.TextStyle(color: PdfColors.orange)), pw.Text('LKR ${totalUnpaid.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))])),
                  ]
                ),
                pw.SizedBox(height: 40),
                pw.Text('Detailed Account Breakdown:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headers: ['Utility Type', 'Account Number', 'Amount (LKR)', 'Status'],
                  data: bills.map((b) => [b['type'].toString(), b['accountNumber'].toString(), b['amount'].toString(), b['status'].toString()]).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white), headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800), rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))), cellAlignment: pw.Alignment.centerLeft, cellPadding: const pw.EdgeInsets.all(8),
                ),
              ]
            );
          }
        )
      );
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save(), name: 'BillMate_Revenue_Report.pdf');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to generate report.'), backgroundColor: Colors.redAccent));
    }
  }

  Future<void> _processPayAll(List<QueryDocumentSnapshot> unpaidBills) async {
    if (unpaidBills.isEmpty) return;
    final cardsSnapshot = await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('saved_cards').get();

    if (cardsSnapshot.docs.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a Payment Method first!'), backgroundColor: Colors.orange));
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageCardsScreen()));
      }
      return;
    }

    if (mounted) {
      showModalBottomSheet(
        context: context,
        backgroundColor: themeNotifier.isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Payment Method', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: themeNotifier.isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 16),
                ...cardsSnapshot.docs.map((doc) {
                  var card = doc.data() as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: themeNotifier.isDark ? Colors.black26 : Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(card['type'] == 'Visa' ? Icons.credit_card : Icons.credit_score, color: const Color(0xFF4F46E5))),
                      title: Text('${card['type']} ending in ${card['last4']}', style: TextStyle(color: themeNotifier.isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                      subtitle: Text(card['cardHolder'], style: const TextStyle(color: Colors.grey)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.pop(context);
                        _executePayment(unpaidBills); 
                      },
                    ),
                  );
                }),
              ],
            ),
          );
        }
      );
    }
  }

  Future<void> _executePayment(List<QueryDocumentSnapshot> unpaidBills) async {
    setState(() => _isPayingAll = true);
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in unpaidBills) {
        var billData = doc.data() as Map<String, dynamic>;
        DocumentReference officialRef = FirebaseFirestore.instance.collection('official_bills').doc(doc.id);
        batch.update(officialRef, {'status': 'Paid', 'paidOn': FieldValue.serverTimestamp()});
        DocumentReference historyRef = FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('bills').doc();
        batch.set(historyRef, {
          'type': billData['type'], 'accountNumber': billData['accountNumber'], 'amount': billData['amount'],
          'status': 'Paid', 'paidOn': FieldValue.serverTimestamp(), 'createdAt': billData['createdAt'] ?? FieldValue.serverTimestamp(),
        });
      }
      await batch.commit(); 
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful!'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Failed.'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isPayingAll = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final String userName = user?.displayName ?? 'User';
    bool isAdmin = user?.email == 'admin@ceb.lk' || user?.email == 'admin@waterboard.lk';

    bool isDark = themeNotifier.isDark;
    Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F7FB);
    Color panelColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : const Color(0xFF1E3A8A);
    Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen())),
        backgroundColor: const Color(0xFF4F46E5),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.support_agent, color: Colors.white, size: 28),
      ).animate().scale(delay: 1.seconds, duration: 500.ms, curve: Curves.easeOutBack),

      body: Column(
        children: [
          // --- HEADER (Beautiful Curved Gradient) ---
          Container(
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 40),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              boxShadow: [BoxShadow(color: const Color(0xFF4F46E5).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                          _loadLocalData(); setState(() {}); 
                        },
                        child: Container(
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                          child: CircleAvatar(
                            radius: 26, backgroundColor: Colors.white24,
                            backgroundImage: _imageBytes != null ? MemoryImage(_imageBytes!) as ImageProvider : NetworkImage('https://ui-avatars.com/api/?name=$userName&background=0D8ABC&color=fff&size=128'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isAdmin ? TranslationService.getText('admin_portal') : TranslationService.getText('welcome_billmate'), 
                              style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              userName, 
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Right side Icons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: IconButton(icon: const Icon(Icons.notifications_active, color: Colors.white), tooltip: 'Notifications', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()))),
                    ).animate().shake(delay: 2.seconds, duration: 500.ms),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white), tooltip: 'Logout',
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- MAIN CONTENT ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  
                  // --- ADMIN ANALYTICS CARD ---
                  if (isAdmin)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('official_bills')
                          .where('type', isEqualTo: user?.email == 'admin@ceb.lk' ? 'Electricity' : 'Water')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        double totalPaid = 0; double totalUnpaid = 0;
                        for (var doc in snapshot.data!.docs) {
                          if (doc['status'] == 'Paid') totalPaid += doc['amount'];
                          else totalUnpaid += doc['amount'];
                        }
                        double maxY = (totalPaid > totalUnpaid ? totalPaid : totalUnpaid) * 1.2;
                        if (maxY == 0) maxY = 1000;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 24), padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: panelColor, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.blue.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('System Revenue Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                                  Container(decoration: BoxDecoration(color: const Color(0xFF4F46E5).withOpacity(0.1), shape: BoxShape.circle), child: IconButton(icon: const Icon(Icons.download_for_offline, color: Color(0xFF4F46E5)), onPressed: _generateAdminReport, tooltip: 'Download Report')),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                                      child: Column(children: [const Text('Collected', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text('LKR ${totalPaid.toStringAsFixed(0)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor))]),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                                      child: Column(children: [const Text('Pending', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text('LKR ${totalUnpaid.toStringAsFixed(0)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor))]),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 120,
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround, maxY: maxY, barTouchData: BarTouchData(enabled: false),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                                        return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(value == 0 ? 'Collected' : 'Unpaid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: value == 0 ? Colors.green : Colors.orange)));
                                      })),
                                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    gridData: const FlGridData(show: false), borderData: FlBorderData(show: false),
                                    barGroups: [
                                      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: totalPaid, color: Colors.green, width: 30, borderRadius: BorderRadius.circular(8))]),
                                      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: totalUnpaid, color: Colors.orange, width: 30, borderRadius: BorderRadius.circular(8))]),
                                    ],
                                  ),
                                ),
                              ).animate().fade(delay: 300.ms).scaleY(alignment: Alignment.bottomCenter),
                            ],
                          ),
                        ).animate().fade().slideY(begin: 0.2);
                      },
                    ),

                  // --- ADMIN CARDS ---
                  if (isAdmin)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminBillsScreen())),
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)]), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: const Color(0xFF4F46E5).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]),
                                child: Row(
                                  children: [
                                    Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), child: const Icon(Icons.manage_search, color: Colors.white, size: 36)),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text('Manage Accounts', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                          SizedBox(height: 6),
                                          Text('View, filter and manage user bills', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 24),
                                  ],
                                ),
                              ),
                            ).animate().fade(delay: 400.ms).slideX(),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: _showNoticeDialog, 
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFEF4444)]), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]),
                                child: Row(
                                  children: [
                                    Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle), child: const Icon(Icons.campaign, color: Colors.white, size: 36)),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text('Broadcast Notice', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                          SizedBox(height: 6),
                                          Text('Send a message to all app users', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.send, color: Colors.white, size: 24),
                                  ],
                                ),
                              ),
                            ).animate().fade(delay: 500.ms).slideX(),
                          ],
                        ),
                      ),
                    ),


                  // --- REGULAR USER: BILLS LIST ---
                  if (!isAdmin) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(TranslationService.getText('linked_accounts'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                        Icon(Icons.account_balance_wallet, color: const Color(0xFF4F46E5).withOpacity(0.8)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('official_bills').where('customerUid', isEqualTo: user?.uid).where('status', isEqualTo: 'Unpaid').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text(TranslationService.getText('no_bills'), style: TextStyle(color: subTextColor, fontSize: 16)));

                          final bills = snapshot.data!.docs;

                          return Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  padding: EdgeInsets.zero, itemCount: bills.length,
                                  itemBuilder: (context, index) {
                                    var billData = bills[index].data() as Map<String, dynamic>;
                                    bool isElec = billData['type'] == 'Electricity';

                                    Timestamp? dueTimestamp = billData['dueDate'] as Timestamp?;
                                    int? daysLeft; bool isDueSoon = false; bool isOverdue = false;
                                    
                                    if (dueTimestamp != null) {
                                      DateTime dueDate = dueTimestamp.toDate();
                                      DateTime now = DateTime.now();
                                      daysLeft = dueDate.difference(now).inDays;
                                      if (daysLeft < 0) isOverdue = true;
                                      else if (daysLeft <= 3) isDueSoon = true;
                                    }

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(color: panelColor, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: isDark ? Colors.black26 : const Color(0xFF4F46E5).withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8))]),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.all(16),
                                        leading: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: isElec ? const LinearGradient(colors: [Colors.orange, Colors.deepOrange]) : const LinearGradient(colors: [Colors.cyan, Colors.blue]), shape: BoxShape.circle, boxShadow: [BoxShadow(color: isElec ? Colors.orange.withOpacity(0.4) : Colors.cyan.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]), child: Icon(isElec ? Icons.bolt : Icons.water_drop, color: Colors.white, size: 28)),
                                        title: Text(billData['type'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 6),
                                            Text('Acct: ${billData['accountNumber']}', style: TextStyle(color: subTextColor, fontSize: 14)),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(color: isOverdue ? Colors.red.withOpacity(0.1) : (isDueSoon ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1)), borderRadius: BorderRadius.circular(12)),
                                              child: Text(
                                                isOverdue ? '⚠️ Overdue by ${daysLeft!.abs()} days' : (isDueSoon ? '⏳ Due in $daysLeft days' : '📅 Unpaid'),
                                                style: TextStyle(color: isOverdue ? Colors.redAccent : (isDueSoon ? Colors.orangeAccent : Colors.green), fontWeight: FontWeight.bold, fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text('LKR', style: TextStyle(fontSize: 12, color: subTextColor, fontWeight: FontWeight.bold)),
                                            Text('${billData['amount']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                                          ],
                                        ),
                                        onTap: billData['status'] == 'Paid' ? null : () => Navigator.push(context, MaterialPageRoute(builder: (context) => BillDetailsScreen(billId: bills[index].id, billData: billData))),
                                      ),
                                    ); 
                                  },
                                ),
                              ),
                              if (bills.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: SizedBox(
                                    width: double.infinity, height: 55,
                                    child: ElevatedButton.icon(
                                      onPressed: _isPayingAll ? null : () => _processPayAll(bills),
                                      icon: const Icon(Icons.payment, color: Colors.white),
                                      label: _isPayingAll ? const CircularProgressIndicator(color: Colors.white) : Text(TranslationService.getText('pay_all'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green, 
                                        shadowColor: Colors.greenAccent,
                                        elevation: 8,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                                      ),
                                    ),
                                  ).animate().fade(delay: 300.ms).slideY(begin: 0.5),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],

                  // --- BOTTOM BUTTONS ---
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: SizedBox(
                      width: double.infinity, height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddUtilityScreen())),
                        icon: Icon(isAdmin ? Icons.post_add : Icons.add_link, color: Colors.white),
                        label: Text(isAdmin ? TranslationService.getText('issue_bill') : TranslationService.getText('link_account'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAdmin ? const Color(0xFFEF4444) : const Color(0xFF4F46E5),
                          shadowColor: isAdmin ? Colors.redAccent : const Color(0xFF4F46E5),
                          elevation: 8,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                        ),
                      ),
                    ),
                  ),

                  if (!isAdmin) ...[
                    Center(
                      child: TextButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentHistoryScreen())),
                        icon: const Icon(Icons.history, color: Color(0xFF4F46E5), size: 22),
                        label: Text(TranslationService.getText('view_history'), style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}