import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/medication_model.dart';
import 'package:spiceease/data/services/medication_service.dart';

/// A state notifier that manages the medication entries of a user.
///
/// This notifier fetches and manages medication-related data for a specific date.
/// It extends the `StateNotifier` class, which is part of Riverpod's state management.
/// The state of this notifier is represented as a list of `MedicationModel` objects.
class MedicationStateNotifier extends StateNotifier<List<MedicationModel>> {
  // Private fields
  final MedicationService
      _medicationService; // A service to interact with the medication data source
  final DateTime _date; // The date for which medication entries are being managed
  bool _isLoading =
      false; // Indicates whether a data fetch operation is in progress
  String? _error; // Stores any error messages from failed operations

  /// Constructor for `MedicationStateNotifier`.
  ///
  /// Requires an instance of [MedicationService] to fetch medication data and a [DateTime]
  /// object to specify the date for fetching medication entries.
  ///
  /// Automatically calls [fetchMedications] to load the initial data.
  MedicationStateNotifier(this._medicationService, this._date) : super([]) {
    fetchMedications();
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

  /// Fetches medication entries for the specified date.
  ///
  /// This method interacts with the `_medicationService` to load medication entries
  /// for the `_date`. It updates the state with the fetched data and handles
  /// any errors that occur during the operation.
  ///
  /// Updates:
  /// - Sets `_isLoading` to `true` at the start of the operation.
  /// - Sets `state` with the fetched medication data if successful.
  /// - Sets `_error` with an error message if the operation fails.
  Future<void> fetchMedications() async {
    if (!mounted) return;

    _setLoading(true); // Mark the loading state as active
    try {
      // Fetch medication entries for the specified date
      final medications = await _medicationService.getMedicationsForDate(_date);

      if (!mounted) return;

      // Update the state with fetched data
      state = medications;
      _setLoading(false); // Mark the loading state as inactive
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching medications: $e');
      }
      if (mounted) {
        _setLoading(false); // Ensure loading is marked inactive on error
        _setError(e.toString()); // Record the error message
      }
    }
  }

  /// Updates the `_isLoading` field to reflect the current loading state.
  ///
  /// [loading]: A boolean indicating whether a fetch operation is in progress.
  void _setLoading(bool loading) => _isLoading = loading;

  /// Updates the `_error` field with an error message.
  ///
  /// [error]: A string containing the error message to record.
  void _setError(String error) => _error = error;
}