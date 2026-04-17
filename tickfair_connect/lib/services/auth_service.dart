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
    // Initialize GoogleSignIn with Web Client ID
    _googleSignIn = GoogleSignIn(
      clientId: _webClientId, // Required for web platform
      scopes: ['email', 'profile'], // Request scopes
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
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.idToken == null) {
        throw Exception('Failed to obtain ID token from Google');
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw Exception('Firebase: ${e.message}');
    } catch (e) {
      throw Exception('Google Sign-In error: $e');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    return await _auth.signOut();
  }

  /// Current user stream for listening to auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
