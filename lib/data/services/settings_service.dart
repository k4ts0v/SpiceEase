import 'package:spiceease/data/models/settings_model.dart';
import 'package:spiceease/data/repositories/settings_repository.dart';

/// A service layer that coordinates settings-related business logic.
///
/// This class depends on the [SettingsRepository] and provides higher-level
/// operations for managing settings. It's responsible for transforming data
/// or adding additional logic before calling the repository.
class SettingsService {
  final SettingsRepository _repository; // Dependency for accessing the repository.

  const SettingsService(this._repository);

  /// Retrieves all settings by delegating to the repository.
  Future<List<SettingsModel>> getAllSettings() => _repository.getAllSettings();

  /// Retrieves a specific settings by ID through the repository.
  Future<SettingsModel?> getSettingsById(String id) => _repository.getSettingsById(id);

  /// Creates a new settings by delegating to the repository.
  Future<SettingsModel> createSettings(SettingsModel settings) => _repository.createSettings(settings);

  /// Updates an existing settings by delegating to the repository.
  Future<SettingsModel> updateSettings(String id, SettingsModel settings) =>
      _repository.updateSettings(id, settings);

  /// Deletes a settings by delegating to the repository.
  Future<void> deleteSettings(String id) => _repository.deleteSettings(id);
}
