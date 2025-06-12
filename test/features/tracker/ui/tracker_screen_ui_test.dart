import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spiceease/core/auth/auth_service.dart';
import 'package:spiceease/core/auth/user_model.dart';
import 'package:spiceease/core/database/database_provider.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/core/database/database_service.dart'
    show DatabaseService, BasicFilter, QueryOperator, QueryOrder;
import 'package:spiceease/core/database/firestore_date_adapter.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:spiceease/data/models/mood_model.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/features/tracker/presentation/widgets/icon_list_launcher.dart';
import 'package:spiceease/features/tracker/presentation/widgets/list_modal.dart';
import 'package:spiceease/features/tracker/presentation/widgets/modals.dart';
import 'package:spiceease/main.dart';
import 'package:collection/collection.dart';

// Import the generated mock file
import '../tracker_mood_test.mocks.dart';

/// This file contains widget tests for the Tracker Screen UI, focusing on the
/// interaction with the IconGrid and its IconListLaunchers, particularly for mood tracking.
///
/// # Testing Strategy
/// - **Widget Tests**: These tests verify the UI behavior of the Tracker screen.
/// - **Riverpod Overrides**: Providers are overridden to supply mock data or mock services.
/// - **Mockito**: Used to mock `DatabaseService` and `AuthService` for controlled test scenarios.
/// - **Finders**: Flutter's widget finders are used to locate and interact with UI elements.
///
/// # Key Areas Tested
/// - Display of `IconListLauncher` for moods.
/// - Tapping the mood `IconListLauncher` to open `ListModal` when mood entries exist.
/// - Tapping the mood `IconListLauncher` to open `MoodLevelEditorModal` when no mood entries exist.
/// - Ensuring the screen handles various screen sizes without overflow.
///
/// # How to run
/// - Run with `flutter test test/features/tracker/tracker_screen_ui_test.dart`
///
/// # Important Notes
/// - The `BasicFilter` class (expected to be in `core/database/database_service.dart`)
///   should correctly implement `operator==` and `hashCode` for `ListEquality` to work,
///   especially for `Timestamp` values when comparing filter lists.

/// Fake implementation of [AuthService] for testing purposes.
/// Provides a logged-in user state.
class FakeAuthService extends Mock implements AuthService {
  @override
  Future<void> initialize() async {}

  @override
  Stream<AppUser?> authStateChanges() =>
      Stream.value(AppUser(uid: 'test-user', email: 'test@example.com'));

  @override
  Future<bool> isSignedIn() async => true;

  @override
  Future<AppUser?> getCurrentUser() async =>
      AppUser(uid: 'test-user', email: 'test@example.com');

  @override
  Future<bool> validateSession() async => true;

  @override
  Future<void> signOut() async {}
}

/// Generates mocks for [DatabaseService].
@GenerateMocks([DatabaseService])
void main() {
  // Ensures that Flutter bindings are initialized for widget testing.
  TestWidgetsFlutterBinding.ensureInitialized();

  // Declare variables for mock services and provider overrides.
  late MockDatabaseService mockDatabaseService;
  late FakeAuthService fakeAuthService;
  late List<Override> globalTestProviderOverrides;

  // Define constants used across tests.
  const String moodEntriesCollectionName = 'mood_entries';
  const String testUserId = 'test-user';
  final fixedTestDate = DateTime(2025, 5, 30); // A consistent date for testing.

  /// Helper function to create the expected list of [BasicFilter] for mood queries.
  /// This ensures consistency in how filters are defined for mock expectations.
  List<BasicFilter> _createExpectedMoodFilters(DateTime date, String userId) {
    final startOfDay = FirestoreDateAdapter.toTimestamp(
        DateTime(date.year, date.month, date.day, 0, 0, 0, 0));
    final startOfNextDay = FirestoreDateAdapter.toTimestamp(
        DateTime(date.year, date.month, date.day, 0, 0, 0, 0)
            .add(const Duration(days: 1)));
    return [
      BasicFilter('user_id', QueryOperator.equal, userId),
      BasicFilter('created_at', QueryOperator.greaterThanOrEqual, startOfDay),
      BasicFilter('created_at', QueryOperator.lessThan, startOfNextDay),
    ];
  }

  /// Sets up mock services and global provider overrides before each test.
  setUp(() {
    mockDatabaseService = MockDatabaseService();
    fakeAuthService = FakeAuthService();

    globalTestProviderOverrides = [
      databaseServiceProvider.overrideWithValue(mockDatabaseService),
      authServiceProvider.overrideWithValue(fakeAuthService),
    ];

    // Default mock behaviors for common database operations.
    when(mockDatabaseService.generateId()).thenReturn('mock-id');
    when(mockDatabaseService.createDocument(any, any))
        .thenAnswer((_) async => <String, dynamic>{});
    when(mockDatabaseService.updateDocument(any, any))
        .thenAnswer((_) async => <String, dynamic>{});
    when(mockDatabaseService.deleteDocument(any)).thenAnswer((_) async => {});

    // Default generic mock for any query, returning an empty list.
    // Specific queries will be mocked per test case.
    when(mockDatabaseService.query(
      collection: anyNamed('collection'),
      filters: anyNamed('filters'),
      orderBy: anyNamed('orderBy'),
      limit: anyNamed('limit'),
      startAfter: anyNamed('startAfter'),
      endBefore: anyNamed('endBefore'),
    )).thenAnswer((_) async => []);
  });

  /// Resets mocks after each test to ensure test isolation.
  tearDown(() {
    reset(mockDatabaseService);
  });

  group('Tracker Screen UI', () {
    /// Test case: Verifies that tapping the mood icon opens the ListModal
    /// when mood entries exist for the selected date.
    testWidgets(
      'IconGrid displays mood tracking icon and is tappable, opening ListModal when moods exist',
      (WidgetTester tester) async {
        // Arrange: Prepare mood data and expected database filters.
        final moodData = MoodModel(
          id: 'm1',
          userId: testUserId,
          moodLevel: 5,
          notes: 'test mood',
          createdAt: fixedTestDate,
        );
        final expectedFilters =
            _createExpectedMoodFilters(fixedTestDate, testUserId);

        // Mock the database query for mood entries to return the prepared moodData.
        when(mockDatabaseService.query(
          collection: moodEntriesCollectionName,
          filters: anyNamed('filters'),
          orderBy: anyNamed('orderBy'),
          // Other query parameters can be set to anyNamed if not critical for this specific mock.
        )).thenAnswer((invocation) async {
          final receivedDynamicFilters = invocation
              .namedArguments[const Symbol('filters')] as List<dynamic>?;
          List<BasicFilter>? convertedActualFilters;
          if (receivedDynamicFilters != null) {
            convertedActualFilters = receivedDynamicFilters
                .map((df) => BasicFilter((df as dynamic).field as String,
                    (df as dynamic).op as QueryOperator, (df as dynamic).value))
                .toList();
          }

          if (const ListEquality<BasicFilter>()
              .equals(convertedActualFilters, expectedFilters)) {
            return [moodData.toMap()];
          }
          return []; // Return empty if filters don't match, causing test to fail if data isn't loaded.
        });

        // Act: Pump the MyApp widget with necessary provider overrides.
        await tester.pumpWidget(
          ProviderScope(overrides: [
            ...globalTestProviderOverrides,
            selectedDateProvider.overrideWith((ref) => fixedTestDate),
          ], child: const MyApp()),
        );
        // Wait for all asynchronous operations and UI updates to complete.
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Assert: Find the mood IconListLauncher.
        final moodIconListLauncherFinder = find.ancestor(
          of: find.byIcon(FontAwesomeIcons.faceSmile),
          matching: find.byType(IconListLauncher<MoodModel>),
        );
        expect(moodIconListLauncherFinder, findsOneWidget,
            reason: "Mood IconListLauncher should be present.");

        // Verify that the launcher has items.
        final launcherWidget = tester
            .widget<IconListLauncher<MoodModel>>(moodIconListLauncherFinder);
        expect(launcherWidget.items.isNotEmpty, isTrue,
            reason:
                "Mood items should be loaded. Items found: ${launcherWidget.items.length}");

        // Find and tap the IconButton within the IconListLauncher.
        final iconButtonFinder = find.descendant(
          of: moodIconListLauncherFinder,
          matching: find.byType(IconButton),
        );
        expect(iconButtonFinder, findsOneWidget,
            reason:
                "IconButton within Mood IconListLauncher should be present.");
        await tester.ensureVisible(iconButtonFinder);
        await tester.tap(iconButtonFinder);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Verify that the ListModal for MoodModel is now displayed.
        expect(find.byType(ListModal<MoodModel>), findsOneWidget,
            reason: "ListModal<MoodModel> should open.");
      },
    );

    /// Test case: Verifies that tapping the mood icon opens the MoodLevelEditorModal
    /// when no mood entries exist for the selected date.
    testWidgets(
      'IconGrid displays mood tracking icon and is tappable, opening MoodLevelEditorModal when no moods exist',
      (WidgetTester tester) async {
        // Arrange: Use a different date to ensure no data is returned by default.
        final specificTestDate = DateTime(2025, 5, 31);
        final expectedFilters =
            _createExpectedMoodFilters(specificTestDate, testUserId);

        // Mock the database query for mood entries to return an empty list.
        when(mockDatabaseService.query(
          collection: moodEntriesCollectionName,
          filters: anyNamed('filters'),
          orderBy: anyNamed('orderBy'),
        )).thenAnswer((invocation) async {
          final receivedDynamicFilters = invocation
              .namedArguments[const Symbol('filters')] as List<dynamic>?;
          List<BasicFilter>? convertedActualFilters;
          if (receivedDynamicFilters != null) {
            convertedActualFilters = receivedDynamicFilters
                .map((df) => BasicFilter((df as dynamic).field as String,
                    (df as dynamic).op as QueryOperator, (df as dynamic).value))
                .toList();
          }
          if (const ListEquality<BasicFilter>()
              .equals(convertedActualFilters, expectedFilters)) {
            return []; // Return empty list for this specific query.
          }
          return []; // Default empty for safety, though the specific mock should hit.
        });

        // Act: Pump the MyApp widget.
        await tester.pumpWidget(
          ProviderScope(overrides: [
            ...globalTestProviderOverrides,
            selectedDateProvider.overrideWith((ref) => specificTestDate),
          ], child: const MyApp()),
        );
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Assert: Find the mood IconListLauncher.
        final moodIconListLauncherFinder = find.ancestor(
          of: find.byIcon(FontAwesomeIcons.faceSmile),
          matching: find.byType(IconListLauncher<MoodModel>),
        );
        expect(moodIconListLauncherFinder, findsOneWidget,
            reason: "Mood IconListLauncher should be present.");

        // Verify that the launcher has no items.
        final launcherWidget = tester
            .widget<IconListLauncher<MoodModel>>(moodIconListLauncherFinder);
        expect(launcherWidget.items.isEmpty, isTrue,
            reason:
                "Mood items should be empty. Items found: ${launcherWidget.items.length}");

        // Find and tap the IconButton within the IconListLauncher.
        final iconButtonFinder = find.descendant(
          of: moodIconListLauncherFinder,
          matching: find.byType(IconButton),
        );
        expect(iconButtonFinder, findsOneWidget,
            reason:
                "IconButton within Mood IconListLauncher (no data) should be present.");
        await tester.ensureVisible(iconButtonFinder);
        await tester.tap(iconButtonFinder);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Verify that the MoodLevelEditorModal is now displayed.
        expect(find.byType(MoodLevelEditorModal), findsOneWidget,
            reason: "MoodLevelEditorModal should open.");
      },
    );

    /// Test group for screen overflow checks.
    /// Verifies that the Tracker screen layout adapts to various screen sizes
    /// without causing overflow errors.
    group('Screen Overflow Tests', () {
      final testSizes = [
        const Size(320, 480), // Small phone
        const Size(600, 800), // Tablet portrait
        const Size(1024, 768), // Tablet landscape
        const Size(400, 300), // Small landscape
      ];

      for (final size in testSizes) {
        testWidgets(
          'Tracker screen handles $size without overflow',
          (WidgetTester tester) async {
            // Arrange: Set the screen size.
            await tester.binding.setSurfaceSize(size);
            tester.view.devicePixelRatio =
                1.0; // Reset device pixel ratio for consistency.

            // Act: Pump the MyApp widget.
            await tester.pumpWidget(
              ProviderScope(overrides: [
                ...globalTestProviderOverrides,
                // Use a fixed date for consistency in data loading.
                selectedDateProvider
                    .overrideWith((ref) => DateTime(2025, 5, 30)),
              ], child: const MyApp()),
            );
            // Wait for UI to settle.
            await tester.pumpAndSettle(const Duration(seconds: 2));

            // Assert: Check for any overflow exceptions.
            expect(tester.takeException(), isNull,
                reason: "Screen should not overflow at size $size");
          },
        );
      }
      // Clean up after screen size tests.
      tearDownAll(() {
        // Made non-async as only synchronous calls remain
        final TestWidgetsFlutterBinding binding =
            TestWidgetsFlutterBinding.instance;
        binding.window.clearPhysicalSizeTestValue();
        binding.window.clearDevicePixelRatioTestValue();
      });
    });
  });
}
