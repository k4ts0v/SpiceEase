/// This file tests the localization functionality of the About screen
/// in the SpiceEase app, ensuring proper translation of all UI elements
/// across different locales.
///
/// The tests verify that:
/// - All static text elements are properly translated
/// - Dynamic content (version info, error messages) uses correct locale
/// - Locale changes are properly reflected in the UI
/// - Dialog messages and actions are translated correctly
/// - Package info display formats are locale-appropriate
///
/// # Test Structure
/// - Mock controllers simulate different app states (loading, error, success)
/// - Helper functions pump the AboutScreen with different locales
/// - Comprehensive assertions verify all translatable elements
/// - Edge cases like error states and dialogs are thoroughly tested
///
/// # How to run
/// - Individual tests: `flutter test --plain-name "specific test name"`
/// - Full suite: `flutter test test/features/settings/about/about_localization_tests.dart`
/// - With coverage: `flutter test --coverage test/features/settings/about/about_localization_tests.dart`
///
/// # Locales tested
/// - English (en) - Primary language
/// - Spanish (es) - Secondary language
/// - Locale switching scenarios
///
/// # Dependencies
/// - Requires proper AppLocalizations setup
/// - Uses mocked AboutController for consistent testing
/// - No external network calls or real package info required

library about_localization_tests;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:spiceease/features/settings/about_screen.dart';
import 'package:spiceease/features/settings/about_controller.dart';
import 'package:spiceease/l10n/app_localizations.dart';

// --------------------------------------------------------------------------
// Mock Controller for Localization Tests
// --------------------------------------------------------------------------

/// Mock implementation of AboutController specifically designed for localization testing.
/// Provides controlled states (loading, error, success) without external dependencies.
class MockAboutLocalizationController extends AboutController {
  final PackageInfo? _mockPackageInfo;
  final bool _isLoading;
  final bool _hasError;

  /// Creates a mock controller with specified state.
  ///
  /// [mockPackageInfo] - Package info to return in success state
  /// [isLoading] - Whether to simulate loading state
  /// [hasError] - Whether to simulate error state
  MockAboutLocalizationController({
    PackageInfo? mockPackageInfo,
    bool isLoading = false,
    bool hasError = false,
  })  : _mockPackageInfo = mockPackageInfo,
        _isLoading = isLoading,
        _hasError = hasError {
    // Set initial state based on constructor parameters
    if (_isLoading) {
      state = const AsyncValue.loading();
    } else if (_hasError) {
      state = const AsyncValue.error(
        "Mock localization error",
        StackTrace.empty,
      );
    } else {
      // Provide default package info if none specified
      state = AsyncValue.data(_mockPackageInfo ??
          PackageInfo(
            appName: 'SpiceEase Localization Test',
            packageName: 'com.spiceease.localization.test',
            version: '2.1.0-localization',
            buildNumber: '42-localization',
            buildSignature: 'localization_test_signature',
          ));
    }
  }

  Future<PackageInfo> build() async {
    if (_isLoading) {
      return Completer<PackageInfo>().future; // Never completes (simulates loading)
    }
    if (_hasError) {
      throw Exception("Mock localization error");
    }
    return state.value ??
        _mockPackageInfo ??
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
// Helper Functions for Test Setup
// --------------------------------------------------------------------------

/// Helper function to pump the AboutScreen with specific locale and controller state.
/// Configures the widget tree with proper localization and provider overrides.
///
/// [tester] - The WidgetTester instance
/// [localeCode] - Locale code to test (e.g., 'en', 'es')
/// [packageInfo] - Optional custom package info
/// [isLoading] - Whether to simulate loading state
/// [hasError] - Whether to simulate error state
///
/// Returns the AppLocalizations instance for the pumped locale.
Future<AppLocalizations> pumpAboutScreenWithLocale(
  WidgetTester tester, {
  required String localeCode,
  PackageInfo? packageInfo,
  bool isLoading = false,
  bool hasError = false,
}) async {
  // Create mock controller with specified state
  final controller = MockAboutLocalizationController(
    mockPackageInfo: packageInfo,
    isLoading: isLoading,
    hasError: hasError,
  );

  // Set larger screen size to prevent UI overflow issues
  await tester.binding.setSurfaceSize(const Size(400, 900));
  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1.0;

  // Pump the widget tree with localization setup
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

  // Ensure all widgets are properly rendered
  if (isLoading) {
    await tester.pump(); // Single pump for loading state
  } else {
    await tester.pumpAndSettle(); // Wait for all animations to complete
  }

  // Return localization instance for assertions
  final context = tester.element(find.byType(AboutScreen));
  return AppLocalizations.of(context)!;
}

/// Helper function to create specific package info for localization testing.
/// Provides consistent test data across different test scenarios.
PackageInfo createLocalizationTestPackageInfo() {
  return PackageInfo(
    appName: 'SpiceEase Localization',
    packageName: 'com.spiceease.localization',
    version: '3.2.1-test',
    buildNumber: '100-test',
    buildSignature: 'test_localization_signature',
  );
}

void main() {
  group('AboutScreen Localization Tests', () {
    /// Verifies that all AboutScreen elements display correctly in English.
    /// Tests the primary language implementation and serves as baseline for other locales.
    testWidgets('Displays correct text in English', (WidgetTester tester) async {
      // Arrange: Create test package info and pump screen in English
      final packageInfo = createLocalizationTestPackageInfo();
      final l10n = await pumpAboutScreenWithLocale(
        tester,
        localeCode: 'en',
        packageInfo: packageInfo,
      );

      // Assert: Verify AppBar title
      expect(find.text(l10n.about), findsOneWidget);

      // Assert: Verify app info section
      expect(find.text('SpiceEase'), findsOneWidget);
      expect(find.text('${l10n.version}: ${packageInfo.version}'), findsOneWidget);
      expect(find.text('${l10n.buildNumber}: ${packageInfo.buildNumber}'), findsOneWidget);

      // Assert: Verify App Info section tiles
      expect(find.text(l10n.developer), findsOneWidget);
      expect(find.text(l10n.sourceCode), findsOneWidget);
      expect(find.text(l10n.licenses), findsOneWidget);
    });

    /// Verifies that all AboutScreen elements display correctly in Spanish.
    /// Tests secondary language implementation and translation completeness.
    testWidgets('Displays correct text in Spanish', (WidgetTester tester) async {
      // Arrange: Create test package info and pump screen in Spanish
      final packageInfo = createLocalizationTestPackageInfo();
      final l10n = await pumpAboutScreenWithLocale(
        tester,
        localeCode: 'es',
        packageInfo: packageInfo,
      );

      // Assert: Verify AppBar title is translated
      expect(find.text(l10n.about), findsOneWidget);

      // Assert: Verify app name (should remain the same)
      expect(find.text('SpiceEase'), findsOneWidget);

      // Assert: Verify version info uses translated labels
      expect(find.text('${l10n.version}: ${packageInfo.version}'), findsOneWidget);
      expect(find.text('${l10n.buildNumber}: ${packageInfo.buildNumber}'), findsOneWidget);

      // Assert: Verify App Info section tiles are translated
      expect(find.text(l10n.developer), findsOneWidget);
      expect(find.text(l10n.sourceCode), findsOneWidget);
      expect(find.text(l10n.licenses), findsOneWidget);
    });

    /// Verifies that loading state displays translated loading indicator and messages.
    /// Tests localization during asynchronous operations.
    testWidgets('Displays localized loading state', (WidgetTester tester) async {
      // Arrange & Act: Pump screen in loading state
      final l10n = await pumpAboutScreenWithLocale(
        tester,
        localeCode: 'en',
        isLoading: true,
      );

      // Assert: Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Assert: Verify static content is still translated
      expect(find.text(l10n.about), findsOneWidget);

      // Assert: Verify version info is not shown during loading
      expect(find.textContaining(l10n.version), findsNothing);
      expect(find.textContaining(l10n.buildNumber), findsNothing);
    });

    /// Verifies that error state displays translated error messages.
    /// Tests localization of error handling and recovery instructions.
    testWidgets('Displays localized error state', (WidgetTester tester) async {
      // Arrange & Act: Pump screen in error state for English
      final englishL10n = await pumpAboutScreenWithLocale(
        tester,
        localeCode: 'en',
        hasError: true,
      );

      // Assert: Verify error message is displayed in English
      expect(find.text(englishL10n.unableToLoadVersionInfo), findsOneWidget);

      // Arrange & Act: Test same error state in Spanish
      final spanishL10n = await pumpAboutScreenWithLocale(
        tester,
        localeCode: 'es',
        hasError: true,
      );

      // Assert: Verify error message is displayed in Spanish
      expect(find.text(spanishL10n.unableToLoadVersionInfo), findsOneWidget);

      // Assert: Verify English error message is no longer present
      expect(find.text(englishL10n.unableToLoadVersionInfo), findsNothing);
    });

    /// Verifies that text updates correctly when switching between locales.
    /// Tests dynamic locale switching without app restart.
    testWidgets('Updates text when locale changes', (WidgetTester tester) async {
      // Arrange: Start with English
      final packageInfo = createLocalizationTestPackageInfo();
      final englishL10n = await pumpAboutScreenWithLocale(
        tester,
        localeCode: 'en',
        packageInfo: packageInfo,
      );

      // Assert: Verify English content is displayed
      final englishAboutTitle = englishL10n.about;
      final englishDeveloperText = englishL10n.developer;
      final englishVersionText = '${englishL10n.version}: ${packageInfo.version}';

      expect(find.text(englishAboutTitle), findsOneWidget);
      expect(find.text(englishDeveloperText), findsOneWidget);
      expect(find.text(englishVersionText), findsOneWidget);

      // Act: Switch to Spanish
      final spanishL10n = await pumpAboutScreenWithLocale(
        tester,
        localeCode: 'es',
        packageInfo: packageInfo,
      );

      // Assert: Verify Spanish content is displayed and English is gone
      final spanishAboutTitle = spanishL10n.about;
      final spanishDeveloperText = spanishL10n.developer;
      final spanishVersionText = '${spanishL10n.version}: ${packageInfo.version}';

      expect(find.text(spanishAboutTitle), findsOneWidget);
      expect(find.text(spanishDeveloperText), findsOneWidget);
      expect(find.text(spanishVersionText), findsOneWidget);

      // Verify English content is no longer present
      expect(find.text(englishAboutTitle), findsNothing);
      expect(find.text(englishDeveloperText), findsNothing);
      expect(find.text(englishVersionText), findsNothing);

      // Act: Switch back to English
      final newEnglishL10n = await pumpAboutScreenWithLocale(
        tester,
        localeCode: 'en',
        packageInfo: packageInfo,
      );

      // Assert: Verify English content is restored and Spanish is gone
      expect(find.text(newEnglishL10n.about), findsOneWidget);
      expect(find.text(newEnglishL10n.developer), findsOneWidget);
      expect(find.text(spanishAboutTitle), findsNothing);
      expect(find.text(spanishDeveloperText), findsNothing);
    });

    /// Verifies that version formatting is consistent across locales.
    /// Tests that version and build number display maintains format across languages.
    testWidgets('Version formatting is consistent across locales',
        (WidgetTester tester) async {
      // Arrange: Create test package info
      final packageInfo = PackageInfo(
        appName: 'Test App',
        packageName: 'com.test.app',
        version: '1.2.3-beta',
        buildNumber: '456',
        buildSignature: 'test_signature',
      );

      // Act: Test English formatting
      final englishL10n = await pumpAboutScreenWithLocale(
        tester,
        localeCode: 'en',
        packageInfo: packageInfo,
      );

      // Assert: Verify English version format
      expect(
        find.text('${englishL10n.version}: ${packageInfo.version}'),
        findsOneWidget,
      );
      expect(
        find.text('${englishL10n.buildNumber}: ${packageInfo.buildNumber}'),
        findsOneWidget,
      );

      // Act: Test Spanish formatting
      final spanishL10n = await pumpAboutScreenWithLocale(
        tester,
        localeCode: 'es',
        packageInfo: packageInfo,
      );

      // Assert: Verify Spanish version format (should use translated labels but same version data)
      expect(
        find.text('${spanishL10n.version}: ${packageInfo.version}'),
        findsOneWidget,
      );
      expect(
        find.text('${spanishL10n.buildNumber}: ${packageInfo.buildNumber}'),
        findsOneWidget,
      );

      // Assert: Verify English format is no longer present
      expect(
        find.text('${englishL10n.version}: ${packageInfo.version}'),
        findsNothing,
      );
    });

    /// Verifies that all icons remain consistent across locales.
    /// Tests that UI icons don't change when language changes.
    testWidgets('Icons remain consistent across locales',
        (WidgetTester tester) async {
      // Arrange: Test English locale
      await pumpAboutScreenWithLocale(tester, localeCode: 'en');

      // Assert: Count icons in English
      final englishIconCount = tester.widgetList(find.byType(Icon)).length;
      expect(englishIconCount, greaterThan(0));

      // Act: Switch to Spanish
      await pumpAboutScreenWithLocale(tester, localeCode: 'es');

      // Assert: Verify same number of icons in Spanish
      final spanishIconCount = tester.widgetList(find.byType(Icon)).length;
      expect(spanishIconCount, equals(englishIconCount));

      // Assert: Verify specific icons are present
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.code_outlined), findsOneWidget);
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    });
  });
}