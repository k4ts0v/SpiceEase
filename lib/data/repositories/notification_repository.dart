import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/notification_model.dart';

abstract class NotificationRepository {
  Future<void> saveNotification(AppNotification notification);
  Future<AppNotification?> getNotification(String id);
  Future<List<AppNotification>> getNotificationHistory();
  Future<List<AppNotification>> getPendingNotifications();
  Future<void> updateNotification(AppNotification notification);
  Future<void> deleteNotification(String id);
  Future<void> markAllAsRead();
  Future<int> getUnreadCount();
  String generateId();
  Future<String> getCurrentUserId();
}

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotificationRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<String> getCurrentUserId() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  @override
  String generateId() {
    return _firestore.collection('notifications').doc().id;
  }

  @override
  Future<void> saveNotification(AppNotification notification) async {
    try {
      final userId = await getCurrentUserId();
      final notificationData = notification.toMap();
      notificationData['user_id'] = userId;

      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notificationData);

      debugPrint('✅ Notification saved to repository: ${notification.id}');
    } catch (e) {
      debugPrint('❌ Error saving notification: $e');
      rethrow;
    }
  }

  @override
  Future<AppNotification?> getNotification(String id) async {
    try {
      final userId = await getCurrentUserId();
      final doc = await _firestore.collection('notifications').doc(id).get();

      if (!doc.exists) {
        debugPrint('📭 Notification not found: $id');
        return null;
      }

      final data = doc.data()!;

      // Verify this notification belongs to the current user
      if (data['user_id'] != userId) {
        debugPrint('❌ Notification access denied: $id');
        return null;
      }

      return AppNotification.fromMap(data, doc.id);
    } catch (e) {
      debugPrint('❌ Error getting notification: $e');
      return null;
    }
  }

  @override
  Future<List<AppNotification>> getNotificationHistory() async {
    try {
      final userId = await getCurrentUserId();
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .limit(100) // Limit to last 100 notifications
          .get();

      return querySnapshot.docs
          .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting notification history: $e');
      return [];
    }
  }

  @override
  Future<List<AppNotification>> getPendingNotifications() async {
    try {
      final userId = await getCurrentUserId();
      final now = DateTime.now();

      final querySnapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .where('scheduled_for', isGreaterThan: Timestamp.fromDate(now))
          .where('is_read', isEqualTo: false)
          .get();

      final notifications = querySnapshot.docs
          .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
          .toList();

      debugPrint('📋 Found ${notifications.length} pending notifications');
      return notifications;
    } catch (e) {
      debugPrint('❌ Error getting pending notifications: $e');
      return [];
    }
  }

  @override
  Future<void> updateNotification(AppNotification notification) async {
    try {
      final userId = await getCurrentUserId();
      final notificationData = notification.toMap();
      notificationData['user_id'] = userId;
      notificationData['updated_at'] = Timestamp.now();

      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .update(notificationData);

      debugPrint('✅ Notification updated: ${notification.id}');
    } catch (e) {
      debugPrint('❌ Error updating notification: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {

      // First verify the notification belongs to the current user
      final notification = await getNotification(id);
      if (notification == null) {
        debugPrint('📭 Notification not found for deletion: $id');
        return;
      }

      await _firestore.collection('notifications').doc(id).delete();

      debugPrint('🗑️ Notification deleted: $id');
    } catch (e) {
      debugPrint('❌ Error deleting notification: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final userId = await getCurrentUserId();
      final batch = _firestore.batch();

      final querySnapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .where('is_read', isEqualTo: false)
          .get();

      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'is_read': true,
          'updated_at': Timestamp.now(),
        });
      }

      await batch.commit();
      debugPrint('✅ Marked ${querySnapshot.docs.length} notifications as read');
    } catch (e) {
      debugPrint('❌ Error marking notifications as read: $e');
      rethrow;
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final userId = await getCurrentUserId();
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .where('is_read', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      debugPrint('❌ Error getting unread count: $e');
      return 0;
    }
  }

  // Helper method to clean up old notifications
  Future<void> cleanupOldNotifications({int daysToKeep = 30}) async {
    try {
      final userId = await getCurrentUserId();
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      final querySnapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .where('created_at', isLessThan: Timestamp.fromDate(cutoffDate))
          .where('is_persistent',
              isEqualTo: false) // Don't delete persistent notifications
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('🧹 Cleaned up ${querySnapshot.docs.length} old notifications');
    } catch (e) {
      debugPrint('❌ Error cleaning up old notifications: $e');
    }
  }

  // Helper method to get notifications by type
  Future<List<AppNotification>> getNotificationsByType(
      NotificationType type) async {
    try {
      final userId = await getCurrentUserId();
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .where('type', isEqualTo: type.toString().split('.').last)
          .orderBy('created_at', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting notifications by type: $e');
      return [];
    }
  }

  // Helper method to get notifications by priority
  Future<List<AppNotification>> getNotificationsByPriority(
      NotificationPriority priority) async {
    try {
      final userId = await getCurrentUserId();
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .where('priority', isEqualTo: priority.toString().split('.').last)
          .orderBy('created_at', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting notifications by priority: $e');
      return [];
    }
  }

  // Helper method to get recent notifications
  Future<List<AppNotification>> getRecentNotifications({int limit = 20}) async {
    try {
      final userId = await getCurrentUserId();
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting recent notifications: $e');
      return [];
    }
  }

  // Helper method to search notifications
  Future<List<AppNotification>> searchNotifications(String query) async {
    try {
      final userId = await getCurrentUserId();

      // Note: Firestore doesn't support full-text search, so we'll do a simple contains search
      // For better search functionality, consider using Algolia or similar service
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      final allNotifications = querySnapshot.docs
          .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
          .toList();

      // Filter locally for now
      final filteredNotifications = allNotifications.where((notification) {
        final searchTerm = query.toLowerCase();
        return notification.title.toLowerCase().contains(searchTerm) ||
            notification.body.toLowerCase().contains(searchTerm);
      }).toList();

      return filteredNotifications;
    } catch (e) {
      debugPrint('❌ Error searching notifications: $e');
      return [];
    }
  }
}

// Provider for the notification repository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl();
});
