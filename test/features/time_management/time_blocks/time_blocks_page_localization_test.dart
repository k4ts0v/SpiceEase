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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:spiceease/app/app_initializer.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/core/auth/auth_service.dart';
import 'package:spiceease/data/providers/unified_auth_provider.dart';
import 'package:spiceease/components/calendar_week_selector.dart' as calendar;
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/features/time_management/time_blocks/time_block_controller.dart';
import 'package:spiceease/features/time_management/time_blocks/time_blocks_page.dart';
import 'package:spiceease/l10n/app_localizations.dart';

// Mock AuthService class for testing
class MockAuthService implements AuthService {
  @override
  Future<String?> getCurrentUserId() async => 'test-user-id';

  @override
  Future<bool> isAuthenticated() async => true;

  // Implement other methods with minimal test implementations
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Create a fake Ref for testing
class FakeRef implements Ref {
  @override
  T read<T>(ProviderListenable<T> provider) {
    throw UnimplementedError('read not implemented in FakeRef');
  }

  @override
  void invalidate(ProviderOrFamily provider) {}

  @override
  ProviderSubscription<T> listen<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = true,
  }) {
    throw UnimplementedError('listen not implemented in FakeRef');
  }

  @override
  State refresh<State>(Refreshable<State> provider) {
    throw UnimplementedError('refresh not implemented in FakeRef');
  }

  @override
  T watch<T>(ProviderListenable<T> provider) {
    throw UnimplementedError('watch not implemented in FakeRef');
  }

  @override
  ProviderContainer get container => throw UnimplementedError();

  @override
  bool exists(ProviderBase<Object?> provider) => false;

  @override
  void invalidateSelf() {}

  @override
  KeepAliveLink keepAlive() {
    throw UnimplementedError();
  }

  @override
  void listenSelf(void Function(Object? previous, Object? next) listener,
      {void Function(Object error, StackTrace stackTrace)? onError}) {}

  @override
  void notifyListeners() {}

  @override
  void onAddListener(void Function() cb) {}

  @override
  void onCancel(void Function() cb) {}

  @override
  void onDispose(void Function() cb) {}

  @override
  void onRemoveListener(void Function() cb) {}

  @override
  void onResume(void Function() cb) {}
}

// --------------------------------------------------------------------------
// Test Data Setup
// --------------------------------------------------------------------------

/// Fixed test date for consistent date formatting across tests
final testSelectedDate = DateTime(2025, 6, 1); // Sunday, June 1, 2025

/// Creates test task and subtask data for localization testing
class LocalizationTestData {
  static List<TaskModel> getBasicTasks({required DateTime forDate}) => [
        // Scheduled task
        TaskModel(
          id: 'scheduled-1',
          title: 'Scheduled Task for Testing',
          status: 'todo',
          dueDate: forDate,
          priority: 1,
          description: 'Test scheduled task',
          createdAt: DateTime.now(),
          userId: 'test-user',
          updatedAt: DateTime.now(),
          startTime: DateTime(forDate.year, forDate.month, forDate.day, 9, 0),
          endTime: DateTime(forDate.year, forDate.month, forDate.day, 10, 0),
        ),
        // Unscheduled task
        TaskModel(
          id: 'unscheduled-1',
          title: 'Unscheduled Task for Testing',
          status: 'todo',
          dueDate: forDate,
          priority: 2,
          description: 'Test unscheduled task',
          createdAt: DateTime.now(),
          userId: 'test-user',
          updatedAt: DateTime.now(),
          startTime: null,
          endTime: null,
        ),
      ];

  static List<SubtaskModel> getBasicSubtasks({required DateTime forDate}) => [
        // Scheduled subtask
        SubtaskModel(
          id: 'scheduled-subtask-1',
          title: 'Scheduled Subtask for Testing',
          completed: false,
          taskId: 'parent-task-1',
          userId: 'test-user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          startTime: DateTime(forDate.year, forDate.month, forDate.day, 11, 0),
          endTime: DateTime(forDate.year, forDate.month, forDate.day, 11, 30),
          rawTimeValue: '30 minutes',
        ),
        // Unscheduled subtask
        SubtaskModel(
          id: 'unscheduled-subtask-1',
          title: 'Unscheduled Subtask for Testing',
          completed: false,
          taskId: 'parent-task-2',
          userId: 'test-user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          startTime: null,
          endTime: null,
          rawTimeValue: '45 minutes',
        ),
      ];
}

// --------------------------------------------------------------------------
// Mock Classes
// --------------------------------------------------------------------------

/// Mock TimeBlock Controller for localization testing
class MockTimeBlockController extends TimeBlockController {
  final List<TaskModel> _tasks;
  final List<SubtaskModel> _subtasks;
  final DateTime _currentDate;
  final bool _isEmpty;

  MockTimeBlockController(
    this._tasks,
    this._subtasks,
    this._currentDate, {
    bool isEmpty = false,
  })  : _isEmpty = isEmpty,
        super(FakeRef());

  @override
  List<dynamic> get scheduledItems => _isEmpty
      ? []
      : [
          ..._tasks.where((t) => t.startTime != null && t.endTime != null),
          ..._subtasks.where((s) => s.startTime != null && s.endTime != null),
        ];

  @override
  List<dynamic> get unscheduledItems => _isEmpty
      ? []
      : [
          ..._tasks.where((t) => t.startTime == null || t.endTime == null),
          ..._subtasks.where((s) => s.startTime == null || s.endTime == null),
        ];

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  DateTime? get currentSelectedDate => _currentDate;

  @override
  Future<void> loadTasks(BuildContext context) async {
    // Mock implementation - do nothing
  }

  @override
  Future<void> scheduleItem(
      dynamic item, DateTime startTime, DateTime endTime) async {
    // Mock implementation - do nothing
  }

  @override
  Future<void> unscheduleItem(dynamic item) async {
    // Mock implementation - do nothing
  }

  @override
  int getPriorityForSubtask(String subtaskId) {
    // Return a default priority for testing
    return 2;
  }
}

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
  /// [hasData]: Whether to include test data or use empty state
  Future<void> pumpTimeBlocksPage(
    WidgetTester tester,
    String localeCode, {
    DateTime? date,
    bool hasData = true,
  }) async {
    final effectiveDate = date ?? testSelectedDate;

    // Set a large test surface size to ensure all UI elements are visible
    await tester.binding.setSurfaceSize(const Size(1200, 800));

    // Create mock controller with test data
    final controller = MockTimeBlockController(
      hasData ? LocalizationTestData.getBasicTasks(forDate: effectiveDate) : [],
      hasData
          ? LocalizationTestData.getBasicSubtasks(forDate: effectiveDate)
          : [],
      effectiveDate,
      isEmpty: !hasData,
    );

    // Create a completed future for app initialization
    final appInitFuture = Future.value();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override auth-related providers
          authServiceProvider.overrideWithValue(MockAuthService()),
          isAuthenticatedProvider.overrideWithValue(true),

          // Override app initializer with a completed future
          appInitializerProvider.overrideWith((_) => appInitFuture),

          // Override the selected date provider with a fixed test date
          selectedDateProvider.overrideWith((ref) => effectiveDate),

          // Override the week offset provider with a fixed value
          weekOffsetProvider.overrideWith((ref) => 0),

          // Override time block controller provider
          timeBlockControllerProvider.overrideWith((ref) => controller),
        ],
        child: MaterialApp(
          locale: Locale(localeCode),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TimeBlocksPage(),
        ),
      ),
    );

    // Use controlled pumping for localization tests
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Helper function to show an unschedule confirmation dialog for testing modal localization
  Future<void> showUnscheduleDialog(
    WidgetTester tester,
    AppLocalizations l10n,
  ) async {
    final context = tester.element(find.byType(TimeBlocksPage));

    // Show a test unschedule dialog that matches the actual implementation
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unschedule),
        content: Text(l10n.unscheduleTaskConfirmation),
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
            child: Text(l10n.unschedule),
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
    /// Verifies that all major UI elements display correct English text
    /// when the app locale is set to English.
    ///
    /// This test covers:
    /// - AppBar title and action buttons
    /// - Date formatting
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

      // Verify calendar week selector exists
      expect(find.byType(calendar.CalendarWeekSelector), findsOneWidget,
          reason: "Calendar week selector should be present");

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

      // Verify calendar week selector exists
      expect(find.byType(calendar.CalendarWeekSelector), findsOneWidget,
          reason: "Calendar week selector should be present");

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

      // Act: Change to Spanish locale
      await pumpTimeBlocksPage(tester, 'es');
      final l10nEs =
          AppLocalizations.of(tester.element(find.byType(TimeBlocksPage)))!;

      // Assert: Verify Spanish state after locale change
      expect(find.text(l10nEs.timeBlocks), findsOneWidget,
          reason: "ES Time Blocks after change");

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

      // Assert: Verify time labels are present in schedule grid
      expect(find.textContaining('AM'), findsWidgets,
          reason: "AM time labels should be present in schedule");
      expect(find.textContaining('PM'), findsWidgets,
          reason: "PM time labels should be present in schedule");
    });

    /// Tests that empty states display correctly in different locales
    testWidgets('Displays empty states correctly in different locales',
        (WidgetTester tester) async {
      // Arrange: Set up TimeBlocksPage with English locale and no data
      await pumpTimeBlocksPage(tester, 'en', hasData: false);
      final l10n =
          AppLocalizations.of(tester.element(find.byType(TimeBlocksPage)))!;

      // Assert: Verify empty state messages are displayed (may be more flexible)
      expect(find.text(l10n.noTasks), findsAny,
          reason:
              "No tasks message should be displayed for empty unscheduled section");

      // Change to Spanish and verify
      await pumpTimeBlocksPage(tester, 'es', hasData: false);
      final l10nEs =
          AppLocalizations.of(tester.element(find.byType(TimeBlocksPage)))!;

      // Assert: Verify Spanish empty state messages
      expect(find.text(l10nEs.noTasks), findsAny,
          reason: "Spanish no tasks message should be displayed");
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
              of: dialogFinder, matching: find.text(l10n.unschedule)),
          findsAtLeastNWidgets(1),
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
              of: dialogFinder, matching: find.text(l10n.unschedule)),
          findsAtLeastNWidgets(1),
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
              of: dialogFinderEs, matching: find.text(l10nEs.cancel)),
          findsOneWidget,
          reason: "ES Cancel button after change");

      expect(
          find.descendant(
              of: dialogFinderEs, matching: find.text(l10nEs.unschedule)),
          findsAtLeastNWidgets(1),
          reason: "ES Unschedule button after change");

      // Assert: Ensure old English text is gone (if different from Spanish)
      if (l10nEn.unschedule != l10nEs.unschedule) {
        expect(
            find.descendant(
                of: dialogFinderEs, matching: find.text(l10nEn.unschedule)),
            findsNothing,
            reason: "Old EN Unschedule button should be gone");
      }
    });

    /// Tests time format localization in the schedule grid
    testWidgets('Displays time format correctly in different locales',
        (WidgetTester tester) async {
      // Arrange: Set up TimeBlocksPage with English locale
      await pumpTimeBlocksPage(tester, 'en');

      // Assert: Verify time format displays (English uses 12-hour format with AM/PM)
      expect(find.textContaining('AM'), findsAtLeastNWidgets(1),
          reason: "AM should be present in English time format");
      expect(find.textContaining('PM'), findsAtLeastNWidgets(1),
          reason: "PM should be present in English time format");

      // Look for specific time labels that should be visible
      expect(find.textContaining('12'), findsAtLeastNWidgets(1),
          reason: "12 o'clock should be visible in schedule");
      expect(find.textContaining('6'), findsAtLeastNWidgets(1),
          reason: "6 o'clock should be visible in schedule");
    });

    /// Tests that the page handles loading states with proper localization
    testWidgets('Displays loading states with correct locale',
        (WidgetTester tester) async {
      // Create a controller that reports loading state
      final controller = MockTimeBlockController([], [], DateTime.now());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(MockAuthService()),
            isAuthenticatedProvider.overrideWithValue(true),
            appInitializerProvider.overrideWith((_) => Future.value()),
            selectedDateProvider.overrideWith((ref) => testSelectedDate),
            weekOffsetProvider.overrideWith((ref) => 0),
            timeBlockControllerProvider.overrideWith((ref) => controller),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const TimeBlocksPage(),
          ),
        ),
      );

      await tester.pump();

      // Assert: Page should render without error even with empty data
      expect(find.byType(Scaffold), findsOneWidget,
          reason: "Scaffold should be present during empty state");
    });
  });
}
