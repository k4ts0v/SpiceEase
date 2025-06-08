import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/core/auth/auth_service.dart';
import 'package:spiceease/core/auth/auth_exception.dart';
import 'package:spiceease/data/providers/current_user_provider.dart';

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

    setPasswordUpdating(true);

    try {
      await _authService.updatePassword(currentPassword, newPassword);
      setPasswordUpdating(false);
      return AccountSettingsResult.success("Password updated successfully");
    } on AuthException catch (e) {
      setPasswordUpdating(false);

      if (e.message == 'requires_recent_login') {
        return AccountSettingsResult.requiresReauth(() async {
          return await updatePassword(
              currentPassword, newPassword, confirmPassword);
        });
      } else {
        return AccountSettingsResult.failure(e.message);
      }
    } catch (e) {
      setPasswordUpdating(false);
      return AccountSettingsResult.failure(e.toString());
    }
  }

  Future<AccountSettingsResult> reauthenticate(
      String email, String password) async {
    try {
      await _authService.reauthenticate(email, password);
      return AccountSettingsResult.success("Reauthentication successful");
    } on AuthException catch (e) {
      return AccountSettingsResult.failure(e.message);
    } catch (e) {
      return AccountSettingsResult.failure(
          'Authentication failed: ${e.toString()}');
    }
  }

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
      final user = await _ref.read(currentUserProvider.future);
      final isVerified = user?.isEmailVerified ?? false;
      print('DEBUG: User verification status from provider: $isVerified');
      return isVerified;
    } catch (e) {
      print('DEBUG: Error checking email verification in controller: $e');
      return false;
    }
  }

  Future<String?> getCurrentUserEmail() async {
    try {
      final user = await _ref.read(currentUserProvider.future);
      final email = user?.email;
      print('DEBUG: User email from provider: $email');
      return email;
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