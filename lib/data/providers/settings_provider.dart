import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/services/settings_service.dart';
import 'package:spiceease/data/repositories/settings_repository.dart';
import 'package:spiceease/core/database/database_provider.dart';

/// Provides the [SettingsRepository] instance.
///
/// This provider watches the [databaseServiceProvider] to
/// get the database layer dependency. When the database service
/// updates, it rebuilds the repository instance as well.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final db = ref.watch(
      databaseServiceProvider); // Watching the database service provider.
  return SettingsRepository(db); // Creating and returning a SettingsRepository.
});

/// Provides the [SettingsService] instance.
///
/// This provider depends on [settingsRepositoryProvider] and initializes
/// the application service for settings-related operations. It ensures the
/// service layer always has an up-to-date repository instance.
final settingsServiceProvider = Provider<SettingsService>((ref) {
  final repo = ref
      .watch(settingsRepositoryProvider); // Watching the settings repository provider.
  return SettingsService(repo); // Creating and returning a SettingsService instance.
});
