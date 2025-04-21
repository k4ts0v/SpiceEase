import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
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
    await auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Registers a new user with email and password.
  ///
  /// - Parameters:
  ///   - [email]: The user's email address.
  ///   - [password]: The user's password.
  @override
  Future<void> register(String email, String password) async {
    await auth.createUserWithEmailAndPassword(email: email, password: password);
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
    return auth.currentUser != null;
  }

  /// Retrieves the currently signed-in user.
  ///
  /// - Returns: An [AppUser] instance representing the signed-in user,
  ///   or `null` if no user is signed in.
  @override
  Future<AppUser?> getCurrentUser() async {
    final user = _auth?.currentUser;
    return user != null ? AppUser.fromPlatformUser(user) : null;
  }

  /// Retrieves the ID token of the currently signed-in user.
  ///
  /// - Returns: The ID token as a [String], or `null` if no user is signed in.
  @override
  Future<String?> getCurrentIdToken() async {
    return auth.currentUser?.getIdToken();
  }

  /// Sends a password reset email to the user.
  ///
  /// - Parameter [email]: The email address to send the reset link to.
  @override
  Future<void> resetPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }
}