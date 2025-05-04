import 'package:spiceease/core/auth/auth_service.dart';
import 'package:spiceease/core/database/database_service.dart';
import 'package:spiceease/core/database/firerstore_date_adapter.dart';
import 'package:spiceease/data/models/mood_model.dart';
import 'package:spiceease/data/repositories/mood_repository.dart';

/// A service layer that coordinates mood-related business logic.
///
/// This class depends on the [MoodRepository] and provides higher-level
/// operations for managing moods. It's responsible for transforming data
/// or adding additional logic before calling the repository.
class MoodService {
  final MoodRepository
      _repository; // Dependency for accessing the repository.
  final AuthService _authService;
  final DatabaseService _db;

  MoodService(this._repository, this._authService, this._db);

  /// Retrieves all moods by delegating to the repository.
  Future<List<MoodModel>> getAllMoods() =>
      _repository.getAllMoodEntries();

  /// Retrieves a specific mood by ID through the repository.
  Future<MoodModel?> getMoodById(String id) =>
      _repository.getMoodById(id);

  /// Creates a new mood by delegating to the repository.
  Future<MoodModel> createMood(MoodModel mood) =>
      _repository.createMood(mood);

  /// Updates an existing mood by delegating to the repository.
  Future<MoodModel> updateMood(String id, MoodModel mood) =>
      _repository.updateMood(id, mood);

  /// Deletes a mood by delegating to the repository.
  Future<void> deleteMood(String id) => _repository.deleteMood(id);

  String generateId() => _db.generateId(); // Generate unique ID

  Future<String> getCurrentUserId() async {
    final user = await _authService.getCurrentUser();
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  /// Provides mood entries for the authenticated user in a specified date.
  Future<List<MoodModel>> getMoodsForDate(DateTime date) async {
    final user = await _authService.getCurrentUser();
    if (user == null) return [];

    final start = FirestoreDateAdapter.toTimestamp(
        DateTime(date.year, date.month, date.day));
    final end = FirestoreDateAdapter.toTimestamp(
        DateTime(date.year, date.month, date.day).add(Duration(days: 1)));

    final raw = await _db.query(
      collection: DatabaseService.moodEntries,
      filters: [
        QueryFilter.basic('user_id', QueryOperator.equal, user.uid),
        QueryFilter.basic('created_at', QueryOperator.greaterThanOrEqual, start),
        QueryFilter.basic('created_at', QueryOperator.lessThan, end),
      ],
      orderBy: [QueryOrder('created_at')],
    );

    return raw.map((e) => MoodModel.fromMap(e)).toList();
  }
}
