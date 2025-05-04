import 'package:spiceease/core/database/firerstore_date_adapter.dart';

/// Represents an energy entry entity logged by a user.
///
/// This model captures details about the user's energy level, associated notes,
/// and timestamps for when the data was recorded and created.
class EnergyModel {
  // Private fields
  final String _id;
  final String _userId; // Immutable field (Foreign Key)
  int _energyLevel; // Mutable field with a setter
  String? _notes; // Mutable field with a setter
  final DateTime _createdAt; // Immutable field (Timestamp when recorded)
  DateTime _updatedAt;

  // Getters for accessing private fields
  String get id => _id;
  String get userId => _userId;
  int get energyLevel => _energyLevel;
  String? get notes => _notes;
  DateTime get createdAt => _createdAt;
  DateTime get updatedAt => _updatedAt;

  // Setters for mutable fields

  /// Sets the energy level for the energy entry.
  set energyLevel(int newEnergyLevel) {
    if (newEnergyLevel >= 1 && newEnergyLevel <= 10) {
      _energyLevel = newEnergyLevel;
    } else {
      throw Exception("Energy level must be between 1 and 10.");
    }
  }

  /// Sets the notes for the energy entry.
  set notes(String? newNotes) {
    _notes = newNotes;
  }

  /// Sets the updatedAt of the energy entry.
  set updatedAt(DateTime newUpdatedAt) {
    if (newUpdatedAt.isBefore(DateTime.now())) {
      _updatedAt = newUpdatedAt;
    } else {
      throw Exception("UpdatedAt must be a past date.");
    }
  }

  // Constructor
  EnergyModel({
    required String id,
    required String userId,
    required int energyLevel,
    required String? notes,
    required DateTime createdAt,
    DateTime? updatedAt,
  })  : _id = id,
        _userId = userId,
        _energyLevel = energyLevel,
        _notes = notes,
        _createdAt = createdAt,
        _updatedAt = updatedAt ?? createdAt;

  /// Factory constructor that creates an EnergyModel from a map.
  factory EnergyModel.fromMap(Map<String, dynamic> map) {
    return EnergyModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      energyLevel: (map['energy_level'] is int)
          ? map['energy_level']
          : int.tryParse(map['energy_level'].toString()) ?? 1,
      notes: map['notes'] as String? ?? '',
      createdAt: FirestoreDateAdapter.fromFirestore(map['created_at']),
      updatedAt: FirestoreDateAdapter.fromFirestore(map['updated_at']),
    );
  }

  /// Serializes the EnergyModel into a map format for database storage.
  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'user_id': _userId,
      'energy_level': _energyLevel,
      'notes': _notes,
      'created_at': FirestoreDateAdapter.toTimestamp(_createdAt),
      'updated_at': FirestoreDateAdapter.toTimestamp(_updatedAt),
    };
  }

  /// Returns a copy of this EnergyModel with updated fields.
  EnergyModel copyWith({
    String? id,
    String? userId,
    int? energyLevel,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EnergyModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      energyLevel: energyLevel ?? this.energyLevel,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}