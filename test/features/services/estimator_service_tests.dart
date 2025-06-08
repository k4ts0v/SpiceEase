/// This file demonstrates contract tests for the Est/// This file demonstrates contract tests for the EstimatorService interface,
/// using the Mockito package to mock HTTP and provider dependencies.
///
/// These tests verify that the service:
/// - Calls the correct goblin.tools API endpoints with the expected payloads
/// - Correctly decodes and returns estimates from the backend
/// - Handles API responses and localization parsing
///
/// # How these tests work
/// - All HTTP requests are intercepted using a mock Dio client.
/// - No real network or backend is used; everything is simulated.
/// - The EnergyService is also mocked to provide a fake energy level.
///
/// # Why use these tests?
/// - To ensure your service correctly formats requests and parses responses.
/// - To catch regressions if you change request/response logic.
/// - To verify integration with energy and localization providers.
///
/// # How to run
/// - Run with `flutter test` as usual.
/// - No external dependencies or network required.
///
/// # See also
/// - https://docs.flutter.dev/testing
/// - https://pub.dev/packages/mockito

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/energy_model.dart';
import 'package:spiceease/data/services/energy_service.dart';
import 'package:spiceease/data/services/estimator_service.dart';
import 'package:spiceease/data/providers/energy_provider.dart';
import 'package:spiceease/l10n/app_localizations.dart';

@GenerateMocks([Dio])
import 'estimator_service_tests.mocks.dart';

/// Dummy EnergyService to override the provider
class DummyEnergyService implements EnergyService {
  @override
  Future<EnergyModel?> getLastEnergyEntry() async {
    return EnergyModel(
      id: 'dummy',
      userId: 'dummy',
      energyLevel: 7,
      notes: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<EnergyModel> createEnergy(EnergyModel energy) =>
      throw UnimplementedError();

  @override
  Future<void> deleteEnergy(String id) => throw UnimplementedError();

  @override
  String generateId() => 'dummy';

  @override
  Future<List<EnergyModel>> getAllEnergyEntries() => throw UnimplementedError();

  @override
  Future<EnergyModel> updateEnergy(String id, EnergyModel energy) =>
      throw UnimplementedError();

  @override
  Stream<List<EnergyModel>> watchAllEnergyEntries() =>
      throw UnimplementedError();

  @override
  Stream<EnergyModel?> watchEnergyEntry(String id) =>
      throw UnimplementedError();

  @override
  Future<EnergyModel?> getEnergyEntryByDate(DateTime date) =>
      throw UnimplementedError();

  @override
  Future<String> getCurrentUserId() => Future.value('dummy');

  @override
  Future<EnergyModel?> getEnergyById(String id) => throw UnimplementedError();

  @override
  Future<List<EnergyModel>> getEnergyEntriesForDate(DateTime date) =>
      throw UnimplementedError();
}

void main() {
  // This ensures the Flutter test environment is initialized.
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDio mockDio;
  late ProviderContainer container;
  late EstimatorService estimatorService;

  // The setUp() function runs before every test in this file.
  // It prepares a fresh instance of the service and mocks for each test.
  setUp(() {
    mockDio = MockDio();

    container = ProviderContainer(overrides: [
      energyServiceProvider.overrideWithValue(DummyEnergyService()),
      estimatorServiceProvider.overrideWithProvider(
        Provider((ref) => EstimatorService(ref, dio: mockDio)),
      ),
    ]);

    estimatorService = container.read(estimatorServiceProvider);
  });

  tearDown(() {
    container.dispose();
  });

  /// Verifies that estimateTask returns API response correctly and calls the correct endpoint.
  test('estimateTask returns API response correctly', () async {
    const title = "Test Estimate";
    const description = "Estimate description";
    const condition = "urgent";
    const expectedSpiciness = 2;

    final expectedBody = {
      "text": "$title $description $condition",
      "spiciness": expectedSpiciness,
      "Ancestors": [],
    };

    const apiResponseData = {"estimatedTime": "15 minutes"};

    when(mockDio.post(
      any,
      data: anyNamed('data'),
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
          data: apiResponseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

    final response =
        await estimatorService.estimateTask(title, description, condition);

    verify(mockDio.post(
      'https://goblin.tools/api/estimator',
      data: {
        "text": "$title $description $condition",
        "spiciness": 4,
        "Ancestors": [],
      },
      options: anyNamed('options'),
    )).called(1);

    expect(response, equals(apiResponseData));
  });

  /// Verifies that parseResponseWithLocale returns parsed estimate for range response.
  testWidgets(
      'parseResponseWithLocale returns parsed estimate for range response',
      (tester) async {
    const testResponse = "10 to 20 minutes";

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: [Locale('en')],
      home: Scaffold(body: Builder(builder: (context) => const SizedBox())),
    ));

    final context = tester.element(find.byType(SizedBox));
    final result =
        await estimatorService.parseResponseWithLocale(testResponse, context);

    expect(result, isNotNull);
    expect(result!["estimate"], equals("15"));
    expect(result["unit"], equals("minutes"));
  });

  /// Verifies that parseResponseWithLocale handles zero seconds fallback.
  testWidgets('parseResponseWithLocale handles zero seconds fallback',
      (tester) async {
    const testResponse = "0 seconds";

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: [Locale('en')],
      home: Scaffold(body: Builder(builder: (context) => const SizedBox())),
    ));

    final context = tester.element(find.byType(SizedBox));
    final result =
        await estimatorService.parseResponseWithLocale(testResponse, context);

    expect(result, isNotNull);
    expect(result!["estimate"], equals("5")); // fallback to 5 seconds
    expect(result["unit"], equals("seconds"));
  });

  // TODO: make this functionality, currently it returns the unit in English.
  /// Verifies that parseResponseWithLocale works for Spanish locale and Spanish text.
  // testWidgets(
  //     'parseResponseWithLocale works for Spanish locale and Spanish text',
  //     (tester) async {
  //   // Spanish task and condition
  //   const title = "Comprar pan";
  //   const description = "Ir a la panadería y comprar pan fresco";
  //   const condition = "urgente";
  //   const testResponse = "10 a 20 minutos";

  //   // Mock the API response for the Spanish estimateTask call
  //   when(mockDio.post(
  //     any,
  //     data: anyNamed('data'),
  //     options: anyNamed('options'),
  //   )).thenAnswer((_) async => Response(
  //         data: {"estimatedTime": testResponse},
  //         statusCode: 200,
  //         requestOptions: RequestOptions(path: ''),
  //       ));

  //   await tester.pumpWidget(MaterialApp(
  //     localizationsDelegates: AppLocalizations.localizationsDelegates,
  //     supportedLocales: const [Locale('es')],
  //     home: Scaffold(body: Builder(builder: (context) => SizedBox())),
  //   ));

  //   final context = tester.element(find.byType(SizedBox));
  //   // This call is now stubbed and will not throw
  //   final apiResponse =
  //       await estimatorService.estimateTask(title, description, condition);
  //   // For this test, we focus on parsing the Spanish response string:
  //   final result =
  //       await estimatorService.parseResponseWithLocale(testResponse, context);

  //   expect(result, isNotNull);
  //   expect(result!["estimate"], equals("15"));
  //   expect(result["unit"], equals("minutos"));
  // });
}
