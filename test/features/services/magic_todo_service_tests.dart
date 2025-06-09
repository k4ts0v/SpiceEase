/// This file demonstrates contract tests for the MagicTodoService interface,
/// using the Mockito package to mock HTTP and provider dependencies.
///
/// These tests verify that the service:
/// - Calls the correct goblin.tools API endpoints with the expected payloads
/// - Correctly decodes and returns subtasks from the backend
/// - Handles both list and string API responses
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
import 'package:spiceease/data/providers/unified_auth_provider.dart';
import 'package:spiceease/data/services/magic_todo_service.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/services/energy_service.dart';
import 'package:spiceease/data/models/energy_model.dart';
import 'package:spiceease/data/providers/energy_provider.dart';

@GenerateMocks([Dio])
import 'magic_todo_service_tests.mocks.dart';

// Dummy EnergyService for provider override
class DummyEnergyService implements EnergyService {
  @override
  Future<EnergyModel?> getLastEnergyEntry() async {
    return EnergyModel(
      id: 'dummy',
      userId: 'dummy',
      energyLevel: 5,
      notes: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<EnergyModel> createEnergy(EnergyModel energy) => throw UnimplementedError();
  @override
  Future<void> deleteEnergy(String id) => throw UnimplementedError();
  @override
  String generateId() => 'dummy';
  @override
  Future<List<EnergyModel>> getAllEnergyEntries() => throw UnimplementedError();
  @override
  Future<EnergyModel> updateEnergy(String id, EnergyModel energy) => throw UnimplementedError();
  @override
  Stream<List<EnergyModel>> watchAllEnergyEntries() => throw UnimplementedError();
  @override
  Stream<EnergyModel?> watchEnergyEntry(String id) => throw UnimplementedError();
  @override
  Future<EnergyModel?> getEnergyEntryByDate(DateTime date) => throw UnimplementedError();
  @override
  Future<String> getCurrentUserId() => Future.value('dummy');
  @override
  Future<EnergyModel?> getEnergyById(String id) => throw UnimplementedError();
  @override
  Future<List<EnergyModel>> getEnergyEntriesForDate(DateTime date) => throw UnimplementedError();
}

void main() {
  // This ensures the Flutter test environment is initialized.
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDio mockDio;
  late ProviderContainer container;
  late MagicTodoService magicTodoService;

  // The setUp() function runs before every test in this file.
  // It prepares a fresh instance of the service and mocks for each test.
  setUp(() {
    mockDio = MockDio();
    container = ProviderContainer(overrides: [
      energyServiceProvider.overrideWithValue(DummyEnergyService()),
      magicTodoServiceProvider.overrideWithProvider(
        Provider((ref) => MagicTodoService(ref, dio: mockDio)),
      ),
      currentUserProvider.overrideWithProvider(
        FutureProvider((ref) async => null),
      ),
    ]);
    magicTodoService = container.read(magicTodoServiceProvider);
  });

  tearDown(() {
    container.dispose();
  });

  /// Verifies that divideTask returns a list of subtasks when API returns a List,
  /// and that the correct API endpoint and payload are used.
  test('divideTask returns list of subtasks when API returns List', () async {
    // Arrange: Set up the mock HTTP response for a successful subtask split.
    final title = "Test Task";
    final description = "Test Description";
    final expectedSpiciness = "3"; // for energyLevel 5

    final apiResponse = ["Subtask 1", "Subtask 2"];
    when(mockDio.post(
      any,
      data: anyNamed('data'),
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
          data: apiResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

    // Act: Call the method under test.
    final subtasks = await magicTodoService.divideTask(
        title: title, description: description);

    // Assert: Check the returned data and verify the correct HTTP call.
    final expectedBody = {
      "text": "$title $description",
      "spiciness": expectedSpiciness,
      "Ancestors": [],
    };
    verify(mockDio.post(
      "https://goblin.tools/api/todo",
      data: expectedBody,
      options: anyNamed('options'),
    )).called(1);

    expect(subtasks, isA<List<SubtaskModel>>());
    expect(subtasks.length, equals(apiResponse.length));
    expect(subtasks.first.title, equals("Subtask 1"));
  });

  /// Verifies that divideTask returns a list of subtasks when API returns a newline-separated String,
  /// and that the correct API endpoint and payload are used.
  test('divideTask returns list of subtasks when API returns newline-separated String', () async {
    // Arrange: Set up the mock HTTP response for a successful subtask split.
    final title = "Another Task";
    final description = "Another Description";
    final expectedSpiciness = "3";
    final apiResponse = "Subtask A\nSubtask B\nSubtask C\n";
    when(mockDio.post(
      any,
      data: anyNamed('data'),
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
          data: apiResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

    // Act: Call the method under test.
    final subtasks = await magicTodoService.divideTask(
        title: title, description: description);

    // Assert: Check the returned data and verify the correct HTTP call.
    final expectedBody = {
      "text": "$title $description",
      "spiciness": expectedSpiciness,
      "Ancestors": [],
    };
    verify(mockDio.post(
      "https://goblin.tools/api/todo",
      data: expectedBody,
      options: anyNamed('options'),
    )).called(1);

    expect(subtasks, isA<List<SubtaskModel>>());
    expect(subtasks.length, equals(3));
    expect(subtasks[1].title, equals("Subtask B"));
  });
}