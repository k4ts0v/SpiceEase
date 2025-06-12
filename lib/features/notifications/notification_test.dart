// import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
// import 'package:spiceease/data/models/notification_model.dart';
// import 'package:spiceease/data/services/notification_service.dart';

// class NotificationTester {
//   final NotificationService _notificationService;
//   final _uuid = const Uuid();

//   NotificationTester(this._notificationService);

//   /// Test an immediate notification with the given priority
//   Future<void> testImmediateNotification(NotificationPriority priority) async {
//     final notification = AppNotification(
//       id: _uuid.v4(),
//       title: 'Test ${_getPriorityName(priority)} Priority',
//       body: 'This is a test notification with ${_getPriorityName(priority)} priority',
//       priority: priority,
//       type: NotificationType.system,
//       createdAt: DateTime.now(),
//       isRead: false,
//     );

//     await _notificationService.scheduleNotification(
//       notification: notification,
//       checkContext: false, // Bypass context rules for testing
//     );
//   }

//   /// Test a scheduled notification to appear after the specified delay
//   Future<void> testScheduledNotification(
//     NotificationPriority priority,
//     Duration delay,
//   ) async {
//     final scheduledTime = DateTime.now().add(delay);

//     final notification = AppNotification(
//       id: _uuid.v4(),
//       title: 'Scheduled ${_getPriorityName(priority)} Priority',
//       body: 'This notification was scheduled to appear ${delay.inSeconds} seconds after creation',
//       priority: priority,
//       type: NotificationType.system,
//       createdAt: DateTime.now(),
//       scheduledFor: scheduledTime,
//       isRead: false,
//     );

//     await _notificationService.scheduleNotification(
//       notification: notification,
//       checkContext: false, // Bypass context rules for testing
//     );
//   }

//   /// Test a persistent notification
//   Future<void> testPersistentNotification(NotificationPriority priority) async {
//     final notification = AppNotification(
//       id: _uuid.v4(),
//       title: 'Persistent ${_getPriorityName(priority)} Priority',
//       body: 'This is a persistent notification that will stay in history',
//       priority: priority,
//       type: NotificationType.system,
//       createdAt: DateTime.now(),
//       isRead: false,
//       isPersistent: true,
//     );

//     await _notificationService.scheduleNotification(
//       notification: notification,
//       checkContext: false,
//     );
//   }

//   /// Test a notification with context rules
//   Future<void> testContextAwareNotification(
//     NotificationPriority priority, {
//     int? minEnergy,
//     int? maxSymptomLevel,
//   }) async {
//     final contextRule = ContextRule(
//       minEnergyLevel: minEnergy,
//       maxSymptomSeverity: maxSymptomLevel,
//       skipWhenFocused: true,
//     );

//     final notification = AppNotification(
//       id: _uuid.v4(),
//       title: 'Context-Aware Notification',
//       body: 'This notification has context rules: min energy ${minEnergy ?? "none"}, '
//            'max symptoms ${maxSymptomLevel ?? "none"}',
//       priority: priority,
//       type: NotificationType.system,
//       createdAt: DateTime.now(),
//       isRead: false,
//       contextRule: contextRule,
//     );

//     await _notificationService.scheduleNotification(
//       notification: notification,
//       checkContext: true, // Enable context rules
//     );
//   }

//   /// Test notifications for all priorities at once
//   Future<void> testAllPriorities() async {
//     for (final priority in NotificationPriority.values) {
//       await testImmediateNotification(priority);
//       await Future.delayed(const Duration(milliseconds: 300)); // Small delay between notifications
//     }
//   }

//   /// Helper method to get priority name
//   String _getPriorityName(NotificationPriority priority) {
//     switch (priority) {
//       case NotificationPriority.low:
//         return 'Low';
//       case NotificationPriority.medium:
//         return 'Medium';
//       case NotificationPriority.high:
//         return 'High';
//       case NotificationPriority.critical:
//         return 'Critical';
//     }
//   }
// }