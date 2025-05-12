import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';
import 'package:spiceease/features/tracker/presentation/tracker_controller.dart';
import 'package:spiceease/l10n/app_localizations.dart';

final kanbanControllerProvider =
    ChangeNotifierProvider.autoDispose<KanbanController>((ref) {
  return KanbanController(ref);
});

class KanbanController extends ChangeNotifier {
  final Ref _ref;

  // State variables - exactly the same as the original class
  List<TaskModel> todoTasks = [];
  List<TaskModel> inProgressTasks = [];
  List<TaskModel> doneTasks = [];
  List<TaskModel> noDueDateTasks = [];
  bool isLoading = true;
  DateTime currentSelectedDate = DateTime.now();

  KanbanController(this._ref);

  Future<void> loadTasks(BuildContext context) async {
    if (!context.mounted) return;

    final localizations = AppLocalizations.of(context)!;
    final selectedDate = _ref.read(selectedDateProvider);
    currentSelectedDate = selectedDate;

    isLoading = true;
    notifyListeners();

    try {
      // Load date-specific tasks
      final allTasks =
          await _ref.read(taskServiceProvider).getTasksForDate(selectedDate);

      // Load tasks without due date
      final allNoDateTasks =
          await _ref.read(taskServiceProvider).getTasksByStatus(
                localizations.pending,
                sortByPriority: true,
              );

      // Filter out parents with subtasks
      final tasksWithSubtasks = allTasks
          .where((task) => allTasks.any((subtask) => subtask.parentTaskId == task.id))
          .map((task) => task.id)
          .toSet();

      final noDateTasksWithSubtasks = allNoDateTasks
          .where((task) =>
              allNoDateTasks.any((subtask) => subtask.parentTaskId == task.id))
          .map((task) => task.id)
          .toSet();

      // Filter the tasks to exclude parents with subtasks
      final tasks = allTasks
          .where((task) => !tasksWithSubtasks.contains(task.id))
          .toList();
      final noDateTasks = allNoDateTasks
          .where((task) =>
              task.dueDate == null &&
              !noDateTasksWithSubtasks.contains(task.id))
          .toList();

      // Group tasks by their status with date filtering
      final todoList = <TaskModel>[];
      final inProgressList = <TaskModel>[];
      final doneList = <TaskModel>[];

      for (final task in tasks) {
        // Handle completed tasks with completion date check
        if (task.completedAt != null) {
          final completedDate = DateTime(
            task.completedAt!.year,
            task.completedAt!.month,
            task.completedAt!.day,
          );
          final currentDate = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
          );

          // Skip tasks completed before the selected date
          if (currentDate.isAfter(completedDate)) continue;
        }

        // Categorize remaining tasks
        if (task.status == localizations.done || task.completedAt != null) {
          doneList.add(task);
        } else if (task.status == localizations.inProgress) {
          inProgressList.add(task);
        } else {
          todoList.add(task);
        }
      }

      // Update the state variables
      todoTasks = todoList;
      inProgressTasks = inProgressList;
      doneTasks = doneList;
      noDueDateTasks = noDateTasks;
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //TODO: BUG: When a task is completed through here, its checked in the dashboard,
  // but its statusis pending.either update the status or use togglecompletion.
  //Method to update task status
  void updateTaskStatus(
      TaskModel task, String newStatus, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Create updated task with new status using copyWith instead of creating a new model
    final updatedTask = task.copyWith(
      status: newStatus,
      completedAt: newStatus == localizations.done ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );

    // Remove from all lists (it will be in one of them)
    todoTasks.removeWhere((t) => t.id == task.id);
    inProgressTasks.removeWhere((t) => t.id == task.id);
    doneTasks.removeWhere((t) => t.id == task.id);

    // If task was in noDueDateTasks and now has a due date, remove it from there too
    if (task.dueDate == null && updatedTask.dueDate != null) {
      noDueDateTasks.removeWhere((t) => t.id == task.id);
    }

    // Add to appropriate list
    if (newStatus == localizations.done) {
      doneTasks.add(updatedTask);
    } else if (newStatus == localizations.inProgress) {
      inProgressTasks.add(updatedTask);
    } else {
      todoTasks.add(updatedTask);
    }

    notifyListeners();

    // Update database in the background
    _saveTaskToDatabase(updatedTask, newStatus,
        context); // Pass updatedTask instead of original task
  }

  // Save task to database without blocking UI
  Future<void> _saveTaskToDatabase(
      TaskModel task, String newStatus, BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    try {
      // Check if the task is marked as done
      final completedAt =
          newStatus == localizations.done ? DateTime.now() : null;

      // Create a new task model with the correct status and completedAt
      final updatedTask = task.copyWith(
        status: newStatus,
        completedAt: completedAt,
        updatedAt: DateTime.now(),
      );

      // Use the direct task service to ensure proper update
      await _ref.read(taskServiceProvider).updateTask(task.id, updatedTask);
    } catch (e) {
      // If saving fails, reload tasks to restore correct state
      debugPrint('Error updating task: $e');
      loadTasks(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.errorSavingTask(e))),
        );
      }
    }
  }
}
