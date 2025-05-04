class UserModel {
  // Private fields
  final String _id; // Immutable field (Document ID)
  String _username; // Mutable field with setter
  int _level; // Mutable field with setter
  int _xp; // Mutable field with setter
  final DateTime _createdAt; // Immutable field
  DateTime _updatedAt; // Mutable field

  // Getters for accessing private fields
  String get id => _id;
  String get username => _username;
  int get level => _level;
  int get xp => _xp;
  DateTime get createdAt => _createdAt;
  DateTime get updatedAt => _updatedAt;

  // Setters for mutable fields

  /// Sets the username to the provided username.
  set username(String newUsername) {
    if (newUsername.isNotEmpty && newUsername.length >= 3) {
      _username = newUsername;
    } else {
      throw Exception("Username cannot be empty.");
    }
  }

  /// Sets the level to the provided level.
  set level(int newLevel) {
    _level = newLevel;
  }

  /// Sets the xp to the provided xp.
  set xp(int newXp) {
    _xp = newXp;
  }

/// Sets the updatedAt field to the provided updatedAt.
  set updatedAt(DateTime newUpdatedAt) {
    _updatedAt = newUpdatedAt;
  }

  // Constructor
  UserModel({
    required String id,
    required String username,
    int level = 1,
    int xp = 0,
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : _id = id,
        _username = username,
        _level = level,
        _xp = xp,
        _createdAt = createdAt,
        _updatedAt = updatedAt;

  /// Factory constructor that constructs UserModel from generic key-value map structure
  /// 
  /// Handles:
  /// - Database-agnostic field mapping
  /// - Type-safe conversions
  /// - Default values for progression fields
  /// 
  /// [map]: Database record structure
  factory UserModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return UserModel(
      id: id ?? map['id'],
      username: map['username'], // Field mapping
      level: map['level'] ?? 1, // Null check with default
      xp: map['xp'] ?? 0, // Null check with default
      createdAt: (map['created_at']).toDateTime(),
      updatedAt: (map['updated_at']).toDateTime(),
    );
  }

  /// Serializes user data to database-agnostic map format
  ///
  /// Returns:
  /// - String keys using application-level naming conventions
  /// - Native Dart types for database compatibility
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'level': level,
      'xp': xp,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
