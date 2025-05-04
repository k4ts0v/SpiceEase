import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/mood_model.dart';
import 'package:spiceease/data/services/mood_service.dart';

/// A state notifier that manages the mood entries of a user.
///
/// This notifier fetches and manages mood-related data for a specific date.
/// It extends the `StateNotifier` class, which is part of Riverpod's state management.
/// The state of this notifier is represented as a list of `MoodModel` objects.
class MoodStateNotifier extends StateNotifier<List<MoodModel>> {
  // Private fields
  final MoodService
      _moodService; // A service to interact with the mood data source
  final DateTime _date; // The date for which mood entries are being managed
  bool _isLoading =
      false; // Indicates whether a data fetch operation is In progress
  String? _error; // Stores any error messages from failed operations

  /// Constructor for `MoodStateNotifier`.
  ///
  /// Requires an instance of [MoodService] to fetch mood data and a [DateTime]
  /// object to specify the date for fetching mood entries.
  ///
  /// Automatically calls [fetchMoods] to load the initial data.
  MoodStateNotifier(this._moodService, this._date) : super([]) {
    fetchMoods();
  }

  /// Getter for the `isLoading` field.
  ///
  /// Returns `true` if a fetch operation is In progress, otherwise `false`.
  bool get isLoading => _isLoading;

  /// Getter for the `error` field.
  ///
  /// Returns an error message if an error occurred during the last operation,
  /// otherwise returns `null`.
  String? get error => _error;

  /// Fetches mood entries for the specified date.
  ///
  /// This method interacts with the `_moodService` to load mood entries
  /// for the `_date`. It updates the state with the fetched data and handles
  /// any errors that occur during the operation.
  ///
  /// Updates:
  /// - Sets `_isLoading` to `true` at the start of the operation.
  /// - Sets `state` with the fetched mood data if successful.
  /// - Sets `_error` with an error message if the operation fails.
  Future<void> fetchMoods() async {
    if (!mounted) return;
    _setLoading(true); // Mark the loading state as active
    try {
      // Fetch mood entries for the specified date
      final moods = await _moodService.getMoodsForDate(_date);
      if (!mounted) return;

      // Update the state with fetched data
      state = moods;
      _setLoading(false); // Mark the loading state as inactive
    } catch (e) {
      if (!mounted) return;
      _setLoading(false); // Ensure loading is marked inactive on error
      _setError(e.toString()); // Record the error message
    }
  }

  /// Updates the `_isLoading` field to reflect the current loading state.
  ///
  /// [loading]: A boolean indicating whether a fetch operation is In progress.
  void _setLoading(bool loading) => _isLoading = loading;

  /// Updates the `_error` field with an error message.
  ///
  /// [error]: A string containing the error message to record.
  void _setError(String error) => _error = error;
}
