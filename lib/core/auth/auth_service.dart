// Import application domain model
import 'package:spiceease/core/auth/user_model.dart';

/// Abstract authentication service contract defining core auth operations
///
/// Acts as an interface between app components and authentication implementations
/// (e.g., Firebase Auth, AWS Cognito). Provides platform-agnostic authentication API.
abstract class AuthService {
  /// Initializes authentication service backend
  ///
  /// Should be called during app startup to prepare auth system.
  /// Typical implementations: Firebase initialization, auth state listeners setup
  Future<void> initialize() async {}

  /// Authenticates user with email/password credentials
  ///
  /// Returns authenticated user on success, throws auth-specific exceptions on failure
  Future<void> signIn(String email, String password);

  /// Creates new user account with email/password
  ///
  /// Automatically signs in user after successful registration.
  /// Throws registration-specific exceptions for invalid inputs/duplicate accounts
  Future<void> register(String email, String password);

  /// Terminates current user session
  ///
  /// Clears authentication state and any cached credentials
  Future<void> signOut();

  /// Stream of authentication state changes
  ///
  /// Emits [AppUser] when authenticated, `null` when logged out
  /// Listeners receive real-time auth state updates
  Stream<AppUser?> authStateChanges();

  /// Checks if user is currently authenticated
  ///
  /// Returns `true` if valid session exists, `false` otherwise
  Future<bool> isSignedIn();

  /// Retrieves current user's ID token
  ///
  /// Returns JWT token for backend authentication.
  /// Returns `null` if no authenticated user
  Future<String?> getCurrentIdToken();

  /// Gets currently authenticated user profile
  ///
  /// Returns [AppUser] with account details if logged in, `null` otherwise
  Future<AppUser?> getCurrentUser();

  /// Initiates password reset flow for email account
  ///
  /// Sends password reset email to provided address.
  /// Throws exceptions for invalid/non-existent emails
  Future<void> resetPassword(String email);
}