import 'package:spiceease/data/models/speedrun_model.dart';
import 'package:spiceease/data/repositories/speedrun_repository.dart';

/// A service layer that coordinates speedrun-related business logic.
///
/// This class depends on the [SpeedrunRepository] and provides higher-level
/// operations for managing speedruns. It's responsible for transforming data
/// or adding additional logic before calling the repository.
class SpeedrunService {
  final SpeedrunRepository _repository; // Dependency for accessing the repository.

  const SpeedrunService(this._repository);

  /// Retrieves all speedruns by delegating to the repository.
  Future<List<SpeedrunModel>> getAllSpeedruns() => _repository.getAllSpeedruns();

  /// Retrieves a specific speedrun by ID through the repository.
  Future<SpeedrunModel?> getSpeedrunById(String id) => _repository.getSpeedrunById(id);

  /// Creates a new speedrun by delegating to the repository.
  Future<SpeedrunModel> createSpeedrun(SpeedrunModel speedrun) => _repository.createSpeedrun(speedrun);

  /// Updates an existing speedrun by delegating to the repository.
  Future<SpeedrunModel> updateSpeedrun(String id, SpeedrunModel speedrun) =>
      _repository.updateSpeedrun(id, speedrun);

  /// Deletes a speedrun by delegating to the repository.
  Future<void> deleteSpeedrun(String id) => _repository.deleteSpeedrun(id);
}
