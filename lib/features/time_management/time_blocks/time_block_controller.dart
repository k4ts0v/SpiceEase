// Standard Flutter imports for UI components and async operations
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data models for tasks and subtasks
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/models/task_model.dart';

// Providers for date selection and data services
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/data/providers/subtask_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';

// ===== TIME BLOCK STATE MANAGEMENT =====
// This controller manages the scheduling and organization of tasks and subtasks
// into time blocks for the selected date

/// Immutable state class that holds all time block related data
/// This represents the current state of scheduled and unscheduled items
class TimeBlockState {
  /// List of items (tasks or subtasks) that have been scheduled with specific times
  final List<dynamic> scheduledItems; // Can be TaskModel or SubtaskModel

  /// List of items (tasks or subtasks) that haven't been assigned specific times
  final List<dynamic> unscheduledItems; // Can be TaskModel or SubtaskModel

  /// Loading indicator for async operations
  final bool isLoading;

  /// Error message if any operation fails
  final String? error;

  /// The currently selected date for time block management
  final DateTime? currentSelectedDate;

  /// Maps subtask IDs to their parent task's priority for proper sorting
  /// This is necessary because subtasks don't have their own priority
  final Map<String, int> subtaskPriorities;

  const TimeBlockState({
    this.scheduledItems = const [],
    this.unscheduledItems = const [],
    this.isLoading = false,
    this.error,
    this.currentSelectedDate,
    this.subtaskPriorities = const {},
  });

  /// Creates a new state instance with updated values
  /// This follows the immutable state pattern for proper state management
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

// ===== TIME BLOCK CONTROLLER =====
// Main controller class that manages time block operations

/// StateNotifier that manages time block state and operations
/// Handles loading, scheduling, unscheduling, and updating items
class TimeBlockController extends StateNotifier<TimeBlockState> {
  /// Reference to Riverpod's dependency injection system
  final Ref ref;

  TimeBlockController(this.ref) : super(const TimeBlockState());

  // ===== UTILITY METHODS =====

  /// Gets the priority for a subtask from the cached priority map
  /// Subtasks inherit their priority from their parent task
  /// Returns default priority of 3 (medium) if not found
  int getPriorityForSubtask(String subtaskId) {
    return state.subtaskPriorities[subtaskId] ??
        3; // Default to medium priority
  }

  /// Parses various time estimate formats into minutes
  /// Supports formats like "2h 30m", "1.5 hours", "90 minutes", etc.
  /// This is used for both tasks and subtasks to calculate durations
  int _parseItemEstimatedTimeToMinutes(String? estimatedTimeStr) {
    if (estimatedTimeStr == null || estimatedTimeStr.isEmpty) return 0;
    String timeStr = estimatedTimeStr.toLowerCase().trim();
    int totalMinutes = 0;

    // Parse hours using regex pattern
    // Matches patterns like "2h", "1.5 hours", "2 hr"
    final hourPattern = RegExp(r"(\d*\.?\d+)\s*(?:h|hr|hour|hours)");
    var match = hourPattern.firstMatch(timeStr);
    if (match != null) {
      try {
        totalMinutes += (double.parse(match.group(1)!) * 60).round();
        timeStr = timeStr.replaceFirst(match.group(0)!, "").trim();
      } catch (_) {
        // Ignore parsing errors and continue
      }
    }

    // Parse minutes using regex pattern
    // Matches patterns like "30m", "45 minutes", "20 min"
    final minPattern = RegExp(r"(\d*\.?\d+)\s*(?:m|min|minute|minutes)");
    match = minPattern.firstMatch(timeStr);
    if (match != null) {
      try {
        totalMinutes += (double.parse(match.group(1)!)).round();
        timeStr = timeStr.replaceFirst(match.group(0)!, "").trim();
      } catch (_) {
        // Ignore parsing errors and continue
      }
    }

    // Parse seconds using regex pattern
    // Matches patterns like "30s", "45 seconds", "20 sec"
    // Converts to minutes (rounded up)
    final secPattern = RegExp(r"(\d*\.?\d+)\s*(?:s|sec|second|seconds)");
    match = secPattern.firstMatch(timeStr);
    if (match != null) {
      try {
        totalMinutes += (double.parse(match.group(1)!) / 60).ceil();
        timeStr = timeStr.replaceFirst(match.group(0)!, "").trim();
      } catch (_) {
        // Ignore parsing errors and continue
      }
    }

    // If only a number remains after removing time units, assume it's minutes
    if (totalMinutes == 0 && timeStr.isNotEmpty) {
      final justNumberPattern = RegExp(r"^(\d*\.?\d+)$");
      match = justNumberPattern.firstMatch(timeStr);
      if (match != null) {
        try {
          totalMinutes = (double.parse(match.group(1)!)).round();
        } catch (_) {
          // Ignore parsing errors
        }
      }
    }
    return totalMinutes; // Returns 0 if parsing fails or estimate is "0"
  }

  // ===== DATA LOADING METHODS =====

  /// Loads all tasks and subtasks for the selected date
  /// Separates them into scheduled (with times) and unscheduled items
  /// This is the main method for populating the time block view
  Future<void> loadTasks(BuildContext context) async {
    // Set loading state and capture current selected date
    state = state.copyWith(
        isLoading: true, currentSelectedDate: ref.read(selectedDateProvider));
    final selectedDate = ref.read(selectedDateProvider);

    try {
      // ===== LOAD TASKS AND SUBTASKS =====
      // Get all tasks for the selected date
      final List<TaskModel> tasks =
          await ref.read(taskServiceProvider).getTasksForDate(selectedDate);
      final List<SubtaskModel> allSubtasksForDay = [];
      final Map<String, int> subtaskPriorities = {}; // Build priority map

      // Load subtasks for tasks that have them
      // Also build the priority mapping for subtasks
      for (final task in tasks) {
        if (task.hasSubtasks) {
          final subtasksForThisTask = await ref
              .read(subtaskServiceProvider)
              .getSubtasksForTask(task.id);
          // Load ALL subtasks, not just those with startTime
          allSubtasksForDay.addAll(subtasksForThisTask);

          // Map each subtask to its parent task's priority
          // This allows subtasks to be sorted by their parent's priority
          for (final subtask in subtasksForThisTask) {
            subtaskPriorities[subtask.id] = task.priority;
          }
        }
      }

      // ===== FILTER ITEMS =====
      // Remove completed tasks and parent tasks that have subtasks
      final List<TaskModel> filteredTasks = tasks.where((task) {
        // Filter out done tasks - they shouldn't appear in time blocks
        if (task.status == 'Done') return false;
        // Filter out parent tasks that have subtasks
        // We show subtasks individually instead of the parent
        if (task.hasSubtasks) return false;
        return true;
      }).toList();

      // Filter out completed subtasks
      final List<SubtaskModel> filteredSubtasks =
          allSubtasksForDay.where((subtask) {
        return !subtask.completed;
      }).toList();

      // ===== PROCESS AND CATEGORIZE ITEMS =====
      // Combine tasks and subtasks into a single list for processing
      final List<dynamic> allItems = [...filteredTasks, ...filteredSubtasks];
      final scheduled = <dynamic>[];
      final unscheduled = <dynamic>[];

      for (final item in allItems) {
        dynamic processedItem = item;
        DateTime? itemStartTime;
        DateTime? itemEndTime;
        String? itemEstimateString;

        // Extract time information based on item type
        if (item is TaskModel) {
          itemStartTime = item.startTime;
          itemEndTime = item.endTime;
          itemEstimateString = item.estimatedTime;
        } else if (item is SubtaskModel) {
          itemStartTime = item.startTime;
          itemEndTime = item.endTime;
          itemEstimateString = item.rawTimeValue;
        }

        // ===== ADDITIONAL SAFETY CHECKS =====
        // Skip items completed before the selected date
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

        // ===== AUTO-CALCULATE END TIMES =====
        // If item has start time but no end time, calculate end time from estimate
        if (itemStartTime != null &&
            itemEndTime == null &&
            itemEstimateString != null) {
          int minutes = _parseItemEstimatedTimeToMinutes(itemEstimateString);
          if (minutes > 0) {
            DateTime calculatedEndTime =
                itemStartTime.add(Duration(minutes: minutes));

            // Update the item with calculated end time
            if (item is TaskModel) {
              processedItem = item.copyWith(endTime: calculatedEndTime);
              // Persist the calculated end time to database
              await ref
                  .read(taskServiceProvider)
                  .updateTask(item.id, processedItem);
            } else if (item is SubtaskModel) {
              processedItem = item.copyWith(endTime: calculatedEndTime);
              // Persist the calculated end time to database
              await ref
                  .read(subtaskServiceProvider)
                  .updateSubtask(item.id, processedItem);
            }
          }
        }

        // ===== CATEGORIZE INTO SCHEDULED/UNSCHEDULED =====
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

      // ===== SORT ITEMS =====
      // Sort scheduled items by start time for chronological display
      scheduled.sort((a, b) {
        DateTime? aTime =
            (a is TaskModel) ? a.startTime : (a as SubtaskModel).startTime;
        DateTime? bTime =
            (b is TaskModel) ? b.startTime : (b as SubtaskModel).startTime;
        if (aTime == null || bTime == null) return 0;
        return aTime.compareTo(bTime);
      });

      // Note: Unscheduled items sorting is commented out
      // They could be sorted by order property if needed in the future
      // unscheduled.sort((a, b) {
      //   int aOrder = (a).order;
      //   int bOrder = (b).order;
      //   return aOrder.compareTo(bOrder);
      // });

      // ===== UPDATE STATE =====
      // Update the state with loaded and processed data
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

      // Show error to user if context is available
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading items: $e')),
        );
      }
    }
  }

  // ===== SCHEDULING METHODS =====

  /// Schedules a task or subtask with specific start and optional end times
  /// If no end time is provided, calculates it from the item's estimated duration
  /// Updates both database and local state
  Future<void> scheduleTask(
    dynamic item, // Can be TaskModel or SubtaskModel
    TimeOfDay startTimeOfDay,
    TimeOfDay? endTimeOfDay, // This is optional
  ) async {
    try {
      final selectedDate = ref.read(selectedDateProvider);
      final now = DateTime.now();
      dynamic itemForStateUpdate;

      // ===== CALCULATE START TIME =====
      // Convert TimeOfDay to DateTime for the selected date
      final startDateTime = DateTime(selectedDate.year, selectedDate.month,
          selectedDate.day, startTimeOfDay.hour, startTimeOfDay.minute);

      DateTime? endDateTime;
      String? itemRawEstimateString;

      // Extract estimate string based on item type
      if (item is TaskModel) {
        itemRawEstimateString = item.estimatedTime;
      } else if (item is SubtaskModel) {
        itemRawEstimateString = item.rawTimeValue;
      }

      // ===== CALCULATE END TIME =====
      if (endTimeOfDay != null) {
        // Use provided end time
        endDateTime = DateTime(selectedDate.year, selectedDate.month,
            selectedDate.day, endTimeOfDay.hour, endTimeOfDay.minute);
      } else {
        // Calculate end time from estimate or use default duration
        int durationMinutes =
            _parseItemEstimatedTimeToMinutes(itemRawEstimateString);
        if (durationMinutes <= 0) {
          durationMinutes =
              60; // Default duration if estimate is missing, zero, or invalid
        }
        endDateTime = startDateTime.add(Duration(minutes: durationMinutes));
      }

      // ===== UPDATE DATABASE =====
      // Update the item in the database with new times
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

      // ===== UPDATE LOCAL STATE =====
      final String itemId =
          item is TaskModel ? item.id : (item as SubtaskModel).id;

      // Remove item from unscheduled list
      final newUnscheduled = state.unscheduledItems.where((t) {
        final String currentItemId =
            t is TaskModel ? t.id : (t as SubtaskModel).id;
        return currentItemId != itemId;
      }).toList();

      // Add item to scheduled list (replacing if it already exists)
      final newScheduled = [
        ...state.scheduledItems.where((t) {
          final String currentItemId =
              t is TaskModel ? t.id : (t as SubtaskModel).id;
          return currentItemId != itemId;
        }),
        itemForStateUpdate
      ];

      // Sort scheduled items by start time
      newScheduled.sort((a, b) {
        DateTime? aTime =
            (a is TaskModel) ? a.startTime : (a as SubtaskModel).startTime;
        DateTime? bTime =
            (b is TaskModel) ? b.startTime : (b as SubtaskModel).startTime;
        if (aTime == null || bTime == null) return 0;
        return aTime.compareTo(bTime);
      });

      // Update state with new lists
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

  /// Removes scheduling from a task or subtask (moves from scheduled to unscheduled)
  /// Clears start and end times from both database and local state
  Future<void> unscheduleTask(dynamic item, BuildContext context) async {
    try {
      debugPrint(
          'TimeBlockController: Starting unscheduleTask for item type: ${item.runtimeType}');

      dynamic updatedItem;
      final now = DateTime.now();

      // ===== UPDATE DATABASE =====
      // Clear start and end times based on item type
      if (item is TaskModel) {
        debugPrint(
            'TimeBlockController: Unscheduling TaskModel with ID: ${item.id}');
        updatedItem = item.copyWith(
          startTime: null,
          endTime: null,
          updatedAt: now,
          clearStartTime: true,
          clearEndTime: true,
        );
        await ref.read(taskServiceProvider).updateTask(item.id, updatedItem);
        debugPrint('TimeBlockController: TaskModel updated in database');
      } else if (item is SubtaskModel) {
        debugPrint(
            'TimeBlockController: Unscheduling SubtaskModel with ID: ${item.id}');
        // Clear start and end times for subtasks
        updatedItem = item.copyWith(
          startTime: null,
          endTime: null,
          updatedAt: now,
          clearStartTime: true,
          clearEndTime: true,
        );
        await ref
            .read(subtaskServiceProvider)
            .updateSubtask(item.id, updatedItem);
        debugPrint('TimeBlockController: SubtaskModel updated in database');
      } else {
        throw Exception(
            "Unknown item type for unscheduling: ${item.runtimeType}");
      }

      // ===== UPDATE LOCAL STATE =====
      final String itemId =
          (item is TaskModel) ? item.id : (item as SubtaskModel).id;

      // Remove from scheduled items
      final newScheduled = state.scheduledItems.where((t) {
        final String currentItemId =
            (t is TaskModel) ? t.id : (t as SubtaskModel).id;
        return currentItemId != itemId;
      }).toList();

      // Add to unscheduled items (avoid duplicates)
      final existingUnscheduledIds = state.unscheduledItems.map((t) {
        return (t is TaskModel) ? t.id : (t as SubtaskModel).id;
      }).toSet();

      final newUnscheduled = [...state.unscheduledItems];
      if (!existingUnscheduledIds.contains(itemId)) {
        newUnscheduled.add(updatedItem);
      }

      // ===== SORT UNSCHEDULED ITEMS =====
      // Sort by priority (higher first), then by creation time
      newUnscheduled.sort((a, b) {
        // Get priority for comparison
        int aPriority = 3; // default medium priority
        int bPriority = 3; // default medium priority

        if (a is TaskModel) {
          aPriority = a.priority;
        } else if (a is SubtaskModel) {
          aPriority = getPriorityForSubtask(a.id);
        }

        if (b is TaskModel) {
          bPriority = b.priority;
        } else if (b is SubtaskModel) {
          bPriority = getPriorityForSubtask(b.id);
        }

        // Sort by priority first (higher priority first), then by creation time
        if (aPriority != bPriority) {
          return bPriority.compareTo(aPriority); // Higher priority first
        }

        // If same priority, sort by creation time
        DateTime aCreated =
            (a is TaskModel) ? a.createdAt : (a as SubtaskModel).createdAt;
        DateTime bCreated =
            (b is TaskModel) ? b.createdAt : (b as SubtaskModel).createdAt;
        return aCreated.compareTo(bCreated);
      });

      // Update state with new lists
      state = state.copyWith(
        scheduledItems: newScheduled,
        unscheduledItems: newUnscheduled,
        error: null,
      );

      debugPrint(
          'TimeBlockController: State updated successfully. Scheduled: ${newScheduled.length}, Unscheduled: ${newUnscheduled.length}');
    } catch (e, s) {
      debugPrint("TimeBlockController: Error in unscheduleTask: $e");
      debugPrint("Stack trace: $s");

      state = state.copyWith(error: 'Failed to unschedule item: $e');

      // Show error to user if context is still mounted
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unschedule item: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      rethrow; // Re-throw to allow calling code to handle
    }
  }

  /// Updates the start time of an already scheduled item
  /// Preserves the original duration if possible, or calculates new duration from estimate
  /// Used when user drags scheduled items to different times
  Future<void> updateScheduledTaskTime(
    dynamic item,
    TimeOfDay newStartTimeOfDay,
  ) async {
    try {
      final selectedDate =
          state.currentSelectedDate ?? ref.read(selectedDateProvider);
      final now = DateTime.now();
      dynamic updatedItem;

      // ===== CALCULATE NEW START TIME =====
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

      // Extract current timing information based on item type
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

      // ===== CALCULATE NEW END TIME =====
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

      // ===== UPDATE DATABASE =====
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

      // ===== UPDATE LOCAL STATE =====
      final String itemId =
          item is TaskModel ? item.id : (item as SubtaskModel).id;

      // Update the item in the scheduled list
      final updatedScheduledList = state.scheduledItems.map((t) {
        final String currentItemId =
            t is TaskModel ? t.id : (t as SubtaskModel).id;
        return currentItemId == itemId ? updatedItem : t;
      }).toList();

      // Re-sort scheduled items by start time
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

// ===== PROVIDER SETUP =====
/// Riverpod provider that creates and manages the TimeBlockController instance
/// This allows the controller to be accessed throughout the widget tree
final timeBlockControllerProvider =
    StateNotifierProvider<TimeBlockController, TimeBlockState>((ref) {
  return TimeBlockController(ref);
});
