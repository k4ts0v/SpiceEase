// ===== CORE FIREBASE IMPORTS =====
// Cloud Firestore integration for timestamp handling and data persistence
import 'package:cloud_firestore/cloud_firestore.dart';

// ===== TASK DATA MODEL =====
/// Comprehensive data model representing a task entity with productivity tracking features
///
/// This model encapsulates all task-related data including basic task information,
/// time tracking capabilities, priority management, and completion status. It supports
/// both simple tasks and complex productivity workflows with time estimation and tracking.
///
/// Key features:
/// - Immutable core identifiers (id, userId, createdAt) for data integrity
/// - Mutable properties with validation through setters
/// - Time tracking support with start/end times and estimation
/// - Priority management and status workflow
/// - Subtask relationship support (hierarchical task structure)
/// - Due date management with optional due date flags
/// - Completion tracking with timestamps
/// - Firebase Firestore integration with type-safe serialization
///
/// Supports multiple productivity methodologies:
/// - Time blocking (start/end times)
/// - Time estimation (estimatedTime field)
/// - Priority-based task management
/// - Completion tracking and analytics
class TaskModel {
  // ===== IMMUTABLE CORE IDENTIFIERS =====

  /// Unique identifier for this task (Firestore document ID)
  /// Immutable once assigned to maintain referential integrity across the system
  final String _id;

  /// User ID that owns this task (foreign key reference)
  /// Immutable to prevent accidental task ownership changes
  final String _userId;

  /// Task creation timestamp (audit trail)
  /// Immutable to maintain accurate creation history
  final DateTime _createdAt;

  // ===== MUTABLE TASK PROPERTIES =====

  /// Task title/name - the primary task identifier for users
  /// Validated through setter to ensure non-empty values
  String _title;

  /// Detailed task description or notes
  /// Optional field for additional task context
  String _description;

  /// Current task status in the workflow
  /// Common values: 'pending', 'In Progress', 'Done', 'cancelled'
  String _status;

  /// Optional due date for deadline tracking
  /// Can be null for tasks without deadlines
  DateTime? _dueDate;

  /// Completion timestamp for analytics and tracking
  /// Set when task is marked as completed
  DateTime? _completedAt;

  /// Estimated time to complete the task (free-form string)
  /// Supports various formats: "2 hours", "30 min", "1.5 hrs"
  String? _estimatedTime;

  /// Task priority level for sorting and urgency indication
  /// Typically 1-5 scale where higher numbers indicate higher priority
  int _priority;

  /// Last modification timestamp for change tracking
  /// Updated whenever task properties are modified
  DateTime _updatedAt;

  // ===== TIME TRACKING PROPERTIES =====

  /// Time when task work was started (for time blocking)
  /// Used for actual time tracking and productivity analysis
  DateTime? _startTime;

  /// Time when task work was completed (for time blocking)
  /// Combined with startTime to calculate actual work duration
  DateTime? _endTime;

  // ===== METADATA FLAGS =====

  /// Flag indicating if this task has a due date set
  /// Automatically maintained based on _dueDate presence
  bool _hasDueDate;

  /// Flag indicating if this task has associated subtasks
  /// Used for UI rendering and hierarchical task management
  bool _hasSubtasks;

  /// Flag indicating if this is a subtask of another task
  /// Used for hierarchical task organization and filtering
  final bool _isSubtask;

  // ===== CONSTRUCTOR =====

  /// Creates a new TaskModel instance with required and optional parameters
  ///
  /// Required parameters:
  /// - [id]: Unique task identifier
  /// - [userId]: Owner user identifier
  /// - [title]: Task name/title
  /// - [createdAt]: Creation timestamp
  /// - [updatedAt]: Last modification timestamp
  ///
  /// Optional parameters have sensible defaults for new task creation
  TaskModel({
    required String id,
    required String userId,
    required String title,
    String description = '',
    String status = 'pending',
    DateTime? dueDate,
    DateTime? completedAt,
    String? estimatedTime,
    int priority = 1,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool? hasDueDate,
    bool hasSubtasks = false,
    bool isSubtask = false,
    DateTime? startTime,
    DateTime? endTime,
  })  : _id = id,
        _userId = userId,
        _title = title,
        _description = description,
        _status = status,
        _dueDate = dueDate,
        _completedAt = completedAt,
        _estimatedTime = estimatedTime,
        _priority = priority,
        _createdAt = createdAt,
        _updatedAt = updatedAt,
        _hasDueDate = dueDate != null,
        _hasSubtasks = hasSubtasks,
        _isSubtask = isSubtask,
        _startTime = startTime,
        _endTime = endTime;

  // ===== GETTER METHODS =====

  /// Gets the unique task identifier
  String get id => _id;

  /// Gets the owner user identifier
  String get userId => _userId;

  /// Gets the task title
  String get title => _title;

  /// Gets the task description
  String get description => _description;

  /// Gets the current task status
  String get status => _status;

  /// Gets the due date (null if no due date set)
  DateTime? get dueDate => _dueDate;

  /// Gets the completion timestamp (null if not completed)
  DateTime? get completedAt => _completedAt;

  /// Gets the estimated time string (null if not estimated)
  String? get estimatedTime => _estimatedTime;

  /// Gets the task priority level
  int get priority => _priority;

  /// Gets the creation timestamp
  DateTime get createdAt => _createdAt;

  /// Gets the last update timestamp
  DateTime get updatedAt => _updatedAt;

  /// Gets whether task has a due date
  bool get hasDueDate => _hasDueDate;

  /// Gets whether task has subtasks
  bool get hasSubtasks => _hasSubtasks;

  /// Gets whether this is a subtask
  bool get isSubtask => _isSubtask;

  /// Gets the work start time (null if not started)
  DateTime? get startTime => _startTime;

  /// Gets the work end time (null if not finished)
  DateTime? get endTime => _endTime;

  // ===== SETTER METHODS WITH VALIDATION =====

  /// Sets the task title with validation
  /// Throws exception if title is empty to maintain data integrity
  set title(String newTitle) {
    if (newTitle.isNotEmpty) {
      _title = newTitle;
    } else {
      throw Exception("Title cannot be empty.");
    }
  }

  /// Sets the task description (allows empty values)
  set description(String newDescription) {
    _description = newDescription;
  }

  /// Sets the task status
  set status(String newStatus) {
    _status = newStatus;
  }

  /// Sets the due date and automatically updates hasDueDate flag
  set dueDate(DateTime? newDueDate) {
    _dueDate = newDueDate;
    _hasDueDate = newDueDate != null;
  }

  /// Sets the completion timestamp
  set completedAt(DateTime? newCompletedAt) {
    _completedAt = newCompletedAt;
  }

  /// Sets the estimated time string
  set estimatedTime(String? newEstimatedTime) {
    _estimatedTime = newEstimatedTime;
  }

  /// Sets the task priority level
  set priority(int newPriority) {
    _priority = newPriority;
  }

  /// Sets the last update timestamp
  set updatedAt(DateTime newUpdatedAt) {
    _updatedAt = newUpdatedAt;
  }

  /// Sets whether task has subtasks
  set hasSubtasks(bool value) {
    _hasSubtasks = value;
  }

  /// Sets the due date flag with validation
  /// Throws error if trying to set true without an actual due date
  set hasDueDate(bool value) {
    if (value && _dueDate == null) {
      throw ArgumentError('Cannot set hasDueDate to true without a dueDate');
    }
    _hasDueDate = value;
    if (!value) {
      _dueDate = null;
    }
  }

  // ===== FACTORY CONSTRUCTORS =====

  /// Creates a TaskModel from a Firestore document map
  ///
  /// Handles various date formats from Firestore including:
  /// - Timestamp objects (native Firestore format)
  /// - DateTime objects (Dart native format)
  /// - String timestamps (ISO format)
  /// - Null values for optional fields
  ///
  /// Provides robust type conversion for numeric fields that may be
  /// stored as either int or double in Firestore.
  factory TaskModel.fromMap(Map<String, dynamic> map, {String? id}) {
    /// Internal helper function for parsing various date formats from Firestore
    /// Handles the common issue of inconsistent date storage formats
    DateTime? _parseDynamicDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is Timestamp) return v.toDate();
      if (v is String) {
        return DateTime.tryParse(v);
      }
      return null;
    }

    return TaskModel(
      id: id ?? (map['id'] as String),
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      dueDate: _parseDynamicDate(map['due_date']),
      completedAt: _parseDynamicDate(map['completed_at']),
      estimatedTime: map['estimated_time'] != null
          ? map['estimated_time'].toString()
          : null,
      priority: map['priority'] is double
          ? (map['priority'] as double).toInt()
          : (map['priority'] as int? ?? 1),
      createdAt: _parseDynamicDate(map['created_at'])!,
      updatedAt: _parseDynamicDate(map['updated_at'])!,
      hasSubtasks: map['has_subtasks'] as bool? ?? false,
      isSubtask: map['is_subtask'] as bool? ?? false,
      startTime: _parseDynamicDate(map['start_time']),
      endTime: _parseDynamicDate(map['end_time']),
    );
  }

  // ===== SERIALIZATION METHODS =====

  /// Serializes this TaskModel to a Map for Firestore storage
  ///
  /// Converts all properties to Firestore-compatible types:
  /// - DateTime objects remain as DateTime (Firestore handles conversion)
  /// - All required fields are included
  /// - Null values are preserved for optional fields
  ///
  /// The map uses snake_case field names to match database conventions.
  Map<String, dynamic> toMap() {
    return {
      'user_id': _userId,
      'title': _title,
      'description': _description,
      'status': _status,
      'due_date': _dueDate,
      'completed_at': _completedAt,
      'estimated_time': _estimatedTime,
      'priority': _priority,
      'created_at': _createdAt,
      'updated_at': _updatedAt,
      'has_due_date': _hasDueDate,
      'has_subtasks': _hasSubtasks,
      'is_subtask': _isSubtask,
      'start_time': _startTime,
      'end_time': _endTime,
    };
  }

  // ===== IMMUTABILITY HELPERS =====

  /// Creates a new TaskModel instance with modified properties
  ///
  /// Follows the immutability pattern for state management, creating a new
  /// instance rather than modifying the existing one. Supports explicit
  /// null-setting through clear* flags for optional fields.
  ///
  /// Special clear flags:
  /// - [clearCompletedAt]: Explicitly set completedAt to null
  /// - [clearStartTime]: Explicitly set startTime to null
  /// - [clearEndTime]: Explicitly set endTime to null
  /// - [clearEstimatedTime]: Explicitly set estimatedTime to null
  /// - [clearDueDate]: Explicitly set dueDate to null
  ///
  /// This pattern allows distinguishing between "keep current value"
  /// and "explicitly set to null".
  TaskModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? status,
    DateTime? dueDate,
    DateTime? completedAt,
    String? estimatedTime,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasDueDate,
    bool? hasSubtasks,
    String? parentTaskId,
    bool? isSubtask,
    int? subtaskOrder,
    DateTime? startTime,
    DateTime? endTime,
    bool? hasReminder,
    DateTime? reminderDateTime,
    List<int>? reminderDaysOfWeek,
    bool? isRecurringReminder,
    // ===== EXPLICIT NULL-SETTING FLAGS =====
    bool clearCompletedAt = false,
    bool clearStartTime = false,
    bool clearEndTime = false,
    bool clearEstimatedTime = false,
    bool clearDueDate = false,
    bool clearReminderDateTime = false,
    bool clearReminderDaysOfWeek = false,
    bool clearParentTaskId = false,
  }) {
    return TaskModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        description: description ?? this.description,
        status: status ?? this.status,
        dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
        completedAt:
            clearCompletedAt ? null : (completedAt ?? this.completedAt),
        estimatedTime:
            clearEstimatedTime ? null : (estimatedTime ?? this.estimatedTime),
        priority: priority ?? this.priority,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        hasDueDate: hasDueDate ?? this.hasDueDate,
        hasSubtasks: hasSubtasks ?? this.hasSubtasks,
        isSubtask: isSubtask ?? this.isSubtask,
        startTime: clearStartTime ? null : (startTime ?? this.startTime),
        endTime: clearEndTime ? null : (endTime ?? this.endTime));
  }

  // ===== BUSINESS LOGIC METHODS =====

  /// Toggles task completion status with proper timestamp management
  ///
  /// This method handles the complete workflow of task completion:
  /// - If task is not completed: marks as 'Done' and sets completion timestamp
  /// - If task is completed: marks as 'In Progress' and clears completion timestamp
  /// - Always updates the modification timestamp for audit trail
  ///
  /// Parameters:
  /// - [selectedDate]: The date to use for completion timestamp (user-selected context)
  ///
  /// Returns a new TaskModel instance with updated completion state.
  /// This maintains immutability while providing convenient completion logic.
  TaskModel toggleCompletion(DateTime selectedDate) {
    final bool isCurrentlyCompleted = status == 'Done' || completedAt != null;

    if (!isCurrentlyCompleted) {
      // ===== MARK AS COMPLETED =====
      // Set completion status and timestamp
      return copyWith(
        status: 'Done',
        completedAt: selectedDate,
        updatedAt: DateTime.now(),
      );
    } else {
      // ===== MARK AS INCOMPLETE =====
      // Reset to in-progress status and clear completion timestamp
      return copyWith(
        status: 'In Progress',
        clearCompletedAt: true,
        updatedAt: DateTime.now(),
      );
    }
  }
}
