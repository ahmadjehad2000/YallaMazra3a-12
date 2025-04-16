import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_user;

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // For verification ID and resending token
  String? _verificationId;
  int? _resendToken;

  // Phone verification
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    required Function(app_user.User) onVerificationComplete,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (Android only)
          await _auth.signInWithCredential(credential);
          final user = await _getUserData(_auth.currentUser!.uid);
          onVerificationComplete(user);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  // Verify OTP and register user
  Future<app_user.User?> verifyOTPAndRegister({
    required String otp,
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      if (_verificationId == null) {
        throw Exception('Verification ID is null. Request OTP first.');
      }

      // Create credential with OTP
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      // Sign in with credential
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Create user data in Firestore
        final userData = app_user.User(
          id: user.uid,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          photoUrl: null,
          isGoogleSignIn: false,
          favoriteVillas: [],
          bookings: [],
        );

        // Store password hash in a secure way (you may want to improve this)
        await _firestore.collection('user_auth').doc(user.uid).set({
          'phoneNumber': phoneNumber,
          'password': _hashPassword(password), // You should use a proper hashing method
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Store user profile data
        await _firestore.collection('users').doc(user.uid).set(userData.toJson());

        return userData;
      }
      return null;
    } catch (e) {
      print('Error verifying OTP: $e');
      return null;
    }
  }

  // Sign in with phone and password
  Future<app_user.User?> signInWithPhonePassword(String phoneNumber, String password) async {
    try {
      // Look up the user by phone number
      final querySnapshot = await _firestore
          .collection('user_auth')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('User not found');
      }

      final authData = querySnapshot.docs.first;
      final storedPassword = authData['password'];

      // Verify password
      if (storedPassword != _hashPassword(password)) {
        throw Exception('Invalid password');
      }

      final userId = authData.id;

      // Create custom token or sign in with phone verification
      // Note: For production, you should implement a server-side token generation
      // This is just a simplified example

      // Get user data
      return await _getUserData(userId);
    } catch (e) {
      print('Phone/Password Sign-In error: $e');
      return null;
    }
  }

  // Get user data from Firestore
  Future<app_user.User> _getUserData(String userId) async {
    final docSnapshot = await _firestore.collection('users').doc(userId).get();

    if (docSnapshot.exists) {
      return app_user.User.fromJson(docSnapshot.data()!);
    } else {
      // If user doesn't exist in Firestore, create a basic profile
      final firebaseUser = _auth.currentUser!;
      final newUser = app_user.User(
        id: userId,
        name: firebaseUser.displayName ?? 'User',
        email: firebaseUser.email ?? '',
        phoneNumber: firebaseUser.phoneNumber,
        photoUrl: firebaseUser.photoURL,
        isGoogleSignIn: false,
        favoriteVillas: [],
        bookings: [],
      );

      // Save to Firestore
      await _firestore.collection('users').doc(userId).set(newUser.toJson());

      return newUser;
    }
  }

  // Simple password hashing (use a proper method in production)
  String _hashPassword(String password) {
    // In a real app, use a secure hashing algorithm like bcrypt
    // This is just for demonstration
    return password.split('').reversed.join('') + '_hashed';
  }
}