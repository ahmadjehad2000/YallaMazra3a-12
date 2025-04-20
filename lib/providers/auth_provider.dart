import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AppAuthProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  bool _isModerator = false;
  bool _isAdmin = false;
  bool _isLocalMod = false;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _googleSignIn = GoogleSignIn();

  AppAuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  AuthStatus get status => _status;
  User? get user => _user;
  bool get isModerator => _isModerator || _isLocalMod;
  bool get isAdmin => _isAdmin;
  bool get isAuthenticated => _user != null || _isLocalMod;

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    _user = firebaseUser;
    if (_user != null) {
      await _checkUserRole(_user!.uid);
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
      _isModerator = false;
      _isAdmin = false;
    }
    notifyListeners();
  }

  Future<void> _checkUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data();
      _isModerator = data?['isModerator'] ?? false;
      _isAdmin = data?['isAdmin'] ?? false;
    } catch (_) {
      _isModerator = false;
      _isAdmin = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      final googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;
      await _checkUserRole(_user!.uid);

      final exists = await _firestore.collection('users').doc(_user!.uid).get();
      if (!exists.exists) {
        await _firestore.collection('users').doc(_user!.uid).set({
          'email': _user!.email,
          'isModerator': false,
          'isAdmin': false,
        });
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _createUserIfNotExists(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();
    if (!docSnapshot.exists) {
      await userDoc.set({
        'email': user.email ?? '',
        'phoneNumber': user.phoneNumber ?? '',
        'isModerator': false,
        'isAdmin': false,
      });
    }
  }

  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;
      await _createUserIfNotExists(_user!);
      await _checkUserRole(_user!.uid);
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }


  Future<void> signInWithPhoneNumberAndPassword(String phone, String password) async {
    try {
      _status = AuthStatus.loading;
      notifyListeners();

      // Try FirebaseAuth first
      final email = "$phone@example.com";
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException {
      // Fallback to Firestore-only mod login
      final query = await _firestore
          .collection('user_auth')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = doc.data();
        if (data['password'] == password) {
          final userQuery = await _firestore
              .collection('users')
              .where('phoneNumber', isEqualTo: phone)
              .limit(1)
              .get();
          if (userQuery.docs.isNotEmpty) {
            final userData = userQuery.docs.first.data();
            _isLocalMod = userData['isModerator'] == true;
            _isAdmin = userData['isAdmin'] == true;
            _status = AuthStatus.authenticated;
            notifyListeners();
            return;
          }
        }
      }

      _status = AuthStatus.unauthenticated;
      notifyListeners();
      throw FirebaseAuthException(code: 'invalid-credentials', message: 'خطأ في رقم الهاتف أو كلمة المرور');
    }
  }

  Future<void> signOut() async {
    _isLocalMod = false;
    _isAdmin = false;
    _isModerator = false;
    _user = null;
    await _auth.signOut();
    await _googleSignIn.signOut();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
