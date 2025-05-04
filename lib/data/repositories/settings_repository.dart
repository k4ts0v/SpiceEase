import 'package:spiceease/data/models/settings_model.dart';
import 'package:spiceease/core/database/database_service.dart';

/// A repository layer that abstracts settings-related database operations.
///
/// This class provides methods to interact with the database, such as
/// creating, updating, and fetching settings data. It also handles the
/// conversion between [SettingsModel] and the Firestore-friendly map format.
class SettingsRepository {
  final DatabaseService
      _db; // The database service for performing CRUD operations.

  const SettingsRepository(this._db);

  /// Fetches all settings documents from the database.
  ///
  /// Queries the database for all documents in the settings collection.
  /// Each document is converted from a map to a [SettingsModel] instance.
  Future<List<SettingsModel>> getAllSettings() async {
    final results = await _db.query(
        collection: DatabaseService.settings); // Querying the settings collection.
    return results
        .map((e) => SettingsModel.fromMap(e))
        .toList(); // Converting maps to SettingsModel instances.
  }

  /// Retrieves a settings document by its unique ID.
  ///
  /// If a document exists for the given ID, its data is converted from a
  /// map to a [SettingsModel]. Otherwise, returns null.
  Future<SettingsModel?> getSettingsById(String id) async {
    final data = await _db.getDocument(
        '${DatabaseService.settings}/$id'); // Fetching document by ID.
    return data != null
        ? SettingsModel.fromMap(data)
        : null; // Returning a SettingsModel or null.
  }

  /// Creates a new settings in the database.
  ///
  /// Takes a [SettingsModel] instance, converts it to a map, and sends it
  /// to the database. The response is then converted back to a [SettingsModel].
  Future<SettingsModel> createSettings(SettingsModel settings) async {
    final data = await _db.createDocument(
        DatabaseService.settings, settings.toMap()); // Creating a new document.
    return SettingsModel.fromMap(
        data); // Returning the created settings as a SettingsModel.
  }

  /// Updates an existing settings document in the database.
  ///
  /// Takes a settings ID and a [SettingsModel]. The settings data is updated in the
  /// database, and the updated data is converted back to a [SettingsModel].
  Future<SettingsModel> updateSettings(String id, SettingsModel settings) async {
    final data = await _db.updateDocument(
      '${DatabaseService.settings}/$id', // Document path.
      settings.toMap(), // Updated data as a map.
    );
    return SettingsModel.fromMap(
        data); // Returning the updated settings as a SettingsModel.
  }

  /// Deletes a settings document by ID.
  ///
  /// Removes the specified settings from the database.
  Future<void> deleteSettings(String id) async {
    await _db.deleteDocument(
        '${DatabaseService.settings}/$id'); // Deleting the document by ID.
  }
}
