import 'package:cloud_firestore/cloud_firestore.dart';

class HabitModel {
  // Private fields
  final String _id; // Immutable field (Document ID)
  final String _userId; // Immutable field (Foreign Key)
  String _title; // Mutable field with setter
  String _description; // Mutable field with setter
  int _frequency; // Mutable field with setter (stored as days)
  List<int>? _customDays; // Mutable field with setter (for custom frequency)
  DateTime? _lastCompleted; // Mutable field with setter
  DateTime? _nextDueDate; // Mutable field with setter
  final DateTime _createdAt; // Immutable field
  DateTime _updatedAt; // Mutable field

  // Constructor
  HabitModel({
    required String id,
    required String userId,
    required String title,
    String description = '',
    int frequency = 1,
    List<int>? customDays,
    DateTime? lastCompleted,
    required DateTime? nextDueDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : _id = id,
        _userId = userId,
        _title = title,
        _description = description,
        _frequency = frequency,
        _customDays = customDays,
        _lastCompleted = lastCompleted,
        _nextDueDate = nextDueDate,
        _createdAt = createdAt,
        _updatedAt = updatedAt;

  // --------------------
  // Getters
  // --------------------
  String get id => _id;
  String get userId => _userId;
  String get title => _title;
  String get description => _description;
  int get frequency => _frequency;
  List<int>? get customDays => _customDays;
  DateTime? get lastCompleted => _lastCompleted;
  DateTime? get nextDueDate => _nextDueDate;
  DateTime get createdAt => _createdAt;
  DateTime get updatedAt => _updatedAt;

  // --------------------
  // Setters
  // --------------------
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

  set frequency(int newFrequency) {
    if (newFrequency > 0) {
      _frequency = newFrequency;
    } else {
      throw Exception("Frequency must be greater than 0.");
    }
  }

  set customDays(List<int>? newCustomDays) {
    _customDays = newCustomDays;
  }

  set lastCompleted(DateTime? newLastCompleted) {
    _lastCompleted = newLastCompleted;
  }

  set nextDueDate(DateTime? newNextDueDate) {
    _nextDueDate = newNextDueDate;
  }

  set updatedAt(DateTime newUpdatedAt) {
    _updatedAt = newUpdatedAt;
  }

  // --------------------
  // Factory from Map
  // --------------------
  factory HabitModel.fromMap(Map<String, dynamic> map, {String? id}) {
  DateTime? _parseDynamicDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is Timestamp) return v.toDate();
    if (v is String) {
      return DateTime.tryParse(v);
    }
    return null;
  }

  return HabitModel(
    id: id ?? map['id'] as String,
    userId: map['user_id'] as String,
    title: map['title'] as String,
    description: map['description'] as String? ?? '',
    frequency: map['frequency'] as int? ?? 1,
    customDays:
        (map['custom_days'] as List<dynamic>?)?.map((e) => e as int).toList(),
    lastCompleted: _parseDynamicDate(map['last_completed']),
    nextDueDate: _parseDynamicDate(map['next_due_date']),
    createdAt: _parseDynamicDate(map['created_at']) ?? DateTime.now(),
    updatedAt: _parseDynamicDate(map['updated_at'])!,
  );
}

  // --------------------
  // Serialization to Map
  // --------------------
  Map<String, dynamic> toMap() {
  return {
    'user_id': _userId,
    'title': _title,
    'description': _description,
    'frequency': _frequency,
    'custom_days': _customDays,
    'last_completed': _lastCompleted, // Ensure UTC for Firestore
    'next_due_date': _nextDueDate, // Ensure UTC for Firestore
    'created_at': _createdAt,
    'updated_at': _updatedAt,
  };
}

  // --------------------
  // Copy Method
  // --------------------
  HabitModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    int? frequency,
    List<int>? customDays,
    DateTime? lastCompleted,
    DateTime? nextDueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      customDays: customDays ?? this.customDays,
      lastCompleted: lastCompleted,
      nextDueDate: nextDueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // --------------------
  // Calculate Next Due Date
  // --------------------
  void calculateNextDueDate() {
    if (_frequency > 0) {
      // Daily or Weekly
      _nextDueDate =
          (_lastCompleted ?? _createdAt).add(Duration(days: _frequency));
    } else if (_frequency == 0 && _customDays != null) {
      if (_customDays!.every((day) => day <= 7)) {
        // Weekly custom frequency
        final today = DateTime.now().weekday;
        final nextDay = _customDays!
            .firstWhere((d) => d > today, orElse: () => _customDays!.first);
        _nextDueDate =
            DateTime.now().add(Duration(days: (nextDay - today).abs()));
      } else {
        // Monthly custom frequency
        final today = DateTime.now().day;
        final nextDay = _customDays!
            .firstWhere((d) => d > today, orElse: () => _customDays!.first);
        _nextDueDate =
            DateTime(DateTime.now().year, DateTime.now().month, nextDay);
      }
    }
  }

// --------------------
  // Toggle Completion
  // --------------------
  void toggleCompletion({required bool isCompleted}) {
    if (isCompleted) {
      // Mark as completed
      _lastCompleted = DateTime.now();
      calculateNextDueDate();
    } else {
      // Unmark as completed
      _lastCompleted = null;

      // Reset nextDueDate to the original value before completion
      if (_frequency > 0) {
        // Daily or Weekly
        _nextDueDate = _createdAt.add(Duration(days: _frequency));
      } else if (_frequency == 0 && _customDays != null) {
        if (_customDays!.every((day) => day <= 7)) {
          // Weekly custom frequency
          final today = _createdAt.weekday;
          final nextDay = _customDays!
              .firstWhere((d) => d > today, orElse: () => _customDays!.first);
          _nextDueDate =
              _createdAt.add(Duration(days: (nextDay - today).abs()));
        } else {
          // Monthly custom frequency
          final today = _createdAt.day;
          final nextDay = _customDays!
              .firstWhere((d) => d > today, orElse: () => _customDays!.first);
          _nextDueDate = DateTime(_createdAt.year, _createdAt.month, nextDay);
        }
      }
    }
  }

   // Method to log the runtime types of the fields
  void logFieldTypes() {
    print('HabitModel Field Types:');
    print('id: ${id.runtimeType}');
    print('userId: ${userId.runtimeType}');
    print('title: ${title.runtimeType}');
    print('description: ${description.runtimeType}');
    print('frequency: ${frequency.runtimeType}');
    print('customDays: ${customDays.runtimeType}');
    if (customDays != null) {
      print('customDays elements: ${customDays!.map((e) => e.runtimeType).toList()}');
    }
    print('lastCompleted: ${lastCompleted.runtimeType}');
    print('nextDueDate: ${nextDueDate.runtimeType}');
    print('createdAt: ${createdAt.runtimeType}');
    print('updatedAt: ${updatedAt.runtimeType}');
  }

}
