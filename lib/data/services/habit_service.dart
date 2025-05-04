import 'package:spiceease/core/auth/auth_service.dart';
import 'package:spiceease/core/database/database_service.dart';
import 'package:spiceease/data/models/habit_model.dart';
import 'package:spiceease/data/repositories/habit_repository.dart';

/// A service layer that coordinates habit-related business logic.
///
/// This class depends on the [HabitRepository] and provides higher-level
/// operations for managing habits. It's responsible for transforming data
/// or adding additional logic before calling the repository.
class HabitService {
  final HabitRepository _repository; // Dependency for accessing the repository.
  final AuthService _authService; // Dependency for accessing the auth.
  final DatabaseService _db; // Dependency for accessing the db.

  HabitService(this._repository, this._authService, this._db);

  /// Retrieves all habits by delegating to the repository.
  Future<List<HabitModel>> getAllHabits() => _repository.getAllHabits();

  /// Retrieves a specific habit by ID through the repository.
  Future<HabitModel?> getHabitById(String id) => _repository.getHabitById(id);

  /// Creates a new habit by delegating to the repository.
  Future<HabitModel> createHabit(HabitModel habit) =>
      _repository.createHabit(habit);

  /// Updates an existing habit by delegating to the repository.
  Future<HabitModel> updateHabit(String id, HabitModel habit) =>
      _repository.updateHabit(id, habit);

  /// Deletes a habit by delegating to the repository.
  Future<void> deleteHabit(String id) => _repository.deleteHabit(id);

  // Provides habit entries for the authenticated user in a specified date.
  /// Since FireStore has technical limitations regarding queries,
  /// this was Done client-side.
  Future<List<HabitModel>> getHabitsForDate(DateTime date) async {
    final user = await _authService.getCurrentUser();
    if (user == null) return [];

    // Get all habits for the user first
    final allHabitsQuery = await _db.query(
      collection: DatabaseService.habits,
      filters: [QueryFilter.basic('user_id', QueryOperator.equal, user.uid)],
    );

    // Process habits client-side to avoid Firestore limitations
    final habits =
        allHabitsQuery.map((e) => HabitModel.fromMap(e)).where((habit) {
      // Daily habits
      if (habit.frequency == 1) return true;

      // Weekly habits
      if (habit.frequency == 7 &&
          habit.customDays != null &&
          habit.customDays!.contains(date.weekday)) {
        return true;
      }

      // Monthly habits
      if (habit.frequency == -1 &&
          habit.customDays != null &&
          habit.customDays!.contains(date.day)) {
        return true;
      }

      // Check next_due_date
      if (habit.nextDueDate != null) {
        final nextDue = DateTime(
          habit.nextDueDate!.year,
          habit.nextDueDate!.month,
          habit.nextDueDate!.day,
        );
        final compareDate = DateTime(date.year, date.month, date.day);
        return nextDue.isAtSameMomentAs(compareDate);
      }

      return false;
    }).toList();

    print('Filtered habits count: ${habits.length}');
    for (final habit in habits) {
      print(
          'Habit: ${habit.title} (ID: ${habit.id}, Frequency: ${habit.frequency}, CustomDays: ${habit.customDays})');
    }

    return habits;
  }

  String generateId() => _db.generateId(); // Generate unique ID
  Future<String> getCurrentUserId() async {
    final user = await _authService.getCurrentUser();
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }
}
