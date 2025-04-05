import 'package:flutter/foundation.dart';
import 'package:safar/models/user.dart';
import 'package:safar/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = true;
  bool _isLoggedIn = false;
  User? _currentUser;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  User? get currentUser => _currentUser;
  String? get error => _error;

  AuthProvider() {
    checkLoginStatus();
  }

  // Check if user is logged in
  Future<void> checkLoginStatus() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _isLoggedIn = await _apiService.isLoggedIn();
      
      if (_isLoggedIn) {
        _currentUser = await _apiService.getCurrentUser();
      }
    } catch (e) {
      _error = e.toString();
      _isLoggedIn = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.login(email, password);
      _isLoggedIn = true;
      _currentUser = await _apiService.getCurrentUser();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoggedIn = false;
      _currentUser = null;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.register(name, email, password);
      _isLoggedIn = true;
      _currentUser = await _apiService.getCurrentUser();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoggedIn = false;
      _currentUser = null;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.logout();
      _isLoggedIn = false;
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 