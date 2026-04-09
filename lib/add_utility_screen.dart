import 'translation_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme_notifier.dart'; 

class AddUtilityScreen extends StatefulWidget {
  const AddUtilityScreen({super.key});

  @override
  State<AddUtilityScreen> createState() => _AddUtilityScreenState();
}

class _AddUtilityScreenState extends State<AddUtilityScreen> {
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedType = 'Electricity';
  bool _isLoading = false;

  Future<void> _submitAction() async {
    final user = FirebaseAuth.instance.currentUser;
    bool isAdmin = user?.email == 'admin@ceb.lk' || user?.email == 'admin@waterboard.lk';

    if (_accountController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      if (isAdmin) {
        
        String assignedUid = '';
        
        
        var previousBills = await FirebaseFirestore.instance.collection('official_bills')
            .where('accountNumber', isEqualTo: _accountController.text.trim())
            .where('type', isEqualTo: _selectedType)
            .get();

        for (var doc in previousBills.docs) {
          var data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('customerUid') && data['customerUid'] != '') {
            assignedUid = data['customerUid'];
            break; 
          }
        }
        

        DateTime calculatedDueDate = DateTime.now().add(const Duration(days: 30));

        await FirebaseFirestore.instance.collection('official_bills').add({
          'accountNumber': _accountController.text.trim(),
          'amount': double.parse(_amountController.text.trim()),
          'type': _selectedType,
          'status': 'Unpaid',
          'customerUid': assignedUid, 
          'createdAt': FieldValue.serverTimestamp(),
          'dueDate': Timestamp.fromDate(calculatedDueDate),
        });

      } else {
       
        if (user != null) {
          
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('linked_accounts')
              .doc(_accountController.text.trim()) 
              .set({
            'accountNumber': _accountController.text.trim(),
            'type': _selectedType,
            'linkedAt': FieldValue.serverTimestamp(),
          });

          
          var billQuery = await FirebaseFirestore.instance
              .collection('official_bills')
              .where('accountNumber', isEqualTo: _accountController.text.trim())
              .where('type', isEqualTo: _selectedType)
              .get();

          if (billQuery.docs.isNotEmpty) {
            WriteBatch batch = FirebaseFirestore.instance.batch();
            for (var doc in billQuery.docs) {
              batch.update(doc.reference, {'customerUid': user.uid});
            }
            await batch.commit();
          }
        }
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = FirebaseAuth.instance.currentUser?.email == 'admin@ceb.lk' || FirebaseAuth.instance.currentUser?.email == 'admin@waterboard.lk';

    bool isDark = themeNotifier.isDark;
    Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F7FB);
    Color panelColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black;
    Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    Color inputFillColor = isDark ? Colors.grey.shade900 : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: bgColor, 
      appBar: AppBar(
        title: Text(isAdmin ? TranslationService.getText('issue_bill') : TranslationService.getText('link_title'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)], begin: Alignment.topLeft, end: Alignment.bottomRight))),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
             
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: panelColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: isDark ? Colors.black45 : Colors.blue.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]
                ),
                child: Column(
                  children: [
                    
                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      dropdownColor: panelColor, 
                      style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF4F46E5)),
                      items: ['Electricity', 'Water'].map((t) => DropdownMenuItem(
                        value: t, 
                        child: Text(t == 'Electricity' ? TranslationService.getText('electricity') : TranslationService.getText('water'), style: TextStyle(color: textColor))
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedType = v!),
                      decoration: InputDecoration(
                        labelText: TranslationService.getText('utility_type'), 
                        labelStyle: TextStyle(color: subTextColor),
                        prefixIcon: Icon(_selectedType == 'Electricity' ? Icons.bolt : Icons.water_drop, color: _selectedType == 'Electricity' ? Colors.orange : Colors.cyan),
                        filled: true,
                        fillColor: inputFillColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    
                    TextField(
                      controller: _accountController,
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: TranslationService.getText('acc_number'), 
                        labelStyle: TextStyle(color: subTextColor),
                        prefixIcon: const Icon(Icons.numbers, color: Color(0xFF4F46E5)),
                        filled: true,
                        fillColor: inputFillColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    
                    if (isAdmin) ...[
                      const SizedBox(height: 20),
                     
                      TextField(
                        controller: _amountController,
                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'Bill Amount (LKR)', 
                          labelStyle: TextStyle(color: subTextColor),
                          prefixIcon: const Icon(Icons.attach_money, color: Colors.green),
                          filled: true,
                          fillColor: inputFillColor,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ],
                  ],
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.2),

              const SizedBox(height: 32),
              
              
              SizedBox(
                width: double.infinity, height: 60,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAdmin ? const Color(0xFFEF4444) : const Color(0xFF4F46E5), 
                    shadowColor: isAdmin ? Colors.redAccent : const Color(0xFF4F46E5).withOpacity(0.5),
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                  ),
                  onPressed: _isLoading ? null : _submitAction,
                  icon: _isLoading ? const SizedBox.shrink() : Icon(isAdmin ? Icons.send : Icons.link, color: Colors.white),
                  label: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : Text(isAdmin ? TranslationService.getText('issue_bill') : TranslationService.getText('link_account'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.5)),
                ),
              ).animate().fade(delay: 400.ms).slideY(begin: 0.5),

            ],
          ),
        ),
      ),
    );
  }
}