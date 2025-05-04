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
import 'package:spiceease/data/providers/symptom_provider.dart';
import 'package:spiceease/data/providers/task_provider.dart';

final trackerControllerProvider = Provider((ref) => TrackerController(ref));

class TrackerController {
  final Ref ref;
  late final selectedDate = ref.watch(selectedDateProvider);

  TrackerController(this.ref);

  Future<String> _getUserId() async {
    final user = await ref.read(authServiceProvider).getCurrentUser();
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  // Energy
  Future<void> addEnergy(int energyLevel, String? notes) async {
    final service = ref.read(energyServiceProvider);
    await service.createEnergy(EnergyModel(
        id: service.generateId(),
        userId: await _getUserId(),
        energyLevel: energyLevel,
        notes: notes,
        createdAt: selectedDate));
    ref.invalidate(energyStateNotifierProvider(selectedDate));
    await ref
        .read(energyStateNotifierProvider(selectedDate).notifier)
        .fetchEnergies();
  }

  Future<void> updateEnergy(String id, int energyLevel, String? notes) async {
    final service = ref.read(energyServiceProvider);
    await service.updateEnergy(
        id,
        EnergyModel(
            id: id,
            userId: await _getUserId(),
            energyLevel: energyLevel,
            notes: notes,
            createdAt: selectedDate));
    ref.invalidate(energyStateNotifierProvider(selectedDate));
    await ref
        .read(energyStateNotifierProvider(selectedDate).notifier)
        .fetchEnergies();
  }

  Future<void> deleteEnergy(String id, WidgetRef ref) async {
    final service = ref.read(energyServiceProvider);
    await service.deleteEnergy(id);
    ref.invalidate(energyStateNotifierProvider(selectedDate));
    await ref
        .read(energyStateNotifierProvider(selectedDate).notifier)
        .fetchEnergies();
  }

  // Mood
  Future<void> addMood(int moodLevel, String? notes) async {
    final service = ref.read(moodServiceProvider);
    await service.createMood(MoodModel(
        id: service.generateId(),
        userId: await _getUserId(),
        moodLevel: moodLevel,
        notes: notes,
        createdAt: selectedDate,
        updatedAt: DateTime.now()));
    ref.invalidate(moodStateNotifierProvider(selectedDate));
  }

  Future<void> updateMood(String id, int moodLevel, String? notes) async {
    final service = ref.read(moodServiceProvider);
    await service.updateMood(
        id,
        MoodModel(
            id: id,
            userId: await _getUserId(),
            moodLevel: moodLevel,
            notes: notes,
            createdAt: selectedDate,
            updatedAt: DateTime.now()));
    ref.invalidate(moodStateNotifierProvider(selectedDate));
    await ref
        .read(moodStateNotifierProvider(selectedDate).notifier)
        .fetchMoods();
  }

  Future<void> deleteMood(String id, WidgetRef ref) async {
    final service = ref.read(moodServiceProvider);
    await service.deleteMood(id);
    ref.invalidate(moodStateNotifierProvider(selectedDate));
    await ref
        .read(moodStateNotifierProvider(selectedDate).notifier)
        .fetchMoods();
  }

  // Symptoms
  Future<void> addSymptom(String name, String category, int severity) async {
    final selectedDate =
        ref.read(selectedDateProvider); // e.g., 2025-05-02 00:00:00
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
      createdAt: dateWithCurrentTime,
      updatedAt: dateWithCurrentTime,
    ));
    ref.invalidate(symptomStateNotifierProvider(selectedDate));
  }

  Future<void> updateSymptom(
      String id, String name, String category, int severity) async {
    final service = ref.read(symptomServiceProvider);
    final now = DateTime.now();

    // First get the existing symptom to preserve createdAt
    final existingSymptom = await service.getSymptomById(id);
    if (existingSymptom == null) {
      throw Exception('Symptom not found');
    }

    // Create updated symptom, preserving the original createdAt
    final updatedSymptom = existingSymptom.copyWith(
      name: name,
      category: category,
      severity: severity,
      updatedAt: now, // Always use DateTime for the model
    );

    await service.updateSymptom(id, updatedSymptom);
    await ref
        .read(symptomStateNotifierProvider(selectedDate).notifier)
        .fetchSymptoms();
  }

  Future<void> deleteSymptom(String id, WidgetRef ref) async {
    final service = ref.read(symptomServiceProvider);
    await service.deleteSymptom(id);
    ref.invalidate(symptomStateNotifierProvider(selectedDate));
    await ref
        .read(symptomStateNotifierProvider(selectedDate).notifier)
        .fetchSymptoms();
  }

  // Medication
  Future<void> addMedication({
    required String name,
    required double dose,
    required String unit,
    required String frequency,
    List<int>? customDays,
    required int timesPerDay,
  }) async {
    final service = ref.read(medicationServiceProvider);
    final id = service.generateId();
    final userId = await service.getCurrentUserId();

    final medication = MedicationModel(
      id: id,
      userId: userId,
      name: name,
      dose: dose,
      unit: unit,
      frequency: frequency,
      customDays: customDays,
      timesPerDay: timesPerDay,
      lastTaken: null,
      nextDueDate: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await service.createMedication(medication);
    ref.invalidate(medicationStateNotifierProvider(selectedDate));
  }

  Future<void> updateMedication(
    String id,
    String name,
    double dose,
    String unit,
    String frequency,
    List<int>? customDays,
    int timesPerDay,
    DateTime? lastTaken,
  ) async {
    final service = ref.read(medicationServiceProvider);

    final existingMedication = await service.getMedicationById(id);
    if (existingMedication == null) {
      throw Exception('Medication not found');
    }

    final updatedMedication = existingMedication.copyWith(
      name: name,
      dose: dose,
      unit: unit,
      frequency: frequency,
      customDays: customDays,
      timesPerDay: timesPerDay,
      lastTaken: lastTaken,
      nextDueDate:
          lastTaken != null ? existingMedication.calculateNextDueDate() : null,
      updatedAt: DateTime.now(),
    );

    await service.updateMedication(id, updatedMedication);
    ref.invalidate(medicationStateNotifierProvider(selectedDate));
  }

  Future<void> markMedicationTaken(String id, bool taken) async {
    final service = ref.read(medicationServiceProvider);
    final existingMed = await service.getMedicationById(id);

    if (existingMed == null) {
      throw Exception('Medication not found');
    }

    final updatedMed = existingMed.copyWith(
      lastTaken: taken ? DateTime.now() : null,
    );

    await service.updateMedication(id, updatedMed);
    ref.invalidate(medicationStateNotifierProvider(selectedDate));
    await ref
        .read(medicationStateNotifierProvider(selectedDate).notifier)
        .fetchMedications();
  }

  Future<void> deleteMedication(String id, WidgetRef ref) async {
    final service = ref.read(medicationServiceProvider);
    await service.deleteMedication(id);
    ref.invalidate(medicationStateNotifierProvider(selectedDate));
    await ref
        .read(medicationStateNotifierProvider(selectedDate).notifier)
        .fetchMedications();
  }

  // Tasks
  Future<void> addTask({
    required String title,
    required String description,
    required String status,
    DateTime? dueDate,
    DateTime? completedAt,
    int? estimatedTime,
    String? estimatedUnit,
    required int priority,
    required List<SubtaskModel> subtasks,
  }) async {
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
    ));

    ref.invalidate(taskStateNotifierProvider(selectedDate));
  }

  Future<void> updateTask(
    String id,
    String title,
    String description,
    String status,
    DateTime? dueDate,
    DateTime? completedAt,
    int? estimatedTime,
    String? estimatedUnit,
    int priority,
    List<SubtaskModel>? subtasks,
  ) async {
    final service = ref.read(taskServiceProvider);
    final existingTask = await service.getTaskById(id);

    if (existingTask == null) {
      throw Exception('Task not found');
    }

    // If marking as completed
    if (status == 'completed' && existingTask.status != 'completed') {
      completedAt = DateTime.now();
    }
    // If unmarking completion
    else if (status != 'completed' && existingTask.status == 'completed') {
      completedAt = null;
    }

    final updatedTask = existingTask.copyWith(
      title: title,
      description: description,
      status: status,
      dueDate: dueDate,
      completedAt: completedAt, // This will be null if uncompleted
      estimatedTime: estimatedTime,
      priority: priority,
      updatedAt: DateTime.now(),
      subtasks: subtasks,
    );

    await service.updateTask(id, updatedTask);
    ref.invalidate(taskStateNotifierProvider(selectedDate));
    await ref
        .read(taskStateNotifierProvider(selectedDate).notifier)
        .fetchTasks();
  }

  Future<void> deleteTask(String id) async {
    final service = ref.read(taskServiceProvider);
    await service.deleteTask(id);
    ref.invalidate(taskStateNotifierProvider(selectedDate));
    await ref
        .read(taskStateNotifierProvider(selectedDate).notifier)
        .fetchTasks();
  }

// Required for subtasks to generate IDs
  String generateId() {
    final service = ref.read(taskServiceProvider);
    return service.generateId();
  }

  Future<String> getUserId() async {
    return await _getUserId();
  }

// Update a single subtask within a parent task
  Future<void> updateSubtask(
      String parentTaskId, SubtaskModel subtask, String title, bool completed,
      {required String rawTimeUnit, required String rawTimeValue}) async {
    final service = ref.read(taskServiceProvider);
    final existingTask = await service.getTaskById(parentTaskId);

    if (existingTask == null || existingTask.subtasks == null) {
      throw Exception('Parent task or subtasks not found');
    }

    // Find and update the subtask in the array
    final updatedSubtasks = [...existingTask.subtasks!];
    final index = updatedSubtasks
        .indexWhere((s) => s.id == subtask.id && s.order == subtask.order);

    if (index == -1) {
      throw Exception('Subtask not found');
    }

    updatedSubtasks[index] = subtask.copyWith(
      title: title,
      taskId: parentTaskId,
      completed: completed,
      rawTimeValue: rawTimeValue,
      rawTimeUnit: rawTimeUnit,
    );

    // Update the parent task with modified subtasks
    await updateTask(
      parentTaskId,
      existingTask.title,
      existingTask.description,
      existingTask.status,
      existingTask.dueDate,
      existingTask.completedAt,
      existingTask.estimatedTime,
      existingTask.estimatedUnit,
      existingTask.priority,
      updatedSubtasks,
    );
  }

  // Habits
  Future<void> addHabit({
    required String title,
    required String description,
    required int frequency,
    List<int>? customDays,
  }) async {
    final service = ref.read(habitServiceProvider);
    final today = DateTime.now();

    // Calculate next due date
    DateTime? nextDueDate;
    if (frequency == 1) {
      // Daily frequency
      nextDueDate = today.add(const Duration(days: 1));
    } else if (frequency == 7 && customDays != null) {
      // Weekly frequency
      final todayWeekday = today.weekday;
      final closestDay = customDays.firstWhere(
        (day) => day >= todayWeekday,
        orElse: () => customDays.first,
      );
      nextDueDate = today.add(Duration(days: (closestDay - todayWeekday) % 7));
    } else if (frequency == -1 && customDays != null) {
      // Monthly frequency
      final todayDay = today.day;
      final closestDay = customDays.firstWhere(
        (day) => day >= todayDay,
        orElse: () => customDays.first,
      );
      nextDueDate = DateTime(today.year, today.month, closestDay);
      if (closestDay < todayDay) {
        // Move to the next month if the closest day is in the past
        nextDueDate = DateTime(today.year, today.month + 1, closestDay);
      }
    }

    await service.createHabit(HabitModel(
      id: service.generateId(),
      userId: await _getUserId(),
      title: title,
      description: description,
      frequency: frequency,
      customDays: customDays,
      nextDueDate: nextDueDate,
      lastCompleted: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    ref.invalidate(habitStateNotifierProvider(selectedDate));
    await ref
        .read(habitStateNotifierProvider(selectedDate).notifier)
        .fetchHabits();
  }

  Future<void> updateHabit(
    String id,
    String title,
    String description,
    int frequency,
    List<int>? customDays, {
    required bool markAsCompleted,
  }) async {
    final service = ref.read(habitServiceProvider);
    final existingHabit = await service.getHabitById(id);

    if (existingHabit == null) {
      throw Exception('Habit not found');
    }

    // Update lastCompleted and nextDueDate based on the toggle state
    DateTime? lastCompleted = existingHabit.lastCompleted;
    DateTime? nextDueDate = existingHabit.nextDueDate;

    if (markAsCompleted) {
      lastCompleted = DateTime.now();
      nextDueDate = lastCompleted.add(Duration(days: frequency));
    } else {
      lastCompleted = null;
      existingHabit.calculateNextDueDate(); // Recalculate nextDueDate
      nextDueDate = existingHabit.nextDueDate;
    }

    final updatedHabit = existingHabit.copyWith(
      title: title,
      description: description,
      frequency: frequency,
      customDays: customDays,
      lastCompleted: markAsCompleted ? DateTime.now() : null,
      nextDueDate: markAsCompleted
          ? DateTime.now().add(Duration(days: frequency))
          : null, // or recalculate as needed
      updatedAt: DateTime.now(),
    );

    print(
        'updateHabit: lastCompleted=$lastCompleted, nextDueDate=$nextDueDate'); // Debugging

    await service.updateHabit(id, updatedHabit);
    ref.invalidate(habitStateNotifierProvider);
  }

  Future<void> deleteHabit(String id) async {
    final service = ref.read(habitServiceProvider);
    await service.deleteHabit(id);
    ref.invalidate(habitStateNotifierProvider(selectedDate));
    await ref
        .read(habitStateNotifierProvider(selectedDate).notifier)
        .fetchHabits();
  }

  // Helper methods for medication frequency
  bool isMedicationDue(MedicationModel med) {
    if (med.lastTaken == null) return true;

    final now = DateTime.now();
    final nextDue = _calculateNextDueDate(med.lastTaken!, med.frequency);
    return now.isAfter(nextDue);
  }

  DateTime _calculateNextDueDate(DateTime lastTaken, String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return lastTaken.add(const Duration(days: 1));
      case 'weekly':
        return lastTaken.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(
          lastTaken.year,
          lastTaken.month + 1,
          lastTaken.day,
          lastTaken.hour,
          lastTaken.minute,
        );
      case 'hourly':
        return lastTaken.add(const Duration(hours: 1));
      default: // 'as needed'
        return lastTaken.add(const Duration(days: 1));
    }
  }

  Future<void> reorderTask(String status, int oldIndex, int newIndex) async {
    final service = ref.read(taskServiceProvider);
    await service.reorderTasks(status, oldIndex, newIndex);
    ref.invalidate(taskStateNotifierProvider(selectedDate));
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
      ref.invalidate(taskStateNotifierProvider(selectedDate));
    }
  }

  Future<List<TaskModel>> getAllTasks() async {
    final service = ref.read(taskServiceProvider);
    return await service.getAllTasks();
  }

  Future<List<TaskModel>> getTasksByStatus(String status) async {
    final service = ref.read(taskServiceProvider);
    return await service.getTasksByStatus(status);
  }
}
