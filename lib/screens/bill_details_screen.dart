import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme_notifier.dart';
import 'manage_cards_screen.dart';

class BillDetailsScreen extends StatefulWidget {
  final String billId;
  final Map<String, dynamic> billData;

  const BillDetailsScreen({super.key, required this.billId, required this.billData});

  @override
  State<BillDetailsScreen> createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen> {
  bool _isLoading = false;
  
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.billData['amount'].toString();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    double payingAmount = double.tryParse(_amountController.text) ?? 0.0;
    double totalDue = double.tryParse(widget.billData['amount'].toString()) ?? 0.0;

    if (payingAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount'), backgroundColor: Colors.redAccent));
      return;
    }
    if (payingAmount > totalDue) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You cannot pay more than the total due!'), backgroundColor: Colors.redAccent));
      return;
    }

    final cardsSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('saved_cards').get();

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
                    decoration: BoxDecoration(
                      color: themeNotifier.isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: themeNotifier.isDark ? Colors.grey.shade800 : Colors.grey.shade200)
                    ),
                    child: ListTile(
                      leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]), child: Icon(card['type'] == 'Visa' ? Icons.credit_card : Icons.credit_score, color: const Color(0xFF4F46E5))),
                      title: Text('${card['type']} ending in ${card['last4']}', style: TextStyle(color: themeNotifier.isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                      subtitle: Text(card['cardHolder'], style: const TextStyle(color: Colors.grey)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.pop(context); 
                        _executePayment(payingAmount, totalDue); 
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

  Future<void> _executePayment(double payingAmount, double totalDue) async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      
      double remainingAmount = totalDue - payingAmount;
      DocumentReference officialRef = FirebaseFirestore.instance.collection('official_bills').doc(widget.billId);

      if (remainingAmount <= 0) {
        batch.update(officialRef, {'status': 'Paid', 'amount': 0.0, 'paidOn': FieldValue.serverTimestamp()});
      } else {
        batch.update(officialRef, {'amount': remainingAmount}); 
      }
      
      DocumentReference historyRef = FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('bills').doc();
      batch.set(historyRef, {
        'type': widget.billData['type'], 
        'accountNumber': widget.billData['accountNumber'], 
        'amount': payingAmount, 
        'status': 'Paid', 
        'paidOn': FieldValue.serverTimestamp(), 
        'createdAt': widget.billData['createdAt'] ?? FieldValue.serverTimestamp(),
      });
      
      await batch.commit(); 
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful!'), backgroundColor: Colors.green));
        Navigator.pop(context); 
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Failed.'), backgroundColor: Colors.redAccent));
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
    Color inputFillColor = isDark ? Colors.grey.shade900 : Colors.grey.shade100;
    bool isElec = widget.billData['type'] == 'Electricity';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Bill Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)], begin: Alignment.topLeft, end: Alignment.bottomRight))),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: panelColor, 
                      borderRadius: BorderRadius.circular(32), 
                      boxShadow: [BoxShadow(color: isDark ? Colors.black45 : const Color(0xFF4F46E5).withOpacity(0.08), blurRadius: 25, offset: const Offset(0, 10))]
                    ),
                    child: Column(
                      children: [
                          
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: isElec ? const LinearGradient(colors: [Colors.orange, Colors.deepOrange]) : const LinearGradient(colors: [Colors.cyan, Colors.blue]),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: isElec ? Colors.orange.withOpacity(0.4) : Colors.cyan.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))]
                          ),
                          child: Icon(isElec ? Icons.bolt : Icons.water_drop, size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        Text(widget.billData['type'], style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
                        const SizedBox(height: 4),
                        Text('Account #${widget.billData['accountNumber']}', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24), 
                          child: Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)
                        ),
                        
                        const Text('Total Due', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(
                          'LKR ${widget.billData['amount']}', 
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5), letterSpacing: -0.5)
                        ),
                      ],
                    ),
                  ).animate().fade().slideY(begin: 0.2),
                  
                  const SizedBox(height: 40),
                  
                   
                  Text('Amount to Pay', style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 20, color: Color(0xFF4F46E5), fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      prefixText: 'LKR  ',
                      prefixStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16),
                      filled: true,
                      fillColor: inputFillColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
                    ),
                  ).animate().fade(delay: 200.ms),
                ],
              ),
            ),
          ),
          
           
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity, height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5), 
                  shadowColor: const Color(0xFF4F46E5).withOpacity(0.5),
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                ),
                onPressed: _isLoading ? null : _processPayment,
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Confirm Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
              ),
            ).animate().fade(delay: 400.ms).slideY(begin: 0.5),
          ),
        ],
      ),
    );
  }
}