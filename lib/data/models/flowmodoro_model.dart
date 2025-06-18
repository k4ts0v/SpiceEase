// ===== CORE FLUTTER/DART IMPORTS =====
// (No external imports needed for this model)

// ===== FLOWMODORO DATA MODEL =====
/// Immutable data model representing a Flowmodoro session entity for time management and productivity tracking
///
/// This model encapsulates all Flowmodoro session-related data including timing configuration,
/// session state management, completion tracking, and task association. It supports the
/// Flowmodoro technique which combines Pomodoro time-boxing with flow state principles.
///
/// Key features:
/// - Immutable core identifiers (id, taskId, createdAt) for data integrity
/// - Flexible timing configuration for focus and break periods
/// - Session state tracking (running, completed) for real-time management
/// - Pomodoro count tracking for technique adherence
/// - Task association for productivity analytics
/// - Simple serialization for local storage and data persistence
/// - Lightweight design optimized for timer operations
///
/// Supports Flowmodoro methodology:
/// - Customizable focus period lengths (default 25 minutes)
/// - Flexible break period configuration (default 5 minutes)
/// - Pomodoro cycle counting for session management
/// - Session completion tracking for analytics
/// - Task-specific session association for productivity insights
class FlowmodoroModel {
  // ===== IMMUTABLE CORE IDENTIFIERS =====

  /// Unique identifier for this Flowmodoro session
  /// Immutable once assigned to maintain referential integrity across the system
  final String id;

  /// Associated task ID for this Flowmodoro session (foreign key reference)
  /// Links the session to a specific task for productivity tracking and analytics
  final String taskId;

  /// Session creation timestamp (audit trail)
  /// Immutable to maintain accurate session history for time tracking analytics
  final DateTime createdAt;

  // ===== TIMING CONFIGURATION PROPERTIES =====

  /// Duration of focus period in minutes
  /// Configurable to support different productivity preferences (default: 25 minutes)
  /// Standard Pomodoro uses 25 minutes, but Flowmodoro allows customization
  final int focusMinutes;

  /// Duration of break period in minutes
  /// Configurable break length between focus sessions (default: 5 minutes)
  /// Supports short breaks (5 min) and long breaks (15-30 min) patterns
  final int breakMinutes;

  /// Number of Pomodoro cycles planned for this session
  /// Tracks intended session length in Pomodoro units (default: 4 cycles)
  /// Used for session planning and completion percentage calculations
  final int pomoCount;

  // ===== SESSION STATE PROPERTIES =====

  /// Flag indicating if the Flowmodoro session is currently active/running
  /// Controls timer state and UI display for active session management
  final bool isRunning;

  /// Flag indicating if the Flowmodoro session has been completed
  /// Tracks session completion for analytics and productivity metrics
  /// Distinguishes between abandoned sessions and successfully completed ones
  final bool isCompleted;

  // ===== CONSTRUCTOR =====

  /// Creates a new FlowmodoroModel instance with required and optional parameters
  ///
  /// Required parameters:
  /// - [id]: Unique session identifier
  /// - [taskId]: Associated task identifier for productivity tracking
  ///
  /// Optional parameters have sensible defaults for standard Flowmodoro sessions:
  /// - [focusMinutes]: Focus period length (default: 25 minutes)
  /// - [breakMinutes]: Break period length (default: 5 minutes)
  /// - [pomoCount]: Planned Pomodoro cycles (default: 4 cycles)
  /// - [isRunning]: Session active state (default: false)
  /// - [isCompleted]: Session completion state (default: false)
  /// - [createdAt]: Creation timestamp (defaults to current time)
  FlowmodoroModel({
    required this.id,
    required this.taskId,
    this.focusMinutes = 25,
    this.breakMinutes = 5,
    this.pomoCount = 4,
    this.isRunning = false,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  // ===== IMMUTABILITY HELPERS =====

  /// Creates a new FlowmodoroModel instance with modified properties
  ///
  /// Follows the immutability pattern for state management, creating a new
  /// instance rather than modifying the existing one. Essential for timer
  /// state updates and session progression tracking.
  ///
  /// All parameters are optional - only specified properties will be updated
  /// while preserving all other values from the current instance.
  FlowmodoroModel copyWith({
    String? id,
    String? taskId,
    int? focusMinutes,
    int? breakMinutes,
    int? pomoCount,
    bool? isRunning,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return FlowmodoroModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      pomoCount: pomoCount ?? this.pomoCount,
      isRunning: isRunning ?? this.isRunning,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ===== FACTORY CONSTRUCTORS =====

  /// Creates a FlowmodoroModel from a data map (typically from storage or API)
  ///
  /// Handles robust deserialization from various data sources, including:
  /// - Type-safe field extraction with fallback defaults
  /// - Flexible date parsing supporting both DateTime objects and ISO strings
  /// - Default values for missing optional fields to ensure data integrity
  /// - Support for external ID assignment for database integration
  ///
  /// Parameters:
  /// - [map]: Data map containing Flowmodoro session properties
  /// - [id]: Optional external ID override (useful for Firestore document IDs)
  factory FlowmodoroModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return FlowmodoroModel(
      id: id ?? map['id'],
      taskId: map['task_id'],
      focusMinutes: map['focus_minutes'] ?? 25,
      breakMinutes: map['break_minutes'] ?? 5,
      pomoCount: map['pomo_count'] ?? 4,
      isRunning: map['is_running'] ?? false,
      isCompleted: map['is_completed'] ?? false,
      // ===== FLEXIBLE DATE PARSING =====
      // Handle both DateTime objects and ISO string formats for broad compatibility
      createdAt: map['created_at'] != null
          ? (map['created_at'] is DateTime
              ? map['created_at']
              : DateTime.parse(map['created_at']))
          : DateTime.now(),
    );
  }

  // ===== SERIALIZATION METHODS =====

  /// Serializes this FlowmodoroModel to a Map for storage or transmission
  ///
  /// Converts all properties to storage-compatible types:
  /// - DateTime objects are converted to ISO 8601 strings for universal compatibility
  /// - All fields use snake_case naming to match database conventions
  /// - Maintains data type consistency for reliable deserialization
  ///
  /// The resulting map can be used for:
  /// - Local storage (SharedPreferences, Hive, etc.)
  /// - Cloud storage (Firestore, REST APIs)
  /// - Inter-process communication
  /// - Data export and backup operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'focus_minutes': focusMinutes,
      'break_minutes': breakMinutes,
      'pomo_count': pomoCount,
      'is_running': isRunning,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ===== STRING REPRESENTATION =====

  /// Provides a human-readable string representation of the Flowmodoro session
  ///
  /// Includes key session details for debugging and logging purposes.
  /// Useful for development, troubleshooting, and session analytics.
  @override
  String toString() {
    return 'FlowmodoroModel('
        'id: "$id", '
        'taskId: "$taskId", '
        'focus: ${focusMinutes}min, '
        'break: ${breakMinutes}min, '
        'cycles: $pomoCount, '
        'running: $isRunning, '
        'completed: $isCompleted'
        ')';
  }

  // ===== COMPUTED PROPERTIES =====

  /// Calculates the total planned session duration in minutes
  ///
  /// Computes the complete session length including all focus periods
  /// and break periods based on the configured cycle count.
  ///
  /// Formula: (focusMinutes + breakMinutes) * pomoCount
  /// Note: The final cycle typically omits the last break period
  int get totalPlannedMinutes => (focusMinutes + breakMinutes) * pomoCount;

  /// Calculates the total planned focus time in minutes
  ///
  /// Computes only the productive focus time, excluding breaks.
  /// Useful for productivity analytics and time tracking reports.
  int get totalFocusMinutes => focusMinutes * pomoCount;

  /// Calculates the total planned break time in minutes
  ///
  /// Computes only the break time, excluding focus periods.
  /// Useful for work-life balance analytics and break pattern tracking.
  int get totalBreakMinutes => breakMinutes * pomoCount;

  // ===== SESSION VALIDATION =====

  /// Validates if the Flowmodoro session configuration is valid
  ///
  /// Checks for logical consistency in session parameters:
  /// - Focus and break minutes must be positive
  /// - Pomodoro count must be at least 1
  /// - IDs must not be empty
  ///
  /// Returns true if configuration is valid, false otherwise.
  /// Useful for input validation and data integrity checks.
  bool get isValidConfiguration {
    return id.isNotEmpty &&
        taskId.isNotEmpty &&
        focusMinutes > 0 &&
        breakMinutes > 0 &&
        pomoCount > 0;
  }
}
