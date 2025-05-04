import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/services/subtask_service.dart';
import 'package:spiceease/data/repositories/subtask_repository.dart';
import 'package:spiceease/core/database/database_provider.dart';

/// Provides the [SubtaskRepository] instance.
///
/// This provider watches the [databaseServiceProvider] to
/// get the database layer dependency. When the database service
/// updates, it rebuilds the repository instance as well.
final subtaskRepositoryProvider = Provider<SubtaskRepository>((ref) {
  final db = ref.watch(
      databaseServiceProvider); // Watching the database service provider.
  return SubtaskRepository(db); // Creating and returning a SubtaskRepository.
});

/// Provides the [SubtaskService] instance.
///
/// This provider depends on [subtaskRepositoryProvider] and initializes
/// the application service for subtask-related operations. It ensures the
/// service layer always has an up-to-date repository instance.
final subtaskServiceProvider = Provider<SubtaskService>((ref) {
  final repo = ref
      .watch(subtaskRepositoryProvider); // Watching the subtask repository provider.
  return SubtaskService(repo); // Creating and returning a SubtaskService instance.
});
