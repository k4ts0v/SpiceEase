// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:spiceease/data/services/notification_service.dart';

// class NotificationSettings {
//   final bool notificationsEnabled;
//   final bool soundEnabled;
//   final bool vibrationEnabled;
//   final int historyRetentionDays;
//   final Set<String> enabledCategories;
//   final bool alwaysShowCritical;
//   final int lowEnergyThreshold;
//   final int highSymptomThreshold;
//   final bool quietHoursEnabled;
//   final TimeOfDay quietHoursStart;
//   final TimeOfDay quietHoursEnd;
//   final bool loggingRemindersEnabled; // Master switch for category reminders
//   final Map<String, TimeOfDay> categoryReminderTimes;
//   final Map<String, List<int>> categoryReminderDays;

//   // Add specific item reminder settings
//   final bool specificItemRemindersEnabled;
//   final Map<String, bool>
//       enabledCategorySpecificReminders; // Which categories allow specific reminders

//   const NotificationSettings({
//     this.notificationsEnabled = true,
//     this.soundEnabled = true,
//     this.vibrationEnabled = true,
//     this.historyRetentionDays = 7,
//     this.enabledCategories = const {
//       'task',
//       'habit',
//       'medication',
//       'appointment'
//     },
//     this.alwaysShowCritical = true,
//     this.lowEnergyThreshold = 3,
//     this.highSymptomThreshold = 7,
//     this.quietHoursEnabled = false,
//     this.quietHoursStart = const TimeOfDay(hour: 22, minute: 0),
//     this.quietHoursEnd = const TimeOfDay(hour: 8, minute: 0),
//     this.loggingRemindersEnabled = false, // Disabled by default
//     this.categoryReminderTimes = const {
//       'task': TimeOfDay(hour: 9, minute: 0),
//       'habit': TimeOfDay(hour: 8, minute: 0),
//       'medication': TimeOfDay(hour: 8, minute: 0),
//       'symptom': TimeOfDay(hour: 20, minute: 0),
//       'energy': TimeOfDay(hour: 19, minute: 0),
//     },
//     this.categoryReminderDays = const {
//       'task': [1, 2, 3, 4, 5, 6, 7],
//       'habit': [1, 2, 3, 4, 5, 6, 7],
//       'medication': [1, 2, 3, 4, 5, 6, 7],
//       'symptom': [1, 2, 3, 4, 5, 6, 7],
//       'energy': [1, 2, 3, 4, 5, 6, 7],
//     },
//     this.specificItemRemindersEnabled = true,
//     this.enabledCategorySpecificReminders = const {
//       'task': true,
//       'habit': true,
//       'medication': true,
//     },
//   });

//   NotificationSettings copyWith({
//     bool? notificationsEnabled,
//     bool? soundEnabled,
//     bool? vibrationEnabled,
//     int? historyRetentionDays,
//     Set<String>? enabledCategories,
//     bool? alwaysShowCritical,
//     int? lowEnergyThreshold,
//     int? highSymptomThreshold,
//     bool? quietHoursEnabled,
//     TimeOfDay? quietHoursStart,
//     TimeOfDay? quietHoursEnd,
//     bool? loggingRemindersEnabled,
//     Map<String, TimeOfDay>? categoryReminderTimes,
//     Map<String, List<int>>? categoryReminderDays,
//     bool? specificItemRemindersEnabled,
//     Map<String, bool>? enabledCategorySpecificReminders,
//   }) {
//     return NotificationSettings(
//       notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
//       soundEnabled: soundEnabled ?? this.soundEnabled,
//       vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
//       historyRetentionDays: historyRetentionDays ?? this.historyRetentionDays,
//       enabledCategories: enabledCategories ?? this.enabledCategories,
//       alwaysShowCritical: alwaysShowCritical ?? this.alwaysShowCritical,
//       lowEnergyThreshold: lowEnergyThreshold ?? this.lowEnergyThreshold,
//       highSymptomThreshold: highSymptomThreshold ?? this.highSymptomThreshold,
//       quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
//       quietHoursStart: quietHoursStart ?? this.quietHoursStart,
//       quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
//       loggingRemindersEnabled:
//           loggingRemindersEnabled ?? this.loggingRemindersEnabled,
//       categoryReminderTimes:
//           categoryReminderTimes ?? this.categoryReminderTimes,
//       categoryReminderDays: categoryReminderDays ?? this.categoryReminderDays,
//       specificItemRemindersEnabled:
//           specificItemRemindersEnabled ?? this.specificItemRemindersEnabled,
//       enabledCategorySpecificReminders: enabledCategorySpecificReminders ??
//           this.enabledCategorySpecificReminders,
//     );
//   }
// }

// class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
//   final SharedPreferences _prefs;
//   final Ref _ref;

//   NotificationSettingsNotifier(this._prefs, this._ref)
//       : super(const NotificationSettings()) {
//     _loadSettings();
//   }

//   Future<void> _loadSettings() async {
//     // Load category reminder times
//     Map<String, TimeOfDay> reminderTimes = {};
//     Map<String, List<int>> reminderDays = {};

//     for (String category in [
//       'task',
//       'habit',
//       'medication',
//       'symptom',
//       'energy'
//     ]) {
//       final hour = _prefs.getInt('${category}_reminder_hour') ?? 9;
//       final minute = _prefs.getInt('${category}_reminder_minute') ?? 0;
//       reminderTimes[category] = TimeOfDay(hour: hour, minute: minute);

//       final days = _prefs
//               .getStringList('${category}_reminder_days')
//               ?.map(int.parse)
//               .toList() ??
//           [1, 2, 3, 4, 5, 6, 7];
//       reminderDays[category] = days;
//     }

//     // Load specific reminder settings
//     final specificRemindersEnabled =
//         _prefs.getBool('specific_item_reminders_enabled') ?? true;
//     Map<String, bool> enabledSpecificReminders = {};
//     for (String category in ['task', 'habit', 'medication']) {
//       enabledSpecificReminders[category] =
//           _prefs.getBool('${category}_specific_reminders_enabled') ?? true;
//     }

//     state = NotificationSettings(
//       notificationsEnabled: _prefs.getBool('notifications_enabled') ?? true,
//       soundEnabled: _prefs.getBool('notification_sound') ?? true,
//       vibrationEnabled: _prefs.getBool('notification_vibration') ?? true,
//       historyRetentionDays: _prefs.getInt('notification_history_days') ?? 7,
//       enabledCategories:
//           _prefs.getStringList('notification_categories')?.toSet() ??
//               {'task', 'habit', 'medication', 'appointment'},
//       alwaysShowCritical: _prefs.getBool('always_show_critical') ?? true,
//       lowEnergyThreshold: _prefs.getInt('low_energy_threshold') ?? 3,
//       highSymptomThreshold: _prefs.getInt('high_symptom_threshold') ?? 7,
//       quietHoursEnabled: _prefs.getBool('quiet_hours_enabled') ?? false,
//       quietHoursStart: TimeOfDay(
//         hour: _prefs.getInt('quiet_hours_start_hour') ?? 22,
//         minute: _prefs.getInt('quiet_hours_start_minute') ?? 0,
//       ),
//       quietHoursEnd: TimeOfDay(
//         hour: _prefs.getInt('quiet_hours_end_hour') ?? 8,
//         minute: _prefs.getInt('quiet_hours_end_minute') ?? 0,
//       ),
//       categoryReminderTimes: reminderTimes,
//       categoryReminderDays: reminderDays,
//       loggingRemindersEnabled:
//           _prefs.getBool('logging_reminders_enabled') ?? false,
//       specificItemRemindersEnabled: specificRemindersEnabled,
//       enabledCategorySpecificReminders: enabledSpecificReminders,
//     );
//   }

//   Future<void> updateSettings(NotificationSettings settings) async {
//     final oldSettings = state;
//     state = settings;

//     // Persist existing settings
//     await _prefs.setBool(
//         'notifications_enabled', settings.notificationsEnabled);
//     await _prefs.setBool('notification_sound', settings.soundEnabled);
//     await _prefs.setBool('notification_vibration', settings.vibrationEnabled);
//     await _prefs.setInt(
//         'notification_history_days', settings.historyRetentionDays);
//     await _prefs.setStringList(
//         'notification_categories', settings.enabledCategories.toList());
//     await _prefs.setBool('always_show_critical', settings.alwaysShowCritical);
//     await _prefs.setInt('low_energy_threshold', settings.lowEnergyThreshold);
//     await _prefs.setInt(
//         'high_symptom_threshold', settings.highSymptomThreshold);
//     await _prefs.setBool('quiet_hours_enabled', settings.quietHoursEnabled);
//     await _prefs.setInt(
//         'quiet_hours_start_hour', settings.quietHoursStart.hour);
//     await _prefs.setInt(
//         'quiet_hours_start_minute', settings.quietHoursStart.minute);
//     await _prefs.setInt('quiet_hours_end_hour', settings.quietHoursEnd.hour);
//     await _prefs.setInt(
//         'quiet_hours_end_minute', settings.quietHoursEnd.minute);
//     await _prefs.setBool(
//         'logging_reminders_enabled', settings.loggingRemindersEnabled);
//     await _prefs.setBool('specific_item_reminders_enabled',
//         settings.specificItemRemindersEnabled);

//     // Persist category reminder settings
//     for (String category in settings.categoryReminderTimes.keys) {
//       final time = settings.categoryReminderTimes[category]!;
//       await _prefs.setInt('${category}_reminder_hour', time.hour);
//       await _prefs.setInt('${category}_reminder_minute', time.minute);
//     }

//     for (String category in settings.categoryReminderDays.keys) {
//       final days = settings.categoryReminderDays[category]!;
//       await _prefs.setStringList(
//           '${category}_reminder_days', days.map((d) => d.toString()).toList());
//     }

//     // Persist specific reminder settings
//     for (String category in settings.enabledCategorySpecificReminders.keys) {
//       await _prefs.setBool('${category}_specific_reminders_enabled',
//           settings.enabledCategorySpecificReminders[category]!);
//     }

//     // Only reschedule if logging reminders are enabled
//     if (oldSettings.loggingRemindersEnabled !=
//             settings.loggingRemindersEnabled ||
//         (settings.loggingRemindersEnabled &&
//             (oldSettings.enabledCategories != settings.enabledCategories ||
//                 oldSettings.categoryReminderTimes !=
//                     settings.categoryReminderTimes ||
//                 oldSettings.categoryReminderDays !=
//                     settings.categoryReminderDays))) {
//       try {
//         final notificationService = _ref.read(notificationServiceProvider);
//         await notificationService.onSettingsChanged();
//       } catch (e) {
//         print('❌ Failed to update notification schedules: $e');
//       }
//     }
//   }
// }

// final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
//   throw UnimplementedError('Should be overridden in app bootstrap');
// });

// final notificationSettingsProvider =
//     StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
//         (ref) {
//   final prefs = ref.watch(sharedPreferencesProvider);
//   return NotificationSettingsNotifier(prefs, ref);
// });
