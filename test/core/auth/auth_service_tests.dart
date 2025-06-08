import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spiceease/core/auth/firebase_auth_service.dart';
import 'package:spiceease/core/auth/firebase_auth_rest.dart';
import 'package:spiceease/core/auth/auth_exception.dart';
import 'package:spiceease/core/auth/user_model.dart';

import 'auth_service_tests.mocks.dart'; // Generated mock file

@GenerateMocks([
  FirebaseAuth,
  User,
  UserCredential,
  Dio,
  FlutterSecureStorage,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter binding is initialized for widget tests

  // --------------------------------------------------------------------------
  // SDK Implementation: FirebaseAuthService (using mocks)
  // --------------------------------------------------------------------------
  group('FirebaseAuthService SDK Tests', () {
    late FirebaseAuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;

    setUp(() {
      // Create mock instances for FirebaseAuth and related classes
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();

      // Use the real service but inject the mock FirebaseAuth
      authService = FirebaseAuthService();
      authService.setTestAuth(mockFirebaseAuth);

      // Set up mock user properties
      when(mockUser.uid).thenReturn('test_uid');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.emailVerified).thenReturn(true);
      when(mockUserCredential.user).thenReturn(mockUser);
    });

    /// This test verifies that signIn calls the correct FirebaseAuth method and returns the expected user.
    test('should sign in successfully', () async {
      // Arrange: Set up the mock to return a user credential
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // Act: Call the signIn method
      await authService.signIn('test@example.com', 'password123');

      // Assert: Verify the correct method was called and user is as expected
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
      expect(mockFirebaseAuth.currentUser?.uid, 'test_uid');
      expect(mockFirebaseAuth.currentUser?.email, 'test@example.com');
    });

    /// This test verifies that signIn throws an AuthException on invalid credentials.
    test('should throw AuthException on invalid credentials', () async {
      // Arrange: Set up the mock to throw an exception
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      // Act & Assert: The signIn call should throw an AuthException
      expect(
        () => authService.signIn('test@example.com', 'wrong_password'),
        throwsA(isA<AuthException>()),
      );
    });

    /// This test verifies that register calls the correct FirebaseAuth method.
    test('should register successfully', () async {
      // Arrange: Set up the mock to return a user credential
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);

      // Act: Call the register method
      await authService.register('newuser@example.com', 'password123');

      // Assert: Verify the correct method was called
      verify(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'newuser@example.com',
        password: 'password123',
      )).called(1);
    });

    /// This test verifies that register throws an AuthException if the email is already in use.
    test('should throw AuthException on email already in use', () async {
      // Arrange: Set up the mock to throw an exception
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      // Act & Assert: The register call should throw an AuthException
      expect(
        () => authService.register('existing@example.com', 'password123'),
        throwsA(isA<AuthException>()),
      );
    });

    /// This test verifies that resetPassword calls the correct FirebaseAuth method.
    test('should send password reset email successfully', () async {
      // Arrange: Set up the mock to complete successfully
      when(mockFirebaseAuth.sendPasswordResetEmail(
        email: anyNamed('email'),
      )).thenAnswer((_) async {});

      // Act: Call the resetPassword method
      await authService.resetPassword('test@example.com');

      // Assert: Verify the correct method was called
      verify(mockFirebaseAuth.sendPasswordResetEmail(
        email: 'test@example.com',
      )).called(1);
    });

    /// This test verifies that resetPassword throws an AuthException on invalid email.
    test('should throw AuthException on invalid email for password reset', () async {
      // Arrange: Set up the mock to throw an exception
      when(mockFirebaseAuth.sendPasswordResetEmail(
        email: anyNamed('email'),
      )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      // Act & Assert: The resetPassword call should throw an AuthException
      expect(
        () => authService.resetPassword('invalid@example.com'),
        throwsA(isA<AuthException>()),
      );
    });

    /// This test verifies that signOut calls the correct FirebaseAuth method.
    test('should sign out successfully', () async {
      // Arrange: Set up the mock to complete successfully
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      // Act: Call the signOut method
      await authService.signOut();

      // Assert: Verify the correct method was called
      verify(mockFirebaseAuth.signOut()).called(1);
    });
  });

  // --------------------------------------------------------------------------
  // REST Implementation: FirebaseAuthRestService (using mocks)
  // --------------------------------------------------------------------------
  group('FirebaseAuthRestService REST Tests', () {
    late FirebaseAuthRestService restService;
    late MockDio mockDio;
    late MockFlutterSecureStorage mockStorage;

    setUp(() {
      mockDio = MockDio();
      mockStorage = MockFlutterSecureStorage();

      // Stub the interceptors property
      when(mockDio.interceptors).thenReturn(Interceptors());

      // Mock FlutterSecureStorage methods
      when(mockStorage.read(key: anyNamed('key'))).thenAnswer((_) async => null);
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value'))).thenAnswer((_) async {});
      when(mockStorage.delete(key: anyNamed('key'))).thenAnswer((_) async {});

      restService = FirebaseAuthRestService(
        apiKey: 'test-api-key',
        dio: mockDio,
        storage: mockStorage,
      );
    });

    /// This test verifies that signIn calls the correct REST endpoint and handles the response.
    test('should sign in successfully', () async {
      // Arrange: Set up the mock Dio to return a successful response
      final responseData = {
        'idToken': 'mock_id_token',
        'refreshToken': 'mock_refresh_token',
        'email': 'test@example.com',
        'localId': 'test_uid',
      };

      when(mockDio.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act: Call the signIn method
      await restService.signIn('test@example.com', 'password123');

      // Assert: Verify the method was called with correct parameters
      verify(mockDio.post(
        any,
        data: {
          'email': 'test@example.com',
          'password': 'password123',
          'returnSecureToken': true,
        },
        queryParameters: anyNamed('queryParameters'),
      )).called(1);
    });

    /// This test verifies that signIn throws an AuthException on invalid credentials.
    test('should throw AuthException on invalid credentials', () async {
      // Arrange: Set up the mock Dio to throw an error response
      when(mockDio.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenThrow(DioError(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 400,
          data: {
            'error': {'message': 'INVALID_PASSWORD'}
          },
          requestOptions: RequestOptions(path: ''),
        ),
      ));

      // Act & Assert: The signIn call should throw an AuthException
      expect(
        () => restService.signIn('test@example.com', 'wrong_password'),
        throwsA(isA<AuthException>()),
      );
    });

    /// This test verifies that register calls the correct REST endpoint and handles the response.
    test('should register successfully', () async {
      // Arrange: Set up the mock Dio to return a successful response
      final responseData = {
        'idToken': 'mock_id_token',
        'refreshToken': 'mock_refresh_token',
        'email': 'newuser@example.com',
        'localId': 'new_user_uid',
      };

      when(mockDio.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act: Call the register method
      await restService.register('newuser@example.com', 'password123');

      // Assert: Verify the method was called with correct parameters
      verify(mockDio.post(
        any,
        data: {
          'email': 'newuser@example.com',
          'password': 'password123',
          'returnSecureToken': true,
        },
        queryParameters: anyNamed('queryParameters'),
      )).called(1);
    });

    /// This test verifies that register throws an AuthException if the email is already in use.
    test('should throw AuthException on email already in use', () async {
      // Arrange: Set up the mock Dio to throw an error response
      when(mockDio.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenThrow(DioError(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 400,
          data: {
            'error': {'message': 'EMAIL_EXISTS'}
          },
          requestOptions: RequestOptions(path: ''),
        ),
      ));

      // Act & Assert: The register call should throw an AuthException
      expect(
        () => restService.register('existing@example.com', 'password123'),
        throwsA(isA<AuthException>()),
      );
    });

    /// This test verifies that refreshToken calls the correct REST endpoint and handles the response.
    test('should refresh token successfully', () async {
      // Arrange: Set up the mock Dio to return a successful response
      final responseData = {
        'id_token': 'new_id_token',
        'refresh_token': 'new_refresh_token',
      };

      when(mockDio.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act: Call the refreshToken method
      await restService.refreshToken();

      // Assert: Verify the method was called with correct parameters
      verify(mockDio.post(
        any,
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': 'old_refresh_token'
        },
        queryParameters: anyNamed('queryParameters'),
      )).called(1);
    });
  });
}