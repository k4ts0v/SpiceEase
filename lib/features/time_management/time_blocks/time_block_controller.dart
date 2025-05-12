import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';

/// Holds scheduled and unscheduled tasks
class TimeBlockState {
  final List<TaskModel> scheduledTasks;
  final List<TaskModel> unscheduledTasks;
  final bool isLoading;
  final String? error;
  final DateTime? currentSelectedDate;

  TimeBlockState({
    this.scheduledTasks = const [],
    this.unscheduledTasks = const [],
    this.isLoading = false,
    this.error,
    this.currentSelectedDate,
  });

  TimeBlockState copyWith({
    List<TaskModel>? scheduledTasks,
    List<TaskModel>? unscheduledTasks,
    bool? isLoading,
    String? error,
    DateTime? currentSelectedDate,
  }) {
    return TimeBlockState(
      scheduledTasks: scheduledTasks ?? this.scheduledTasks,
      unscheduledTasks: unscheduledTasks ?? this.unscheduledTasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentSelectedDate: currentSelectedDate ?? this.currentSelectedDate,
    );
  }
}

// TODO: add subtasks support.
// TODO: Modify query to not show tasks once they're done.(Check DSK)
class TimeBlockController extends StateNotifier<TimeBlockState> {
  final Ref ref;
  TimeBlockController(this.ref) : super(TimeBlockState());

  /// Load tasks for the selected date
Future<void> loadTasks(BuildContext context) async {
  state = state.copyWith(
      isLoading: true, currentSelectedDate: ref.read(selectedDateProvider));

  final selectedDate = ref.read(selectedDateProvider);
  // Create DateTime for start and end of the selected day
  final dayStart =
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
  final dayEnd = dayStart
      .add(const Duration(days: 1))
      .subtract(const Duration(microseconds: 1));

  try {
    // Get tasks for the selected date
    final List<TaskModel> tasks =
        await ref.read(taskServiceProvider).getTasksForDate(selectedDate);

    // Sort into scheduled and unscheduled
    final scheduledTasks = <TaskModel>[];
    final unscheduledTasks = <TaskModel>[];

    for (final task in tasks) {
      // Skip tasks completed before the selected date
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

        if (currentDate.isAfter(completedDate)) {
          continue;
        }
      }

      print("Processing task: ${task.title}, Start: ${task.startTime}, End: ${task.endTime}, Est: ${task.estimatedTime}");

      // Calculate end time if we have start time and estimated time but no end time
      TaskModel processedTask = task;
      if (task.startTime != null &&
          task.endTime == null &&
          task.estimatedTime != null) {
        // Parse estimated time string (e.g. "20 minutes")
        int minutes = parseEstimatedTimeToMinutes(task.estimatedTime!);
        if (minutes > 0) {
          DateTime calculatedEndTime =
              task.startTime!.add(Duration(minutes: minutes));
          processedTask = task.copyWith(endTime: calculatedEndTime);
          print(
              "Calculated end time for ${task.title}: $calculatedEndTime from estimated time: ${task.estimatedTime}");
        }
      }

      // Now, a task is scheduled if it has a start time AND (end time OR estimated time)
      if (processedTask.startTime != null && processedTask.endTime != null) {
        print("Task ${processedTask.title} is scheduled");
        scheduledTasks.add(processedTask);
      } else {
        print("Task ${processedTask.title} is unscheduled");
        unscheduledTasks.add(processedTask);
      }
    }

    state = state.copyWith(
      isLoading: false,
      scheduledTasks: scheduledTasks,
      unscheduledTasks: unscheduledTasks,
    );

    print(
        "Scheduled tasks: ${scheduledTasks.length}, Unscheduled tasks: ${unscheduledTasks.length}");
  } catch (e) {
    print("Error loading tasks: $e");
    state = state.copyWith(isLoading: false);
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading tasks: $e')),
    );
  }
}

  // Helper method to parse estimated time string
  int parseEstimatedTimeToMinutes(String estimatedTime) {
    estimatedTime = estimatedTime.toLowerCase();
    int minutes = 0;

    // Handle decimal hours (e.g., "1.5 hours" = 90 minutes)
    if (estimatedTime.contains("hour") || estimatedTime.contains("hr")) {
      final matches = RegExp(r'(\d+\.?\d*)').allMatches(estimatedTime);
      if (matches.isNotEmpty) {
        final hours = double.parse(matches.first.group(1)!);
        minutes += (hours * 60).round();
      }
    }

    // Existing minute parsing
    final minutesMatch = RegExp(r'(\d+)\s*(?:min|m)').firstMatch(estimatedTime);
    if (minutesMatch != null) {
      minutes += int.parse(minutesMatch.group(1)!);
    }

    return minutes > 0 ? minutes : 60; // Default to 1hr if parsing fails
  }

  /// Schedule a task by setting its start/end times
  Future<void> scheduleTask(
    TaskModel task,
    TimeOfDay startTime,
    TimeOfDay endTime,
  ) async {
    try {
      final now = DateTime.now();
      final dayOnly = DateTime(now.year, now.month, now.day);

      final start = DateTime(dayOnly.year, dayOnly.month, dayOnly.day,
          startTime.hour, startTime.minute);
      final end = DateTime(dayOnly.year, dayOnly.month, dayOnly.day,
          endTime.hour, endTime.minute);

      final updatedTask = task.copyWith(startTime: start, endTime: end);

      // Persist changes via your service or repository as needed:
      await ref.read(taskServiceProvider).updateTask(task.id, updatedTask);

      final newScheduled = [...state.scheduledTasks, updatedTask];
      final newUnscheduled =
          state.unscheduledTasks.where((t) => t.id != task.id).toList();

      state = state.copyWith(
        scheduledTasks: newScheduled,
        unscheduledTasks: newUnscheduled,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to schedule task: $e');
    }
  }

  /// Unschedule a task by clearing its start/end time
  Future<void> unscheduleTask(TaskModel task, BuildContext context) async {
    try {
      final updatedTask = task.copyWith(
        startTime: null,
        endTime: null,
        updatedAt: DateTime.now(),
      );

      await ref.read(taskServiceProvider).updateTask(task.id, updatedTask);

      final newScheduled =
          state.scheduledTasks.where((t) => t.id != task.id).toList();
      final newUnscheduled = [...state.unscheduledTasks, updatedTask];

      state = state.copyWith(
        scheduledTasks: newScheduled,
        unscheduledTasks: newUnscheduled,
      );

      await loadTasks(context);
    } catch (e) {
      print("Error unscheduling task: $e");
      state = state.copyWith(error: 'Failed to unschedule task: $e');
    }
  }

  Future<void> updateScheduledTaskTime(
    TaskModel task,
    TimeOfDay newStartTime,
  ) async {
    try {
      final now = DateTime.now();
      final dayOnly = DateTime(now.year, now.month, now.day);

      // 1. Calculate new start time
      final newStart = DateTime(
        dayOnly.year,
        dayOnly.month,
        dayOnly.day,
        newStartTime.hour,
        newStartTime.minute,
      );

      // 2. Calculate end time using estimated time first
      DateTime newEnd;
      if (task.estimatedTime != null) {
        final minutes = parseEstimatedTimeToMinutes(task.estimatedTime!);
        newEnd = newStart.add(Duration(minutes: minutes));
      } else {
        // Fallback to original duration or default
        final originalDuration = task.endTime != null && task.startTime != null
            ? task.endTime!.difference(task.startTime!)
            : const Duration(hours: 1);
        newEnd = newStart.add(originalDuration);
      }

      // 3. Update task with new times
      final updatedTask = task.copyWith(
        startTime: newStart,
        endTime: newEnd,
        updatedAt: DateTime.now(),
      );

      // 4. Persist changes
      await ref.read(taskServiceProvider).updateTask(task.id, updatedTask);

      // 5. Update state immediately
      final updatedList = state.scheduledTasks
          .map((t) => t.id == task.id ? updatedTask : t)
          .toList();

      state = state.copyWith(scheduledTasks: updatedList);

      print("Scheduled task updated - Start: $newStart, End: $newEnd");
    } catch (e) {
      print("Error updating schedule: $e");
      state = state.copyWith(error: 'Failed to update schedule: $e');
    }
  }
}

// Provide the controller
final timeBlockControllerProvider =
    StateNotifierProvider<TimeBlockController, TimeBlockState>((ref) {
  return TimeBlockController(ref);
});
