import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  final String key = "theme_mode";
  late SharedPreferences _prefs;
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeNotifier() {
    _loadFromPrefs();
  }

  void toggleTheme() {
    _isDark = !_isDark;
    _saveToPrefs();
    notifyListeners(); // Instantly updates the whole app!
  }

  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _isDark = _prefs.getBool(key) ?? false;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    await _prefs.setBool(key, _isDark);
  }
}

// Global instance to use anywhere in the app
final themeNotifier = ThemeNotifier();