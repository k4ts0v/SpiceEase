import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/data/models/energy_model.dart';
import 'package:spiceease/data/services/energy_service.dart';
import 'package:spiceease/data/repositories/energy_repository.dart';
import 'package:spiceease/core/database/database_provider.dart';
import 'package:spiceease/data/state_notifiers/energy_state_notifier.dart';

/// Provides the [EnergyRepository] instance.
///
/// This provider watches the [databaseServiceProvider] to
/// get the database layer dependency. When the database service
/// updates, it rebuilds the repository instance as well.
final energyRepositoryProvider = Provider<EnergyRepository>((ref) {
  final db = ref.watch(
      databaseServiceProvider); // Watching the database service provider.
  return EnergyRepository(db); // Creating and returning a EnergyRepository.
});

/// Provides the [EnergyService] instance.
///
/// This provider depends on [energyRepositoryProvider] and initializes
/// the application service for energy-related operations. It ensures the
/// service layer always has an up-to-date repository instance.
final energyServiceProvider = Provider<EnergyService>((ref) {
  final repo = ref
      .watch(energyRepositoryProvider); // Watching the energy repository provider.
  final auth = ref.watch(authServiceProvider);
  final db = ref.watch(databaseServiceProvider);
  return EnergyService(repo, auth, db); // Creating and returning a EnergyService instance.
});


/// Provides a state notifier to manage energies.
final energyStateNotifierProvider = StateNotifierProvider.autoDispose
    .family<EnergyStateNotifier, List<EnergyModel>, DateTime>((ref, date) {
  final service = ref.read(energyServiceProvider);
  return EnergyStateNotifier(service, date);
});
