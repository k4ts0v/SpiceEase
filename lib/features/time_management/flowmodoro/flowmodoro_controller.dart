import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/flowmodoro_model.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/flowmodoro_provider.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/data/providers/subtask_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';
import 'package:spiceease/l10n/app_localizations.dart';

/// The FlowmodoroController manages lists of both tasks and subtasks for flowmodoro usage,
/// keeping them separate to avoid ID conflicts.
final flowmodoroControllerProvider =
    ChangeNotifierProvider.autoDispose<FlowmodoroController>((ref) {
  return FlowmodoroController(ref);
});

class FlowmodoroController extends ChangeNotifier {
  final Ref _ref;

  /// List of tasks that are incomplete and relevant to Flowmodoro
  List<TaskModel> availableTasks = [];

  /// List of subtasks that are incomplete and relevant to Flowmodoro
  List<SubtaskModel> availableSubtasks = [];

  /// Parent titles for tasks that have subtasks
  final Map<String, dynamic> parentTaskDetails = {};

  bool isLoading = true;
  DateTime currentSelectedDate = DateTime.now();

  FlowmodoroController(this._ref);

  /// Loads tasks and subtasks for the currently selected date,
  /// filtering out completed items that occurred before the date.
  Future<void> loadTasks(BuildContext context) async {
    if (!context.mounted) return;
    final localizations = AppLocalizations.of(context)!;
    final selectedDate = _ref.read(selectedDateProvider);
    currentSelectedDate = selectedDate;

    isLoading = true;
    notifyListeners();

    try {
      // Fetch all tasks for the selected date
      final allTasks =
          await _ref.read(taskServiceProvider).getTasksForDate(selectedDate);

      final List<TaskModel> incompleteTasks = [];
      final List<SubtaskModel> incompleteSubtasks = [];
      parentTaskDetails.clear();

      for (final task in allTasks) {
        // Skip any task that is completed
        if (task.completedAt != null) {
          continue;
        }

        // If task has subtasks, store its title  and priority, but do not add it to the task list
        if (task.hasSubtasks) {
          parentTaskDetails[task.id] = {
        'title': task.title,
        'priority': task.priority,
      };

          // Fetch and add incomplete subtasks
          final subs = await _ref
              .read(subtaskServiceProvider)
              .getSubtasksForTask(task.id);
          for (final subtask in subs) {
            if (!subtask.completed) {
              incompleteSubtasks.add(subtask);
            }
          }
        } else {
          // Add only tasks without subtasks
          if (task.status != localizations.done) {
            incompleteTasks.add(task);
          }
        }
      }

      availableTasks = incompleteTasks;
      availableSubtasks = incompleteSubtasks;
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Completes a regular task by marking it as done in the database
  /// and removing it from the in-memory list.
  Future<bool> completeTask(String taskId) async {
    try {
      final index = availableTasks.indexWhere((t) => t.id == taskId);
      if (index == -1) {
        throw Exception('Task not found in list');
      }

      final oldTask = availableTasks[index];
      final updated = oldTask.copyWith(
        status: 'Done',
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _ref.read(taskServiceProvider).updateTask(taskId, updated);
      availableTasks.removeAt(index);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error completing task: $e');
      return false;
    }
  }

  /// Completes a subtask by marking it as done in the database
  /// and removing it from the in-memory list.
  Future<bool> completeSubtask(String subtaskId) async {
    try {
      final index = availableSubtasks.indexWhere((st) => st.id == subtaskId);
      if (index == -1) {
        throw Exception('Subtask not found in list');
      }

      final oldSubtask = availableSubtasks[index];
      final updated = oldSubtask.copyWith(
        completed: true,
        updatedAt: DateTime.now(),
      );

      await _ref.read(subtaskServiceProvider).updateSubtask(subtaskId, updated);
      availableSubtasks.removeAt(index);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error completing subtask: $e');
      return false;
    }
  }

  /// Saves the results of a completed flowmodoro session for analytics.
  Future<void> saveCompletedFlowmodoro({
    required String taskId,
    required int focusMinutes,
    required int breakMinutes,
    required int cycles,
  }) async {
    try {
      debugPrint(
          'Saving flowmodoro data: $taskId, $focusMinutes min focus, $breakMinutes min break, $cycles cycles');

      await _ref
          .read(flowmodoroServiceProvider)
          .createFlowmodoro(FlowmodoroModel(
            id: '', // Firestore will generate
            taskId: taskId,
            focusMinutes: focusMinutes,
            breakMinutes: breakMinutes,
            pomoCount: cycles,
            isCompleted: true,
            createdAt: DateTime.now(),
          ));
    } catch (e) {
      debugPrint('Error saving flowmodoro data: $e');
    }
  }

  /// For subtasks, retrieve the parent task’s display title, if any.
  String? getParentTaskTitle(String parentTaskId) {
    return parentTaskDetails[parentTaskId]?['title'];
  }

  /// For subtasks, retrieve the parent task’s priority, if any.
  int? getParentTaskPriority(String parentTaskId) {
    return parentTaskDetails[parentTaskId]?['priority'];
  }

  /// Utility method to check if it's a subtask. In this updated approach,
  /// tasks and subtasks remain separate, so this always returns false for tasks.
  bool isSubtask(TaskModel task) {
    return false;
  }
}
