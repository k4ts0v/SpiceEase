import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/data/models/flowmodoro_model.dart';
import 'package:spiceease/data/services/flowmodoro_service.dart';
import 'package:spiceease/data/repositories/flowmodoro_repository.dart';
import 'package:spiceease/core/database/database_provider.dart';
import 'package:spiceease/data/state_notifiers/flowmodoro_state_notifier.dart';

/// Provides the [FlowmodoroRepository] instance.
///
/// This provider watches the [databaseServiceProvider] to
/// get the database layer dependency. When the database service
/// updates, it rebuilds the repository instance as well.
final flowmodoroRepositoryProvider = Provider<FlowmodoroRepository>((ref) {
  final db = ref.watch(
      databaseServiceProvider); // Watching the database service provider.
  return FlowmodoroRepository(db, ref); // Creating and returning a FlowmodoroRepository.
});

/// Provides the [FlowmodoroService] instance.
///
/// This provider depends on [flowmodoroRepositoryProvider] and initializes
/// the application service for flowmodoro-related operations. It ensures the
/// service layer always has an up-to-date repository instance.
final flowmodoroServiceProvider = Provider<FlowmodoroService>((ref) {
  final repo = ref
      .watch(flowmodoroRepositoryProvider); // Watching the flowmodoro repository provider.
  final auth = ref.watch(authServiceProvider);
  final db = ref.watch(databaseServiceProvider);
  return FlowmodoroService(repo, auth, db); // Creating and returning a FlowmodoroService instance.
});


/// Provides a [FlowmodoroStateNotifier] for a given [DateTime].
final flowmodoroStateNotifierProvider = StateNotifierProvider.autoDispose
    .family<FlowmodoroStateNotifier, List<FlowmodoroModel>, DateTime>(
  (ref, date) {
    final service = ref.read(flowmodoroServiceProvider);
    return FlowmodoroStateNotifier(service, date);
  },
);