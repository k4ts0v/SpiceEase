import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/core/auth/auth_service.dart';
import 'package:spiceease/core/auth/firebase_auth_rest.dart';
import 'package:spiceease/core/auth/user_model.dart';
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
      isLoading; // Indicates whether an authentication request is currently in progress.
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
  final AuthService _service;

  AuthController(this._service) : super(AuthState.initial()) {
    // Listen to authentication state changes from the AuthService.
    // When a user signs in or out, update the state accordingly.
    _service.authStateChanges().listen((user) {
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
      await _service.resetPassword(email);
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
  /// Displays loading while in progress and sets an error message if it fails.
  Future<void> submit(String email, String password, String? confirmPassword,
      BuildContext context) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (state.isLogin) {
        await _service.signIn(email, password);
      } else {
        if (password != confirmPassword) {
          throw AuthException('password_mismatch');
        }
        await _service.register(email, password);
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
    final message = error
        .toString()
        .toLowerCase()
        .replaceAll(RegExp("authexception: "), "");
    final localizations = AppLocalizations.of(context)!;

    switch (message) {
      case 'invalid_login_credentials' || 'wrong_password' || 'user_not_found':
        return localizations.invalidLoginCredentials;
      case 'email_already_in_use' || 'email_exists':
        return localizations.emailAlreadyInUse;
      case 'missing_password':
        return localizations.missingPassword;
      case 'password_mismatch':
        return localizations.passwordMismatch;
      case 'invalid_email':
        return localizations.invalidEmail;
      case 'session_expired':
        return localizations.sessionExpired;
      case 'password_reset_failed':
        return localizations.resetPasswordError;
      case 'token_expired':
        return localizations.sessionExpired;
      case 'weak_password':
        return "Password should be at least 6 characters. (not localized)";
      default:
        return message;
      // return localizations.unknownError;
    }
  }
}

/// Provides the [AuthController] to the Riverpod dependency injection system.
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final service = ref.read(authServiceProvider);
  return AuthController(service);
});
