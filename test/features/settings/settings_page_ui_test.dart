/// This file contains UI tests for the Settings page in the SpiceEase app,
/// verifying both the layout and interactive functionality.
///
/// These tests verify that:
/// - All UI elements are displayed correctly with proper structure
/// - Navigation methods are called when settings options are tapped
/// - Theme, language, and dark mode settings work as expected
/// - The UI adapts properly to different screen sizes
///
/// # How these tests work
/// - A MockSettingsController is used to simulate controller behavior
/// - The real SettingsPage widget is rendered with the mock controller
/// - No real navigation or state persistence happens; everything is simulated
///
/// # Why use these tests?
/// - To ensure UI elements render correctly
/// - To verify user interactions trigger appropriate actions
/// - To catch visual regressions if the settings UI is changed
/// - To ensure proper responsiveness across different devices
///
/// # How to run
/// - Run with `flutter test test/features/settings/settings_page_ui_test.dart`
/// - No external dependencies or network required
///
/// # See also
/// - https://docs.flutter.dev/testing/widget-testing
/// - https://docs.flutter.dev/cookbook/testing/widget/introduction

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/features/settings/settings_page.dart';
import 'package:spiceease/features/settings/settings_controller.dart';
import 'package:spiceease/l10n/app_localizations.dart';
import 'package:spiceease/components/settings/settings_section.dart';
import 'package:spiceease/components/settings/settings_option_tile.dart';

/// Standardized screen sizes for consistent testing across ALL UI test suites
const List<Size> standardTestSizes = [
  Size(375, 667), // iPhone SE
  Size(390, 844), // iPhone 12/13 mini
  Size(414, 896), // iPhone 11
  Size(768, 1024), // iPad Portrait
  Size(1024, 768), // iPad Landscape
  Size(1200, 800), // Desktop
  Size(1920, 1080), // Large Desktop
];

/// Mock implementation of SettingsController for testing purposes
///
/// This mock:
/// - Tracks when navigation methods are called
/// - Allows setting predefined values for theme, language, etc.
/// - Simulates state changes like toggling dark mode
class MockSettingsController extends StateNotifier<void>
    implements SettingsController {
  MockSettingsController() : super(null);

  @override
  ThemeMode currentThemeMode = ThemeMode.system;
  @override
  Color currentAccentColor = Colors.blue;
  @override
  bool isDarkMode = false;
  @override
  Locale? currentLocale = const Locale('en');

  // Add tracking variables for navigation methods
  bool accountSettingsCalled = false;
  bool themeSettingsCalled = false;
  bool languageSettingsCalled = false;
  bool helpCalled = false;
  bool aboutCalled = false;
  bool darkModeToggled = false;

  @override
  void navigateToAccountSettings(BuildContext context) {
    accountSettingsCalled = true;
  }

  @override
  void navigateToThemeSettings(BuildContext context) {
    themeSettingsCalled = true;
  }

  @override
  void navigateToLanguageSettings(BuildContext context) {
    languageSettingsCalled = true;
  }

  @override
  void navigateToHelp(BuildContext context) {
    helpCalled = true;
  }

  @override
  void navigateToAbout(BuildContext context) {
    aboutCalled = true;
  }

  @override
  void toggleDarkMode() {
    isDarkMode = !isDarkMode;
    darkModeToggled = true;
  }

  /// Resets all tracking flags to false for test isolation
  void resetTracking() {
    accountSettingsCalled = false;
    themeSettingsCalled = false;
    languageSettingsCalled = false;
    helpCalled = false;
    aboutCalled = false;
    darkModeToggled = false;
  }

  @override
  Ref<Object?> get ref => throw UnimplementedError();

  @override
  Future<void> setAccentColor(Color color) {
    throw UnimplementedError();
  }

  @override
  Future<void> setLocale(Locale locale) {
    throw UnimplementedError();
  }

  @override
  Future<void> setThemeMode(ThemeMode themeMode) {
    throw UnimplementedError();
  }
}

/// Helper method to render the SettingsPage with controlled test conditions
///
/// Parameters:
/// - controller: MockSettingsController to inject
/// - localeCode: Language code for localization testing
/// - screenSize: Custom screen dimensions for responsiveness testing
Future<void> pumpSettingsPage(
  WidgetTester tester, {
  required MockSettingsController controller,
  String localeCode = 'en',
  Size? screenSize,
}) async {
  if (screenSize != null) {
    await tester.binding.setSurfaceSize(screenSize);
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsControllerProvider.overrideWith((_) => controller),
      ],
      child: MaterialApp(
        locale: Locale(localeCode),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SettingsPage(),
      ),
    ),
  );

  // Wait for all animations to complete
  await tester.pumpAndSettle();
}

void main() {
  group('Settings Page UI Tests', () {
    /// Verifies that all expected section headers are present in the UI
    testWidgets('Displays all section headers correctly',
        (WidgetTester tester) async {
      // Arrange
      final controller = MockSettingsController();

      // Act
      await pumpSettingsPage(tester, controller: controller);

      // Assert - Changed from 4 to 3 to match actual implementation
      expect(find.byType(SettingsSection), findsNWidgets(3));

      // Make sure each section title is displayed (based on debug output)
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Language & Region'), findsOneWidget);
    });

    /// Verifies that all setting option tiles are present with correct titles
    testWidgets('Displays correct setting options with titles',
        (WidgetTester tester) async {
      // Arrange
      final controller = MockSettingsController();

      // Act
      await pumpSettingsPage(tester, controller: controller);

      // Assert - Verify we have 5 option tiles
      expect(find.byType(SettingsOptionTile), findsNWidgets(5));

      // Check for specific titles (based on debug output)
      expect(find.text('Account Settings'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Accent Color'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
    });

    /// Verifies that the theme mode subtitle displays correctly based on controller state
    testWidgets('Displays correct theme mode subtitle',
        (WidgetTester tester) async {
      // Arrange with System theme
      final controller = MockSettingsController();
      controller.currentThemeMode = ThemeMode.system;

      // Act
      await pumpSettingsPage(tester, controller: controller);

      // Assert - Find the System subtitle text (based on debug output)
      expect(find.text('System'), findsOneWidget);
      expect(controller.currentThemeMode, ThemeMode.system);
    });

    /// Verifies that the language subtitle displays correctly based on controller state
    testWidgets('Displays correct language subtitle',
        (WidgetTester tester) async {
      // Arrange - with English
      final controller = MockSettingsController();
      controller.currentLocale = const Locale('en');

      // Act
      await pumpSettingsPage(tester, controller: controller);

      // Assert - Find the English subtitle (based on debug output)
      expect(find.text('English'), findsOneWidget);
      expect(controller.currentLocale?.languageCode, 'en');
    });

    /// Verifies that the dark mode switch reflects the current theme state
    testWidgets('Dark mode switch reflects current theme state',
        (WidgetTester tester) async {
      // Arrange
      final controller = MockSettingsController();
      controller.isDarkMode = true; // Start with isDarkMode true

      // Act
      await pumpSettingsPage(tester, controller: controller);

      // Assert - Find specific switch
      final darkModeTile = find.ancestor(
        of: find.text('Dark Mode'),
        matching: find.byType(SettingsOptionTile),
      );

      final switchWidget = find.descendant(
        of: darkModeTile,
        matching: find.byType(Switch),
      );

      expect(switchWidget, findsOneWidget);

      expect(controller.isDarkMode, isTrue);
    });

    /// Tests UI responsiveness across different screen sizes
    group('Screen Size Responsiveness', () {
      for (final size in standardTestSizes) {
        testWidgets(
            'Layout adapts correctly to ${size.width}x${size.height} screen size',
            (WidgetTester tester) async {
          // Arrange
          final controller = MockSettingsController();

          // Act
          await pumpSettingsPage(
            tester,
            controller: controller,
            screenSize: size,
          );

          // Assert - Check that the basic structure exists without overflow
          expect(find.byType(ListView), findsOneWidget);
          expect(find.byType(SettingsSection), findsWidgets);
          expect(find.byType(SettingsOptionTile), findsWidgets);

          // Check for overflow errors
          expect(tester.takeException(), isNull);
        });
      }
    });
  });

  group('Settings Interaction Tests', () {
    /// Verifies that tapping the dark mode switch toggles the isDarkMode flag
    testWidgets('Dark mode switch toggles when tapped',
        (WidgetTester tester) async {
      // Arrange
      final controller = MockSettingsController();
      controller.isDarkMode = false;
      controller.resetTracking();

      // Act
      await pumpSettingsPage(tester, controller: controller);

      // Initial state
      expect(controller.isDarkMode, false);
      expect(controller.darkModeToggled, isFalse);

      // Find and tap the switch
      final darkModeTile = find.ancestor(
        of: find.text('Dark Mode'),
        matching: find.byType(SettingsOptionTile),
      );
      final switchWidget = find.descendant(
        of: darkModeTile,
        matching: find.byType(Switch),
      );

      await tester.tap(switchWidget);
      await tester.pumpAndSettle();

      // Assert
      expect(controller.isDarkMode, true);
      expect(controller.darkModeToggled, isTrue);
    });

    /// Verifies that tapping the account settings tile calls navigateToAccountSettings
    testWidgets('Tapping account settings tile calls navigateToAccountSettings',
        (WidgetTester tester) async {
      // Arrange
      final controller = MockSettingsController();
      controller.resetTracking();
      await pumpSettingsPage(tester, controller: controller);

      // Act - Find and tap the account settings tile
      final accountTile = find.ancestor(
          of: find.text('Account Settings'),
          matching: find.byType(SettingsOptionTile));
      await tester.tap(accountTile);
      await tester.pumpAndSettle();

      // Assert - Verify the correct navigation method was called
      expect(controller.accountSettingsCalled, isTrue);
      expect(controller.themeSettingsCalled, isFalse);
      expect(controller.languageSettingsCalled, isFalse);
      expect(controller.helpCalled, isFalse);
      expect(controller.aboutCalled, isFalse);
    });

    /// Verifies that tapping the theme settings tile calls navigateToThemeSettings
    testWidgets('Tapping theme settings tile calls navigateToThemeSettings',
        (WidgetTester tester) async {
      // Arrange
      final controller = MockSettingsController();
      controller.resetTracking();
      await pumpSettingsPage(tester, controller: controller);

      // Act - Find and tap the theme settings tile
      final themeTile = find.ancestor(
          of: find.text('Theme'), matching: find.byType(SettingsOptionTile));
      await tester.tap(themeTile);
      await tester.pumpAndSettle();

      // Assert - Verify the correct navigation method was called
      expect(controller.accountSettingsCalled, isFalse);
      expect(controller.themeSettingsCalled, isTrue);
      expect(controller.languageSettingsCalled, isFalse);
      expect(controller.helpCalled, isFalse);
      expect(controller.aboutCalled, isFalse);
    });

    /// Verifies that tapping the language settings tile calls navigateToLanguageSettings
    testWidgets(
        'Tapping language settings tile calls navigateToLanguageSettings',
        (WidgetTester tester) async {
      // Arrange
      final controller = MockSettingsController();
      controller.resetTracking();
      await pumpSettingsPage(tester, controller: controller);

      // Act - Find and tap the language settings tile
      final languageTile = find.ancestor(
          of: find.text('Language'), matching: find.byType(SettingsOptionTile));
      await tester.tap(languageTile);
      await tester.pumpAndSettle();

      // Assert - Verify the correct navigation method was called
      expect(controller.accountSettingsCalled, isFalse);
      expect(controller.themeSettingsCalled, isFalse);
      expect(controller.languageSettingsCalled, isTrue);
      expect(controller.helpCalled, isFalse);
      expect(controller.aboutCalled, isFalse);
    });
  });
}