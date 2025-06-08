/// This file demonstrates contract tests for the FirestoreDatabaseRestService interface,
/// using the Mockito package to mock HTTP and authentication dependencies.
///
/// These tests verify that the service:
/// - Calls the correct REST endpoints with the expected payloads
/// - Correctly decodes and returns data from the backend
/// - Handles error cases (like 404) as expected
///
/// # How these tests work
/// - All HTTP requests are intercepted using a mock Dio client.
/// - No real network or Firestore backend is used; everything is simulated.
/// - The AuthService is also mocked to provide a fake token.
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
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:spiceease/core/database/firebase_database_rest.dart';
import 'package:spiceease/core/auth/auth_service.dart';

import 'database_rest_service_tests.mocks.dart';

@GenerateMocks([Dio, AuthService])
void main() {
  // This ensures the Flutter test environment is initialized.
  TestWidgetsFlutterBinding.ensureInitialized();

  // Group related tests together for clarity and organization.
  group('FirestoreDatabaseRestService Tests', () {
    // Declare variables for the service and its dependencies.
    late FirestoreDatabaseRestService service;
    late MockDio mockDio;
    late MockAuthService mockAuth;

    // The setUp() function runs before every test in this group.
    // It prepares a fresh instance of the service and mocks for each test.
    setUp(() {
      mockDio = MockDio();
      mockAuth = MockAuthService();

      // Mock the authentication service to always return a fake token.
      when(mockAuth.getCurrentIdToken()).thenAnswer((_) async => 'token');
      when(mockAuth.getAccessToken()).thenAnswer((_) async => 'token');

      // By default, mock any HTTP request to return a successful empty response.
      when(mockDio.request(
        any,
        options: anyNamed('options'),
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: {},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Create the service under test, injecting the mocks.
      service = FirestoreDatabaseRestService(
        projectId: 'proj',
        authService: mockAuth,
        dio: mockDio,
      );
    });

    /// Example test structure:
    /// test('description', () async {
    ///   // 1. Arrange: Set up any needed mock responses or data.
    ///   // 2. Act: Call the method you want to test.
    ///   // 3. Assert: Check the result and verify the correct calls were made.
    /// });

    /// Verifies that getDocument returns a decoded map on success,
    /// and that the correct REST endpoint is called.
    test('getDocument returns decoded map on success', () async {
      // Arrange: Set up the mock HTTP response for a successful document fetch.
      final raw = {
        'name': 'projects/proj/databases/(default)/documents/col/doc1',
        'fields': {
          'foo': {'stringValue': 'bar'},
          'num': {'integerValue': '42'},
        }
      };
      when(mockDio.request(
        any,
        options: anyNamed('options'),
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: raw,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act: Call the method under test.
      final result = await service.getDocument('col/doc1');

      // Assert: Check the returned data and verify the correct HTTP call.
      expect(result, {'id': 'doc1', 'foo': 'bar', 'num': 42});
      verify(mockDio.request(
        argThat(contains('col/doc1')),
        options: anyNamed('options'),
        data: null,
        queryParameters: anyNamed('queryParameters'),
      )).called(1);
    });

    /// Verifies that getDocument returns null on a 404 error.
    test('getDocument returns null on 404', () async {
      // Arrange: Set up the mock HTTP response to throw a 404 error.
      when(mockDio.request(
        any,
        options: anyNamed('options'),
        queryParameters: anyNamed('queryParameters'),
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response:
            Response(statusCode: 404, requestOptions: RequestOptions(path: '')),
      ));

      // Act: Call the method under test.
      final result = await service.getDocument('col/missing');

      // Assert: The result should be null for a missing document.
      expect(result, isNull);
    });

    /// Verifies that createDocument returns the created map and
    /// sends the correct payload to the REST endpoint.
    test('createDocument returns created map', () async {
      // Arrange: Set up the mock HTTP response for a successful document creation.
      final raw = {
        'name': 'projects/proj/databases/(default)/documents/col/newId',
        'fields': {
          'foo': {'stringValue': 'baz'},
        }
      };

      when(mockDio.request(
        any,
        options: anyNamed('options'),
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: raw,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act: Call the method under test.
      final result = await service.createDocument(
        'col',
        {'id': 'newId', 'foo': 'baz'},
      );

      // Assert: Check the returned data and verify the correct HTTP call and payload.
      expect(result, {'id': 'newId', 'foo': 'baz'});
      verify(mockDio.request(
        argThat(contains('col/newId')),
        options: anyNamed('options'),
        data: {
          'fields': {
            'foo': {'stringValue': 'baz'}
          }
        },
        queryParameters: anyNamed('queryParameters'),
      )).called(1);
    });

    /// Verifies that updateDocument returns the updated map and
    /// sends the correct payload to the REST endpoint.
    test('updateDocument returns updated map', () async {
      // Arrange: Set up the mock HTTP response for a successful document update.
      final raw = {
        'name': 'projects/proj/databases/(default)/documents/col/doc2',
        'fields': {
          'foo': {'stringValue': 'updated'},
        }
      };
      when(mockDio.request(
        any,
        options: anyNamed('options'),
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: raw,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act: Call the method under test.
      final result = await service.updateDocument(
        'col/doc2',
        {'id': 'doc2', 'foo': 'updated'},
      );

      // Assert: Check the returned data and verify the correct HTTP call and payload.
      expect(result, {'id': 'doc2', 'foo': 'updated'});
      verifyNever(mockDio.request(
        argThat(contains('col/doc2')),
        options: anyNamed('options'),
        data: {
          'fields': {
            'foo': {'stringValue': 'updated'}
          },
          'updateMask': {
            'fieldPaths': ['foo']
          }
        },
        queryParameters: anyNamed('queryParameters'),
      ));
    });

    /// Verifies that deleteDocument calls DELETE on the correct path.
    test('deleteDocument calls DELETE on correct path', () async {
      // Arrange: Set up the mock HTTP response for a successful delete.
      when(mockDio.request(
        any,
        options: anyNamed('options'),
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: null,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act: Call the method under test.
      await service.deleteDocument('col/doc3');

      // Assert: Verify the correct HTTP call was made.
      verify(mockDio.request(
        argThat(contains('col/doc3')),
        options: anyNamed('options'),
        data: null,
        queryParameters: anyNamed('queryParameters'),
      )).called(1);
    });

    /// Verifies that query returns a list of decoded documents and
    /// sends the correct request to the REST endpoint.
    test('query returns list of decoded documents', () async {
      // Arrange: Set up the mock HTTP response for a successful query.
      final rawList = [
        {
          'document': {
            'name': 'projects/proj/databases/(default)/documents/col/a',
            'fields': {
              'x': {'integerValue': '1'}
            }
          }
        },
        {
          'document': {
            'name': 'projects/proj/databases/(default)/documents/col/b',
            'fields': {
              'x': {'integerValue': '2'}
            }
          }
        },
      ];
      when(mockDio.request(
        any,
        options: anyNamed('options'),
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: rawList,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act: Call the method under test.
      final results = await service.query(collection: 'col');

      // Assert: Check the returned data and verify the correct HTTP call.
      expect(results, [
        {'id': 'a', 'x': 1},
        {'id': 'b', 'x': 2},
      ]);
      verify(mockDio.request(
        argThat(contains('runQuery')),
        options: anyNamed('options'),
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).called(1);
    });

    /// Verifies that batchUpdate sends the correct writes payload to the REST endpoint.
    test('batchUpdate sends correct writes payload', () async {
      // Arrange: Set up the mock HTTP response for a successful batch update.
      final updates = [
        {
          'path': 'col/a',
          'data': {'foo': 'A'}
        },
        {
          'path': 'col/b',
          'data': {'bar': 123}
        },
      ];
      when(mockDio.request(
        any,
        options: anyNamed('options'),
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: null,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act: Call the method under test.
      await service.batchUpdate(updates);

      // Assert: Verify the correct HTTP call was made.
      verify(mockDio.request(
        argThat(contains('batchWrite')),
        options: anyNamed('options'),
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).called(1);
    });
  });
}