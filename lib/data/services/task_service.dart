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
  Future<TaskModel> updateTask(String id, TaskModel task) =>
      _repository.updateTask(id, task);

  /// Deletes a task by delegating to the repository.
  Future<void> deleteTask(String id) => _repository.deleteTask(id);

  // Provides task entries for the authenticated user in a specified date.
  Future<List<TaskModel>> getTasksForDate(DateTime date) async {
    final user = await _authService.getCurrentUser();
    if (user == null) return [];

    final start = FirestoreDateAdapter.toTimestamp(
        DateTime(date.year, date.month, date.day));
    final end = FirestoreDateAdapter.toTimestamp(
        DateTime(date.year, date.month, date.day).add(Duration(days: 1)));

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

    print(tasksWithDueDate);
    print(tasksWithoutDueDate);
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

  Future<void> reorderTasks(String status, int oldIndex, int newIndex) async {
    final userId = await getCurrentUserId();

    // 1. Get all tasks in the current status with their current order
    final tasks = await _db.query(
      collection: DatabaseService.tasks,
      filters: [
        QueryFilter.basic('user_id', QueryOperator.equal, userId),
        QueryFilter.basic('status', QueryOperator.equal, status),
      ],
      orderBy: [QueryOrder('order')],
    );

    // 2. Validate indices
    if (oldIndex >= tasks.length || newIndex >= tasks.length) {
      throw RangeError('Invalid index for reordering');
    }

    // 3. Prepare batch updates using DatabaseService
    final updates = <Map<String, dynamic>>[];

    // Remove the task from old position
    final movedTask = tasks.removeAt(oldIndex);

    // Insert it at new position
    tasks.insert(newIndex, movedTask);

    // 4. Create update operations for all affected tasks
    for (int i = 0; i < tasks.length; i++) {
      updates.add({
        'path': '${DatabaseService.tasks}/${tasks[i]['id']}',
        'data': {'order': i}
      });
    }

    // 5. Execute batch updates through DatabaseService
    await _db.batchUpdate(updates);
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

  /// Retrieves all subtasks of a given parent task
  Future<List<TaskModel>> getSubtasksForParent(String parentTaskId) async {
    final user = await _authService.getCurrentUser();
    if (user == null) return [];

    // Use the repository method instead of direct DB query
    final allSubtasks = await _repository.getSubtasksByParentId(parentTaskId);

    // Filter by current user if needed (though repository could handle this)
    return allSubtasks.where((task) => task.userId == user.uid).toList();
  }

  /// Creates a new subtask under the specified parent
  Future<TaskModel> createSubtask(String parentId, String title,
      String description, int? estimatedTime, String? estimatedUnit) async {
    final user = await _authService.getCurrentUser();
    if (user == null) throw Exception('User not authenticated');

    // First get count of existing subtasks to determine order
    final existingSubtasks = await getSubtasksForParent(parentId);
    final nextOrder = existingSubtasks.length;

    // Create the subtask
    final subtaskId = generateId();
    final now = DateTime.now();

    final subtask = TaskModel(
      id: subtaskId,
      userId: user.uid,
      title: title,
      description: description,
      status: 'Pending',
      dueDate: null,
      completedAt: null,
      estimatedTime: estimatedTime,
      priority: 1, // Default priority
      createdAt: now,
      updatedAt: now,
      parentTaskId: parentId,
      isSubtask: true,
      subtaskOrder: nextOrder,
    );

    // Use repository instead of direct DB call
    return await _repository.createSubtask(subtask);
  }

  /// Update a subtask
  Future<TaskModel> updateSubtask(String id, TaskModel subtask) async {
    return await _repository.updateSubtask(id, subtask);
  }

  /// Delete a subtask
  Future<void> deleteSubtask(String id) async {
    return await _repository.deleteSubtask(id);
  }
}
