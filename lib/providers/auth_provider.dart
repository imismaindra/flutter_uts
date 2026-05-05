import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';

class AuthProvider with ChangeNotifier {
  bool _isAdmin;
  bool _isLoggedIn = false;
  int? _userId;
  String? _userEmail;
  String? _userName;
  String? _userAvatar;

  AuthProvider({bool isAdmin = false}) : _isAdmin = isAdmin;

  bool get isAdmin => _isAdmin;
  bool get isLoggedIn => _isLoggedIn;
  int? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get userAvatar => _userAvatar;

  Future<bool> login(String email, String password) async {
    // 1. Cek di Database
    final userData = await DatabaseHelper.instance.loginUser(email, password);
    
    if (userData != null) {
      _isLoggedIn = true;
      _userId = userData['id'];
      _userEmail = email;
      _userName = userData['name'];
      _userAvatar = userData['avatar'];
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

  Future<bool> register(String email, String password, {String? name}) async {
    // 1. Simpan ke Database
    final result = await DatabaseHelper.instance.registerUser(email, password, name: name);
    
    if (result != -1) {
      _isLoggedIn = true;
      _userId = result;
      _userEmail = email;
      _userName = name ?? email.split('@')[0];
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
    _userId = null;
    _userEmail = null;
    _userName = null;
    _userAvatar = null;
    _isAdmin = false;
    notifyListeners();
  }

  void setAdmin(bool value) {
    _isAdmin = value;
    notifyListeners();
  }

  void toggleAdmin() => setAdmin(!isAdmin);

  // ─── USER MANAGEMENT (ADMIN ONLY) ──────────────────────────────────────────
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> get users => _users;

  Future<void> fetchUsers() async {
    if (!_isAdmin) return;
    _users = await DatabaseHelper.instance.getAllUsers();
    notifyListeners();
  }

  Future<bool> deleteUser(int id) async {
    if (!_isAdmin) return false;
    final result = await DatabaseHelper.instance.deleteUser(id);
    if (result > 0) {
      await fetchUsers();
      return true;
    }
    return false;
  }

  Future<bool> updateProfile({String? name, String? email, String? password, String? avatar}) async {
    if (_userId == null) return false;
    
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (password != null) data['password'] = password;
    if (avatar != null) data['avatar'] = avatar;

    if (data.isEmpty) return true;

    final result = await DatabaseHelper.instance.updateUserProfile(_userId!, data);
    if (result > 0) {
      if (name != null) _userName = name;
      if (email != null) _userEmail = email;
      if (avatar != null) _userAvatar = avatar;
      notifyListeners();
      return true;
    }
    return false;
  }
}
