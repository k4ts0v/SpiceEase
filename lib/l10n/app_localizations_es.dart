// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get confirmPassword => 'Confirmación de contraseña';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get createAccount => 'Crear nueva cuenta';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get sessionExpired =>
      'Sesión caducada. Por favor inicia sesión nuevamente.';

  @override
  String get rememberMe => 'Recuérdame';

  @override
  String get recoveryEmailSent => 'Se ha enviado un correo de recuperación.';

  @override
  String get invalidLoginCredentials => 'Las credenciales son incorrectas.';

  @override
  String get wrongPassword => 'Las credenciales son incorrectas.';

  @override
  String get userNotFound => 'Las credenciales son incorrectas.';

  @override
  String get emailAlreadyInUse =>
      'Este correo ya está registrado. Prueba a iniciar sesión.';

  @override
  String get missingPassword => 'Introduce tu contraseña.';

  @override
  String get passwordMismatch => 'Las contraseñas no son iguales.';

  @override
  String get invalidEmail => 'Introduce una dirección de correo válida.';

  @override
  String get passwordReset => 'Reseteo de contraseña';

  @override
  String get emailHint => 'Introduce tu email.';

  @override
  String get resetEmail => 'Enviar email de recuperación.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get passwordResetEmail =>
      'El correo de recuperación de contraseña se ha enviado.';

  @override
  String get resetPasswordError =>
      'Ha ocurrido un error al resetear la contraseña.';

  @override
  String get unknownError => 'Ha ocurrido un error desconocido.';
}
