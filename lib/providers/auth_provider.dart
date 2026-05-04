import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';

class AuthProvider with ChangeNotifier {
  bool _isAdmin;
  bool _isLoggedIn = false;
  String? _userEmail;

  AuthProvider({bool isAdmin = false}) : _isAdmin = isAdmin;

  bool get isAdmin => _isAdmin;
  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;

  Future<bool> login(String email, String password) async {
    // 1. Cek di Database
    final userData = await DatabaseHelper.instance.loginUser(email, password);
    
    if (userData != null) {
      _isLoggedIn = true;
      _userEmail = email;
      _isAdmin = userData['role'] == 'admin';
      notifyListeners();
      return true;
    }

    // 2. Fallback untuk Web (In-Memory Mock)
    if (kIsWeb) {
      if (email.isNotEmpty && password.length >= 6) {
        _isLoggedIn = true;
        _userEmail = email;
        _isAdmin = email.contains('admin');
        notifyListeners();
        return true;
      }
    }
    
    return false;
  }

  Future<bool> register(String email, String password) async {
    // 1. Simpan ke Database
    final result = await DatabaseHelper.instance.registerUser(email, password);
    
    if (result != -1) {
      _isLoggedIn = true;
      _userEmail = email;
      _isAdmin = false; // Default register is user
      notifyListeners();
      return true;
    }

    // 2. Fallback untuk Web
    if (kIsWeb) {
      if (email.isNotEmpty && password.length >= 6) {
        _isLoggedIn = true;
        _userEmail = email;
        _isAdmin = false;
        notifyListeners();
        return true;
      }
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
