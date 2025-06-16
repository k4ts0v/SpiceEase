import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/database/firestore_date_adapter.dart';
import 'package:spiceease/data/models/flowmodoro_model.dart';
import 'package:spiceease/core/database/database_service.dart';
import 'package:spiceease/data/providers/unified_auth_provider.dart';

/// A repository layer that abstracts flowmodoro-related database operations.
///
/// This class provides methods to interact with the database, such as
/// creating, updating, and fetching flowmodoro data. It also handles the
/// conversion between [FlowmodoroModel] and the Firestore-friendly map format.
class FlowmodoroRepository {
  final DatabaseService
      _db; // The database service for performing CRUD operations.
  final Ref
      _ref; // The reference to the provider for accessing other providers.

  const FlowmodoroRepository(this._db, this._ref);

  /// Fetches all flowmodoro documents from the database.
  ///
  /// Queries the database for all documents in the flowmodoro collection.
  /// Each document is converted from a map to a [FlowmodoroModel] instance.
  Future<List<FlowmodoroModel>> getAllFlowmodoro() async {
    final results = await _db.query(
        collection:
            DatabaseService.flowmodoros); // Querying the flowmodoro collection.
    return results
        .map((e) => FlowmodoroModel.fromMap(e))
        .toList(); // Converting maps to FlowmodoroModel instances.
  }

  /// Retrieves a flowmodoro document by its unique ID.
  ///
  /// If a document exists for the given ID, its data is converted from a
  /// map to a [FlowmodoroModel]. Otherwise, returns null.
  Future<FlowmodoroModel?> getFlowmodoroById(String id) async {
    final data = await _db.getDocument(
        '${DatabaseService.flowmodoros}/$id'); // Fetching document by ID.
    return data != null
        ? FlowmodoroModel.fromMap(data)
        : null; // Returning a FlowmodoroModel or null.
  }

  /// Creates a new flowmodoro in the database.
  ///
  /// Takes a [FlowmodoroModel] instance, converts it to a map, and sends it
  /// to the database. The response is then converted back to a [FlowmodoroModel].
  Future<FlowmodoroModel> createFlowmodoro(FlowmodoroModel flowmodoro) async {
    final data = await _db.createDocument(DatabaseService.flowmodoros,
        flowmodoro.toMap()); // Creating a new document.
    return FlowmodoroModel.fromMap(
        data); // Returning the created flowmodoro as a FlowmodoroModel.
  }

  /// Updates an existing flowmodoro document in the database.
  ///
  /// Takes a flowmodoro ID and a [FlowmodoroModel]. The flowmodoro data is updated in the
  /// database, and the updated data is converted back to a [FlowmodoroModel].
  Future<FlowmodoroModel> updateFlowmodoro(
      String id, FlowmodoroModel flowmodoro) async {
    final data = await _db.updateDocument(
      '${DatabaseService.flowmodoros}/$id', // Document path.
      flowmodoro.toMap(), // Updated data as a map.
    );
    return FlowmodoroModel.fromMap(
        data); // Returning the updated flowmodoro as a FlowmodoroModel.
  }

  /// Deletes a flowmodoro document by ID.
  ///
  /// Removes the specified flowmodoro from the database.
  Future<void> deleteFlowmodoro(String id) async {
    await _db.deleteDocument(
        '${DatabaseService.flowmodoros}/$id'); // Deleting the document by ID.
  }

  /// Retrieves all flowmodoro documents for a specific user on a given date.
  ///
  /// This method fetches flowmodoro documents created by the user on the specified date.
  /// It filters the documents based on the user's ID and the creation date,
  /// and returns a list of [FlowmodoroModel] instances.
  /// It has the parameter [date] which is the date for which flowmodoros are fetched.
  Future<List<FlowmodoroModel>> getFlowmodorosForDate(DateTime date) async {
    final user = _ref.read(unifiedAuthProvider).value;
    if (user == null) return [];

    final start = FirestoreDateAdapter.toTimestamp(
        DateTime(date.year, date.month, date.day));
    final end = FirestoreDateAdapter.toTimestamp(
        DateTime(date.year, date.month, date.day).add(const Duration(days: 1)));

    final raw = await _db.query(
      collection: DatabaseService.flowmodoros,
      filters: [
        QueryFilter.basic('user_id', QueryOperator.equal, user.uid),
        QueryFilter.basic(
            'created_at', QueryOperator.greaterThanOrEqual, start),
        QueryFilter.basic('created_at', QueryOperator.lessThan, end),
      ],
      orderBy: [const QueryOrder('created_at')],
    );

    return raw.map((e) => FlowmodoroModel.fromMap(e)).toList();
  }
}
