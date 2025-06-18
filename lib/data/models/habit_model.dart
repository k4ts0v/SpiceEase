// ===== CORE FLUTTER/DART IMPORTS =====
// Flutter material design components and debugging utilities
import 'package:flutter/material.dart';
// Internationalization support for date formatting and locale-specific operations
import 'package:intl/intl.dart';

// ===== APPLICATION DATABASE IMPORTS =====
// Firestore date adapter for consistent timestamp handling across the application
import 'package:spiceease/core/database/firestore_date_adapter.dart';

// ===== HABIT DATA MODEL =====
/// Comprehensive data model representing a habit entity with completion tracking and scheduling
///
/// This model encapsulates all habit-related data including basic habit information,
/// completion tracking, flexible scheduling patterns, and streak analytics. It supports
/// various frequency patterns for building consistent habits and tracking progress over time.
///
/// Key features:
/// - Immutable core identifiers (id, userId, createdAt) for data integrity
/// - Flexible frequency support (daily intervals or custom days/weeks)
/// - Completion tracking with historical date records
/// - Next due date calculation based on frequency patterns
/// - Streak calculation and habit analytics support
/// - Real-time completion toggling with automatic date normalization
/// - Firebase Firestore integration with type-safe serialization
/// - Debug utilities for completion tracking and troubleshooting
///
/// Supports various habit patterns:
/// - Daily habits (every N days)
/// - Weekly habits (specific days of the week)
/// - Monthly habits (specific days of the month)
/// - Custom frequency patterns with flexible scheduling
class HabitModel {
  // ===== IMMUTABLE CORE IDENTIFIERS =====

  /// Unique identifier for this habit (Firestore document ID)
  /// Immutable once assigned to maintain referential integrity across the system
  final String _id;

  /// User ID that owns this habit (foreign key reference)
  /// Immutable to prevent accidental habit ownership changes
  final String _userId;

  /// Habit creation timestamp (audit trail)
  /// Immutable to maintain accurate creation history for streak calculations
  final DateTime _createdAt;

  // ===== MUTABLE HABIT PROPERTIES =====

  /// Habit title/name - the primary habit identifier for users
  /// Validated through setter to ensure non-empty values
  String _title;

  /// Detailed habit description or notes
  /// Optional field for additional habit context and motivation
  String _description;

  /// Frequency pattern for habit scheduling
  /// - Positive values: repeat every N days (e.g., 1=daily, 7=weekly)
  /// - Zero: use custom days pattern from _customDays list
  int _frequency;

  /// Custom days for flexible scheduling patterns
  /// - For weekly patterns: days of week (1=Monday, 7=Sunday)
  /// - For monthly patterns: days of month (1-31)
  /// - Null when using simple frequency intervals
  List<int>? _customDays;

  /// Historical record of all dates when habit was completed
  /// Used for streak tracking, analytics, and progress visualization
  /// Each entry represents one completion on that date (normalized to midnight)
  List<DateTime> _completedDates;

  /// Calculated next due date based on frequency pattern and last completion
  /// Automatically updated when habit completion status changes
  DateTime? _nextDueDate;

  /// Last modification timestamp for change tracking
  /// Updated whenever habit properties or completion status changes
  DateTime _updatedAt;

  // ===== CONSTRUCTOR =====

  /// Creates a new HabitModel instance with required and optional parameters
  ///
  /// Required parameters:
  /// - [id]: Unique habit identifier
  /// - [userId]: Owner user identifier
  /// - [title]: Habit name/description
  ///
  /// Optional parameters have sensible defaults for new habit creation:
  /// - [frequency]: Defaults to 1 (daily habit)
  /// - [description]: Defaults to empty string
  /// - [completedDates]: Defaults to empty list
  /// - Timestamps default to current time if not provided
  HabitModel({
    required String id,
    required String userId,
    required String title,
    String? description,
    int? frequency,
    List<int>? customDays,
    List<DateTime>? completedDates,
    DateTime? nextDueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : _id = id,
        _userId = userId,
        _title = title,
        _description = description ?? '',
        _frequency = frequency ?? 1,
        _customDays = customDays,
        _completedDates = completedDates ?? <DateTime>[],
        _nextDueDate = nextDueDate,
        _createdAt = createdAt ?? DateTime.now(),
        _updatedAt = updatedAt ?? DateTime.now();

  // ===== GETTER METHODS =====

  /// Gets the unique habit identifier
  String get id => _id;

  /// Gets the owner user identifier
  String get userId => _userId;

  /// Gets the habit title
  String get title => _title;

  /// Gets the habit description
  String get description => _description;

  /// Gets the frequency pattern (days interval or 0 for custom)
  int get frequency => _frequency;

  /// Gets the custom days list (null if using simple frequency)
  List<int>? get customDays => _customDays;

  /// Gets an unmodifiable view of completed dates for streak tracking
  /// Returns a copy to prevent external modification of internal state
  List<DateTime> get completedDates => List.unmodifiable(_completedDates);

  /// Gets the next due date (null if not calculated)
  DateTime? get nextDueDate => _nextDueDate;

  /// Gets the creation timestamp
  DateTime get createdAt => _createdAt;

  /// Gets the last update timestamp
  DateTime get updatedAt => _updatedAt;

  /// Gets the most recent completion date for streak calculations
  /// Returns null if habit has never been completed
  /// Used for next due date calculations and streak analytics
  DateTime? get lastCompleted {
    if (_completedDates.isEmpty) return null;
    return _completedDates.last;
  }

  // ===== SETTER METHODS WITH VALIDATION =====

  /// Sets the habit title with validation
  /// Throws exception if title is empty to maintain data integrity
  set title(String value) {
    if (value.isEmpty) throw Exception("Title cannot be empty.");
    _title = value;
  }

  /// Sets the habit description (allows empty values)
  set description(String newDescription) => _description = newDescription;

  /// Sets the frequency with validation
  /// Throws exception if frequency is zero or negative to prevent invalid schedules
  set frequency(int value) {
    if (value <= 0) throw Exception("Frequency must be greater than 0.");
    _frequency = value;
  }

  /// Sets the custom days list for flexible scheduling
  set customDays(List<int>? value) => _customDays = value;

  /// Sets the last update timestamp
  set updatedAt(DateTime value) => _updatedAt = value;

  /// Sets the next due date
  set nextDueDate(DateTime? value) => _nextDueDate = value;

  // ===== FACTORY CONSTRUCTORS =====

  /// Creates a HabitModel from a Firestore document map
  ///
  /// Handles robust deserialization from Firestore data, including:
  /// - Type-safe field extraction with fallback defaults
  /// - Consistent timestamp conversion using FirestoreDateAdapter
  /// - Custom completed dates parsing with error handling
  /// - Null safety for all optional fields
  factory HabitModel.fromMap(Map<String, dynamic> map, {String? id}) {
    /// Internal helper function for parsing completed dates array from Firestore
    /// Handles various date formats and filters out invalid dates
    List<DateTime> parseCompletedDates(dynamic value) {
      if (value == null || value is! List) return <DateTime>[];
      final List<DateTime> result = [];
      for (final item in value) {
        final date = FirestoreDateAdapter.fromFirestore(item);
        if (date != null) result.add(date);
      }
      return result;
    }

    return HabitModel(
      id: id ?? (map['id'] ?? '') as String,
      userId: (map['user_id'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      description: map['description'] as String? ?? '',
      frequency: map['frequency'] as int? ?? 1,
      customDays: (map['custom_days'] as List?)?.map((e) => e as int).toList(),
      completedDates: parseCompletedDates(map['completed_dates']),
      nextDueDate: FirestoreDateAdapter.fromFirestore(map['next_due_date']),
      createdAt: FirestoreDateAdapter.fromFirestore(map['created_at']) ??
          DateTime.now(),
      updatedAt: FirestoreDateAdapter.fromFirestore(map['updated_at']) ??
          DateTime.now(),
    );
  }

  // ===== SERIALIZATION METHODS =====

  /// Serializes this HabitModel to a Map for Firestore storage
  ///
  /// Converts all properties to Firestore-compatible types using the
  /// FirestoreDateAdapter for consistent timestamp handling. Handles
  /// the completed dates list conversion to Firestore Timestamp objects.
  ///
  /// The map uses snake_case field names to match database conventions.
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'user_id': _userId,
      'title': _title,
      'description': _description,
      'frequency': _frequency,
      'custom_days': _customDays,
      'completed_dates': _completedDates
          .map((d) => FirestoreDateAdapter.toTimestamp(d))
          .toList(),
      'next_due_date': _nextDueDate != null
          ? FirestoreDateAdapter.toTimestamp(_nextDueDate!)
          : null,
      'created_at': FirestoreDateAdapter.toTimestamp(_createdAt),
      'updated_at': FirestoreDateAdapter.toTimestamp(_updatedAt),
    };
  }

  // ===== IMMUTABILITY HELPERS =====

  /// Creates a new HabitModel instance with modified properties
  ///
  /// Follows the immutability pattern for state management, creating a new
  /// instance rather than modifying the existing one. Preserves the completed
  /// dates history and immutable identifiers while allowing property updates.
  ///
  /// Automatically updates the modification timestamp unless explicitly provided.
  HabitModel copyWith({
    String? title,
    String? description,
    int? frequency,
    List<int>? customDays,
    DateTime? nextDueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitModel(
      id: _id,
      userId: _userId,
      title: title ?? _title,
      description: description ?? _description,
      frequency: frequency ?? _frequency,
      customDays: customDays ?? _customDays,
      completedDates: List<DateTime>.from(_completedDates),
      nextDueDate: nextDueDate ?? _nextDueDate,
      createdAt: createdAt ?? _createdAt,
      updatedAt: updatedAt ?? _updatedAt,
    );
  }

  // ===== STRING REPRESENTATION AND DEBUGGING =====

  /// Provides a human-readable string representation of the habit
  ///
  /// Includes key habit details and completion information for debugging
  /// and logging purposes. Formats dates consistently for readability.
  @override
  String toString() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return 'HabitModel('
        'id: "$id", '
        'title: "$title", '
        'frequency: $frequency, '
        'completedDates: ${completedDates.map((d) => dateFormat.format(d)).toList()}, '
        'lastCompleted: ${lastCompleted != null ? dateFormat.format(lastCompleted!) : "null"}'
        ')';
  }

  /// Debug utility method to print all completed dates to console
  ///
  /// Provides detailed completion tracking information for troubleshooting
  /// and development. Shows completion dates in chronological order for
  /// easy pattern recognition and streak analysis.
  void debugPrintCompletedDates() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    debugPrint('[$id] Completed dates (${completedDates.length}):');
    for (final date in completedDates) {
      debugPrint('  - ${dateFormat.format(date)}');
    }
  }

  // ===== COMPLETION TRACKING METHODS =====

  /// Toggles habit completion status for a specific date with automatic metadata updates
  ///
  /// This method handles the complete workflow of habit completion tracking:
  /// - Normalizes the target date to midnight for consistent day-level tracking
  /// - Adds/removes completion entries based on the isCompleted flag
  /// - Maintains chronological ordering of completion dates
  /// - Automatically recalculates next due date based on new completion status
  /// - Updates modification timestamp for audit trail
  /// - Provides detailed debug logging for troubleshooting
  ///
  /// Parameters:
  /// - [isCompleted]: Whether to mark the habit as completed (true) or incomplete (false)
  /// - [forDate]: Target date for completion (defaults to current date if null)
  ///
  /// The method uses date normalization to ensure all completion tracking
  /// operates at the day level, ignoring time components for consistency.
  void toggleCompletion({required bool isCompleted, DateTime? forDate}) {
    final now = DateTime.now();
    // ===== NORMALIZE TARGET DATE =====
    // Strip time components to ensure day-level completion tracking
    final date = DateTime(
      forDate?.year ?? now.year,
      forDate?.month ?? now.month,
      forDate?.day ?? now.day,
    );

    // ===== DEBUG LOGGING =====
    debugPrint(
        '[HabitModel] Toggling completion: $isCompleted for ${DateFormat('yyyy-MM-dd').format(date)}');
    debugPrintCompletedDates();

    if (isCompleted) {
      // ===== MARK AS COMPLETED =====
      // Add completion entry if not already present for this date
      if (!_completedDates.any((d) => _isSameDate(d, date))) {
        _completedDates.add(date);
        // ===== MAINTAIN CHRONOLOGICAL ORDER =====
        // Sort completion dates to ensure consistent ordering for analytics
        _completedDates.sort((a, b) => a.compareTo(b));
      }
    } else {
      // ===== MARK AS INCOMPLETE =====
      // Remove all completion entries for this date
      _completedDates.removeWhere((d) => _isSameDate(d, date));
    }

    // ===== POST-COMPLETION DEBUG LOGGING =====
    debugPrint('[HabitModel] After toggle:');
    debugPrintCompletedDates();

    // ===== UPDATE TRACKING METADATA =====
    // Recalculate next due date based on new completion status
    _nextDueDate = calculateNextDueDate();
    // Update modification timestamp for audit trail
    _updatedAt = DateTime.now();
  }

  /// Internal helper method for date comparison ignoring time components
  ///
  /// Compares two DateTime objects at the day level, ignoring hours, minutes,
  /// and seconds. Essential for consistent completion tracking across different
  /// time zones and user interaction patterns.
  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ===== SCHEDULE CALCULATION METHODS =====

  /// Calculates the next due date based on habit frequency and completion history
  ///
  /// Supports complex scheduling logic for different frequency patterns:
  /// - Simple intervals: Next occurrence after N days from last completion
  /// - Weekly patterns: Next occurrence of specified weekdays
  /// - Monthly patterns: Next occurrence of specified month days
  ///
  /// Uses the last completion date as the base, falling back to creation date
  /// if habit has never been completed. Returns null for invalid configurations.
  DateTime? calculateNextDueDate() {
    if (_frequency > 0) {
      // ===== SIMPLE INTERVAL SCHEDULING =====
      // Calculate next due date as N days after last completion (or creation)
      final baseDate =
          _completedDates.isNotEmpty ? _completedDates.last : _createdAt;
      return baseDate.add(Duration(days: _frequency));
    } else if (_frequency == 0 && _customDays != null) {
      // ===== CUSTOM DAYS SCHEDULING =====
      final now = DateTime.now();
      final todayWeekday = now.weekday;

      // ===== WEEKLY PATTERN (days 1-7) =====
      if (_customDays!.every((d) => d <= 7)) {
        // Find next weekday in the custom days list
        final next = _customDays!.where((d) => d > todayWeekday).fold<int?>(
                  null,
                  (prev, curr) => prev == null || curr < prev ? curr : prev,
                ) ??
            _customDays!.first; // Wrap to next week if no days left this week
        final daysUntil = (next - todayWeekday + 7) % 7;
        return now.add(Duration(days: daysUntil));
      } else {
        // ===== MONTHLY PATTERN (days > 7) =====
        final todayDay = now.day;
        // Find next day of month in the custom days list
        final nextDay = _customDays!.where((d) => d > todayDay).fold<int?>(
                  null,
                  (prev, curr) => prev == null || curr < prev ? curr : prev,
                ) ??
            _customDays!.first; // Wrap to next month if no days left this month
        return DateTime(now.year, now.month, nextDay);
      }
    }
    // ===== INVALID CONFIGURATION =====
    return null;
  }
}
