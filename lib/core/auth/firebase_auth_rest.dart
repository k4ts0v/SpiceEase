import 'dart:async';
import 'dart:convert';
import 'dart:math';
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
  final FlutterSecureStorage _storage; // Secure token storage
  final StreamController<AppUser?> _authController =
      StreamController.broadcast(); // Auth state stream

  /// Initialize service with Firebase API key
  ///
  /// [apiKey]: Firebase project web API key
  /// [dio]: Optional Dio instance for custom configuration
  FirebaseAuthRestService({
    required this.apiKey,
    Dio? dio,
    FlutterSecureStorage? storage,
  })  : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://identitytoolkit.googleapis.com/v1/',
            )),
        _storage = storage ?? const FlutterSecureStorage() {
    _initAuthInterceptor();
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
        print('Token from storage: $token');
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

  /// Get access token for Firestore API calls
  @override
  Future<String?> getAccessToken() async {
    try {
      // For Firestore REST API, we use the ID token directly
      return await getCurrentIdToken();
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
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
        // Check and log token expiration status
        if (_isTokenExpired(token)) {
          print('Token is expired, signing out for fresh authentication');
          await signOut(); // Force fresh login instead of trying refresh
        } else {
          print('Token is valid, fetching user profile');
          _authController.add(await _fetchUserProfile(token));
        }
      } catch (e) {
        print('Error during authentication initialization: $e');
        await signOut();
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
    print('Attempting to refresh token...');
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) {
      print('No refresh token found, signing out');
      await signOut();
      throw AuthException('No refresh token');
    }

    try {
      print('Making refresh request to Firebase...');
      final response = await _dio.post(
        'https://securetoken.googleapis.com/v1/token',
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
        queryParameters: {'key': apiKey},
      );

      print('Refresh response received: ${response.statusCode}');
      if (response.data == null || !response.data.containsKey('id_token')) {
        print('Invalid refresh response: ${response.data}');
        await signOut();
        throw AuthException('Invalid refresh response');
      }

      // Fix key names if needed - Firebase returns id_token, not idToken
      final data = {
        'idToken': response.data['id_token'] ?? response.data['idToken'],
        'refreshToken':
            response.data['refresh_token'] ?? response.data['refreshToken'],
      };

      await _storeTokens(data);
      print('Tokens refreshed and stored successfully');

      // Use _fetchUserProfile instead of _getCurrentUser to avoid refresh loops
      final userProfile = await _fetchUserProfile(data['idToken']);
      _authController.add(userProfile);
    } on DioException catch (e) {
      print(
          'Refresh token request failed: ${e.response?.statusCode} ${e.message}');
      await signOut(); // Always sign out on refresh failure
      throw AuthException(_parseError(e));
    } catch (e) {
      print('Unexpected error during refresh: $e');
      await signOut();
      throw AuthException('Token refresh failed: $e');
    }
  }

  /// Fetch user profile without triggering token refreshes
  Future<AppUser?> _fetchUserProfile(String token) async {
    try {
      final response = await _dio.post(
        'accounts:lookup',
        queryParameters: {'key': apiKey},
        data: {'idToken': token},
      );

      if (response.data == null || response.data['users'] == null) {
        return null;
      }

      return AppUser.fromPlatformUser(response.data['users'][0]);
    } on DioException {
      return null;
    }
  }

  /// Store authentication tokens securely
  ///
  /// [data]: Response data containing tokens
  /// Saves:
  /// - idToken: Short-lived authentication token
  /// - refreshToken: Long-lived refresh token
  Future<void> _storeTokens(Map<String, dynamic> data) async {
    // Safely print token fragments for debugging
    final idTokenSnippet = data['idToken']
            ?.substring(0, min<int>(10, data['idToken']?.length ?? 0)) ??
        'null';
    final refreshTokenSnippet = data['refreshToken']
            ?.substring(0, min<int>(10, data['refreshToken']?.length ?? 0)) ??
        'null';
    print(
        'Storing tokens: idToken=$idTokenSnippet... refreshToken=$refreshTokenSnippet...');

    // Validate required tokens are present
    if (data['idToken'] == null || data['refreshToken'] == null) {
      throw AuthException('Missing required tokens in authentication response');
    }

    // Store the tokens securely
    await _storage.write(key: 'idToken', value: data['idToken']);
    await _storage.write(key: 'refreshToken', value: data['refreshToken']);
    print('Tokens stored successfully');
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
    print('Parsing error: ${e}');
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
    try {
      final claims = _parseJwt(token);
      if (claims == null) {
        print('Token has invalid format - cannot parse JWT');
        return true;
      }

      if (!claims.containsKey('exp')) {
        print('Token missing expiration claim');
        return true;
      }

      final expiry = claims['exp'] * 1000;
      final now = DateTime.now().millisecondsSinceEpoch;
      final isExpired = now > expiry;

      print('Token expires at: ${DateTime.fromMillisecondsSinceEpoch(expiry)}');
      print('Current time is: ${DateTime.now()}');
      print('Token ${isExpired ? "IS" : "is NOT"} expired');

      return isExpired;
    } catch (e) {
      print('Error checking token expiration: $e');
      return true;
    }
  }

  /// Updates the user's email address
  ///
  /// - Parameter [newEmail]: The new email address to set
  // ...existing code...

  // ...existing code...

  @override
  Future<void> updateEmail(String newEmail) async {
    try {
      print('DEBUG: Auth service - updateEmail called with: $newEmail');

      final token = await getCurrentIdToken();
      if (token == null) {
        throw AuthException('Authentication required');
      }

      // Step 1: Try to update the email directly
      final response = await _dio.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:update',
        queryParameters: {
          'key': apiKey,
        },
        data: {
          'idToken': token,
          'email': newEmail,
          'returnSecureToken': true,
        },
      );

      if (response.statusCode == 200) {
        print('DEBUG: Auth service - Email updated successfully to: $newEmail');

        // Store new tokens and update auth state
        await _storeTokens(response.data);
        _authController.add(AppUser.fromFirebase(response.data));

        // Send verification email to the NEW address
        await sendEmailVerification();
      }
    } on DioException catch (e) {
      print(
          'DEBUG: Auth service - DioException in updateEmail: ${e.response?.data}');

      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData != null && errorData['error'] != null) {
          final errorMessage = errorData['error']['message'] ?? '';

          if (errorMessage.contains('OPERATION_NOT_ALLOWED') &&
              errorMessage.contains('Please verify the new email')) {
            // Firebase requires new email verification first
            // Store the email change request and send verification
            await _initiateEmailChangeWithVerification(newEmail);
            throw AuthException('VERIFICATION_EMAIL_SENT:$newEmail');
          } else if (errorMessage.contains('EMAIL_EXISTS')) {
            throw AuthException('An account with this email already exists');
          } else if (errorMessage.contains('INVALID_ID_TOKEN')) {
            throw AuthException('requires_recent_login');
          } else {
            throw AuthException(errorMessage);
          }
        }
      }

      throw AuthException('Failed to update email: ${e.message}');
    } catch (e) {
      print('DEBUG: Auth service - Exception in updateEmail: $e');
      throw AuthException('Failed to update email: $e');
    }
  }

  /// Initiate email change with verification flow
  Future<void> _initiateEmailChangeWithVerification(String newEmail) async {
    print('DEBUG: Initiating email change with verification for: $newEmail');

    try {
      // Store the current user's info and the requested new email
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw AuthException('Authentication required');
      }

      await _storage.write(key: 'email_change_request', value: newEmail);
      await _storage.write(
          key: 'original_user_email', value: currentUser.email);

      // Try to create a temporary account to send verification to new email
      final tempPassword = _generateSecurePassword();

      final createResponse = await _dio.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp',
        queryParameters: {'key': apiKey},
        data: {
          'email': newEmail,
          'password': tempPassword,
          'returnSecureToken': true,
        },
      );

      if (createResponse.statusCode == 200) {
        final tempToken = createResponse.data['idToken'];

        // Send verification email to the new address
        await _dio.post(
          'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode',
          queryParameters: {'key': apiKey},
          data: {
            'requestType': 'VERIFY_EMAIL',
            'idToken': tempToken,
          },
        );

        // Store temp account info for later cleanup
        await _storage.write(key: 'temp_account_token', value: tempToken);
        await _storage.write(key: 'temp_account_password', value: tempPassword);

        print('DEBUG: Verification email sent to new address: $newEmail');
      }
    } on DioException catch (e) {
      print(
          'DEBUG: Error in _initiateEmailChangeWithVerification: ${e.response?.data}');

      if (e.response?.data?['error']?['message']?.contains('EMAIL_EXISTS') ==
          true) {
        // Email already has an account - ask user to sign in with that account instead
        throw AuthException('EXISTING_ACCOUNT_VERIFICATION:$newEmail');
      } else {
        throw AuthException('Failed to send verification email to new address');
      }
    }
  }

  /// Check if user has verified the new email and complete the change
  Future<bool> checkAndCompleteEmailChange() async {
    try {
      final pendingEmail = await _storage.read(key: 'email_change_request');
      final tempToken = await _storage.read(key: 'temp_account_token');
      final tempPassword = await _storage.read(key: 'temp_account_password');

      if (pendingEmail == null || tempToken == null || tempPassword == null) {
        print('DEBUG: No pending email change found');
        return false;
      }

      print(
          'DEBUG: Checking verification status for pending email: $pendingEmail');

      // Check if the temp account's email is verified
      try {
        final lookupResponse = await _dio.post(
          'https://identitytoolkit.googleapis.com/v1/accounts:lookup',
          queryParameters: {'key': apiKey},
          data: {'idToken': tempToken},
        );

        final tempUser = lookupResponse.data['users'][0];
        if (tempUser['emailVerified'] == true) {
          print('DEBUG: New email is verified, completing email change...');

          // Now we can update the original user's email
          final currentToken = await getCurrentIdToken();
          if (currentToken == null) {
            throw AuthException('Authentication required');
          }

          // Delete the temp account first (we don't need it anymore)
          try {
            await _dio.post(
              'https://identitytoolkit.googleapis.com/v1/accounts:delete',
              queryParameters: {'key': apiKey},
              data: {'idToken': tempToken},
            );
            print('DEBUG: Temp account deleted');
          } catch (e) {
            print('DEBUG: Error deleting temp account: $e');
            // Continue anyway
          }

          // Now try to update the original user's email again
          final updateResponse = await _dio.post(
            'https://identitytoolkit.googleapis.com/v1/accounts:update',
            queryParameters: {'key': apiKey},
            data: {
              'idToken': currentToken,
              'email': pendingEmail,
              'returnSecureToken': true,
            },
          );

          if (updateResponse.statusCode == 200) {
            print(
                'DEBUG: Email change completed successfully to: $pendingEmail');

            // Store new tokens and update auth state
            await _storeTokens(updateResponse.data);
            _authController.add(AppUser.fromFirebase(updateResponse.data));

            // Clean up stored data
            await _cleanupEmailChangeData();

            return true;
          } else {
            throw AuthException('Failed to complete email update');
          }
        } else {
          print('DEBUG: New email not verified yet');
          return false;
        }
      } catch (e) {
        print('DEBUG: Error checking temp account: $e');
        // Clean up if temp account is invalid
        await _cleanupEmailChangeData();
        return false;
      }
    } catch (e) {
      print('DEBUG: Error in checkAndCompleteEmailChange: $e');
      await _cleanupEmailChangeData();
      throw AuthException('Failed to complete email change: $e');
    }
  }

  /// Clean up email change related data
  Future<void> _cleanupEmailChangeData() async {
    await _storage.delete(key: 'email_change_request');
    await _storage.delete(key: 'original_user_email');
    await _storage.delete(key: 'temp_account_token');
    await _storage.delete(key: 'temp_account_password');
  }

  /// Get pending email change info
  Future<String?> getPendingEmailChange() async {
    return await _storage.read(key: 'email_change_request');
  }

  String _generateSecurePassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
        16, (index) => chars[(random * 17 + index * 31) % chars.length]).join();
  }

  // Remove the old completeEmailChange method and helper methods that create confusion
  // ...existing code...

  /// Attempt to send verification email to new email address
  /// This is a workaround since Firebase REST API doesn't directly support this
  Future<void> _sendVerificationToNewEmail(String newEmail) async {
    print('DEBUG: Attempting to send verification to new email: $newEmail');

    // Workaround: Create a temporary account to send verification
    try {
      // Generate a secure temporary password
      final tempPassword = _generateSecurePassword();

      // Create temporary account with new email
      final createResponse = await _dio.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp',
        queryParameters: {'key': apiKey},
        data: {
          'email': newEmail,
          'password': tempPassword,
          'returnSecureToken': true,
        },
      );

      if (createResponse.statusCode == 200) {
        final tempToken = createResponse.data['idToken'];

        // Send verification email to the new address
        await _dio.post(
          'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode',
          queryParameters: {'key': apiKey},
          data: {
            'requestType': 'VERIFY_EMAIL',
            'idToken': tempToken,
          },
        );

        // Store the temporary account info for later cleanup
        await _storage.write(key: 'temp_account_token', value: tempToken);
        await _storage.write(key: 'pending_email_change', value: newEmail);

        print('DEBUG: Verification email sent to new address: $newEmail');

        // Note: We don't delete the temp account immediately because the user
        // needs to verify the email first. We'll clean it up after verification.
      }
    } on DioException catch (e) {
      print('DEBUG: Error creating temp account: ${e.response?.data}');

      if (e.response?.data?['error']?['message']?.contains('EMAIL_EXISTS') ==
          true) {
        // The email already has an account - that's actually good!
        // We can try to trigger a verification email to that existing account
        try {
          await _triggerVerificationForExistingEmail(newEmail);
        } catch (existingEmailError) {
          rethrow; // Re-throw the original error
        }
      } else {
        rethrow;
      }
    }
  }

  /// Trigger verification email for existing email account
  Future<void> _triggerVerificationForExistingEmail(String email) async {
    try {
      // Send password reset email as a workaround to verify email ownership
      await _dio.post(
        'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode',
        queryParameters: {'key': apiKey},
        data: {
          'requestType': 'PASSWORD_RESET',
          'email': email,
        },
      );

      print('DEBUG: Password reset email sent to existing account: $email');
      throw AuthException('EXISTING_ACCOUNT_VERIFICATION:$email');
    } catch (e) {
      print('DEBUG: Error sending password reset to existing account: $e');
      rethrow;
    }
  }

  /// Updates the user's password
  ///
  /// - Parameters:
  ///   - [currentPassword]: The user's current password for verification
  ///   - [newPassword]: The new password to set
  @override
  Future<void> updatePassword(
      String currentPassword, String newPassword) async {
    try {
      // First verify the current password by signing in again
      final user = await getCurrentUser();
      if (user == null || user.email == null) {
        throw AuthException('not_signed_in');
      }

      // Verify current password with a sign-in attempt
      // We don't store this token because we'll get a new one after password change
      try {
        await _dio.post(
          'accounts:signInWithPassword',
          queryParameters: {'key': apiKey},
          data: {
            'email': user.email,
            'password': currentPassword,
            'returnSecureToken': false,
          },
        );
      } on DioException catch (e) {
        // If verification fails, it's likely an incorrect password
        throw AuthException('invalid_current_password');
      }

      // Once verified, update the password
      final token = await getCurrentIdToken();
      if (token == null) {
        throw AuthException('not_signed_in');
      }

      // Change password with verified token
      final response = await _dio.post(
        'accounts:update',
        queryParameters: {'key': apiKey},
        data: {
          'idToken': token,
          'password': newPassword,
          'returnSecureToken': true,
        },
      );

      // Store the new tokens and update auth state
      await _storeTokens(response.data);
      _authController.add(AppUser.fromFirebase(response.data));
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  /// Re-authenticates the user with their credentials
  @override
  Future<void> reauthenticate(String email, String password) async {
    try {
      // Re-authenticate by performing a fresh sign-in
      final response = await _dio.post(
        'accounts:signInWithPassword',
        queryParameters: {'key': apiKey},
        data: {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      );

      // Store the new tokens
      await _storeTokens(response.data);
      _authController.add(AppUser.fromFirebase(response.data));
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  /// Send email verification to current user
  @override
  Future<void> sendEmailVerification() async {
    try {
      final token = await getCurrentIdToken();
      if (token == null) {
        throw AuthException('not_signed_in');
      }

      await _dio.post(
        'accounts:sendOobCode',
        queryParameters: {'key': apiKey},
        data: {
          'requestType': 'VERIFY_EMAIL',
          'idToken': token,
        },
      );
    } on DioException catch (e) {
      throw AuthException(_parseError(e));
    }
  }
}
