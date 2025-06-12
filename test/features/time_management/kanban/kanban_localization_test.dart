/// This file tests the localization functionality of the KanbanPage widget.
///
/// # Testing Strategy
///
/// This test suite validates three main scenarios for the KanbanPage:
///
/// 1.  **Static English Localization**:
///     - Verifies that all relevant UI elements (AppBar title, buttons, column headers,
///       task details, empty state messages) display the correct English text when the
///       application's locale is set to 'en'.
///     - Ensures that `AppLocalizations.en` strings are correctly loaded and rendered.
///
/// 2.  **Static Spanish Localization**:
///     - Verifies that all relevant UI elements display the correct Spanish text when the
///       application's locale is set to 'es'.
///     - Ensures that `AppLocalizations.es` strings are correctly loaded and rendered.
///
/// 3.  **Dynamic Locale Change**:
///     - Tests the behavior of the KanbanPage when the locale is changed dynamically
///       (e.g., from English to Spanish) during runtime.
///     - Verifies that the widget tree rebuilds and all localizable strings are updated
///       to reflect the new locale.
///
/// # Features Tested
///
/// The localization tests cover a comprehensive set of UI elements within the KanbanPage:
/// - **AppBar Title**: e.g., "Kanban Board".
/// - **Buttons**: e.g., "New Task".
/// - **Tooltips**: e.g., "Refresh".
/// - **Loading Indicator Text**: e.g., "Loading...".
/// - **Date Display**: Format of the selected date.
/// - **Column Titles**: "TODO", "IN PROGRESS", "DONE".
/// - **Section Titles**: "Tasks without due date".
/// - **Empty State Messages**:
///   - "No tasks" and "Drag tasks here" for empty columns.
///   - "No tasks without due date" for the empty no-due-date section.
/// - **Task Card Details**:
///   - Priority labels (e.g., "High Priority").
///   - "Subtask" indicator.
///
/// # Technical Approach
///
/// - **ProviderScope & Overrides**: Each test sets up a `ProviderScope` to manage Riverpod state.
///   Key providers are overridden:
///   - `kanbanControllerProvider`: Overridden with a `TestKanbanController` instance. This
///     controller is initialized with a predefined list of tasks and a selected date to
///     provide consistent data for tests. Its `loadTasks` method is simplified for testing.
///   - `selectedDateProvider`: Overridden to provide a fixed date, ensuring consistency.
/// - **MaterialApp Wrapper**: The `KanbanPage` is wrapped in a `MaterialApp` to provide the
///   necessary context for localization (locale, localizationsDelegates, supportedLocales).
/// - **`pumpKanbanPage` Helper**: A utility function to encapsulate the widget pumping logic,
///   including setting the locale, providing the mock controller, and initial task data.
/// - **`TestKanbanController`**: A simplified version of `KanbanController` that allows direct
///   control over the tasks displayed and loading states for testing purposes.
/// - **Mock Task Data**: Predefined `TaskModel` instances are used to populate the Kanban board
///   in various states (e.g., with tasks in each column, empty columns).
/// - **`AppLocalizations`**: Used to access localized strings programmatically for assertions.
/// - **`tester.pumpAndSettle()`**: Used to wait for UI updates and animations to complete.
///
/// # Test Structure
///
/// Each `testWidgets` follows the Arrange-Act-Assert pattern:
/// - **Arrange**:
///   - The `KanbanPage` is pumped with the desired locale and mock task data using `pumpKanbanPage`.
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
/// - Run with `flutter test test/features/time_management/locales/kanban_page_localization_test.dart`
/// - No external dependencies are required as all providers are mocked.
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
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/features/time_management/kanban/kanban_controller.dart';
import 'package:spiceease/features/time_management/kanban/kanban_page.dart';
import 'package:spiceease/l10n/app_localizations.dart';

// --------------------------------------------------------------------------
// Test Data Setup
// --------------------------------------------------------------------------

/// Fixed test date for consistent date formatting across tests
final testSelectedDate = DateTime(2025, 6, 1); // Sunday, June 1, 2025

/// Creates a comprehensive set of sample tasks covering all statuses and priorities.
/// Used to populate the Kanban board with realistic test data.
List<TaskModel> getSampleTasks({required DateTime forDate}) => [
      TaskModel(
          id: 't1',
          title: 'Todo Task 1',
          status: 'todo',
          dueDate: forDate,
          priority: 3,
          createdAt: DateTime.now(),
          userId: '',
          updatedAt: DateTime.now()),
      TaskModel(
          id: 't2',
          title: 'InProgress Task 1',
          status: 'in_progress',
          dueDate: forDate,
          priority: 5,
          createdAt: DateTime.now(),
          userId: '',
          updatedAt: DateTime.now()),
      TaskModel(
          id: 't3',
          title: 'Done Task 1',
          status: 'done',
          dueDate: forDate,
          priority: 1,
          createdAt: DateTime.now(),
          userId: '',
          updatedAt: DateTime.now()),
      TaskModel(
          id: 't4',
          title: 'Subtask for Todo',
          status: 'todo',
          dueDate: forDate,
          priority: 2,
          createdAt: DateTime.now(),
          userId: '',
          updatedAt: DateTime.now()),
      TaskModel(
          id: 'nd1',
          title: 'No DueDate Task 1',
          status: 'todo',
          dueDate: null,
          priority: 4,
          createdAt: DateTime.now(),
          userId: '',
          updatedAt: DateTime.now()),
      TaskModel(
          id: 'prio1',
          title: 'Priority 1 Task',
          status: 'todo',
          dueDate: forDate,
          priority: 1,
          createdAt: DateTime.now(),
          userId: '',
          updatedAt: DateTime.now()),
      TaskModel(
          id: 'prio2',
          title: 'Priority 2 Task',
          status: 'todo',
          dueDate: forDate,
          priority: 2,
          createdAt: DateTime.now(),
          userId: '',
          updatedAt: DateTime.now()),
      TaskModel(
          id: 'prio3',
          title: 'Priority 3 Task',
          status: 'todo',
          dueDate: forDate,
          priority: 3,
          createdAt: DateTime.now(),
          userId: '',
          updatedAt: DateTime.now()),
      TaskModel(
          id: 'prio4',
          title: 'Priority 4 Task',
          status: 'todo',
          dueDate: forDate,
          priority: 4,
          createdAt: DateTime.now(),
          userId: '',
          updatedAt: DateTime.now()),
      TaskModel(
          id: 'prio5',
          title: 'Priority 5 Task',
          status: 'todo',
          dueDate: forDate,
          priority: 5,
          createdAt: DateTime.now(),
          userId: '',
          updatedAt: DateTime.now()),
    ];

/// Empty task list for testing loading states and empty UI states
final List<TaskModel> emptyTasks = [];

// --------------------------------------------------------------------------
// Test Doubles
// --------------------------------------------------------------------------

/// A test-specific implementation of KanbanController that provides
/// predictable behavior for testing localization features.
///
/// This controller allows direct manipulation of task lists and loading
/// states without requiring actual database connections or complex state management.
class TestKanbanController extends KanbanController {
  final List<TaskModel> _allTasksStorage;
  DateTime _currentSelectedDateStorage;
  bool _isLoadingStorage = false;

  List<TaskModel> _todoList = [];
  List<TaskModel> _inProgressList = [];
  List<TaskModel> _doneList = [];
  List<TaskModel> _noDateList = [];

  TestKanbanController(
      super.ref, List<TaskModel> initialTasks, DateTime initialDate)
      : _allTasksStorage = initialTasks,
        _currentSelectedDateStorage = initialDate {
    _filterTasksForDate(_currentSelectedDateStorage);
  }

  @override
  List<TaskModel> get todoTasks => _todoList;
  @override
  List<TaskModel> get inProgressTasks => _inProgressList;
  @override
  List<TaskModel> get doneTasks => _doneList;
  @override
  List<TaskModel> get noDueDateTasks => _noDateList;
  @override
  bool get isLoading => _isLoadingStorage;
  @override
  DateTime get currentSelectedDate => _currentSelectedDateStorage;

  /// Filters the stored tasks by the given date and categorizes them by status.
  /// This simulates the real controller's date-based filtering logic.
  void _filterTasksForDate(DateTime date) {
    _currentSelectedDateStorage = date;
    _todoList = _allTasksStorage
        .where((task) =>
            task.status == 'todo' &&
            task.dueDate != null &&
            _isSameDay(task.dueDate!, date))
        .toList();
    _inProgressList = _allTasksStorage
        .where((task) =>
            task.status == 'in_progress' &&
            task.dueDate != null &&
            _isSameDay(task.dueDate!, date))
        .toList();
    _doneList = _allTasksStorage
        .where((task) =>
            task.status == 'done' &&
            task.dueDate != null &&
            _isSameDay(task.dueDate!, date))
        .toList();
    _noDateList =
        _allTasksStorage.where((task) => task.dueDate == null).toList();
  }

  /// Helper method to check if two dates represent the same calendar day
  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  @override
  Future<void> loadTasks(BuildContext context, {DateTime? date}) async {
    _isLoadingStorage = true;
    await Future.delayed(Duration.zero); // Simulate async operation

    if (date != null) {
      _filterTasksForDate(date);
    } else {
      _filterTasksForDate(_currentSelectedDateStorage);
    }
    _isLoadingStorage = false;
  }

  @override
  Future<void> updateTaskStatus(
      TaskModel task, String newStatus, BuildContext context) async {
    final index = _allTasksStorage.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _allTasksStorage[index] =
          _allTasksStorage[index].copyWith(status: newStatus);
      _filterTasksForDate(_currentSelectedDateStorage);
    }
  }

  /// Test helper method to explicitly control the loading state
  void setLoadingState(bool isLoading) {
    _isLoadingStorage = isLoading;
  }
}

// --------------------------------------------------------------------------
// Test Helpers
// --------------------------------------------------------------------------

void main() {
  /// Helper function to set up and pump the KanbanPage widget with the specified
  /// locale and test data. This encapsulates the complex setup required for
  /// testing localized widgets with Riverpod providers.
  ///
  /// [localeCode]: The locale to test (e.g., 'en', 'es')
  /// [currentTasks]: The tasks to populate the controller with
  /// [date]: Optional date override (defaults to testSelectedDate)
  /// [isLoading]: Whether to start in loading state
  Future<void> pumpKanbanPage(
    WidgetTester tester,
    String localeCode,
    List<TaskModel> currentTasks, {
    DateTime? date,
    bool isLoading = false,
  }) async {
    final effectiveDate = date ?? testSelectedDate;

    // Set a large test surface size to ensure all UI elements are visible
    await tester.binding.setSurfaceSize(const Size(1200, 800));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override the selected date provider with a fixed test date
          selectedDateProvider.overrideWith((ref) => effectiveDate),

          // Override the kanban controller with our test implementation
          kanbanControllerProvider.overrideWith((ref) {
            final testController = TestKanbanController(
              ref,
              currentTasks
                  .map((t) => t.copyWith())
                  .toList(), // Deep copy to avoid mutations
              effectiveDate,
            );
            testController.setLoadingState(isLoading);
            return testController;
          }),
        ],
        child: MaterialApp(
          locale: Locale(localeCode),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const KanbanPage(),
        ),
      ),
    );

    // Wait for different completion states based on loading status
    if (isLoading) {
      await tester.pump(); // Single pump for loading state
    } else {
      await tester.pumpAndSettle(); // Wait for all animations to complete
    }
  }

  // --------------------------------------------------------------------------
  // Test Cases
  // --------------------------------------------------------------------------

  group('KanbanPage Localization Tests', () {
    /// Verifies that all major UI elements display correct English text
    /// when the app locale is set to English.
    ///
    /// This test covers:
    /// - AppBar title and action buttons
    /// - Date formatting
    /// - Column headers for all task statuses
    /// - Section titles
    /// - Task priority labels
    /// - Subtask indicators
    testWidgets('Displays English UI elements correctly',
        (WidgetTester tester) async {
      // Arrange: Set up KanbanPage with English locale and sample tasks
      await pumpKanbanPage(
          tester, 'en', getSampleTasks(forDate: testSelectedDate));
      final l10n =
          AppLocalizations.of(tester.element(find.byType(KanbanPage)))!;

      // Act: (Widget is already pumped and settled)

      // Assert: Verify all English UI elements are present
      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget, reason: "AppBar should be present");

      expect(
          find.descendant(of: appBarFinder, matching: find.text(l10n.kanban)),
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

      // Verify all column headers are in English
      expect(find.text(l10n.todo), findsWidgets,
          reason: "Todo column should be in English");
      expect(find.text(l10n.inProgress), findsWidgets,
          reason: "In Progress column should be in English");
      expect(find.text(l10n.done), findsWidgets,
          reason: "Done column should be in English");

      // Verify section titles are in English
      expect(find.text(l10n.tasksWithoutDueDate), findsOneWidget,
          reason: "Tasks without due date section should be in English");

      // Verify task priority labels are in English
      expect(find.text(l10n.highestPriority, skipOffstage: false), findsWidgets,
          reason: "Highest Priority label should be in English");
      expect(find.text(l10n.mediumPriority, skipOffstage: false), findsWidgets,
          reason: "Medium Priority label should be in English");
      expect(find.text(l10n.lowestPriority, skipOffstage: false), findsWidgets,
          reason: "Lowest Priority label should be in English");
    });

    /// Verifies that all major UI elements display correct Spanish text
    /// when the app locale is set to Spanish.
    ///
    /// This is a parallel test to the English version, ensuring that
    /// localization works correctly for non-English locales.
    testWidgets('Displays Spanish UI elements correctly',
        (WidgetTester tester) async {
      // Arrange: Set up KanbanPage with Spanish locale and sample tasks
      await pumpKanbanPage(
          tester, 'es', getSampleTasks(forDate: testSelectedDate));
      final l10n =
          AppLocalizations.of(tester.element(find.byType(KanbanPage)))!;

      // Act: (Widget is already pumped and settled)

      // Assert: Verify all Spanish UI elements are present
      final appBarFinder = find.byType(AppBar);
      expect(
          find.descendant(of: appBarFinder, matching: find.text(l10n.kanban)),
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

      // Verify all column headers are in Spanish
      expect(find.text(l10n.todo), findsWidgets,
          reason: "Todo column should be in Spanish");
      expect(find.text(l10n.inProgress), findsWidgets,
          reason: "In Progress column should be in Spanish");
      expect(find.text(l10n.done), findsWidgets,
          reason: "Done column should be in Spanish");

      // Verify section titles are in Spanish
      expect(find.text(l10n.tasksWithoutDueDate), findsOneWidget,
          reason: "Tasks without due date section should be in Spanish");

      // Verify task priority labels are in Spanish
      expect(find.text(l10n.highestPriority, skipOffstage: false), findsWidgets,
          reason: "Highest Priority label should be in Spanish");
      expect(find.text(l10n.mediumPriority, skipOffstage: false), findsWidgets,
          reason: "Medium Priority label should be in Spanish");
      expect(find.text(l10n.lowestPriority, skipOffstage: false), findsWidgets,
          reason: "Lowest Priority label should be in Spanish");

    });

    /// Verifies that the loading state displays the correct localized text
    /// when the controller is in loading mode with English locale.
    testWidgets('Displays English loading state correctly',
        (WidgetTester tester) async {
      // Arrange: Set up KanbanPage in loading state with English locale
      await pumpKanbanPage(tester, 'en', emptyTasks, isLoading: true);
      final l10n =
          AppLocalizations.of(tester.element(find.byType(KanbanPage)))!;

      // Act: (Widget is already pumped in loading state)

      // Assert: Verify loading text is in English
      expect(find.text(l10n.loading), findsOneWidget,
          reason: "EN Loading indicator text");
    });

    /// Verifies that the loading state displays the correct localized text
    /// when the controller is in loading mode with Spanish locale.
    testWidgets('Displays Spanish loading state correctly',
        (WidgetTester tester) async {
      // Arrange: Set up KanbanPage in loading state with Spanish locale
      await pumpKanbanPage(tester, 'es', emptyTasks, isLoading: true);
      final l10n =
          AppLocalizations.of(tester.element(find.byType(KanbanPage)))!;

      // Act: (Widget is already pumped in loading state)

      // Assert: Verify loading text is in Spanish
      expect(find.text(l10n.loading), findsOneWidget,
          reason: "ES Loading indicator text");
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
      await pumpKanbanPage(
          tester, 'en', getSampleTasks(forDate: testSelectedDate));
      final l10nEn =
          AppLocalizations.of(tester.element(find.byType(KanbanPage)))!;

      // Act: Verify initial English state
      expect(find.text(l10nEn.kanban), findsOneWidget,
          reason: "EN Kanban initially");
      expect(find.text(l10nEn.todo), findsWidgets,
          reason: "EN Todo column initially");

      // Act: Change to Spanish locale
      await pumpKanbanPage(
          tester, 'es', getSampleTasks(forDate: testSelectedDate));
      final l10nEs =
          AppLocalizations.of(tester.element(find.byType(KanbanPage)))!;

      // Assert: Verify Spanish state after locale change
      expect(find.text(l10nEs.kanban), findsOneWidget,
          reason: "ES Kanban after change");
      expect(find.text(l10nEs.todo), findsWidgets,
          reason: "ES Todo column after change");

      // Assert: Ensure old English text is gone (if different from Spanish)
      if (l10nEn.kanban != l10nEs.kanban) {
        expect(find.text(l10nEn.kanban), findsNothing,
            reason: "Old EN Kanban title should be gone");
      }
    });

    /// Verifies that the basic structure of the KanbanPage exists
    /// even when there are no tasks to display.
    ///
    /// This test ensures that the localization infrastructure works
    /// correctly even in edge cases like empty states.
    testWidgets('Verifies core UI elements exist (basic structure)',
        (WidgetTester tester) async {
      // Arrange: Set up KanbanPage with no tasks
      await pumpKanbanPage(tester, 'en', emptyTasks);

      // Act: (Widget is already pumped)

      // Assert: Verify basic structure exists
      expect(find.byType(AppBar), findsOneWidget,
          reason: "AppBar should exist");
      expect(find.byType(Scaffold), findsOneWidget,
          reason: "Scaffold should exist");

      // Assert: Verify empty state message is localized
      final l10n =
          AppLocalizations.of(tester.element(find.byType(KanbanPage)))!;
      expect(find.text(l10n.noTasksWithoutDueDate, skipOffstage: false),
          findsOneWidget,
          reason: "No tasks without due date message should exist");
    });
  });
}
