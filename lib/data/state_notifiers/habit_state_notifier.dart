import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/habit_model.dart';
import 'package:spiceease/data/services/habit_service.dart';

/// A state notifier that manages the habit entries of a user.
///
/// This notifier fetches and manages habit-related data for a specific date.
/// It extends the `StateNotifier` class, which is part of Riverpod's state management.
/// The state of this notifier is represented as a list of `HabitModel` objects.
class HabitStateNotifier extends StateNotifier<List<HabitModel>> {
  // Private fields
  final HabitService
      _habitService; // A service to interact with the habit data source
  final DateTime _date; // The date for which habit entries are being managed
  bool _isLoading =
      false; // Indicates whether a data fetch operation is in progress
  String? _error; // Stores any error messages from failed operations

  /// Constructor for `HabitStateNotifier`.
  ///
  /// Requires an instance of [HabitService] to fetch habit data and a [DateTime]
  /// object to specify the date for fetching habit entries.
  ///
  /// Automatically calls [fetchHabits] to load the initial data.
  HabitStateNotifier(this._habitService, this._date) : super([]) {
    fetchHabits();
  }

  /// Getter for the `isLoading` field.
  ///
  /// Returns `true` if a fetch operation is in progress, otherwise `false`.
  bool get isLoading => _isLoading;

  /// Getter for the `error` field.
  ///
  /// Returns an error message if an error occurred during the last operation,
  /// otherwise returns `null`.
  String? get error => _error;

  /// Fetches habit entries for the specified date.
  ///
  /// This method interacts with the `_habitService` to load habit entries
  /// for the `_date`. It updates the state with the fetched data and handles
  /// any errors that occur during the operation.
  ///
  /// Updates:
  /// - Sets `_isLoading` to `true` at the start of the operation.
  /// - Sets `state` with the fetched habit data if successful.
  /// - Sets `_error` with an error message if the operation fails.
  Future<void> fetchHabits() async {
    // ===== DISPOSAL CHECK =====
    // Ensure the notifier hasn't been disposed before starting operation
    if (!mounted) return;

    _setLoading(true); // Mark the loading state as active
    try {
      // Fetch habit entries for the specified date
      final habits = await _habitService.getHabitsForDate(_date);

      // ===== DISPOSAL CHECK AFTER ASYNC OPERATION =====
      // Check if notifier is still mounted after async operation completes
      if (!mounted) return;

      // Update the state with fetched data
      state = habits;
      _setLoading(false); // Mark the loading state as inactive
    } catch (e) {
      // ===== DISPOSAL CHECK BEFORE ERROR HANDLING =====
      // Ensure notifier is still mounted before updating error state
      if (!mounted) return;

      _setLoading(false); // Ensure loading is marked inactive on error
      _setError(e.toString()); // Record the error message
    }
  }

  /// Refreshes the habit data by re-fetching from the service
  ///
  /// This method provides a public interface for refreshing data,
  /// with built-in disposal checking to prevent errors
  Future<void> refresh() async {
    if (!mounted) return;
    await fetchHabits();
  }

  /// Updates a specific habit in the current state without full refresh
  ///
  /// This method allows for optimistic updates to individual habits
  /// while maintaining state consistency
  void updateHabitInState(HabitModel updatedHabit) {
    if (!mounted) return;

    state = [
      for (final habit in state)
        if (habit.id == updatedHabit.id) updatedHabit else habit
    ];
  }

  /// Adds a new habit to the current state
  ///
  /// This method allows for optimistic addition of new habits
  /// without requiring a full data refresh
  void addHabitToState(HabitModel newHabit) {
    if (!mounted) return;

    state = [...state, newHabit];
  }

  /// Removes a habit from the current state
  ///
  /// This method allows for optimistic removal of habits
  /// without requiring a full data refresh
  void removeHabitFromState(String habitId) {
    if (!mounted) return;

    state = state.where((habit) => habit.id != habitId).toList();
  }

  /// Updates the `_isLoading` field to reflect the current loading state.
  ///
  /// [loading]: A boolean indicating whether a fetch operation is in progress.
  void _setLoading(bool loading) {
    if (!mounted) return;
    _isLoading = loading;
  }

  /// Updates the `_error` field with an error message.
  ///
  /// [error]: A string containing the error message to record.
  void _setError(String error) {
    if (!mounted) return;
    _error = error;
  }
}
