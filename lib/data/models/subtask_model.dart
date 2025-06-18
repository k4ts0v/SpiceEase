// ===== CORE DATABASE IMPORTS =====
// Firestore date adapter for consistent timestamp handling across the application
import 'package:spiceease/core/database/firestore_date_adapter.dart';

// ===== SUBTASK DATA MODEL =====
/// Immutable data model representing a subtask entity within hierarchical task management
///
/// This model encapsulates subtask-specific data for breaking down complex tasks into
/// manageable components. It maintains a parent-child relationship with TaskModel and
/// supports individual completion tracking, ordering, and time management.
///
/// Key features:
/// - Immutable core identifiers (id, userId, taskId, createdAt, updatedAt) for referential integrity
/// - Hierarchical relationship with parent tasks through taskId foreign key
/// - Individual completion tracking independent of parent task status
/// - Ordering support for sequential subtask organization
/// - Time tracking capabilities for detailed productivity analysis
/// - Status workflow management for subtask progression
/// - Raw time value storage for flexible time input formats
/// - Firebase Firestore integration with consistent date handling
///
/// Supports productivity workflows:
/// - Task decomposition into manageable components
/// - Sequential execution with ordering
/// - Individual time tracking per subtask
/// - Completion analytics and progress tracking
class SubtaskModel {
  // ===== IMMUTABLE CORE IDENTIFIERS =====

  /// Unique identifier for this subtask (Firestore document ID)
  /// Immutable once assigned to maintain referential integrity
  final String _id;

  /// User ID that owns this subtask (foreign key reference)
  /// Immutable to prevent accidental ownership changes
  final String _userId;

  /// Parent task ID this subtask belongs to (foreign key reference)
  /// Immutable to maintain hierarchical relationship integrity
  final String _taskId;

  // ===== MUTABLE SUBTASK PROPERTIES =====

  /// Subtask title/name - the primary subtask identifier for users
  /// Can be modified through copyWith method for task updates
  String _title;

  /// Display order within the parent task's subtask list
  /// Used for maintaining user-defined subtask sequence
  int _order;

  /// Completion status flag for this individual subtask
  /// Independent of parent task completion state
  bool _completed;

  /// Current subtask status in the workflow
  /// Common values: 'todo', 'in_progress', 'done', 'cancelled'
  String _status;

  /// Raw time value as entered by user (free-form string)
  /// Supports various formats before parsing: "30min", "1.5h", "2 hours"
  String? _rawTimeValue;

  // ===== TIME TRACKING PROPERTIES =====

  /// Time when subtask work was started (for detailed time tracking)
  /// Used for actual time measurement and productivity analysis
  final DateTime? _startTime;

  /// Time when subtask work was completed (for detailed time tracking)
  /// Combined with startTime to calculate actual work duration
  final DateTime? _endTime;

  /// Timestamp when subtask was marked as completed
  /// Used for completion analytics and progress tracking
  final DateTime? _completedAt;

  // ===== AUDIT TRAIL TIMESTAMPS =====

  /// Subtask creation timestamp (immutable audit trail)
  /// Automatically set on creation, never modified
  final DateTime _createdAt;

  /// Last modification timestamp for change tracking
  /// Updated through copyWith method when properties change
  final DateTime _updatedAt;

  // ===== CONSTRUCTOR =====

  /// Creates a new SubtaskModel instance with required and optional parameters
  ///
  /// Required parameters:
  /// - [id]: Unique subtask identifier
  /// - [taskId]: Parent task identifier (foreign key)
  /// - [userId]: Owner user identifier
  /// - [title]: Subtask name/description
  ///
  /// Optional parameters have sensible defaults for new subtask creation
  SubtaskModel({
    required String id,
    required String taskId,
    required String userId,
    required String title,
    int order = 0,
    bool completed = false,
    String status = 'todo',
    String? rawTimeValue,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : _id = id,
        _taskId = taskId,
        _userId = userId,
        _title = title,
        _order = order,
        _completed = completed,
        _status = status,
        _rawTimeValue = rawTimeValue,
        _startTime = startTime,
        _endTime = endTime,
        _completedAt = completedAt,
        _createdAt = createdAt ?? DateTime.now(),
        _updatedAt = updatedAt ?? DateTime.now();

  // ===== GETTER METHODS =====

  /// Gets the unique subtask identifier
  String get id => _id;

  /// Gets the owner user identifier
  String get userId => _userId;

  /// Gets the parent task identifier
  String get taskId => _taskId;

  /// Gets the subtask title
  String get title => _title;

  /// Gets the display order within parent task
  int get order => _order;

  /// Gets the completion status
  bool get completed => _completed;

  /// Gets the current workflow status
  String get status => _status;

  /// Gets the raw time value string (null if not set)
  String? get rawTimeValue => _rawTimeValue;

  /// Gets the work start time (null if not started)
  DateTime? get startTime => _startTime;

  /// Gets the work end time (null if not finished)
  DateTime? get endTime => _endTime;

  /// Gets the completion timestamp (null if not completed)
  DateTime? get completedAt => _completedAt;

  /// Gets the creation timestamp
  DateTime get createdAt => _createdAt;

  /// Gets the last update timestamp
  DateTime get updatedAt => _updatedAt;

  // ===== IMMUTABILITY HELPERS =====

  /// Creates a new SubtaskModel instance with modified properties
  ///
  /// Follows the immutability pattern for state management, creating a new
  /// instance rather than modifying the existing one. Supports explicit
  /// null-setting through clear* flags for optional time fields.
  ///
  /// Special clear flags:
  /// - [clearStartTime]: Explicitly set startTime to null
  /// - [clearEndTime]: Explicitly set endTime to null
  ///
  /// This pattern allows distinguishing between "keep current value"
  /// and "explicitly set to null" for time tracking fields.
  SubtaskModel copyWith({
    String? id,
    String? taskId,
    String? userId,
    String? title,
    int? order,
    bool? completed,
    String? status,
    String? rawTimeValue,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    // ===== EXPLICIT NULL-SETTING FLAGS =====
    bool clearStartTime = false,
    bool clearEndTime = false,
  }) {
    return SubtaskModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      order: order ?? this.order,
      completed: completed ?? this.completed,
      status: status ?? this.status,
      rawTimeValue: rawTimeValue ?? this.rawTimeValue,
      startTime: clearStartTime ? null : (startTime ?? this.startTime),
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // ===== SERIALIZATION METHODS =====

  /// Serializes this SubtaskModel to a Map for Firestore storage
  ///
  /// Converts all properties to Firestore-compatible types using the
  /// FirestoreDateAdapter for consistent timestamp handling. The map
  /// uses snake_case field names to match database conventions.
  ///
  /// Handles null values appropriately and ensures all timestamps
  /// are properly converted to Firestore Timestamp objects.
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'task_id': _taskId,
      'user_id': _userId,
      'title': _title,
      'order': _order,
      'completed': _completed,
      'status': _status,
      'raw_time_value': _rawTimeValue,
      'start_time': _startTime != null
          ? FirestoreDateAdapter.toTimestamp(_startTime)
          : null,
      'end_time':
          _endTime != null ? FirestoreDateAdapter.toTimestamp(_endTime) : null,
      'completed_at': _completedAt != null
          ? FirestoreDateAdapter.toTimestamp(_completedAt)
          : null,
      'created_at': FirestoreDateAdapter.toTimestamp(_createdAt),
      'updated_at': FirestoreDateAdapter.toTimestamp(_updatedAt),
    };
  }

  // ===== FACTORY CONSTRUCTORS =====

  /// Creates a SubtaskModel from a Firestore document map
  ///
  /// Handles robust deserialization from Firestore data, including:
  /// - Type-safe field extraction with fallback defaults
  /// - Consistent timestamp conversion using FirestoreDateAdapter
  /// - Null safety for optional fields
  /// - Default values for missing required fields
  ///
  /// Uses FirestoreDateAdapter to handle various Firestore timestamp
  /// formats consistently across the application.
  factory SubtaskModel.fromMap(Map<String, dynamic> map) {
    return SubtaskModel(
      id: map['id'] ?? '',
      taskId: map['task_id'] ?? '',
      userId: map['user_id'] ?? '',
      title: map['title'] ?? '',
      order: map['order'] ?? 0,
      completed: map['completed'] ?? false,
      status: map['status'] ?? 'todo',
      rawTimeValue: map['raw_time_value'],
      startTime: FirestoreDateAdapter.fromFirestore(map['start_time']),
      endTime: FirestoreDateAdapter.fromFirestore(map['end_time']),
      completedAt: FirestoreDateAdapter.fromFirestore(map['completed_at']),
      createdAt: FirestoreDateAdapter.fromFirestore(map['created_at']) ??
          DateTime.now(),
      updatedAt: FirestoreDateAdapter.fromFirestore(map['updated_at']) ??
          DateTime.now(),
    );
  }
}
