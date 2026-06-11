import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  UserModel? _user;
  bool _isLoading = false;

  AuthProvider(this._authService) {
    _checkCurrentUser();
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<void> _checkCurrentUser() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _authService.getCurrentUser();
    } catch (e) {
      _user = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _authService.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String curp,
    required String name,
    required String phone,
    required String postalCode,
    required String colonia,
    required String street,
    String? block,
    String? exteriorNumber,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _authService.register({
        'email': email,
        'password': password,
        'curp': curp,
        'name': name,
        'phone': phone,
        'postal_code': postalCode,
        'colonia': colonia,
        'street': street,
        'block': block,
        'exterior_number': exteriorNumber,
      });
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String postalCode,
    required String colonia,
    required String street,
    String? block,
    String? exteriorNumber,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _authService.updateUser({
        'name': name,
        'phone': phone,
        'postal_code': postalCode,
        'colonia': colonia,
        'street': street,
        'block': block,
        'exterior_number': exteriorNumber,
      });
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } finally {
      _user = null;
      notifyListeners();
    }
  }
}
