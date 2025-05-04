import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/data/models/task_model.dart';
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
  final db = ref.watch(
      databaseServiceProvider); // Watching the database service provider.
  return TaskRepository(db); // Creating and returning a TaskRepository.
});

/// Provides the [TaskService] instance.
///
/// This provider depends on [taskRepositoryProvider] and initializes
/// the application service for task-related operations. It ensures the
/// service layer always has an up-to-date repository instance.
final taskServiceProvider = Provider<TaskService>((ref) {
  final repo = ref
      .watch(taskRepositoryProvider); // Watching the task repository provider.
  final auth = ref.watch(authServiceProvider);
  final db = ref.watch(databaseServiceProvider);

  return TaskService(
      repo, auth, db); // Creating and returning a TaskService instance.
});

/// Provides today's tasks list.
final todayTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  return ref.read(taskServiceProvider).getTasksForDate(DateTime.now());
});

/// Provides a state notifier to manage tasks.
final taskStateNotifierProvider = StateNotifierProvider.autoDispose
    .family<TaskStateNotifier, List<TaskModel>, DateTime>((ref, date) {
  final service = ref.read(taskServiceProvider);
  return TaskStateNotifier(service, date);
});
