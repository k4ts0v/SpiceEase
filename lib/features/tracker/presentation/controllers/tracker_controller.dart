// Standard Flutter imports for debugging and UI components
import 'package:flutter/material.dart';

// Riverpod for state management and dependency injection
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Authentication provider for user management
import 'package:spiceease/core/auth/auth_provider.dart';

// Data models that define the structure of different tracked entities
import 'package:spiceease/data/models/energy_model.dart';
import 'package:spiceease/data/models/habit_model.dart';
import 'package:spiceease/data/models/medication_model.dart';
import 'package:spiceease/data/models/mood_model.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/models/symptom_model.dart';
import 'package:spiceease/data/models/task_model.dart';

// Providers that manage state for different entity types
import 'package:spiceease/data/providers/energy_provider.dart';
import 'package:spiceease/data/providers/habit_provider.dart';
import 'package:spiceease/data/providers/medication_provider.dart';
import 'package:spiceease/data/providers/mood_provider.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/data/providers/subtask_provider.dart';
import 'package:spiceease/data/providers/symptom_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';

/// Provider that creates and manages a single instance of TrackerController
/// This controller handles all business logic for the tracking features
final trackerControllerProvider = Provider((ref) => TrackerController(ref));

/// TrackerController manages all CRUD operations for tracking entities
/// It acts as a central hub for coordinating data operations and UI updates
class TrackerController {
  /// Reference to Riverpod's dependency injection system
  /// This allows access to other providers and services
  final Ref ref;

  /// Currently selected date for filtering data
  /// This determines which day's data to show/modify
  late final selectedDate = ref.watch(selectedDateProvider);

  TrackerController(this.ref);

  // ===== PROVIDER REFRESH METHODS =====
  // These methods handle updating the UI after data changes
  // Each method refreshes a specific type of data provider


  /// Refreshes only habit data for the given date
  void _refreshHabitsOnly(DateTime date) {
    ref.invalidate(habitStateNotifierProvider(date));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(habitStateNotifierProvider(date).notifier).fetchHabits();
    });
  }

  /// Refreshes only medication data for the given date
  void _refreshMedicationsOnly(DateTime date) {
    ref.invalidate(medicationStateNotifierProvider(date));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(medicationStateNotifierProvider(date).notifier)
          .fetchMedications();
    });
  }

  /// Refreshes only symptom data for the given date
  void _refreshSymptomsOnly(DateTime date) {
    ref.invalidate(symptomStateNotifierProvider(date));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(symptomStateNotifierProvider(date).notifier).fetchSymptoms();
    });
  }

  /// Refreshes only energy data for the given date
  void _refreshEnergiesOnly(DateTime date) {
    ref.invalidate(energyStateNotifierProvider(date));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(energyStateNotifierProvider(date).notifier).fetchEnergies();
    });
  }

  /// Refreshes only mood data for the given date
  void _refreshMoodOnly(DateTime date) {
    ref.invalidate(moodStateNotifierProvider(date));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(moodStateNotifierProvider(date).notifier).fetchMoods();
    });
  }

  /// Refreshes both task and subtask data
  /// Used when task operations might affect subtasks or vice versa
  void _refreshTaskProviders(DateTime date, {String? taskId}) {
    // Refresh main task list
    ref.invalidate(taskStateNotifierProvider(date));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskStateNotifierProvider(date).notifier).init();
      // If a specific task ID is provided, also refresh its subtasks
      if (taskId != null) {
        ref.invalidate(subtaskStateNotifierProvider(taskId));
        ref.read(subtaskStateNotifierProvider(taskId).notifier).refresh();
      }
    });
  }

  /// Helper method to get the current authenticated user's ID
  /// Throws an exception if no user is logged in
  Future<String> _getUserId() async {
    final user = await ref.read(authServiceProvider).getCurrentUser();
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  // ===== ENERGY TRACKING METHODS =====
  // Energy tracking allows users to record their energy levels throughout the day

  /// Adds a new energy level entry for the current time on the selected date
  /// @param energyLevel: Integer representing energy level (typically 1-10)
  /// @param notes: Optional notes about the energy level
  Future<void> addEnergy(int energyLevel, String? notes) async {
    final now = DateTime.now();
    // Combine selected date with current time for precise timestamping
    final combinedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
      now.microsecond,
    );

    final service = ref.read(energyServiceProvider);
    await service.createEnergy(EnergyModel(
      id: service.generateId(),
      userId: await _getUserId(),
      energyLevel: energyLevel,
      notes: notes,
      createdAt: combinedDate,
    ));

    // Update UI to show the new energy entry
    _refreshEnergiesOnly(selectedDate);
  }

  /// Updates an existing energy entry
  /// @param id: ID of the energy entry to update
  /// @param energyLevel: New energy level value
  /// @param notes: Updated notes
  Future<void> updateEnergy(String id, int energyLevel, String? notes) async {
    final now = DateTime.now();
    final combinedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
      now.microsecond,
    );

    final service = ref.read(energyServiceProvider);
    await service.updateEnergy(
      id,
      EnergyModel(
        id: id,
        userId: await _getUserId(),
        energyLevel: energyLevel,
        notes: notes,
        createdAt: combinedDate,
      ),
    );
    _refreshEnergiesOnly(selectedDate);
  }

  /// Deletes an energy entry
  /// @param id: ID of the energy entry to delete
  /// @param ref: Widget reference for accessing providers
  Future<void> deleteEnergy(String id, WidgetRef ref) async {
    final service = ref.read(energyServiceProvider);
    await service.deleteEnergy(id);
    _refreshEnergiesOnly(selectedDate);
  }

  // ===== MOOD TRACKING METHODS =====
  // Mood tracking allows users to record their emotional state

  /// Adds a new mood entry for the current time on the selected date
  /// @param moodLevel: Integer representing mood level (typically 1-10)
  /// @param notes: Optional notes about the mood
  Future<void> addMood(int moodLevel, String? notes) async {
    final now = DateTime.now();
    final combinedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
      now.microsecond,
    );

    final service = ref.read(moodServiceProvider);
    await service.createMood(MoodModel(
      id: service.generateId(),
      userId: await _getUserId(),
      moodLevel: moodLevel,
      notes: notes,
      createdAt: combinedDate,
      updatedAt: DateTime.now(),
    ));
    _refreshMoodOnly(selectedDate);
  }

  /// Updates an existing mood entry
  Future<void> updateMood(String id, int moodLevel, String? notes) async {
    final now = DateTime.now();
    final combinedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
      now.microsecond,
    );

    final service = ref.read(moodServiceProvider);
    await service.updateMood(
      id,
      MoodModel(
        id: id,
        userId: await _getUserId(),
        moodLevel: moodLevel,
        notes: notes,
        createdAt: combinedDate,
        updatedAt: DateTime.now(),
      ),
    );
    _refreshMoodOnly(selectedDate);
  }

  /// Deletes a mood entry
  Future<void> deleteMood(String id, WidgetRef ref) async {
    final service = ref.read(moodServiceProvider);
    await service.deleteMood(id);
    _refreshMoodOnly(selectedDate);
  }

  // ===== SYMPTOM TRACKING METHODS =====
  // Symptom tracking allows users to record health symptoms and their severity

  /// Adds a new symptom entry
  /// @param name: Name of the symptom
  /// @param category: Category the symptom belongs to
  /// @param severity: Severity level (typically 1-10)
  /// @param notes: Optional additional notes
  Future<void> addSymptom(
      String name, String category, int severity, String? notes) async {
    final selectedDate = ref.read(selectedDateProvider);
    final now = DateTime.now();

    // Create timestamp with selected date but current time
    final dateWithCurrentTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
      now.microsecond,
    );

    final service = ref.read(symptomServiceProvider);
    await service.createSymptom(SymptomModel(
      id: service.generateId(),
      userId: await _getUserId(),
      name: name,
      category: category,
      severity: severity,
      notes: notes,
      createdAt: dateWithCurrentTime,
      updatedAt: dateWithCurrentTime,
    ));
    _refreshSymptomsOnly(selectedDate);
  }

  /// Updates an existing symptom entry
  Future<void> updateSymptom(String id, String name, String category,
      int severity, String? notes) async {
    final service = ref.read(symptomServiceProvider);
    final now = DateTime.now();

    // Get the existing symptom to preserve original creation date
    final existingSymptom = await service.getSymptomById(id);
    if (existingSymptom == null) {
      throw Exception('Symptom not found');
    }

    // Update only the specified fields, keeping creation date intact
    final updatedSymptom = existingSymptom.copyWith(
      name: name,
      category: category,
      severity: severity,
      notes: notes,
      updatedAt: now,
    );

    await service.updateSymptom(id, updatedSymptom);
    _refreshSymptomsOnly(selectedDate);
  }

  /// Deletes a symptom entry
  Future<void> deleteSymptom(String id, WidgetRef ref) async {
    final service = ref.read(symptomServiceProvider);
    await service.deleteSymptom(id);
    _refreshSymptomsOnly(selectedDate);
  }

  // ===== MEDICATION TRACKING METHODS =====
  // Medication tracking helps users manage their medication schedules

  /// Adds a new medication to track
  /// @param name: Name of the medication
  /// @param dose: Dosage amount
  /// @param unit: Unit of measurement (mg, ml, etc.)
  /// @param frequency: How often to take (daily, weekly, etc.)
  /// @param customDays: Custom days for weekly/monthly schedules
  /// @param timesPerDay: How many times per day to take
  Future<void> addMedication({
    required String name,
    required double dose,
    required String unit,
    required String frequency,
    List<int>? customDays,
    required int timesPerDay,
  }) async {
    final service = ref.read(medicationServiceProvider);
    final userId = await service.getCurrentUserId();
    final id = service.generateId();
    final now = DateTime.now();

    // Create medication with initial empty completion history
    var medication = MedicationModel(
      id: id,
      userId: userId,
      name: name,
      dose: dose,
      unit: unit,
      frequency: frequency,
      customDays: customDays,
      timesPerDay: timesPerDay,
      completedDates: [],
      nextDueDate: null,
      createdAt: now,
      updatedAt: now,
    );

    // Calculate when this medication should next be due
    final initialNextDueDate = medication.calculateNextDueDate();
    medication = medication.copyWith(nextDueDate: initialNextDueDate);

    await service.createMedication(medication);
    _refreshMedicationsOnly(selectedDate);
  }

  /// Updates medication completion status with optimistic UI support
  /// @param id: Medication ID
  /// @param isCompleted: Whether the medication was taken
  /// @param forDate: Date the medication was taken
  /// @param skipRefresh: Skip UI refresh for optimistic updates
  Future<void> updateMedication({
    required String id,
    required bool isCompleted,
    required DateTime forDate,
    bool skipRefresh = false,
  }) async {
    final service = ref.read(medicationServiceProvider);
    final existingMed = await service.getMedicationById(id);

    if (existingMed == null) throw Exception('Medication not found');

    // Use date without time for consistent day-based tracking
    final dateOnly = DateTime(forDate.year, forDate.month, forDate.day);

    final updatedCompletedDates =
        List<DateTime>.from(existingMed.completedDates);

    // Check if this date is already marked as completed
    final isAlreadyCompleted = updatedCompletedDates.any((d) =>
        d.year == dateOnly.year &&
        d.month == dateOnly.month &&
        d.day == dateOnly.day);

    if (isCompleted && !isAlreadyCompleted) {
      // Mark as complete: add the date
      updatedCompletedDates.add(dateOnly);
    } else if (!isCompleted && isAlreadyCompleted) {
      // Mark as incomplete: remove all instances of this date
      updatedCompletedDates.removeWhere((d) =>
          d.year == dateOnly.year &&
          d.month == dateOnly.month &&
          d.day == dateOnly.day);
    } else {
      // No change needed - state is already correct
      return;
    }

    // Calculate new next due date based on updated completion history
    final tempMed = existingMed.copyWith(completedDates: updatedCompletedDates);
    final updatedMed = tempMed.copyWith(
      nextDueDate: tempMed.calculateNextDueDate(),
      updatedAt: DateTime.now(),
    );

    await service.updateMedication(id, updatedMed);

    // Only refresh UI if not using optimistic updates
    if (!skipRefresh) {
      _refreshMedicationsOnly(selectedDate);
    }
  }

  /// Updates medication details (name, dose, frequency, etc.)
  Future<void> updateMedicationDetails({
    required String id,
    required String name,
    required double dose,
    required String unit,
    required String frequency,
    List<int>? customDays,
    required int timesPerDay,
  }) async {
    final service = ref.read(medicationServiceProvider);
    final existingMed = await service.getMedicationById(id);
    if (existingMed == null) throw Exception('Medication not found');

    // Update medication details while preserving completion history
    final updatedMed = existingMed.copyWith(
      name: name,
      dose: dose,
      unit: unit,
      frequency: frequency,
      customDays: customDays,
      timesPerDay: timesPerDay,
      updatedAt: DateTime.now(),
    );

    await service.updateMedication(id, updatedMed);
    _refreshMedicationsOnly(selectedDate);
  }

  /// Deletes a medication
  Future<void> deleteMedication(String id) async {
    final service = ref.read(medicationServiceProvider);
    await service.deleteMedication(id);
    _refreshMedicationsOnly(selectedDate);
  }

  // ===== TASK MANAGEMENT METHODS =====
  // Task management for productivity tracking

  /// Creates a new task
  /// @param title: Task title
  /// @param description: Task description
  /// @param status: Initial status (todo/in_progress/done)
  /// @param dueDate: Optional due date
  /// @param completedAt: Completion timestamp if already done
  /// @param estimatedTime: Time estimate for completion
  /// @param priority: Priority level
  /// @param subtasks: List of subtasks
  /// @param startTime: When task was started
  /// @param endTime: When task was completed
  Future<void> addTask(
      {required String title,
      required String description,
      required String status,
      DateTime? dueDate,
      DateTime? completedAt,
      String? estimatedTime,
      required int priority,
      required List<SubtaskModel> subtasks,
      DateTime? startTime,
      DateTime? endTime}) async {
    final service = ref.read(taskServiceProvider);
    await service.createTask(TaskModel(
        id: service.generateId(),
        userId: await _getUserId(),
        title: title,
        description: description,
        status: status,
        dueDate: dueDate,
        completedAt: completedAt,
        estimatedTime: estimatedTime,
        priority: priority,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        startTime: startTime,
        endTime: endTime));

    _refreshTaskProviders(selectedDate);
  }

  /// Updates an existing task with optimistic UI support
  /// @param skipRefresh: Skip UI refresh for optimistic updates
  Future<void> updateTask(
    String id,
    String title,
    String description,
    String status,
    DateTime? dueDate,
    DateTime? completedAt,
    String? estimatedTime,
    int priority,
    List<SubtaskModel>? subtasks,
    DateTime? startTime,
    DateTime? endTime, {
    bool skipRefresh = false,
  }) async {
    final service = ref.read(taskServiceProvider);
    final existingTask = await service.getTaskById(id);

    if (existingTask == null) {
      throw Exception('Task not found');
    }

    // Handle completion logic
    String finalStatus = status;
    DateTime? finalCompletedAt = completedAt;

    if (status == 'Done') {
      // When marking as done, set completion timestamp
      finalCompletedAt = completedAt ?? DateTime.now();
      finalStatus = 'Done';
    } else {
      // When marking as not done, clear completion timestamp
      finalCompletedAt = null;
      finalStatus = status;
    }

    final updatedTask = existingTask.copyWith(
      title: title,
      description: description,
      status: finalStatus,
      dueDate: dueDate,
      completedAt: finalCompletedAt,
      estimatedTime: estimatedTime,
      priority: priority,
      updatedAt: DateTime.now(),
      startTime: startTime,
      endTime: endTime,
      clearCompletedAt: finalCompletedAt == null,
    );

    await service.updateTask(id, updatedTask);

    // Only refresh UI if not using optimistic updates
    if (!skipRefresh) {
      _refreshTaskProviders(selectedDate, taskId: id);
    }
  }

  /// Deletes a task and all its subtasks
  Future<void> deleteTask(String id) async {
    final service = ref.read(taskServiceProvider);
    await service.deleteTask(id);
    _refreshTaskProviders(selectedDate);
  }

  // ===== SUBTASK MANAGEMENT METHODS =====
  // Subtasks are smaller components of larger tasks

  /// Updates a subtask with optimistic UI support
  /// This method is called when users check/uncheck subtasks
  /// @param skipRefresh: Skip UI refresh to prevent rebuilds during optimistic updates
  Future<void> updateSubtask(
      String taskId,
      SubtaskModel subtask,
      String title,
      bool completed,
      String status,
      String rawTimeValue,
      DateTime? startTime,
      DateTime? endtime,
      {bool skipRefresh = false}) async {
    final taskService = ref.read(taskServiceProvider);
    final subtaskService = ref.read(subtaskServiceProvider);
    final userId = await taskService.getCurrentUserId();
    final selectedDate = ref.read(selectedDateProvider);

    // Determine final status and completion timestamp based on completion state
    String finalStatus = status;
    DateTime? completedAt;

    if (completed && status.toLowerCase() != 'done') {
      // Completing a subtask that wasn't marked as done
      finalStatus = 'done';
      completedAt =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    } else if (!completed && status.toLowerCase() == 'done') {
      // Uncompleting a subtask that was done
      finalStatus = 'in_progress';
      completedAt = null;
    } else if (completed && status.toLowerCase() == 'done') {
      // Already completed - preserve existing completion date
      completedAt = subtask.completedAt ??
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    } else {
      // No completion change
      completedAt = null;
    }

    final updatedSubtask = subtask.copyWith(
      title: title,
      completed: completed,
      rawTimeValue: rawTimeValue,
      startTime: startTime,
      endTime: endtime,
      status: finalStatus,
      userId: userId,
      completedAt: completedAt,
      updatedAt: DateTime.now(),
    );

    await subtaskService.updateSubtask(subtask.id, updatedSubtask);

    // Only refresh UI if not using optimistic updates
    // This prevents subtask list rebuilds when checking/unchecking
    if (!skipRefresh) {
      _refreshTaskProviders(selectedDate, taskId: taskId);
    }
  }

  /// Creates a new subtask for a task
  /// @param taskId: ID of the parent task
  /// @param title: Subtask title
  /// @param rawTimeValue: Time estimate string
  /// @param order: Order in the subtask list
  Future<void> createSubtask(
      String taskId, String title, String? rawTimeValue, int? order) async {
    final taskService = ref.read(taskServiceProvider);
    final subtaskService = ref.read(subtaskServiceProvider);
    final userId = await taskService.getCurrentUserId();

    // Calculate order based on existing subtasks
    final existingSubtasks = await subtaskService.getSubtasksForTask(taskId);
    final newOrder = existingSubtasks.length;

    final subtask = SubtaskModel(
      id: taskService.generateId(),
      taskId: taskId,
      userId: userId,
      title: title,
      order: newOrder,
      completed: false,
      status: 'todo',
      rawTimeValue: rawTimeValue,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await subtaskService.createSubtaskAndUpdateParent(subtask);
    _refreshTaskProviders(selectedDate, taskId: taskId);
  }

  /// Deletes a subtask
  Future<void> deleteSubtask(String subtaskId, String parentTaskId) async {
    final service = ref.read(subtaskServiceProvider);
    await service.deleteSubtaskAndUpdateParent(subtaskId);
    _refreshTaskProviders(selectedDate, taskId: parentTaskId);
  }

  // ===== HABIT TRACKING METHODS =====
  // Habits are recurring activities users want to track

  /// Creates a new habit
  /// @param title: Habit name
  /// @param description: Habit description
  /// @param frequency: How often (daily=1, weekly=7, etc.)
  /// @param customDays: Custom schedule for weekly/monthly habits
  Future<void> addHabit({
    required String title,
    required String description,
    required int frequency,
    List<int>? customDays,
  }) async {
    final service = ref.read(habitServiceProvider);
    final today = DateTime.now();

    // Calculate when this habit should next be due
    DateTime? nextDueDate =
        _calculateHabitNextDueDate(today, frequency, customDays);

    await service.createHabit(HabitModel(
      id: service.generateId(),
      userId: await _getUserId(),
      title: title,
      description: description,
      frequency: frequency,
      customDays: customDays,
      nextDueDate: nextDueDate,
      createdAt: today,
      updatedAt: today,
    ));

    _refreshHabitsOnly(selectedDate);
  }

  /// Updates habit details and completion status with optimistic UI support
  /// @param skipRefresh: Skip UI refresh for optimistic updates
  Future<void> updateHabit(
    String id,
    String title,
    String description,
    int frequency,
    List<int>? customDays,
    bool markAsCompleted, {
    bool skipRefresh = false,
  }) async {
    final service = ref.read(habitServiceProvider);
    final existingHabit = await service.getHabitById(id);

    if (existingHabit == null) throw Exception('Habit not found');

    final selectedDate = ref.read(selectedDateProvider);
    final dateOnly =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    // Toggle completion status for the selected date
    existingHabit.toggleCompletion(
        isCompleted: markAsCompleted, forDate: dateOnly);

    final updatedHabit = existingHabit.copyWith(
      title: title,
      description: description,
      frequency: frequency,
      customDays: customDays,
      nextDueDate: existingHabit.nextDueDate,
      updatedAt: DateTime.now(),
    );

    await service.updateHabit(id, updatedHabit);

    // Only refresh UI if not using optimistic updates
    if (!skipRefresh) {
      _refreshHabitsOnly(selectedDate);
    }
  }

  /// Deletes a habit
  Future<void> deleteHabit(String id) async {
    final service = ref.read(habitServiceProvider);

    try {
      await service.deleteHabit(id);
      _refreshHabitsOnly(selectedDate);
      debugPrint('Habit $id deleted successfully');
    } catch (e) {
      debugPrint('Error deleting habit: $e');
      rethrow;
    }
  }

  // ===== UTILITY METHODS =====
  // Helper methods for various calculations and operations

  /// Generates a unique ID for new entities
  String generateId() {
    final service = ref.read(taskServiceProvider);
    return service.generateId();
  }

  /// Gets the current user's ID
  Future<String> getUserId() async {
    return await _getUserId();
  }

  /// Calculates when a habit should next be due based on its frequency
  /// @param completedDate: When the habit was last completed
  /// @param frequency: Frequency type (1=daily, 7=weekly, -1=monthly)
  /// @param customDays: Custom days for weekly/monthly habits
  DateTime? _calculateHabitNextDueDate(
      DateTime completedDate, int frequency, List<int>? customDays) {
    if (frequency == 1) {
      // Daily habits: due tomorrow
      return completedDate.add(const Duration(days: 1));
    } else if (frequency == 7 && customDays != null && customDays.isNotEmpty) {
      // Weekly habits with custom days
      final todayWeekday = completedDate.weekday;
      final sortedDays = List<int>.from(customDays)..sort();

      // Find next scheduled weekday
      int nextDay = sortedDays.firstWhere(
        (day) => day > todayWeekday,
        orElse: () => sortedDays.first,
      );

      int daysToAdd = nextDay > todayWeekday
          ? nextDay - todayWeekday
          : 7 - todayWeekday + nextDay;

      return completedDate.add(Duration(days: daysToAdd));
    } else if (frequency == -1 && customDays != null && customDays.isNotEmpty) {
      // Monthly habits with custom days
      final todayDay = completedDate.day;
      final sortedDays = List<int>.from(customDays)..sort();

      // Find next scheduled day of month
      int nextDay = sortedDays.firstWhere(
        (day) => day > todayDay,
        orElse: () => sortedDays.first,
      );

      if (nextDay > todayDay) {
        return DateTime(completedDate.year, completedDate.month, nextDay);
      } else {
        return DateTime(completedDate.year, completedDate.month + 1, nextDay);
      }
    }

    return null;
  }

  // ===== ADDITIONAL HELPER METHODS =====

  /// Checks if a medication is due based on its schedule
  bool isMedicationDue(MedicationModel med) {
    if (med.completedDates.isEmpty) return true;

    final now = DateTime.now();
    final nextDue =
        _calculateNextDueDate(med.completedDates.last, med.frequency);
    return now.isAfter(nextDue);
  }

  /// Calculates next due date for medications based on frequency
  DateTime _calculateNextDueDate(DateTime lastCompletedDate, String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return lastCompletedDate.add(const Duration(days: 1));
      case 'weekly':
        return lastCompletedDate.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(
          lastCompletedDate.year,
          lastCompletedDate.month + 1,
          lastCompletedDate.day,
          lastCompletedDate.hour,
          lastCompletedDate.minute,
        );
      case 'hourly':
        return lastCompletedDate.add(const Duration(hours: 1));
      default:
        return lastCompletedDate.add(const Duration(days: 1));
    }
  }

  /// Legacy method for toggling medication completion
  /// @deprecated Use updateMedication instead
  Future<void> toggleMedicationCompletion(
      MedicationModel medication, bool isCompleted) async {
    final service = ref.read(medicationServiceProvider);
    final selectedDate = ref.read(selectedDateProvider);

    DateTime? nextDueDate;
    if (isCompleted) {
      final updatedMed = medication.copyWith(
        completedDates: [...medication.completedDates, selectedDate],
      );
      nextDueDate = updatedMed.calculateNextDueDate();
    }

    final updatedMed = medication.copyWith(
      completedDates: isCompleted
          ? [...medication.completedDates, selectedDate]
          : medication.completedDates,
      nextDueDate: nextDueDate,
      updatedAt: DateTime.now(),
    );

    await service.updateMedication(medication.id, updatedMed);
    _refreshMedicationsOnly(selectedDate);
  }

  /// Updates task status from drag-and-drop or other UI interactions
  Future<void> updateTaskStatus(
      String oldStatus, int index, String newStatus) async {
    final service = ref.read(taskServiceProvider);
    final tasks = await service.getTasksByStatus(oldStatus);
    if (index < tasks.length) {
      final task = tasks[index];
      await service.updateTask(
        task.id,
        task.copyWith(status: newStatus),
      );
      _refreshTaskProviders(selectedDate);
    }
  }

  // ===== DATA RETRIEVAL METHODS =====
  // Methods for fetching data without modifying it

  /// Gets all tasks for the selected date
  Future<List<TaskModel>> getAllTasks() async {
    final service = ref.read(taskServiceProvider);
    return await service.getAllTasksFiltered(selectedDate);
  }

  /// Gets tasks filtered by status for the selected date
  Future<List<TaskModel>> getTasksByStatus(String status) async {
    final service = ref.read(taskServiceProvider);
    return await service.getTasksByStatus(status, filterDate: selectedDate);
  }

  /// Gets tasks specifically for the selected date
  Future<List<TaskModel>> getTasksForSelectedDate() async {
    final service = ref.read(taskServiceProvider);
    return await service.getTasksForDate(selectedDate);
  }

  /// Gets subtasks for a specific task, filtered by selected date
  Future<List<SubtaskModel>> getSubtasksForTask(String taskId) async {
    final service = ref.read(subtaskServiceProvider);
    return await service.getSubtasksForTaskFiltered(taskId, selectedDate);
  }
}
