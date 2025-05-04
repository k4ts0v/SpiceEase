import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/data/models/medication_model.dart';
import 'package:spiceease/data/services/medication_service.dart';
import 'package:spiceease/data/repositories/medication_repository.dart';
import 'package:spiceease/core/database/database_provider.dart';
import 'package:spiceease/data/state_notifiers/medication_state_notifier.dart';

/// Provides the [MedicationRepository] instance.
///
/// This provider watches the [databaseServiceProvider] to
/// get the database layer dependency. When the database service
/// updates, it rebuilds the repository instance as well.
final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  final db = ref.watch(
      databaseServiceProvider); // Watching the database service provider.
  return MedicationRepository(db); // Creating and returning a MedicationRepository.
});

/// Provides the [MedicationService] instance.
///
/// This provider depends on [medicationRepositoryProvider] and initializes
/// the application service for medication-related operations. It ensures the
/// service layer always has an up-to-date repository instance.
final medicationServiceProvider = Provider<MedicationService>((ref) {
  final repo = ref
      .watch(medicationRepositoryProvider); // Watching the medication repository provider.
  final auth = ref.watch(authServiceProvider);
  final db = ref.watch(databaseServiceProvider);
  return MedicationService(repo, auth, db); // Creating and returning a MedicationService instance.
});


/// Provides a state notifier to manage medications.
final medicationStateNotifierProvider = StateNotifierProvider.autoDispose
    .family<MedicationStateNotifier, List<MedicationModel>, DateTime>((ref, date) {
  final service = ref.read(medicationServiceProvider);
  return MedicationStateNotifier(service, date);
});
