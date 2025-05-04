import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spiceease/data/models/subtask_model.dart';

class TaskModel {
  // Private fields
  final String _id; // Immutable field (Document ID)
  final String _userId; // Immutable field (Foreign Key)
  String _title; // Mutable field with setter
  String _description; // Mutable field with setter
  String _status; // Mutable field with setter
  DateTime? _dueDate; // Mutable field with setter
  DateTime? _completedAt; // Mutable field with setter
  int? _estimatedTime; // Mutable field with setter
  String? _estimatedUnit; // Mutable field with setter
  int _priority; // Mutable field with setter
  final DateTime _createdAt; // Immutable field
  DateTime _updatedAt; // Mutable field
  bool _hasDueDate;
  final List<SubtaskModel>? _subtasks;
  final String? _parentTaskId; // null for root tasks, populated for subtasks
  final bool _isSubtask; // flag to easily identify subtasks
  final int _subtaskOrder; // position within parent's subtasks

  // Constructor
  TaskModel({
    required String id,
    required String userId,
    required String title,
    String description = '',
    String status = 'pending',
    DateTime? dueDate,
    DateTime? completedAt,
    int? estimatedTime,
    String? estimatedUnit,
    int priority = 1,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool? hasDueDate,
    List<SubtaskModel>? subtasks,
    final String? parentTaskId,
    final bool isSubtask = false,
    final int subtaskOrder = 0,
  })  : _id = id,
        _userId = userId,
        _title = title,
        _description = description,
        _status = status,
        _dueDate = dueDate,
        _completedAt = completedAt,
        _estimatedTime = estimatedTime,
        _estimatedUnit = estimatedUnit,
        _priority = priority,
        _createdAt = createdAt,
        _updatedAt = updatedAt,
        _hasDueDate = dueDate != null,
        _subtasks = subtasks ?? [],
        _parentTaskId = parentTaskId,
        _isSubtask = isSubtask,
        _subtaskOrder = subtaskOrder;

  // Getters
  String get id => _id;
  String get userId => _userId;
  String get title => _title;
  String get description => _description;
  String get status => _status;
  DateTime? get dueDate => _dueDate;
  DateTime? get completedAt => _completedAt;
  int? get estimatedTime => _estimatedTime;
  String? get estimatedUnit => _estimatedUnit;
  int get priority => _priority;
  DateTime get createdAt => _createdAt;
  DateTime get updatedAt => _updatedAt;
  bool get hasDueDate => _hasDueDate;
  List<SubtaskModel>? get subtasks => _subtasks;
  String? get parentTaskId => _parentTaskId;
  bool get isSubtask => _isSubtask;
  int get subtaskOrder => _subtaskOrder;


  // Setters
  set title(String newTitle) {
    if (newTitle.isNotEmpty) {
      _title = newTitle;
    } else {
      throw Exception("Title cannot be empty.");
    }
  }

  set description(String newDescription) {
    _description = newDescription;
  }

  set status(String newStatus) {
    _status = newStatus;
  }

  set dueDate(DateTime? newDueDate) {
    _dueDate = newDueDate;
  }

  set completedAt(DateTime? newCompletedAt) {
    _completedAt = newCompletedAt;
  }

  set estimatedTime(int? newEstimatedTime) {
    _estimatedTime = newEstimatedTime;
  }

  set estimatedUnit(String? newEstimatedUnit) {
    _estimatedUnit = newEstimatedUnit;
  }

  set priority(int newPriority) {
    _priority = newPriority;
  }

  set updatedAt(DateTime newUpdatedAt) {
    _updatedAt = newUpdatedAt;
  }

  set hasDueDate(bool value) {
    if (value && _dueDate == null) {
      throw ArgumentError('Cannot set hasDueDate to true without a dueDate');
    }
    _hasDueDate = value;
    if (!value) {
      _dueDate = null;
    }
    ;
  }

  // Update the fromMap method to safely convert double to int:

factory TaskModel.fromMap(Map<String, dynamic> map, {String? id}) {
  DateTime? _parseDynamicDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is Timestamp) return v.toDate();
    if (v is String) {
      return DateTime.tryParse(v);
    }
    return null;
  }

  // Safely handle numeric values that might be doubles or ints
  int? _parseEstimatedTime(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
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
    // Use the safe conversion function
    estimatedTime: _parseEstimatedTime(map['estimated_time']),
    estimatedUnit: (map['estimated_unit'] as String?),
    priority: map['priority'] is double ? (map['priority'] as double).toInt() : (map['priority'] as int? ?? 1),
    createdAt: _parseDynamicDate(map['created_at'])!,
    updatedAt: _parseDynamicDate(map['updated_at'])!,
    subtasks: (map['subtasks'] as List?)
            ?.map((s) => SubtaskModel.fromMap(s))
            .toList() ??
        [],
    parentTaskId: map['parent_task_id'] as String?,
    isSubtask: map['is_subtask'] as bool? ?? false,
    subtaskOrder: map['subtask_order'] is double ? (map['subtask_order'] as double).toInt() : (map['subtask_order'] as int? ?? 0),
  );
}

  /// Serializes this TaskModel to a Map, storing dates as ISO-8601 strings.
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
      'has_due_date': dueDate != null,
      'subtasks': subtasks?.map((s) => s.toMap()).toList(),
      'parent_task_id': _parentTaskId,
      'is_subtask': _isSubtask,
      'subtask_order': _subtaskOrder,
    };
  }

  TaskModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? status,
    DateTime? dueDate,
    DateTime? completedAt,
    int? estimatedTime,
    String? estimatedUnit,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasDueDate,
    List<SubtaskModel>? subtasks,
    String? parentTaskId,
    bool? isSubtask,
    int? subtaskOrder,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      estimatedUnit: estimatedUnit ?? this.estimatedUnit,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hasDueDate: hasDueDate ?? this.hasDueDate,
      subtasks: subtasks ?? this.subtasks,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      isSubtask: isSubtask ?? this.isSubtask,
      subtaskOrder: subtaskOrder ?? this.subtaskOrder,
    );
  }
}