import 'package:flutter/material.dart';
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

  /// Filters tasks to show completed tasks until their completion date (not after)
  List<TaskModel> _filterTasksForSelectedDate(
      List<TaskModel> tasks, DateTime selectedDate) {
    final selectedDay = DateUtils.dateOnly(selectedDate);

    return tasks.where((task) {
      // If task is completed, only show if selected date is on or before completion date
      if (task.status.toLowerCase() == 'done' || task.completedAt != null) {
        if (task.completedAt != null) {
          final completedDay = DateUtils.dateOnly(task.completedAt!);
          // Show if selected date is on or before the completion date
          return selectedDay.isBefore(completedDay) ||
              selectedDay.isAtSameMomentAs(completedDay);
        }
        // Task marked as done but no completion date - don't show it
        return false;
      }

      // Show non-completed tasks
      return true;
    }).toList();
  }

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
    final taskModels = allTasks.map((e) => TaskModel.fromMap(e)).toList();

    // Apply filtering to show completed tasks from completion date onwards
    return _filterTasksForSelectedDate(taskModels, date);
  }

  /// Gets filtered tasks for all dates (used by tracker)
  Future<List<TaskModel>> getAllTasksFiltered(DateTime selectedDate) async {
    final allTasks = await getAllTasks();
    return _filterTasksForSelectedDate(allTasks, selectedDate);
  }

  Future<List<TaskModel>> getTasksByStatus(
    String status, {
    bool sortByPriority = false,
    DateTime? filterDate,
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

    final taskModels = tasks.map(TaskModel.fromMap).toList();

    // Apply filtering if date is provided
    if (filterDate != null) {
      return _filterTasksForSelectedDate(taskModels, filterDate);
    }

    return taskModels;
  }

  String generateId() => _db.generateId();

  Future<String> getCurrentUserId() async {
    final user = await _authService.getCurrentUser();
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  Future<void> toggleTaskCompletion(
      String taskId, DateTime selectedDate) async {
    final task = await getTaskById(taskId);
    if (task == null) throw Exception("Task not found");

    final updatedTask = task.toggleCompletion(selectedDate);
    await _repository.updateTask(taskId, updatedTask);
  }
}
