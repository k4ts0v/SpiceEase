import 'package:spiceease/core/database/firerstore_date_adapter.dart';

class MedicationModel {
  final String id;
  final String userId;
  final String name;
  final double dose;
  final String unit;
  final int takenTimes;
  final String frequency;
  final List<int>? customDays;
  final int timesPerDay;
  final DateTime? lastTaken;
  final DateTime? nextDueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicationModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.dose,
    required this.unit,
    required this.takenTimes,
    required this.frequency,
    this.customDays,
    required this.timesPerDay,
    this.lastTaken,
    this.nextDueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  MedicationModel copyWith({
    String? name,
    double? dose,
    String? unit,
    int? takenTimes,
    String? frequency,
    List<int>? customDays,
    int? timesPerDay,
    DateTime? lastTaken,
    DateTime? nextDueDate,
    DateTime? updatedAt,
  }) {
    return MedicationModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      unit: unit ?? this.unit,
      takenTimes: takenTimes ?? this.takenTimes,
      frequency: frequency ?? this.frequency,
      customDays: customDays ?? this.customDays,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      lastTaken: lastTaken ?? this.lastTaken,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  DateTime? calculateNextDueDate() {
    final baseDate = lastTaken ?? createdAt;

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
        final offset =
            nextDay > today ? (nextDay - today) : (7 - today + nextDay);
        return baseDate.add(Duration(days: offset));

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'dose': dose,
      'unit': unit,
      'taken_times': takenTimes,
      'frequency': frequency,
      'custom_days': customDays,
      'times_per_day': timesPerDay,
      'last_taken': lastTaken,
      'next_due_date': nextDueDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory MedicationModel.fromMap(Map<String, dynamic> map) {
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
      takenTimes: (map['taken_times'] is int)
          ? map['taken_times']
          : (map['taken_times'] is double)
              ? (map['taken_times'] as double).toInt()
              : int.tryParse(map['taken_times']?.toString() ?? '0') ?? 0,
      frequency: map['frequency'] ?? '',
      customDays:
          (map['custom_days'] as List<dynamic>?)?.map((e) => e as int).toList(),
      timesPerDay: (map['times_per_day'] is int)
          ? map['times_per_day']
          : int.tryParse(map['times_per_day'].toString()) ?? 1,
      lastTaken: FirestoreDateAdapter.fromFirestore(map['last_taken']),
      nextDueDate: FirestoreDateAdapter.fromFirestore(map['next_due_date']),
      createdAt: FirestoreDateAdapter.fromFirestore(map['created_at']),
      updatedAt: FirestoreDateAdapter.fromFirestore(map['updated_at']),
    );
  }
}
