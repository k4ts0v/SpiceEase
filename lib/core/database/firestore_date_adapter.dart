import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDateAdapter {
  /// Converts a DateTime to a Firestore Timestamp.
  static Timestamp toTimestamp(DateTime dateTime) => Timestamp.fromDate(dateTime);

  /// Converts a Firestore Timestamp or ISO string to DateTime.
  /// static DateTime fromFirestore(dynamic timestamp) {
  static DateTime? fromFirestore(dynamic value) {
    if (value == null) return null; // Default date if null
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return null; // Default date if parsing fails
  }
}