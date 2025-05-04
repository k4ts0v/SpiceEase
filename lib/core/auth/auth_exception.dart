/// Custom authentication exception
///
/// Wraps error messages from Firebase API
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

