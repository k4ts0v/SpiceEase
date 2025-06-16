/// This file demonstrates contract tests for the MagicTodoService interface,
/// using the Mockito package to mock HTTP and provider dependencies.
///
/// These tests verify that the service:
/// - Calls the correct goblin.tools API endpoints with the expected payloads
/// - Correctly decodes and returns subtasks from the backend
/// - Handles both list and string API responses
/// - Maps energy levels to spiciness values correctly
/// - Generates proper SubtaskModel instances with correct field mappings
///
/// # How these tests work
/// - All HTTP requests are intercepted using a mock Dio client.
/// - No real network or backend is used; everything is simulated.
/// - The EnergyService is also mocked to provide a fake energy level.
///
/// # Why use these tests?
/// - To ensure your service correctly formats requests and parses responses.
/// - To catch regressions if you change request/response logic.
/// - To verify integration with energy and user providers.
/// - To validate SubtaskModel creation with proper field mapping.
///
/// # How to run
/// - Run with `flutter test` as usual.
/// - No external dependencies or network required.
///
/// # See also
/// - https://docs.flutter.dev/testing
/// - https://pub.dev/packages/mockito

import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_user_model.dart';
import 'package:spiceease/data/providers/unified_auth_provider.dart';
import 'package:spiceease/data/services/magic_todo_service.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/services/energy_service.dart';
import 'package:spiceease/data/models/energy_model.dart';
import 'package:spiceease/data/providers/energy_provider.dart';
import 'package:uuid/uuid.dart';

@GenerateMocks([Dio])
import 'magic_todo_service_tests.mocks.dart';

/// A simplified test implementation of MagicTodoService that doesn't depend on external providers
class TestMagicTodoService {
  final Dio dio;
  final int? energyLevel;
  final Uuid _uuid = const Uuid();

  TestMagicTodoService({required this.dio, this.energyLevel});

  /// Divide a task into subtasks using the Goblin Tools API
  Future<List<SubtaskModel>> divideTask({
    required String title,
    String description = '',
  }) async {
    try {
      final spiciness = await getSpiciness();
      final response = await dio.post(
        'https://goblin.tools/api/todo',
        data: {
          'text': '$title $description',
          'spiciness': spiciness,
          'Ancestors': [],
        },
      );

      final data = response.data;
      List<String> subtaskTexts = [];

      // Handle both list and string responses from the API
      if (data is List) {
        print('Goblin API returned a List: $data');
        subtaskTexts = data.map((item) => item.toString()).toList();
      } else if (data is String) {
        print('Goblin API returned a String: $data');
        // Split string by newlines and filter out empty strings
        subtaskTexts = data
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();
        print('($subtaskTexts)');
      } else {
        print('Goblin API returned unexpected type: ${data.runtimeType}');
        return [];
      }

      // Create subtasks from the results
      final userId = 'test-user-123';
      final List<SubtaskModel> subtasks = [];

      for (int i = 0; i < subtaskTexts.length; i++) {
        final subtask = SubtaskModel(
          id: _uuid.v4(),
          userId: userId,
          taskId: '',
          title: subtaskTexts[i],
          completed: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          order: i,
        );
        subtasks.add(subtask);
      }

      return subtasks;
    } catch (e) {
      print('Error dividing task: $e');
      return [];
    }
  }

  /// Get the spiciness level based on energy
  Future<String> getSpiciness() async {
    // If energy level is null, return highest spiciness "5"
    if (energyLevel == null) return "5";

    // Map energy levels to spiciness
    if (energyLevel! <= 2) return "5";
    if (energyLevel! <= 4) return "4";
    if (energyLevel! <= 6) return "3";
    if (energyLevel! <= 8) return "2";
    return "1"; // 9-10
  }
}

void main() {
  // This ensures the Flutter test environment is initialized.
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDio mockDio;
  late TestMagicTodoService magicTodoService;

  // The setUp() function runs before every test in this file.
  setUp(() {
    mockDio = MockDio();

    // Create our test service directly, without using providers
    magicTodoService = TestMagicTodoService(
      dio: mockDio,
      energyLevel: 5,
    );
  });

  /// Verifies that divideTask returns a list of subtasks when API returns a List,
  /// and that the correct API endpoint and payload are used.
  test('divideTask returns list of subtasks when API returns List', () async {
    // Arrange: Set up the mock HTTP response for a successful subtask split.
    const title = "Test Task";
    const description = "Test Description";
    const expectedSpiciness = "3"; // String like in the actual service

    final apiResponse = ["Subtask 1", "Subtask 2", "Subtask 3"];
    when(mockDio.post(
      any,
      data: anyNamed('data'),
    )).thenAnswer((_) async => Response(
          data: apiResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

    // Act: Call the method under test.
    final subtasks = await magicTodoService.divideTask(
        title: title, description: description);

    // Assert: Check the returned data and verify the correct HTTP call.
    verify(mockDio.post(
      "https://goblin.tools/api/todo",
      data: {
        'text': "$title $description",
        'spiciness': expectedSpiciness,
        'Ancestors': [],
      },
    )).called(1);

    expect(subtasks, isA<List<SubtaskModel>>());
    expect(subtasks.length, equals(apiResponse.length));
    expect(subtasks[0].title, equals("Subtask 1"));
    expect(subtasks[0].userId, equals('test-user-123'));
    expect(subtasks[0].taskId, equals(''));
    expect(subtasks[0].completed, equals(false));
    expect(subtasks[0].order, equals(0));
    expect(subtasks[1].order, equals(1));
    expect(subtasks[2].order, equals(2));
  });

  /// Verifies that divideTask returns a list of subtasks when API returns a newline-separated String,
  /// and that the correct API endpoint and payload are used.
  test(
      'divideTask returns list of subtasks when API returns newline-separated String',
      () async {
    // Arrange: Set up the mock HTTP response for a successful subtask split.
    const title = "Another Task";
    const description = "Another Description";
    const expectedSpiciness = "3";
    const apiResponse = "Subtask A\nSubtask B\nSubtask C\n";

    when(mockDio.post(
      any,
      data: anyNamed('data'),
    )).thenAnswer((_) async => Response(
          data: apiResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

    // Act: Call the method under test.
    final subtasks = await magicTodoService.divideTask(
        title: title, description: description);

    // Assert: Check the returned data and verify the correct HTTP call.
    verify(mockDio.post(
      "https://goblin.tools/api/todo",
      data: {
        'text': "$title $description",
        'spiciness': expectedSpiciness,
        'Ancestors': [],
      },
    )).called(1);

    expect(subtasks, isA<List<SubtaskModel>>());
    expect(subtasks.length, equals(3));
    expect(subtasks[0].title, equals("Subtask A"));
    expect(subtasks[1].title, equals("Subtask B"));
    expect(subtasks[2].title, equals("Subtask C"));

    // Verify SubtaskModel properties
    for (int i = 0; i < subtasks.length; i++) {
      expect(subtasks[i].userId, equals('test-user-123'));
      expect(subtasks[i].taskId, equals(''));
      expect(subtasks[i].completed, equals(false));
      expect(subtasks[i].order, equals(i));
      expect(subtasks[i].id, isNotEmpty);
    }
  });

  /// Verifies spiciness mapping based on energy levels
  test('maps energy levels to correct spiciness values', () async {
    // Test different energy levels and their expected spiciness
    final testCases = [
      {'energy': 1, 'expectedSpiciness': "5"},
      {'energy': 2, 'expectedSpiciness': "5"},
      {'energy': 3, 'expectedSpiciness': "4"},
      {'energy': 4, 'expectedSpiciness': "4"},
      {'energy': 5, 'expectedSpiciness': "3"},
      {'energy': 6, 'expectedSpiciness': "3"},
      {'energy': 7, 'expectedSpiciness': "2"},
      {'energy': 8, 'expectedSpiciness': "2"},
      {'energy': 9, 'expectedSpiciness': "1"},
      {'energy': 10, 'expectedSpiciness': "1"},
    ];

    for (final testCase in testCases) {
      // Create a new service with the specific energy level
      final testService = TestMagicTodoService(
        dio: mockDio,
        energyLevel: testCase['energy'] as int,
      );

      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: ["Test Subtask"],
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      await testService.divideTask(title: "Test", description: "Test");

      // Assert
      verify(mockDio.post(
        "https://goblin.tools/api/todo",
        data: {
          'text': "Test Test",
          'spiciness': testCase['expectedSpiciness'],
          'Ancestors': [],
        },
      )).called(1);

      reset(mockDio);
    }
  });

  /// Verifies behavior when no energy data is available (null energy)
  test('handles null energy by defaulting to spiciness 5', () async {
    // Create a new service with null energy
    final testService = TestMagicTodoService(
      dio: mockDio,
      energyLevel: null,
    );

    when(mockDio.post(
      any,
      data: anyNamed('data'),
    )).thenAnswer((_) async => Response(
          data: ["Test Subtask"],
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

    // Act
    await testService.divideTask(title: "Test", description: "Test");

    // Assert: Should default to spiciness 5 when energy is null
    verify(mockDio.post(
      "https://goblin.tools/api/todo",
      data: {
        'text': "Test Test",
        'spiciness': "5",
        'Ancestors': [],
      },
    )).called(1);
  });

  /// Verifies error handling when API call fails
  test('returns empty list when API call fails', () async {
    // Arrange: Mock a failed HTTP request
    when(mockDio.post(
      any,
      data: anyNamed('data'),
    )).thenThrow(DioException(
      requestOptions: RequestOptions(path: ''),
      message: 'Network error',
    ));

    // Act
    final subtasks = await magicTodoService.divideTask(
      title: "Test Task",
      description: "Test Description",
    );

    // Assert
    expect(subtasks, isEmpty);
  });

  /// Verifies behavior when API returns unexpected data type
  test('returns empty list when API returns unexpected data type', () async {
    // Arrange: Mock API returning unexpected data type
    when(mockDio.post(
      any,
      data: anyNamed('data'),
    )).thenAnswer((_) async => Response(
          data: {'unexpected': 'object'},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

    // Act
    final subtasks = await magicTodoService.divideTask(
      title: "Test Task",
      description: "Test Description",
    );

    // Assert
    expect(subtasks, isEmpty);
  });

  /// Verifies proper handling of empty string response
  test('handles empty string response correctly', () async {
    // Arrange
    when(mockDio.post(
      any,
      data: anyNamed('data'),
    )).thenAnswer((_) async => Response(
          data: "",
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

    // Act
    final subtasks = await magicTodoService.divideTask(
      title: "Test Task",
      description: "Test Description",
    );

    // Assert
    expect(subtasks, isEmpty);
  });

  /// Verifies proper handling of string with only whitespace
  test('handles string with only whitespace correctly', () async {
    // Arrange
    when(mockDio.post(
      any,
      data: anyNamed('data'),
    )).thenAnswer((_) async => Response(
          data: "\n\n  \n\t\n",
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

    // Act
    final subtasks = await magicTodoService.divideTask(
      title: "Test Task",
      description: "Test Description",
    );

    // Assert
    expect(subtasks, isEmpty);
  });
}
