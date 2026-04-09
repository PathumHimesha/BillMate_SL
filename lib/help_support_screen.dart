import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'translation_service.dart';
import '../theme_notifier.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
   
    _messages.add({
      'text': "Hello! I am the BillMate AI Assistant 🤖.\nAsk me about paying bills, linking accounts, or setting budgets!",
      'isUser': false
    });
  }

 
  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    
    String userText = _controller.text.trim();
    setState(() {
      _messages.add({'text': userText, 'isUser': true});
      _controller.clear();
      _isTyping = true; 
    });
    
    _scrollToBottom();

    
    Future.delayed(const Duration(milliseconds: 1000), () {
      _generateBotResponse(userText.toLowerCase());
    });
  }

  
  void _generateBotResponse(String input) {
    String botReply = "";

    if (input.contains('pay') || input.contains('bill')) {
      botReply = "To pay a bill, go to your Dashboard, tap on any 'Unpaid' bill in your list, and enter the amount you wish to pay. You will get a PDF receipt after!";
    } else if (input.contains('link') || input.contains('account') || input.contains('add')) {
      botReply = "To link a utility account, click the 'Link My Account' button on the Dashboard. Select 'Water' or 'Electricity' and enter your account number.";
    } else if (input.contains('budget') || input.contains('limit')) {
      botReply = "You can set your monthly budget by going to your Profile screen and clicking 'Set Monthly Budget'.";
    } else if (input.contains('password') || input.contains('security')) {
      botReply = "To update your password, go to the Profile screen and tap on 'Security & Password'.";
    } else if (input.contains('hi') || input.contains('hello')) {
      botReply = "Hi there! How can I assist you with BillMate SL today?";
    } else {
      botReply = "I am a simple AI support bot. Please ask me things like:\n- 'How to pay a bill'\n- 'How to link an account'\n- 'How to change budget'";
    }

    setState(() {
      _isTyping = false;
      _messages.add({'text': botReply, 'isUser': false});
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.isDark;
    Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F7FB);
    Color panelColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(TranslationService.getText('help'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)]))),
      ),
      body: Column(
        children: [
          
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isUser = _messages[index]['isUser'];
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF4F46E5) : panelColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                        bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
                    ),
                    child: Text(
                      _messages[index]['text'],
                      style: TextStyle(fontSize: 15, color: isUser ? Colors.white : textColor),
                    ),
                  ).animate().fade().slideY(begin: 0.1),
                );
              },
            ),
          ),
          
          
          if (_isTyping)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                child: const Text("Bot is typing...", style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)).animate().fade(),
              ),
            ),

         
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: panelColor, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: TranslationService.getText('type_message'),
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(color: Color(0xFF4F46E5), shape: BoxShape.circle),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ).animate().scale(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}