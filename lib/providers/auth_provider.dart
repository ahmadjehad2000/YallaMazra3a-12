import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, otpSent, otpVerified }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  User? _currentUser;
  String _errorMessage = '';
  String _verificationId = '';

  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String get verificationId => _verificationId;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    if (_authService.currentUser != null) {
      try {
        final userData = await _authService.getUserData();
        if (userData != null) {
          _currentUser = userData;
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
        }
      } catch (e) {
        _status = AuthStatus.unauthenticated;
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // Manual override login method
  void setAuthenticated(bool value) {
    _status = value ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  // Google sign in
  Future<bool> signInWithGoogle() async {
    try {
      _status = AuthStatus.initial;
      _errorMessage = '';
      notifyListeners();

      final user = await _authService.signInWithGoogle();

      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
        _errorMessage = '';
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'فشل تسجيل الدخول باستخدام جوجل';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'فشل تسجيل الدخول باستخدام جوجل: ${e.toString()}';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // Phone/password sign in
  Future<bool> signInWithPhonePassword(String phone, String password) async {
    try {
      if (phone.isEmpty || password.isEmpty) {
        _errorMessage = 'الرجاء إدخال رقم الهاتف وكلمة المرور';
        notifyListeners();
        return false;
      }

      _status = AuthStatus.initial;
      _errorMessage = '';
      notifyListeners();

      final user = await _authService.signInWithPhonePassword(phone, password);

      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
        _errorMessage = '';
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'رقم الهاتف أو كلمة المرور غير صحيحة';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تسجيل الدخول: ${e.toString()}';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Toggle favorite villa
  Future<void> toggleFavorite(String villaId) async {
    if (_currentUser == null) return;

    List<String> updatedFavorites = List.from(_currentUser!.favoriteVillas);

    if (updatedFavorites.contains(villaId)) {
      updatedFavorites.remove(villaId);
    } else {
      updatedFavorites.add(villaId);
    }

    final updatedUser = _currentUser!.copyWith(favoriteVillas: updatedFavorites);
    _currentUser = updatedUser;

    await _authService.updateUserData(updatedUser);
    notifyListeners();
  }

  // Check if villa is favorite
  bool isFavorite(String villaId) {
    return _currentUser?.favoriteVillas.contains(villaId) ?? false;
  }

  // Phone verification methods

  // Request OTP
  Future<bool> requestOTP(String phoneNumber) async {
    try {
      _status = AuthStatus.initial;
      _errorMessage = '';
      notifyListeners();

      // TODO: Implement phone verification via Firebase
      // For now, just simulate OTP sent
      _verificationId = DateTime.now().millisecondsSinceEpoch.toString();
      _status = AuthStatus.otpSent;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ: ${e.toString()}';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // Verify OTP and register
  Future<bool> verifyOTPAndRegister({
    required String otp,
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      _status = AuthStatus.initial;
      _errorMessage = '';
      notifyListeners();

      // TODO: Implement OTP verification via Firebase
      // For now, simulate successful verification
      if (otp == "123456" || true) { // For testing, any OTP works
        // Create user
        final userData = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          photoUrl: null,
          isGoogleSignIn: false,
          favoriteVillas: [],
          bookings: [],
        );

        _currentUser = userData;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'رمز التحقق غير صحيح';
        _status = AuthStatus.otpSent;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ: ${e.toString()}';
      _status = AuthStatus.otpSent;
      notifyListeners();
      return false;
    }
  }
}