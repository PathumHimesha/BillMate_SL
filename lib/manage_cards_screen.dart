import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme_notifier.dart';

class ManageCardsScreen extends StatefulWidget {
  const ManageCardsScreen({super.key});

  @override
  State<ManageCardsScreen> createState() => _ManageCardsScreenState();
}

class _ManageCardsScreenState extends State<ManageCardsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  bool _isAddingCard = false;

  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  Future<void> _saveCard() async {
    if (_cardNumberController.text.length < 16) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid Card Number'), backgroundColor: Colors.redAccent));
      return;
    }

    String last4 = _cardNumberController.text.substring(_cardNumberController.text.length - 4);
    String cardType = _cardNumberController.text.startsWith('4') ? 'Visa' : 'MasterCard';

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('saved_cards').add({
      'last4': last4,
      'cardHolder': _cardHolderController.text,
      'expiry': _expiryController.text,
      'type': cardType,
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      _isAddingCard = false;
      _cardNumberController.clear();
      _cardHolderController.clear();
      _expiryController.clear();
      _cvvController.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Card Added Successfully!'), backgroundColor: Colors.green));
    }
  }

  Future<void> _deleteCard(String docId) async {
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('saved_cards').doc(docId).delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Card removed.'), backgroundColor: Colors.orangeAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.isDark;
    Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F7FB);
    Color panelColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black87;
    Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    Color inputFillColor = isDark ? Colors.grey.shade900 : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Payment Methods', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)], begin: Alignment.topLeft, end: Alignment.bottomRight))),
      ),
      body: Column(
        children: [
           
          if (_isAddingCard)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: panelColor, 
                    borderRadius: BorderRadius.circular(32), 
                    boxShadow: [BoxShadow(color: isDark ? Colors.black45 : const Color(0xFF4F46E5).withOpacity(0.08), blurRadius: 25, offset: const Offset(0, 10))]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add New Card', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 24),
                      
                      TextField(
                        controller: _cardNumberController,
                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, letterSpacing: 2),
                        keyboardType: TextInputType.number,
                        maxLength: 16,
                        decoration: InputDecoration(
                          labelText: 'Card Number', labelStyle: TextStyle(color: subTextColor, letterSpacing: 0),
                          prefixIcon: const Icon(Icons.credit_card, color: Color(0xFF4F46E5)),
                          filled: true, fillColor: inputFillColor,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextField(
                        controller: _cardHolderController,
                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'Card Holder Name', labelStyle: TextStyle(color: subTextColor),
                          prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF4F46E5)),
                          filled: true, fillColor: inputFillColor,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _expiryController,
                              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                labelText: 'MM/YY', labelStyle: TextStyle(color: subTextColor),
                                prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF4F46E5), size: 20),
                                filled: true, fillColor: inputFillColor,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _cvvController,
                              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                              obscureText: true,
                              maxLength: 3,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'CVV', labelStyle: TextStyle(color: subTextColor),
                                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF4F46E5), size: 20),
                                counterText: "",  
                                filled: true, fillColor: inputFillColor,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => setState(() => _isAddingCard = false), 
                              child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold))
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 55,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  shadowColor: const Color(0xFF4F46E5).withOpacity(0.5),
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                                ),
                                onPressed: _saveCard,
                                child: const Text('Save Card', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ).animate().fade().slideY(begin: 0.2),
              ),
            )
          else ...[
             
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity, height: 60,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5), 
                    shadowColor: const Color(0xFF4F46E5).withOpacity(0.5),
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                  ),
                  onPressed: () => setState(() => _isAddingCard = true),
                  icon: const Icon(Icons.add_card, color: Colors.white),
                  label: const Text('Add New Payment Method', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ).animate().fade().slideY(begin: -0.2),
            ),

             
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('saved_cards').orderBy('createdAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.credit_card_off, size: 80, color: subTextColor.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text('No saved cards found.', style: TextStyle(color: subTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ).animate().fade(),
                    );
                  }

                  final cards = snapshot.data!.docs;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      var card = cards[index].data() as Map<String, dynamic>;
                      bool isVisa = card['type'] == 'Visa';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isVisa ? [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)] : [const Color(0xFFB91D73), const Color(0xFFF953C6)],
                            begin: Alignment.topLeft, end: Alignment.bottomRight
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: isVisa ? Colors.blue.withOpacity(0.4) : Colors.pink.withOpacity(0.4), 
                              blurRadius: 15, offset: const Offset(0, 8)
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                
                                const Icon(Icons.memory, color: Colors.amberAccent, size: 36),
                               
                                const Icon(Icons.wifi, color: Colors.white70, size: 28),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              '**** **** **** ${card['last4']}', 
                              style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 3, fontWeight: FontWeight.bold, fontFamily: 'monospace')  
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('CARD HOLDER', style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1)),
                                    const SizedBox(height: 4),
                                    Text(card['cardHolder'].toString().toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(card['type'], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                                  ],
                                ),
                              ],
                            ),
                             
                            Align(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: () => _deleteCard(cards[index].id),
                                child: Container(
                                  margin: const EdgeInsets.only(top: 16),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
                                  child: const Text('Remove Card', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                              ),
                            )
                          ],
                        ),
                      ).animate().fade(delay: (100 * index).ms).slideX(begin: 0.2);
                    },
                  );
                },
              ),
            )
          ]
        ],
      ),
    );
  }
}