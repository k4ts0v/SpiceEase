import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/core/auth/user_model.dart';

/// A provider that checks if a user is already signed in by validating stored tokens/session.
/// This works with both Firebase SDK and REST implementations.
final isUserSignedInProvider = FutureProvider<bool>((ref) async {
  try {
    final authService = ref.read(authServiceProvider);

    // Initialize the auth service first
    await authService.initialize();

    // Check if user is signed in using the auth service
    final isSignedIn = await authService.isSignedIn();

    if (isSignedIn) {
      // Validate the session
      final isValid = await authService.validateSession();
      if (!isValid) {
        debugPrint('Session invalid, signing out...');
        await authService.signOut();
        return false;
      }
    }

    return isSignedIn;
  } catch (e) {
    debugPrint('Error checking sign-in status: $e');
    // Clear any stored tokens on error
    try {
      final prefs = await SharedPreferences.getInstance();
      await _clearStoredTokens(prefs);
    } catch (clearError) {
      debugPrint('Error clearing tokens: $clearError');
    }
    return false;
  }
});

/// A provider that fetches the current authenticated user (if any).
final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  try {
    final authService = ref.read(authServiceProvider);

    // Check if user is signed in first
    final isSignedIn = await ref.watch(isUserSignedInProvider.future);

    if (!isSignedIn) {
      return null;
    }

    return await authService.getCurrentUser();
  } catch (e) {
    debugPrint('Error fetching current user: $e');
    return null;
  }
});

/// Helper function to clear stored authentication tokens
Future<void> _clearStoredTokens(SharedPreferences prefs) async {
  await Future.wait([
    prefs.remove('auth_token'),
    prefs.remove('access_token'),
    prefs.remove('refresh_token'),
    prefs.remove('user_data'),
  ]);
}
