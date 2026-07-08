import 'package:flutter/material.dart';
import 'package:lapak_tani/models/user_model.dart';
import 'package:lapak_tani/services/auth_service.dart';
import 'package:lapak_tani/services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  String get userRole => _user?.role ?? '';

  /// Check auth on app start - if Firebase user exists, fetch profile
  Future<void> checkAuth() async {
    try {
      _isLoading = true;
      notifyListeners();

      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        _user = await _authService.getUserProfile(firebaseUser.uid);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await _authService.login(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _parseAuthError(e.toString());
      notifyListeners();
      return false;
    }
  }

  /// Register a new user
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _parseAuthError(e.toString());
      notifyListeners();
      return false;
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.logout();
      _user = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = _parseAuthError(e.toString());
      notifyListeners();
      return false;
    }
  }

  /// Update user in local state (e.g. after profile edit)
  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  /// Update profile to Firestore and update local state
  Future<bool> updateProfile(UserModel updatedUser) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await UserService().updateProfile(updatedUser);
      _user = updatedUser;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Parse Firebase Auth error codes into user-friendly messages
  String _parseAuthError(String error) {
    if (error.contains('user-not-found')) {
      return 'Akun tidak ditemukan. Silakan daftar terlebih dahulu.';
    } else if (error.contains('wrong-password')) {
      return 'Password salah. Silakan coba lagi.';
    } else if (error.contains('email-already-in-use')) {
      return 'Email sudah terdaftar. Silakan gunakan email lain.';
    } else if (error.contains('weak-password')) {
      return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
    } else if (error.contains('invalid-email')) {
      return 'Format email tidak valid.';
    } else if (error.contains('too-many-requests')) {
      return 'Terlalu banyak percobaan. Silakan coba lagi nanti.';
    } else if (error.contains('network-request-failed')) {
      return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
    }
    return 'Terjadi kesalahan: $error';
  }
}
