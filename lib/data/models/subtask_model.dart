import 'package:spiceease/core/database/firestore_date_adapter.dart';

class SubtaskModel {
  final String _id;
  final String _userId;
  final String _taskId;
  String _title;
  int _order;
  bool _completed;
  String _status;
  String? _rawTimeValue;
  final DateTime? _startTime;
  final DateTime? _endTime;
  final DateTime? _completedAt;
  final DateTime _createdAt;
  final DateTime _updatedAt;

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

  String get id => _id;
  String get userId => _userId;
  String get taskId => _taskId;
  String get title => _title;
  int get order => _order;
  bool get completed => _completed;
  String get status => _status;
  String? get rawTimeValue => _rawTimeValue;
  DateTime? get startTime => _startTime;
  DateTime? get endTime => _endTime;
  DateTime? get completedAt => _completedAt;
  DateTime get createdAt => _createdAt;
  DateTime get updatedAt => _updatedAt;

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
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

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
      'start_time': _startTime != null ? FirestoreDateAdapter.toTimestamp(_startTime) : null,
      'end_time': _endTime != null ? FirestoreDateAdapter.toTimestamp(_endTime) : null,
      'completed_at': _completedAt != null ? FirestoreDateAdapter.toTimestamp(_completedAt) : null,
      'created_at': FirestoreDateAdapter.toTimestamp(_createdAt),
      'updated_at': FirestoreDateAdapter.toTimestamp(_updatedAt),
    };
  }

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
      createdAt:
          FirestoreDateAdapter.fromFirestore(map['created_at']) ?? DateTime.now(),
      updatedAt:
          FirestoreDateAdapter.fromFirestore(map['updated_at']) ?? DateTime.now(),
    );
  }
}