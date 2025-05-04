import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/data/models/symptom_model.dart';
import 'package:spiceease/data/services/symptom_service.dart';
import 'package:spiceease/data/repositories/symptom_repository.dart';
import 'package:spiceease/data/state_notifiers/symptom_state_notifier.dart';
import 'package:spiceease/core/database/database_provider.dart';

/// Provides the [SymptomRepository] instance.
final symptomRepositoryProvider = Provider<SymptomRepository>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return SymptomRepository(db);
});

/// Provides the [SymptomService] instance.
final symptomServiceProvider = Provider<SymptomService>((ref) {
  final repo = ref.watch(symptomRepositoryProvider);
  final auth = ref.watch(authServiceProvider);
  final db = ref.watch(databaseServiceProvider);
  return SymptomService(repo, auth, db);
});

/// Provides today's symptoms list.
final todaySymptomsProvider = FutureProvider<List<SymptomModel>>((ref) async {
  return ref.read(symptomServiceProvider).getSymptomsForDate(DateTime.now());
});

// /// Provides yesterday's symptom count for trend comparison.
// final yesterdaySymptomCountProvider = FutureProvider<int>((ref) async {
//   return ref.read(symptomServiceProvider);
//   // .getYesterdaySymptomCount();
// });

/// Provides a state notifier to manage symptoms.
final symptomStateNotifierProvider = StateNotifierProvider.autoDispose.family<
    SymptomStateNotifier, List<SymptomModel>, DateTime>((ref, date) {
  final service = ref.read(symptomServiceProvider);
  return SymptomStateNotifier(service, date);
});
