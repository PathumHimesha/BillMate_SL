import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BillMateApp());
}

class BillMateApp extends StatelessWidget {
  const BillMateApp({super.key});

  @override
  Widget build(BuildContext context) {

    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, child) {
        return MaterialApp(
          title: 'BillMate SL',
          debugShowCheckedModeBanner: false,
          
         
          themeMode: themeNotifier.isDark ? ThemeMode.dark : ThemeMode.light,
          
         
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF312E81),
              primary: const Color(0xFF4F46E5),
              secondary: const Color(0xFF06B6D4),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
          ),

         
          darkTheme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFF121212), 
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF312E81),
              primary: const Color(0xFF4F46E5),
              secondary: const Color(0xFF06B6D4),
              brightness: Brightness.dark, 
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
          ),
          
          home: const LoginScreen(), 
        );
      },
    );
  }
}
