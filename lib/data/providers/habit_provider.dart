import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/data/models/habit_model.dart';
import 'package:spiceease/data/services/habit_service.dart';
import 'package:spiceease/data/repositories/habit_repository.dart';
import 'package:spiceease/core/database/database_provider.dart';
import 'package:spiceease/data/state_notifiers/habit_state_notifier.dart';

/// Provides the [HabitRepository] instance.
///
/// This provider watches the [databaseServiceProvider] to
/// get the database layer dependency. When the database service
/// updates, it rebuilds the repository instance as well.
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final db = ref.watch(
      databaseServiceProvider); // Watching the database service provider.
  return HabitRepository(db); // Creating and returning a HabitRepository.
});

/// Provides the [HabitService] instance.
///
/// This provider depends on [habitRepositoryProvider] and initializes
/// the application service for habit-related operations. It ensures the
/// service layer always has an up-to-date repository instance.
final habitServiceProvider = Provider<HabitService>((ref) {
  final repo = ref.watch(habitRepositoryProvider); // Watching the habit repository provider.
  final auth = ref.watch(authServiceProvider);
  final db = ref.watch(databaseServiceProvider);
  return HabitService(repo, auth, db); // Creating and returning a HabitService instance.
});

/// Provides today's habits list./// Provides today's habits list.
final todayHabitsProvider = FutureProvider<List<HabitModel>>((ref) async {
  return ref.read(habitServiceProvider).getHabitsForDate(DateTime.now());
});

/// Provides a state notifier to manage habits.
final habitStateNotifierProvider = StateNotifierProvider.autoDispose.family<
    HabitStateNotifier, List<HabitModel>, DateTime>((ref, date) {
  final service = ref.read(habitServiceProvider);
  return HabitStateNotifier(service, date);
});