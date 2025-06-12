// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:spiceease/data/models/notification_model.dart';
// import 'package:spiceease/data/services/notification_service.dart';

// class NotificationDebugScreen extends ConsumerWidget {
//   const NotificationDebugScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notification Debug'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Test instant notification
//             ElevatedButton(
//               onPressed: () async {
//                 final notificationService =
//                     ref.read(notificationServiceProvider);
//                 await notificationService.testInstantNotification();

//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Instant notification sent!'),
//                     ),
//                   );
//                 }
//               },
//               child: const Text('Test Instant Notification'),
//             ),
//             const SizedBox(height: 16),

//             // Cancel all notifications
//             ElevatedButton(
//               onPressed: () async {
//                 try {
//                   final notificationService =
//                       ref.read(notificationServiceProvider);
//                   await notificationService.cancelAllNotifications();

//                   if (context.mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('All notifications cancelled'),
//                       ),
//                     );
//                   }
//                 } catch (e) {
//                   print('❌ Error cancelling notifications: $e');
//                 }
//               },
//               child: const Text('Cancel All Notifications'),
//             ),
//             const SizedBox(height: 20),

//             // MAIN TEST SECTION - FIX THE SCHEDULING ISSUE
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.red, width: 2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 children: [
//                   const Text(
//                     '🔥 CRITICAL BACKGROUND TEST',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.red,
//                       fontSize: 16,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'This schedules notification for 10 seconds later and minimizes app immediately.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 12),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () async {
//                       try {
//                         final notificationService =
//                             ref.read(notificationServiceProvider);

//                         // Schedule for FUTURE time (not immediate)
//                         final scheduledTime =
//                             DateTime.now().add(const Duration(seconds: 10));

//                         // Create test notification with FUTURE scheduling
//                         final testNotification = AppNotification(
//                           id: 'critical_test_${DateTime.now().millisecondsSinceEpoch}',
//                           title: '� CRITICAL BACKGROUND TEST',
//                           body:
//                               'This should appear in 10 seconds when app is closed!',
//                           type: NotificationType.habit,
//                           priority: NotificationPriority.high,
//                           createdAt: DateTime.now(),
//                         );

//                         print('🔥 SCHEDULING FOR: ${scheduledTime.toString()}');
//                         print('🔥 CURRENT TIME: ${DateTime.now().toString()}');

//                         await notificationService.scheduleNotification(
//                           notification: testNotification.copyWith(
//                               scheduledFor: scheduledTime),
//                         );

//                         if (context.mounted) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text(
//                                   '🔥 CRITICAL: Notification scheduled for ${scheduledTime.toString().substring(11, 19)}. Minimizing NOW!'),
//                               duration: const Duration(seconds: 2),
//                               backgroundColor: Colors.red,
//                             ),
//                           );

//                           // Minimize immediately - don't wait
//                           await Future.delayed(
//                               const Duration(milliseconds: 500));
//                           SystemChannels.platform
//                               .invokeMethod('SystemNavigator.pop');
//                         }
//                       } catch (e) {
//                         print('🔥 CRITICAL ERROR: $e');
//                         if (context.mounted) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text('🔥 CRITICAL ERROR: $e'),
//                               backgroundColor: Colors.red,
//                             ),
//                           );
//                         }
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       foregroundColor: Colors.white,
//                     ),
//                     child: const Text(
//                         '🔥 CRITICAL TEST - 10 Seconds + Minimize NOW'),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Better scheduling test
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 children: [
//                   const Text(
//                     '⏰ PROPER SCHEDULING TEST',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue,
//                       fontSize: 16,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'Schedule notification for 30 seconds in the future.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 12),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () async {
//                       try {
//                         final notificationService =
//                             ref.read(notificationServiceProvider);

//                         // Schedule for 30 seconds in the future
//                         final scheduledTime =
//                             DateTime.now().add(const Duration(seconds: 30));

//                         final testNotification = AppNotification(
//                           id: 'proper_test_${DateTime.now().millisecondsSinceEpoch}',
//                           title: '⏰ PROPER SCHEDULED TEST',
//                           body:
//                               'This notification was scheduled 30 seconds ago!',
//                           type: NotificationType.medication,
//                           priority: NotificationPriority.high,
//                           createdAt: DateTime.now(),
//                         );

//                         print(
//                             '⏰ PROPER SCHEDULING FOR: ${scheduledTime.toString()}');
//                         print('⏰ CURRENT TIME: ${DateTime.now().toString()}');
//                         print(
//                             '⏰ TIME DIFFERENCE: ${scheduledTime.difference(DateTime.now()).inSeconds} seconds');

//                         await notificationService.scheduleNotification(
//                           notification: testNotification.copyWith(
//                               scheduledFor: scheduledTime),
//                         );

//                         if (context.mounted) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text(
//                                   '⏰ Notification scheduled for ${scheduledTime.toString().substring(11, 19)} (30 seconds from now). Minimize the app manually!'),
//                               duration: const Duration(seconds: 5),
//                               backgroundColor: Colors.blue,
//                             ),
//                           );
//                         }
//                       } catch (e) {
//                         print('⏰ SCHEDULING ERROR: $e');
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       foregroundColor: Colors.white,
//                     ),
//                     child: const Text('⏰ Schedule for 30 Seconds Later'),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Manual test instructions
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.orange.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     '📱 MANUAL STEP-BY-STEP TEST:',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text('1. Tap "Schedule Test" button below'),
//                   const Text('2. Wait for "scheduled" message'),
//                   const Text('3. Immediately press HOME button'),
//                   const Text('4. Wait exactly 5 seconds'),
//                   const Text('5. Check if notification appears'),
//                   const Text('6. If no notification, there\'s a deeper issue'),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () async {
//                       try {
//                         final notificationService =
//                             ref.read(notificationServiceProvider);

//                         // Schedule for exactly 5 seconds
//                         final scheduledTime =
//                             DateTime.now().add(const Duration(seconds: 5));

//                         final testNotification = AppNotification(
//                           id: 'manual_step_test_${DateTime.now().millisecondsSinceEpoch}',
//                           title: '📱 MANUAL STEP TEST',
//                           body:
//                               'SUCCESS! Background notifications work perfectly!',
//                           type: NotificationType.habit,
//                           priority: NotificationPriority.high,
//                           createdAt: DateTime.now(),
//                         );

//                         print(
//                             '📱 MANUAL TEST SCHEDULED FOR: ${scheduledTime.toString()}');

//                         await notificationService.scheduleNotification(
//                           notification: testNotification.copyWith(
//                               scheduledFor: scheduledTime),
//                         );

//                         if (context.mounted) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text(
//                                   '📱 TEST SCHEDULED! Press HOME button NOW and count to 5!'),
//                               duration: Duration(seconds: 4),
//                               backgroundColor: Colors.orange,
//                             ),
//                           );
//                         }
//                       } catch (e) {
//                         print('📱 MANUAL TEST ERROR: $e');
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.orange,
//                       foregroundColor: Colors.white,
//                     ),
//                     child: const Text('📱 Schedule Test (5 seconds)'),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),

//             // System settings
//             const Text(
//               'System Settings:',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             const SizedBox(height: 12),

//             ElevatedButton(
//               onPressed: () async {
//                 final status =
//                     await Permission.ignoreBatteryOptimizations.status;
//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Battery optimization status: $status'),
//                     ),
//                   );
//                 }
//               },
//               child: const Text('Check Battery Optimization'),
//             ),
//             const SizedBox(height: 12),

//             ElevatedButton(
//               onPressed: () async {
//                 await openAppSettings();
//               },
//               child: const Text('Open App Settings'),
//             ),
//             const SizedBox(height: 20),
//           // ...existing code...

//           // Add this button to your debug screen
//           ElevatedButton(
//             onPressed: () async {
//               try {
//                 final notificationService = ref.read(notificationServiceProvider);

//                 // Schedule direct background test
//                 await notificationService.scheduleDirectBackgroundTest(seconds: 5);

//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('🔥 DIRECT test scheduled! Press HOME NOW and wait 5 seconds!'),
//                       duration: Duration(seconds: 3),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 }
//               } catch (e) {
//                 print('Error: $e');
//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Error: $e'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 }
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('🔥 DIRECT BACKGROUND TEST (5 sec)'),
//           ),          ],
//         ),
//       ),
//     );
//   }
// }
