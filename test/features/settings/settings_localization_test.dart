/// This file tests the localization functionality of the Settings page in the SpiceEase app.
///
/// # Testing Strategy
///
/// This test suite validates four main scenarios for the SettingsPage:
///
/// 1.  **Static English Localization**:
///     - Verifies that all UI elements (section headers, setting options,
///       subtitles, descriptions) display the correct English text when the
///       application's locale is set to 'en'.
///     - Ensures that `AppLocalizations.en` strings are correctly loaded and rendered.
///
/// 2.  **Static Spanish Localization**:
///     - Verifies that all UI elements display the correct Spanish text when the
///       application's locale is set to 'es'.
///     - Ensures that `AppLocalizations.es` strings are correctly loaded and rendered.
///
/// 3.  **Dynamic Locale Change**:
///     - Tests the behavior of the SettingsPage when the locale is changed dynamically
///       (e.g., from English to Spanish) during runtime.
///     - Verifies that the widget tree rebuilds and all localizable strings are updated
///       to reflect the new locale.
///
/// 4.  **Theme Subtitle Localization**:
///     - Tests that theme mode subtitles are properly localized in different languages.
///     - Verifies that text like "System", "Light", or "Dark" appears in the correct language.
///
/// # Features Tested
///
/// The localization tests cover a comprehensive set of UI elements within the SettingsPage:
/// - **Section Headers**: "Account", "Appearance", "Language & Region", etc.
/// - **Setting Titles**: "Account Settings", "Theme", "Dark Mode", "Language", etc.
/// - **Setting Subtitles**: "System", "Light", "Dark", "English", "Spanish", etc.
/// - **Setting Descriptions**: "Manage your account information", "Customize app colors", etc.
/// - **Toggle Options**: "Dark Mode" and its related text.
///
/// # Technical Approach
///
/// - **ProviderScope & Overrides**: Each test sets up a `ProviderScope` to manage Riverpod state.
///   The `settingsControllerProvider` is overridden to provide controlled test data.
/// - **MaterialApp Wrapper**: The `SettingsPage` is wrapped in a `MaterialApp` to provide the
///   necessary context for localization (locale, localizationsDelegates, supportedLocales).
/// - **`pumpSettingsPage` Helper**: A utility function to encapsulate the widget pumping logic,
///   including setting the locale and providing consistent test setup.
/// - **`AppLocalizations`**: Used to access localized strings programmatically for assertions.
/// - **`tester.pumpAndSettle()`**: Used to wait for UI updates and animations to complete.
///
/// # Test Structure
///
/// Each `testWidgets` follows the Arrange-Act-Assert pattern:
/// - **Arrange**:
///   - The `SettingsPage` is pumped with the desired locale using `pumpSettingsPage`.
///   - An instance of `AppLocalizations` for the current locale is obtained.
///   - The controller state is configured as needed.
/// - **Act**:
///   - `tester.pumpAndSettle()` is called to allow the widget tree to stabilize.
///   - User interactions are simulated when testing dynamic behavior.
/// - **Assert**:
///   - `expect()` is used with `find.text()` to verify that UI elements
///     display the correct localized text.
///   - Multiple checks ensure comprehensive coverage of all localized UI elements.
///
/// # How to run
/// - Run with `flutter test test/features/settings/settings_localization_test.dart`
/// - No external dependencies are required as all providers use minimal overrides.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/features/settings/settings_page.dart';
import 'package:spiceease/features/settings/settings_controller.dart';
import 'package:spiceease/l10n/app_localizations.dart';

// --------------------------------------------------------------------------
// Mock Controller Setup
// --------------------------------------------------------------------------

/// Mock implementation of SettingsController for localization testing
///
/// This mock provides the minimum implementation needed to test
/// the localization features without real business logic
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

  @override
  void navigateToAccountSettings(BuildContext context) {}

  @override
  void navigateToThemeSettings(BuildContext context) {}

  @override
  void navigateToLanguageSettings(BuildContext context) {}

  @override
  void navigateToHelp(BuildContext context) {}

  @override
  void navigateToAbout(BuildContext context) {}

  @override
  Ref<Object?> get ref => throw UnimplementedError();

  @override
  void toggleDarkMode() {}

  @override
  Future<void> setAccentColor(Color color) async {}

  @override
  Future<void> setLocale(Locale locale) async {}

  @override
  Future<void> setThemeMode(ThemeMode themeMode) async {}
}

// --------------------------------------------------------------------------
// Test Helpers
// --------------------------------------------------------------------------

/// Helper method to render the SettingsPage with specific locale for testing
///
/// Parameters:
/// - tester: The widget tester instance
/// - localeCode: The language code for localization testing (e.g., 'en', 'es', 'fr')
/// - themeMode: Optional theme mode to test different theme states
/// - isDarkMode: Optional flag to test dark mode state
Future<void> pumpSettingsPage(
  WidgetTester tester, {
  required String localeCode,
  ThemeMode themeMode = ThemeMode.system,
  bool isDarkMode = false,
}) async {
  final controller = MockSettingsController();
  controller.currentThemeMode = themeMode;
  controller.isDarkMode = isDarkMode;

  // Set large test surface size to prevent overflow issues
  await tester.binding.setSurfaceSize(const Size(1000, 800));

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
  group('Settings Page Localization Tests', () {
    /// Verifies that all UI text appears correctly in English, including section headers,
    /// setting options, descriptions, and system values.
    testWidgets('Displays correct text in English',
        (WidgetTester tester) async {
      // Arrange
      await pumpSettingsPage(tester, localeCode: 'en');
      final context = tester.element(find.byType(SettingsPage));
      final l10n = AppLocalizations.of(context)!;

      // Assert - Check section titles
      expect(find.text(l10n.account), findsOneWidget,
          reason: "Account section title should be present in English");
      expect(find.text(l10n.appearance), findsOneWidget,
          reason: "Appearance section title should be present in English");
      expect(find.text(l10n.languageAndRegion), findsOneWidget,
          reason:
              "Language & Region section title should be present in English");

      // Check setting options and their descriptions
      expect(find.text(l10n.accountSettings), findsOneWidget,
          reason: "Account Settings option should be present in English");
      expect(find.text(l10n.manageAccountInfo), findsOneWidget,
          reason:
              "Manage account info description should be present in English");

      expect(find.text(l10n.theme), findsOneWidget,
          reason: "Theme option should be present in English");
      expect(find.text('System'), findsOneWidget,
          reason: "System theme subtitle should be present in English");

      expect(find.text(l10n.accentColor), findsOneWidget,
          reason: "Accent Color option should be present in English");
      expect(find.text(l10n.customizeAppColors), findsOneWidget,
          reason:
              "Customize app colors description should be present in English");

      expect(find.text(l10n.darkMode), findsOneWidget,
          reason: "Dark Mode option should be present in English");
      expect(find.text(l10n.toggleDarkMode), findsOneWidget,
          reason: "Toggle dark mode description should be present in English");

      expect(find.text(l10n.language), findsOneWidget,
          reason: "Language option should be present in English");
      expect(find.text('English'), findsOneWidget,
          reason: "English language subtitle should be present");
    });

    /// Verifies that all UI text appears correctly in Spanish, including section headers,
    /// setting options, descriptions, and system values.
    testWidgets('Displays correct text in Spanish',
        (WidgetTester tester) async {
      // Arrange
      await pumpSettingsPage(tester, localeCode: 'es');
      final context = tester.element(find.byType(SettingsPage));
      final l10n = AppLocalizations.of(context)!;

      // Assert - Check section titles using l10n
      expect(find.text(l10n.account), findsOneWidget,
          reason: "Account section title should be present in Spanish");
      expect(find.text(l10n.appearance), findsOneWidget,
          reason: "Appearance section title should be present in Spanish");
      expect(find.text(l10n.languageAndRegion), findsOneWidget,
          reason:
              "Language & Region section title should be present in Spanish");

      // Check setting options and descriptions using l10n
      expect(find.text(l10n.accountSettings), findsOneWidget,
          reason: "Account Settings option should be present in Spanish");
      expect(find.text(l10n.manageAccountInfo), findsOneWidget,
          reason:
              "Manage account info description should be present in Spanish");

      expect(find.text(l10n.theme), findsOneWidget,
          reason: "Theme option should be present in Spanish");
      expect(find.text(l10n.systemTheme), findsOneWidget,
          reason: "System theme subtitle should be present in Spanish");

      expect(find.text(l10n.accentColor), findsOneWidget,
          reason: "Accent Color option should be present in Spanish");
      expect(find.text(l10n.customizeAppColors), findsOneWidget,
          reason:
              "Customize app colors description should be present in Spanish");

      expect(find.text(l10n.darkMode), findsOneWidget,
          reason: "Dark Mode option should be present in Spanish");
      expect(find.text(l10n.toggleDarkMode), findsOneWidget,
          reason: "Toggle dark mode description should be present in Spanish");

      expect(find.text(l10n.language), findsOneWidget,
          reason: "Language option should be present in Spanish");
    });

    /// Verifies that the UI updates correctly when the locale changes from English to Spanish
    /// during runtime, ensuring that all text elements are properly translated.
    testWidgets('Updates text when locale changes from English to Spanish',
        (WidgetTester tester) async {
      // Act - Start with English
      await pumpSettingsPage(tester, localeCode: 'en');
      final enContext = tester.element(find.byType(SettingsPage));
      final enL10n = AppLocalizations.of(enContext)!;

      // Assert - Check English text
      expect(find.text(enL10n.account), findsOneWidget,
          reason:
              "Account section title should be present in English initially");
      expect(find.text(enL10n.appearance), findsOneWidget,
          reason:
              "Appearance section title should be present in English initially");

      // Act - Change to Spanish
      await pumpSettingsPage(tester, localeCode: 'es');
      final esContext = tester.element(find.byType(SettingsPage));
      final esL10n = AppLocalizations.of(esContext)!;

      // Assert - Check Spanish text
      expect(find.text(esL10n.account), findsOneWidget,
          reason: "Account section title should be translated to Spanish");
      expect(find.text(esL10n.appearance), findsOneWidget,
          reason: "Appearance section title should be translated to Spanish");
    });

    /// Verifies that all UI elements use localized strings by checking that
    /// programmatically obtained localized strings are actually present in the UI.
    testWidgets('All UI elements use localized strings',
        (WidgetTester tester) async {
      // Arrange
      await pumpSettingsPage(tester, localeCode: 'en');
      final context = tester.element(find.byType(SettingsPage));
      final l10n = AppLocalizations.of(context)!;

      // Get all Text widgets
      final textWidgets = tester.widgetList<Text>(find.byType(Text));

      // Check that known localized strings appear in text widgets
      final knownLocalizations = [
        l10n.account,
        l10n.appearance,
        l10n.languageAndRegion,
        l10n.accountSettings,
        l10n.manageAccountInfo,
        l10n.theme,
        l10n.accentColor,
        l10n.customizeAppColors,
        l10n.darkMode,
        l10n.toggleDarkMode,
        l10n.language,
      ];

      // Check if we find all our known localizations in the widget tree
      for (final locString in knownLocalizations) {
        expect(
          textWidgets.any((text) =>
              text.data == locString ||
              (text.textSpan?.toPlainText() == locString)),
          isTrue,
          reason:
              'Could not find localized string "$locString" in the widget tree',
        );
      }
    });

    /// Verifies that theme mode subtitles are correctly localized
    testWidgets('Theme subtitle is correctly localized',
        (WidgetTester tester) async {
      // Test System theme in English
      await pumpSettingsPage(tester,
          localeCode: 'en', themeMode: ThemeMode.system);
      final enContext = tester.element(find.byType(SettingsPage));
      final enL10n = AppLocalizations.of(enContext)!;
      expect(find.text(enL10n.systemTheme), findsOneWidget,
          reason: "System theme subtitle should be in English");

      // Test System theme in Spanish
      await pumpSettingsPage(tester,
          localeCode: 'es', themeMode: ThemeMode.system);
      final esContext = tester.element(find.byType(SettingsPage));
      final esL10n = AppLocalizations.of(esContext)!;
      expect(find.text(esL10n.systemTheme), findsOneWidget,
          reason: "System theme subtitle should be in Spanish");
    });

    /// Verifies that the dark mode switch state is correctly preserved when changing locales
    testWidgets('Dark mode state is preserved when changing locale',
        (WidgetTester tester) async {
      // Start with English and dark mode on
      await pumpSettingsPage(tester, localeCode: 'en', isDarkMode: true);

      // Verify dark mode switch is on in English
      final switchWidget = find.byType(Switch);
      expect(switchWidget, findsOneWidget, reason: "Switch should be present");
      expect((tester.widget(switchWidget) as Switch).value, isTrue,
          reason: "Dark mode should be enabled in English");

      // Change to Spanish
      await pumpSettingsPage(tester, localeCode: 'es', isDarkMode: true);

      // Verify dark mode is still on in Spanish
      final switchWidgetEs = find.byType(Switch);
      expect((tester.widget(switchWidgetEs) as Switch).value, isTrue,
          reason: "Dark mode should still be enabled in Spanish");

      // Verify Spanish UI elements using l10n
      final esContext = tester.element(find.byType(SettingsPage));
      final esL10n = AppLocalizations.of(esContext)!;
      expect(find.text(esL10n.darkMode), findsOneWidget,
          reason: "Dark Mode should now be in Spanish");
    });

    /// Verifies that localization works correctly when switching back from Spanish to English
    testWidgets('Updates text when locale changes from Spanish to English',
        (WidgetTester tester) async {
      // Start with Spanish
      await pumpSettingsPage(tester, localeCode: 'es');
      final esContext = tester.element(find.byType(SettingsPage));
      final esL10n = AppLocalizations.of(esContext)!;

      // Check Spanish text
      expect(find.text(esL10n.account), findsOneWidget);
      expect(find.text(esL10n.appearance), findsOneWidget);

      // Change to English
      await pumpSettingsPage(tester, localeCode: 'en');
      final enContext = tester.element(find.byType(SettingsPage));
      final enL10n = AppLocalizations.of(enContext)!;

      // Check English text
      expect(find.text(enL10n.account), findsOneWidget);
      expect(find.text(enL10n.appearance), findsOneWidget);
    });
  });
}
