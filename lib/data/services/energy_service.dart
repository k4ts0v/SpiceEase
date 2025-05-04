import 'package:spiceease/core/auth/auth_service.dart';
import 'package:spiceease/core/database/database_service.dart';
import 'package:spiceease/core/database/firerstore_date_adapter.dart';
import 'package:spiceease/data/models/energy_model.dart';
import 'package:spiceease/data/repositories/energy_repository.dart';

/// A service layer that coordinates energy-related business logic.
///
/// This class depends on the [EnergyRepository] and provides higher-level
/// operations for managing energyEntries. It's responsible for transforming data
/// or adding additional logic before calling the repository.
class EnergyService {
  final EnergyRepository
      _repository; // Dependency for accessing the repository.
  final AuthService _authService;
  final DatabaseService _db;

  EnergyService(this._repository, this._authService, this._db);

  /// Retrieves all energyEntries by delegating to the repository.
  Future<List<EnergyModel>> getAllEnergyEntries() =>
      _repository.getAllEnergyEntries();

  /// Retrieves a specific energy by ID through the repository.
  Future<EnergyModel?> getEnergyById(String id) =>
      _repository.getEnergyById(id);

  /// Creates a new energy by delegating to the repository.
  Future<EnergyModel> createEnergy(EnergyModel energy) =>
      _repository.createEnergy(energy);

  /// Updates an existing energy by delegating to the repository.
  Future<EnergyModel> updateEnergy(String id, EnergyModel energy) =>
      _repository.updateEnergy(id, energy);

  /// Deletes a energy by delegating to the repository.
  Future<void> deleteEnergy(String id) => _repository.deleteEnergy(id);

  String generateId() => _db.generateId(); // Generate unique ID

  Future<String> getCurrentUserId() async {
    final user = await _authService.getCurrentUser();
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

/// Retrieves a specific energy by ID through the repository.
  Future<EnergyModel?> getLastEnergyEntry() =>
      _repository.getLastEnergyEntry();

  /// Provides energy entries for the authenticated user in a specified date.
  Future<List<EnergyModel>> getEnergyEntriesForDate(DateTime date) async {
    final user = await _authService.getCurrentUser();
    if (user == null) return [];

    // Use Timestamps for Firestore queries
    final start = FirestoreDateAdapter.toTimestamp(
        DateTime(date.year, date.month, date.day));
    final end = FirestoreDateAdapter.toTimestamp(
        DateTime(date.year, date.month, date.day).add(Duration(days: 1)));

    final raw = await _db.query(
      collection: DatabaseService.energyEntries,
      filters: [
        QueryFilter.basic('user_id', QueryOperator.equal, user.uid),
        QueryFilter.basic('created_at', QueryOperator.greaterThanOrEqual, start),
        QueryFilter.basic('created_at', QueryOperator.lessThan, end),
      ],
      orderBy: [QueryOrder('created_at')],
    );

    print("Energy Entries: $raw");
    return raw.map((e) => EnergyModel.fromMap(e)).toList();
  }
}
