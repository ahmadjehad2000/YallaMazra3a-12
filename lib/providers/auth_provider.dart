import 'package:flutter/material.dart';
import '../models/user.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  User? _currentUser;
  String _errorMessage = '';

  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // Mock implementation of Google sign in
  Future<bool> signInWithGoogle() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock successful authentication
      _currentUser = User(
        id: '1',
        name: 'محمد أحمد',
        email: 'mohammed@example.com',
        phoneNumber: '0501234567',
        photoUrl: 'https://ui-avatars.com/api/?name=محمد+أحمد&background=0D8ABC&color=fff',
        isGoogleSignIn: true,
      );
      
      _status = AuthStatus.authenticated;
      _errorMessage = '';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'فشل تسجيل الدخول باستخدام جوجل';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // Mock implementation of phone/password sign in
  Future<bool> signInWithPhonePassword(String phone, String password) async {
    try {
      // Validate input
      if (phone.isEmpty || password.isEmpty) {
        _errorMessage = 'الرجاء إدخال رقم الهاتف وكلمة المرور';
        notifyListeners();
        return false;
      }
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Check mock credentials (in a real app, this would be a server call)
      if (phone == '0501234567' && password == '123456') {
        _currentUser = User(
          id: '2',
          name: 'عبدالله محمد',
          email: 'abdullah@example.com',
          phoneNumber: phone,
          isGoogleSignIn: false,
        );
        
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
      _errorMessage = 'حدث خطأ أثناء تسجيل الدخول';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // Sign out function
  Future<void> signOut() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // Add villa to favorites
  void toggleFavorite(String villaId) {
    if (_currentUser == null) return;

    List<String> updatedFavorites = List.from(_currentUser!.favoriteVillas);
    
    if (updatedFavorites.contains(villaId)) {
      updatedFavorites.remove(villaId);
    } else {
      updatedFavorites.add(villaId);
    }
    
    _currentUser = _currentUser!.copyWith(favoriteVillas: updatedFavorites);
    notifyListeners();
  }

  bool isFavorite(String villaId) {
    return _currentUser?.favoriteVillas.contains(villaId) ?? false;
  }
}
