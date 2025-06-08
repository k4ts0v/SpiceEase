import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/data/providers/subtask_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';
import 'package:spiceease/l10n/app_localizations.dart';

/// Provider for the [KanbanController] that manages the kanban board state.
///
/// This provider creates and manages the lifecycle of the kanban controller,
/// automatically disposing of it when no longer needed.
final kanbanControllerProvider =
    ChangeNotifierProvider.autoDispose<KanbanController>((ref) {
  return KanbanController(ref);
});

/// Controller for managing the kanban board state and operations.
///
/// This controller handles loading, categorizing, and updating tasks in a kanban
/// board layout. It flattens parent tasks with subtasks to show subtasks as
/// individual cards while maintaining the relationship context.
///
/// The controller manages four main categories:
/// - Todo tasks (status: 'todo')
/// - In Progress tasks (status: 'in_progress')
/// - Done tasks (status: 'done')
/// - Tasks with no due date
class KanbanController extends ChangeNotifier {
  /// Reference to the Riverpod ref for accessing other providers.
  final Ref _ref;

  /// List of tasks in the 'todo' status column.
  ///
  /// These are tasks that have not been started yet.
  List<TaskModel> todoTasks = [];

  /// List of tasks in the 'in_progress' status column.
  ///
  /// These are tasks that are currently being worked on.
  List<TaskModel> inProgressTasks = [];

  /// List of tasks in the 'done' status column.
  ///
  /// These are completed tasks, filtered by completion date to only show
  /// tasks completed on the currently selected date.
  List<TaskModel> doneTasks = [];

  /// List of tasks that have no due date set.
  ///
  /// These tasks are shown separately as they don't belong to any specific
  /// time-based category.
  List<TaskModel> noDueDateTasks = [];

  /// Map of parent task IDs to their titles.
  ///
  /// Used to display the parent task context for subtasks that are shown
  /// as individual cards in the kanban board.
  final Map<String, String> parentTaskTitles = {};

  /// Whether the controller is currently loading data.
  ///
  /// Used to show loading indicators in the UI while data is being fetched.
  bool isLoading = true;

  /// The currently selected date for filtering tasks.
  ///
  /// Tasks are filtered and displayed based on this date.
  DateTime currentSelectedDate = DateTime.now();

  /// Creates a new [KanbanController] with the given [Ref].
  ///
  /// The [ref] parameter is used to access other providers and services.
  KanbanController(this._ref);

  /// Loads and categorizes tasks for the currently selected date.
  ///
  /// This method performs the following operations:
  /// 1. Fetches all tasks for the selected date from the database
  /// 2. Flattens parent tasks with subtasks (shows subtasks as individual cards)
  /// 3. Categorizes tasks by status into appropriate columns
  /// 4. Filters done tasks to only show those completed on the selected date
  /// 5. Updates the UI by calling [notifyListeners]
  ///
  /// The [context] parameter is used to check if the widget is still mounted
  /// before performing asynchronous operations.
  Future<void> loadTasks(BuildContext context) async {
    // Early return if the widget context is no longer valid
    if (!context.mounted) return;

    // Get the currently selected date from the provider
    final selectedDate = _ref.read(selectedDateProvider);
    currentSelectedDate = selectedDate;

    // Set loading state and notify UI
    isLoading = true;
    notifyListeners();

    try {
      // Step 1: Fetch all tasks for the selected date from the database
      final allTasks =
          await _ref.read(taskServiceProvider).getTasksForDate(selectedDate);

      debugPrint('Loaded ${allTasks.length} tasks from DB');

      // Step 2: Flatten parent tasks with subtasks
      // Instead of showing parent tasks, we show their subtasks as individual cards
      final List<TaskModel> displayTasks = [];
      parentTaskTitles.clear();

      for (final task in allTasks) {
        if (task.hasSubtasks) {
          // Store parent task title for context display
          parentTaskTitles[task.id] = task.title;

          // Fetch all subtasks for this parent task
          final subs = await _ref
              .read(subtaskServiceProvider)
              .getSubtasksForTask(task.id);

          debugPrint(
              'Task ${task.id} has ${subs.length} subtasks, flattening them');

          // Convert subtasks to TaskModel format for display
          displayTasks.addAll(
            subs.map((st) => TaskModel(
                  id: st.id,
                  title: st.title,
                  description: task.description,
                  status: st.status ?? 'todo', // Use subtask status
                  completedAt: st.completed ? st.updatedAt : null,
                  dueDate: task.dueDate, // Inherit parent's due date
                  estimatedTime: st.rawTimeValue, // Use subtask time estimate
                  priority: task.priority, // Inherit parent's priority
                  parentTaskId: task.id, // Mark as subtask
                  userId: task.userId,
                  createdAt: task.createdAt,
                  updatedAt: st.updatedAt ?? task.updatedAt,
                )),
          );
        } else {
          // Regular task without subtasks, add as-is
          displayTasks.add(task);
        }
      }

      // Step 3: Remove parent tasks that have subtasks from the display
      // We only want to show either the parent OR its subtasks, not both
      final tasksWithSubtasks = displayTasks
          .where((t) => t.parentTaskId != null)
          .map((t) => t.parentTaskId!)
          .toSet();

      final tasks =
          displayTasks.where((t) => !tasksWithSubtasks.contains(t.id)).toList();

      // Step 4: Categorize tasks by status into appropriate columns
      final todoList = <TaskModel>[];
      final inProgList = <TaskModel>[];
      final doneList = <TaskModel>[];

      for (final task in tasks) {
        debugPrint('Categorizing task ${task.id} with status ${task.status}');

        // Special handling for completed tasks: only show on completion date
        if (task.completedAt != null) {
          final completedDay = DateUtils.dateOnly(task.completedAt!);
          final selectedDay = DateUtils.dateOnly(selectedDate);
          if (completedDay.isAtSameMomentAs(selectedDay)) {
            doneList.add(task);
          }
        } else if (task.status == 'done') {
          // Task marked as done but no completion date
          doneList.add(task);
        } else if (task.status == 'in_progress') {
          // Task currently being worked on
          inProgList.add(task);
        } else {
          // Default to todo status
          todoList.add(task);
        }
      }

      // Step 5: Update the controller's state with categorized tasks
      todoTasks = todoList;
      inProgressTasks = inProgList;
      doneTasks = doneList;

      // Step 6: Identify tasks with no due date for separate display
      noDueDateTasks = tasks
          .where((t) => t.dueDate == null && t.completedAt == null)
          .toList();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      // Always clear loading state and notify listeners
      isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the status of a task and persists the change to the database.
  ///
  /// This method handles both regular tasks and subtasks differently:
  /// - For subtasks: Updates the subtask record and refreshes the subtask provider
  /// - For regular tasks: Updates the task record directly
  ///
  /// The [task] parameter is the task to update.
  /// The [newStatus] parameter should be one of: 'todo', 'in_progress', 'done'.
  /// The [context] parameter is used for mounted checks during async operations.
  Future<void> updateTaskStatus(
      TaskModel task, String newStatus, BuildContext context) async {
    // Check if this is a subtask or a regular task
    final isSubtask = task.parentTaskId != null;

    if (isSubtask) {
      await _updateSubtaskStatus(task, newStatus, context);
    } else {
      await _updateRegularTaskStatus(task, newStatus, context);
    }
  }

  /// Updates the status of a regular (non-subtask) task.
  ///
  /// This method:
  /// 1. Creates an updated task with the new status
  /// 2. Sets completion date if status is 'done'
  /// 3. Persists the change to the database
  /// 4. Reloads all tasks to refresh the UI
  ///
  /// The [task] parameter is the task to update.
  /// The [newStatus] parameter is the new status code.
  /// The [context] parameter is used for mounted checks.
  Future<void> _updateRegularTaskStatus(
      TaskModel task, String newStatus, BuildContext context) async {
    final selectedDate = _ref.read(selectedDateProvider);

    // Create updated task with new status and completion date if applicable
    final updated = task.copyWith(
      status: newStatus,
      completedAt: newStatus == 'done' ? selectedDate : null,
      updatedAt: DateTime.now(),
    );

    try {
      // Persist the change to the database
      await _ref.read(taskServiceProvider).updateTask(task.id, updated);
      debugPrint(
          'Task ${task.id} updated in DB with status $newStatus, reloading tasks');

      // Reload all tasks to refresh the UI
      await loadTasks(context);
    } catch (e) {
      debugPrint('Error updating task: $e');
      // Still reload tasks to ensure UI consistency
      await loadTasks(context);
    }
  }

  /// Updates the status of a subtask.
  ///
  /// This method:
  /// 1. Fetches the current subtask from the database
  /// 2. Creates an updated subtask with new status and completion state
  /// 3. Persists the change to the database
  /// 4. Refreshes the subtask provider to update other UI components
  /// 5. Reloads all tasks to refresh the kanban board
  ///
  /// The [subtaskAsTask] parameter is the subtask represented as a TaskModel.
  /// The [newStatus] parameter is the new status code.
  /// The [context] parameter is used for mounted checks.
  Future<void> _updateSubtaskStatus(
      TaskModel subtaskAsTask, String newStatus, BuildContext context) async {
    final selectedDate = _ref.read(selectedDateProvider);

    try {
      // Fetch the current subtask from the database
      final subtask = await _ref
          .read(subtaskServiceProvider)
          .getSubtaskById(subtaskAsTask.id);

      if (subtask != null) {
        // Create updated subtask with new status and completion state
        final updatedSubtask = subtask.copyWith(
          status: newStatus, // Set the new status code
          completed: newStatus == 'done', // Mark as completed if done
          updatedAt: selectedDate, // Update the timestamp
        );

        // Persist the change to the database
        await _ref
            .read(subtaskServiceProvider)
            .updateSubtask(subtaskAsTask.id, updatedSubtask);

        // Refresh the subtask provider for the parent task
        // This ensures other UI components (like task details) are updated
        if (subtask.taskId.isNotEmpty) {
          _ref.refresh(subtaskStateNotifierProvider(subtask.taskId));
        }

        debugPrint(
            'Subtask ${subtaskAsTask.id} updated in DB with status $newStatus, reloading tasks');
      } else {
        debugPrint('Subtask not found in DB for id: ${subtaskAsTask.id}');
      }

      // Reload all tasks to refresh the kanban board
      await loadTasks(context);
    } catch (e) {
      debugPrint('Error updating subtask: $e');
      // Still reload tasks to ensure UI consistency
      await loadTasks(context);
    }
  }
}
