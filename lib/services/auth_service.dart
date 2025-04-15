import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart' as app_user;

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
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
        // Create a user object from Firebase user
        return app_user.User(
          id: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          phoneNumber: user.phoneNumber,
          photoUrl: user.photoURL,
          isGoogleSignIn: true,
          favoriteVillas: [],
          bookings: [],
        );
      }

      return null;
    } catch (e) {
      print('Google Sign-In error: $e');
      return null;
    }
  }

  // Sign in with email & password
  Future<app_user.User?> signInWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        return app_user.User(
          id: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          phoneNumber: user.phoneNumber,
          photoUrl: user.photoURL,
          isGoogleSignIn: false,
          favoriteVillas: [],
          bookings: [],
        );
      }

      return null;
    } catch (e) {
      print('Email/Password Sign-In error: $e');
      return null;
    }
  }

  // Sign in with phone number and password
  Future<app_user.User?> signInWithPhonePassword(String phone, String password) async {
    try {
      // In a real app, you would validate against your user database
      // For now, we'll use a workaround with email sign-in

      // Convert phone to email for testing purposes
      // This is just a mock implementation
      final email = '$phone@example.com';

      return await signInWithEmailPassword(email, password);
    } catch (e) {
      print('Phone/Password Sign-In error: $e');
      return null;
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
      // Determine if user signed in with Google
      bool isGoogleSignIn = user.providerData
          .any((provider) => provider.providerId == 'google.com');

      return app_user.User(
        id: user.uid,
        name: user.displayName ?? 'User',
        email: user.email ?? '',
        phoneNumber: user.phoneNumber,
        photoUrl: user.photoURL,
        isGoogleSignIn: isGoogleSignIn,
        favoriteVillas: [],
        bookings: [],
      );
    }

    return null;
  }

  // Update user data
  Future<bool> updateUserData(app_user.User userData) async {
    try {
      // In a real app with Firestore, you would update the user document
      // For now, we'll implement a basic update of the profile
      final user = _auth.currentUser;

      if (user != null) {
        // Update displayName if different
        if (user.displayName != userData.name) {
          await user.updateDisplayName(userData.name);
        }

        // Note: Updating email, phone, etc. requires additional verification
        // which we're not implementing here for simplicity

        return true;
      }

      return false;
    } catch (e) {
      print('Update User Data error: $e');
      return false;
    }
  }
}