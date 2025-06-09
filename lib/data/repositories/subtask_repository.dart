import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/core/database/database_service.dart';
import 'package:spiceease/data/providers/unified_auth_provider.dart';

/// A repository layer that abstracts subtask-related database operations.
///
/// This class provides methods to interact with the database, such as
/// creating, updating, and fetching subtask data. It also handles the
/// conversion between [SubtaskModel] and the Firestore-friendly map format.
class SubtaskRepository {
  final DatabaseService
      _db; // The database service for performing CRUD operations.
  final Ref
      _ref; // The reference to the provider for accessing other providers.

  const SubtaskRepository(this._db, this._ref);

  /// Fetches all subtask documents from the database.
  ///
  /// Queries the database for all documents in the subtasks collection.
  /// Each document is converted from a map to a [SubtaskModel] instance.
  Future<List<SubtaskModel>> getAllSubtasks() async {
    final user = await _ref.read(unifiedAuthProvider).value;
    if (user == null) return [];

    final results = await _db.query(
        collection:
            DatabaseService.subtasks); // Querying the subtasks collection.
    return results
        .map((e) => SubtaskModel.fromMap(e))
        .toList(); // Converting maps to SubtaskModel instances.
  }

  /// Retrieves a subtask document by its unique ID.
  ///
  /// If a document exists for the given ID, its data is converted from a
  /// map to a [SubtaskModel]. Otherwise, returns null.
  Future<SubtaskModel?> getSubtaskById(String id) async {
    final data = await _db.getDocument(
        '${DatabaseService.subtasks}/$id'); // Fetching document by ID.
    return data != null
        ? SubtaskModel.fromMap(data)
        : null; // Returning a SubtaskModel or null.
  }

  /// Creates a new subtask in the database.
  ///
  /// Takes a [SubtaskModel] instance, converts it to a map, and sends it
  /// to the database. The response is then converted back to a [SubtaskModel].
  Future<SubtaskModel> createSubtask(SubtaskModel subtask) async {
    final data = await _db.createDocument(
        DatabaseService.subtasks, subtask.toMap()); // Creating a new document.
    return SubtaskModel.fromMap(
        data); // Returning the created subtask as a SubtaskModel.
  }

  /// Updates an existing subtask document in the database.
  ///
  /// Takes a subtask ID and a [SubtaskModel]. The subtask data is updated in the
  /// database, and the updated data is converted back to a [SubtaskModel].
  Future<SubtaskModel> updateSubtask(String id, SubtaskModel subtask) async {
    final data = await _db.updateDocument(
      '${DatabaseService.subtasks}/$id', // Document path.
      subtask.toMap(), // Updated data as a map.
    );
    return SubtaskModel.fromMap(
        data); // Returning the updated subtask as a SubtaskModel.
  }

  /// Deletes a subtask document by ID.
  ///
  /// Removes the specified subtask from the database.
  Future<void> deleteSubtask(String id) async {
    await _db.deleteDocument(
        '${DatabaseService.subtasks}/$id'); // Deleting the document by ID.
  }

  /// Get subtasks for a specific task
  Future<List<SubtaskModel>> getSubtasksForTask(String taskId) async {
    final user = await _ref.read(unifiedAuthProvider).value;
    if (user == null) return [];

    final subtasks = await _db.query(
      collection: DatabaseService.subtasks,
      filters: [
        QueryFilter.basic('task_id', QueryOperator.equal, taskId),
        QueryFilter.basic('user_id', QueryOperator.equal, user.uid),
      ],
      orderBy: [QueryOrder('order')],
    );

    return subtasks.map((e) => SubtaskModel.fromMap(e)).toList();
  }
}
