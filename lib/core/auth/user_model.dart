import 'package:firebase_auth/firebase_auth.dart';

/// Represents an application user with unified authentication properties.
///
/// This class provides a platform-agnostic representation of user data,
/// supporting both Firebase authentication and REST API sources. It handles:
/// - User identification (UID)
/// - Authentication state (anonymous vs registered)
/// - Account creation metadata
/// - Cross-platform user data conversion
class AppUser {
  /// Unique persistent identifier for the user across all systems
  ///
  /// This is the primary key for user-related operations and should never
  /// be empty or null. Matches the authentication provider's UID system.
  final String uid;

  /// Verified email address associated with the account
  ///
  /// Null for anonymous users or accounts created without email.
  /// Always use this instead of direct authentication provider's email field.
  final String? email;

  /// Indicates if the user authenticated anonymously
  ///
  /// Defaults to false. Important for differentiating temporary vs permanent
  /// accounts in business logic and data retention policies.
  final bool isAnonymous;

  /// Timestamp of account creation in the authentication system
  ///
  /// Useful for analytics, account age checks, and compliance features.
  /// Null if the authentication provider doesn't supply this information.
  final DateTime? created;

  /// Constructs an [AppUser] instance with required authentication details
  ///
  /// Parameters:
  /// - [uid] : Required unique identifier from authentication provider
  /// - [email] : Optional verified email address
  /// - [isAnonymous] : Default false, set true for temporary accounts
  /// - [created] : Optional account creation timestamp
  const AppUser({
    required this.uid,
    this.email,
    this.isAnonymous = false,
    this.created,
  });

  /// Creates an [AppUser] from Firebase Authentication's [User] object
  ///
  /// Usage:
  /// ```dart
  /// final firebaseUser = FirebaseAuth.instance.currentUser;
  /// final appUser = AppUser.fromFirebase(firebaseUser!);
  /// ```
  ///
  /// Parameters:
  /// - [user] : Authenticated Firebase User object
  ///
  /// Returns fully populated AppUser with mapped Firebase properties
  factory AppUser.fromFirebase(User user) => AppUser(
        uid: user.uid,
        email: user.email,
        isAnonymous: user.isAnonymous,
        created: user.metadata.creationTime,
      );

  /// Creates an [AppUser] from REST API authentication response data
  ///
  /// Handles different API response formats by checking multiple possible
  /// UID field names ('localId' or 'uid'). Throws [ArgumentError] if
  /// essential data is missing.
  ///
  /// Parameters:
  /// - [data] : Map containing user data from REST API response
  ///
  /// Throws:
  /// - [ArgumentError] if UID field is missing or empty
  ///
  /// Returns validated AppUser instance with parsed properties
  factory AppUser.fromRestApi(Map<String, dynamic> data) {
    final uid = data['localId'] ?? data['uid'] ?? '';
    final email = data['email'] ?? '';

    if (uid.isEmpty) throw ArgumentError('Invalid user data - missing UID');

    return AppUser(
      uid: uid,
      email: email.isNotEmpty ? email : null,
      created: data['created'] != null
          ? DateTime.parse(data['created'].toString())
          : DateTime.now(),
      isAnonymous: data['isAnonymous'] ?? false,
    );
  }

  /// Factory method to handle multiple platform user types
  ///
  /// Provides unified entry point for converting different authentication
  /// provider responses into our standard [AppUser] format.
  ///
  /// Parameters:
  /// - [platformUser] : Dynamic authentication provider response object
  ///   Supports:
  ///   - Firebase [User] objects
  ///   - REST API response maps
  ///
  /// Returns:
  /// - [AppUser] if conversion succeeds
  /// - `null` for unsupported platformUser types
  static AppUser? fromPlatformUser(dynamic platformUser) {
    if (platformUser is User) return AppUser.fromFirebase(platformUser);
    if (platformUser is Map<String, dynamic>) {
      return AppUser.fromRestApi(platformUser);
    }
    return null;
  }
}
