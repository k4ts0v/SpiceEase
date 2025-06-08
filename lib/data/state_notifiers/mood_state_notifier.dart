import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/mood_model.dart';
import 'package:spiceease/data/services/mood_service.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

/// A state notifier that manages the mood entries of a user.
///
/// This notifier fetches and manages mood-related data for a specific date.
/// It extends the `StateNotifier` class, which is part of Riverpod's state management.
/// The state of this notifier is represented as a list of `MoodModel` objects.
class MoodStateNotifier extends StateNotifier<List<MoodModel>> {
  // Private fields
  final MoodService _moodService; // A service to interact with the mood data source
  final DateTime _date; // The date for which mood entries are being managed
  bool _isLoading = false; // Indicates whether a data fetch operation is In progress
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
  Future<void> fetchMoods() async {
    if (!mounted) return;
    _setLoading(true);
    _setError(null); // Clear previous errors
    debugPrint("[MoodStateNotifier] Fetching moods for date: $_date");
    try {
      final moods = await _moodService.getMoodsForDate(_date);
      if (!mounted) return;
      state = moods;
      debugPrint("[MoodStateNotifier] Fetched ${moods.length} moods for date: $_date");
    } catch (e, stackTrace) {
      if (!mounted) return;
      _setError(e.toString());
      debugPrint("[MoodStateNotifier] Error fetching moods for date: $_date. Error: $e, StackTrace: $stackTrace");
    } finally {
      if (mounted) {
        _setLoading(false);
      }
    }
  }

  /// Adds a new mood entry.
  Future<void> addMood(MoodModel mood) async {
    if (!mounted) return;
    _setLoading(true);
    try {
      await _moodService.createMood(mood);
      await fetchMoods(); // Refresh the list
    } catch (e) {
      if (!mounted) return;
      _setError(e.toString());
    } finally {
      if (mounted) {
        _setLoading(false);
      }
    }
  }

  /// Updates an existing mood entry.
  Future<void> updateMood(MoodModel mood) async {
    if (!mounted) return;
    _setLoading(true);
    try {
      await _moodService.updateMood(mood.id, mood);
      await fetchMoods(); // Refresh the list
    } catch (e) {
      if (!mounted) return;
      _setError(e.toString());
    } finally {
      if (mounted) {
        _setLoading(false);
      }
    }
  }

  /// Deletes a mood entry by its ID.
  Future<void> deleteMood(String moodId) async {
    if (!mounted) return;
    _setLoading(true);
    try {
      await _moodService.deleteMood(moodId);
      await fetchMoods(); // Refresh the list
    } catch (e) {
      if (!mounted) return;
      _setError(e.toString());
    } finally {
      if (mounted) {
        _setLoading(false);
      }
    }
  }

  void _setLoading(bool loading) {
    if (mounted) {
      _isLoading = loading;
      // No need to call setState for _isLoading and _error as they are not part of the 'state'
      // that StateNotifier manages directly for UI rebuilds based on List<MoodModel>.
      // If you need UI to react to isLoading/error, consider making them part of a more complex state object.
    }
  }

  void _setError(String? error) {
    if (mounted) {
      _error = error;
    }
  }
}