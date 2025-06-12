// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:spiceease/data/services/notification_service.dart';
// import 'package:spiceease/data/models/notification_model.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import '../../../l10n/app_localizations.dart';

// class NotificationHistoryScreen extends ConsumerStatefulWidget {
//   const NotificationHistoryScreen({Key? key}) : super(key: key);

//   @override
//   ConsumerState<NotificationHistoryScreen> createState() => _NotificationHistoryScreenState();
// }

// class _NotificationHistoryScreenState extends ConsumerState<NotificationHistoryScreen> {
//   late Future<List<AppNotification>> _notificationsFuture;

//   @override
//   void initState() {
//     super.initState();
//     _loadNotifications();
//   }

//   void _loadNotifications() {
//     final service = ref.read(notificationServiceProvider);
//     _notificationsFuture = service.getNotificationHistory();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final localizations = AppLocalizations.of(context)!;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           localizations.notificationHistory,
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.5,
//             color: theme.colorScheme.onSurface,
//           ),
//         ),
//         elevation: 0,
//         backgroundColor: theme.colorScheme.surface,
//         foregroundColor: theme.colorScheme.onSurface,
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           setState(() {
//             _loadNotifications();
//           });
//         },
//         child: FutureBuilder<List<AppNotification>>(
//           future: _notificationsFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             if (snapshot.hasError) {
//               return Center(
//                 child: Text(
//                   '${localizations.errorLoadingNotifications}: ${snapshot.error}',
//                   textAlign: TextAlign.center,
//                 ),
//               );
//             }

//             final notifications = snapshot.data ?? [];

//             if (notifications.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.notifications_off,
//                       size: 64,
//                       color: theme.colorScheme.onSurface.withOpacity(0.5),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       localizations.noNotificationsYet,
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         color: theme.colorScheme.onSurface.withOpacity(0.7),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             // Group notifications by day
//             final groupedNotifications = <String, List<AppNotification>>{};
//             for (final notification in notifications) {
//               final date = DateTime(
//                 notification.createdAt.year,
//                 notification.createdAt.month,
//                 notification.createdAt.day,
//               );
//               final dateKey = date.toIso8601String();

//               if (!groupedNotifications.containsKey(dateKey)) {
//                 groupedNotifications[dateKey] = [];
//               }

//               groupedNotifications[dateKey]!.add(notification);
//             }

//             final sortedDates = groupedNotifications.keys.toList()
//               ..sort((a, b) => b.compareTo(a)); // Sort dates newest first

//             return ListView.builder(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               itemCount: sortedDates.length,
//               itemBuilder: (context, index) {
//                 final dateKey = sortedDates[index];
//                 final date = DateTime.parse(dateKey);
//                 final dateNotifications = groupedNotifications[dateKey]!;

//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       child: Text(
//                         _formatDate(date, context),
//                         style: theme.textTheme.titleSmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: theme.colorScheme.onSurface.withOpacity(0.7),
//                         ),
//                       ),
//                     ),
//                     ...dateNotifications.map((notification) {
//                       return _buildNotificationTile(notification, theme);
//                     }),
//                     const Divider(),
//                   ],
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }

//   String _formatDate(DateTime date, BuildContext context) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = DateTime(now.year, now.month, now.day - 1);

//     if (date.year == today.year && date.month == today.month && date.day == today.day) {
//       return AppLocalizations.of(context)!.today;
//     } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
//       return AppLocalizations.of(context)!.yesterday;
//     } else {
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }

//   Widget _buildNotificationTile(AppNotification notification, ThemeData theme) {
//     final service = ref.read(notificationServiceProvider);

//     // Define colors for different priority levels
//     Color priorityColor;
//     switch (notification.priority) {
//       case NotificationPriority.low:
//         priorityColor = Colors.grey;
//         break;
//       case NotificationPriority.medium:
//         priorityColor = Colors.blue;
//         break;
//       case NotificationPriority.high:
//         priorityColor = Colors.orange;
//         break;
//       case NotificationPriority.critical:
//         priorityColor = Colors.red;
//         break;
//     }

//     return Dismissible(
//       key: Key(notification.id),
//       background: Container(
//         color: theme.colorScheme.error,
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.only(right: 16),
//         child: const Icon(
//           Icons.delete,
//           color: Colors.white,
//         ),
//       ),
//       direction: DismissDirection.endToStart,
//       onDismissed: (_) {
//         service.cancelNotification(notification.id);
//       },
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: priorityColor.withOpacity(0.2),
//           child: Icon(
//             _getIconForType(notification.type),
//             color: priorityColor,
//             size: 20,
//           ),
//         ),
//         title: Text(
//           notification.title,
//           style: TextStyle(
//             fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(notification.body),
//             const SizedBox(height: 4),
//             Text(
//               timeago.format(notification.createdAt),
//               style: theme.textTheme.bodySmall?.copyWith(
//                 color: theme.colorScheme.onSurface.withOpacity(0.6),
//               ),
//             ),
//           ],
//         ),
//         isThreeLine: true,
//         onTap: () {
//           // Mark as read
//           service.markAsRead(notification.id);

//           // Perform action if available
//           if (notification.actionData != null) {
//             // Handle navigation or other actions
//           }
//         },
//       ),
//     );
//   }

//   IconData _getIconForType(NotificationType type) {
//     switch (type) {
//       case NotificationType.task:
//         return Icons.task_alt;
//       case NotificationType.habit:
//         return Icons.repeat;
//       case NotificationType.medication:
//         return Icons.medication;
//       case NotificationType.appointment:
//         return Icons.calendar_today;
//       case NotificationType.symptom:
//         return Icons.healing;
//       case NotificationType.energy:
//         return Icons.battery_charging_full;
//       case NotificationType.system:
//         return Icons.notifications;
//     }
//   }
// }