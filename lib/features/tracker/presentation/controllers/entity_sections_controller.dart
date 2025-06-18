import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data models
import 'package:spiceease/data/models/habit_model.dart';
import 'package:spiceease/data/models/medication_model.dart';
import 'package:spiceease/data/models/task_model.dart';

// Business logic controller
import 'package:spiceease/features/tracker/presentation/controllers/tracker_controller.dart';

// Internationalization
import 'package:spiceease/l10n/app_localizations.dart';

/// Controller that manages business logic for entity sections
///
/// This controller handles:
/// - Local state management for optimistic UI updates
/// - Backend update operations with error handling
/// - State synchronization between local and remote data
class EntitySectionsController extends StateNotifier<EntitySectionsState> {
  final Ref _ref;
  final DateTime _selectedDate;

  EntitySectionsController(this._ref, this._selectedDate)
      : super(EntitySectionsState.initial());

  // ===== LOCAL STATE MANAGEMENT =====

  /// Updates local medication count for optimistic UI
  void updateLocalMedicationCount(String medicationId, int count) {
    state = state.copyWith(
      localMedicationCounts: {
        ...state.localMedicationCounts,
        medicationId: count,
      },
    );
  }

  /// Updates local task completion status for optimistic UI
  void updateLocalTaskCompletion(String taskId, bool isCompleted) {
    state = state.copyWith(
      localTaskCompletion: {
        ...state.localTaskCompletion,
        taskId: isCompleted,
      },
    );
  }

  /// Updates local habit completion status for optimistic UI
  void updateLocalHabitCompletion(String habitId, bool isCompleted) {
    state = state.copyWith(
      localHabitCompletion: {
        ...state.localHabitCompletion,
        habitId: isCompleted,
      },
    );
  }

  /// Clears all local state (called when date changes)
  void clearLocalState() {
    state = state.copyWith(
      localMedicationCounts: {},
      localTaskCompletion: {},
      localHabitCompletion: {},
    );
  }

  // ===== EFFECTIVE STATE HELPERS =====

  /// Gets effective medication count (local state takes precedence)
  int getEffectiveMedicationCount(MedicationModel medication) {
    return state.localMedicationCounts[medication.id] ??
        medication.getTakenCountForDate(_selectedDate);
  }

  /// Gets effective task completion status (local state takes precedence)
  bool getEffectiveTaskCompletion(TaskModel task) {
    return state.localTaskCompletion[task.id] ??
        (task.status == 'Done' || task.completedAt != null);
  }

  /// Gets effective habit completion status (local state takes precedence)
  bool getEffectiveHabitCompletion(HabitModel habit) {
    if (state.localHabitCompletion.containsKey(habit.id)) {
      return state.localHabitCompletion[habit.id]!;
    }

    return habit.completedDates.any((d) =>
        d.year == _selectedDate.year &&
        d.month == _selectedDate.month &&
        d.day == _selectedDate.day);
  }

  // ===== MEDICATION OPERATIONS =====

  /// Updates medication completion status with optimistic UI
  Future<void> updateMedicationCompletion({
    required String medicationId,
    required bool isCompleted,
    required VoidCallback onError,
  }) async {
    // Optimistic update
    updateLocalMedicationCount(medicationId, isCompleted ? 1 : 0);

    try {
      final controller = _ref.read(trackerControllerProvider);
      await controller.updateMedication(
        id: medicationId,
        isCompleted: isCompleted,
        forDate: _selectedDate,
        skipRefresh: true,
      );
    } catch (e) {
      // Revert optimistic update on error
      state = state.copyWith(
        localMedicationCounts: Map.from(state.localMedicationCounts)
          ..remove(medicationId),
      );
      onError();
    }
  }

  /// Updates medication dose count with optimistic UI
  Future<void> updateMedicationDoseCount({
    required String medicationId,
    required int currentCount,
    required int newCount,
    required int timesPerDay,
    required VoidCallback onError,
  }) async {
    final wasCompleted = currentCount >= timesPerDay;
    final willBeCompleted = newCount >= timesPerDay;

    // Optimistic update
    updateLocalMedicationCount(medicationId, newCount);

    // Only update backend if completion status changes
    if (wasCompleted != willBeCompleted) {
      try {
        final controller = _ref.read(trackerControllerProvider);
        await controller.updateMedication(
          id: medicationId,
          isCompleted: willBeCompleted,
          forDate: _selectedDate,
          skipRefresh: true,
        );
      } catch (e) {
        // Revert optimistic update on error
        updateLocalMedicationCount(medicationId, currentCount);
        onError();
      }
    }
  }

  // ===== TASK OPERATIONS =====

  /// Updates task completion status with optimistic UI and delayed backend sync
  Future<void> updateTaskCompletion({
    required TaskModel task,
    required bool isCompleted,
    required VoidCallback onError,
  }) async {
    // Optimistic update
    updateLocalTaskCompletion(task.id, isCompleted);

    // Delayed backend update to prevent UI flickering
    Future.delayed(const Duration(milliseconds: 100), () async {
      try {
        final controller = _ref.read(trackerControllerProvider);
        await controller.updateTask(
          task.id,
          task.title,
          task.description,
          isCompleted ? 'Done' : 'In Progress',
          task.dueDate,
          isCompleted ? _selectedDate : null,
          task.estimatedTime,
          task.priority,
          null,
          task.startTime,
          task.endTime,
          skipRefresh: true,
        );
      } catch (e) {
        // Revert optimistic update on error
        state = state.copyWith(
          localTaskCompletion: Map.from(state.localTaskCompletion)
            ..remove(task.id),
        );
        onError();
      }
    });
  }

  // ===== HABIT OPERATIONS =====

  /// Updates habit completion status with optimistic UI and delayed backend sync
  Future<void> updateHabitCompletion({
    required HabitModel habit,
    required bool isCompleted,
    required VoidCallback onError,
  }) async {
    // Optimistic update
    updateLocalHabitCompletion(habit.id, isCompleted);

    // Delayed backend update to prevent UI flickering
    Future.delayed(const Duration(milliseconds: 100), () async {
      try {
        final controller = _ref.read(trackerControllerProvider);
        await controller.updateHabit(
          habit.id,
          habit.title,
          habit.description,
          habit.frequency,
          habit.customDays,
          isCompleted,
          skipRefresh: true,
        );
      } catch (e) {
        // Revert optimistic update on error
        state = state.copyWith(
          localHabitCompletion: Map.from(state.localHabitCompletion)
            ..remove(habit.id),
        );
        onError();
      }
    });
  }

  // ===== UTILITY METHODS =====

  /// Converts task status to localized string
  String getLocalizedStatus(String status, AppLocalizations localizations) {
    switch (status.toLowerCase()) {
      case 'done':
        return localizations.done;
      case 'in_progress':
        return localizations.inProgress;
      case 'todo':
      default:
        return localizations.todo;
    }
  }

  /// Converts habit frequency to localized string
  String getLocalizedFrequency(
      HabitModel habit, AppLocalizations localizations) {
    switch (habit.frequency) {
      case 1:
        return localizations.daily;
      case 7:
        return localizations.weekly;
      case -1:
        final days = habit.customDays?.join(', ') ?? '';
        return '${localizations.monthlyDays} $days';
      default:
        return '';
    }
  }
}

/// State class for EntitySectionsController
class EntitySectionsState {
  final Map<String, int> localMedicationCounts;
  final Map<String, bool> localTaskCompletion;
  final Map<String, bool> localHabitCompletion;

  const EntitySectionsState({
    required this.localMedicationCounts,
    required this.localTaskCompletion,
    required this.localHabitCompletion,
  });

  factory EntitySectionsState.initial() {
    return const EntitySectionsState(
      localMedicationCounts: {},
      localTaskCompletion: {},
      localHabitCompletion: {},
    );
  }

  EntitySectionsState copyWith({
    Map<String, int>? localMedicationCounts,
    Map<String, bool>? localTaskCompletion,
    Map<String, bool>? localHabitCompletion,
  }) {
    return EntitySectionsState(
      localMedicationCounts:
          localMedicationCounts ?? this.localMedicationCounts,
      localTaskCompletion: localTaskCompletion ?? this.localTaskCompletion,
      localHabitCompletion: localHabitCompletion ?? this.localHabitCompletion,
    );
  }
}

/// Provider for EntitySectionsController
final entitySectionsControllerProvider = StateNotifierProvider.family<
    EntitySectionsController, EntitySectionsState, DateTime>(
  (ref, selectedDate) => EntitySectionsController(ref, selectedDate),
);
