class SubtaskModel {
  // Private fields
  final String _id; // Immutable field (Document ID)
  final String _taskId; // Immutable field (Foreign Key)
  String _title; // Mutable field with setter
  int _order; // Mutable field with setter
  bool _completed; // Mutable field with setter
  String? _rawTimeValue; // Raw time value for database compatibility
  String? _rawTimeUnit; // Raw time unit for database compatibility

  // Getters for accessing private fields
  String get id => _id;
  String get taskId => _taskId;
  String get title => _title;
  int get order => _order;
  bool get completed => _completed;
  String? get rawTimeValue => _rawTimeValue;
  String? get rawTimeUnit => _rawTimeUnit;

  // Setters for mutable fields

  /// Sets the title to the provided title.
  set title(String newTitle) {
    if (newTitle.isNotEmpty) {
      _title = newTitle;
    } else {
      throw Exception("Title cannot be empty.");
    }
  }

  /// Sets the order to the provided order.
  set order(int newOrder) {
    if (newOrder >= 0) {
      _order = newOrder;
    } else {
      throw Exception("Order cannot be negative.");
    }
  }

  /// Sets the completed status to the provided completed status.
  set completed(bool newCompleted) {
    _completed = newCompleted;
  }

  // Constructor
  SubtaskModel({
    required String id,
    required String taskId,
    required String title,
    int order = 0,
    bool completed = false,
    String? rawTimeValue,
    String? rawTimeUnit,
  })  : _id = id,
        _taskId = taskId,
        _title = title,
        _order = order,
        _completed = completed,
        _rawTimeValue = rawTimeValue,
        _rawTimeUnit = rawTimeUnit;

  /// Factory constructor that constructs SubtaskModel from generic key-value map structure
  ///
  /// Handles:
  /// - Database-agnostic field mapping
  /// - Type-safe conversions
  /// - Default values for subtask fields
  ///
  /// [map]: Database record structure
  factory SubtaskModel.fromMap(Map<String, dynamic> map) {
    return SubtaskModel(
      id: map['id'] ?? '', // Handle null ID
      taskId: map['task_id'] ?? '', // Handle null task_id
      title: map['title'] ?? '',
      order: map['order'] ?? 0,
      completed: map['completed'] ?? false,
      rawTimeValue: map['raw_time_value'] ?? '',
      rawTimeUnit: map['raw_time_unit'] ?? '',
    );
  }

  /// Serializes subtask data to database-agnostic map format
  ///
  /// Returns:
  /// - String keys using application-level naming conventions
  /// - Native Dart types for database compatibility
  Map<String, dynamic> toMap() {
    return {
      'task_id': _taskId,
      'title': _title,
      'order': _order,
      'completed': _completed,
      'raw_time_value': rawTimeValue,
      'raw_time_unit': rawTimeUnit,
    };
  }

  SubtaskModel copyWith({
    String? id,
    String? taskId,
    String? title,
    int? order,
    bool? completed,
    String? rawTimeValue,
    String? rawTimeUnit,
  }) {
    return SubtaskModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      order: order ?? this.order,
      completed: completed ?? this.completed,
      rawTimeValue: rawTimeValue ?? this.rawTimeValue,
      rawTimeUnit: rawTimeUnit ?? this.rawTimeUnit,
    );
  }
}
