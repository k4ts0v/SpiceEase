import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/core/auth/auth_service.dart';
import 'package:spiceease/core/auth/auth_exception.dart';
import 'package:spiceease/data/providers/unified_auth_provider.dart';

class AccountSettingsController extends StateNotifier<AccountSettingsState> {
  final AuthService _authService;
  final Ref _ref;

  AccountSettingsController(this._authService, this._ref)
      : super(const AccountSettingsState());

  void setEmailUpdating(bool isUpdating) {
    state = state.copyWith(isUpdatingEmail: isUpdating);
  }

  void setPasswordUpdating(bool isUpdating) {
    state = state.copyWith(isUpdatingPassword: isUpdating);
  }

  Future<AccountSettingsResult> updateEmail(String newEmail) async {
    print('DEBUG: Controller - updateEmail called with: $newEmail');

    if (newEmail.isEmpty) {
      return AccountSettingsResult.failure("Email cannot be empty");
    }

    setEmailUpdating(true);

    try {
      print('DEBUG: Controller - calling authService.updateEmail...');
      await _authService.updateEmail(newEmail);
      print('DEBUG: Controller - updateEmail completed successfully');
      setEmailUpdating(false);
      return AccountSettingsResult.success(
          "Email change verification sent to $newEmail. Please check your inbox and click the verification link to complete the change.");
    } on AuthException catch (e) {
      print('DEBUG: Controller - AuthException in updateEmail: ${e.message}');
      setEmailUpdating(false);

      if (e.message.contains('email_already_in_use')) {
        return AccountSettingsResult.failure(
            'An account with this email already exists');
      } else if (e.message.contains('invalid_email')) {
        return AccountSettingsResult.failure(
            'Please enter a valid email address');
      } else if (e.message == 'requires_recent_login') {
        return AccountSettingsResult.requiresReauth(() async {
          return await updateEmail(newEmail);
        });
      } else {
        return AccountSettingsResult.failure(e.message);
      }
    } catch (e, stackTrace) {
      print('DEBUG: Controller - Exception in updateEmail: $e');
      print('DEBUG: Stack trace: $stackTrace');
      setEmailUpdating(false);
      return AccountSettingsResult.failure(
          "Failed to update email: ${e.toString()}");
    }
  }
  Future<AccountSettingsResult> updatePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    print('DEBUG: Controller - updatePassword called');
    print('DEBUG: Current password length: ${currentPassword.length}');
    print('DEBUG: New password length: ${newPassword.length}');
    print('DEBUG: Confirm password length: ${confirmPassword.length}');

    // Validation
    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      return AccountSettingsResult.failure("All fields are required");
    }

    if (newPassword != confirmPassword) {
      return AccountSettingsResult.failure("Passwords don't match");
    }

    if (newPassword.length < 6) {
      return AccountSettingsResult.failure(
          "Password must be at least 6 characters long");
    }

    if (currentPassword == newPassword) {
      return AccountSettingsResult.failure(
          "New password must be different from current password");
    }

    setPasswordUpdating(true);

    try {
      print('DEBUG: Controller - calling authService.updatePassword...');
      
      // Increased timeout to 2 minutes for very slow connections
      await _authService.updatePassword(currentPassword, newPassword)
          .timeout(
            const Duration(seconds: 120), // Increased from 45 to 120 seconds
            onTimeout: () {
              throw Exception('Password update timed out after 2 minutes. Please check your internet connection and try again later.');
            },
          );
      
      print('DEBUG: Controller - updatePassword completed successfully');
      setPasswordUpdating(false);
      return AccountSettingsResult.success("Password updated successfully");
    } on AuthException catch (e) {
      print('DEBUG: Controller - AuthException in updatePassword: ${e.message}');
      setPasswordUpdating(false);

      if (e.message == 'requires_recent_login') {
        return AccountSettingsResult.requiresReauth(() async {
          return await updatePassword(
              currentPassword, newPassword, confirmPassword);
        });
      } else if (e.message.contains('wrong_password') || 
                 e.message.contains('invalid_credential') ||
                 e.message.contains('invalid_login_credentials')) {
        return AccountSettingsResult.failure("Current password is incorrect");
      } else if (e.message.contains('weak_password')) {
        return AccountSettingsResult.failure(
            "Password is too weak. Please choose a stronger password");
      } else if (e.message == 'operation_timeout') {
        return AccountSettingsResult.failure(
            "Operation timed out. This may be due to network issues. Please try again later or check your internet connection.");
      } else {
        return AccountSettingsResult.failure(_parsePasswordError(e.message));
      }
    } catch (e, stackTrace) {
      print('DEBUG: Controller - Exception in updatePassword: $e');
      print('DEBUG: Stack trace: $stackTrace');
      setPasswordUpdating(false);
      
      if (e.toString().contains('timed out') || e.toString().contains('TimeoutException')) {
        return AccountSettingsResult.failure(
            "Password update timed out. This may be due to slow network conditions. Please try again later when you have a better connection.");
      }
      
      return AccountSettingsResult.failure(
          "Failed to update password: ${e.toString()}");
    }
  }


  String _parsePasswordError(String error) {
    switch (error.toLowerCase()) {
      case 'wrong_password':
      case 'invalid_credential':
      case 'invalid_login_credentials':
        return 'Current password is incorrect';
      case 'weak_password':
        return 'Password is too weak. Please choose a stronger password';
      case 'requires_recent_login':
        return 'Please verify your identity to continue';
      case 'operation_timeout':
        return 'Operation timed out. Please check your internet connection and try again';
      case 'network_request_failed':
        return 'Network error. Please check your connection and try again';
      case 'too_many_attempts':
        return 'Too many attempts. Please try again later';
      default:
        return error;
    }
  }

  Future<AccountSettingsResult> reauthenticate(
      String email, String password) async {
    print('DEBUG: Controller - reauthenticate called for email: $email');
    
    try {
      await _authService.reauthenticate(email, password)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Authentication timed out');
            },
          );
      
      print('DEBUG: Controller - reauthenticate successful');
      return AccountSettingsResult.success("Reauthentication successful");
    } on AuthException catch (e) {
      print('DEBUG: Controller - AuthException in reauthenticate: ${e.message}');
      
      if (e.message.contains('wrong_password') || 
          e.message.contains('invalid_credential') ||
          e.message.contains('invalid_login_credentials')) {
        return AccountSettingsResult.failure("Password is incorrect");
      } else if (e.message == 'operation_timeout') {
        return AccountSettingsResult.failure("Authentication timed out. Please try again");
      } else {
        return AccountSettingsResult.failure(_parsePasswordError(e.message));
      }
    } catch (e) {
      print('DEBUG: Controller - Exception in reauthenticate: $e');
      
      if (e.toString().contains('timed out') || e.toString().contains('TimeoutException')) {
        return AccountSettingsResult.failure("Authentication timed out. Please try again");
      }
      
      return AccountSettingsResult.failure(
          'Authentication failed: ${e.toString()}');
    }
  }

// ...existing code...
  Future<AccountSettingsResult> signOut() async {
    try {
      await _authService.signOut();
      return AccountSettingsResult.success("Successfully signed out");
    } catch (e) {
      return AccountSettingsResult.failure("Sign out failed: $e");
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      throw Exception('Failed to send verification email: ${e.toString()}');
    }
  }

  Future<bool> isCurrentEmailVerified() async {
    try {
      final authState = _ref.read(unifiedAuthProvider);
      return authState.when(
        data: (user) {
          final isVerified = user?.isEmailVerified ?? false;
          print('DEBUG: User verification status from provider: $isVerified');
          return isVerified;
        },
        loading: () => false,
        error: (_, __) => false,
      );
    } catch (e) {
      print('DEBUG: Error checking email verification in controller: $e');
      return false;
    }
  }

  Future<String?> getCurrentUserEmail() async {
    try {
      final authState = _ref.read(unifiedAuthProvider);
      return authState.when(
        data: (user) {
          final email = user?.email;
          print('DEBUG: User email from provider: $email');
          return email;
        },
        loading: () => null,
        error: (_, __) => null,
      );
    } catch (e) {
      print('DEBUG: Error getting user email in controller: $e');
      return null;
    }
  }
}

class AccountSettingsState {
  final bool isUpdatingEmail;
  final bool isUpdatingPassword;

  const AccountSettingsState({
    this.isUpdatingEmail = false,
    this.isUpdatingPassword = false,
  });

  AccountSettingsState copyWith({
    bool? isUpdatingEmail,
    bool? isUpdatingPassword,
  }) {
    return AccountSettingsState(
      isUpdatingEmail: isUpdatingEmail ?? this.isUpdatingEmail,
      isUpdatingPassword: isUpdatingPassword ?? this.isUpdatingPassword,
    );
  }
}

class AccountSettingsResult {
  final bool isSuccess;
  final String message;
  final Future<AccountSettingsResult> Function()? retryAction;

  const AccountSettingsResult._({
    required this.isSuccess,
    required this.message,
    this.retryAction,
  });

  factory AccountSettingsResult.success(String message) {
    return AccountSettingsResult._(isSuccess: true, message: message);
  }

  factory AccountSettingsResult.failure(String message) {
    return AccountSettingsResult._(isSuccess: false, message: message);
  }

  factory AccountSettingsResult.requiresReauth(
    Future<AccountSettingsResult> Function() retryAction,
  ) {
    return AccountSettingsResult._(
      isSuccess: false,
      message: "requires_recent_login",
      retryAction: retryAction,
    );
  }
}

final accountSettingsControllerProvider =
    StateNotifierProvider<AccountSettingsController, AccountSettingsState>(
        (ref) {
  final authService = ref.read(authServiceProvider);
  return AccountSettingsController(authService, ref);
});