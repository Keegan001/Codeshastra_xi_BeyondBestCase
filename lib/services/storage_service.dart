import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safar/core/constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  late SharedPreferences _prefs;
  bool _initialized = false;

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  // Get a string value
  Future<String?> getString(String key) async {
    await _ensureInitialized();
    return _prefs.getString(key);
  }

  // Set a string value
  Future<bool> setString(String key, String value) async {
    await _ensureInitialized();
    return await _prefs.setString(key, value);
  }

  // Get a boolean value
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    await _ensureInitialized();
    return _prefs.getBool(key) ?? defaultValue;
  }

  // Set a boolean value
  Future<bool> setBool(String key, bool value) async {
    await _ensureInitialized();
    return await _prefs.setBool(key, value);
  }

  // Get an integer value
  Future<int> getInt(String key, {int defaultValue = 0}) async {
    await _ensureInitialized();
    return _prefs.getInt(key) ?? defaultValue;
  }

  // Set an integer value
  Future<bool> setInt(String key, int value) async {
    await _ensureInitialized();
    return await _prefs.setInt(key, value);
  }

  // Get an object from JSON
  Future<T?> getObject<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    await _ensureInitialized();
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(json);
    } catch (e) {
      return null;
    }
  }

  // Save an object as JSON
  Future<bool> setObject(String key, Object value) async {
    await _ensureInitialized();
    return await _prefs.setString(key, jsonEncode(value));
  }

  // Get all app settings as a map
  Future<Map<String, dynamic>> getSettings() async {
    await _ensureInitialized();
    final settingsJson = _prefs.getString(StorageKeys.settings);
    if (settingsJson == null) {
      return {};
    }
    
    try {
      return jsonDecode(settingsJson) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  // Save all app settings
  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    await _ensureInitialized();
    return await _prefs.setString(StorageKeys.settings, jsonEncode(settings));
  }

  // Update a specific setting
  Future<bool> updateSetting(String key, dynamic value) async {
    await _ensureInitialized();
    final settings = await getSettings();
    settings[key] = value;
    return await saveSettings(settings);
  }

  // Remove a value
  Future<bool> remove(String key) async {
    await _ensureInitialized();
    return await _prefs.remove(key);
  }

  // Clear all data
  Future<bool> clear() async {
    await _ensureInitialized();
    return await _prefs.clear();
  }

  // Ensure the service is initialized
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }
} 