import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/data/providers/subtask_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';

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
/// board layout. It works directly with TaskModel and SubtaskModel instances.
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
  List<TaskModel> todoTasks = [];

  /// List of tasks in the 'in_progress' status column.
  List<TaskModel> inProgressTasks = [];

  /// List of tasks in the 'done' status column.
  List<TaskModel> doneTasks = [];

  /// List of tasks that have no due date set.
  List<TaskModel> noDueDateTasks = [];

  /// List of subtasks in the 'todo' status column.
  List<SubtaskModel> todoSubtasks = [];

  /// List of subtasks in the 'in_progress' status column.
  List<SubtaskModel> inProgressSubtasks = [];

  /// List of subtasks in the 'done' status column.
  List<SubtaskModel> doneSubtasks = [];

  /// Map to store parent task information for subtasks
  Map<String, TaskModel> parentTasksMap = {};

  /// Whether the controller is currently loading data.
  bool isLoading = true;

  /// The currently selected date for filtering tasks.
  DateTime currentSelectedDate = DateTime.now();

  /// Creates a new [KanbanController] with the given [Ref].
  KanbanController(this._ref);

  /// Loads and categorizes tasks for the currently selected date.
  Future<void> loadTasks(BuildContext context) async {
    if (!context.mounted) return;

    final selectedDate = _ref.read(selectedDateProvider);
    currentSelectedDate = selectedDate;

    isLoading = true;
    notifyListeners();

    try {
      // Step 1: Fetch all tasks for the selected date from the database
      final List<TaskModel> tasks =
          await _ref.read(taskServiceProvider).getTasksForDate(selectedDate);

      debugPrint('Loaded ${tasks.length} tasks from DB');

      // Step 2: Load all subtasks for tasks that have subtasks
      final List<SubtaskModel> allSubtasksForDay = [];
      parentTasksMap.clear();

      for (final task in tasks) {
        if (task.hasSubtasks) {
          final subtasksForThisTask = await _ref
              .read(subtaskServiceProvider)
              .getSubtasksForTask(task.id);

          // Store parent task info for subtasks
          parentTasksMap[task.id] = task;

          // Add all subtasks
          allSubtasksForDay.addAll(subtasksForThisTask);

          debugPrint(
              'Task ${task.id} has ${subtasksForThisTask.length} subtasks');
        }
      }

      // Step 3: Filter out parent tasks that have subtasks and filter out done tasks
      final List<TaskModel> filteredTasks = tasks.where((task) {
        // Filter out done tasks
        if (task.status == 'Done') return false;
        // Filter out parent tasks that have subtasks
        if (task.hasSubtasks) return false;
        return true;
      }).toList();

      // Step 4: Filter out completed subtasks
      final List<SubtaskModel> filteredSubtasks =
          allSubtasksForDay.where((subtask) {
        return !subtask.completed;
      }).toList();

      // Step 5: Categorize regular tasks by status
      final todoTaskList = <TaskModel>[];
      final inProgTaskList = <TaskModel>[];
      final doneTaskList = <TaskModel>[];

      for (final task in filteredTasks) {
        debugPrint('Categorizing task ${task.id} with status ${task.status}');

        // Special handling for completed tasks: only show on completion date
        if (task.completedAt != null) {
          final completedDay = DateUtils.dateOnly(task.completedAt!);
          final selectedDay = DateUtils.dateOnly(selectedDate);
          if (completedDay.isAtSameMomentAs(selectedDay)) {
            doneTaskList.add(task);
          }
        } else if (task.status.toLowerCase() == 'done') {
          // Task marked as done but no completion date
          doneTaskList.add(task);
        } else if (task.status.toLowerCase() == 'in progress') {
          // Task currently being worked on
          inProgTaskList.add(task);
        } else {
          // Default to todo status
          todoTaskList.add(task);
        }
      }

      // Step 6: Categorize subtasks by status
      final todoSubtaskList = <SubtaskModel>[];
      final inProgSubtaskList = <SubtaskModel>[];
      final doneSubtaskList = <SubtaskModel>[];

      for (final subtask in filteredSubtasks) {
        debugPrint(
            'Categorizing subtask ${subtask.id} with status ${subtask.status}');

        // Special handling for completed subtasks: only show on completion date
        if (subtask.completed && subtask.updatedAt != null) {
          final completedDay = DateUtils.dateOnly(subtask.updatedAt!);
          final selectedDay = DateUtils.dateOnly(selectedDate);
          if (completedDay.isAtSameMomentAs(selectedDay)) {
            doneSubtaskList.add(subtask);
          }
        } else if (subtask.status?.toLowerCase() == 'done' ||
            subtask.completed) {
          // Subtask marked as done
          doneSubtaskList.add(subtask);
        } else if (subtask.status?.toLowerCase() == 'in_progress') {
          // Subtask currently being worked on
          inProgSubtaskList.add(subtask);
        } else {
          // Default to todo status
          todoSubtaskList.add(subtask);
        }
      }

      // Step 7: Update the controller's state with categorized items
      todoTasks = todoTaskList;
      inProgressTasks = inProgTaskList;
      doneTasks = doneTaskList;

      todoSubtasks = todoSubtaskList;
      inProgressSubtasks = inProgSubtaskList;
      doneSubtasks = doneSubtaskList;

      // Step 8: Identify tasks with no due date for separate display
      noDueDateTasks = filteredTasks
          .where((task) => task.dueDate == null && task.completedAt == null)
          .toList();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the status of a task and persists the change to the database.
  Future<void> updateTaskStatus(
      TaskModel task, String newStatus, BuildContext context) async {
    final selectedDate = _ref.read(selectedDateProvider);

    try {
      // Map display status to database status
      String dbStatus;
      switch (newStatus.toLowerCase()) {
        case 'in_progress':
          dbStatus = 'In Progress';
          break;
        case 'done':
          dbStatus = 'Done';
          break;
        default:
          dbStatus = 'pending';
      }

      // Create updated task with new status and completion date if applicable
      final updated = task.copyWith(
        status: dbStatus,
        completedAt: newStatus == 'done' ? selectedDate : null,
        clearCompletedAt: newStatus != 'done',
        updatedAt: DateTime.now(),
      );

      // Persist the change to the database
      await _ref.read(taskServiceProvider).updateTask(task.id, updated);
      debugPrint(
          'Task ${task.id} updated in DB with status $dbStatus, reloading tasks');

      // Reload all tasks to refresh the UI
      await loadTasks(context);
    } catch (e) {
      debugPrint('Error updating task: $e');
      // Still reload tasks to ensure UI consistency
      await loadTasks(context);
    }
  }

  /// Updates the status of a subtask and persists the change to the database.
  Future<void> updateSubtaskStatus(
      SubtaskModel subtask, String newStatus, BuildContext context) async {
    final selectedDate = _ref.read(selectedDateProvider);

    try {
      // Map display status to database status
      String dbStatus;
      switch (newStatus.toLowerCase()) {
        case 'in_progress':
          dbStatus = 'in_progress';
          break;
        case 'done':
          dbStatus = 'done';
          break;
        default:
          dbStatus = 'todo';
      }

      // Create updated subtask with new status and completion state
      final updatedSubtask = subtask.copyWith(
        status: dbStatus, // Set the new status code
        completed: newStatus == 'done', // Mark as completed if done
        updatedAt: selectedDate, // Update the timestamp
      );

      // Persist the change to the database
      await _ref
          .read(subtaskServiceProvider)
          .updateSubtask(subtask.id, updatedSubtask);

      // Refresh the subtask provider for the parent task
      if (subtask.taskId.isNotEmpty) {
        _ref.refresh(subtaskStateNotifierProvider(subtask.taskId));
      }

      debugPrint(
          'Subtask ${subtask.id} updated in DB with status $dbStatus, reloading tasks');

      // Reload all tasks to refresh the kanban board
      await loadTasks(context);
    } catch (e) {
      debugPrint('Error updating subtask: $e');
      // Still reload tasks to ensure UI consistency
      await loadTasks(context);
    }
  }

  /// Gets the parent task for a given subtask
  TaskModel? getParentTask(SubtaskModel subtask) {
    return parentTasksMap[subtask.taskId];
  }

  /// Checks if an item is a subtask based on its type
  bool isSubtask(dynamic item) {
    return item is SubtaskModel;
  }
}
