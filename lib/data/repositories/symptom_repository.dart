import 'package:spiceease/data/models/symptom_model.dart';
import 'package:spiceease/core/database/database_service.dart';

/// A repository layer that abstracts symptom-related database operations.
///
/// This class provides methods to interact with the database, such as
/// creating, updating, and fetching symptom data. It also handles the
/// conversion between [SymptomModel] and the Firestore-friendly map format.
class SymptomRepository {
  final DatabaseService
      _db; // The database service for performing CRUD operations.

  const SymptomRepository(this._db);

  /// Fetches all symptom documents from the database.
  ///
  /// Queries the database for all documents in the symptoms collection.
  /// Each document is converted from a map to a [SymptomModel] instance.
  Future<List<SymptomModel>> getAllSymptoms() async {
    final results = await _db.query(
        collection: DatabaseService
            .symptoms); // Querying the symptoms collection.
    return results
        .map((e) => SymptomModel.fromMap(e))
        .toList(); // Converting maps to SymptomModel instances.
  }

  /// Retrieves a symptom document by its unique ID.
  ///
  /// If a document exists for the given ID, its data is converted from a
  /// map to a [SymptomModel]. Otherwise, returns null.
  Future<SymptomModel?> getSymptomById(String id) async {
    final data = await _db.getDocument(
        '${DatabaseService.symptoms}/$id'); // Fetching document by ID.
    return data != null
        ? SymptomModel.fromMap(data)
        : null; // Returning a SymptomModel or null.
  }

  /// Creates a new symptom in the database.
  ///
  /// Takes a [SymptomModel] instance, converts it to a map, and sends it
  /// to the database. The response is then converted back to a [SymptomModel].
  Future<SymptomModel> createSymptom(SymptomModel symptom) async {
    final data = await _db.createDocument(DatabaseService.symptoms,
        symptom.toMap()); // Creating a new document.
    return SymptomModel.fromMap(
        data); // Returning the created symptom as a SymptomModel.
  }

  /// Updates an existing symptom document in the database.
  ///
  /// Takes a symptom ID and a [SymptomModel]. The symptom data is updated in the
  /// database, and the updated data is converted back to a [SymptomModel].
  Future<SymptomModel> updateSymptom(String id, SymptomModel symptom) async {
    final data = await _db.updateDocument(
      '${DatabaseService.symptoms}/$id', // Document path.
      symptom.toMap(), // Updated data as a map.
    );
    return SymptomModel.fromMap(
        data); // Returning the updated symptom as a SymptomModel.
  }

  /// Deletes a symptom document by ID.
  ///
  /// Removes the specified symptom from the database.
  Future<void> deleteSymptom(String id) async {
    await _db.deleteDocument(
        '${DatabaseService.symptoms}/$id'); // Deleting the document by ID.
  }
}
