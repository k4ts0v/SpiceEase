import 'package:spiceease/data/models/mood_model.dart';
import 'package:spiceease/core/database/database_service.dart';

/// A repository layer that abstracts mood-related database operations.
///
/// This class provides methods to interact with the database, such as
/// creating, updating, and fetching mood data. It also handles the
/// conversion between [MoodModel] and the Firestore-friendly map format.
class MoodRepository {
  final DatabaseService
      _db; // The database service for performing CRUD operations.

  const MoodRepository(this._db);

  /// Fetches all mood documents from the database.
  ///
  /// Queries the database for all documents in the moodEntries collection.
  /// Each document is converted from a map to a [MoodModel] instance.
  Future<List<MoodModel>> getAllMoodEntries() async {
    final results = await _db.query(
        collection: DatabaseService
            .moodEntries); // Querying the moodEntries collection.
    return results
        .map((e) => MoodModel.fromMap(e))
        .toList(); // Converting maps to MoodModel instances.
  }

  /// Retrieves a mood document by its unique ID.
  ///
  /// If a document exists for the given ID, its data is converted from a
  /// map to a [MoodModel]. Otherwise, returns null.
  Future<MoodModel?> getMoodById(String id) async {
    final data = await _db.getDocument(
        '${DatabaseService.moodEntries}/$id'); // Fetching document by ID.
    return data != null
        ? MoodModel.fromMap(data)
        : null; // Returning a MoodModel or null.
  }

  /// Creates a new mood in the database.
  ///
  /// Takes a [MoodModel] instance, converts it to a map, and sends it
  /// to the database. The response is then converted back to a [MoodModel].
  Future<MoodModel> createMood(MoodModel mood) async {
    final data = await _db.createDocument(DatabaseService.moodEntries,
        mood.toMap()); // Creating a new document.
    return MoodModel.fromMap(
        data); // Returning the created mood as a MoodModel.
  }

  /// Updates an existing mood document in the database.
  ///
  /// Takes a mood ID and a [MoodModel]. The mood data is updated in the
  /// database, and the updated data is converted back to a [MoodModel].
  Future<MoodModel> updateMood(String id, MoodModel mood) async {
    final data = await _db.updateDocument(
      '${DatabaseService.moodEntries}/$id', // Document path.
      mood.toMap(), // Updated data as a map.
    );
    return MoodModel.fromMap(
        data); // Returning the updated mood as a MoodModel.
  }

  /// Deletes a mood document by ID.
  ///
  /// Removes the specified mood from the database.
  Future<void> deleteMood(String id) async {
    await _db.deleteDocument(
        '${DatabaseService.moodEntries}/$id'); // Deleting the document by ID.
  }
}
