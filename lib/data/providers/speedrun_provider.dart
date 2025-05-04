import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/services/speedrun_service.dart';
import 'package:spiceease/data/repositories/speedrun_repository.dart';
import 'package:spiceease/core/database/database_provider.dart';

/// Provides the [SpeedrunRepository] instance.
///
/// This provider watches the [databaseServiceProvider] to
/// get the database layer dependency. When the database service
/// updates, it rebuilds the repository instance as well.
final speedrunRepositoryProvider = Provider<SpeedrunRepository>((ref) {
  final db = ref.watch(
      databaseServiceProvider); // Watching the database service provider.
  return SpeedrunRepository(db); // Creating and returning a SpeedrunRepository.
});

/// Provides the [SpeedrunService] instance.
///
/// This provider depends on [speedrunRepositoryProvider] and initializes
/// the application service for speedrun-related operations. It ensures the
/// service layer always has an up-to-date repository instance.
final speedrunServiceProvider = Provider<SpeedrunService>((ref) {
  final repo = ref
      .watch(speedrunRepositoryProvider); // Watching the speedrun repository provider.
  return SpeedrunService(repo); // Creating and returning a SpeedrunService instance.
});
