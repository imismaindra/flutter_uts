import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  bool _isAdmin;

  AuthProvider({bool isAdmin = false}) : _isAdmin = isAdmin;

  bool get isAdmin => _isAdmin;

  void setAdmin(bool value) {
    _isAdmin = value;
    notifyListeners();
  }

  void toggleAdmin() => setAdmin(!isAdmin);
}
