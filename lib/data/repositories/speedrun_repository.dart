import 'package:spiceease/data/models/speedrun_model.dart';
import 'package:spiceease/core/database/database_service.dart';

/// A repository layer that abstracts speedrun-related database operations.
///
/// This class provides methods to interact with the database, such as
/// creating, updating, and fetching speedrun data. It also handles the
/// conversion between [SpeedrunModel] and the Firestore-friendly map format.
class SpeedrunRepository {
  final DatabaseService
      _db; // The database service for performing CRUD operations.

  const SpeedrunRepository(this._db);

  /// Fetches all speedrun documents from the database.
  ///
  /// Queries the database for all documents in the speedruns collection.
  /// Each document is converted from a map to a [SpeedrunModel] instance.
  Future<List<SpeedrunModel>> getAllSpeedruns() async {
    final results = await _db.query(
        collection: DatabaseService.speedruns); // Querying the speedruns collection.
    return results
        .map((e) => SpeedrunModel.fromMap(e))
        .toList(); // Converting maps to SpeedrunModel instances.
  }

  /// Retrieves a speedrun document by its unique ID.
  ///
  /// If a document exists for the given ID, its data is converted from a
  /// map to a [SpeedrunModel]. Otherwise, returns null.
  Future<SpeedrunModel?> getSpeedrunById(String id) async {
    final data = await _db.getDocument(
        '${DatabaseService.speedruns}/$id'); // Fetching document by ID.
    return data != null
        ? SpeedrunModel.fromMap(data)
        : null; // Returning a SpeedrunModel or null.
  }

  /// Creates a new speedrun in the database.
  ///
  /// Takes a [SpeedrunModel] instance, converts it to a map, and sends it
  /// to the database. The response is then converted back to a [SpeedrunModel].
  Future<SpeedrunModel> createSpeedrun(SpeedrunModel speedrun) async {
    final data = await _db.createDocument(
        DatabaseService.speedruns, speedrun.toMap()); // Creating a new document.
    return SpeedrunModel.fromMap(
        data); // Returning the created speedrun as a SpeedrunModel.
  }

  /// Updates an existing speedrun document in the database.
  ///
  /// Takes a speedrun ID and a [SpeedrunModel]. The speedrun data is updated in the
  /// database, and the updated data is converted back to a [SpeedrunModel].
  Future<SpeedrunModel> updateSpeedrun(String id, SpeedrunModel speedrun) async {
    final data = await _db.updateDocument(
      '${DatabaseService.speedruns}/$id', // Document path.
      speedrun.toMap(), // Updated data as a map.
    );
    return SpeedrunModel.fromMap(
        data); // Returning the updated speedrun as a SpeedrunModel.
  }

  /// Deletes a speedrun document by ID.
  ///
  /// Removes the specified speedrun from the database.
  Future<void> deleteSpeedrun(String id) async {
    await _db.deleteDocument(
        '${DatabaseService.speedruns}/$id'); // Deleting the document by ID.
  }
}
