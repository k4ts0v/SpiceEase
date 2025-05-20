import 'package:spiceease/core/auth/auth_service.dart';
import 'package:spiceease/core/database/database_service.dart';
import 'package:spiceease/core/database/firerstore_date_adapter.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/repositories/task_repository.dart';

/// A service layer that coordinates task-related business logic.
///
/// This class depends on the [TaskRepository] and provides higher-level
/// operations for managing tasks. It's responsible for transforming data
/// or adding additional logic before calling the repository.
class TaskService {
  final AuthService _authService;
  final DatabaseService _db;
  final TaskRepository _repository; // Dependency for accessing the repository.

  TaskService(this._repository, this._authService, this._db);

  /// Retrieves all tasks by delegating to the repository.
  Future<List<TaskModel>> getAllTasks() => _repository.getAllTasks();

  /// Retrieves a specific task by ID through the repository.
  Future<TaskModel?> getTaskById(String id) => _repository.getTaskById(id);

  /// Creates a new task by delegating to the repository.
  Future<TaskModel> createTask(TaskModel task) => _repository.createTask(task);

  /// Updates an existing task by delegating to the repository.
  Future<TaskModel> updateTask(String id, TaskModel task) async {
    return await _repository.updateTask(id, task);
  }

  /// Deletes a task by delegating to the repository.
  Future<void> deleteTask(String id) => _repository.deleteTask(id);

  // Provides task entries for the authenticated user in a specified date.
  Future<List<TaskModel>> getTasksForDate(DateTime date) async {
    final user = await _authService.getCurrentUser();
    if (user == null) return [];

    final start = FirestoreDateAdapter.toTimestamp(
        DateTime(date.year, date.month, date.day));
    print("Start date: $start"); //For debugging
    final end = FirestoreDateAdapter.toTimestamp(
        DateTime(date.year, date.month, date.day).add(Duration(days: 1)));
    print("End date: $end");

    final tasksWithDueDate = await _db.query(
      collection: DatabaseService.tasks,
      filters: [
        QueryFilter.basic('user_id', QueryOperator.equal, user.uid),
        QueryFilter.basic('due_date', QueryOperator.greaterThanOrEqual, start),
        QueryFilter.basic('due_date', QueryOperator.lessThanOrEqual, end),
      ],
      orderBy: [QueryOrder('due_date')],
    );

    final tasksWithoutDueDate = await _db.query(
      collection: DatabaseService.tasks,
      filters: [
        QueryFilter.basic('user_id', QueryOperator.equal, user.uid),
        QueryFilter.basic('has_due_date', QueryOperator.equal, false),
      ],
    );

  print("Tasks with due date: $tasksWithDueDate"); //For debugging
  print("Tasks without due date: $tasksWithoutDueDate"); //For debugging

    // Combine tasks with and without due dates
    final allTasks = [...tasksWithDueDate, ...tasksWithoutDueDate];
    return allTasks.map((e) => TaskModel.fromMap(e)).toList();
  }

  String generateId() => _db.generateId(); // Generate unique ID

  Future<String> getCurrentUserId() async {
    final user = await _authService.getCurrentUser();
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  Future<List<TaskModel>> getTasksByStatus(String status,
      {bool sortByPriority = false}) async {
    final userId = await getCurrentUserId();

    final orderFields = [
      QueryOrder('order'), // Maintain UI order first
      if (sortByPriority) QueryOrder('priority', descending: true),
      QueryOrder('due_date'), // Then sort by due date
      QueryOrder('created_at'), // Finally by creation time
    ];

    final tasks = await _db.query(
      collection: DatabaseService.tasks,
      filters: [
        QueryFilter.basic('user_id', QueryOperator.equal, userId),
        QueryFilter.basic('status', QueryOperator.equal, status),
      ],
      orderBy: orderFields,
    );

    return tasks.map(TaskModel.fromMap).toList();
  }
}
