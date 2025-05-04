import 'package:spiceease/core/database/firerstore_date_adapter.dart';

/// Represents an mood entry entity logged by a user.
///
/// This model captures details about the user's mood level, associated notes,
/// and timestamps for when the data was recorded and created.
class MoodModel {
  // Private fields
  final String _id;
  final String _userId; // Immutable field (Foreign Key)
  int _moodLevel; // Mutable field with a setter
  String? _notes; // Mutable field with a setter
  final DateTime _createdAt; // Immutable field (Timestamp when recorded)
  DateTime _updatedAt;

  // Getters for accessing private fields
  String get id => _id;
  String get userId => _userId;
  int get moodLevel => _moodLevel;
  String? get notes => _notes;
  DateTime get createdAt => _createdAt;
  DateTime get updatedAt => _updatedAt;

  // Setters for mutable fields

  /// Sets the mood level for the mood entry.
  set moodLevel(int newMoodLevel) {
    if (newMoodLevel >= 1 && newMoodLevel <= 10) {
      _moodLevel = newMoodLevel;
    } else {
      throw Exception("Mood level must be between 1 and 10.");
    }
  }

  /// Sets the notes for the mood entry.
  set notes(String? newNotes) {
    _notes = newNotes;
  }

  /// Sets the updatedAt of the mood entry.
  set updatedAt(DateTime newUpdatedAt) {
    if (newUpdatedAt.isBefore(DateTime.now())) {
      _updatedAt = newUpdatedAt;
    } else {
      throw Exception("UpdatedAt must be a past date.");
    }
  }

  // Constructor
  MoodModel({
    required String id,
    required String userId,
    required int moodLevel,
    required String? notes,
    required DateTime createdAt,
    DateTime? updatedAt,
  })  : _id = id,
        _userId = userId,
        _moodLevel = moodLevel,
        _notes = notes,
        _createdAt = createdAt,
        _updatedAt = updatedAt ?? createdAt;

  /// Factory constructor that creates an MoodModel from a map.
  factory MoodModel.fromMap(Map<String, dynamic> map) {
    return MoodModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      moodLevel: (map['mood_level'] is int)
          ? map['mood_level']
          : int.tryParse(map['mood_level'].toString()) ?? 1,
      notes: map['notes'] as String? ?? '',
      createdAt: FirestoreDateAdapter.fromFirestore(map['created_at']),
      updatedAt: FirestoreDateAdapter.fromFirestore(map['updated_at']),
    );
  }

  /// Serializes the MoodModel into a map format for database storage.
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'user_id': _userId,
      'mood_level': _moodLevel,
      'notes': _notes,
      'created_at': FirestoreDateAdapter.toTimestamp(_createdAt),
      'updated_at': FirestoreDateAdapter.toTimestamp(_updatedAt),
    };
  }

  /// Returns a copy of this MoodModel with updated fields.
  MoodModel copyWith({
    String? id,
    String? userId,
    int? moodLevel,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MoodModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      moodLevel: moodLevel ?? this.moodLevel,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}