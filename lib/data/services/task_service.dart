// lib/data/services/task_service.dart

import 'package:spiceease/core/auth/auth_service.dart';
import 'package:spiceease/core/database/database_service.dart';
import 'package:spiceease/core/database/firestore_date_adapter.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/repositories/task_repository.dart';

class TaskService {
  final AuthService _authService;
  final DatabaseService _db;
  final TaskRepository _repository;

  TaskService(
    this._repository,
    this._authService,
    this._db,
  );

  Future<List<TaskModel>> getAllTasks() => _repository.getAllTasks();

  Future<TaskModel?> getTaskById(String id) => _repository.getTaskById(id);

  Future<TaskModel> createTask(TaskModel task) => _repository.createTask(task);

  Future<TaskModel> updateTask(String id, TaskModel task) =>
      _repository.updateTask(id, task);

  Future<void> deleteTask(String id) => _repository.deleteTask(id);

  Future<List<TaskModel>> getTasksForDate(DateTime date) async {
    final user = await _authService.getCurrentUser();
    if (user == null) return [];

    final start = FirestoreDateAdapter.toTimestamp(
      DateTime(date.year, date.month, date.day),
    );
    final end = FirestoreDateAdapter.toTimestamp(
      DateTime(date.year, date.month, date.day).add(const Duration(days: 1)),
    );

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

    final allTasks = [...tasksWithDueDate, ...tasksWithoutDueDate];
    return allTasks.map((e) => TaskModel.fromMap(e)).toList();
  }

  String generateId() => _db.generateId();

  Future<String> getCurrentUserId() async {
    final user = await _authService.getCurrentUser();
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  Future<List<TaskModel>> getTasksByStatus(
    String status, {
    bool sortByPriority = false,
  }) async {
    final userId = await getCurrentUserId();

    final orderFields = [
      QueryOrder('order'),
      if (sortByPriority) QueryOrder('priority', descending: true),
      QueryOrder('due_date'),
      QueryOrder('created_at'),
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

  /// You may add a signal method to inform UI when toggling is complete
  Future<void> toggleTaskCompletion(String taskId, DateTime selectedDate) async {
    final task = await getTaskById(taskId);
    if (task == null) throw Exception("Task not found");

    final updatedTask = task.toggleCompletion(selectedDate);
    await _repository.updateTask(taskId, updatedTask);
  }
}
