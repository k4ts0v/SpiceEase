import 'package:spiceease/data/models/energy_model.dart';
import 'package:spiceease/core/database/database_service.dart';

/// A repository layer that abstracts energy-related database operations.
///
/// This class provides methods to interact with the database, such as
/// creating, updating, and fetching energy data. It also handles the
/// conversion between [EnergyModel] and the Firestore-friendly map format.
class EnergyRepository {
  final DatabaseService
      _db; // The database service for performing CRUD operations.

  const EnergyRepository(this._db);

  /// Fetches all energy documents from the database.
  ///
  /// Queries the database for all documents in the energyEntries collection.
  /// Each document is converted from a map to a [EnergyModel] instance.
  Future<List<EnergyModel>> getAllEnergyEntries() async {
    final results = await _db.query(
        collection: DatabaseService
            .energyEntries); // Querying the energyEntries collection.
    return results
        .map((e) => EnergyModel.fromMap(e))
        .toList(); // Converting maps to EnergyModel instances.
  }

  /// Retrieves a energy document by its unique ID.
  ///
  /// If a document exists for the given ID, its data is converted from a
  /// map to a [EnergyModel]. Otherwise, returns null.
  Future<EnergyModel?> getEnergyById(String id) async {
    final data = await _db.getDocument(
        '${DatabaseService.energyEntries}/$id'); // Fetching document by ID.
    return data != null
        ? EnergyModel.fromMap(data)
        : null; // Returning a EnergyModel or null.
  }

  /// Creates a new energy in the database.
  ///
  /// Takes a [EnergyModel] instance, converts it to a map, and sends it
  /// to the database. The response is then converted back to a [EnergyModel].
  Future<EnergyModel> createEnergy(EnergyModel energy) async {
    final data = await _db.createDocument(DatabaseService.energyEntries,
        energy.toMap()); // Creating a new document.
    return EnergyModel.fromMap(
        data); // Returning the created energy as a EnergyModel.
  }

  /// Updates an existing energy document in the database.
  ///
  /// Takes a energy ID and a [EnergyModel]. The energy data is updated in the
  /// database, and the updated data is converted back to a [EnergyModel].
  Future<EnergyModel> updateEnergy(String id, EnergyModel energy) async {
    final data = await _db.updateDocument(
      '${DatabaseService.energyEntries}/$id', // Document path.
      energy.toMap(), // Updated data as a map.
    );
    return EnergyModel.fromMap(
        data); // Returning the updated energy as a EnergyModel.
  }

  /// Deletes a energy document by ID.
  ///
  /// Removes the specified energy from the database.
  Future<void> deleteEnergy(String id) async {
    await _db.deleteDocument(
        '${DatabaseService.energyEntries}/$id'); // Deleting the document by ID.
  }

  Future<EnergyModel?> getLastEnergyEntry() async {
    await _db.query(
      collection: DatabaseService.energyEntries,
      filters: [
        QueryFilter.basic('recorded_at', QueryOperator.greaterThanOrEqual,
            DateTime.now().subtract(const Duration(days: 1))),
      ],
      orderBy: [QueryOrder('recorded_at')],
    );
    final results = await _db.query(
        collection: DatabaseService
            .energyEntries); // Querying the energyEntries collection.
    if (results.isNotEmpty) {
      return EnergyModel.fromMap(results.first);
    } else {
      return null; // Return null if no results found.
    }
  }
}
