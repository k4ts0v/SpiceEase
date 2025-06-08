import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spiceease/core/database/firestore_date_adapter.dart';

class HabitModel {
  final String _id;
  final String _userId;
  String _title;
  String _description;
  int _frequency;
  List<int>? _customDays;
  List<DateTime> _completedDates;
  DateTime? _nextDueDate;
  final DateTime _createdAt;
  DateTime _updatedAt;

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

  String get id => _id;
  String get userId => _userId;
  String get title => _title;
  String get description => _description;
  int get frequency => _frequency;
  List<int>? get customDays => _customDays;
  List<DateTime> get completedDates => List.unmodifiable(_completedDates);
  DateTime? get nextDueDate => _nextDueDate;
  DateTime get createdAt => _createdAt;
  DateTime get updatedAt => _updatedAt;

  set title(String value) {
    if (value.isEmpty) throw Exception("Title cannot be empty.");
    _title = value;
  }

  set description(String newDescription) => _description = newDescription;
  set frequency(int value) {
    if (value <= 0) throw Exception("Frequency must be greater than 0.");
    _frequency = value;
  }

  set customDays(List<int>? value) => _customDays = value;
  set updatedAt(DateTime value) => _updatedAt = value;
  set nextDueDate(DateTime? value) => _nextDueDate = value;

  DateTime? get lastCompleted {
    if (_completedDates.isEmpty) return null;
    return _completedDates.last;
  }

  factory HabitModel.fromMap(Map<String, dynamic> map, {String? id}) {
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

  void debugPrintCompletedDates() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    debugPrint('[$id] Completed dates (${completedDates.length}):');
    for (final date in completedDates) {
      debugPrint('  - ${dateFormat.format(date)}');
    }
  }

  void toggleCompletion({required bool isCompleted, DateTime? forDate}) {
    final now = DateTime.now();
    final date = DateTime(
      forDate?.year ?? now.year,
      forDate?.month ?? now.month,
      forDate?.day ?? now.day,
    );

    debugPrint(
        '[HabitModel] Toggling completion: $isCompleted for ${DateFormat('yyyy-MM-dd').format(date)}');
    debugPrintCompletedDates();

    if (isCompleted) {
      if (!_completedDates.any((d) => _isSameDate(d, date))) {
        _completedDates.add(date);
        _completedDates.sort((a, b) => a.compareTo(b));
      }
    } else {
      _completedDates.removeWhere((d) => _isSameDate(d, date));
    }

    debugPrint('[HabitModel] After toggle:');
    debugPrintCompletedDates();

    _nextDueDate = calculateNextDueDate();
    _updatedAt = DateTime.now();
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime? calculateNextDueDate() {
    if (_frequency > 0) {
      final baseDate =
          _completedDates.isNotEmpty ? _completedDates.last : _createdAt;
      return baseDate.add(Duration(days: _frequency));
    } else if (_frequency == 0 && _customDays != null) {
      final now = DateTime.now();
      final todayWeekday = now.weekday;

      if (_customDays!.every((d) => d <= 7)) {
        final next = _customDays!.where((d) => d > todayWeekday).fold<int?>(
                  null,
                  (prev, curr) => prev == null || curr < prev ? curr : prev,
                ) ??
            _customDays!.first;
        final daysUntil = (next - todayWeekday + 7) % 7;
        return now.add(Duration(days: daysUntil));
      } else {
        final todayDay = now.day;
        final nextDay = _customDays!.where((d) => d > todayDay).fold<int?>(
                  null,
                  (prev, curr) => prev == null || curr < prev ? curr : prev,
                ) ??
            _customDays!.first;
        return DateTime(now.year, now.month, nextDay);
      }
    }
    return null;
  }
}
