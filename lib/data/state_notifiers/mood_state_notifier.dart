import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/mood_model.dart';
import 'package:spiceease/data/providers/unified_auth_provider.dart';
import 'package:spiceease/data/services/mood_service.dart';
import 'package:spiceease/app/app_initializer.dart';
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
  final Ref _ref; // Reference to access other providers
  bool _isLoading = false; // Indicates whether a data fetch operation is In progress
  String? _error; // Stores any error messages from failed operations

  /// Constructor for `MoodStateNotifier`.
  ///
  /// Requires an instance of [MoodService] to fetch mood data, a [DateTime]
  /// object to specify the date for fetching mood entries, and a [Ref] to access providers.
  ///
  /// Automatically calls [fetchMoods] to load the initial data if user is authenticated.
  MoodStateNotifier(this._moodService, this._date, this._ref) : super([]) {
    _initializeIfAuthenticated();
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

  /// Initialize data fetching only if user is authenticated
  Future<void> _initializeIfAuthenticated() async {
    try {
      final isAuthenticated = _ref.read(isAuthenticatedProvider);
      if (isAuthenticated && mounted) {
        await fetchMoods();
      } else {
        debugPrint("[MoodStateNotifier] User not authenticated, skipping mood fetch");
      }
    } catch (e) {
      debugPrint("[MoodStateNotifier] Error checking authentication: $e");
    }
  }

  /// Checks if user is authenticated and database is initialized before performing operations
  Future<bool> _ensureAuthenticatedAndInitialized() async {
    try {
      // Check authentication status
      final isAuthenticated = _ref.read(isAuthenticatedProvider);
      if (!isAuthenticated) {
        debugPrint("[MoodStateNotifier] User not authenticated");
        _setError("User not authenticated");
        return false;
      }

      // Ensure database is initialized
      await _ref.read(databaseInitializerProvider.future);
      return true;
    } catch (e) {
      debugPrint("[MoodStateNotifier] Authentication or database initialization failed: $e");
      if (e.toString().contains('Firestore not initialized') || 
          e.toString().contains('Database not initialized')) {
        _setError("Database not available. Please log in.");
      } else {
        _setError("Authentication error: ${e.toString()}");
      }
      return false;
    }
  }

  /// Fetches mood entries for the specified date.
  ///
  /// This method first checks authentication and database initialization,
  /// then interacts with the `_moodService` to load mood entries
  /// for the `_date`. It updates the state with the fetched data and handles
  /// any errors that occur during the operation.
  Future<void> fetchMoods() async {
    if (!mounted) return;
    
    _setLoading(true);
    _setError(null); // Clear previous errors
    
    debugPrint("[MoodStateNotifier] Fetching moods for date: $_date");
    
    try {
      // Check authentication and database initialization first
      final canProceed = await _ensureAuthenticatedAndInitialized();
      if (!canProceed) {
        if (mounted) {
          state = []; // Clear state for unauthenticated users
          _setLoading(false);
        }
        return;
      }

      final moods = await _moodService.getMoodsForDate(_date);
      if (!mounted) return;
      
      state = moods;
      debugPrint("[MoodStateNotifier] Fetched ${moods.length} moods for date: $_date");
    } catch (e, stackTrace) {
      if (!mounted) return;
      
      // Handle specific database errors
      if (e.toString().contains('Firestore not initialized') || 
          e.toString().contains('Database not initialized')) {
        debugPrint("[MoodStateNotifier] Database not available - user may not be authenticated");
        _setError("Please log in to access your mood data");
        state = []; // Clear state
      } else {
        _setError(e.toString());
        debugPrint("[MoodStateNotifier] Error fetching moods for date: $_date. Error: $e, StackTrace: $stackTrace");
      }
    } finally {
      if (mounted) {
        _setLoading(false);
      }
    }
  }

  /// Adds a new mood entry.
  /// Only works if user is authenticated and database is initialized.
  Future<void> addMood(MoodModel mood) async {
    if (!mounted) return;
    
    _setLoading(true);
    _setError(null);
    
    try {
      final canProceed = await _ensureAuthenticatedAndInitialized();
      if (!canProceed) {
        _setLoading(false);
        return;
      }

      await _moodService.createMood(mood);
      await fetchMoods(); // Refresh the list
    } catch (e) {
      if (!mounted) return;
      _setError(e.toString());
      debugPrint("[MoodStateNotifier] Error adding mood: $e");
    } finally {
      if (mounted) {
        _setLoading(false);
      }
    }
  }

  /// Updates an existing mood entry.
  /// Only works if user is authenticated and database is initialized.
  Future<void> updateMood(MoodModel mood) async {
    if (!mounted) return;
    
    _setLoading(true);
    _setError(null);
    
    try {
      final canProceed = await _ensureAuthenticatedAndInitialized();
      if (!canProceed) {
        _setLoading(false);
        return;
      }

      await _moodService.updateMood(mood.id, mood);
      await fetchMoods(); // Refresh the list
    } catch (e) {
      if (!mounted) return;
      _setError(e.toString());
      debugPrint("[MoodStateNotifier] Error updating mood: $e");
    } finally {
      if (mounted) {
        _setLoading(false);
      }
    }
  }

  /// Deletes a mood entry by its ID.
  /// Only works if user is authenticated and database is initialized.
  Future<void> deleteMood(String moodId) async {
    if (!mounted) return;
    
    _setLoading(true);
    _setError(null);
    
    try {
      final canProceed = await _ensureAuthenticatedAndInitialized();
      if (!canProceed) {
        _setLoading(false);
        return;
      }

      await _moodService.deleteMood(moodId);
      await fetchMoods(); // Refresh the list
    } catch (e) {
      if (!mounted) return;
      _setError(e.toString());
      debugPrint("[MoodStateNotifier] Error deleting mood: $e");
    } finally {
      if (mounted) {
        _setLoading(false);
      }
    }
  }

  /// Refreshes mood data - useful after user logs in
  Future<void> refresh() async {
    await fetchMoods();
  }

  /// Clears all mood data - useful when user logs out
  void clear() {
    if (mounted) {
      state = [];
      _setError(null);
      _setLoading(false);
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