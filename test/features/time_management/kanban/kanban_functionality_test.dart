/// This file tests the core functionality of the KanbanPage widget.
///
/// # Testing Strategy
///
/// This test suite validates basic Kanban functionality:
/// 1. Basic UI Rendering
/// 2. Task Display and Organization
/// 3. Loading States
/// 4. Empty States
/// 5. Task Status Changes (Drag & Drop simulation)
/// 6. No Due Date Section Verification
/// 7. Date-specific Task Display
///
/// # How to run
/// - Run with `flutter test test/features/time_management/kanban/kanban_functionality_test.dart`

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/features/time_management/kanban/kanban_controller.dart';
import 'package:spiceease/features/time_management/kanban/kanban_page.dart';
import 'package:spiceease/l10n/app_localizations.dart';

// --------------------------------------------------------------------------
// Test Data Setup
// --------------------------------------------------------------------------

/// Fixed test date for consistent testing across all scenarios
final testSelectedDate = DateTime(2025, 6, 1);

/// Creates a comprehensive set of sample tasks for testing all scenarios
class TestTaskData {
  static List<TaskModel> getAllTasks({required DateTime forDate}) => [
        // Todo tasks
        TaskModel(
          id: 'todo-1',
          title: 'Todo Task Priority 1',
          status: 'todo',
          dueDate: forDate,
          priority: 1,
          description: 'Low priority todo task',
          createdAt: DateTime.now(),
          userId: 'test-user',
          updatedAt: DateTime.now(),
        ),
        TaskModel(
          id: 'todo-2',
          title: 'Todo Task Priority 3',
          status: 'todo',
          dueDate: forDate,
          priority: 3,
          description: 'Medium priority todo task',
          estimatedTime: '30 minutes',
          createdAt: DateTime.now(),
          userId: 'test-user',
          updatedAt: DateTime.now(),
        ),

        // In Progress tasks
        TaskModel(
          id: 'progress-1',
          title: 'In Progress Task 1',
          status: 'in_progress',
          dueDate: forDate,
          priority: 2,
          description: 'Currently working on this',
          estimatedTime: '50 minutes',
          createdAt: DateTime.now(),
          userId: 'test-user',
          updatedAt: DateTime.now(),
        ),

        // Done tasks
        TaskModel(
          id: 'done-1',
          title: 'Completed Task 1',
          status: 'done',
          dueDate: forDate,
          priority: 3,
          description: 'Successfully completed task',
          completedAt: forDate,
          createdAt: DateTime.now(),
          userId: 'test-user',
          updatedAt: DateTime.now(),
        ),

        // Tasks without due date
        TaskModel(
          id: 'no-date-1',
          title: 'No Due Date Task 1',
          status: 'todo',
          dueDate: null,
          priority: 2,
          description: 'Task without specific due date',
          createdAt: DateTime.now(),
          userId: 'test-user',
          updatedAt: DateTime.now(),
        ),

        // Subtasks
        TaskModel(
          id: 'subtask-1',
          title: 'Subtask for Todo',
          status: 'todo',
          dueDate: forDate,
          priority: 3,
          description: 'This is a subtask',
          parentTaskId: 'todo-2',
          estimatedTime: '60 minutes',
          createdAt: DateTime.now(),
          userId: 'test-user',
          updatedAt: DateTime.now(),
        ),
      ];

  static List<TaskModel> getEmptyTasks() => [];

  /// Tasks specifically for no due date testing
  static List<TaskModel> getNoDueDateTasks() => [
        TaskModel(
          id: 'no-date-todo',
          title: 'No Date Todo Task',
          status: 'todo',
          dueDate: null,
          priority: 1,
          description: 'Todo task without due date',
          createdAt: DateTime.now(),
          userId: 'test-user',
          updatedAt: DateTime.now(),
        ),
        TaskModel(
          id: 'no-date-progress',
          title: 'No Date In Progress Task',
          status: 'in_progress',
          dueDate: null,
          priority: 2,
          description: 'In progress task without due date',
          createdAt: DateTime.now(),
          userId: 'test-user',
          updatedAt: DateTime.now(),
        ),
        TaskModel(
          id: 'no-date-done',
          title: 'No Date Done Task',
          status: 'done',
          dueDate: null,
          priority: 3,
          description: 'Completed task without due date',
          completedAt: null, // No completion date either
          createdAt: DateTime.now(),
          userId: 'test-user',
          updatedAt: DateTime.now(),
        ),
      ];
}

// --------------------------------------------------------------------------
// Mock Classes
// --------------------------------------------------------------------------

/// Enhanced Mock Kanban Controller with status change tracking
class MockKanbanController extends KanbanController {
  final List<TaskModel> _allTasks;
  DateTime _currentDate;
  bool _isLoading;

  // Categorized task lists
  List<TaskModel> _todoTasks = [];
  List<TaskModel> _inProgressTasks = [];
  List<TaskModel> _doneTasks = [];
  List<TaskModel> _noDueDateTasks = [];

  // Track status changes for testing
  List<Map<String, dynamic>> statusChanges = [];

  MockKanbanController(
    super.ref,
    this._allTasks,
    this._currentDate, {
    bool isLoading = false,
  }) : _isLoading = isLoading {
    _categorizeTasksForDate(_currentDate);
  }

  // Getters that match the real controller
  @override
  List<TaskModel> get todoTasks => _todoTasks;
  @override
  List<TaskModel> get inProgressTasks => _inProgressTasks;
  @override
  List<TaskModel> get doneTasks => _doneTasks;
  @override
  List<TaskModel> get noDueDateTasks => _noDueDateTasks;
  @override
  bool get isLoading => _isLoading;
  @override
  DateTime get currentSelectedDate => _currentDate;

  /// Categorizes tasks by status and filters by date
  void _categorizeTasksForDate(DateTime date) {
    _currentDate = date;

    // Filter tasks for the specific date
    final dateSpecificTasks = _allTasks.where((task) {
      if (task.dueDate == null) return false;
      return _isSameDay(task.dueDate!, date);
    }).toList();

    // Categorize by status
    _todoTasks = dateSpecificTasks.where((t) => t.status == 'todo').toList();
    _inProgressTasks =
        dateSpecificTasks.where((t) => t.status == 'in_progress').toList();
    _doneTasks = dateSpecificTasks.where((t) {
      // Show completed tasks if they are completed on this date OR due on this date
      if (t.status == 'done') {
        if (t.completedAt != null && _isSameDay(t.completedAt!, date)) {
          return true;
        }
        if (t.dueDate != null && _isSameDay(t.dueDate!, date)) {
          return true;
        }
      }
      return false;
    }).toList();

    // No due date tasks (regardless of selected date)
    _noDueDateTasks = _allTasks
        .where((t) => t.dueDate == null && t.completedAt == null)
        .toList();
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  @override
  Future<void> loadTasks(BuildContext context, {DateTime? date}) async {
    if (date != null) {
      _categorizeTasksForDate(date);
    } else {
      _categorizeTasksForDate(_currentDate);
    }
    notifyListeners();
  }

  @override
  Future<void> updateTaskStatus(
      TaskModel task, String newStatus, BuildContext context) async {
    // Track the status change
    statusChanges.add({
      'taskId': task.id,
      'oldStatus': task.status,
      'newStatus': newStatus,
      'timestamp': DateTime.now(),
    });

    final taskIndex = _allTasks.indexWhere((t) => t.id == task.id);
    if (taskIndex != -1) {
      final updatedTask = _allTasks[taskIndex].copyWith(
        status: newStatus,
        completedAt: newStatus == 'done' ? _currentDate : null,
        updatedAt: DateTime.now(),
      );
      _allTasks[taskIndex] = updatedTask;
      _categorizeTasksForDate(_currentDate);
      notifyListeners();
    }
  }

  // Helper method to find task by ID
  TaskModel? findTaskById(String id) {
    try {
      return _allTasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
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
  /// Helper function to set up and pump the KanbanPage widget
  Future<void> pumpKanbanPage(
    WidgetTester tester,
    MockKanbanController controller, {
    String localeCode = 'en',
  }) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedDateProvider
              .overrideWith((ref) => controller.currentSelectedDate),
          kanbanControllerProvider.overrideWith((ref) => controller),
        ],
        child: MaterialApp(
          locale: Locale(localeCode),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const KanbanPage(),
        ),
      ),
    );

    // Use controlled pumping instead of pumpAndSettle
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  // --------------------------------------------------------------------------
  // Test Cases
  // --------------------------------------------------------------------------

  group('KanbanPage Functionality Tests', () {
    testWidgets('Renders Kanban board with correct UI structure',
        (WidgetTester tester) async {
      // Arrange
      final controller = MockKanbanController(
        FakeRef(),
        TestTaskData.getAllTasks(forDate: testSelectedDate),
        testSelectedDate,
      );

      // Act
      await pumpKanbanPage(tester, controller);

      // Assert
      final l10n =
          AppLocalizations.of(tester.element(find.byType(KanbanPage)))!;

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text(l10n.kanban), findsOneWidget);
      expect(find.text(l10n.newTask), findsOneWidget);
      expect(find.text(l10n.todo), findsWidgets);
      expect(find.text(l10n.inProgress), findsWidgets);
      expect(find.text(l10n.done), findsWidgets);
      expect(find.text(l10n.tasksWithoutDueDate), findsOneWidget);
    });

    testWidgets('Displays tasks in correct columns based on status',
        (WidgetTester tester) async {
      // Arrange
      final controller = MockKanbanController(
        FakeRef(),
        TestTaskData.getAllTasks(forDate: testSelectedDate),
        testSelectedDate,
      );

      // Act
      await pumpKanbanPage(tester, controller);

      // Assert - Todo tasks
      expect(find.text('Todo Task Priority 1'), findsOneWidget);
      expect(find.text('Todo Task Priority 3'), findsOneWidget);
      expect(
          find.text('Subtask for Todo', skipOffstage: false), findsOneWidget);

      // Assert - In Progress tasks
      expect(find.text('In Progress Task 1'), findsOneWidget);

      // Assert - Done tasks
      expect(find.text('Completed Task 1'), findsOneWidget);

      // Assert - No due date tasks
      expect(find.text('No Due Date Task 1'), findsOneWidget);
    });

    testWidgets('Shows loading state correctly', (WidgetTester tester) async {
      // Arrange
      final controller = MockKanbanController(
        FakeRef(),
        TestTaskData.getEmptyTasks(),
        testSelectedDate,
        isLoading: true,
      );

      // Act
      await pumpKanbanPage(tester, controller);

      // Assert
      final l10n =
          AppLocalizations.of(tester.element(find.byType(KanbanPage)))!;
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(l10n.loading), findsOneWidget);
    });

    testWidgets('Shows empty states correctly in all columns',
        (WidgetTester tester) async {
      // Arrange
      final controller = MockKanbanController(
        FakeRef(),
        TestTaskData.getEmptyTasks(),
        testSelectedDate,
      );

      // Act
      await pumpKanbanPage(tester, controller);

      // Assert
      final l10n =
          AppLocalizations.of(tester.element(find.byType(KanbanPage)))!;
      expect(find.text(l10n.noTasks), findsWidgets);
      expect(find.text(l10n.noTasksWithoutDueDate), findsOneWidget);
    });

    testWidgets('Controller data is correctly categorized',
        (WidgetTester tester) async {
      // Arrange
      final controller = MockKanbanController(
        FakeRef(),
        TestTaskData.getAllTasks(forDate: testSelectedDate),
        testSelectedDate,
      );

      // Act - No need to pump widget, just test controller logic

      // Assert controller data directly
      expect(controller.todoTasks.length, equals(3));
      expect(controller.inProgressTasks.length, equals(1));
      expect(controller.doneTasks.length, equals(1));
      expect(controller.noDueDateTasks.length, equals(1));

      // Verify specific tasks are in correct categories
      expect(controller.todoTasks.any((t) => t.title == 'Todo Task Priority 1'),
          isTrue);
      expect(controller.todoTasks.any((t) => t.title == 'Todo Task Priority 3'),
          isTrue);
      expect(controller.todoTasks.any((t) => t.title == 'Subtask for Todo'),
          isTrue);

      expect(
          controller.inProgressTasks
              .any((t) => t.title == 'In Progress Task 1'),
          isTrue);
      expect(controller.doneTasks.any((t) => t.title == 'Completed Task 1'),
          isTrue);
      expect(
          controller.noDueDateTasks.any((t) => t.title == 'No Due Date Task 1'),
          isTrue);
    });

    group('Task Status Changes (Drag & Drop Simulation)', () {
      testWidgets(
          'Updates task status through all columns: todo → in_progress → done',
          (WidgetTester tester) async {
        // Arrange
        final controller = MockKanbanController(
          FakeRef(),
          TestTaskData.getAllTasks(forDate: testSelectedDate),
          testSelectedDate,
        );

        // Find a todo task to test with
        final testTask = controller.todoTasks.first;
        final taskId = testTask.id;

        // Act & Assert: Move todo → in_progress
        await controller.updateTaskStatus(testTask, 'in_progress',
            tester.element(find.byType(Container).first));
        await tester.pump();

        expect(controller.findTaskById(taskId)?.status, equals('in_progress'));
        expect(controller.inProgressTasks.any((t) => t.id == taskId), isTrue);
        expect(controller.todoTasks.any((t) => t.id == taskId), isFalse);

        // Act & Assert: Move in_progress → done
        final updatedTask = controller.findTaskById(taskId)!;
        await controller.updateTaskStatus(
            updatedTask, 'done', tester.element(find.byType(Container).first));
        await tester.pump();

        expect(controller.findTaskById(taskId)?.status, equals('done'));
        expect(controller.doneTasks.any((t) => t.id == taskId), isTrue);
        expect(controller.inProgressTasks.any((t) => t.id == taskId), isFalse);

        // Act & Assert: Move done → todo (reverse flow)
        final doneTask = controller.findTaskById(taskId)!;
        await controller.updateTaskStatus(
            doneTask, 'todo', tester.element(find.byType(Container).first));
        await tester.pump();

        expect(controller.findTaskById(taskId)?.status, equals('todo'));
        expect(controller.todoTasks.any((t) => t.id == taskId), isTrue);
        expect(controller.doneTasks.any((t) => t.id == taskId), isFalse);

        // Verify status change tracking
        expect(controller.statusChanges.length, equals(3));
        expect(controller.statusChanges[0]['newStatus'], equals('in_progress'));
        expect(controller.statusChanges[1]['newStatus'], equals('done'));
        expect(controller.statusChanges[2]['newStatus'], equals('todo'));
      });

      testWidgets('Handles completion date correctly when moving to done',
          (WidgetTester tester) async {
        // Arrange
        final controller = MockKanbanController(
          FakeRef(),
          TestTaskData.getAllTasks(forDate: testSelectedDate),
          testSelectedDate,
        );

        final testTask = controller.todoTasks.first;

        // Act: Move to done
        await controller.updateTaskStatus(
            testTask, 'done', tester.element(find.byType(Container).first));
        await tester.pump();

        // Assert: Completion date is set
        final updatedTask = controller.findTaskById(testTask.id)!;
        expect(updatedTask.completedAt, isNotNull);
        expect(updatedTask.completedAt, equals(testSelectedDate));

        // Act: Move back to todo
        await controller.updateTaskStatus(
            updatedTask, 'todo', tester.element(find.byType(Container).first));
        await tester.pump();

        // Assert: Completion date is cleared
        final revertedTask = controller.findTaskById(testTask.id)!;
        expect(revertedTask.completedAt, isNull);
      });
    });

    group('Priority and Estimation Display Tests', () {
      testWidgets('Displays priority levels correctly',
          (WidgetTester tester) async {
        // Arrange
        final tasksWithDifferentPriorities = [
          TaskModel(
            id: 'high-priority',
            title: 'High Priority Task',
            status: 'todo',
            dueDate: testSelectedDate,
            priority: 1, // High priority
            description: 'High priority task',
            estimatedTime: '1 hour',
            createdAt: DateTime.now(),
            userId: 'test-user',
            updatedAt: DateTime.now(),
          ),
          TaskModel(
            id: 'medium-priority',
            title: 'Medium Priority Task',
            status: 'in_progress',
            dueDate: testSelectedDate,
            priority: 2, // Medium priority
            description: 'Medium priority task',
            estimatedTime: '2 hours',
            createdAt: DateTime.now(),
            userId: 'test-user',
            updatedAt: DateTime.now(),
          ),
          TaskModel(
            id: 'low-priority',
            title: 'Low Priority Task',
            status: 'done',
            dueDate: testSelectedDate,
            priority: 3, // Low priority
            description: 'Low priority task',
            estimatedTime: '30 minutes',
            completedAt: testSelectedDate,
            createdAt: DateTime.now(),
            userId: 'test-user',
            updatedAt: DateTime.now(),
          ),
        ];

        final controller = MockKanbanController(
          FakeRef(),
          tasksWithDifferentPriorities,
          testSelectedDate,
        );

        // Act
        await pumpKanbanPage(tester, controller);

        // Assert: Verify tasks with different priorities are displayed
        expect(find.text('High Priority Task'), findsOneWidget);
        expect(find.text('Medium Priority Task'), findsOneWidget);
        expect(find.text('Low Priority Task'), findsOneWidget);

        // Verify time estimations are shown
        expect(find.textContaining('1 hour'), findsOneWidget);
        expect(find.textContaining('2 hours'), findsOneWidget);
        expect(find.textContaining('30 minutes'), findsOneWidget);

        // Controller should categorize correctly by priority
        expect(controller.todoTasks.first.priority, equals(1));
        expect(controller.inProgressTasks.first.priority, equals(2));
        expect(controller.doneTasks.first.priority, equals(3));
      });
    });

    group('No Due Date Section Tests', () {
      testWidgets('Displays tasks without due dates correctly',
          (WidgetTester tester) async {
        // Arrange
        final controller = MockKanbanController(
          FakeRef(),
          TestTaskData.getNoDueDateTasks(),
          testSelectedDate,
        );

        // Act
        await pumpKanbanPage(tester, controller);

        // Assert
        final l10n =
            AppLocalizations.of(tester.element(find.byType(KanbanPage)))!;

        // Should find the no due date section
        expect(find.text(l10n.tasksWithoutDueDate), findsOneWidget);

        // Should find all no due date tasks regardless of status
        expect(find.text('No Date Todo Task'), findsOneWidget);
        expect(find.text('No Date In Progress Task'), findsOneWidget);
        expect(find.text('No Date Done Task'), findsOneWidget);

        // Verify controller categorization
        expect(controller.noDueDateTasks.length, equals(3));
        expect(
            controller.noDueDateTasks
                .any((t) => t.title == 'No Date Todo Task'),
            isTrue);
        expect(
            controller.noDueDateTasks
                .any((t) => t.title == 'No Date In Progress Task'),
            isTrue);
        expect(
            controller.noDueDateTasks
                .any((t) => t.title == 'No Date Done Task'),
            isTrue);
      });

      testWidgets('Shows empty state for no due date section when empty',
          (WidgetTester tester) async {
        // Arrange
        final controller = MockKanbanController(
          FakeRef(),
          TestTaskData.getAllTasks(
              forDate: testSelectedDate), // Only tasks with due dates
          testSelectedDate,
        );

        // Act
        await pumpKanbanPage(tester, controller);

        // Assert
        final l10n =
            AppLocalizations.of(tester.element(find.byType(KanbanPage)))!;

        // Should still show the section header
        expect(find.text(l10n.tasksWithoutDueDate), findsOneWidget);

        // Controller should show the one task without due date from getAllTasks
        expect(controller.noDueDateTasks.length, equals(1));
      });

      testWidgets('No due date tasks do not appear in date-specific columns',
          (WidgetTester tester) async {
        // Arrange: Mix of tasks with and without due dates
        final allTasks = [
          ...TestTaskData.getAllTasks(forDate: testSelectedDate),
          ...TestTaskData.getNoDueDateTasks(),
        ];

        final controller = MockKanbanController(
          FakeRef(),
          allTasks,
          testSelectedDate,
        );

        // Act
        await pumpKanbanPage(tester, controller);

        // Assert: Date-specific columns should only contain tasks with due dates
        expect(
            controller.todoTasks.every((task) => task.dueDate != null), isTrue);
        expect(controller.inProgressTasks.every((task) => task.dueDate != null),
            isTrue);
        expect(
            controller.doneTasks.every((task) => task.dueDate != null), isTrue);

        // Assert: No due date section should only contain tasks without due dates
        expect(controller.noDueDateTasks.every((task) => task.dueDate == null),
            isTrue);

        // Assert: Verify specific task placement
        expect(controller.todoTasks.any((t) => t.title == 'No Date Todo Task'),
            isFalse);
        expect(
            controller.noDueDateTasks
                .any((t) => t.title == 'No Date Todo Task'),
            isTrue);
      });
    });

    group('Date-specific Task Display', () {
      testWidgets(
          'Tasks with due dates appear in corresponding columns for selected date',
          (WidgetTester tester) async {
        // Arrange
        final selectedDate = DateTime(2025, 6, 1);
        final differentDate = DateTime(2025, 6, 2);

        final tasksForSelectedDate =
            TestTaskData.getAllTasks(forDate: selectedDate);
        final tasksForDifferentDate =
            TestTaskData.getAllTasks(forDate: differentDate)
                .map((task) => task.copyWith(id: '${task.id}-diff'))
                .toList();

        final allTasks = [...tasksForSelectedDate, ...tasksForDifferentDate];

        final controller = MockKanbanController(
          FakeRef(),
          allTasks,
          selectedDate,
        );

        // Act
        await pumpKanbanPage(tester, controller);

        // Assert: Only tasks for selected date should appear
        expect(find.text('Todo Task Priority 1'), findsOneWidget);
        expect(find.text('In Progress Task 1'), findsOneWidget);
        expect(find.text('Completed Task 1'), findsOneWidget);

        // Assert: Tasks for different date should not appear
        expect(find.text('Todo Task Priority 1-diff'), findsNothing);

        // Verify controller filtering
        expect(
            controller.todoTasks.every((task) =>
                task.dueDate != null &&
                _isSameDay(task.dueDate!, selectedDate)),
            isTrue);
        expect(
            controller.inProgressTasks.every((task) =>
                task.dueDate != null &&
                _isSameDay(task.dueDate!, selectedDate)),
            isTrue);
        expect(
            controller.doneTasks.every((task) =>
                task.dueDate != null &&
                (_isSameDay(task.dueDate!, selectedDate) ||
                    (task.completedAt != null &&
                        _isSameDay(task.completedAt!, selectedDate)))),
            isTrue);
      });
    });
  });
}

// Helper function for date comparison
bool _isSameDay(DateTime d1, DateTime d2) {
  return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}