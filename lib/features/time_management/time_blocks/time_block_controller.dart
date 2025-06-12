import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/data/providers/subtask_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';

// ...existing code...

/// Holds scheduled and unscheduled items (tasks or subtasks)
class TimeBlockState {
  final List<dynamic> scheduledItems; // Can be TaskModel or SubtaskModel
  final List<dynamic> unscheduledItems; // Can be TaskModel or SubtaskModel
  final bool isLoading;
  final String? error;
  final DateTime? currentSelectedDate;
  final Map<String, int>
      subtaskPriorities; // Maps subtask ID to parent task priority

  TimeBlockState({
    this.scheduledItems = const [],
    this.unscheduledItems = const [],
    this.isLoading = false,
    this.error,
    this.currentSelectedDate,
    this.subtaskPriorities = const {},
  });

  TimeBlockState copyWith({
    List<dynamic>? scheduledItems,
    List<dynamic>? unscheduledItems,
    bool? isLoading,
    String? error,
    DateTime? currentSelectedDate,
    Map<String, int>? subtaskPriorities,
  }) {
    return TimeBlockState(
      scheduledItems: scheduledItems ?? this.scheduledItems,
      unscheduledItems: unscheduledItems ?? this.unscheduledItems,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Keep null if not provided, don't fallback to this.error
      currentSelectedDate: currentSelectedDate ?? this.currentSelectedDate,
      subtaskPriorities: subtaskPriorities ?? this.subtaskPriorities,
    );
  }
}

class TimeBlockController extends StateNotifier<TimeBlockState> {
  final Ref ref;
  TimeBlockController(this.ref) : super(TimeBlockState());

  // Get priority for a subtask from the cached map
  int getPriorityForSubtask(String subtaskId) {
    return state.subtaskPriorities[subtaskId] ??
        3; // Default to medium priority
  }

  // More robust parser for item estimated time (tasks or subtasks)
  int _parseItemEstimatedTimeToMinutes(String? estimatedTimeStr) {
    if (estimatedTimeStr == null || estimatedTimeStr.isEmpty) return 0;
    String timeStr = estimatedTimeStr.toLowerCase().trim();
    int totalMinutes = 0;

    // Hours
    final hourPattern = RegExp(r"(\d*\.?\d+)\s*(?:h|hr|hour|hours)");
    var match = hourPattern.firstMatch(timeStr);
    if (match != null) {
      try {
        totalMinutes += (double.parse(match.group(1)!) * 60).round();
        timeStr = timeStr.replaceFirst(match.group(0)!, "").trim();
      } catch (_) {}
    }

    // Minutes
    final minPattern = RegExp(r"(\d*\.?\d+)\s*(?:m|min|minute|minutes)");
    match = minPattern.firstMatch(timeStr);
    if (match != null) {
      try {
        totalMinutes += (double.parse(match.group(1)!)).round();
        timeStr = timeStr.replaceFirst(match.group(0)!, "").trim();
      } catch (_) {}
    }

    // Seconds
    final secPattern = RegExp(r"(\d*\.?\d+)\s*(?:s|sec|second|seconds)");
    match = secPattern.firstMatch(timeStr);
    if (match != null) {
      try {
        totalMinutes += (double.parse(match.group(1)!) / 60).ceil();
        timeStr = timeStr.replaceFirst(match.group(0)!, "").trim();
      } catch (_) {}
    }

    // If only a number remains, assume it's minutes
    if (totalMinutes == 0 && timeStr.isNotEmpty) {
      final justNumberPattern = RegExp(r"^(\d*\.?\d+)$");
      match = justNumberPattern.firstMatch(timeStr);
      if (match != null) {
        try {
          totalMinutes = (double.parse(match.group(1)!)).round();
        } catch (_) {}
      }
    }
    return totalMinutes; // Returns 0 if parsing fails or estimate is "0"
  }

  // ...existing code...

  // ...existing code...

  Future<void> loadTasks(BuildContext context) async {
    state = state.copyWith(
        isLoading: true, currentSelectedDate: ref.read(selectedDateProvider));
    final selectedDate = ref.read(selectedDateProvider);

    try {
      final List<TaskModel> tasks =
          await ref.read(taskServiceProvider).getTasksForDate(selectedDate);
      final List<SubtaskModel> allSubtasksForDay = [];
      final Map<String, int> subtaskPriorities = {}; // Build priority map

      for (final task in tasks) {
        if (task.hasSubtasks) {
          final subtasksForThisTask = await ref
              .read(subtaskServiceProvider)
              .getSubtasksForTask(task.id);
          // Load ALL subtasks, not just those with startTime
          allSubtasksForDay.addAll(subtasksForThisTask);

          // Map each subtask to its parent task's priority
          for (final subtask in subtasksForThisTask) {
            subtaskPriorities[subtask.id] = task.priority;
          }
        }
      }

      // Filter out parent tasks that have subtasks and filter out done tasks
      final List<TaskModel> filteredTasks = tasks.where((task) {
        // Filter out done tasks
        if (task.status == 'Done') return false;
        // Filter out parent tasks that have subtasks
        if (task.hasSubtasks) return false;
        return true;
      }).toList();

      // Filter out completed subtasks
      final List<SubtaskModel> filteredSubtasks =
          allSubtasksForDay.where((subtask) {
        return !subtask.completed;
      }).toList();

      final List<dynamic> allItems = [...filteredTasks, ...filteredSubtasks];
      final scheduled = <dynamic>[];
      final unscheduled = <dynamic>[];

      for (final item in allItems) {
        dynamic processedItem = item;
        DateTime? itemStartTime;
        DateTime? itemEndTime;
        String? itemEstimateString;

        if (item is TaskModel) {
          itemStartTime = item.startTime;
          itemEndTime = item.endTime;
          itemEstimateString = item.estimatedTime;
        } else if (item is SubtaskModel) {
          itemStartTime = item.startTime;
          itemEndTime = item.endTime;
          itemEstimateString = item.rawTimeValue;
        }

        // Skip items completed before the selected date (additional safety check)
        DateTime? completedAt = (item is TaskModel) ? item.completedAt : null;
        bool subtaskCompleted = (item is SubtaskModel) ? item.completed : false;

        if (completedAt != null) {
          final completedDateOnly =
              DateTime(completedAt.year, completedAt.month, completedAt.day);
          final selectedDateOnly =
              DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
          if (selectedDateOnly.isAfter(completedDateOnly)) {
            continue;
          }
        }

        // Skip completed subtasks (additional safety check)
        if (item is SubtaskModel && subtaskCompleted) {
          continue;
        }

        // Calculate end time if start time exists but end time doesn't
        if (itemStartTime != null &&
            itemEndTime == null &&
            itemEstimateString != null) {
          int minutes = _parseItemEstimatedTimeToMinutes(itemEstimateString);
          if (minutes > 0) {
            DateTime calculatedEndTime =
                itemStartTime.add(Duration(minutes: minutes));
            if (item is TaskModel) {
              processedItem = item.copyWith(endTime: calculatedEndTime);
              // Update in database
              await ref
                  .read(taskServiceProvider)
                  .updateTask(item.id, processedItem);
            } else if (item is SubtaskModel) {
              processedItem = item.copyWith(endTime: calculatedEndTime);
              // Update in database
              await ref
                  .read(subtaskServiceProvider)
                  .updateSubtask(item.id, processedItem);
            }
          }
        }

        // Refresh item times after potential update
        itemStartTime = (processedItem is TaskModel)
            ? processedItem.startTime
            : (processedItem as SubtaskModel).startTime;
        itemEndTime = (processedItem is TaskModel)
            ? processedItem.endTime
            : (processedItem as SubtaskModel).endTime;

        // Check if item should be scheduled (has both start and end time on selected date)
        if (itemStartTime != null &&
            itemEndTime != null &&
            itemStartTime.year == selectedDate.year &&
            itemStartTime.month == selectedDate.month &&
            itemStartTime.day == selectedDate.day) {
          scheduled.add(processedItem);
        } else {
          // Add to unscheduled - already filtered for non-done items above
          unscheduled.add(processedItem);
        }
      }

      // Sort scheduled items by start time
      scheduled.sort((a, b) {
        DateTime? aTime =
            (a is TaskModel) ? a.startTime : (a as SubtaskModel).startTime;
        DateTime? bTime =
            (b is TaskModel) ? b.startTime : (b as SubtaskModel).startTime;
        if (aTime == null || bTime == null) return 0;
        return aTime.compareTo(bTime);
      });

      // Sort unscheduled items by order property
      unscheduled.sort((a, b) {
        int aOrder = (a as SubtaskModel).order;
        int bOrder = (b as SubtaskModel).order;
        return aOrder.compareTo(bOrder);
      });

      state = state.copyWith(
        isLoading: false,
        scheduledItems: scheduled,
        unscheduledItems: unscheduled,
        subtaskPriorities: subtaskPriorities, // Store the priority map
        error: null,
      );
    } catch (e, s) {
      debugPrint("Error loading items: $e\n$s");
      state =
          state.copyWith(isLoading: false, error: 'Error loading items: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading items: $e')),
        );
      }
    }
  }

  // ...existing code...

  Future<void> scheduleTask(
    dynamic item, // Can be TaskModel or SubtaskModel
    TimeOfDay startTimeOfDay,
    TimeOfDay? endTimeOfDay, // This is optional
  ) async {
    try {
      final selectedDate = ref.read(selectedDateProvider);
      final now = DateTime.now();
      dynamic itemForStateUpdate;

      final startDateTime = DateTime(selectedDate.year, selectedDate.month,
          selectedDate.day, startTimeOfDay.hour, startTimeOfDay.minute);

      DateTime? endDateTime;
      String? itemRawEstimateString;

      if (item is TaskModel) {
        itemRawEstimateString = item.estimatedTime;
      } else if (item is SubtaskModel) {
        itemRawEstimateString = item.rawTimeValue;
      }

      if (endTimeOfDay != null) {
        endDateTime = DateTime(selectedDate.year, selectedDate.month,
            selectedDate.day, endTimeOfDay.hour, endTimeOfDay.minute);
      } else {
        int durationMinutes =
            _parseItemEstimatedTimeToMinutes(itemRawEstimateString);
        if (durationMinutes <= 0) {
          durationMinutes =
              60; // Default duration if estimate is missing, zero, or invalid
        }
        endDateTime = startDateTime.add(Duration(minutes: durationMinutes));
      }

      if (item is TaskModel) {
        itemForStateUpdate = item.copyWith(
          startTime: startDateTime,
          endTime: endDateTime,
          updatedAt: now,
        );
        await ref
            .read(taskServiceProvider)
            .updateTask(item.id, itemForStateUpdate as TaskModel);
      } else if (item is SubtaskModel) {
        itemForStateUpdate = item.copyWith(
          startTime: startDateTime,
          endTime: endDateTime,
          updatedAt: now,
        );
        await ref
            .read(subtaskServiceProvider)
            .updateSubtask(item.id, itemForStateUpdate as SubtaskModel);
      } else {
        throw Exception("Unknown item type for scheduling");
      }

      final String itemId =
          item is TaskModel ? item.id : (item as SubtaskModel).id;
      final newUnscheduled = state.unscheduledItems.where((t) {
        final String currentItemId =
            t is TaskModel ? t.id : (t as SubtaskModel).id;
        return currentItemId != itemId;
      }).toList();

      final newScheduled = [
        ...state.scheduledItems.where((t) {
          final String currentItemId =
              t is TaskModel ? t.id : (t as SubtaskModel).id;
          return currentItemId != itemId;
        }),
        itemForStateUpdate
      ];

      newScheduled.sort((a, b) {
        DateTime? aTime =
            (a is TaskModel) ? a.startTime : (a as SubtaskModel).startTime;
        DateTime? bTime =
            (b is TaskModel) ? b.startTime : (b as SubtaskModel).startTime;
        if (aTime == null || bTime == null) return 0;
        return aTime.compareTo(bTime);
      });

      state = state.copyWith(
        scheduledItems: newScheduled,
        unscheduledItems: newUnscheduled,
        error: null,
      );
      debugPrint(
          "TimeBlockController: scheduleTask completed for item ID: $itemId.");
    } catch (e, s) {
      debugPrint("TimeBlockController: Error in scheduleTask: $e\n$s");
      state = state.copyWith(error: 'Failed to schedule item: $e');
      if (e is Error) rethrow;
    }
  }

  Future<void> unscheduleTask(dynamic item, BuildContext context) async {
    try {
      dynamic updatedItem;
      final now = DateTime.now();
      if (item is TaskModel) {
        updatedItem =
            item.copyWith(startTime: null, endTime: null, updatedAt: now);
        await ref.read(taskServiceProvider).updateTask(item.id, updatedItem);
      } else if (item is SubtaskModel) {
        updatedItem =
            item.copyWith(startTime: null, endTime: null, updatedAt: now);
        await ref
            .read(subtaskServiceProvider)
            .updateSubtask(item.id, updatedItem);
      } else {
        throw Exception("Unknown item type for unscheduling");
      }

      final String itemId =
          (item is TaskModel) ? item.id : (item as SubtaskModel).id;
      final newScheduled = state.scheduledItems.where((t) {
        final String currentItemId =
            (t is TaskModel) ? t.id : (t as SubtaskModel).id;
        return currentItemId != itemId;
      }).toList();
      final newUnscheduled = [
        ...state.unscheduledItems.where((t) {
          final String currentItemId =
              (t is TaskModel) ? t.id : (t as SubtaskModel).id;
          return currentItemId != itemId;
        }),
        updatedItem
      ];

      state = state.copyWith(
        scheduledItems: newScheduled,
        unscheduledItems: newUnscheduled,
        error: null,
      );
    } catch (e, s) {
      debugPrint("Error in unscheduleTask: $e\n$s");
      state = state.copyWith(error: 'Failed to unschedule item: $e');
    }
  }

  Future<void> updateScheduledTaskTime(
    dynamic item,
    TimeOfDay newStartTimeOfDay,
  ) async {
    try {
      final selectedDate =
          state.currentSelectedDate ?? ref.read(selectedDateProvider);
      final now = DateTime.now();
      dynamic updatedItem;

      final newStartDateTime = DateTime(
        selectedDate!.year,
        selectedDate.month,
        selectedDate.day,
        newStartTimeOfDay.hour,
        newStartTimeOfDay.minute,
      );

      DateTime newEndDateTime;
      DateTime? currentStartTime, currentEndTime;
      String? itemRawEstimateString;

      if (item is TaskModel) {
        currentStartTime = item.startTime;
        currentEndTime = item.endTime;
        itemRawEstimateString = item.estimatedTime;
      } else if (item is SubtaskModel) {
        currentStartTime = item.startTime;
        currentEndTime = item.endTime;
        itemRawEstimateString = item.rawTimeValue;
      } else {
        throw Exception("Unknown item type for time update");
      }

      if (currentStartTime != null && currentEndTime != null) {
        // Preserve original duration if item was already scheduled with an explicit duration
        final originalDuration = currentEndTime.difference(currentStartTime);
        newEndDateTime = newStartDateTime.add(originalDuration);
      } else {
        // If no original duration, calculate from estimate
        int durationMinutes =
            _parseItemEstimatedTimeToMinutes(itemRawEstimateString);
        if (durationMinutes <= 0) {
          durationMinutes = 60; // Default duration
        }
        newEndDateTime =
            newStartDateTime.add(Duration(minutes: durationMinutes));
      }

      if (item is TaskModel) {
        updatedItem = item.copyWith(
          startTime: newStartDateTime,
          endTime: newEndDateTime,
          updatedAt: now,
        );
        await ref
            .read(taskServiceProvider)
            .updateTask(item.id, updatedItem as TaskModel);
      } else if (item is SubtaskModel) {
        updatedItem = item.copyWith(
          startTime: newStartDateTime,
          endTime: newEndDateTime,
          updatedAt: now,
        );
        await ref
            .read(subtaskServiceProvider)
            .updateSubtask(item.id, updatedItem as SubtaskModel);
      }

      final String itemId =
          item is TaskModel ? item.id : (item as SubtaskModel).id;
      final updatedScheduledList = state.scheduledItems.map((t) {
        final String currentItemId =
            t is TaskModel ? t.id : (t as SubtaskModel).id;
        return currentItemId == itemId ? updatedItem : t;
      }).toList();

      updatedScheduledList.sort((a, b) {
        DateTime? aTime =
            (a is TaskModel) ? a.startTime : (a as SubtaskModel).startTime;
        DateTime? bTime =
            (b is TaskModel) ? b.startTime : (b as SubtaskModel).startTime;
        if (aTime == null || bTime == null) return 0;
        return aTime.compareTo(bTime);
      });

      state = state.copyWith(scheduledItems: updatedScheduledList, error: null);
      debugPrint(
          "TimeBlockController: updateScheduledTaskTime completed for item ID: $itemId.");
    } catch (e, s) {
      debugPrint(
          "TimeBlockController: Error in updateScheduledTaskTime: $e\n$s");
      state = state.copyWith(error: 'Failed to update schedule: $e');
      if (e is Error) rethrow;
    }
  }
}

final timeBlockControllerProvider =
    StateNotifierProvider<TimeBlockController, TimeBlockState>((ref) {
  return TimeBlockController(ref);
});
