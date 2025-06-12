import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:spiceease/core/database/firestore_date_adapter.dart';

class MedicationModel {
  final String _id;
  final String _userId;
  String _name;
  double _dose;
  String _unit;
  String _frequency;
  List<int>? _customDays;
  int _timesPerDay;
  final List<DateTime> _datesTaken;
  DateTime? _nextDueDate;
  final DateTime _createdAt;
  DateTime _updatedAt;

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

  // Getters
  String get id => _id;
  String get userId => _userId;
  String get name => _name;
  double get dose => _dose;
  String get unit => _unit;
  String get frequency => _frequency;
  List<int>? get customDays => _customDays;
  int get timesPerDay => _timesPerDay;
  List<DateTime> get completedDates => List.unmodifiable(_datesTaken);
  DateTime? get nextDueDate => _nextDueDate;
  DateTime get createdAt => _createdAt;
  DateTime get updatedAt => _updatedAt;

  // Get last completed date
  DateTime? get lastCompleted {
    if (_datesTaken.isEmpty) return null;
    return _datesTaken.last;
  }

  // Setters
  set name(String newName) => _name = newName;
  set dose(double newDose) => _dose = newDose;
  set unit(String newUnit) => _unit = newUnit;
  set frequency(String newFrequency) => _frequency = newFrequency;
  set customDays(List<int>? newCustomDays) => _customDays = newCustomDays;
  set timesPerDay(int newTimesPerDay) => _timesPerDay = newTimesPerDay;
  set nextDueDate(DateTime? newNextDueDate) => _nextDueDate = newNextDueDate;
  set updatedAt(DateTime newUpdatedAt) => _updatedAt = newUpdatedAt;

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
      'completed_dates': _datesTaken
          .map((d) => FirestoreDateAdapter.toTimestamp(d))
          .toList(),
      'next_due_date': nextDueDate != null
          ? FirestoreDateAdapter.toTimestamp(nextDueDate!)
          : null,
      'created_at': FirestoreDateAdapter.toTimestamp(createdAt),
      'updated_at': FirestoreDateAdapter.toTimestamp(updatedAt),
    };
  }

  factory MedicationModel.fromMap(Map<String, dynamic> map) {
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
      dose: (map['dose'] is double)
          ? map['dose']
          : (map['dose'] is int)
              ? (map['dose'] as int).toDouble()
              : double.tryParse(map['dose'].toString()) ?? 0.0,
      unit: map['unit'] ?? '',
      frequency: map['frequency'] ?? 'daily',
      customDays:
          (map['custom_days'] as List<dynamic>?)?.map((e) => e as int).toList(),
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

  DateTime? calculateNextDueDate() {
    final baseDate = lastCompleted ?? updatedAt;
    if (baseDate == null) return null;

    switch (frequency.toLowerCase()) {
      case 'daily':
        return baseDate.add(const Duration(days: 1));

      case 'weekly':
        if (customDays == null || customDays!.isEmpty) {
          return baseDate.add(const Duration(days: 7));
        }
        final today = baseDate.weekday;
        final nextDay = customDays!.firstWhere(
          (day) => day > today,
          orElse: () => customDays!.first,
        );
        final daysUntil = (nextDay - today + 7) % 7;
        return baseDate.add(Duration(days: daysUntil));

      case 'monthly':
        if (customDays == null || customDays!.isEmpty) {
          return DateTime(baseDate.year, baseDate.month + 1, baseDate.day);
        }
        final currentDay = baseDate.day;
        final nextDay = customDays!.firstWhere(
          (day) => day > currentDay,
          orElse: () => customDays!.first,
        );
        return nextDay > currentDay
            ? DateTime(baseDate.year, baseDate.month, nextDay)
            : DateTime(baseDate.year, baseDate.month + 1, nextDay);

      default:
        return null;
    }
  }

  // Get taken count for specific date
  int getTakenCountForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return _datesTaken.where((d) =>
      d.year == dateKey.year && d.month == dateKey.month && d.day == dateKey.day
    ).length;
  }

  // Update taken status for a specific date
  void updateTakenStatus(DateTime date, bool taken) {
    final dateKey = DateTime(date.year, date.month, date.day);
    if (taken) {
      if (!_datesTaken.any((d) =>
          d.year == dateKey.year &&
          d.month == dateKey.month &&
          d.day == dateKey.day)) {
        _datesTaken.add(dateKey);
      }
    } else {
      _datesTaken.removeWhere((d) =>
          d.year == dateKey.year &&
          d.month == dateKey.month &&
          d.day == dateKey.day);
    }
    _updatedAt = DateTime.now();
    _nextDueDate = calculateNextDueDate();
  }

  // Check if medication was taken on a date
  bool isTakenOnDate(DateTime date) {
    return getTakenCountForDate(date) > 0;
  }

  @override
  String toString() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final completedDatesStr = _datesTaken
        .map((d) => dateFormat.format(d))
        .join(', ');

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

  // Debug method to print completed dates
  void debugPrintCompletedDates() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    debugPrint('[$id] Completed dates:');
    if (_datesTaken.isEmpty) {
      debugPrint('  - None');
      return;
    }

    final sortedDates = _datesTaken.toList()..sort();
    for (final date in sortedDates) {
      debugPrint('  - ${dateFormat.format(date)}');
    }
  }
}