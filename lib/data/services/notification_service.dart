// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:spiceease/data/models/habit_model.dart';
// import 'package:spiceease/data/models/medication_model.dart';
// import 'package:spiceease/data/models/notification_model.dart';
// import 'package:spiceease/data/models/task_model.dart';
// import 'package:spiceease/data/providers/app_active_state_provider.dart';
// import 'package:spiceease/data/providers/energy_provider.dart';
// import 'package:spiceease/data/providers/focus_mode_provider.dart';
// import 'package:spiceease/data/providers/symptom_provider.dart';
// import 'package:spiceease/data/repositories/notification_repository.dart';
// import '../providers/notification_settings_provider.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class NotificationService {
//   final NotificationRepository _repository;
//   final Ref _ref;
//   final FlutterLocalNotificationsPlugin _notifications;
//   final BehaviorSubject<AppNotification?> _onNotificationClick;

//   NotificationService(this._repository, this._ref)
//       : _notifications = FlutterLocalNotificationsPlugin(),
//         _onNotificationClick = BehaviorSubject<AppNotification?>();

//   Stream<AppNotification?> get onNotificationClick => _onNotificationClick.stream;

//   // =============================================================================
//   // INITIALIZATION
//   // =============================================================================

//   Future<void> initialize() async {
//     print('🔔 Initializing notification service...');

//     await _initializeTimezone();
//     await _initializePlugin();
//     await _requestPermissions();
//     await _createChannels();

//     print('✅ Notification service initialized');
//   }

//   Future<void> _initializeTimezone() async {
//     tz.initializeTimeZones();

//     String timezoneName = 'Europe/Madrid';
//     try {
//       if (Platform.isAndroid) {
//         final process = await Process.run('getprop', ['persist.sys.timezone']);
//         if (process.exitCode == 0 && process.stdout.toString().trim().isNotEmpty) {
//           timezoneName = process.stdout.toString().trim();
//         }
//       }
//       tz.setLocalLocation(tz.getLocation(timezoneName));
//       print('📍 Timezone set: ${tz.local.name}');
//     } catch (e) {
//       tz.setLocalLocation(tz.getLocation('Europe/Madrid'));
//       print('❌ Timezone fallback: $e');
//     }
//   }

//   Future<void> _initializePlugin() async {
//     const android = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const ios = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//       requestCriticalPermission: true,
//     );

//     await _notifications.initialize(
//       const InitializationSettings(android: android, iOS: ios),
//       onDidReceiveNotificationResponse: _onNotificationResponse,
//       onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationResponse,
//     );
//   }

//   Future<void> _requestPermissions() async {
//     if (Platform.isAndroid) {
//       final android = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
//       if (android != null) {
//         await android.requestNotificationsPermission();
//         await android.requestExactAlarmsPermission();
//       }
//       await _requestBatteryOptimization();
//     } else if (Platform.isIOS) {
//       final ios = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
//       await ios?.requestPermissions(alert: true, badge: true, sound: true, critical: true);
//     }
//   }

//   Future<void> _requestBatteryOptimization() async {
//     try {
//       final status = await Permission.ignoreBatteryOptimizations.status;
//       if (status.isDenied) {
//         await Permission.ignoreBatteryOptimizations.request();
//       }
//     } catch (e) {
//       print('❌ Battery optimization error: $e');
//     }
//   }

//   Future<void> _createChannels() async {
//     if (!Platform.isAndroid) return;

//     final android = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
//     if (android == null) return;

//     final channels = [
//       const AndroidNotificationChannel('low', 'Low Priority', importance: Importance.low),
//       const AndroidNotificationChannel('medium', 'Medium Priority', importance: Importance.defaultImportance),
//       const AndroidNotificationChannel('high', 'High Priority', importance: Importance.high),
//       const AndroidNotificationChannel('critical', 'Critical', importance: Importance.max),
//       const AndroidNotificationChannel('test', 'Test', importance: Importance.max),
//     ];

//     for (final channel in channels) {
//       await android.createNotificationChannel(channel);
//     }
//   }

//   // =============================================================================
//   // CORE NOTIFICATION METHODS
//   // =============================================================================

//   Future<void> scheduleNotification({
//     required AppNotification notification,
//     bool checkContext = true,
//   }) async {
//     print('📅 Scheduling: ${notification.title}');

//     // Save to repository
//     await _repository.saveNotification(notification);

//     // Check context for immediate notifications
//     if (checkContext && notification.scheduledFor == null) {
//       if (!await _shouldShowNotification(notification)) {
//         print('❌ Blocked by context rules');
//         return;
//       }
//     }

//     // Schedule or show immediately
//     if (notification.scheduledFor != null) {
//       await _scheduleForLater(notification);
//     } else {
//       await _showNow(notification);
//     }
//   }

//   Future<void> _scheduleForLater(AppNotification notification) async {
//     final scheduledDate = tz.TZDateTime.from(notification.scheduledFor!, tz.local);

//     await _notifications.zonedSchedule(
//       notification.id.hashCode,
//       notification.title,
//       notification.body,
//       scheduledDate,
//       _getNotificationDetails(notification),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
//       payload: notification.id,
//     );

//     print('✅ Scheduled for: $scheduledDate');
//   }

//   Future<void> _showNow(AppNotification notification) async {
//     await _notifications.show(
//       notification.id.hashCode,
//       notification.title,
//       notification.body,
//       _getNotificationDetails(notification),
//       payload: notification.id,
//     );

//     print('✅ Shown immediately');
//   }

//   NotificationDetails _getNotificationDetails(AppNotification notification) {
//     final settings = _ref.read(notificationSettingsProvider);

//     final channelId = notification.priority.name;
//     final importance = _getImportance(notification.priority);
//     final priority = _getPriority(notification.priority);

//     final android = AndroidNotificationDetails(
//       channelId,
//       '${notification.priority.name.toUpperCase()} Priority',
//       importance: importance,
//       priority: priority,
//       playSound: settings.soundEnabled,
//       enableVibration: settings.vibrationEnabled,
//       vibrationPattern: settings.vibrationEnabled ? Int64List.fromList([0, 500, 250, 500]) : null,
//       autoCancel: notification.priority != NotificationPriority.critical,
//       ongoing: notification.priority == NotificationPriority.critical,
//       fullScreenIntent: notification.priority == NotificationPriority.critical,
//       visibility: NotificationVisibility.public,
//     );

//     const ios = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//       interruptionLevel: InterruptionLevel.active,
//     );

//     return NotificationDetails(android: android, iOS: ios);
//   }

//   Importance _getImportance(NotificationPriority priority) {
//     switch (priority) {
//       case NotificationPriority.low: return Importance.low;
//       case NotificationPriority.medium: return Importance.defaultImportance;
//       case NotificationPriority.high: return Importance.high;
//       case NotificationPriority.critical: return Importance.max;
//     }
//   }

//   Priority _getPriority(NotificationPriority priority) {
//     switch (priority) {
//       case NotificationPriority.low: return Priority.low;
//       case NotificationPriority.medium: return Priority.defaultPriority;
//       case NotificationPriority.high: return Priority.high;
//       case NotificationPriority.critical: return Priority.max;
//     }
//   }

//   // =============================================================================
//   // CONTEXT EVALUATION
//   // =============================================================================

//   Future<bool> _shouldShowNotification(AppNotification notification) async {
//     try {
//       final settings = _ref.read(notificationSettingsProvider);

//       // Always show critical if setting enabled
//       if (notification.priority == NotificationPriority.critical && settings.alwaysShowCritical) {
//         return true;
//       }

//       // Check energy level
//       final currentEnergy = await _getCurrentEnergy();
//       if (currentEnergy <= settings.lowEnergyThreshold &&
//           notification.priority.index < NotificationPriority.high.index) {
//         print('❌ Blocked: Low energy ($currentEnergy <= ${settings.lowEnergyThreshold})');
//         return false;
//       }

//       // Check symptoms
//       final symptomImpact = await _getSymptomImpact();
//       if (symptomImpact.shouldBlockNotifications &&
//           notification.priority != NotificationPriority.critical) {
//         print('❌ Blocked: High symptom severity');
//         return false;
//       }

//       // Check custom context rule
//       if (notification.contextRule != null) {
//         return _evaluateContextRule(notification.contextRule!, currentEnergy, symptomImpact.maxSeverity);
//       }

//       return true;
//     } catch (e) {
//       print('❌ Context evaluation error: $e');
//       return true; // Default to showing notification
//     }
//   }

//   bool _evaluateContextRule(ContextRule rule, int energy, int maxSymptoms) {
//     final now = TimeOfDay.now();
//     final isInFocusMode = _ref.read(focusModeActiveProvider);
//     final isAppActive = _ref.read(appActiveStateProvider);

//     return rule.shouldShowForContext(
//       currentEnergy: energy,
//       currentSymptomLevel: maxSymptoms,
//       currentTime: now,
//       isInFocusMode: isInFocusMode,
//       isAppActive: isAppActive,
//     );
//   }

//   Future<int> _getCurrentEnergy() async {
//     final today = DateTime.now();
//     final todayDate = DateTime(today.year, today.month, today.day);
//     final energyData = _ref.read(energyStateNotifierProvider(todayDate));
//     return energyData.isNotEmpty ? energyData.last.energyLevel : 5;
//   }

//   Future<SymptomImpact> _getSymptomImpact() async {
//     final today = DateTime.now();
//     final todayDate = DateTime(today.year, today.month, today.day);
//     final symptoms = _ref.read(symptomStateNotifierProvider(todayDate));

//     if (symptoms.isEmpty) {
//       return const SymptomImpact(maxSeverity: 0, totalSymptoms: 0, shouldBlockNotifications: false);
//     }

//     final severities = symptoms.map((s) => s.severity.clamp(1, 10)).toList();
//     final maxSeverity = severities.reduce((a, b) => a > b ? a : b);
//     final avgSeverity = severities.reduce((a, b) => a + b) / severities.length;

//     // Block if: severe symptom (8-10), or 2+ moderate (6+), or 3+ with avg ≥5
//     final shouldBlock = maxSeverity >= 8 ||
//                        severities.where((s) => s >= 6).length >= 2 ||
//                        (severities.length >= 3 && avgSeverity >= 5);

//     return SymptomImpact(
//       maxSeverity: maxSeverity,
//       totalSymptoms: severities.length,
//       shouldBlockNotifications: shouldBlock,
//       averageSeverity: avgSeverity,
//     );
//   }

//   // =============================================================================
//   // REMINDER SCHEDULING
//   // =============================================================================

//   Future<void> scheduleCategoryReminders() async {
//     try {
//       final settings = _ref.read(notificationSettingsProvider);

//       if (!settings.notificationsEnabled || !settings.loggingRemindersEnabled) {
//         await _cancelCategoryReminders();
//         return;
//       }

//       await _cancelCategoryReminders();

//       for (final category in settings.enabledCategories) {
//         if (_supportedCategories.contains(category) &&
//             settings.categoryReminderTimes.containsKey(category) &&
//             settings.categoryReminderDays.containsKey(category)) {
//           await _scheduleCategoryReminder(category, settings);
//         }
//       }

//       print('✅ Category reminders scheduled');
//     } catch (e) {
//       print('❌ Category reminder error: $e');
//     }
//   }

//   static const _supportedCategories = ['task', 'habit', 'medication', 'symptom', 'energy'];

//   Future<void> _scheduleCategoryReminder(String category, NotificationSettings settings) async {
//     final reminderTime = settings.categoryReminderTimes[category]!;
//     final reminderDays = settings.categoryReminderDays[category]!;

//     for (final dayOfWeek in reminderDays) {
//       final notificationId = '${category}_reminder_$dayOfWeek'.hashCode;
//       final scheduledDate = _getNextReminderDate(dayOfWeek, reminderTime);
//       final notification = _createCategoryNotification(category, scheduledDate);

//       await _notifications.zonedSchedule(
//         notificationId,
//         notification.title,
//         notification.body,
//         scheduledDate,
//         _getNotificationDetails(notification),
//         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//         uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
//         matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
//       );
//     }
//   }

//   tz.TZDateTime _getNextReminderDate(int dayOfWeek, TimeOfDay time) {
//     final now = tz.TZDateTime.now(tz.local);
//     final daysUntilTarget = ((dayOfWeek - now.weekday) % 7);

//     var targetDate = now.add(Duration(days: daysUntilTarget));

//     // If it's today but time has passed, schedule for next week
//     if (daysUntilTarget == 0) {
//       final nowTime = TimeOfDay.now();
//       if (nowTime.hour > time.hour || (nowTime.hour == time.hour && nowTime.minute >= time.minute)) {
//         targetDate = targetDate.add(const Duration(days: 7));
//       }
//     }

//     return tz.TZDateTime(tz.local, targetDate.year, targetDate.month, targetDate.day, time.hour, time.minute);
//   }

//   AppNotification _createCategoryNotification(String category, tz.TZDateTime scheduledDate) {
//     final content = _getCategoryContent(category);

//     return AppNotification(
//       id: '${category}_reminder_${scheduledDate.millisecondsSinceEpoch}',
//       title: content['title']!,
//       body: content['body']!,
//       priority: NotificationPriority.medium,
//       type: _getCategoryType(category),
//       createdAt: DateTime.now(),
//       scheduledFor: scheduledDate.toLocal(),
//       actionData: {'category': category, 'action': 'reminder'},
//       contextRule: const ContextRule(minEnergyLevel: 2, maxSymptomSeverity: 8, skipWhenFocused: true),
//     );
//   }

//   Map<String, String> _getCategoryContent(String category) {
//     const content = {
//       'task': {'title': 'Task Reminder', 'body': 'Time to review your pending tasks!'},
//       'habit': {'title': 'Habit Check-in', 'body': 'How are your habits going today?'},
//       'medication': {'title': 'Medication Reminder', 'body': 'Don\'t forget your medications today.'},
//       'symptom': {'title': 'Symptom Tracking', 'body': 'Log any symptoms you\'re experiencing.'},
//       'energy': {'title': 'Energy Level Check', 'body': 'How are your energy levels today?'},
//     };
//     return content[category] ?? {'title': 'Daily Reminder', 'body': 'Time for your daily check-in!'};
//   }

//   NotificationType _getCategoryType(String category) {
//     switch (category) {
//       case 'task': return NotificationType.task;
//       case 'habit': return NotificationType.habit;
//       case 'medication': return NotificationType.medication;
//       case 'symptom': return NotificationType.symptom;
//       case 'energy': return NotificationType.energy;
//       default: return NotificationType.system;
//     }
//   }

//   Future<void> _cancelCategoryReminders() async {
//     for (final category in _supportedCategories) {
//       for (int day = 1; day <= 7; day++) {
//         await _notifications.cancel('${category}_reminder_$day'.hashCode);
//       }
//     }
//   }

//   // =============================================================================
//   // SPECIFIC ITEM REMINDERS
//   // =============================================================================

//   Future<void> scheduleTaskReminder(TaskModel task) async {
//     final settings = _ref.read(notificationSettingsProvider);

//     if (!_canScheduleSpecific('task', settings) || !task.hasReminder || task.reminderDateTime == null) {
//       return;
//     }

//     final notification = AppNotification(
//       id: 'task_${task.id}_reminder',
//       title: 'Task Reminder',
//       body: 'Don\'t forget: ${task.title}',
//       priority: _getTaskPriority(task.priority),
//       type: NotificationType.task,
//       createdAt: DateTime.now(),
//       scheduledFor: task.reminderDateTime,
//       actionData: {'taskId': task.id, 'action': 'task_reminder'},
//       contextRule: const ContextRule(minEnergyLevel: 3, maxSymptomSeverity: 7),
//     );

//     await scheduleNotification(notification: notification);
//   }

//   // Future<void> scheduleHabitReminder(HabitModel habit) async {
//   //   final settings = _ref.read(notificationSettingsProvider);

//   //   if (!_canScheduleSpecific('habit', settings) || !habit.hasReminder ||
//   //       habit.reminderTime == null || habit.reminderDaysOfWeek == null) {
//   //     return;
//   //   }

//   //   for (final dayOfWeek in habit.reminderDaysOfWeek!) {
//   //     final scheduledDate = _getNextReminderDate(dayOfWeek, habit.reminderTime!);

//   //     final notification = AppNotification(
//   //       id: 'habit_${habit.id}_reminder_$dayOfWeek',
//   //       title: 'Habit Reminder',
//   //       body: 'Time for your habit: ${habit.title}',
//   //       priority: NotificationPriority.medium,
//   //       type: NotificationType.habit,
//   //       createdAt: DateTime.now(),
//   //       scheduledFor: scheduledDate.toLocal(),
//   //       actionData: {'habitId': habit.id, 'action': 'habit_reminder'},
//   //       contextRule: const ContextRule(minEnergyLevel: 2, maxSymptomSeverity: 8),
//   //     );

//   //     await scheduleNotification(notification: notification);
//   //   }
//   // }

//   // Future<void> scheduleMedicationReminder(MedicationModel medication) async {
//   //   final settings = _ref.read(notificationSettingsProvider);

//   //   if (!_canScheduleSpecific('medication', settings) || !medication.hasReminder ||
//   //       medication.reminderTimes?.isEmpty == true || medication.reminderDaysOfWeek?.isEmpty == true) {
//   //     return;
//   //   }

//   //   for (final dayOfWeek in medication.reminderDaysOfWeek!) {
//   //     for (int i = 0; i < medication.reminderTimes!.length; i++) {
//   //       final reminderTime = medication.reminderTimes![i];
//   //       final scheduledDate = _getNextReminderDate(dayOfWeek, reminderTime);

//   //       final notification = AppNotification(
//   //         id: 'medication_${medication.id}_reminder_${dayOfWeek}_$i',
//   //         title: 'Medication Reminder',
//   //         body: 'Time to take: ${medication.name} (${medication.dose} ${medication.unit})',
//   //         priority: NotificationPriority.high,
//   //         type: NotificationType.medication,
//   //         createdAt: DateTime.now(),
//   //         scheduledFor: scheduledDate.toLocal(),
//   //         actionData: {'medicationId': medication.id, 'action': 'medication_reminder'},
//   //         contextRule: const ContextRule(minEnergyLevel: 1, maxSymptomSeverity: 9),
//   //       );

//   //       await scheduleNotification(notification: notification);
//   //     }
//   //   }
//   // }

//   bool _canScheduleSpecific(String category, NotificationSettings settings) {
//     return settings.notificationsEnabled &&
//            settings.specificItemRemindersEnabled &&
//            (settings.enabledCategorySpecificReminders[category] ?? false);
//   }

//   NotificationPriority _getTaskPriority(int taskPriority) {
//     switch (taskPriority) {
//       case 0: case 1: return NotificationPriority.low;
//       case 2: return NotificationPriority.medium;
//       case 3: return NotificationPriority.high;
//       case 4: case 5: return NotificationPriority.critical;
//       default: return NotificationPriority.medium;
//     }
//   }

//   // =============================================================================
//   // UTILITY METHODS
//   // =============================================================================

//   Future<List<AppNotification>> getNotificationHistory() => _repository.getNotificationHistory();

//   Future<void> markAsRead(String id) async {
//     final notification = await _repository.getNotification(id);
//     if (notification != null) {
//       await _repository.updateNotification(notification.copyWith(isRead: true));
//     }
//   }

//   Future<void> cancelNotification(String id) async {
//     await _notifications.cancel(id.hashCode);
//     await _repository.deleteNotification(id);
//   }

//   Future<void> cancelAllNotifications() async {
//     await _notifications.cancelAll();
//   }

//   Future<void> rescheduleAllNotifications() async {
//     final pending = await _repository.getPendingNotifications();
//     await _notifications.cancelAll();

//     for (final notification in pending) {
//       if (notification.scheduledFor?.isAfter(DateTime.now()) == true) {
//         await scheduleNotification(notification: notification, checkContext: false);
//       }
//     }
//   }

//   Future<void> onSettingsChanged() async {
//     await scheduleCategoryReminders();
//   }

//   // =============================================================================
//   // EVENT HANDLERS
//   // =============================================================================

//   @pragma('vm:entry-point')
//   static void _onBackgroundNotificationResponse(NotificationResponse response) {
//     print('📱 Background notification: ${response.payload}');
//   }

//   void _onNotificationResponse(NotificationResponse response) {
//     print('📱 Foreground notification: ${response.payload}');
//     _repository.getNotification(response.id?.toString() ?? '').then((notification) {
//       if (notification != null) {
//         _onNotificationClick.add(notification);
//       }
//     });
//   }

//   // =============================================================================
//   // TEST METHODS
//   // =============================================================================

//   Future<void> testInstantNotification() async {
//     await _notifications.show(
//       999999,
//       'Test Notification',
//       'This is a test notification',
//       const NotificationDetails(
//         android: AndroidNotificationDetails('test', 'Test', importance: Importance.max),
//         iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
//       ),
//     );
//   }

//   Future<void> testContextEvaluation() async {
//     final energy = await _getCurrentEnergy();
//     final symptoms = await _getSymptomImpact();

//     print('📊 Current Energy: $energy/10');
//     print('📊 Symptom Impact: ${symptoms.maxSeverity}/10 max, ${symptoms.totalSymptoms} total');
//     print('📊 Should block: ${symptoms.shouldBlockNotifications}');

//     for (final priority in NotificationPriority.values) {
//       final notification = AppNotification(
//         id: 'test_${priority.name}',
//         title: 'Test ${priority.name.toUpperCase()}',
//         body: 'Testing context rules',
//         priority: priority,
//         type: NotificationType.system,
//         createdAt: DateTime.now(),
//         isRead: false,
//       );

//       final shouldShow = await _shouldShowNotification(notification);
//       print('${priority.name.toUpperCase().padRight(8)}: ${shouldShow ? "✅ ALLOW" : "❌ BLOCK"}');
//     }
//   }

//   Future<void> testImmediateNotificationWithContext(NotificationPriority priority) async {
//     final notification = AppNotification(
//       id: 'test_immediate_${DateTime.now().millisecondsSinceEpoch}',
//       title: 'Context-Aware ${priority.name.toUpperCase()} Test',
//       body: 'This notification respects your current context',
//       priority: priority,
//       type: NotificationType.system,
//       createdAt: DateTime.now(),
//       isRead: false,
//     );

//     await scheduleNotification(notification: notification, checkContext: true);
//   }

//   Future<void> scheduleDirectBackgroundTest({int seconds = 5}) async {
//     final scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(seconds: seconds));

//     await _notifications.zonedSchedule(
//       12345,
//       '🔥 BACKGROUND TEST',
//       'SUCCESS! Background notification works!',
//       scheduledTime,
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'test', 'Test',
//           importance: Importance.max,
//           priority: Priority.max,
//           fullScreenIntent: true,
//         ),
//         iOS: DarwinNotificationDetails(
//           presentAlert: true,
//           presentBadge: true,
//           presentSound: true,
//           interruptionLevel: InterruptionLevel.critical,
//         ),
//       ),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
//     );
//   }

//   Future<void> showInstantNotification({
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     await _notifications.show(
//       DateTime.now().millisecondsSinceEpoch.hashCode,
//       title,
//       body,
//       const NotificationDetails(
//         android: AndroidNotificationDetails('test', 'Test', importance: Importance.max),
//         iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
//       ),
//       payload: payload,
//     );
//   }
// }

// // =============================================================================
// // PROVIDERS
// // =============================================================================

// final notificationServiceProvider = Provider<NotificationService>((ref) {
//   final repository = ref.watch(notificationRepositoryProvider);
//   return NotificationService(repository, ref);
// });

// final notificationInitializationProvider = FutureProvider<void>((ref) async {
//   final service = ref.read(notificationServiceProvider);
//   await service.initialize();
// });