/// This file contains widget tests focused on the UI aspects of the main Tracker Screen.
///
/// It verifies:
/// - The presence and basic interactivity of UI elements like the IconGrid.
/// - The screen's responsiveness to different sizes (overflow checks).
/// - Correct localization of static text elements on the screen.
///
/// # How these tests work
/// - `flutter_test` and `mockito` are used. `ProviderScope` overrides services.
/// - `WidgetTester` simulates interactions and screen manipulations (size, locale).
/// - `expect` asserts UI states (widget presence, text content).
/// - Golden file testing (`matchesGoldenFile`) can be added for comprehensive visual regression testing.
///
/// # Mocking Strategy
/// - `FakeAuthService` and `MockDatabaseService` are used as in other tests to ensure
///   the app initializes correctly and dependent features don't break.
///
/// # How to run
/// - Run with `flutter test test/features/tracker/tracker_screen_ui_test.dart`

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
import 'package:spiceease/data/models/mood_model.dart';
import 'package:spiceease/main.dart'; // Assuming MyApp is your root widget
import 'package:spiceease/core/database/database_service.dart';
import 'package:spiceease/features/tracker/presentation/widgets/icon_grid.dart';
import 'package:spiceease/features/tracker/presentation/widgets/list_modal.dart';
import 'package:spiceease/l10n/app_localizations.dart';

import 'tracker_mood_test.mocks.dart'; // Reusing mocks

/// A fake implementation of [AuthService] for testing purposes.
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

@GenerateMocks([DatabaseService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDatabaseService mockDatabaseService;
  late FakeAuthService fakeAuthService;
  late List<Override> testProviderOverrides;
  const String moodEntriesCollectionName = 'mood_entries';

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    fakeAuthService = FakeAuthService();
    testProviderOverrides = [
      databaseServiceProvider.overrideWithValue(mockDatabaseService),
      authServiceProvider.overrideWithValue(fakeAuthService),
    ];

    // Basic stubs for database queries to prevent null errors during app init
    final collectionsToStub = [
      moodEntriesCollectionName,
      'medications',
      'tasks',
      'recipes',
      'energy_entries',
      'symptoms',
      'habits'
    ];
    for (var collectionName in collectionsToStub) {
      when(mockDatabaseService.query(
        collection: collectionName,
        filters: anyNamed('filters'),
        orderBy: anyNamed('orderBy'),
        limit: anyNamed('limit'),
        startAfter: anyNamed('startAfter'),
        endBefore: anyNamed('endBefore'),
      )).thenAnswer((_) async => []);
    }
    // Stub for querying mood documents specifically for IconListLauncher stats
    when(mockDatabaseService.query(
      collection: moodEntriesCollectionName,
      filters: anyNamed('filters'),
      orderBy: anyNamed('orderBy'),
      limit: anyNamed('limit'),
      startAfter: anyNamed('startAfter'),
      endBefore: anyNamed('endBefore'),
    )).thenAnswer((_) async => [
          // Provide a sample mood entry if statsLabelBuilder depends on it
          // Or an empty list if that's the default state you want to test
        ]);
  });

  group('Tracker Screen UI', () {
    testWidgets(
        'IconGrid displays mood tracking icon and is tappable, opening ListModal',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(overrides: testProviderOverrides, child: const MyApp()),
      );
      await tester.pumpAndSettle();

      // Ensure the IconGrid itself is present
      final iconGridFinder = find.byType(IconGrid);
      expect(iconGridFinder, findsOneWidget,
          reason: "IconGrid should be present on the tracker screen.");

      // Find the specific IconListLauncher for Mood by its icon or title if more specific finders are needed
      final moodIconLauncherFinder = find.widgetWithIcon(
          InkWell,
          FontAwesomeIcons
              .faceSmile); // IconListLauncher wraps IconButton in InkWell
      expect(moodIconLauncherFinder, findsOneWidget,
          reason: "Mood tracking icon launcher should be in the grid.");

      // Tap the icon part of the IconListLauncher
      final moodIconButtonFinder = find.descendant(
          of: moodIconLauncherFinder, matching: find.byType(IconButton));
      expect(moodIconButtonFinder, findsOneWidget);
      await tester.tap(moodIconButtonFinder);
      await tester.pumpAndSettle(); // For dialog to appear

      // Verify ListModal is opened
      expect(find.byType(ListModal<MoodModel>), findsOneWidget,
          reason: "Tapping mood icon should open the ListModal for MoodModel.");
      // And it should contain an add button
      expect(
          find.descendant(
              of: find.byType(ListModal<MoodModel>),
              matching: find.byIcon(Icons.add_circle_outline)),
          findsOneWidget,
          reason: "List modal should open with an add button.");
    });

    testWidgets('Tracker screen handles various screen sizes without overflow',
        (WidgetTester tester) async {
      final testSizes = [
        const Size(320, 480), // Small phone
        const Size(600, 800), // Tablet portrait
        const Size(1024, 768), // Tablet landscape
        const Size(400, 300), // Wide but short - good for testing Wrap behavior
      ];

      for (final size in testSizes) {
        await tester.binding.setSurfaceSize(size);
        tester.view.physicalSize = size; // Important for RenderBox calculations
        tester.view.devicePixelRatio = 1.0; // Consistent pixel ratio

        await tester.pumpWidget(
          ProviderScope(overrides: testProviderOverrides, child: const MyApp()),
        );
        // It's crucial to pumpAndSettle to allow layout calculations after size change.
        await tester.pumpAndSettle(
            const Duration(seconds: 1)); // Allow ample time for layout

        final iconGridFinder = find.byType(IconGrid);
        expect(iconGridFinder, findsOneWidget);

        expect(tester.takeException(), isNull,
            reason: "Screen should not overflow at size $size");

        // Golden file testing is also excellent for this:
        // await expectLater(find.byType(IconGrid), matchesGoldenFile('goldens/icon_grid_size_${size.width}x${size.height}.png'));
      }
      await tester.binding.setSurfaceSize(null); // Reset to default
    });

    testWidgets('Tracker screen icon labels are localized',
        (WidgetTester tester) async {
      final supportedLocales = AppLocalizations.supportedLocales;
      if (supportedLocales.isEmpty) {
        debugPrint(
            "Skipping localization test: No supported locales found in AppLocalizations.");
        return;
      }

      for (final locale in supportedLocales) {
        debugPrint("Testing locale: $locale");
        // Create a new MyApp instance with the specific locale for testing
        // This ensures that AppLocalizations.of(context) gets the correct locale.
        await tester.pumpWidget(
          ProviderScope(
            overrides: testProviderOverrides,
            child: MaterialApp(
              // Use MaterialApp directly to set locale for this test instance
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: const Scaffold(
                  body:
                      MyApp()), // Assuming MyApp can be a child or contains the IconGrid
            ),
          ),
        );
        await tester
            .pumpAndSettle(); // Wait for localization to load and UI to rebuild

        // Get localizations from a context within the pumped widget tree
        final BuildContext context =
            tester.element(find.byType(IconGrid)); // Get context from IconGrid
        final localizations = AppLocalizations.of(context)!;

        // Verify the "Mood" IconListLauncher title
        // The IconListLauncher displays its title as a Text widget.
        expect(find.text(localizations.mood), findsWidgets,
            reason:
                "Mood icon label should be localized for $locale. Found: ${localizations.mood}");

        // If your main screen has a title like "Home" that is localized:
        // final homeScreenTitleFinder = find.text(localizations.home);
        // expect(homeScreenTitleFinder, findsOneWidget, reason: "Home screen title should be localized for $locale");
      }
    });
  });
}
