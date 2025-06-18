// ===== CORE FLUTTER/DART IMPORTS =====
// Flutter debugging utilities and internationalization support
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

// ===== APPLICATION DATABASE IMPORTS =====
// Firestore date adapter for consistent timestamp handling across the application
import 'package:spiceease/core/database/firestore_date_adapter.dart';

// ===== MEDICATION DATA MODEL =====
/// Comprehensive data model representing a medication entity with schedule tracking and adherence monitoring
///
/// This model encapsulates all medication-related data including basic medication information,
/// dosage tracking, schedule management, and adherence analytics. It supports multiple frequency
/// patterns and provides detailed tracking of when medications are taken.
///
/// Key features:
/// - Immutable core identifiers (id, userId, createdAt) for data integrity
/// - Flexible medication schedule support (daily, weekly, monthly, custom days)
/// - Adherence tracking with completion date history
/// - Next due date calculation based on schedule patterns
/// - Multiple doses per day support for complex medication regimens
/// - Real-time adherence status checking for specific dates
/// - Firebase Firestore integration with type-safe serialization
/// - Debug utilities for adherence monitoring and troubleshooting
///
/// Supports various medication schedules:
/// - Daily medications (every day)
/// - Weekly medications (specific days of week)
/// - Monthly medications (specific days of month)
/// - Custom frequency patterns with flexible day selection
/// - Multiple daily doses with individual tracking
class MedicationModel {
  // ===== IMMUTABLE CORE IDENTIFIERS =====

  /// Unique identifier for this medication (Firestore document ID)
  /// Immutable once assigned to maintain referential integrity across the system
  final String _id;

  /// User ID that owns this medication (foreign key reference)
  /// Immutable to prevent accidental medication ownership changes
  final String _userId;

  /// Medication creation timestamp (audit trail)
  /// Immutable to maintain accurate creation history for adherence analytics
  final DateTime _createdAt;

  // ===== MUTABLE MEDICATION PROPERTIES =====

  /// Medication name/brand - the primary medication identifier for users
  /// Can be updated for name changes or corrections
  String _name;

  /// Dosage amount as a numeric value
  /// Supports decimal doses (e.g., 2.5mg, 0.25ml) for precise medication tracking
  double _dose;

  /// Unit of measurement for the dose
  /// Common values: "mg", "ml", "tablets", "drops", "puffs"
  String _unit;

  /// Frequency pattern for medication schedule
  /// Supported values: "daily", "weekly", "monthly", "as needed"
  String _frequency;

  /// Custom days for weekly/monthly schedules
  /// - For weekly: days of week (1=Monday, 7=Sunday)
  /// - For monthly: days of month (1-31)
  /// - Null for daily medications or simple weekly/monthly patterns
  List<int>? _customDays;

  /// Number of times this medication should be taken per day
  /// Supports complex regimens like "3 times daily" or "twice daily"
  int _timesPerDay;

  /// Historical record of all dates when medication was taken
  /// Used for adherence tracking, analytics, and streak calculations
  /// Each entry represents one dose taken on that date
  final List<DateTime> _datesTaken;

  /// Calculated next due date based on schedule and last taken date
  /// Automatically updated when medication is marked as taken
  DateTime? _nextDueDate;

  /// Last modification timestamp for change tracking
  /// Updated whenever medication properties or adherence status changes
  DateTime _updatedAt;

  // ===== CONSTRUCTOR =====

  /// Creates a new MedicationModel instance with required and optional parameters
  ///
  /// Required parameters:
  /// - [id]: Unique medication identifier
  /// - [userId]: Owner user identifier
  /// - [name]: Medication name/brand
  /// - [dose]: Dosage amount
  /// - [unit]: Dosage unit
  /// - [frequency]: Schedule frequency pattern
  /// - [timesPerDay]: Daily dose frequency
  /// - [createdAt]: Creation timestamp
  /// - [updatedAt]: Last modification timestamp
  ///
  /// Optional parameters have sensible defaults for new medication creation
  MedicationModel({
    required String id,
    required String userId,
    required String name,
    required double dose,
    required String unit,
    required String frequency,
    List<int>? customDays,
    required int timesPerDay,
    List<DateTime>? completedDates,
    DateTime? nextDueDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : _id = id,
        _userId = userId,
        _name = name,
        _dose = dose,
        _unit = unit,
        _frequency = frequency,
        _customDays = customDays,
        _timesPerDay = timesPerDay,
        _datesTaken = completedDates ?? <DateTime>[],
        _nextDueDate = nextDueDate,
        _createdAt = createdAt,
        _updatedAt = updatedAt;

  // ===== GETTER METHODS =====

  /// Gets the unique medication identifier
  String get id => _id;

  /// Gets the owner user identifier
  String get userId => _userId;

  /// Gets the medication name
  String get name => _name;

  /// Gets the dosage amount
  double get dose => _dose;

  /// Gets the dosage unit
  String get unit => _unit;

  /// Gets the frequency pattern
  String get frequency => _frequency;

  /// Gets the custom days list (null if not applicable)
  List<int>? get customDays => _customDays;

  /// Gets the daily dose frequency
  int get timesPerDay => _timesPerDay;

  /// Gets an unmodifiable view of completed dates for adherence tracking
  /// Returns a copy to prevent external modification of internal state
  List<DateTime> get completedDates => List.unmodifiable(_datesTaken);

  /// Gets the next due date (null if not calculated)
  DateTime? get nextDueDate => _nextDueDate;

  /// Gets the creation timestamp
  DateTime get createdAt => _createdAt;

  /// Gets the last update timestamp
  DateTime get updatedAt => _updatedAt;

  /// Gets the most recent date when medication was taken
  /// Returns null if medication has never been taken
  /// Used for adherence analytics and next due date calculations
  DateTime? get lastCompleted {
    if (_datesTaken.isEmpty) return null;
    return _datesTaken.last;
  }

  // ===== SETTER METHODS =====

  /// Sets the medication name
  set name(String newName) => _name = newName;

  /// Sets the dosage amount
  set dose(double newDose) => _dose = newDose;

  /// Sets the dosage unit
  set unit(String newUnit) => _unit = newUnit;

  /// Sets the frequency pattern
  set frequency(String newFrequency) => _frequency = newFrequency;

  /// Sets the custom days list
  set customDays(List<int>? newCustomDays) => _customDays = newCustomDays;

  /// Sets the daily dose frequency
  set timesPerDay(int newTimesPerDay) => _timesPerDay = newTimesPerDay;

  /// Sets the next due date
  set nextDueDate(DateTime? newNextDueDate) => _nextDueDate = newNextDueDate;

  /// Sets the last update timestamp
  set updatedAt(DateTime newUpdatedAt) => _updatedAt = newUpdatedAt;

  // ===== IMMUTABILITY HELPERS =====

  /// Creates a new MedicationModel instance with modified properties
  ///
  /// Follows the immutability pattern for state management, creating a new
  /// instance rather than modifying the existing one. Preserves the completed
  /// dates history and immutable identifiers while allowing property updates.
  ///
  /// Automatically updates the modification timestamp to track changes.
  MedicationModel copyWith({
    String? name,
    double? dose,
    String? unit,
    String? frequency,
    List<int>? customDays,
    int? timesPerDay,
    List<DateTime>? completedDates,
    DateTime? nextDueDate,
    DateTime? updatedAt,
  }) {
    return MedicationModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      unit: unit ?? this.unit,
      frequency: frequency ?? this.frequency,
      customDays: customDays ?? this.customDays,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      completedDates: completedDates ?? List<DateTime>.from(_datesTaken),
      nextDueDate: nextDueDate ?? this.nextDueDate,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // ===== SERIALIZATION METHODS =====

  /// Serializes this MedicationModel to a Map for Firestore storage
  ///
  /// Converts all properties to Firestore-compatible types using the
  /// FirestoreDateAdapter for consistent timestamp handling. Handles
  /// the completed dates list conversion to Firestore Timestamp objects.
  ///
  /// The map uses snake_case field names to match database conventions.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'dose': dose,
      'unit': unit,
      'frequency': frequency,
      'custom_days': customDays,
      'times_per_day': timesPerDay,
      'completed_dates':
          _datesTaken.map((d) => FirestoreDateAdapter.toTimestamp(d)).toList(),
      'next_due_date': nextDueDate != null
          ? FirestoreDateAdapter.toTimestamp(nextDueDate!)
          : null,
      'created_at': FirestoreDateAdapter.toTimestamp(createdAt),
      'updated_at': FirestoreDateAdapter.toTimestamp(updatedAt),
    };
  }

  // ===== FACTORY CONSTRUCTORS =====

  /// Creates a MedicationModel from a Firestore document map
  ///
  /// Handles robust deserialization from Firestore data, including:
  /// - Type-safe numeric conversion for dose and timesPerDay fields
  /// - Custom completed dates parsing with error handling
  /// - Consistent timestamp conversion using FirestoreDateAdapter
  /// - Default values for missing optional fields
  /// - Null safety for all optional properties
  factory MedicationModel.fromMap(Map<String, dynamic> map) {
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

    return MedicationModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      // ===== ROBUST NUMERIC CONVERSION =====
      // Handle dose as double, int, or string to support various data sources
      dose: (map['dose'] is double)
          ? map['dose']
          : (map['dose'] is int)
              ? (map['dose'] as int).toDouble()
              : double.tryParse(map['dose'].toString()) ?? 0.0,
      unit: map['unit'] ?? '',
      frequency: map['frequency'] ?? 'daily',
      customDays:
          (map['custom_days'] as List<dynamic>?)?.map((e) => e as int).toList(),
      // ===== ROBUST INTEGER CONVERSION =====
      // Handle timesPerDay as int or string to support various data sources
      timesPerDay: (map['times_per_day'] is int)
          ? map['times_per_day']
          : int.tryParse(map['times_per_day'].toString()) ?? 1,
      completedDates: parseCompletedDates(map['completed_dates']),
      nextDueDate: map['next_due_date'] != null
          ? FirestoreDateAdapter.fromFirestore(map['next_due_date'])
          : null,
      createdAt: FirestoreDateAdapter.fromFirestore(map['created_at']) ??
          DateTime.now(),
      updatedAt: FirestoreDateAdapter.fromFirestore(map['updated_at']) ??
          DateTime.now(),
    );
  }

  // ===== SCHEDULE CALCULATION METHODS =====

  /// Calculates the next due date based on medication frequency and last taken date
  ///
  /// Supports complex scheduling logic for different frequency patterns:
  /// - Daily: Simple 24-hour interval from last taken date
  /// - Weekly: Next occurrence of specified weekdays
  /// - Monthly: Next occurrence of specified month days
  ///
  /// Uses the last completed date as the base, falling back to updated date
  /// if medication has never been taken. Returns null for unsupported frequencies.
  DateTime? calculateNextDueDate() {
    final baseDate = lastCompleted ?? updatedAt;
    if (baseDate == null) return null;

    switch (frequency.toLowerCase()) {
      case 'daily':
        // ===== DAILY MEDICATION SCHEDULE =====
        // Simple 24-hour interval from last taken date
        return baseDate.add(const Duration(days: 1));

      case 'weekly':
        // ===== WEEKLY MEDICATION SCHEDULE =====
        if (customDays == null || customDays!.isEmpty) {
          // Default weekly: same day next week
          return baseDate.add(const Duration(days: 7));
        }
        // Custom weekly: next specified weekday
        final today = baseDate.weekday;
        final nextDay = customDays!.firstWhere(
          (day) => day > today,
          orElse: () => customDays!.first,
        );
        final daysUntil = (nextDay - today + 7) % 7;
        return baseDate.add(Duration(days: daysUntil));

      case 'monthly':
        // ===== MONTHLY MEDICATION SCHEDULE =====
        if (customDays == null || customDays!.isEmpty) {
          // Default monthly: same day next month
          return DateTime(baseDate.year, baseDate.month + 1, baseDate.day);
        }
        // Custom monthly: next specified day of month
        final currentDay = baseDate.day;
        final nextDay = customDays!.firstWhere(
          (day) => day > currentDay,
          orElse: () => customDays!.first,
        );
        return nextDay > currentDay
            ? DateTime(baseDate.year, baseDate.month, nextDay)
            : DateTime(baseDate.year, baseDate.month + 1, nextDay);

      default:
        // ===== UNSUPPORTED FREQUENCY =====
        return null;
    }
  }

  // ===== ADHERENCE TRACKING METHODS =====

  /// Gets the number of doses taken on a specific date
  ///
  /// Counts all completion entries that match the specified date (ignoring time).
  /// Useful for tracking multiple daily doses and adherence compliance.
  ///
  /// Returns 0 if no doses were taken on the specified date.
  int getTakenCountForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return _datesTaken
        .where((d) =>
            d.year == dateKey.year &&
            d.month == dateKey.month &&
            d.day == dateKey.day)
        .length;
  }

  /// Updates the taken status for a specific date
  ///
  /// Handles both marking as taken and unmarking medications:
  /// - If taken=true: adds a completion entry for the date (if not already present)
  /// - If taken=false: removes all completion entries for the date
  ///
  /// Automatically updates the modification timestamp and recalculates next due date.
  /// This method modifies the internal state for real-time adherence tracking.
  void updateTakenStatus(DateTime date, bool taken) {
    final dateKey = DateTime(date.year, date.month, date.day);
    if (taken) {
      // ===== MARK AS TAKEN =====
      // Add completion entry if not already present for this date
      if (!_datesTaken.any((d) =>
          d.year == dateKey.year &&
          d.month == dateKey.month &&
          d.day == dateKey.day)) {
        _datesTaken.add(dateKey);
      }
    } else {
      // ===== MARK AS NOT TAKEN =====
      // Remove all completion entries for this date
      _datesTaken.removeWhere((d) =>
          d.year == dateKey.year &&
          d.month == dateKey.month &&
          d.day == dateKey.day);
    }
    // ===== UPDATE TRACKING METADATA =====
    _updatedAt = DateTime.now();
    _nextDueDate = calculateNextDueDate();
  }

  /// Checks if medication was taken on a specific date
  ///
  /// Returns true if at least one dose was taken on the specified date,
  /// false otherwise. Useful for adherence status checking and UI state.
  bool isTakenOnDate(DateTime date) {
    return getTakenCountForDate(date) > 0;
  }

  // ===== STRING REPRESENTATION AND DEBUGGING =====

  /// Provides a human-readable string representation of the medication
  ///
  /// Includes key medication details and adherence information for debugging
  /// and logging purposes. Formats dates consistently for readability.
  @override
  String toString() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final completedDatesStr =
        _datesTaken.map((d) => dateFormat.format(d)).join(', ');

    return 'MedicationModel('
        'id: "$id", '
        'name: "$name", '
        'dose: $dose $unit, '
        'frequency: $frequency, '
        'timesPerDay: $timesPerDay, '
        'completedDates: [$completedDatesStr], '
        'nextDueDate: ${nextDueDate != null ? dateFormat.format(nextDueDate!) : "null"}'
        ')';
  }

  /// Debug utility method to print all completed dates to console
  ///
  /// Provides detailed adherence tracking information for troubleshooting
  /// and development. Shows completion dates in chronological order for
  /// easy pattern recognition and adherence analysis.
  void debugPrintCompletedDates() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    debugPrint('[$id] Completed dates:');
    if (_datesTaken.isEmpty) {
      debugPrint('  - None');
      return;
    }

    // ===== SORT AND DISPLAY COMPLETION HISTORY =====
    final sortedDates = _datesTaken.toList()..sort();
    for (final date in sortedDates) {
      debugPrint('  - ${dateFormat.format(date)}');
    }
  }
}
