import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  User? _currentUser;
  String _errorMessage = '';

  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isModerator => _currentUser?.isModerator ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

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

  Future<bool> registerWithPhonePassword({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      _status = AuthStatus.initial;
      _errorMessage = '';
      notifyListeners();

      final user = await _authService.registerWithPhonePassword(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'فشل التسجيل، يرجى المحاولة مرة أخرى';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء التسجيل: ${e.toString()}';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }

  void setAuthenticated(bool value) {
    _status = value ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    try {
      _status = AuthStatus.initial;
      _errorMessage = '';
      notifyListeners();

      final user = await _authService.signInWithGoogle();

      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
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

  Future<bool> signInWithPhonePassword(String phone, String password) async {
    try {
      _errorMessage = '';
      _status = AuthStatus.initial;
      notifyListeners();

      final user = await _authService.signInWithPhonePassword(phone, password);

      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
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

  bool isFavorite(String villaId) {
    return _currentUser?.favoriteVillas.contains(villaId) ?? false;
  }
}
