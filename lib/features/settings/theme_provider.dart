import 'package:flutter/material.dart';
import 'package:safar/core/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  static const String _prefsKey = 'isDarkMode';

  ThemeProvider() {
    _loadThemePreference();
  }

  bool get isDarkMode => _isDarkMode;
  
  ThemeData get themeData => _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  // Toggle between light and dark themes
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemePreference();
    notifyListeners();
  }

  // Set theme explicitly
  void setDarkMode(bool isDarkMode) {
    _isDarkMode = isDarkMode;
    _saveThemePreference();
    notifyListeners();
  }

  // Load the saved theme preference
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_prefsKey) ?? false;
      notifyListeners();
    } catch (e) {
      // Fall back to default light theme if there's an error
      _isDarkMode = false;
    }
  }

  // Save the current theme preference
  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, _isDarkMode);
    } catch (e) {
      // Silently fail if there's an error saving preferences
    }
  }
} 