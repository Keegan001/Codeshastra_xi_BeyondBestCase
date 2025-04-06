import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:safar/core/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;
  static const String _prefsKey = 'themeMode';

  ThemeProvider() {
    _loadThemePreference();
  }

  AppThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode {
    if (_themeMode == AppThemeMode.system) {
      // Get system brightness
      final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == AppThemeMode.dark;
  }
  
  ThemeData get themeData => isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  // Toggle between light and dark themes
  void toggleTheme() {
    if (_themeMode == AppThemeMode.light) {
      _themeMode = AppThemeMode.dark;
    } else {
      _themeMode = AppThemeMode.light;
    }
    _saveThemePreference();
    notifyListeners();
  }

  // Set theme mode explicitly
  void setThemeMode(AppThemeMode mode) {
    _themeMode = mode;
    _saveThemePreference();
    notifyListeners();
  }
  
  // For backward compatibility
  void setDarkMode(bool isDarkMode) {
    _themeMode = isDarkMode ? AppThemeMode.dark : AppThemeMode.light;
    _saveThemePreference();
    notifyListeners();
  }

  // Load the saved theme preference
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getInt(_prefsKey);
      
      if (savedMode != null) {
        _themeMode = AppThemeMode.values[savedMode];
      } else {
        // Check for legacy preference
        final legacyDarkMode = prefs.getBool('isDarkMode');
        if (legacyDarkMode != null) {
          _themeMode = legacyDarkMode ? AppThemeMode.dark : AppThemeMode.light;
        }
      }
      
      notifyListeners();
    } catch (e) {
      // Fall back to system theme if there's an error
      _themeMode = AppThemeMode.system;
    }
  }

  // Save the current theme preference
  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsKey, _themeMode.index);
    } catch (e) {
      // Silently fail if there's an error saving preferences
    }
  }
  
  // Get a friendly name for each theme mode
  String getThemeModeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'System Default';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }
  
  // Get an icon for each theme mode
  IconData getThemeModeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return Icons.brightness_auto;
      case AppThemeMode.light:
        return Icons.brightness_5;
      case AppThemeMode.dark:
        return Icons.brightness_3;
    }
  }
} 