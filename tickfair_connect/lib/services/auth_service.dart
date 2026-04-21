import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _webClientId =
      '634102915421-5u86g14u0e0533lgaqdu1oss9rtpf49q.apps.googleusercontent.com';

  AuthService();

  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        return await _auth.signInWithPopup(provider);
      }

      // ✅ ใช้ API ใหม่ของ google_sign_in v7
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Unable to get ID token from Google');
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Firebase error: ${e.message}';

      if (e.code == 'account-exists-with-different-credential') {
        errorMsg =
            'This Google account is already linked to another login method';
      } else if (e.code == 'invalid-credential') {
        errorMsg = 'Invalid credentials. Please try again.';
      }

      throw Exception(errorMsg);
    } catch (e) {
      String errorMsg = '$e';

      if (e.toString().contains('cancel')) {
        errorMsg = 'Sign-in was cancelled.';
      } else if (e.toString().contains('network')) {
        errorMsg = 'Network error. Please check your internet connection.';
      }

      throw Exception(errorMsg);
    }
  }

  Future<void> signOut() async {
    // Fire-and-forget: do not await GoogleSignIn.signOut() as it can hang
    // indefinitely on Android when the instance was not fully initialized.
    GoogleSignIn.instance.signOut().catchError((_) {});
    try {
      await _auth.signOut();
    } catch (_) {}
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Stream<Map<String, dynamic>?> get currentUserData {
    return authStateChanges.asyncMap((user) async {
      if (user == null) return null;
      await user.reload();
      return {
        'uid': user.uid,
        'email': user.email,
        'displayName':
            user.displayName ?? user.email?.split('@').first ?? 'User',
      };
    });
  }
}