/// This file contains comprehensive UI tests for the AboutScreen widget,
/// testing various screen sizes, loading states, error handling, and user interactions.
///
/// These tests verify that the AboutScreen:
/// - Displays the correct UI elements (app info, version, build number)
/// - Shows appropriate loading and error states
/// - Handles responsive design across different screen sizes
/// - Contains the expected SettingsOptionTile widgets with correct icons
/// - Adapts to screen size by showing/hiding the Contact section
///
/// # How these tests work
/// - Uses MockUIAboutController to simulate different controller states
/// - Tests across multiple standardized screen sizes (mobile to tablet)
/// - Mocks PackageInfo data to test version information display
/// - Uses WidgetTester to pump widgets and verify UI elements
///
/// # Why use these tests?
/// - To ensure the AboutScreen renders correctly across devices
/// - To verify responsive behavior and adaptive layout
/// - To catch UI regressions when modifying the about screen
/// - To validate proper integration with AboutController states
///
/// # How to run
/// - Run with `flutter test` as usual
/// - No external dependencies required (uses mocked data)
/// - Tests can be run individually or as a complete suite
///
/// # See also
/// - https://docs.flutter.dev/testing/widget-testing
/// - https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:spiceease/features/settings/about_screen.dart';
import 'package:spiceease/features/settings/about_controller.dart';
import 'package:spiceease/l10n/app_localizations.dart';
import 'package:spiceease/components/settings/settings_option_tile.dart';

/// Standardized screen sizes for consistent testing across different devices.
/// These sizes represent common device categories from smallest phones to tablets.
const List<Size> standardTestSizes = [
  Size(320, 568), // iPhone SE (smallest supported)
  Size(375, 667), // iPhone 8
  Size(390, 844), // iPhone 13
  Size(600, 960), // Small tablet
  Size(800, 1280), // Medium tablet
];

/// Helper function to determine if Contact section should be visible based on screen size.
/// The Contact section (Report Bug, Request Feature) only appears on larger screens
/// to provide a better user experience on smaller devices.
///
/// Returns true if screen width is >= 390px (iPhone 13 size and larger).
bool shouldShowContactSection(Size screenSize) {
  // Based on test results: Contact section appears on screens >= 390 width
  return screenSize.width >= 390;
}

// --------------------------------------------------------------------------
// Mock Controller for UI Tests
// --------------------------------------------------------------------------

/// Mock implementation of AboutController for testing purposes.
/// Allows simulation of different controller states (loading, error, success)
/// without requiring actual package info retrieval or network calls.
class MockUIAboutController extends AboutController {
  final PackageInfo? _packageInfoData;
  final bool isLoading;
  final bool hasError;

  /// Creates a mock controller with specified state and optional package info.
  ///
  /// [packageInfoData] - Custom package info to return in success state
  /// [isLoading] - Whether to simulate loading state
  /// [hasError] - Whether to simulate error state
  MockUIAboutController({
    PackageInfo? packageInfoData,
    this.isLoading = false,
    this.hasError = false,
  }) : _packageInfoData = packageInfoData {
    // Create default package info for testing if none provided
    final defaultPackageInfo = PackageInfo(
      appName: 'SpiceEase MockApp',
      packageName: 'com.example.spiceease.mock',
      version: '1.0.0-mock',
      buildNumber: '1-mock',
      buildSignature: 'mock_signature',
    );

    // Set the appropriate AsyncValue state based on constructor parameters
    if (isLoading) {
      state = const AsyncValue.loading();
    } else if (hasError) {
      state = const AsyncValue.error(
          "Mock error loading package info", StackTrace.empty);
    } else {
      state = AsyncValue.data(_packageInfoData ?? defaultPackageInfo);
    }
  }

  /// Builds the PackageInfo object based on the current state.
  /// Returns a Future that completes with the package info data.
  /// If [isLoading] is true, returns a never-completing Future to simulate loading.
  /// If [hasError] is true, throws an exception to simulate error state.
  Future<PackageInfo> build() async {
    if (isLoading) {
      return Completer<PackageInfo>()
          .future; // Never completes (simulates loading)
    }
    if (hasError) {
      throw Exception("Mock error loading package info");
    }
    return state.value ??
        _packageInfoData ??
        PackageInfo(
          appName: 'Default Fallback Build',
          packageName: 'com.example.fallback.build',
          version: '0.0.1-build',
          buildNumber: '0-build',
          buildSignature: 'fallback_sig_build',
        );
  }
}

// --------------------------------------------------------------------------
// Helper method to pump the screen for testing
// --------------------------------------------------------------------------

/// Helper function to set up and render the AboutScreen for testing.
/// Handles provider overrides, screen size configuration, and localization setup.
///
/// Returns the AppLocalizations instance for accessing translated strings in tests.
Future<AppLocalizations> pumpAboutScreen(
  WidgetTester tester, {
  PackageInfo? packageInfo,
  bool isLoading = false,
  bool hasError = false,
  Size? screenSize,
  String localeCode = 'en', // Defaulting to English
}) async {
  // Create mock controller with specified state
  final controller = MockUIAboutController(
    packageInfoData: packageInfo,
    isLoading: isLoading,
    hasError: hasError,
  );

  // Configure screen size if specified (for responsive testing)
  if (screenSize != null) {
    await tester.binding.setSurfaceSize(screenSize);
    tester.view.physicalSize = screenSize;
    tester.view.devicePixelRatio = 1.0;
  }

  // Pump the widget with provider override and localization
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // Override the real controller with our mock
        aboutControllerProvider.overrideWith((ref) => controller),
      ],
      child: MaterialApp(
        locale: Locale(localeCode),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AboutScreen(),
      ),
    ),
  );

  // Handle different pump strategies based on state
  if (isLoading) {
    await tester.pump(); // Single pump for loading state
  } else {
    await tester.pumpAndSettle(); // Wait for all animations to complete
  }

  // Return localization instance for use in tests
  return AppLocalizations.of(tester.element(find.byType(AboutScreen)))!;
}

void main() {
  // Group all AboutScreen tests together for organization
  group('AboutScreen UI Tests', () {
    /// Verifies that the AppBar displays with the correct translated title.
    /// This is a basic smoke test to ensure the screen renders properly.
    testWidgets('Displays AppBar with correct title',
        (WidgetTester tester) async {
      // Arrange & Act: Pump the screen with default settings
      final l10n = await pumpAboutScreen(tester);

      // Assert: AppBar should contain the translated "About" title
      expect(find.widgetWithText(AppBar, l10n.about), findsOneWidget);
    });

    /// Verifies that a loading indicator is shown when package info is being loaded.
    /// Also ensures that version/build info is not displayed during loading.
    testWidgets('Displays loading indicator when package info is loading',
        (WidgetTester tester) async {
      // Arrange & Act: Pump screen in loading state
      final l10n = await pumpAboutScreen(tester, isLoading: true);

      // Assert: Should show loading indicator and hide version info
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.textContaining(l10n.version), findsNothing);
      expect(find.textContaining(l10n.buildNumber), findsNothing);
    });

    /// Verifies that an error message is displayed when package info fails to load.
    /// Also ensures loading indicator and version info are not shown in error state.
    testWidgets('Displays error message when package info fails to load',
        (WidgetTester tester) async {
      // Arrange & Act: Pump screen in error state
      final l10n = await pumpAboutScreen(tester, hasError: true);

      // Assert: Should show error message and hide other elements
      expect(find.text(l10n.unableToLoadVersionInfo), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining(l10n.version), findsNothing);
      expect(find.textContaining(l10n.buildNumber), findsNothing);
    });

    // Group tests that require successfully loaded data
    group('When data is loaded successfully', () {
      // Create specific mock package info for consistent testing
      final specificMockPackageInfo = PackageInfo(
        appName: 'TestApp Success',
        packageName: 'com.test.app.success',
        version: '2.3.4-success',
        buildNumber: '987-success',
        buildSignature: 'success_sig',
      );

      /// Helper function to verify that a specific tile exists with the given text.
      /// Checks both that the text exists and that it's contained within a SettingsOptionTile.
      void expectTileWithText(AppLocalizations l10n, String tileTextKey) {
        final textFinder = find.text(tileTextKey, findRichText: true);
        expect(textFinder, findsOneWidget,
            reason: "Direct text finder for '$tileTextKey' failed.");
        final tileFinder = find.ancestor(
          of: textFinder,
          matching: find.byType(SettingsOptionTile),
        );
        expect(tileFinder, findsOneWidget,
            reason:
                "Could not find SettingsOptionTile ancestor for '$tileTextKey'.");
      }

      /// Verifies that all basic app information is displayed correctly.
      /// Tests app logo, name, version, and build number formatting.
      testWidgets('Displays app logo, name, version, and build number',
          (WidgetTester tester) async {
        // Arrange & Act: Pump screen with specific package info
        final l10n =
            await pumpAboutScreen(tester, packageInfo: specificMockPackageInfo);

        // Assert: All app info elements should be present
        expect(find.byType(ImageIcon), findsOneWidget);
        expect(find.text('SpiceEase'), findsOneWidget);
        expect(find.text('${l10n.version}: ${specificMockPackageInfo.version}'),
            findsOneWidget);
        expect(
            find.text(
                '${l10n.buildNumber}: ${specificMockPackageInfo.buildNumber}'),
            findsOneWidget);

        // Assert: Loading and error states should not be present
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text(l10n.unableToLoadVersionInfo), findsNothing);
      });

      /// Verifies that all SettingsOptionTiles are displayed correctly on large screens.
      /// Tests both App Info section (always present) and Contact section (large screens only).
      testWidgets(
          'Displays all SettingsOptionTiles correctly on default screen',
          (WidgetTester tester) async {
        // Arrange: Use a large screen where Contact section should be visible
        const screenSize =
            Size(390, 844); // Large enough for Contact section

        // Act: Pump screen with large screen size
        final l10n = await pumpAboutScreen(tester,
            packageInfo: specificMockPackageInfo, screenSize: screenSize);

        // Assert: Test the App Info section tiles (always present)
        expectTileWithText(l10n, l10n.developer);
        expectTileWithText(l10n, l10n.sourceCode);
        expectTileWithText(l10n, l10n.licenses);

        // Assert: Test Contact section tiles (should be present on large screens)
        expectTileWithText(l10n, l10n.reportBug);
        expectTileWithText(l10n, l10n.requestFeature);

        // Assert: Verify total tile count for large screens
        expect(find.byType(SettingsOptionTile), findsExactly(5));
      });

      /// Verifies that only App Info tiles are shown on small screens.
      /// Contact section should be hidden to improve UX on smaller devices.
      testWidgets('Displays only App Info tiles on small screens',
          (WidgetTester tester) async {
        // Arrange: Use a small screen where Contact section should be hidden
        const screenSize = Size(320, 568); // Small screen

        // Act: Pump screen with small screen size
        final l10n = await pumpAboutScreen(tester,
            packageInfo: specificMockPackageInfo, screenSize: screenSize);

        // Assert: Test the App Info section tiles (always present)
        expectTileWithText(l10n, l10n.developer);
        expectTileWithText(l10n, l10n.sourceCode);
        expectTileWithText(l10n, l10n.licenses);

        // Assert: Contact section tiles should NOT be present on small screens
        expect(find.text(l10n.reportBug), findsNothing);
        expect(find.text(l10n.requestFeature), findsNothing);

        // Assert: Verify total tile count for small screens
        expect(find.byType(SettingsOptionTile), findsExactly(3));
      });

      /// Verifies that SettingsOptionTiles display the correct icons.
      /// Tests that each tile contains its expected Material icon.
      testWidgets('SettingsOptionTiles have correct icons',
          (WidgetTester tester) async {
        // Arrange & Act: Pump screen with package info
        final l10n =
            await pumpAboutScreen(tester, packageInfo: specificMockPackageInfo);

        /// Helper function to find a specific icon within a tile containing given text.
        Finder findIconInTile(String tileText, IconData iconData) {
          final textFinder = find.text(tileText, findRichText: true);
          expect(textFinder, findsOneWidget,
              reason: "Text '$tileText' not found for icon check.");
          final tileFinder = find.ancestor(
              of: textFinder, matching: find.byType(SettingsOptionTile));
          expect(tileFinder, findsOneWidget,
              reason: "Tile not found for text '$tileText' for icon check.");
          return find.descendant(
            of: tileFinder,
            matching: find.byIcon(iconData),
          );
        }

        // Assert: Test icons for the 3 App Info section tiles (always present)
        expect(findIconInTile(l10n.developer, Icons.person_outline),
            findsOneWidget);
        expect(findIconInTile(l10n.sourceCode, Icons.code_outlined),
            findsOneWidget);
        expect(findIconInTile(l10n.licenses, Icons.description_outlined),
            findsOneWidget);
      });
    });

    // Group tests that verify responsive behavior across different screen sizes
    group('Responsiveness Tests', () {
      // Create package info specifically for responsive testing
      final responsiveMockPackageInfo = PackageInfo(
        appName: 'ResponsiveApp',
        packageName: 'com.responsive.app',
        version: 'R1.0-responsive',
        buildNumber: 'R1-responsive',
        buildSignature: 'responsive_sig',
      );

      /// Helper function for responsive tile verification.
      /// Similar to expectTileWithText but with responsive-specific error messages.
      void expectTileWithTextResponsive(
          AppLocalizations l10n, String tileTextKey) {
        final textFinder = find.text(tileTextKey, findRichText: true);
        expect(textFinder, findsOneWidget,
            reason:
                "Responsive: Direct text finder for '$tileTextKey' failed.");
        final tileFinder = find.ancestor(
          of: textFinder,
          matching: find.byType(SettingsOptionTile),
        );
        expect(tileFinder, findsOneWidget,
            reason:
                "Responsive: Could not find SettingsOptionTile ancestor for '$tileTextKey'.");
      }

      // Generate tests for each standard screen size
      for (final size in standardTestSizes) {
        /// Verifies that loading state renders correctly across all screen sizes.
        testWidgets(
            'Renders correctly on ${size.width}x${size.height} screen (Loading)',
            (WidgetTester tester) async {
          // Arrange & Act: Pump loading state with specific screen size
          await pumpAboutScreen(tester, isLoading: true, screenSize: size);

          // Assert: Loading indicator should be present regardless of screen size
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
        });

        /// Verifies that error state renders correctly across all screen sizes.
        testWidgets(
            'Renders correctly on ${size.width}x${size.height} screen (Error)',
            (WidgetTester tester) async {
          // Arrange & Act: Pump error state with specific screen size
          final l10n =
              await pumpAboutScreen(tester, hasError: true, screenSize: size);

          // Assert: Error message should be present regardless of screen size
          expect(find.text(l10n.unableToLoadVersionInfo), findsOneWidget);
        });

        /// Verifies that data-loaded state renders correctly with proper responsive behavior.
        /// Tests adaptive tile count based on screen size.
        testWidgets(
            'Renders correctly on ${size.width}x${size.height} screen (Data Loaded)',
            (WidgetTester tester) async {
          // Arrange & Act: Pump screen with data and specific screen size
          final l10n = await pumpAboutScreen(tester,
              packageInfo: responsiveMockPackageInfo, screenSize: size);

          // Assert: Basic app info should always be present
          expect(find.text('SpiceEase'), findsOneWidget);
          expect(find.textContaining(responsiveMockPackageInfo.version),
              findsOneWidget);

          // Assert: App Info section tiles should always be present
          expectTileWithTextResponsive(l10n, l10n.developer);
          expectTileWithTextResponsive(l10n, l10n.sourceCode);
          expectTileWithTextResponsive(l10n, l10n.licenses);

          // Assert: Determine expected tile count based on screen size
          final expectedTileCount = shouldShowContactSection(size) ? 5 : 3;
          expect(
              find.byType(SettingsOptionTile), findsExactly(expectedTileCount),
              reason:
                  "Responsive: Expected $expectedTileCount SettingsOptionTiles for ${size.width}x${size.height}");

          // Assert: Test Contact section tiles only on larger screens
          if (shouldShowContactSection(size)) {
            expectTileWithTextResponsive(l10n, l10n.reportBug);
            expectTileWithTextResponsive(l10n, l10n.requestFeature);
          } else {
            expect(find.text(l10n.reportBug), findsNothing);
            expect(find.text(l10n.requestFeature), findsNothing);
          }

          // Assert: No exceptions should occur during rendering
          final exception = tester.takeException();
          expect(exception, isNull);
        });
      }
    });
  });
}
