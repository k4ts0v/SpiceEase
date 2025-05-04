import 'package:spiceease/core/database/firerstore_date_adapter.dart';

/// Represents a symptom logged by a user.
///
/// This model captures details about the user's symptom, including its name,
/// severity, category, and onset time.
class SymptomModel {
  // Private fields
  final String _id; // Immutable field (Primary Key, assigned by the database)
  final String _userId; // Immutable field (Foreign Key)
  String _category; // Mutable field with setter
  String _name; // Mutable field with setter
  int _severity; // Mutable field with setter
  final DateTime _createdAt; // Immutable field (Timestamp of onset)
  DateTime _updatedAt;

  // Getters for accessing private fields
  String get id => _id;
  String get userId => _userId;
  String get category => _category;
  String get name => _name;
  int get severity => _severity;
  DateTime get createdAt => _createdAt;
  DateTime get updatedAt => _updatedAt;

  // Setters for mutable fields

  /// Sets the category ID for the symptom.
  ///
  /// Throws an exception if the category ID is not positive.
  set category(String newCategory) {
    if (newCategory.isNotEmpty) {
      _category = newCategory;
    } else {
      throw Exception("Category ID must be a non-empty string.");
    }
  }

  /// Sets the name of the symptom.
  ///
  /// Throws an exception if the name is empty or exceeds 100 characters.
  set name(String newName) {
    if (newName.isNotEmpty && newName.length <= 100) {
      _name = newName;
    } else {
      throw Exception("Symptom name must be between 1 and 100 characters.");
    }
  }

  /// Sets the severity of the symptom.
  ///
  /// Throws an exception if the severity is not between 1 and 10.
  set severity(int newSeverity) {
    if (newSeverity >= 1 && newSeverity <= 10) {
      _severity = newSeverity;
    } else {
      throw Exception("Severity must be between 1 and 10.");
    }
  }

  /// Sets the updatedAt of the symptom.
  ///
  /// Throws an exception if the severity is not between 1 and 10.
  set updatedAt(DateTime newUpdatedAt) {
    if (newUpdatedAt.isBefore(DateTime.now())) {
      _updatedAt = newUpdatedAt;
    } else {
      throw Exception("UpdatedAt must be a past date.");
    }
  }

  // Constructor
  SymptomModel({
    required String id,
    required String userId,
    required String category,
    required String name,
    required int severity,
    required DateTime createdAt,
    DateTime? updatedAt,
  })  : _id = id,
        _userId = userId,
        _category = category,
        _name = name,
        _severity = severity,
        _createdAt = createdAt,
        _updatedAt = updatedAt ?? createdAt;

  /// Factory constructor that creates a SymptomModel from a map.
  ///
  /// Handles:
  /// - Database field mapping
  /// - Type-safe conversions
  ///
  /// [map]: The database record as a key-value map.
  factory SymptomModel.fromMap(Map<String, dynamic> map) {
    return SymptomModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      category: map['category_id'] ?? '',
      name: map['name'] ?? '',
      severity: (map['severity'] is int)
          ? map['severity']
          : int.tryParse(map['severity'].toString()) ?? 1,
      createdAt: FirestoreDateAdapter.fromFirestore(map['created_at']),
      updatedAt: FirestoreDateAdapter.fromFirestore(map['updated_at']),
    );
  }

  /// Serializes the SymptomModel into a map format for database storage.
  ///
  /// Returns:
  /// - Key-value pairs with application-level naming conventions.
  /// - Converts Dart `DateTime` to ISO 8601 string for compatibility.
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'user_id': _userId,
      'category_id': _category,
      'name': _name,
      'severity': _severity,
      'created_at': FirestoreDateAdapter.toTimestamp(_createdAt),
      'updated_at': FirestoreDateAdapter.toTimestamp(_updatedAt),
    };
  }

  SymptomModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    int? severity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SymptomModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
