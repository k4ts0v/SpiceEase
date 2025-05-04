import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:spiceease/core/auth/auth_exception.dart';
import 'package:spiceease/core/auth/auth_service.dart';
import 'package:spiceease/core/auth/user_model.dart';
import 'package:spiceease/core/database/firebase_options.dart';

/// A service class to handle user authentication using Firebase.
///
/// Implements the [AuthService] interface and provides authentication-related
/// functionalities like sign-in, sign-out, registration, and state monitoring.
class FirebaseAuthService implements AuthService {
  /// Singleton instance of [FirebaseAuthService] to avoid multiple instances.
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();

  /// Factory constructor to return the singleton instance.
  factory FirebaseAuthService() => _instance;

  /// Private constructor for singleton pattern.
  FirebaseAuthService._internal();

  /// Instance of [FirebaseAuth] to perform authentication operations.
  FirebaseAuth? _auth;

  /// Sets a mock [FirebaseAuth] instance for testing purposes.
  ///
  /// - Parameter [auth]: The mock [FirebaseAuth] instance to set.
  void setTestAuth(FirebaseAuth auth) => _auth = auth;

  /// Configures the service for test mode with optional [auth].
  ///
  /// - Parameter [auth]: A mock [FirebaseAuth] instance to use for testing.
  void configureForTest({FirebaseAuth? auth}) {
    _auth = auth;
  }

  /// Initializes the [FirebaseAuth] instance asynchronously.
  ///
  /// Ensures that the [FirebaseAuth] instance is properly initialized before
  /// performing authentication operations.
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _auth = FirebaseAuth.instance;
  }

  /// Returns the initialized [FirebaseAuth] instance.
  ///
  /// Throws a [StateError] if the instance has not been initialized.
  FirebaseAuth get auth {
    if (_auth == null) {
      throw StateError('FirebaseAuth not initialized');
    }
    return _auth!;
  }

  /// Resets the [FirebaseAuth] instance to null for testing purposes.
  @visibleForTesting
  void resetForTest() {
    _auth = null;
  }

  /// Signs in a user using email and password.
  ///
  /// - Parameters:
  ///   - [email]: The user's email address.
  ///   - [password]: The user's password.
  @override
  Future<void> signIn(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_parseError(e));
    } catch (e) {
      rethrow;
    }
  }

  /// Registers a new user with email and password.
  ///
  /// - Parameters:
  ///   - [email]: The user's email address.
  ///   - [password]: The user's password.
  @override
  Future<void> register(String email, String password) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_parseError(e));
    } catch (e) {
      rethrow;
    }
  }

  /// Signs out the current user.
  @override
  Future<void> signOut() async {
    await auth.signOut();
  }

  /// Monitors the authentication state changes of the user.
  ///
  /// - Returns: A stream of [AppUser] representing the authenticated user,
  ///   or `null` if no user is signed in.
  @override
  Stream<AppUser?> authStateChanges() {
    return _auth!.authStateChanges().map((user) {
      return user != null ? AppUser.fromPlatformUser(user) : null;
    });
  }

  /// Checks whether a user is currently signed in.
  ///
  /// - Returns: `true` if a user is signed in, `false` otherwise.
  @override
  Future<bool> isSignedIn() async {
    try {
      return auth.currentUser != null;
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves the currently signed-in user.
  ///
  /// - Returns: An [AppUser] instance representing the signed-in user,
  ///   or `null` if no user is signed in.
  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final user = _auth?.currentUser;
      if (user == null) return null;
      return AppUser.fromPlatformUser(user);
    } catch (e) {
      throw AuthException('session_expired');
    }
  }

  /// Retrieves the ID token of the currently signed-in user.
  ///
  /// - Returns: The ID token as a [String], or `null` if no user is signed in.
  @override
  Future<String?> getCurrentIdToken() async {
    try {
      return await auth.currentUser?.getIdToken();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_parseError(e));
    } catch (e) {
      rethrow;
    }
  }

  /// Sends a password reset email to the user.
  ///
  /// - Parameter [email]: The email address to send the reset link to.
  @override
  Future<void> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_parseError(e));
    } catch (e) {
      rethrow;
    }
  }

  /// Validates the current session
  /// Returns true if session is valid, false otherwise
  @override
  Future<bool> validateSession() async {
    // Firebase SDK handles session validation automatically
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      await user.reload();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Maps Firebase error codes to application-specific error codes.
  String _parseError(FirebaseAuthException e) {
    final code = e.code.replaceAll('-', '_').toUpperCase();
    switch (code) {
      case 'CHANNEL_ERROR':
      case 'INVALID_EMAIL':
        return 'invalid_email';
      case 'USER_NOT_FOUND':
      case 'WRONG_PASSWORD':
      case 'INVALID_CREDENTIAL':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'invalid_login_credentials';
      case 'EMAIL_ALREADY_IN_USE':
      case 'EMAIL_EXISTS':
        return 'email_already_in_use';
      case 'WEAK_PASSWORD':
        return 'weak_password';
      case 'OPERATION_NOT_ALLOWED':
        return 'operation_not_allowed';
      case 'TOO_MANY_REQUESTS':
      case 'TOO_MANY_ATTEMPTS_TRY_LATER':
        return 'too_many_attempts';
      case 'NETWORK_REQUEST_FAILED':
        return 'network_request_failed';
      case 'REQUIRES_RECENT_LOGIN':
        return 'requires_recent_login';
      case 'USER_DISABLED':
        return 'user_disabled';
      case 'EXPIRED_ACTION_CODE':
      case 'EXPIRED_OOB_CODE':
      case 'TOKEN_EXPIRED':
        return 'session_expired';
      case 'MISSING_PASSWORD':
        return 'missing_password';
      case 'PASSWORD_MISMATCH':
        return 'password_mismatch';
      case 'USERNAME_REQUIRED':
        return 'username_required';
      default:
        // Print for debugging and return the original code for transparency
        debugPrint('Firebase Auth Error - Unmapped code: $code');
        return code.toLowerCase();
    }
  }
}
