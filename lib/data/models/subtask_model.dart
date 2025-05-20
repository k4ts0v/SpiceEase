import 'package:cloud_firestore/cloud_firestore.dart';

class SubtaskModel {
  // Add fields required for flat DB structure
  final String _id;
  final String _userId; // Add owner user ID
  final String _taskId;
  String _title;
  int _order;
  bool _completed;
  String? _rawTimeValue;
  final DateTime _createdAt; // Add creation timestamp
  final DateTime _updatedAt; // Add update timestamp

  // Update constructor
  SubtaskModel({
    required String id,
    required String taskId,
    required String userId,
    required String title,
    int order = 0,
    bool completed = false,
    String? rawTimeValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : _id = id,
        _taskId = taskId,
        _userId = userId,
        _title = title,
        _order = order,
        _completed = completed,
        _rawTimeValue = rawTimeValue,
        _createdAt = createdAt ?? DateTime.now(),
        _updatedAt = updatedAt ?? DateTime.now();

  // Add getters for new fields
  String get id => _id;
  String get userId => _userId;
  String get taskId => _taskId;
  String get title => _title;
  int get order => _order;
  bool get completed => _completed;
  String? get rawTimeValue => _rawTimeValue;
  DateTime get createdAt => _createdAt;
  DateTime get updatedAt => _updatedAt;
  // Update toMap method
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'task_id': _taskId,
      'user_id': _userId,
      'title': _title,
      'order': _order,
      'completed': _completed,
      'raw_time_value': _rawTimeValue,
      'created_at': _createdAt,
      'updated_at': _updatedAt,
    };
  }

  // Update fromMap factory
  factory SubtaskModel.fromMap(Map<String, dynamic> map) {
    DateTime? _parseDynamicDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is Timestamp) return v.toDate();
      if (v is String) {
        return DateTime.tryParse(v);
      }
      return null;
    }

    return SubtaskModel(
      id: map['id'] ?? '',
      taskId: map['task_id'] ?? '',
      userId: map['user_id'] ?? '',
      title: map['title'] ?? '',
      order: map['order'] ?? 0,
      completed: map['completed'] ?? false,
      rawTimeValue: map['raw_time_value'],
      createdAt: _parseDynamicDate(map['created_at']),
      updatedAt: _parseDynamicDate(map['updated_at']),
    );
  }

  // Add copyWith method
SubtaskModel copyWith({
  String? id,
  String? taskId,
  String? userId,
  String? title,
  int? order,
  bool? completed,
  String? rawTimeValue,
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
    rawTimeValue: rawTimeValue ?? this.rawTimeValue,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? DateTime.now(), // Always update the updatedAt timestamp
  );
}

}
