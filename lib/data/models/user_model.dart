/*
 * File: userModel.dart
 * Project: k4ts0v
 * File Created: Wednesday, 16th April 2025 8:12:00 PM
 * Author: Lucas Villa (k4ts0v@protonmail.com)
 * -----
 * Last Modified: Wednesday, 16th April 2025 8:12:01 PM
 * Modified By: Lucas Villa (k4ts0v@protonmail.com)
 */

import 'package:cloud_firestore/cloud_firestore.dart';

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
  set username(String newUsername) {
    if (newUsername.isNotEmpty && newUsername.length >= 3) {
      _username = newUsername;
    } else {
      throw Exception("Username cannot be empty.");
    }
  }

  set level(int newLevel) {
    _level = newLevel;
  }

  set xp(int newXp) {
    _xp = newXp;
  }

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

  // Factory constructor for converting Firestore documents into UserModel objects
  factory UserModel.fromFirestore(DocumentSnapshot docSnap) {
    final data = docSnap.data() as Map<String, dynamic>;
    return UserModel(
      id: docSnap.id, // Firestore document ID
      username: data['username'], // Field mapping
      level: data['level'] ?? 1, // Null check with default
      xp: data['xp'] ?? 0, // Null check with default
      createdAt:
          (data['created_at'] as Timestamp).toDate(), // Timestamp to DateTime
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }

  // Convert Dart object to Firestore-compatible Map
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'level': level,
      'xp': xp,
      // Convert DateTime to Firestore Timestamp
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
