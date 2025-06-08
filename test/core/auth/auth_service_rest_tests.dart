/// This file contains contract tests for the FirebaseAuthRestService,
/// using the Mockito package to mock HTTP and secure storage dependencies.
///
/// These tests verify that the service:
/// - Calls the correct REST endpoints with the expected payloads
/// - Correctly decodes and returns data from the backend
/// - Handles error cases (like invalid credentials or email already in use)
///
/// # How these tests work
/// - All HTTP requests are intercepted using a mock Dio client.
/// - No real network or Firebase backend is used; everything is simulated.
/// - The secure storage is also mocked to simulate token storage.
///
/// # Why use these tests?
/// - To ensure your REST service correctly formats requests and parses responses.
/// - To catch regressions if you change request/response logic.
/// - To verify integration with authentication and error handling.
///
/// # How to run
/// - Run with `flutter test` as usual.
/// - No external dependencies or network required.
///
/// # See also
/// - https://docs.flutter.dev/testing
/// - https://pub.dev/packages/mockito

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:spiceease/core/auth/firebase_auth_rest.dart';
import 'package:spiceease/core/auth/auth_exception.dart';

import 'auth_service_tests.mocks.dart'; // Generated mock file

@GenerateMocks([
  Dio,
  FlutterSecureStorage,
])
void main() {
  // This ensures the Flutter test environment is initialized.
  TestWidgetsFlutterBinding.ensureInitialized();

  // Group related tests together for clarity and organization.
  group('FirebaseAuthRestService REST Tests', () {
    // Declare variables for the service and its dependencies.
    late FirebaseAuthRestService restService;
    late MockDio mockDio;
    late MockFlutterSecureStorage mockStorage;

    // The setUp() function runs before every test in this group.
    // It prepares a fresh instance of the service and mocks for each test.
    setUp(() {
      mockDio = MockDio();
      mockStorage = MockFlutterSecureStorage();

      // Stub the interceptors property
      when(mockDio.interceptors).thenReturn(Interceptors());

      // Mock FlutterSecureStorage methods
      when(mockStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => null);
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async {});
      when(mockStorage.delete(key: anyNamed('key'))).thenAnswer((_) async {});

      // Create the service under test, injecting the mocks.
      restService = FirebaseAuthRestService(
        apiKey: 'test-api-key',
        dio: mockDio,
        storage: mockStorage,
      );
    });

    /// Verifies that signIn calls the correct REST endpoint and handles the response.
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

    /// Verifies that signIn throws an AuthException on invalid credentials.
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

    /// Verifies that register calls the correct REST endpoint and handles the response.
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

    /// Verifies that register throws an AuthException if the email is already in use.
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

    /// Verifies that refreshToken calls the correct REST endpoint and handles the response.
    test('should refresh token successfully', () async {
      // Arrange: Set up the mock Dio to return a successful response
      final responseData = {
        'id_token': 'new_id_token',
        'refresh_token': 'new_refresh_token',
      };

      // Mock storage to return a refresh token
      when(mockStorage.read(key: 'refreshToken'))
          .thenAnswer((_) async => 'old_refresh_token');

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