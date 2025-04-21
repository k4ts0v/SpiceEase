// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get signIn => 'Sign In';

  @override
  String get register => 'Register';

  @override
  String get createAccount => 'Create new account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get sessionExpired => 'Session expired. Please login again.';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get recoveryEmailSent => 'A recovery email has been sent.';

  @override
  String get invalidLoginCredentials => 'Incorrect email or password.';

  @override
  String get wrongPassword => 'Incorrect email or password.';

  @override
  String get userNotFound => 'Incorrect email or password.';

  @override
  String get emailAlreadyInUse =>
      'This email is already registered. Try logging in instead.';

  @override
  String get missingPassword => 'Please enter your password.';

  @override
  String get passwordMismatch => 'The passwords are not equal.';

  @override
  String get invalidEmail => 'Enter a valid email address.';

  @override
  String get passwordReset => 'Password reset';

  @override
  String get emailHint => 'Enter your email.';

  @override
  String get resetEmail => 'Send reset email.';

  @override
  String get cancel => 'Cancel';

  @override
  String get passwordResetEmail =>
      'The email for resetting the password was sent!';

  @override
  String get resetPasswordError =>
      'An error ocurred while resetting the password.';

  @override
  String get unknownError => 'An unknown error happened.';
}
