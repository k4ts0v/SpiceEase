import 'package:spiceease/data/models/medication_model.dart';
import 'package:spiceease/core/database/database_service.dart';

/// A repository layer that abstracts medication-related database operations.
///
/// This class provides methods to interact with the database, such as
/// creating, updating, and fetching medication data. It also handles the
/// conversion between [MedicationModel] and the Firestore-friendly map format.
class MedicationRepository {
  final DatabaseService
      _db; // The database service for performing CRUD operations.

  const MedicationRepository(this._db);

  /// Fetches all medication documents from the database.
  ///
  /// Queries the database for all documents in the medications collection.
  /// Each document is converted from a map to a [MedicationModel] instance.
  Future<List<MedicationModel>> getAllMedications() async {
    final results = await _db.query(
        collection: DatabaseService
            .medications); // Querying the medications collection.
    return results
        .map((e) => MedicationModel.fromMap(e))
        .toList(); // Converting maps to MedicationModel instances.
  }

  /// Retrieves a medication document by its unique ID.
  ///
  /// If a document exists for the given ID, its data is converted from a
  /// map to a [MedicationModel]. Otherwise, returns null.
  Future<MedicationModel?> getMedicationById(String id) async {
    final data = await _db.getDocument(
        '${DatabaseService.medications}/$id'); // Fetching document by ID.
    return data != null
        ? MedicationModel.fromMap(data)
        : null; // Returning a MedicationModel or null.
  }

  /// Creates a new medication in the database.
  ///
  /// Takes a [MedicationModel] instance, converts it to a map, and sends it
  /// to the database. The response is then converted back to a [MedicationModel].
  Future<MedicationModel> createMedication(MedicationModel medication) async {
    final data = await _db.createDocument(DatabaseService.medications,
        medication.toMap()); // Creating a new document.
    return MedicationModel.fromMap(
        data); // Returning the created medication as a MedicationModel.
  }

  /// Updates an existing medication document in the database.
  ///
  /// Takes a medication ID and a [MedicationModel]. The medication data is updated in the
  /// database, and the updated data is converted back to a [MedicationModel].
  Future<MedicationModel> updateMedication(String id, MedicationModel medication) async {
    final data = await _db.updateDocument(
      '${DatabaseService.medications}/$id', // Document path.
      medication.toMap(), // Updated data as a map.
    );
    return MedicationModel.fromMap(
        data); // Returning the updated medication as a MedicationModel.
  }

  /// Deletes a medication document by ID.
  ///
  /// Removes the specified medication from the database.
  Future<void> deleteMedication(String id) async {
    await _db.deleteDocument(
        '${DatabaseService.medications}/$id'); // Deleting the document by ID.
  }
}
