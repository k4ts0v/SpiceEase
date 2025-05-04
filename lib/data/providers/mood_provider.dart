import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/data/models/mood_model.dart';
import 'package:spiceease/data/services/mood_service.dart';
import 'package:spiceease/data/repositories/mood_repository.dart';
import 'package:spiceease/core/database/database_provider.dart';
import 'package:spiceease/data/state_notifiers/mood_state_notifier.dart';

/// Provides the [MoodRepository] instance.
///
/// This provider watches the [databaseServiceProvider] to
/// get the database layer dependency. When the database service
/// updates, it rebuilds the repository instance as well.
final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  final db = ref.watch(
      databaseServiceProvider); // Watching the database service provider.
  return MoodRepository(db); // Creating and returning a MoodRepository.
});

/// Provides the [MoodService] instance.
///
/// This provider depends on [moodRepositoryProvider] and initializes
/// the application service for mood-related operations. It ensures the
/// service layer always has an up-to-date repository instance.
final moodServiceProvider = Provider<MoodService>((ref) {
  final repo = ref
      .watch(moodRepositoryProvider); // Watching the mood repository provider.
  final auth = ref.watch(authServiceProvider);
  final db = ref.watch(databaseServiceProvider);
  return MoodService(repo, auth, db); // Creating and returning a MoodService instance.
});

/// Provides today's moods list.
final todayMoodsProvider = FutureProvider<List<MoodModel>>((ref) async {
  return ref.read(moodServiceProvider).getMoodsForDate(DateTime.now());
});


/// Provides a state notifier to manage moods.
final moodStateNotifierProvider = StateNotifierProvider.autoDispose
    .family<MoodStateNotifier, List<MoodModel>, DateTime>((ref, date) {
  final service = ref.read(moodServiceProvider);
  return MoodStateNotifier(service, date);
});

