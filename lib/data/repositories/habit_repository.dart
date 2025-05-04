import 'package:spiceease/data/models/habit_model.dart';
import 'package:spiceease/core/database/database_service.dart';

/// A repository layer that abstracts habit-related database operations.
///
/// This class provides methods to interact with the database, such as
/// creating, updating, and fetching habit data. It also handles the
/// conversion between [HabitModel] and the Firestore-friendly map format.
class HabitRepository {
  final DatabaseService
      _db; // The database service for performing CRUD operations.

  const HabitRepository(this._db);

  /// Fetches all habit documents from the database.
  ///
  /// Queries the database for all documents in the habits collection.
  /// Each document is converted from a map to a [HabitModel] instance.
  Future<List<HabitModel>> getAllHabits() async {
    final results = await _db.query(
        collection: DatabaseService.habits); // Querying the habits collection.
    return results
        .map((e) => HabitModel.fromMap(e))
        .toList(); // Converting maps to HabitModel instances.
  }

  /// Retrieves a habit document by its unique ID.
  ///
  /// If a document exists for the given ID, its data is converted from a
  /// map to a [HabitModel]. Otherwise, returns null.
  Future<HabitModel?> getHabitById(String id) async {
    final data = await _db.getDocument(
        '${DatabaseService.habits}/$id'); // Fetching document by ID.
    return data != null
        ? HabitModel.fromMap(data)
        : null; // Returning a HabitModel or null.
  }

  /// Creates a new habit in the database.
  ///
  /// Takes a [HabitModel] instance, converts it to a map, and sends it
  /// to the database. The response is then converted back to a [HabitModel].
  Future<HabitModel> createHabit(HabitModel habit) async {
    final data = await _db.createDocument(
        DatabaseService.habits, habit.toMap()); // Creating a new document.
    return HabitModel.fromMap(
        data); // Returning the created habit as a HabitModel.
  }

  /// Updates an existing habit document in the database.
  ///
  /// Takes a habit ID and a [HabitModel]. The habit data is updated in the
  /// database, and the updated data is converted back to a [HabitModel].
  Future<HabitModel> updateHabit(String id, HabitModel habit) async {
    final data = await _db.updateDocument(
      '${DatabaseService.habits}/$id', // Document path.
      habit.toMap(), // Updated data as a map.
    );
    return HabitModel.fromMap(
        data); // Returning the updated habit as a HabitModel.
  }

  /// Deletes a habit document by ID.
  ///
  /// Removes the specified habit from the database.
  Future<void> deleteHabit(String id) async {
    await _db.deleteDocument(
        '${DatabaseService.habits}/$id'); // Deleting the document by ID.
  }
}
