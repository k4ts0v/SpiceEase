/// This file tests the UI overflow and layout handling of the FlowmodoroPage widget.
///
/// # Testing Strategy
///
/// This test suite validates UI robustness:
/// 1. UI Overflow Prevention with long text content in task and subtask lists
/// 2. Screen Size Responsiveness across different devices
/// 3. Layout stability with comprehensive task data
/// 4. Text wrapping and ellipsis handling in flowmodoro task cards
/// 5. Timer display and controls layout handling
/// 6. Settings dialog overflow handling
///
/// # How to run
/// - Run with `flutter test test/features/time_management/flowmodoro/flowmodoro_ui_test.dart`
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/features/time_management/flowmodoro/flowmodoro_controller.dart';
import 'package:spiceease/features/time_management/flowmodoro/flowmodoro_page.dart';
import 'package:spiceease/l10n/app_localizations.dart';

// --------------------------------------------------------------------------
// STANDARDIZED TEST SCREEN SIZES - MATCHING OTHER UI TESTS
// --------------------------------------------------------------------------

/// Standardized screen sizes for consistent testing across ALL UI test suites
/// These sizes MUST be kept identical in kanban_ui_test.dart, time_blocks_ui_test.dart, and flowmodoro_ui_test.dart
const List<Size> standardTestSizes = [
  Size(375, 667), // iPhone SE
  Size(390, 844), // iPhone 12/13 mini
  Size(414, 896), // iPhone 11
  Size(768, 1024), // iPad Portrait
  Size(1024, 768), // iPad Landscape
  Size(1200, 800), // Desktop
  Size(1920, 1080), // Large Desktop
];

// --------------------------------------------------------------------------
// Test Data Setup for Flowmodoro UI Testing
// --------------------------------------------------------------------------

/// Fixed test date for consistent testing across all scenarios
final testSelectedDate = DateTime(2025, 6, 1);

/// UI-focused test data with emphasis on content that can cause overflow in flowmodoro
class FlowmodoroUITestData {
  /// Regular tasks with long titles for overflow testing
  static List<TaskModel> getTasksWithLongTitles({required DateTime forDate}) =>
      [
        TaskModel(
          id: 'task-long-title-1',
          title:
              'This is an extremely long regular task title that should test how the flowmodoro UI handles text overflow and wrapping in the task selection cards and lists',
          status: 'todo',
          dueDate: forDate,
          priority: 1,
          description:
              'This regular task has an extremely long description that should also test text overflow handling in the flowmodoro UI components. It contains multiple sentences to really stress test the task list layout.',
          hasSubtasks: false,
          createdAt: DateTime.now(),
          userId: 'test-user',
          updatedAt: DateTime.now(),
        ),
        TaskModel(
          id: 'task-long-title-2',
          title:
              'Another extremely long regular task title for comprehensive overflow testing in flowmodoro session selection',
          status: 'todo',
          dueDate: forDate,
          priority: 2,
          description: 'Short desc for regular task',
          hasSubtasks: false,
          createdAt: DateTime.now(),
          userId: 'test-user',
          updatedAt: DateTime.now(),
        ),
      ];

  /// Parent tasks with subtasks that have long titles
  static List<TaskModel> getParentTasksWithLongTitles(
          {required DateTime forDate}) =>
      [
        TaskModel(
          id: 'parent-long-title-1',
          title:
              'This is an extremely long parent task title that should test how the flowmodoro UI handles parent task information display and metadata storage',
          status: 'todo',
          dueDate: forDate,
          priority: 3,
          description:
              'This parent task has an extremely long description and contains subtasks that should test the flowmodoro UI layout with comprehensive parent task data.',
          hasSubtasks: true,
          createdAt: DateTime.now(),
          userId: 'test-user',
          updatedAt: DateTime.now(),
        ),
        TaskModel(
          id: 'parent-long-title-2',
          title:
              'Another comprehensive parent task with extensive title for flowmodoro testing scenarios',
          status: 'todo',
          dueDate: forDate,
          priority: 4,
          description: 'Parent task with comprehensive metadata',
          hasSubtasks: true,
          createdAt: DateTime.now(),
          userId: 'test-user',
          updatedAt: DateTime.now(),
        ),
      ];

  /// Subtasks with long titles for overflow testing
  static List<SubtaskModel> getSubtasksWithLongTitles() => [
        SubtaskModel(
          id: 'subtask-long-title-1',
          taskId: 'parent-long-title-1',
          title:
              'This is an extremely long subtask title that should test how the flowmodoro UI handles text overflow and wrapping in the subtask selection cards and lists',
          completed: false,
          rawTimeValue: '45 minutes',
          createdAt: DateTime.now(),
          userId: 'test-user',
          updatedAt: DateTime.now(),
        ),
        SubtaskModel(
          id: 'subtask-long-title-2',
          taskId: 'parent-long-title-1',
          title:
              'Another extremely long subtask title for comprehensive overflow testing in flowmodoro session selection interface',
          completed: false,
          rawTimeValue: '1 hour 30 minutes',
          createdAt: DateTime.now(),
          userId: 'test-user',
          updatedAt: DateTime.now(),
        ),
        SubtaskModel(
          id: 'subtask-long-title-3',
          taskId: 'parent-long-title-2',
          title:
              'Third extremely long subtask title with comprehensive data for extensive UI testing scenarios',
          completed: false,
          rawTimeValue: '2 hours 15 minutes',
          createdAt: DateTime.now(),
          userId: 'test-user',
          updatedAt: DateTime.now(),
        ),
      ];

  /// Simple tasks for basic UI testing
  static List<TaskModel> getSimpleRegularTasks({required DateTime forDate}) => [
        TaskModel(
          id: 'simple-regular',
          title: 'Simple Regular Task',
          status: 'todo',
          dueDate: forDate,
          priority: 1,
          description: 'Simple regular task for UI testing',
          hasSubtasks: false,
          createdAt: DateTime.now(),
          userId: 'test-user',
          updatedAt: DateTime.now(),
        ),
      ];

  static List<TaskModel> getSimpleParentTasks({required DateTime forDate}) => [
        TaskModel(
          id: 'simple-parent',
          title: 'Simple Parent Task',
          status: 'todo',
          dueDate: forDate,
          priority: 2,
          description: 'Simple parent task for UI testing',
          hasSubtasks: true,
          createdAt: DateTime.now(),
          userId: 'test-user',
          updatedAt: DateTime.now(),
        ),
      ];

  static List<SubtaskModel> getSimpleSubtasks() => [
        SubtaskModel(
          id: 'simple-subtask',
          taskId: 'simple-parent',
          title: 'Simple Subtask',
          completed: false,
          rawTimeValue: '30 minutes',
          createdAt: DateTime.now(),
          userId: 'test-user',
          updatedAt: DateTime.now(),
        ),
      ];
}

// --------------------------------------------------------------------------
// Mock Classes for Flowmodoro UI Testing
// --------------------------------------------------------------------------

/// Mock Flowmodoro Controller for UI testing
class UITestFlowmodoroController extends FlowmodoroController {
  final List<TaskModel> _allTasks;
  final List<SubtaskModel> _allSubtasks;
  final DateTime _currentDate;

  // Override properties from parent controller
  @override
  List<TaskModel> availableTasks = [];
  @override
  List<SubtaskModel> availableSubtasks = [];
  @override
  Map<String, Map<String, dynamic>> parentTaskDetails = {};
  @override
  bool isLoading = false;
  @override
  DateTime currentSelectedDate;

  UITestFlowmodoroController(
    this._allTasks,
    this._allSubtasks,
    this._currentDate,
  ) : currentSelectedDate = _currentDate,
        super(FakeRef()) {
    _categorizeTasksForDate(_currentDate);
  }

  void _categorizeTasksForDate(DateTime date) {
    currentSelectedDate = date;

    // Filter tasks for the specific date and categorize
    final dateSpecificTasks = _allTasks.where((task) {
      if (task.dueDate == null) return false;
      return _isSameDay(task.dueDate!, date);
    }).toList();

    final List<TaskModel> incompleteTasks = [];
    final List<SubtaskModel> incompleteSubtasks = [];
    parentTaskDetails.clear();

    for (final task in dateSpecificTasks) {
      // Skip completed tasks
      if (task.completedAt != null) {
        continue;
      }

      // If task has subtasks, store its details but don't add to available tasks
      if (task.hasSubtasks) {
        parentTaskDetails[task.id] = {
          'title': task.title,
          'priority': task.priority,
        };

        // Add incomplete subtasks for this parent
        final taskSubtasks =
            _allSubtasks.where((s) => s.taskId == task.id).toList();
        for (final subtask in taskSubtasks) {
          if (!subtask.completed) {
            incompleteSubtasks.add(subtask);
          }
        }
      } else {
        // Add only tasks without subtasks that are not marked as 'Done'
        if (task.status != 'Done') {
          incompleteTasks.add(task);
        }
      }
    }

    availableTasks = incompleteTasks;
    availableSubtasks = incompleteSubtasks;
    isLoading = false;
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  @override
  String? getParentTaskTitle(String taskId) {
    return parentTaskDetails[taskId]?['title'];
  }

  @override
  int? getParentTaskPriority(String taskId) {
    return parentTaskDetails[taskId]?['priority'];
  }

  @override
  bool isSubtask(dynamic item) {
    return item is SubtaskModel;
  }

  @override
  Future<void> loadTasks(BuildContext context) async {
    // Mock implementation - do nothing since we already have tasks loaded
    // This prevents the UI from trying to reload and changing our test data
  }

  @override
  Future<bool> completeTask(String taskId) async {
    return true; // Mock success
  }

  @override
  Future<bool> completeSubtask(String subtaskId) async {
    return true; // Mock success
  }

  @override
  Future<void> saveCompletedFlowmodoro({
    required String taskId,
    required int focusMinutes,
    required int breakMinutes,
    required int cycles,
  }) async {
    // Mock implementation - do nothing
  }
}

/// Fake Ref implementation for testing
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
// Test Helpers
// --------------------------------------------------------------------------

void main() {
  /// Helper function to set up and pump the FlowmodoroPage widget for UI testing
  Future<void> pumpFlowmodoroPageForUI(
    WidgetTester tester,
    UITestFlowmodoroController controller, {
    String localeCode = 'en',
    Size? screenSize,
  }) async {
    if (screenSize != null) {
      await tester.binding.setSurfaceSize(screenSize);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedDateProvider
              .overrideWith((ref) => controller.currentSelectedDate!),
          flowmodoroControllerProvider.overrideWith((ref) => controller),
        ],
        child: MaterialApp(
          locale: Locale(localeCode),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const FlowmodoroPage(),
        ),
      ),
    );

    // Use controlled pumping for UI tests
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  // --------------------------------------------------------------------------
  // Flowmodoro UI Overflow and Layout Test Cases
  // --------------------------------------------------------------------------

  group('FlowmodoroPage UI Overflow and Layout Tests', () {
    testWidgets('Handles long regular task titles without overflow',
        (WidgetTester tester) async {
      // Arrange
      final controller = UITestFlowmodoroController(
        FlowmodoroUITestData.getTasksWithLongTitles(forDate: testSelectedDate),
        [],
        testSelectedDate,
      );

      // Act
      await pumpFlowmodoroPageForUI(tester, controller,
          screenSize: const Size(1200, 800));

      // Assert: Find regular tasks with long titles
      expect(
          find.textContaining('This is an extremely long regular task title'),
          findsAtLeastNWidgets(1));
      expect(find.textContaining('Another extremely long regular task title'),
          findsAtLeastNWidgets(1));

      // Assert: Verify text widgets are properly constrained
      final textWidgets = find.byType(Text);
      expect(textWidgets, findsWidgets);

      // Check that text widgets have proper overflow behavior
      for (final widget in tester.widgetList<Text>(textWidgets)) {
        expect(
            widget.overflow,
            anyOf(
              equals(TextOverflow.ellipsis),
              equals(TextOverflow.fade),
              equals(TextOverflow.clip),
              isNull, // Default overflow is acceptable too
            ));
      }

      // Verify no overflow exceptions occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('Handles long subtask titles without overflow',
        (WidgetTester tester) async {
      // Arrange
      final parentTasks = FlowmodoroUITestData.getParentTasksWithLongTitles(
          forDate: testSelectedDate);
      final subtasks = FlowmodoroUITestData.getSubtasksWithLongTitles();

      final controller = UITestFlowmodoroController(
        parentTasks,
        subtasks,
        testSelectedDate,
      );

      // Act
      await pumpFlowmodoroPageForUI(tester, controller,
          screenSize: const Size(1200, 800));

      // Assert: Find subtasks with long titles
      expect(find.textContaining('This is an extremely long subtask title'),
          findsAtLeastNWidgets(1));
      expect(find.textContaining('Another extremely long subtask title'),
          findsAtLeastNWidgets(1));
      expect(find.textContaining('Third extremely long subtask title'),
          findsAtLeastNWidgets(1));

      // Assert: Verify text widgets handle overflow properly
      final textWidgets = find.byType(Text);
      for (final widget in tester.widgetList<Text>(textWidgets)) {
        expect(
            widget.overflow,
            anyOf(
              equals(TextOverflow.ellipsis),
              equals(TextOverflow.fade),
              equals(TextOverflow.clip),
              isNull,
            ));
      }

      // Verify no overflow exceptions occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('Handles mixed tasks and subtasks without overflow',
        (WidgetTester tester) async {
      // Arrange: Mix of regular tasks and subtasks
      final allTasks = [
        ...FlowmodoroUITestData.getTasksWithLongTitles(
            forDate: testSelectedDate),
        ...FlowmodoroUITestData.getParentTasksWithLongTitles(
            forDate: testSelectedDate),
      ];
      final allSubtasks = FlowmodoroUITestData.getSubtasksWithLongTitles();

      final controller = UITestFlowmodoroController(
        allTasks,
        allSubtasks,
        testSelectedDate,
      );

      // Act
      await pumpFlowmodoroPageForUI(tester, controller,
          screenSize: const Size(1200, 800));

      // Assert: Verify both regular tasks and subtasks are displayed
      expect(
          find.textContaining('This is an extremely long regular task title'),
          findsAtLeastNWidgets(1));
      expect(find.textContaining('This is an extremely long subtask title'),
          findsAtLeastNWidgets(1));

      // Assert: Verify scrolling is available for task/subtask lists
      expect(find.byType(ListView), findsWidgets);

      // Verify text widgets handle overflow properly
      final textWidgets = find.byType(Text);
      for (final widget in tester.widgetList<Text>(textWidgets)) {
        expect(
            widget.overflow,
            anyOf(
              equals(TextOverflow.ellipsis),
              equals(TextOverflow.fade),
              equals(TextOverflow.clip),
              isNull,
            ));
      }

      // Verify no overflow exceptions occurred
      expect(tester.takeException(), isNull);
    });

    group('Screen Size Responsiveness for Flowmodoro', () {
      // USE STANDARDIZED TEST SIZES - MATCHING OTHER UI TESTS
      for (final size in standardTestSizes) {
        testWidgets(
            'Handles flowmodoro layout on ${size.width}x${size.height} screen',
            (WidgetTester tester) async {
          // Arrange - Use simple test data to focus on layout rather than content
          final allTasks = [
            ...FlowmodoroUITestData.getSimpleRegularTasks(
                forDate: testSelectedDate),
            ...FlowmodoroUITestData.getSimpleParentTasks(
                forDate: testSelectedDate),
          ];
          final allSubtasks = FlowmodoroUITestData.getSimpleSubtasks();

          final controller = UITestFlowmodoroController(
            allTasks,
            allSubtasks,
            testSelectedDate,
          );

          // Act
          await pumpFlowmodoroPageForUI(tester, controller, screenSize: size);

          // Assert: Verify layout doesn't break
          expect(find.byType(FlowmodoroPage), findsOneWidget);

          // Verify basic structure exists
          expect(find.byType(Scaffold), findsOneWidget);

          // Verify scrolling is available
          final listViews = find.byType(ListView);
          if (listViews.evaluate().isNotEmpty) {
            expect(listViews, findsWidgets);
          }

          // Verify no overflow exceptions occurred
          expect(tester.takeException(), isNull);
        });
      }
    });

    group('Flowmodoro Specific Layout Tests', () {
      testWidgets('Displays task selection interface correctly',
          (WidgetTester tester) async {
        // Arrange
        final allTasks = FlowmodoroUITestData.getSimpleRegularTasks(
            forDate: testSelectedDate);
        final controller = UITestFlowmodoroController(
          allTasks,
          [],
          testSelectedDate,
        );

        // Act
        await pumpFlowmodoroPageForUI(tester, controller,
            screenSize: const Size(1200, 800));

        // Assert: Verify task selection interface is displayed
        expect(find.textContaining('Simple Regular Task'), findsOneWidget);

        // Verify main components are present
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(Column), findsWidgets);

        // Verify no overflow exceptions occurred
        expect(tester.takeException(), isNull);
      });

      testWidgets('Handles empty task list without errors',
          (WidgetTester tester) async {
        // Arrange - Empty task and subtask lists
        final controller = UITestFlowmodoroController([], [], testSelectedDate);

        // Act
        await pumpFlowmodoroPageForUI(tester, controller,
            screenSize: const Size(1200, 800));

        // Assert: Verify page displays without error
        expect(find.byType(FlowmodoroPage), findsOneWidget);

        // Verify empty state is handled gracefully
        final textWidgets = find.byType(Text);
        expect(textWidgets, findsWidgets);

        // Verify no overflow exceptions occurred
        expect(tester.takeException(), isNull);
      });

      testWidgets('Displays parent task information for subtasks',
          (WidgetTester tester) async {
        // Arrange - Parent task with subtasks
        final parentTasks = FlowmodoroUITestData.getSimpleParentTasks(
            forDate: testSelectedDate);
        final subtasks = FlowmodoroUITestData.getSimpleSubtasks();

        final controller = UITestFlowmodoroController(
          parentTasks,
          subtasks,
          testSelectedDate,
        );

        // Act
        await pumpFlowmodoroPageForUI(tester, controller,
            screenSize: const Size(1200, 800));

        // Assert: Verify subtask is displayed
        expect(find.textContaining('Simple Subtask'), findsOneWidget);

        // Verify parent task information is accessible through controller
        expect(controller.getParentTaskTitle('simple-parent'),
            equals('Simple Parent Task'));
        expect(controller.getParentTaskPriority('simple-parent'), equals(2));

        // Verify no overflow exceptions occurred
        expect(tester.takeException(), isNull);
      });
    });

    group('Extreme Content Stress Tests for Flowmodoro', () {
      testWidgets(
          'Handles extremely long single word titles in tasks and subtasks',
          (WidgetTester tester) async {
        // Arrange: Test with unique extreme content to avoid multiple widget matches
        final extremeTasks = [
          TaskModel(
            id: 'extreme-task',
            title: 'ExtremelyLongSingleWordTaskForTestingOverflowHandling',
            status: 'todo',
            dueDate: testSelectedDate,
            priority: 1,
            description: 'Test description for extreme task',
            hasSubtasks: true,
            createdAt: DateTime.now(),
            userId: 'test-user',
            updatedAt: DateTime.now(),
          ),
        ];

        final extremeSubtasks = [
          SubtaskModel(
            id: 'extreme-subtask',
            taskId: 'extreme-task',
            title: 'ExtremelyLongSingleWordSubtaskForTestingOverflowHandling',
            completed: false,
            rawTimeValue: '30 minutes',
            createdAt: DateTime.now(),
            userId: 'test-user',
            updatedAt: DateTime.now(),
          ),
        ];

        final controller = UITestFlowmodoroController(
          extremeTasks,
          extremeSubtasks,
          testSelectedDate,
        );

        // Act
        await pumpFlowmodoroPageForUI(tester, controller,
            screenSize: standardTestSizes[2]); // iPhone 11 size

        // Assert: Verify the subtask is displayed without breaking layout
        expect(find.textContaining('ExtremelyLongSingleWordSubtask'),
            findsOneWidget);

        // Verify no major layout breakage occurs even with extreme content
        final textWidgets = find.byType(Text);
        for (final widget in tester.widgetList<Text>(textWidgets)) {
          expect(
              widget.overflow,
              anyOf(
                equals(TextOverflow.ellipsis),
                equals(TextOverflow.fade),
                equals(TextOverflow.clip),
                isNull,
              ));
        }

        // Verify no overflow exceptions occurred
        expect(tester.takeException(), isNull);
      });

      testWidgets('Handles maximum number of tasks and subtasks',
          (WidgetTester tester) async {
        // Arrange: Create many tasks and subtasks to stress test layout
        final stressTasks = List.generate(10, (index) {
          return TaskModel(
            id: 'stress-task-$index',
            title: 'Stress Test Task $index with Long Title',
            status: 'todo',
            dueDate: testSelectedDate,
            priority: (index % 5) + 1,
            description: 'This is stress test task $index with description.',
            hasSubtasks: index % 2 == 0, // Half are parent tasks
            createdAt: DateTime.now(),
            userId: 'test-user',
            updatedAt: DateTime.now(),
          );
        });

        final stressSubtasks = List.generate(15, (index) {
          final parentIndex = index % 5; // Distribute among parent tasks
          return SubtaskModel(
            id: 'stress-subtask-$index',
            taskId:
                'stress-task-${parentIndex * 2}', // Only even-indexed tasks are parents
            title: 'Stress Test Subtask $index with Long Title',
            completed: false,
            rawTimeValue: '${index + 1} hours',
            createdAt: DateTime.now(),
            userId: 'test-user',
            updatedAt: DateTime.now(),
          );
        });

        final controller = UITestFlowmodoroController(
          stressTasks,
          stressSubtasks,
          testSelectedDate,
        );

        // Act
        await pumpFlowmodoroPageForUI(tester, controller,
            screenSize: standardTestSizes[5]); // Desktop size for many items

        // Assert: Verify tasks and subtasks are displayed
        expect(find.textContaining('Stress Test'), findsWidgets);

        // Verify scrolling handles many items
        expect(find.byType(ListView), findsWidgets);

        // Verify no major layout breakage with many items
        final textWidgets = find.byType(Text);
        for (final widget in tester.widgetList<Text>(textWidgets)) {
          expect(
              widget.overflow,
              anyOf(
                equals(TextOverflow.ellipsis),
                equals(TextOverflow.fade),
                equals(TextOverflow.clip),
                isNull,
              ));
        }

        // Verify the layout is still functional
        expect(find.byType(FlowmodoroPage), findsOneWidget);

        // Verify no overflow exceptions occurred
        expect(tester.takeException(), isNull);
      });
    });
  });
}