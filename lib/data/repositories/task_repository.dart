import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/core/database/database_service.dart';

/// A repository layer that abstracts task-related database operations.
///
/// This class provides methods to interact with the database, such as
/// creating, updating, and fetching task data. It also handles the
/// conversion between [TaskModel] and the Firestore-friendly map format.
class TaskRepository {
  final DatabaseService
      _db; // The database service for performing CRUD operations.

  const TaskRepository(this._db);

  /// Fetches all task documents from the database.
  ///
  /// Queries the database for all documents in the tasks collection.
  /// Each document is converted from a map to a [TaskModel] instance.
  Future<List<TaskModel>> getAllTasks() async {
    final results = await _db.query(
        collection: DatabaseService.tasks); // Querying the tasks collection.
    return results
        .map((e) => TaskModel.fromMap(e))
        .toList(); // Converting maps to TaskModel instances.
  }

  /// Retrieves a task document by its unique ID.
  ///
  /// If a document exists for the given ID, its data is converted from a
  /// map to a [TaskModel]. Otherwise, returns null.
  Future<TaskModel?> getTaskById(String id) async {
    final data = await _db.getDocument(
        '${DatabaseService.tasks}/$id'); // Fetching document by ID.
    return data != null
        ? TaskModel.fromMap(data)
        : null; // Returning a TaskModel or null.
  }

  /// Creates a new task in the database.
  ///
  /// Takes a [TaskModel] instance, converts it to a map, and sends it
  /// to the database. The response is then converted back to a [TaskModel].
  Future<TaskModel> createTask(TaskModel task) async {
    final data = await _db.createDocument(
        DatabaseService.tasks, task.toMap()); // Creating a new document.
    return TaskModel.fromMap(
        data); // Returning the created task as a TaskModel.
  }

  /// Updates an existing task document in the database.
  ///
  /// Takes a task ID and a [TaskModel]. The task data is updated in the
  /// database, and the updated data is converted back to a [TaskModel].
  Future<TaskModel> updateTask(String id, TaskModel task) async {
    final data = await _db.updateDocument(
      '${DatabaseService.tasks}/$id', // Document path.
      task.toMap(), // Updated data as a map.
    );
    return TaskModel.fromMap(
        data); // Returning the updated task as a TaskModel.
  }

  /// Deletes a task document by ID.
  ///
  /// Removes the specified task from the database.
  Future<void> deleteTask(String id) async {
    await _db.deleteDocument(
        '${DatabaseService.tasks}/$id'); // Deleting the document by ID.
  }

  /// Fetches all subtasks for a specific parent task
  Future<List<TaskModel>> getSubtasksByParentId(String parentId) async {
    final results = await _db.query(
      collection: DatabaseService.tasks,
      filters: [
        QueryFilter.basic('parent_task_id', QueryOperator.equal, parentId),
        QueryFilter.basic('is_subtask', QueryOperator.equal, true),
      ],
      orderBy: [QueryOrder('subtask_order')],
    );
    return results.map((e) => TaskModel.fromMap(e)).toList();
  }

  /// Creates a new subtask
  Future<TaskModel> createSubtask(TaskModel subtask) async {
    // We're using the same tasks collection, just with parent_task_id populated
    if (subtask.parentTaskId == null) {
      throw Exception('Subtasks must have a parent task ID');
    }
    if (!subtask.isSubtask) {
      throw Exception('Task must be marked as subtask');
    }

    final data =
        await _db.createDocument(DatabaseService.tasks, subtask.toMap());
    return TaskModel.fromMap(data);
  }

  /// Updates an existing subtask
  Future<TaskModel> updateSubtask(String id, TaskModel subtask) async {
    // Validate it's actually a subtask
    if (!subtask.isSubtask) {
      throw Exception('Can only update tasks marked as subtasks');
    }

    // Use the same update method as regular tasks
    return updateTask(id, subtask);
  }

  /// Deletes a subtask by ID
  Future<void> deleteSubtask(String id) async {
    // First verify this is a subtask
    final task = await getTaskById(id);
    if (task == null || !task.isSubtask) {
      throw Exception('ID does not belong to a subtask');
    }

    // Then delete it (identical to deleting a task)
    return deleteTask(id);
  }
}
