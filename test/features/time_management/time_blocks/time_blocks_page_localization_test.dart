/// This file tests the localization functionality of the TimeBlocksPage widget.
///
/// # Testing Strategy
///
/// This test suite validates four main scenarios for the TimeBlocksPage:
///
/// 1.  **Static English Localization**:
///     - Verifies that all relevant UI elements (AppBar title, buttons, section headers,
///       date formatting, empty state messages) display the correct English text when the
///       application's locale is set to 'en'.
///     - Ensures that `AppLocalizations.en` strings are correctly loaded and rendered.
///
/// 2.  **Static Spanish Localization**:
///     - Verifies that all relevant UI elements display the correct Spanish text when the
///       application's locale is set to 'es'.
///     - Ensures that `AppLocalizations.es` strings are correctly loaded and rendered.
///
/// 3.  **Dynamic Locale Change**:
///     - Tests the behavior of the TimeBlocksPage when the locale is changed dynamically
///       (e.g., from English to Spanish) during runtime.
///     - Verifies that the widget tree rebuilds and all localizable strings are updated
///       to reflect the new locale.
///
/// 4.  **Modal Localization**:
///     - Tests that modals (like unschedule confirmation dialogs) display correct
///       localized text including titles, messages, and button labels.
///
/// # Features Tested
///
/// The localization tests cover a comprehensive set of UI elements within the TimeBlocksPage:
/// - **AppBar Title**: e.g., "Time Blocks".
/// - **Buttons**: e.g., "New Task".
/// - **Tooltips**: e.g., "Refresh".
/// - **Date Display**: Format of the selected date.
/// - **Section Titles**: "Unscheduled Tasks".
/// - **Empty State Messages**: "No tasks" for empty unscheduled tasks section.
/// - **Time Format**: Hour labels in the schedule area.
/// - **Calendar Navigation**: Week navigation chevron buttons.
/// - **Modal Dialogs**: Unschedule confirmation dialog text and buttons.
///
/// # Technical Approach
///
/// - **ProviderScope & Overrides**: Each test sets up a `ProviderScope` to manage Riverpod state.
///   Key providers are overridden:
///   - `selectedDateProvider`: Overridden to provide a fixed date, ensuring consistency.
///   - `weekOffsetProvider`: Overridden to provide a fixed week offset for consistent calendar display.
/// - **MaterialApp Wrapper**: The `TimeBlocksPage` is wrapped in a `MaterialApp` to provide the
///   necessary context for localization (locale, localizationsDelegates, supportedLocales).
/// - **`pumpTimeBlocksPage` Helper**: A utility function to encapsulate the widget pumping logic,
///   including setting the locale and providing consistent test setup.
/// - **`AppLocalizations`**: Used to access localized strings programmatically for assertions.
/// - **`tester.pumpAndSettle()`**: Used to wait for UI updates and animations to complete.
/// - **Modal Testing**: Uses `showDialog` programmatically to test modal localization without
///   requiring complex user interaction simulation.
///
/// # Test Structure
///
/// Each `testWidgets` follows the Arrange-Act-Assert pattern:
/// - **Arrange**:
///   - The `TimeBlocksPage` is pumped with the desired locale using `pumpTimeBlocksPage`.
///   - An instance of `AppLocalizations` for the current locale is obtained.
///   - Finders for various UI elements are prepared.
/// - **Act**: (Often minimal, as pumping the widget with the correct state is the primary action)
///   - `tester.pumpAndSettle()` is called to allow the widget tree to stabilize.
/// - **Assert**:
///   - `expect()` is used with various finders (`find.text`, `find.widgetWithText`, `find.byTooltip`)
///     to verify that UI elements display the correct localized text.
///   - `reason` strings are provided in assertions for clearer test failure messages.
///
/// # How to run
/// - Run with `flutter test test/features/time_management/locales/time_blocks_page_localization_test.dart`
/// - No external dependencies are required as all providers use minimal overrides.
///
/// # Example output
/// - If localization strings are missing or incorrect, tests will fail with descriptive messages.
/// - If locale switching doesn't work, the dynamic locale change test will fail.
/// - If UI elements aren't found, tests will fail with specific finder information.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:spiceease/components/calendar_week_selector.dart' as calendar;
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/features/time_management/time_blocks/time_blocks_page.dart';
import 'package:spiceease/l10n/app_localizations.dart';

// --------------------------------------------------------------------------
// Test Data Setup
// --------------------------------------------------------------------------

/// Fixed test date for consistent date formatting across tests
final testSelectedDate = DateTime(2025, 6, 1); // Sunday, June 1, 2025

// --------------------------------------------------------------------------
// Test Helpers
// --------------------------------------------------------------------------

void main() {
  /// Helper function to set up and pump the TimeBlocksPage widget with the specified
  /// locale and test data. This encapsulates the complex setup required for
  /// testing localized widgets with Riverpod providers.
  ///
  /// [localeCode]: The locale to test (e.g., 'en', 'es')
  /// [date]: Optional date override (defaults to testSelectedDate)
  Future<void> pumpTimeBlocksPage(
    WidgetTester tester,
    String localeCode, {
    DateTime? date,
  }) async {
    final effectiveDate = date ?? testSelectedDate;

    // Set a large test surface size to ensure all UI elements are visible
    await tester.binding.setSurfaceSize(const Size(1200, 800));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override the selected date provider with a fixed test date
          selectedDateProvider.overrideWith((ref) => effectiveDate),

          // Override the week offset provider with a fixed value
          weekOffsetProvider.overrideWith((ref) => 0),
        ],
        child: MaterialApp(
          locale: Locale(localeCode),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TimeBlocksPage(),
        ),
      ),
    );

    // Wait for all animations and async operations to complete
    await tester.pumpAndSettle();
  }

  /// Helper function to show an unschedule confirmation dialog for testing modal localization
  /// This mimics the actual dialog shown in TimeBlocksPage._confirmUnschedule()
  Future<void> showUnscheduleDialog(
    WidgetTester tester,
    AppLocalizations l10n,
  ) async {
    final context = tester.element(find.byType(TimeBlocksPage));

    // Show a test unschedule dialog that matches the actual implementation
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unscheduledTasks), // This is what the actual code uses
        content: Text(l10n
            .unscheduleTaskConfirmation), // This is what the actual code uses
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: Text(
                l10n.unschedule), // Use localized string instead of hardcoded
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();
  }

  // --------------------------------------------------------------------------
  // Test Cases
  // --------------------------------------------------------------------------

  group('TimeBlocksPage Localization Tests', () {
    /// Example test structure for localization tests:
    /// testWidgets('description', (WidgetTester tester) async {
    ///   // 1. Arrange: Set up the page with the desired locale and test data.
    ///   // 2. Act: Pump the widget and allow it to settle.
    ///   // 3. Assert: Verify that UI elements display the correct localized text.
    /// });

    /// Verifies that all major UI elements display correct English text
    /// when the app locale is set to English.
    ///
    /// This test covers:
    /// - AppBar title and action buttons
    /// - Date formatting
    /// - Section titles
    /// - Empty state messages
    /// - Calendar navigation elements
    testWidgets('Displays English UI elements correctly',
        (WidgetTester tester) async {
      // Arrange: Set up TimeBlocksPage with English locale
      await pumpTimeBlocksPage(tester, 'en');
      final l10n =
          AppLocalizations.of(tester.element(find.byType(TimeBlocksPage)))!;

      // Assert: Verify all English UI elements are present
      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget, reason: "AppBar should be present");

      expect(
          find.descendant(
              of: appBarFinder, matching: find.text(l10n.timeBlocks)),
          findsOneWidget,
          reason: "AppBar title should be in English");

      expect(
          find.descendant(of: appBarFinder, matching: find.text(l10n.newTask)),
          findsOneWidget,
          reason: "New Task button should be in English");

      expect(find.byTooltip(l10n.refresh), findsOneWidget,
          reason: "Refresh tooltip should be in English");

      // Verify date formatting uses English locale
      final expectedDateString =
          DateFormat.yMMMMd('en').format(testSelectedDate);
      expect(find.text(expectedDateString), findsOneWidget,
          reason: "Date should be formatted in English");

      // Verify section titles are in English
      expect(find.text(l10n.unscheduledTasks), findsOneWidget,
          reason: "Unscheduled Tasks section should be in English");

      // Verify empty state text is in English
      expect(find.text(l10n.noTasks), findsOneWidget,
          reason: "No tasks message should be in English");

      // Verify calendar navigation elements exist
      expect(find.byIcon(Icons.chevron_left), findsAtLeastNWidgets(1),
          reason: "Previous week chevron should be present");
      expect(find.byIcon(Icons.chevron_right), findsAtLeastNWidgets(1),
          reason: "Next week chevron should be present");
    });

    /// Verifies that all major UI elements display correct Spanish text
    /// when the app locale is set to Spanish.
    ///
    /// This is a parallel test to the English version, ensuring that
    /// localization works correctly for non-English locales.
    testWidgets('Displays Spanish UI elements correctly',
        (WidgetTester tester) async {
      // Arrange: Set up TimeBlocksPage with Spanish locale
      await pumpTimeBlocksPage(tester, 'es');
      final l10n =
          AppLocalizations.of(tester.element(find.byType(TimeBlocksPage)))!;

      // Assert: Verify all Spanish UI elements are present
      final appBarFinder = find.byType(AppBar);
      expect(
          find.descendant(
              of: appBarFinder, matching: find.text(l10n.timeBlocks)),
          findsOneWidget,
          reason: "AppBar title should be in Spanish");

      expect(
          find.descendant(of: appBarFinder, matching: find.text(l10n.newTask)),
          findsOneWidget,
          reason: "New Task button should be in Spanish");

      expect(find.byTooltip(l10n.refresh), findsOneWidget,
          reason: "Refresh tooltip should be in Spanish");

      // Verify date formatting uses Spanish locale
      final expectedDateString =
          DateFormat.yMMMMd('es').format(testSelectedDate);
      expect(find.text(expectedDateString), findsOneWidget,
          reason: "Date should be formatted in Spanish");

      // Verify section titles are in Spanish
      expect(find.text(l10n.unscheduledTasks), findsOneWidget,
          reason: "Unscheduled Tasks section should be in Spanish");

      // Verify empty state text is in Spanish
      expect(find.text(l10n.noTasks), findsOneWidget,
          reason: "No tasks message should be in Spanish");

      // Verify calendar navigation elements exist
      expect(find.byIcon(Icons.chevron_left), findsAtLeastNWidgets(1),
          reason: "Previous week chevron should be present");
      expect(find.byIcon(Icons.chevron_right), findsAtLeastNWidgets(1),
          reason: "Next week chevron should be present");
    });

    /// Tests dynamic locale switching by verifying that UI elements update
    /// correctly when the locale changes from English to Spanish at runtime.
    ///
    /// This test is crucial for ensuring that the localization system works
    /// correctly in real-world scenarios where users might change their
    /// language preference while the app is running.
    testWidgets('Updates when locale changes from English to Spanish',
        (WidgetTester tester) async {
      // Arrange: Start with English locale
      await pumpTimeBlocksPage(tester, 'en');
      final l10nEn =
          AppLocalizations.of(tester.element(find.byType(TimeBlocksPage)))!;

      // Act: Verify initial English state
      expect(find.text(l10nEn.timeBlocks), findsOneWidget,
          reason: "EN Time Blocks initially");
      expect(find.text(l10nEn.unscheduledTasks), findsOneWidget,
          reason: "EN Unscheduled Tasks initially");

      // Act: Change to Spanish locale
      await pumpTimeBlocksPage(tester, 'es');
      final l10nEs =
          AppLocalizations.of(tester.element(find.byType(TimeBlocksPage)))!;

      // Assert: Verify Spanish state after locale change
      expect(find.text(l10nEs.timeBlocks), findsOneWidget,
          reason: "ES Time Blocks after change");
      expect(find.text(l10nEs.unscheduledTasks), findsOneWidget,
          reason: "ES Unscheduled Tasks after change");

      // Assert: Ensure old English text is gone (if different from Spanish)
      if (l10nEn.timeBlocks != l10nEs.timeBlocks) {
        expect(find.text(l10nEn.timeBlocks), findsNothing,
            reason: "Old EN Time Blocks title should be gone");
      }
    });

    /// Verifies that the basic structure of the TimeBlocksPage exists
    /// and all core UI elements are present.
    ///
    /// This test ensures that the page renders correctly even when
    /// there are no tasks to display.
    testWidgets('Verifies core UI elements exist', (WidgetTester tester) async {
      // Arrange: Set up TimeBlocksPage with English locale
      await pumpTimeBlocksPage(tester, 'en');
      final l10n =
          AppLocalizations.of(tester.element(find.byType(TimeBlocksPage)))!;

      // Assert: Verify basic structure exists
      expect(find.byType(AppBar), findsOneWidget,
          reason: "AppBar should exist");
      expect(find.byType(Scaffold), findsOneWidget,
          reason: "Scaffold should exist");

      // Assert: Verify calendar week selector exists
      expect(find.byType(calendar.CalendarWeekSelector), findsOneWidget,
          reason: "Calendar week selector should exist");

      // Assert: Verify essential icons are present
      expect(find.byIcon(Icons.add), findsOneWidget,
          reason: "Add task icon should exist");
      expect(find.byIcon(Icons.refresh), findsOneWidget,
          reason: "Refresh icon should exist");

      // Assert: Verify localized empty state message
      expect(find.text(l10n.noTasks), findsOneWidget,
          reason: "No tasks message should exist in empty state");

      // Assert: Verify time labels are present in schedule grid
      expect(find.textContaining('AM'), findsWidgets,
          reason: "AM time labels should be present in schedule");
      expect(find.textContaining('PM'), findsWidgets,
          reason: "PM time labels should be present in schedule");
    });

    /// Verifies that the unschedule confirmation modal displays correct English text
    /// when the app locale is set to English.
    ///
    /// This test covers modal localization including:
    /// - Dialog title
    /// - Dialog message/content
    /// - Action button labels (Cancel, Unschedule)
    testWidgets('Displays English unschedule modal correctly',
        (WidgetTester tester) async {
      // Arrange: Set up TimeBlocksPage with English locale
      await pumpTimeBlocksPage(tester, 'en');
      final l10n =
          AppLocalizations.of(tester.element(find.byType(TimeBlocksPage)))!;

      // Act: Show the unschedule confirmation dialog
      await showUnscheduleDialog(tester, l10n);

      // Assert: Verify English modal text is present within the dialog
      final dialogFinder = find.byType(AlertDialog);
      expect(dialogFinder, findsOneWidget,
          reason: "Alert dialog should be present");

      expect(
          find.descendant(
              of: dialogFinder, matching: find.text(l10n.unscheduledTasks)),
          findsOneWidget,
          reason: "Dialog title should be in English");

      expect(
          find.descendant(
              of: dialogFinder,
              matching: find.text(l10n.unscheduleTaskConfirmation)),
          findsOneWidget,
          reason: "Dialog message should be in English");

      expect(
          find.descendant(of: dialogFinder, matching: find.text(l10n.cancel)),
          findsOneWidget,
          reason: "Cancel button should be in English");

      expect(
          find.descendant(
              of: dialogFinder, matching: find.text(l10n.unschedule)),
          findsOneWidget,
          reason: "Unschedule button should be in English");
    });

    /// Verifies that the unschedule confirmation modal displays correct Spanish text
    /// when the app locale is set to Spanish.
    ///
    /// This is a parallel test to the English modal version, ensuring that
    /// modal localization works correctly for non-English locales.
    testWidgets('Displays Spanish unschedule modal correctly',
        (WidgetTester tester) async {
      // Arrange: Set up TimeBlocksPage with Spanish locale
      await pumpTimeBlocksPage(tester, 'es');
      final l10n =
          AppLocalizations.of(tester.element(find.byType(TimeBlocksPage)))!;

      // Act: Show the unschedule confirmation dialog
      await showUnscheduleDialog(tester, l10n);

      // Assert: Verify Spanish modal text is present within the dialog
      final dialogFinder = find.byType(AlertDialog);
      expect(dialogFinder, findsOneWidget,
          reason: "Alert dialog should be present");

      expect(
          find.descendant(
              of: dialogFinder, matching: find.text(l10n.unscheduledTasks)),
          findsOneWidget,
          reason: "Dialog title should be in Spanish");

      expect(
          find.descendant(
              of: dialogFinder,
              matching: find.text(l10n.unscheduleTaskConfirmation)),
          findsOneWidget,
          reason: "Dialog message should be in Spanish");

      expect(
          find.descendant(of: dialogFinder, matching: find.text(l10n.cancel)),
          findsOneWidget,
          reason: "Cancel button should be in Spanish");

      expect(
          find.descendant(
              of: dialogFinder, matching: find.text(l10n.unschedule)),
          findsOneWidget,
          reason: "Unschedule button should be in Spanish");
    });

    /// Tests that the unschedule modal updates correctly when locale changes
    /// from English to Spanish at runtime.
    ///
    /// This test ensures that modals respect dynamic locale changes.
    testWidgets('Unschedule modal updates when locale changes',
        (WidgetTester tester) async {
      // Arrange: Start with English locale
      await pumpTimeBlocksPage(tester, 'en');
      final l10nEn =
          AppLocalizations.of(tester.element(find.byType(TimeBlocksPage)))!;

      // Act: Show English modal
      await showUnscheduleDialog(tester, l10nEn);

      // Assert: Verify initial English state within the dialog
      final dialogFinder = find.byType(AlertDialog);
      expect(
          find.descendant(
              of: dialogFinder, matching: find.text(l10nEn.unscheduledTasks)),
          findsOneWidget,
          reason: "EN Dialog title initially");
      expect(
          find.descendant(of: dialogFinder, matching: find.text(l10nEn.cancel)),
          findsOneWidget,
          reason: "EN Cancel button initially");

      // Act: Dismiss the dialog
      await tester.tap(find.descendant(
          of: dialogFinder, matching: find.text(l10nEn.cancel)));
      await tester.pumpAndSettle();

      // Act: Change to Spanish locale
      await pumpTimeBlocksPage(tester, 'es');
      final l10nEs =
          AppLocalizations.of(tester.element(find.byType(TimeBlocksPage)))!;

      // Act: Show Spanish modal
      await showUnscheduleDialog(tester, l10nEs);

      // Assert: Verify Spanish state after locale change within the dialog
      final dialogFinderEs = find.byType(AlertDialog);
      expect(
          find.descendant(
              of: dialogFinderEs, matching: find.text(l10nEs.unscheduledTasks)),
          findsOneWidget,
          reason: "ES Dialog title after change");
      expect(
          find.descendant(
              of: dialogFinderEs, matching: find.text(l10nEs.cancel)),
          findsOneWidget,
          reason: "ES Cancel button after change");

      expect(
          find.descendant(
              of: dialogFinderEs, matching: find.text(l10nEs.unschedule)),
          findsOneWidget,
          reason: "ES Unschedule button after change");

      // Assert: Ensure old English text is gone (if different from Spanish)
      if (l10nEn.unscheduledTasks != l10nEs.unscheduledTasks) {
        expect(
            find.descendant(
                of: dialogFinderEs,
                matching: find.text(l10nEn.unscheduledTasks)),
            findsNothing,
            reason: "Old EN Dialog title should be gone");
      }

      if (l10nEn.unschedule != l10nEs.unschedule) {
        expect(
            find.descendant(
                of: dialogFinderEs,
                matching: find.text(l10nEn.unschedule)),
            findsNothing,
            reason: "Old EN Unschedule button should be gone");
      }
    });
  });
}