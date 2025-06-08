import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/subtask_provider.dart';
import 'package:spiceease/data/services/task_service.dart';
import 'package:spiceease/data/repositories/task_repository.dart';
import 'package:spiceease/core/database/database_provider.dart';
import 'package:spiceease/data/state_notifiers/task_state_notifier.dart';

/// Provides the [TaskRepository] instance.
///
/// This provider watches the [databaseServiceProvider] to
/// get the database layer dependency. When the database service
/// updates, it rebuilds the repository instance as well.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return TaskRepository(db);
});

/// Provides the [TaskService] instance.
///
/// This provider depends on [taskRepositoryProvider] and initializes
/// the application service for task-related operations. It ensures the
/// service layer always has an up-to-date repository instance.
final taskServiceProvider = Provider<TaskService>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  final auth = ref.watch(authServiceProvider);
  final db = ref.watch(databaseServiceProvider);

  return TaskService(repo, auth, db);
});

/// Provides today's tasks list.
final todayTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  return ref.read(taskServiceProvider).getTasksForDate(DateTime.now());
});

/// Provides a state notifier to manage tasks for a specific date.
final taskStateNotifierProvider = StateNotifierProvider.autoDispose
    .family<TaskStateNotifier, List<TaskModel>, DateTime>((ref, date) {
  final service = ref.read(taskServiceProvider);
  return TaskStateNotifier(service, date);
});

/// Provides a single task by its ID
final taskDetailProvider =
    FutureProvider.family<TaskModel?, String>((ref, taskId) async {
  final service = ref.read(taskServiceProvider);
  return service.getTaskById(taskId);
});

/// This provider is in charge of refreshing the task when its subtasks change
final taskWithSubtasksProvider =
    Provider.family<AsyncValue<TaskModel?>, String>((ref, taskId) {
  // Watch the task details with AsyncValue to handle loading/error states
  final taskAsync = ref.watch(taskDetailProvider(taskId));

  // Also watch the subtasks to trigger refresh when they change
  ref.watch(subtaskStateNotifierProvider(taskId));

  // Return the AsyncValue for proper handling in UI
  return taskAsync;
});

/// Provider to get tasks filtered by status
final tasksByStatusProvider =
    FutureProvider.family<List<TaskModel>, String>((ref, status) async {
  final service = ref.read(taskServiceProvider);
  return service.getTasksByStatus(status);
});

/// Provider to get all tasks with their subtasks
final allTasksWithSubtasksProvider =
    FutureProvider<List<TaskModel>>((ref) async {
  final service = ref.read(taskServiceProvider);
  final tasks = await service.getAllTasks();

  // Watch all subtask changes to refresh when needed
  ref.watch(allSubtasksProvider);

  return tasks;
});

/// Provider to get overdue tasks
final overdueTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final service = ref.read(taskServiceProvider);
  final now = DateTime.now();
  final tasks = await service.getAllTasks();

  return tasks.where((task) {
    return task.dueDate != null &&
        task.dueDate!.isBefore(now) &&
        task.status != 'Done' &&
        task.completedAt == null;
  }).toList();
});

/// Provider to get pending tasks due today
final todayDueTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final service = ref.read(taskServiceProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final tasks = await service.getAllTasks();

  return tasks.where((task) {
    return task.dueDate != null &&
        task.dueDate!.isAfter(today.subtract(const Duration(seconds: 1))) &&
        task.dueDate!.isBefore(tomorrow) &&
        task.status != 'Done';
  }).toList();
});