import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_exception.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/core/auth/auth_service.dart';
import 'package:spiceease/core/auth/user_model.dart';
import 'package:spiceease/data/models/user_model.dart';
import 'package:spiceease/data/providers/user_provider.dart';
import 'package:spiceease/data/services/user_service.dart';
import 'package:spiceease/l10n/app_localizations.dart';

/// Holds all relevant authentication state for the application.
class AuthState {
  final AppUser?
      user; // Represents the currently signed-in user. If no user is signed in, this will be null.
  final bool
      isLogin; // A flag indicating whether the user is in login mode (true) or registration mode (false).
  final bool
      isPasswordVisible; // Determines if the password field should display the text or hide it.
  final bool
      isConfirmPasswordVisible; // Determines if the password field should display the text or hide it.
  final bool
      isLoading; // Indicates whether an authentication request is currently In progress.
  final bool
      rememberMe; // Indicates whether the user session is going to be remembered or not (non-nullable).
  final String?
      error; // Stores the latest error message received from authentication operations.

  AuthState({
    required this.user,
    required this.isLogin,
    required this.isPasswordVisible,
    required this.isConfirmPasswordVisible,
    required this.isLoading,
    bool? rememberMe, // Accept nullable in constructor but store as non-null
    this.error,
  }) : rememberMe = rememberMe ?? false; // Convert null to false

  /// Creates an initial default state where no user is signed in,
  /// login mode is active, the password is obscured, and no loading or error is present.
  factory AuthState.initial() => AuthState(
        user: null,
        isLogin: true,
        isPasswordVisible: false,
        isConfirmPasswordVisible: false,
        isLoading: false,
        rememberMe: false,
        error: null,
      );

  /// Returns a new copy of the current state with specified changes applied.
  AuthState copyWith({
    AppUser? user,
    bool? isLogin,
    bool? isPasswordVisible,
    bool? isConfirmPasswordVisible,
    bool? isLoading,
    bool? rememberMe,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLogin: isLogin ?? this.isLogin,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isConfirmPasswordVisible:
          isConfirmPasswordVisible ?? this.isConfirmPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      rememberMe: rememberMe ?? this.rememberMe,
      error: error,
    );
  }
}

/// A controller that manages the [AuthState] using Riverpod's [StateNotifier].
class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;
  final UserService _userService;

  AuthController(this._authService, this._userService)
      : super(AuthState.initial()) {
    // Listen to authentication state changes from the AuthService.
    // When a user signs in or out, update the state accordingly.
    _authService.authStateChanges().listen((user) {
      state = state.copyWith(user: user, isLoading: false, error: null);
    });
  }

  /// Toggles between login and registration modes.
  void toggleAuthMode() {
    state = state.copyWith(isLogin: !state.isLogin, error: null);
  }

  /// Toggles the visibility of the password field.
  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  /// Toggles the visibility of the confirm password field.
  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
        isConfirmPasswordVisible: !state.isConfirmPasswordVisible);
  }

  void toggleRememberMe() {
    state = state.copyWith(rememberMe: !state.rememberMe);
  }

  Future<void> resetPassword(String email, BuildContext context) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.resetPassword(email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.passwordResetEmail)),
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.resetPasswordError)),
      );
      state = state.copyWith(
        isLoading: false,
        error: _parseError(e, context),
      );
    }
  }

  /// Handles user sign-in or registration depending on the current mode.
  /// Displays loading while In progress and sets an error message if it fails.
  Future<void> submit(
    String email,
    String password,
    String? confirmPassword,
    String? username,
    BuildContext context,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (state.isLogin) {
        await _authService.signIn(email, password);
      } else {
        if (password != confirmPassword) {
          throw AuthException('password_mismatch');
        }
        if (username == null || username.isEmpty) {
          throw AuthException('username_required');
        }

        // Start listening for auth changes before registration
        final completer = Completer<void>();
        final sub = _authService.authStateChanges().listen((user) async {
          if (user != null && !completer.isCompleted) {
            try {
              // Create user profile in database
              await _userService.createUser(UserModel(
                id: user.uid,
                username: username,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ));
              completer.complete();
            } catch (e) {
              if (!completer.isCompleted) {
                completer.completeError(e);
              }
            }
          }
        });

        // Perform registration
        await _authService.register(email, password);

        // Wait for the auth change to complete (with timeout for safety)
        await completer.future.timeout(const Duration(seconds: 10));
        sub.cancel();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _parseError(e, context),
      );
    }
  }

  /// Interprets known exception types and returns a user-friendly error message
  /// based on the contents of their messages. This avoids relying on the exception
  /// class names and instead handles errors by matching message contents.
  String _parseError(dynamic error, BuildContext context) {
    String message;

    // Handle AuthException format
    if (error.toString().toLowerCase().contains('authexception: ')) {
      message = error
          .toString()
          .toLowerCase()
          .replaceAll(RegExp(r'authexception:\s*'), '');
    } else {
      // Handle raw error messages
      message = error.toString().toLowerCase();
    }

    debugPrint('Auth Error Message: $message'); // For debugging
    final localizations = AppLocalizations.of(context)!;

    switch (message) {
      case 'invalid_login_credentials':
      case 'wrong_password':
      case 'user_not_found':
      case 'invalid_credential':
        return localizations.invalidLoginCredentials;
      case 'email_already_in_use':
      case 'email_exists':
        return localizations.emailAlreadyInUse;
      case 'missing_password':
        return localizations.missingPassword;
      case 'password_mismatch':
        return localizations.passwordMismatch;
      case 'invalid_email':
        return localizations.invalidEmail;
      case 'session_expired':
      case 'token_expired':
      case 'expired_action_code':
        return localizations.sessionExpired;
      case 'network_request_failed':
      // return localizations.networkError;
      case 'too_many_attempts':
      // return localizations.tooManyAttempts;
      case 'user_disabled':
      // return localizations.userDisabled;
      case 'requires_recent_login':
      // return localizations.requiresRecentLogin;
      case 'operation_not_allowed':
      // return localizations.operationNotAllowed;
      case 'weak_password':
      // return localizations.weakPassword;
      case 'username_required':
      // return localizations.usernameRequired;
      default:
        debugPrint('Unhandled auth error: $message');
        // Return the message instead of a generic error
        return message.contains('firebase_auth/')
            ? message.split('firebase_auth/')[1]
            : message;
    }
  }
}

/// Provides the [AuthController] to the Riverpod dependency injection system.
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  final userService =
      ref.read(userServiceProvider); // Make sure this provider exists
  return AuthController(authService, userService);
});
