import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  bool _isAdmin;
  bool _isLoggedIn = false;
  String? _userEmail;

  AuthProvider({bool isAdmin = false}) : _isAdmin = isAdmin;

  bool get isAdmin => _isAdmin;
  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;

  Future<bool> login(String email, String password) async {
    // Mock authentication delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Simple logic: any email/password works for demo
    if (email.isNotEmpty && password.length >= 6) {
      _isLoggedIn = true;
      _userEmail = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isNotEmpty && password.length >= 6) {
      _isLoggedIn = true;
      _userEmail = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    _userEmail = null;
    _isAdmin = false;
    notifyListeners();
  }

  void setAdmin(bool value) {
    _isAdmin = value;
    notifyListeners();
  }

  void toggleAdmin() => setAdmin(!isAdmin);
}
