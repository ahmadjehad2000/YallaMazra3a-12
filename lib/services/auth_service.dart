import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user.dart' as app_user;

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current Firebase user
  firebase_auth.User? get currentUser => _auth.currentUser;

  // Sign in with Google
  Future<app_user.User?> signInWithGoogle() async {
    try {
      // Trigger the Google authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Obtain auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Check if user exists in Firestore
        final docSnapshot = await _firestore.collection('users').doc(user.uid).get();

        if (!docSnapshot.exists) {
          // Create a new user if doesn't exist
          final newUser = app_user.User(
            id: user.uid,
            name: user.displayName ?? 'User',
            email: user.email ?? '',
            phoneNumber: user.phoneNumber,
            photoUrl: user.photoURL,
            isGoogleSignIn: true,
            favoriteVillas: [],
            bookings: [],
          );

          await _firestore.collection('users').doc(user.uid).set(newUser.toJson());
          return newUser;
        } else {
          // Return existing user
          return app_user.User.fromJson(docSnapshot.data()!);
        }
      }
      return null;
    } catch (e) {
      print('Google Sign-In error: $e');
      return null;
    }
  }

  // Register with phone and password
  Future<app_user.User?> registerWithPhonePassword({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Create email from phone for Firebase Auth
      final emailFromPhone = _createEmailFromPhone(phone);

      // Register with Firebase
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailFromPhone,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(name);

        // Create user in Firestore
        final newUser = app_user.User(
          id: user.uid,
          name: name,
          email: email,
          phoneNumber: phone,
          photoUrl: null,
          isGoogleSignIn: false,
          favoriteVillas: [],
          bookings: [],
        );

        // Store user profile in Firestore
        await _firestore.collection('users').doc(user.uid).set(newUser.toJson());

        // Store auth information including hashed password
        await _firestore.collection('user_auth').doc(user.uid).set({
          'phone': phone,
          'email': emailFromPhone,
          'password': _hashPassword(password), // Store hashed password
          'createdAt': FieldValue.serverTimestamp(),
        });

        return newUser;
      }
      return null;
    } catch (e) {
      print('Registration error: $e');
      throw e;
    }
  }

  // Sign in with phone and password
  Future<app_user.User?> signInWithPhonePassword(String phone, String password) async {
    try {
      // Create email from phone
      final emailFromPhone = _createEmailFromPhone(phone);

      try {
        // First, try signing in with Firebase Auth
        final userCredential = await _auth.signInWithEmailAndPassword(
            email: emailFromPhone,
            password: password
        );

        final user = userCredential.user;
        if (user != null) {
          // Get user data from Firestore
          final docSnapshot = await _firestore.collection('users').doc(user.uid).get();

          if (docSnapshot.exists) {
            // Update password hash in Firestore if it doesn't exist
            await _updatePasswordHash(user.uid, password);
            return app_user.User.fromJson(docSnapshot.data()!);
          } else {
            // Create basic user if not exists (fallback)
            final newUser = app_user.User(
              id: user.uid,
              name: user.displayName ?? 'User',
              email: user.email ?? '',
              phoneNumber: phone,
              photoUrl: null,
              isGoogleSignIn: false,
              favoriteVillas: [],
              bookings: [],
            );

            await _firestore.collection('users').doc(user.uid).set(newUser.toJson());
            await _updatePasswordHash(user.uid, password);
            return newUser;
          }
        }
      } catch (authError) {
        print('Firebase Auth error: $authError');

        // Try finding user by phone number in Firestore as fallback
        final querySnapshot = await _firestore
            .collection('user_auth')
            .where('phone', isEqualTo: phone)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final authDoc = querySnapshot.docs.first;
          final storedPassword = authDoc['password'];

          // Verify password
          if (storedPassword == _hashPassword(password)) {
            final userId = authDoc.id;
            final userDoc = await _firestore.collection('users').doc(userId).get();

            if (userDoc.exists) {
              // Try to sign in with Firebase Auth for session
              try {
                await _auth.signInWithEmailAndPassword(
                    email: emailFromPhone,
                    password: password
                );
              } catch (e) {
                print('Could not sign in with Firebase Auth: $e');
                // Continue anyway, as we verified password manually
              }

              return app_user.User.fromJson(userDoc.data()!);
            }
          }
        }
      }

      return null;
    } catch (e) {
      print('Phone/Password Sign-In error: $e');
      return null;
    }
  }

  // Update password hash in Firestore
  Future<void> _updatePasswordHash(String userId, String password) async {
    try {
      final authDoc = await _firestore.collection('user_auth').doc(userId).get();

      if (!authDoc.exists || authDoc.data()!['password'] == null) {
        await _firestore.collection('user_auth').doc(userId).set({
          'password': _hashPassword(password),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error updating password hash: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Sign Out error: $e');
    }
  }

  // Get user data
  Future<app_user.User?> getUserData() async {
    final user = _auth.currentUser;

    if (user != null) {
      final docSnapshot = await _firestore.collection('users').doc(user.uid).get();

      if (docSnapshot.exists) {
        return app_user.User.fromJson(docSnapshot.data()!);
      }
    }

    return null;
  }

  // Update user data
  Future<bool> updateUserData(app_user.User userData) async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        // Update Firestore
        await _firestore.collection('users').doc(user.uid).update(userData.toJson());
        return true;
      }

      return false;
    } catch (e) {
      print('Update User Data error: $e');
      return false;
    }
  }

  // Helper method to create email from phone
  String _createEmailFromPhone(String phone) {
    // Remove any non-numeric characters
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return '$cleanPhone@yallamazra3a.app';
  }

  // Helper method to hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}