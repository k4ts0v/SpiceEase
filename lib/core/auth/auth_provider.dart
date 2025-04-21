import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_service.dart';
import 'package:spiceease/core/auth/firebase_auth_rest.dart';
import 'package:spiceease/core/auth/firebase_auth_service.dart';
import 'package:spiceease/core/auth/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Provides an instance of [AuthService] based on the platform.
///
/// - On Linux, it uses [FirebaseAuthRestService], which communicates with the
///   Firebase REST API.
/// - On other platforms, it defaults to [FirebaseAuthService], which uses the
///   Firebase SDK for authentication.
///
/// Example usage:
/// ```dart
/// final authService = ref.watch(authServiceProvider);
/// ```
final authServiceProvider = Provider<AuthService>((ref) {
  if (defaultTargetPlatform == TargetPlatform.linux) {
    /// Use the Firebase REST API for Linux platform.
    return FirebaseAuthRestService(apiKey: dotenv.env['API_KEY_WEB']!);
  }

  /// Use the Firebase SDK for all other platforms.
  return FirebaseAuthService();
});

/// A provider that streams the authentication state of the current user.
///
/// This listens to changes in the authentication state (e.g., user signs in or out)
/// and provides an [AppUser] instance if the user is authenticated or `null` if no user is signed in.
///
/// Example usage:
/// ```dart
/// final authState = ref.watch(authStateProvider);
/// authState.when(
///   data: (user) => user != null ? HomeScreen() : AuthScreen(),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => Text('Error: $error'),
/// );
/// ```
final authStateProvider = StreamProvider<AppUser?>((ref) {
  /// Watch the [authServiceProvider] and listen to authentication state changes.
  return ref.watch(authServiceProvider).authStateChanges();
});
