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
      final tasks =
          await _ref.read(taskServiceProvider).getTasksForDate(selectedDate);

      // Load tasks without due date
      final allTasks = await _ref.read(taskServiceProvider).getTasksByStatus(
            localizations.pending,
            sortByPriority: true,
          );

      final noDateTasks =
          allTasks.where((task) => task.dueDate == null).toList();

      // Group tasks by their status
      final todoList = <TaskModel>[];
      final inProgressList = <TaskModel>[];
      final doneList = <TaskModel>[];

      for (final task in tasks) {
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
      // Handle error
      debugPrint('Error loading tasks: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Method to update task status
  void updateTaskStatus(
      TaskModel task, String newStatus, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Create updated task with new status
    final updatedTask = TaskModel(
      id: task.id,
      userId: task.userId,
      title: task.title,
      description: task.description,
      status: newStatus,
      createdAt: task.createdAt,
      dueDate: task.dueDate,
      completedAt: newStatus == localizations.done ? DateTime.now() : null,
      estimatedTime: task.estimatedTime,
      priority: task.priority,
      subtasks: task.subtasks,
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
    _saveTaskToDatabase(task, newStatus, context);
  }

  // Save task to database without blocking UI
  Future<void> _saveTaskToDatabase(
      TaskModel task, String newStatus, BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    try {
      final completedAt =
          newStatus == localizations.done ? DateTime.now() : null;

      await _ref.read(trackerControllerProvider).updateTask(
            task.id,
            task.title,
            task.description,
            newStatus,
            task.dueDate,
            completedAt,
            task.estimatedTime,
            task.priority,
            task.subtasks,
          );
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
