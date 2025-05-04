class SpeedrunModel {
  // Private fields
  final String _id; // Immutable field (Document ID)
  final String _userId; // Immutable field (Foreign Key)
  final String _taskId; // Immutable field (Foreign Key)
  DateTime _startTime; // Mutable field with setter
  DateTime? _endTime; // Mutable field with setter
  int _durationSec; // Mutable field with setter
  bool _abandoned; // Mutable field with setter

  // Getters for accessing private fields
  String get id => _id;
  String get userId => _userId;
  String get taskId => _taskId;
  DateTime get startTime => _startTime;
  DateTime? get endTime => _endTime;
  int get durationSec => _durationSec;
  bool get abandoned => _abandoned;

  // Setters for mutable fields

  /// Sets the startTime to the provided startTime.
  set startTime(DateTime newStartTime) {
    _startTime = newStartTime;
  }

  /// Sets the endTime to the provided endTime.
  set endTime(DateTime? newEndTime) {
    _endTime = newEndTime;
  }

  /// Sets the durationSec to the provided durationSec.
  set durationSec(int newDurationSec) {
    if (newDurationSec >= 0) {
      _durationSec = newDurationSec;
    } else {
      throw Exception("Duration cannot be negative.");
    }
  }

  /// Sets the abandoned status to the provided abandoned status.
  set abandoned(bool newAbandoned) {
    _abandoned = newAbandoned;
  }

  // Constructor
  SpeedrunModel({
    required String id,
    required String userId,
    required String taskId,
    required DateTime startTime,
    DateTime? endTime,
    int durationSec = 0,
    bool abandoned = false,
  })  : _id = id,
        _userId = userId,
        _taskId = taskId,
        _startTime = startTime,
        _endTime = endTime,
        _durationSec = durationSec,
        _abandoned = abandoned;

  /// Factory constructor that constructs SpeedrunModel from generic key-value map structure
  ///
  /// Handles:
  /// - Database-agnostic field mapping
  /// - Type-safe conversions
  /// - Default values for speedrun fields
  ///
  /// [map]: Database record structure
  factory SpeedrunModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return SpeedrunModel(
      id: id ?? map['id'],
      userId: map['user_id'], // Field mapping
      taskId: map['task_id'], // Field mapping
      startTime: map['start_time'].toDateTime(), // Conversion
      endTime: map['end_time']?.toDateTime(), // Nullable conversion
      durationSec: map['duration_sec'] ?? 0, // Null check with default
      abandoned: map['abandoned'] ?? false, // Null check with default
    );
  }

  /// Serializes speedrun data to database-agnostic map format
  ///
  /// Returns:
  /// - String keys using application-level naming conventions
  /// - Native Dart types for database compatibility
  Map<String, dynamic> toMap() {
    return {
      'user_id': _userId,
      'task_id': _taskId,
      'start_time': _startTime,
      'end_time': _endTime,
      'duration_sec': _durationSec,
      'abandoned': _abandoned,
    };
  }
}