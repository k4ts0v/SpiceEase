import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spiceease/core/auth/auth_exception.dart';
import 'package:spiceease/core/auth/user_model.dart';
import 'auth_service.dart';

/// Firebase Authentication REST API implementation
///
/// Handles authentication flows using Firebase Identity Toolkit REST API
/// Features:
/// - Email/password authentication
/// - Token management with secure storage
/// - Automatic token refresh
/// - JWT validation
/// - Auth state streaming
class FirebaseAuthRestService implements AuthService {
  final Dio _dio; // HTTP client for REST API calls
  final String apiKey; // Firebase project API key
  final _storage = const FlutterSecureStorage(); // Secure token storage
  final StreamController<AppUser?> _authController =
      StreamController.broadcast(); // Auth state stream

  /// Initialize service with Firebase API key
  ///
  /// [apiKey]: Firebase project web API key
  /// [dio]: Optional Dio instance for custom configuration
  FirebaseAuthRestService({
    required this.apiKey,
    Dio? dio,
  }) : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://identitytoolkit.googleapis.com/v1/',
              headers: {'Content-Type': 'application/json'},
            )) {
    _initAuthInterceptor(); // Setup request/response interceptors
  }

  /// Initialize authentication interceptors
  ///
  /// Adds:
  /// 1. Request interceptor for adding Authorization header
  /// 2. Error interceptor for handling 401 unauthorized responses
  void _initAuthInterceptor() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Skip auth header for token refresh endpoints
        if (options.path.contains('accounts:')) return handler.next(options);

        // Add Bearer token if available
        final token = await _storage.read(key: 'idToken');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 Unauthorized errors
        if (error.response?.statusCode == 401) {
          try {
            // Attempt token refresh
            await refreshToken();

            // Retry original request with new token
            final req = error.requestOptions;
            final retry = await _dio.request(
              req.path,
              data: req.data,
              queryParameters: req.queryParameters,
              options: Options(
                method: req.method,
                headers: req.headers,
              ),
            );
            return handler.resolve(retry);
          } catch (e) {
            // Clear auth state on refresh failure
            _authController.add(null);
            return handler.reject(error);
          }
        }
        return handler.reject(error);
      },
    ));
  }

  /// Initialize auth state from storage
  ///
  /// Checks for existing tokens and validates them
  /// Updates auth state stream if valid session exists
  @override
  Future<void> initialize() async {
    final token = await _storage.read(key: 'idToken');
    if (token != null) {
      try {
        // Add token validation and refresh if needed
        final claims = _parseJwt(token);
        if (claims == null ||
            DateTime.now().millisecondsSinceEpoch > claims['exp'] * 1000) {
          await refreshToken();
        }
        _authController.add(await _getCurrentUser());
      } catch (e) {
        // Handle initialization errors gracefully
        await signOut();
        throw AuthException('Session expired');
      }
    }
  }

  /// Email/password registration
  ///
  /// [email]: User email address
  /// [password]: User password
  /// Throws AuthException on failure
  @override
  Future<void> signUp(String email, String password) async {
    try {
      final response = await _dio.post(
        'accounts:signUp',
        queryParameters: {'key': apiKey},
        data: {'email': email, 'password': password, 'returnSecureToken': true},
      );

      // Store tokens and update auth state
      await _storeTokens(response.data);
      _authController.add(AppUser.fromFirebase(response.data));
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  /// Email/password authentication
  ///
  /// [email]: Registered email address
  /// [password]: User password
  /// Throws AuthException on invalid credentials
  @override
  Future<void> signIn(String email, String password) async {
    try {
      final response = await _dio.post(
        'accounts:signInWithPassword',
        queryParameters: {'key': apiKey},
        data: {'email': email, 'password': password, 'returnSecureToken': true},
      );

      await _storeTokens(response.data);
      _authController.add(AppUser.fromPlatformUser(response.data));
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  /// Refresh authentication tokens
  ///
  /// Uses refresh token to obtain new ID token
  /// Updates storage and auth state
  /// Throws AuthException on failure
  Future<void> refreshToken() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) throw AuthException('No refresh token');

    try {
      final response = await _dio.post(
        'https://securetoken.googleapis.com/v1/token',
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
        queryParameters: {'key': apiKey},
      );

      await _storeTokens(response.data);
      _authController.add(await _getCurrentUser());
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  /// Store authentication tokens securely
  ///
  /// [data]: Response data containing tokens
  /// Saves:
  /// - idToken: Short-lived authentication token
  /// - refreshToken: Long-lived refresh token
  Future<void> _storeTokens(Map<String, dynamic> data) async {
    await _storage.write(key: 'idToken', value: data['idToken']);
    await _storage.write(key: 'refreshToken', value: data['refreshToken']);
  }

  /// Clear authentication state
  ///
  /// Removes stored tokens and updates auth stream
  @override
  Future<void> signOut() async {
    await _storage.delete(key: 'idToken');
    await _storage.delete(key: 'refreshToken');
    _authController.add(null);
  }

  /// Stream of authentication state changes
  ///
  /// Emits:
  /// - AppUser when authenticated
  /// - null when signed out
  @override
  Stream<AppUser?> authStateChanges() => _authController.stream;

  /// Get current ID token with validation
  ///
  /// Returns:
  /// - Valid ID token (refreshes if expired)
  /// - null if no valid session exists
  @override
  Future<String?> getCurrentIdToken() async {
    final token = await _storage.read(key: 'idToken');
    if (token == null) return null;

    // Validate token expiration
    final claims = _parseJwt(token);
    if (claims == null ||
        DateTime.now().millisecondsSinceEpoch > claims['exp'] * 1000) {
      await refreshToken();
      return await _storage.read(key: 'idToken');
    }
    return token;
  }

  /// Get current authenticated user
  ///
  /// Returns:
  /// - AppUser if valid session exists
  /// - null if not authenticated
  @override
  Future<AppUser?> getCurrentUser() async {
    final token = await getCurrentIdToken();
    if (token == null) return null;

    try {
      final response = await _dio.post(
        'accounts:lookup',
        queryParameters: {'key': apiKey},
        data: {'idToken': token},
      );
      return AppUser.fromPlatformUser(response.data['users'][0]);
    } on DioException {
      await signOut();
      return null;
    }
  }

  /// Parse JWT token payload
  ///
  /// [token]: JWT string
  /// Returns decoded payload or null on failure
  Map<String, dynamic>? _parseJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      return jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(payload))),
      );
    } catch (_) {
      return null;
    }
  }

  /// Internal method to fetch current user
  ///
  /// Used during initialization and token refresh
  Future<AppUser?> _getCurrentUser() async {
  try {
    final token = await _storage.read(key: 'idToken');
    if (token == null) return null;

    final response = await _dio.post(
      'accounts:lookup',
      queryParameters: {'key': apiKey},
      data: {'idToken': token},
    );

    if (response.data == null || response.data['users'] == null) {
      await signOut();
      return null;
    }

    return AppUser.fromPlatformUser(response.data['users'][0]);
  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      try {
        await refreshToken();
        return getCurrentUser();
      } catch (_) {
        await signOut();
        throw AuthException('Session expired');
      }
    }
    await signOut();
    throw AuthException(_parseError(e));
  }
}

  /// Parse error responses from Firebase
  ///
  /// Extracts error message from DioException
  String _parseError(DioException e) {
    return e.response?.data?['error']?['message'] ??
        e.message ??
        'Authentication failed';
  }

  /// Email/password registration (alias for signUp)
  @override
  Future<void> register(String email, String password) async {
    try {
      final response = await _dio.post(
        'accounts:signUp',
        queryParameters: {'key': apiKey},
        data: {'email': email, 'password': password, 'returnSecureToken': true},
      );

      await _storeTokens(response.data);
      _authController.add(AppUser.fromPlatformUser(response.data));
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  /// Check authentication status
  ///
  /// Returns true if valid session exists
  @override
  Future<bool> isSignedIn() async {
    final token = await _storage.read(key: 'idToken');
    return token != null;
  }

  /// Initiate password reset flow
  ///
  /// [email]: Registered email address
  /// Sends password reset email via Firebase
  @override
  Future<void> resetPassword(String email) async {
    try {
      await _dio.post(
        'accounts:sendOobCode',
        queryParameters: {'key': apiKey},
        data: {'requestType': 'PASSWORD_RESET', 'email': email},
      );
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  /// Validate stored tokens and refresh if needed
  Future<bool> validateSession() async {
    try {
      final token = await _storage.read(key: 'idToken');
      if (token == null) return false;

      final claims = _parseJwt(token);
      if (claims == null ||
          DateTime.now().millisecondsSinceEpoch > claims['exp'] * 1000) {
        await refreshToken();
      }

      final user = await _getCurrentUser();
      return user != null;
    } catch (e) {
      await signOut();
      return false;
    }
  }

  /// Check token expiration
  bool _isTokenExpired(String token) {
    final claims = _parseJwt(token);
    if (claims == null) return true;

    final expiry = claims['exp'] * 1000;
    return DateTime.now().millisecondsSinceEpoch > expiry;
  }
}
