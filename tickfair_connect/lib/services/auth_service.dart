import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

/// A simple wrapper around FirebaseAuth for authentication flows.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Use the Firebase web OAuth client ID for mobile server-side token exchange.
  // This is required for GoogleSignIn to return a valid idToken on Android/iOS.
  static const String _webClientId =
      '634102915421-5u86g14u0e0533lgaqdu1oss9rtpf49q.apps.googleusercontent.com';

  final GoogleSignIn? _googleSignIn = kIsWeb
      ? null
      : GoogleSignIn(
          scopes: ['email', 'profile'],
          serverClientId: _webClientId,
          forceCodeForRefreshToken: true,
        );

  AuthService();

  /// Registers a user with email and password.
  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Signs in an existing user.
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Signs in with Google account (Gmail).
  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web-specific Google Sign-In uses Firebase auth popup.
        final provider = GoogleAuthProvider();
        final UserCredential userCredential = await _auth.signInWithPopup(provider);
        return userCredential;
      }

      // Mobile platforms use GoogleSignIn plugin.
      await _googleSignIn?.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn?.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled by user');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null && accessToken == null) {
        throw Exception('Unable to get authentication token from Google. Please try again.');
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Firebase error: ${e.message}';
      if (e.code == 'account-exists-with-different-credential') {
        errorMsg = 'This Google account is already linked to another login method';
      } else if (e.code == 'invalid-credential') {
        errorMsg = 'Invalid credentials. Please try again.';
      } else if (e.code == 'cancelled' || e.message?.contains('closed') == true) {
        errorMsg = 'Sign-in was cancelled. Please try again.';
      }
      throw Exception(errorMsg);
    } on FirebaseException catch (e) {
      String errorMsg = 'Firebase error: ${e.message}';
      if (e.message?.contains('closed') == true || e.message?.contains('popup') == true) {
        errorMsg = 'Sign-in was cancelled. Please try again.';
      }
      throw Exception(errorMsg);
    } catch (e) {
      String errorMsg = '$e';
      if (e.toString().contains('popup_closed') || e.toString().contains('closed')) {
        errorMsg = 'Sign-in was cancelled. Please try again.';
      } else if (e.toString().contains('network')) {
        errorMsg = 'Network error. Please check your internet connection.';
      }
      throw Exception(errorMsg);
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _googleSignIn?.signOut();
    } catch (e) {
      // Ignore errors during sign out
    }
    return await _auth.signOut();
  }

  /// Current user stream for listening to auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current user data as a stream
  Stream<Map<String, dynamic>?> get currentUserData {
    return authStateChanges.asyncMap((user) async {
      if (user == null) return null;
      await user.reload();
      return {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? user.email?.split('@').first ?? 'User',
      };
    });
  }
}
