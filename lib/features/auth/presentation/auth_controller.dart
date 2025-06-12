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

class AuthState {
  final AppUser? user;
  final bool isLogin;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool isLoading;
  final bool rememberMe;
  final String? error;

  AuthState({
    required this.user,
    required this.isLogin,
    required this.isPasswordVisible,
    required this.isConfirmPasswordVisible,
    required this.isLoading,
    bool? rememberMe,
    this.error,
  }) : rememberMe = rememberMe ?? false;

  factory AuthState.initial() => AuthState(
        user: null,
        isLogin: true,
        isPasswordVisible: false,
        isConfirmPasswordVisible: false,
        isLoading: false,
        rememberMe: false,
        error: null,
      );

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

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;
  final UserService _userService;

  AuthController(this._authService, this._userService)
      : super(AuthState.initial());

  void toggleAuthMode() {
    state = state.copyWith(isLogin: !state.isLogin, error: null);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(
        isConfirmPasswordVisible: !state.isConfirmPasswordVisible);
  }

  void toggleRememberMe() {
    state = state.copyWith(rememberMe: !state.rememberMe);
  }

  Future<void> resetPassword(String email, BuildContext context) async {
    if (email.trim().isEmpty) {
      state = state.copyWith(error: 'Please enter your email address');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.resetPassword(email.trim());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.passwordResetEmail ??
                  'Password reset email sent. Check your inbox.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.resetPasswordError ??
                  'Failed to send reset email. Please try again.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }

      state = state.copyWith(
        isLoading: false,
        error: _parseError(e, context),
      );
    }
  }

  Future<void> submit(
    String email,
    String password,
    String? confirmPassword,
    BuildContext context,
  ) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      state = state.copyWith(error: 'Please fill in all required fields');
      return;
    }

    if (!state.isLogin && (confirmPassword?.trim().isEmpty ?? true)) {
      state = state.copyWith(error: 'Please confirm your password');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      if (state.isLogin) {
        await _authService.signIn(email.trim(), password.trim());
      } else {
        if (password.trim() != confirmPassword?.trim()) {
          throw AuthException('password_mismatch');
        }

        if (password.trim().length < 6) {
          throw AuthException('weak_password');
        }

        final completer = Completer<void>();
        late StreamSubscription subscription;

        subscription = _authService.authStateChanges().listen((user) async {
          if (user != null && !completer.isCompleted) {
            try {
              await _userService.createUser(UserModel(
                id: user.uid,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ));

              subscription.cancel();

              if (!completer.isCompleted) {
                completer.complete();
              }
            } catch (e) {
              subscription.cancel();

              if (!completer.isCompleted) {
                completer.completeError(e);
              }
            }
          }
        });

        await _authService.register(email.trim(), password.trim());

        await completer.future.timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            subscription.cancel();
            throw TimeoutException(
              'Registration completed but profile creation timed out',
              const Duration(seconds: 15),
            );
          },
        );
      }

      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _parseError(e, context),
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = AuthState.initial();
    } catch (e) {
      state = AuthState.initial();
    }
  }

  String _parseError(dynamic error, BuildContext context) {
    String message;

    if (error.toString().toLowerCase().contains('authexception: ')) {
      message = error
          .toString()
          .toLowerCase()
          .replaceAll(RegExp(r'authexception:\s*'), '');
    } else {
      message = error.toString().toLowerCase();
    }

    final localizations = AppLocalizations.of(context);

    switch (message) {
      case 'invalid_login_credentials':
      case 'wrong_password':
      case 'user_not_found':
      case 'invalid_credential':
        return localizations?.invalidLoginCredentials ??
            'Invalid email or password';

      case 'email_already_in_use':
      case 'email_exists':
        return localizations?.emailAlreadyInUse ?? 'Email is already in use';

      case 'missing_password':
        return localizations?.missingPassword ?? 'Password is required';

      case 'password_mismatch':
        return localizations?.passwordMismatch ?? 'Passwords do not match';

      case 'invalid_email':
        return localizations?.invalidEmail ?? 'Invalid email address';

      case 'weak_password':
        return 'Password must be at least 6 characters long';

      case 'session_expired':
      case 'token_expired':
      case 'expired_action_code':
        return localizations?.sessionExpired ??
            'Session expired. Please try again';

      case 'network_request_failed':
        return 'Network error. Please check your connection';

      case 'too_many_attempts':
        return 'Too many attempts. Please try again later';

      case 'user_disabled':
        return 'This account has been disabled';

      case 'requires_recent_login':
        return 'Please sign in again to continue';

      case 'operation_not_allowed':
        return 'This operation is not allowed';

      default:
        if (message.contains('firebase_auth/')) {
          return message.split('firebase_auth/')[1].replaceAll('-', ' ');
        }
        return message.length > 100
            ? 'Authentication failed. Please try again.'
            : message;
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  final userService = ref.read(userServiceProvider);
  return AuthController(authService, userService);
});
