import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/data/providers/subtask_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';
import 'package:spiceease/features/tracker/presentation/tracker_controller.dart';
import 'package:spiceease/l10n/app_localizations.dart';

final kanbanControllerProvider =
    ChangeNotifierProvider.autoDispose<KanbanController>((ref) {
  return KanbanController(ref);
});

class KanbanController extends ChangeNotifier {
  final Ref _ref;

  // flattened lists per column
  List<TaskModel> todoTasks = [];
  List<TaskModel> inProgressTasks = [];
  List<TaskModel> doneTasks = [];
  List<TaskModel> noDueDateTasks = [];

  // expose parent‐task titles for subtasks
  final Map<String, String> parentTaskTitles = {};

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
      // 1) fetch all tasks for the date
      final allTasks =
          await _ref.read(taskServiceProvider).getTasksForDate(selectedDate);

      // 2) flatten: parents → their subtasks, standalone otherwise
      final List<TaskModel> displayTasks = [];
      parentTaskTitles.clear();

      for (final task in allTasks) {
        if (task.hasSubtasks) {
          // remember parent title
          parentTaskTitles[task.id] = task.title;

          // fetch and inline its subtasks
          final subs =
              await _ref.read(subtaskServiceProvider).getSubtasksForTask(task.id);

          displayTasks.addAll(subs.map((st) => TaskModel(
                id: st.id,
                title: st.title,
                description: task.description,
                status: task.status,
                dueDate: task.dueDate,
                completedAt: st.completed ? DateTime.now() : null,
                estimatedTime: st.rawTimeValue,
                priority: task.priority,
                parentTaskId: task.id,
                userId: task.userId,
                createdAt: task.createdAt,
                updatedAt: task.updatedAt,
              )));
        } else {
          displayTasks.add(task);
        }
      }

      // 3) drop any vestigial “parent” entries now represented by subtasks
      final tasksWithSubtasks = displayTasks
          .where((t) => t.parentTaskId != null)
          .map((t) => t.parentTaskId!)
          .toSet();
      final tasks = displayTasks
          .where((t) => !tasksWithSubtasks.contains(t.id))
          .toList();

      // 4) categorize by status (and skip ones completed before the selected date)
      final todoList = <TaskModel>[];
      final inProgList = <TaskModel>[];
      final doneList = <TaskModel>[];

      for (final task in tasks) {
        // skip if completed earlier than selected
        if (task.completedAt != null) {
          final completedDate = DateTime(
            task.completedAt!.year,
            task.completedAt!.month,
            task.completedAt!.day,
          );
          final curDate = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
          );
          if (curDate.isAfter(completedDate)) continue;
        }

        // bucket
        if (task.status == localizations.done || task.completedAt != null) {
          doneList.add(task);
        } else if (task.status == localizations.inProgress) {
          inProgList.add(task);
        } else {
          todoList.add(task);
        }
      }

      // 5) commit
      todoTasks = todoList;
      inProgressTasks = inProgList;
      doneTasks = doneList;
      noDueDateTasks = tasks.where((t) => t.dueDate == null).toList();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Change status and persist
  void updateTaskStatus(
      TaskModel task, String newStatus, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final updated = task.copyWith(
      status: newStatus,
      completedAt:
          newStatus == localizations.done ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );

    // remove old
    todoTasks.removeWhere((t) => t.id == task.id);
    inProgressTasks.removeWhere((t) => t.id == task.id);
    doneTasks.removeWhere((t) => t.id == task.id);
    if (task.dueDate == null && updated.dueDate != null) {
      noDueDateTasks.removeWhere((t) => t.id == task.id);
    }

    // re-add
    if (newStatus == localizations.done) {
      doneTasks.add(updated);
    } else if (newStatus == localizations.inProgress) {
      inProgressTasks.add(updated);
    } else {
      todoTasks.add(updated);
    }
    notifyListeners();

    // persist in background
    _saveTaskToDatabase(updated, newStatus, context);
  }

  Future<void> _saveTaskToDatabase(
      TaskModel task, String newStatus, BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    try {
      final completed =
          newStatus == localizations.done ? DateTime.now() : null;
      final updated = task.copyWith(
        status: newStatus,
        completedAt: completed,
        updatedAt: DateTime.now(),
      );
      await _ref.read(taskServiceProvider).updateTask(task.id, updated);
    } catch (e) {
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