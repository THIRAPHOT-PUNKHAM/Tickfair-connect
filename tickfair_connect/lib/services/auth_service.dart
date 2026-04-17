import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A simple wrapper around FirebaseAuth for authentication flows.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Web OAuth Client ID from Firebase Console
  // Project: tickfair-connect-ff20d
  static const String _webClientId = '634102915421-h4o1k9m8l7j6i5h4g3f2e1d0c9b8a7f6.apps.googleusercontent.com';
  
  late final GoogleSignIn _googleSignIn;

  AuthService() {
    // Initialize GoogleSignIn
    _googleSignIn = GoogleSignIn(
      clientId: _webClientId,
      scopes: ['email', 'profile'],
      forceCodeForRefreshToken: true,
    );
  }

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
      // Sign out first to show account picker
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled by user');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Unable to get ID token from Google. Please try again.');
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Firebase error: ${e.message}';
      if (e.code == 'account-exists-with-different-credential') {
        errorMsg = 'This Google account is already linked to another login method';
      } else if (e.code == 'invalid-credential') {
        errorMsg = 'Invalid credentials. Please try again.';
      }
      throw Exception(errorMsg);
    } on FirebaseException catch (e) {
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      String errorMsg = '$e';
      if (e.toString().contains('popup_closed')) {
        errorMsg = 'Google Sign-In popup was closed. Please try again.';
      } else if (e.toString().contains('network')) {
        errorMsg = 'Network error. Please check your internet connection.';
      }
      throw Exception(errorMsg);
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignore errors during sign out
    }
    return await _auth.signOut();
  }

  /// Current user stream for listening to auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
