import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/data/models/energy_model.dart';
import 'package:spiceease/data/models/habit_model.dart';
import 'package:spiceease/data/models/medication_model.dart';
import 'package:spiceease/data/models/mood_model.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/models/symptom_model.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/energy_provider.dart';
import 'package:spiceease/data/providers/habit_provider.dart';
import 'package:spiceease/data/providers/medication_provider.dart';
import 'package:spiceease/data/providers/mood_provider.dart';
import 'package:spiceease/data/providers/selected_date_provider.dart';
import 'package:spiceease/data/providers/subtask_provider.dart';
import 'package:spiceease/data/providers/symptom_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';

final trackerControllerProvider = Provider((ref) => TrackerController(ref));

class TrackerController {
  final Ref ref;
  late final selectedDate = ref.watch(selectedDateProvider);

  TrackerController(this.ref);

  void _refreshTasksOnly(DateTime date) {
    ref.invalidate(taskStateNotifierProvider(date));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskStateNotifierProvider(date).notifier).init();
    });
  }

  void _refreshHabitsOnly(DateTime date) {
    ref.invalidate(habitStateNotifierProvider(date));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(habitStateNotifierProvider(date).notifier).fetchHabits();
    });
  }

  void _refreshMedicationsOnly(DateTime date) {
    ref.invalidate(medicationStateNotifierProvider(date));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(medicationStateNotifierProvider(date).notifier)
          .fetchMedications();
    });
  }

  void _refreshSymptomsOnly(DateTime date) {
    ref.invalidate(symptomStateNotifierProvider(date));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(symptomStateNotifierProvider(date).notifier).fetchSymptoms();
    });
  }

  void _refreshEnergiesOnly(DateTime date) {
    ref.invalidate(energyStateNotifierProvider(date));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(energyStateNotifierProvider(date).notifier).fetchEnergies();
    });
  }

  void _refreshMoodOnly(DateTime date) {
    ref.invalidate(moodStateNotifierProvider(date));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(moodStateNotifierProvider(date).notifier).fetchMoods();
    });
  }

  // Helper method to refresh task-related providers
  void _refreshTaskProviders(DateTime date, {String? taskId}) {
    ref.invalidate(taskStateNotifierProvider(date));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskStateNotifierProvider(date).notifier).init();
      if (taskId != null) {
        ref.invalidate(subtaskStateNotifierProvider(taskId));
        ref.read(subtaskStateNotifierProvider(taskId).notifier).refresh();
      }
    });
  }

  Future<String> _getUserId() async {
    final user = await ref.read(authServiceProvider).getCurrentUser();
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  // Energy methods - updated with unified refresh
  Future<void> addEnergy(int energyLevel, String? notes) async {
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
    await service.createEnergy(EnergyModel(
      id: service.generateId(),
      userId: await _getUserId(),
      energyLevel: energyLevel,
      notes: notes,
      createdAt: combinedDate,
    ));
    _refreshEnergiesOnly(selectedDate);
  }

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

  Future<void> deleteEnergy(String id, WidgetRef ref) async {
    final service = ref.read(energyServiceProvider);
    await service.deleteEnergy(id);
    _refreshEnergiesOnly(selectedDate);
  }

  // Mood methods - updated with unified refresh
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

  Future<void> deleteMood(String id, WidgetRef ref) async {
    final service = ref.read(moodServiceProvider);
    await service.deleteMood(id);
    _refreshMoodOnly(selectedDate);
  }

  // Symptoms - updated with unified refresh
  Future<void> addSymptom(
      String name, String category, int severity, String? notes) async {
    final selectedDate = ref.read(selectedDateProvider);
    final now = DateTime.now();

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

  Future<void> updateSymptom(String id, String name, String category,
      int severity, String? notes) async {
    final service = ref.read(symptomServiceProvider);
    final now = DateTime.now();

    final existingSymptom = await service.getSymptomById(id);
    if (existingSymptom == null) {
      throw Exception('Symptom not found');
    }

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

  Future<void> deleteSymptom(String id, WidgetRef ref) async {
    final service = ref.read(symptomServiceProvider);
    await service.deleteSymptom(id);
    _refreshSymptomsOnly(selectedDate);
  }

  // Medication methods - updated to NOT refresh when using optimistic updates
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

    final initialNextDueDate = medication.calculateNextDueDate();
    medication = medication.copyWith(nextDueDate: initialNextDueDate);

    await service.createMedication(medication);
    _refreshMedicationsOnly(selectedDate);
  }

  // ...existing code...
  // Updated to NOT refresh when using optimistic updates
  Future<void> updateMedication({
    required String id,
    required bool isCompleted, // Changed from newCount to a boolean flag
    required DateTime forDate,
    bool skipRefresh = false,
  }) async {
    final service = ref.read(medicationServiceProvider);
    final existingMed = await service.getMedicationById(id);

    if (existingMed == null) throw Exception('Medication not found');

    // Use a date with no time component for consistent day-based checks
    final dateOnly = DateTime(forDate.year, forDate.month, forDate.day);

    final updatedCompletedDates =
        List<DateTime>.from(existingMed.completedDates);

    // Check if the date is already in the list
    final isAlreadyCompleted = updatedCompletedDates.any((d) =>
        d.year == dateOnly.year &&
        d.month == dateOnly.month &&
        d.day == dateOnly.day);

    if (isCompleted && !isAlreadyCompleted) {
      // If we need to mark it as complete and it's not already, add the date.
      updatedCompletedDates.add(dateOnly);
    } else if (!isCompleted && isAlreadyCompleted) {
      // If we need to mark it as not complete and it is, remove all instances of the date.
      updatedCompletedDates.removeWhere((d) =>
          d.year == dateOnly.year &&
          d.month == dateOnly.month &&
          d.day == dateOnly.day);
    } else {
      // No change needed, state is already correct.
      return;
    }

    final tempMed = existingMed.copyWith(completedDates: updatedCompletedDates);
    final updatedMed = tempMed.copyWith(
      nextDueDate: tempMed.calculateNextDueDate(),
      updatedAt: DateTime.now(),
    );

    await service.updateMedication(id, updatedMed);

    // Only refresh if not using optimistic updates
    if (!skipRefresh) {
      _refreshMedicationsOnly(selectedDate);
    }
  }

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

  Future<void> deleteMedication(String id) async {
    final service = ref.read(medicationServiceProvider);
    await service.deleteMedication(id);
    _refreshMedicationsOnly(selectedDate);
  }

  // Tasks - updated to NOT refresh when using optimistic updates
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

  // Updated to NOT refresh when using optimistic updates
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
    bool skipRefresh = false, // Add flag to skip refresh for optimistic updates
  }) async {
    final service = ref.read(taskServiceProvider);
    final existingTask = await service.getTaskById(id);

    if (existingTask == null) {
      throw Exception('Task not found');
    }

    String finalStatus = status;
    DateTime? finalCompletedAt = completedAt;

    if (status == 'Done') {
      finalCompletedAt = completedAt ?? DateTime.now();
      finalStatus = 'Done';
    } else {
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

    // Only refresh if not using optimistic updates
    if (!skipRefresh) {
      _refreshTaskProviders(selectedDate, taskId: id);
    }
  }

  Future<void> deleteTask(String id) async {
    final service = ref.read(taskServiceProvider);
    await service.deleteTask(id);
    _refreshTaskProviders(selectedDate);
  }

  // Update the updateSubtask method around line 450

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
    // Add skipRefresh parameter
    final taskService = ref.read(taskServiceProvider);
    final subtaskService = ref.read(subtaskServiceProvider);
    final userId = await taskService.getCurrentUserId();
    final selectedDate = ref.read(selectedDateProvider);

    String finalStatus = status;
    DateTime? completedAt;

    if (completed && status.toLowerCase() != 'done') {
      finalStatus = 'done';
      completedAt =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    } else if (!completed && status.toLowerCase() == 'done') {
      finalStatus = 'in_progress';
      completedAt = null;
    } else if (completed && status.toLowerCase() == 'done') {
      completedAt = subtask.completedAt ??
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    } else {
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

    // Only refresh if not using optimistic updates
    if (!skipRefresh) {
      _refreshTaskProviders(selectedDate, taskId: taskId);
    }
  }

  Future<void> createSubtask(
      String taskId, String title, String? rawTimeValue, int? order) async {
    final taskService = ref.read(taskServiceProvider);
    final subtaskService = ref.read(subtaskServiceProvider);
    final userId = await taskService.getCurrentUserId();

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

  Future<void> deleteSubtask(String subtaskId, String parentTaskId) async {
    final service = ref.read(subtaskServiceProvider);
    await service.deleteSubtaskAndUpdateParent(subtaskId);
    _refreshTaskProviders(selectedDate, taskId: parentTaskId);
  }

  // Habits - updated to NOT refresh when using optimistic updates
  Future<void> addHabit({
    required String title,
    required String description,
    required int frequency,
    List<int>? customDays,
  }) async {
    final service = ref.read(habitServiceProvider);
    final today = DateTime.now();

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

  // Updated to NOT refresh when using optimistic updates
  Future<void> updateHabit(
    String id,
    String title,
    String description,
    int frequency,
    List<int>? customDays,
    bool markAsCompleted, {
    bool skipRefresh = false, // Add flag to skip refresh for optimistic updates
  }) async {
    final service = ref.read(habitServiceProvider);
    final existingHabit = await service.getHabitById(id);

    if (existingHabit == null) throw Exception('Habit not found');

    final selectedDate = ref.read(selectedDateProvider);
    final dateOnly =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

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

    // Only refresh if not using optimistic updates
    if (!skipRefresh) {
      _refreshHabitsOnly(selectedDate);
    }
  }

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

  // ... rest of the existing methods remain the same ...

  String generateId() {
    final service = ref.read(taskServiceProvider);
    return service.generateId();
  }

  Future<String> getUserId() async {
    return await _getUserId();
  }

  DateTime? _calculateHabitNextDueDate(
      DateTime completedDate, int frequency, List<int>? customDays) {
    if (frequency == 1) {
      return completedDate.add(const Duration(days: 1));
    } else if (frequency == 7 && customDays != null && customDays.isNotEmpty) {
      final todayWeekday = completedDate.weekday;
      final sortedDays = List<int>.from(customDays)..sort();

      int nextDay = sortedDays.firstWhere(
        (day) => day > todayWeekday,
        orElse: () => sortedDays.first,
      );

      int daysToAdd = nextDay > todayWeekday
          ? nextDay - todayWeekday
          : 7 - todayWeekday + nextDay;

      return completedDate.add(Duration(days: daysToAdd));
    } else if (frequency == -1 && customDays != null && customDays.isNotEmpty) {
      final todayDay = completedDate.day;
      final sortedDays = List<int>.from(customDays)..sort();

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

  // Additional helper methods remain the same...
  bool isMedicationDue(MedicationModel med) {
    if (med.completedDates.isEmpty) return true;

    final now = DateTime.now();
    final nextDue =
        _calculateNextDueDate(med.completedDates.last, med.frequency);
    return now.isAfter(nextDue);
  }

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

  Future<List<TaskModel>> getAllTasks() async {
    final service = ref.read(taskServiceProvider);
    return await service.getAllTasksFiltered(selectedDate);
  }

  Future<List<TaskModel>> getTasksByStatus(String status) async {
    final service = ref.read(taskServiceProvider);
    return await service.getTasksByStatus(status, filterDate: selectedDate);
  }

  Future<List<TaskModel>> getTasksForSelectedDate() async {
    final service = ref.read(taskServiceProvider);
    return await service.getTasksForDate(selectedDate);
  }

  Future<List<SubtaskModel>> getSubtasksForTask(String taskId) async {
    final service = ref.read(subtaskServiceProvider);
    return await service.getSubtasksForTaskFiltered(taskId, selectedDate);
  }
}
