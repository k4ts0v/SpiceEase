import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/core/auth/user_model.dart';

/// A provider that checks if a user is already signed in.
/// This is watched in the UI to decide navigation.
final isUserSignedInProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.isSignedIn();
});

/// A provider that fetches the current authenticated user (if any).
/// This is useful to fetch the user's details without calling AuthScreen.
final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.getCurrentUser();
});